// nn::ro overrides: the runtime module loader. main, subsdk0, sdk and the game's NROs (tfoaf1, tfoaf2) are
// statically linked at the layout bases, so loading is a no-op success and symbol lookup answers from the
// loader's global symbol tables, which already bind every module in load order (loader.c).
#include "host.h"

static void ro_ok(Cpu *c) { ret_x(c, 0); }

static void ro_lookup(Cpu *c, uint64_t name_addr, uint64_t out) {
    const char *name = (const char *)(uintptr_t)name_addr;
    uint64_t a = ldr_symbol(name);
    if (!a) rt_fatal("nn::ro::LookupSymbol: %s is not in any loaded module", name);
    ST64(out, a);
    ret_x(c, 0);
}

// Result LookupSymbol(uintptr_t *out, const char *name)
static void ro_lookup_symbol(Cpu *c) { ro_lookup(c, c->x[1], c->x[0]); }

// Result LookupModuleSymbol(uintptr_t *out, const Module *, const char *name): the module is already linked,
// so the name resolves the same global tables regardless of which module the game asks about.
static void ro_lookup_module(Cpu *c) { ro_lookup(c, c->x[2], c->x[0]); }

// Result LoadModule(Module *, const void *nro, void *buffer, size_t, int): the NRO is linked at its layout base
// already; the game's buffers stay untouched and later lookups hit the static tables.
static void ro_loaded(Cpu *c) { ret_x(c, 0); }

// void Initialize(), void InitializeWithPortName(const char *): no service to open
HOST_OVERRIDE("_ZN2nn2ro10InitializeEv", ro_ok);
HOST_OVERRIDE("_ZN2nn2ro22InitializeWithPortNameEPKc", ro_ok);
// Result GetBufferSize(size_t *out, const void *nro)
HOST_OVERRIDE("_ZN2nn2ro13GetBufferSizeEPmPKv", ro_ok);
// Result LookupSymbol(uintptr_t *out, const char *) / LookupModuleSymbol(uintptr_t *, const Module *, const char *)
HOST_OVERRIDE("_ZN2nn2ro12LookupSymbolEPmPKc", ro_lookup_symbol);
HOST_OVERRIDE("_ZN2nn2ro18LookupModuleSymbolEPmPKNS0_6ModuleEPKc", ro_lookup_module);
// Result RegisterModuleInfo(RegistrationInfo *, const void *) / UnregisterModuleInfo(RegistrationInfo *)
HOST_OVERRIDE("_ZN2nn2ro18RegisterModuleInfoEPNS0_16RegistrationInfoEPKv", ro_ok);
HOST_OVERRIDE("_ZN2nn2ro20UnregisterModuleInfoEPNS0_16RegistrationInfoE", ro_ok);
HOST_OVERRIDE("_ZN2nn2ro10LoadModuleEPNS0_6ModuleEPKvPvmi", ro_loaded);
HOST_OVERRIDE("_ZN2nn2ro10LoadModuleEPNS0_6ModuleEPKvPvmib", ro_loaded);
