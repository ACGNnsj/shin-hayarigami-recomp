#!/bin/bash
# Build build/v0/haya.exe for the Shin Hayarigami 1+2 port (ExeFS + 2 NROs, title 010005F00E036000).
set -e
cd /d/consoles/ns/shin-hayarigami-recomp 2>/dev/null || cd "$(dirname "$0")/.."
CL=/c/msys64/ucrt64/bin/clang.exe
INC='-Iframework/runtime -Ibuild/gen-shin -Ibuild/v0 -I/c/msys64/ucrt64/include -I/c/msys64/ucrt64/include/vma -Iframework/runtime/third_party/imgui -Iframework/runtime/third_party/imgui/backends'
# 1. runtime library for this title
echo '== rtlib'
(cd framework/tools && /d/consoles/ns/hayarigami-recomp/.venv/Scripts/python.exe build_game.py --make-runtime-lib --expected ../../data/expected-shin.json --out ../../build/rtlib --jobs 12 >/dev/null)
# 2. platform, menu and Dear ImGui objects
mkdir -p build/rtobj2/platform build/rtobj2/ui build/rtobj2/imgui build/rtobj2/backends
for f in framework/runtime/platform/common.c framework/runtime/platform/win32.c; do $CL -c -O2 -g -Wall -fno-strict-aliasing -march=x86-64-v3 $INC $f -o build/rtobj2/platform/$(basename $f .c).o; done
for f in framework/runtime/ui/*.cpp; do b=$(basename $f .cpp); case $b in *_sdl) continue;; esac; $CL -c -O2 -g -Wall -fno-strict-aliasing -march=x86-64-v3 -std=c++20 $INC $f -o build/rtobj2/ui/$b.o; done
for f in framework/runtime/third_party/imgui/*.cpp; do $CL -c -O2 -g -Wall -fno-strict-aliasing -march=x86-64-v3 -std=c++20 $INC $f -o build/rtobj2/imgui/$(basename $f .cpp).o; done
$CL -c -O2 -g -Wall -fno-strict-aliasing -march=x86-64-v3 -std=c++20 $INC framework/runtime/third_party/imgui/backends/imgui_impl_vulkan.cpp -o build/rtobj2/backends/imgui_impl_vulkan.o
# 3. RomFS index + module glue first: romfs.c includes the generated romfs_config.h
echo '== romfs+glue'
/d/consoles/ns/hayarigami-recomp/.venv/Scripts/python.exe framework/tools/romfs_index.py --romfs build/extracted/shin/romfs --out build/v0 >/dev/null
/d/consoles/ns/hayarigami-recomp/.venv/Scripts/python.exe tools/gen_modules.py >/dev/null
$CL -c -O1 -fno-strict-aliasing -march=x86-64-v3 -Iframework/runtime -Ibuild/gen-shin build/v0/modules.c -o build/v0/modules.o
# 4. patches.c, romfs.c and ov_zstd.c
for f in patches romfs ov_zstd; do $CL -c -O2 -g -Wall -fno-strict-aliasing -march=x86-64-v3 $INC framework/runtime/$f.c -o build/rtobj2/$f.o; done
# 5. link
echo '== link'
$CL -fuse-ld=lld -Wl,--stack,16777216 -Wl,--subsystem,windows -o build/v0/haya.exe \
  build/rtlib/obj/runtime/*.o build/rtobj2/*.o build/rtobj2/platform/*.o build/rtobj2/ui/*.o build/rtobj2/imgui/*.o build/rtobj2/backends/*.o \
  $(find build/genobj -name '*.o') build/v0/modules.o \
  -lpsapi -lbcrypt -lvulkan-1 -luser32 -lgdi32 -ldwmapi -lwinmm -lSDL3 -lopus -l:libvpx.a -lmfplat -lmfuuid -lole32 -l:libzstd.a -l:libstdc++.a -l:libwinpthread.a
# 6. shader translator (borrowed from hayarigami-recomp; keeps --seconds runs from going all-black)
mkdir -p build/xlate
for f in xc2_xlate.exe xc2_xlate.id; do
  g=${f/xc2_xlate/haya_xlate};
  if [ ! -f build/xlate/$g ]; then cp /d/consoles/ns/hayarigami-recomp/build/xlate/$f build/xlate/$g; fi
done
# 7. save/profile tree (fs MountSave FATALs if missing; pwsh-spawned runs cannot mkdir under repo taint)
mkdir -p build/profile/save build/profile/save-backup build/profile/save-tx build/profile/temp build/profile/cache
# 8. icon (procedural red-brush mark, framework/runtime/haya.ico; title lives in the window code)
if [ ! -f framework/runtime/haya.ico ]; then /d/consoles/ns/hayarigami-recomp/.venv/Scripts/python.exe tools/make_haya_icon.py >/dev/null; fi
ls -l build/v0/haya.exe build/xlate/
