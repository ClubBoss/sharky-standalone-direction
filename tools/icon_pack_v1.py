#!/usr/bin/env python3
"""Generate or check the iOS AppIcon set from one opaque 1024px PNG."""

import argparse
from decimal import Decimal
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

try:
    from PIL import Image
except ImportError:
    Image = None

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "assets/skin_v1/app_icon.png"
ICON_SET = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
MASTER_SIZE = (1024, 1024)


def icon_sizes(icon_set):
    """Deduplicate filenames shared between iPhone and iPad slots."""
    sizes = {}
    for entry in json.loads((icon_set / "Contents.json").read_text())["images"]:
        name = entry["filename"]
        if Path(name).name != name or not name.endswith(".png"):
            raise ValueError(f"Invalid icon filename: {name}")
        scale = Decimal(entry["scale"].removesuffix("x"))
        pixels = tuple(Decimal(side) * scale for side in entry["size"].split("x"))
        if len(pixels) != 2 or any(p <= 0 or p != int(p) for p in pixels):
            raise ValueError(f"Invalid pixel size for {name}: {pixels}")
        size = tuple(map(int, pixels))
        if name in sizes and sizes[name] != size:
            raise ValueError(f"Conflicting sizes for {name}")
        sizes[name] = size
    if not sizes:
        raise ValueError("Contents.json has no icons")
    return sizes


def sips(*args):
    if sys.platform != "darwin" or not shutil.which("sips"):
        raise ValueError("Install Pillow or run on macOS with sips available")
    return subprocess.run(["sips", *map(str, args)], check=True,
                          capture_output=True, text=True).stdout


def check_png(path, expected_size):
    if Image is not None:
        with Image.open(path) as image:
            kind = image.format
            size = image.size
            alpha = "A" in image.getbands() or "transparency" in image.info
            image.verify()
    else:
        result = sips("-g", "format", "-g", "pixelWidth", "-g", "pixelHeight",
                      "-g", "hasAlpha", path)
        fields = dict(line.strip().split(": ", 1) for line in result.splitlines()
                      if line.startswith("  ") and ": " in line)
        kind = fields["format"].upper()
        size = (int(fields["pixelWidth"]), int(fields["pixelHeight"]))
        alpha = fields["hasAlpha"] != "no"
    if kind != "PNG":
        raise ValueError(f"{path}: expected PNG, got {kind}")
    if size != expected_size:
        raise ValueError(f"{path}: expected {expected_size}, got {size}")
    if alpha:
        raise ValueError(f"{path}: alpha channel or transparency is not allowed")


def generate(source, icon_set, sizes):
    # Stage the entire set before replacing any current icons.
    with tempfile.TemporaryDirectory(dir=icon_set) as temporary:
        staging = Path(temporary)
        if Image is not None:
            with Image.open(source) as image:
                rgb = image.convert("RGB")
                for name, size in sizes.items():
                    rgb.resize(size, Image.Resampling.LANCZOS).save(staging / name)
        else:
            for name, (width, height) in sizes.items():
                sips("-z", height, width, source, "--out", staging / name)
        for name, size in sizes.items():
            check_png(staging / name, size)
        for name in sizes:
            (staging / name).replace(icon_set / name)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, nargs="?", default=DEFAULT_SOURCE,
                        help="1024x1024 opaque PNG (default: B104 appIcon slot)")
    parser.add_argument("--check", action="store_true",
                        help="Validate source and existing icon set without writing")
    parser.add_argument("--icon-set", type=Path, default=ICON_SET,
                        help="AppIcon directory (defaults to the iOS Runner set)")
    args = parser.parse_args(argv)
    try:
        check_png(args.source, MASTER_SIZE)
        sizes = icon_sizes(args.icon_set)
        if not args.check:
            generate(args.source, args.icon_set, sizes)
        for name, size in sizes.items():
            check_png(args.icon_set / name, size)
    except (OSError, ValueError, KeyError, ArithmeticError, subprocess.CalledProcessError) as error:
        print(f"AppIcon: {error}", file=sys.stderr)
        return 1
    print(f"AppIcon: {'checked' if args.check else 'generated'} {len(sizes)} opaque PNGs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
