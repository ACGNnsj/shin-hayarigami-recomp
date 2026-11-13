# NRO loader for game-shipped code modules (Shin Hayarigami 1+2 pack: nro/Tfoaf1.nro, Tfoaf2.nro).
"""NRO loader: build the memory image, parse MOD0/dynamic info. Same consumer surface as nso.Nso."""
import hashlib
import struct
import sys
from collections import Counter

DT_NULL, DT_NEEDED, DT_PLTRELSZ, DT_HASH, DT_STRTAB, DT_SYMTAB, DT_RELA, DT_RELASZ = 0, 1, 2, 4, 5, 6, 7, 8
DT_STRSZ, DT_JMPREL, DT_RELACOUNT = 10, 23, 0x6FFFFFF9
DT_RELRSZ, DT_RELR, DT_GNU_HASH = 0x23, 0x24, 0x6FFFFEF5
R_AARCH64_ABS64, R_AARCH64_GLOB_DAT, R_AARCH64_JUMP_SLOT, R_AARCH64_RELATIVE = 257, 1025, 1026, 1027


class Nro:
    """One game NRO. The file maps whole (the 16-byte per-game wrapper stays a mapped prefix, like the
    NRO header itself); the dynamic values are image offsets, like Nso. Differences from NSO: segments are
    stored uncompressed, there is no DT_NEEDED, and MOD0 sits at a fixed ro offset instead of .text start."""

    def __init__(self, path):
        raw = open(path, 'rb').read()
        base = 16 if raw[16:20] == b'NRO0' else 0
        assert raw[base:base + 4] == b'NRO0', path
        self.build_id = hashlib.sha256(raw).hexdigest()
        text_off, text_size, ro_off, ro_size, data_off, data_size, bss_size = \
            struct.unpack_from('<IIIIIII', raw, base + 0x10)
        self.text = (text_off, text_size)
        self.rodata = (ro_off, ro_size)
        self.data = (data_off, data_size)
        self.bss_size = bss_size
        end = data_off + data_size + bss_size
        self.size = (end + 0xFFF) & ~0xFFF
        img = bytearray(self.size)
        img[:len(raw)] = raw[:self.size]
        self.image = img
        self._parse_mod0(ro_off)

    def u32(self, off): return struct.unpack_from('<I', self.image, off)[0]
    def u64(self, off): return struct.unpack_from('<Q', self.image, off)[0]

    def _mod0_candidate(self, mod0):
        if self.image[mod0:mod0 + 4] != b'MOD0':
            return None
        rel = lambda i: mod0 + struct.unpack_from('<i', self.image, mod0 + 4 + i * 4)[0]
        dyn = rel(0)
        if dyn <= 0 or dyn + 32 > len(self.image):
            return None
        tags = set()
        off = dyn
        for _ in range(24):
            tag = self.u64(off)
            tags.add(tag)
            if tag == DT_NULL:
                break
            off += 16
        else:
            return None
        if DT_STRTAB not in tags or DT_SYMTAB not in tags:
            return None
        return dyn

    def _parse_mod0(self, ro_off):
        dyn = self._mod0_candidate(ro_off + 0x34)
        if dyn is None:
            dyn = None
            i = bytes(self.image).find(b'MOD0')
            while i >= 0:
                if self._mod0_candidate(i) is not None:
                    dyn = self._mod0_candidate(i)
                    break
                i = bytes(self.image).find(b'MOD0', i + 1)
        assert dyn is not None, 'no MOD0 with a usable dynamic table'
        self.dynamic = dyn
        # NRO MOD0 carries no eh_frame range the lifter could use; Module falls back to exports and relocs.
        self.bss_start, self.bss_end = 0, 0
        self.eh_start, self.eh_end, self.module_obj = 0, 0, 0
        dyn_map = {}
        needed = []
        off = self.dynamic
        while True:
            tag, val = self.u64(off), self.u64(off + 8)
            off += 16
            if tag == DT_NULL:
                break
            if tag == DT_NEEDED:
                needed.append(val)
            dyn_map.setdefault(tag, val)
        self.dyn = dyn_map
        strtab = dyn_map.get(DT_STRTAB, 0)
        self.strtab = strtab
        self.needed = [self.cstr(strtab + n) for n in needed]
        self.syms = []
        nsyms = self.symbol_count()
        if nsyms and DT_SYMTAB in dyn_map:
            st = dyn_map[DT_SYMTAB]
            for i in range(nsyms):
                o = st + i * 24
                name, info, other, shndx = struct.unpack_from('<IBBH', self.image, o)
                value, size = struct.unpack_from('<QQ', self.image, o + 8)
                self.syms.append((self.cstr(strtab + name), info, shndx, value, size))
        self.relocs = []
        for base_tag, size_tag in ((DT_RELA, DT_RELASZ), (DT_JMPREL, DT_PLTRELSZ)):
            if base_tag in dyn_map:
                b, n = dyn_map[base_tag], dyn_map[size_tag] // 24
                for i in range(n):
                    r_off, r_info, r_add = struct.unpack_from('<QQq', self.image, b + i * 24)
                    self.relocs.append((r_off, r_info & 0xFFFFFFFF, r_info >> 32, r_add))
        if DT_RELR in dyn_map:
            where = 0
            for i in range(dyn_map[DT_RELRSZ] // 8):
                e = self.u64(dyn_map[DT_RELR] + i * 8)
                if e & 1 == 0:
                    self.relocs.append((e, R_AARCH64_RELATIVE, 0, self.u64(e)))
                    where = e + 8
                    continue
                for k in range(63):
                    if e >> (k + 1) & 1:
                        a = where + k * 8
                        self.relocs.append((a, R_AARCH64_RELATIVE, 0, self.u64(a)))
                where += 63 * 8

    def symbol_count(self):
        dyn = self.dyn
        if DT_HASH in dyn:
            return self.u32(dyn[DT_HASH] + 4)
        if DT_GNU_HASH not in dyn:
            return 0
        h = dyn[DT_GNU_HASH]
        nbuckets, symoffset, bloom_size = self.u32(h), self.u32(h + 4), self.u32(h + 8)
        buckets = h + 16 + bloom_size * 8
        last = max([self.u32(buckets + 4 * i) for i in range(nbuckets)] + [0])
        if last < symoffset:
            return symoffset
        chains = buckets + 4 * nbuckets
        while not self.u32(chains + 4 * (last - symoffset)) & 1:
            last += 1
        return last + 1

    def cstr(self, off):
        end = bytes(self.image).index(b'\0', off)
        return self.image[off:end].decode('utf-8', 'replace')

    def imports(self):
        return [s for s in self.syms if s[0] and s[2] == 0]

    def exports(self):
        return [s for s in self.syms if s[0] and s[2] != 0]


if __name__ == '__main__':
    for p in sys.argv[1:]:
        n = Nro(p)
        print(f'== {p}  image 0x{n.size:x}')
        print(f'  text 0x{n.text[0]:x}+0x{n.text[1]:x}  ro 0x{n.rodata[0]:x}+0x{n.rodata[1]:x}  '
              f'data 0x{n.data[0]:x}+0x{n.data[1]:x}  bss 0x{n.bss_size:x}')
        print(f'  needed {n.needed}  syms {len(n.syms)}  imports {len(n.imports())}  exports {len(n.exports())}')
        print(f'  relocs {dict(Counter(r[1] for r in n.relocs))}')
