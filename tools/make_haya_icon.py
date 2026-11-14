#!/usr/bin/env python3
"""Draw framework/runtime/haya.ico from tools/hayalogo.jpg (official SHIN HAYARIGAMI 1.2 Pack logo).

Crops the red "1.2 Pack" mark (readable at 16px), scales with LANCZOS and writes a multi-size ICO
via PIL, plus a PNG preview into build/v0 (git-ignored). Needs PIL in the lifter venv.

    .venv\\Scripts\\python tools\\make_haya_icon.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "framework" / "runtime"
PREVIEW_DIR = ROOT / "build" / "v0"
SRC = Path(__file__).resolve().parent / "hayalogo.jpg"
SIZES = (16, 24, 32, 48, 64, 256)
# whole official logo: center square of the full art (girl + full SHIN HAYARIGAMI 1.2 Pack lettering)
CROP = None


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    PREVIEW_DIR.mkdir(parents=True, exist_ok=True)
    img = Image.open(SRC).convert("RGB")
    side = min(img.size)
    left = (img.size[0] - side) // 2
    top = (img.size[1] - side) // 2
    crop = img.crop((left, top, left + side, top + side)) if CROP is None else img.crop(CROP)
    big = crop.resize((256, 256), Image.LANCZOS)
    big.save(OUT_DIR / "haya_icon_preview.png")
    big.save(OUT_DIR / "haya.ico", sizes=[(n, n) for n in SIZES])
    print(f"framework/runtime/haya.ico: {len(SIZES)} sizes from {SRC.name}")


if __name__ == "__main__":
    main()
