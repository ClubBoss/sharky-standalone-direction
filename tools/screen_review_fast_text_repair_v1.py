#!/usr/bin/env python3
"""Repair Flutter-test Ahem button labels in fast screen-review PNGs."""

from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


PIXEL_RATIO = 2


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(
            "Usage: tools/screen_review_fast_text_repair_v1.py <output_dir> compact",
            file=sys.stderr,
        )
        return 64
    output_dir = Path(argv[1]).expanduser().resolve()
    device = argv[2]
    if device != "compact":
        print(f"Unsupported device for fast text repair: {device}", file=sys.stderr)
        return 64
    if not output_dir.exists():
        print(f"Missing output directory: {output_dir}", file=sys.stderr)
        return 1

    repaired = 0
    for overlay in sorted(output_dir.glob(f"{device}.*.png.text_overlays.json")):
        png = output_dir / overlay.name.removesuffix(".text_overlays.json")
        if not png.exists():
            continue
        repaired += _repair_png(png, overlay)
        overlay.unlink(missing_ok=True)

    print(f"screen_review_fast_text_repair_v1: repaired {repaired} labels")
    return 0


def _repair_png(png: Path, overlay: Path) -> int:
    entries = json.loads(overlay.read_text(encoding="utf-8"))
    if not entries:
        return 0
    image = Image.open(png).convert("RGBA")
    draw = ImageDraw.Draw(image)
    count = 0
    for entry in entries:
        text = str(entry.get("text", "")).strip()
        if not text:
            continue
        left = int(round(float(entry["left"]) * PIXEL_RATIO))
        top = int(round(float(entry["top"]) * PIXEL_RATIO))
        width = int(round(float(entry["width"]) * PIXEL_RATIO))
        height = int(round(float(entry["height"]) * PIXEL_RATIO))
        if width <= 0 or height <= 0:
            continue
        bbox = _clip_bbox(
            image,
            (
                left - 4,
                top - 3,
                left + width + 4,
                top + height + 3,
            ),
        )
        background = _background_color(image, bbox)
        draw.rectangle(bbox, fill=background)

        font_size = max(8, int(round(float(entry.get("fontSize", 14)) * PIXEL_RATIO)))
        weight = int(entry.get("fontWeight", 400))
        font = _font(font_size, bold=weight >= 700)
        text_color = _parse_argb(str(entry.get("color", "#ffffffff")))
        _draw_centered(draw, bbox, text, font, text_color)
        count += 1
    image.convert("RGB").save(png, format="PNG", optimize=True)
    return count


def _clip_bbox(image: Image.Image, bbox: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    left, top, right, bottom = bbox
    return (
        max(0, min(image.width, left)),
        max(0, min(image.height, top)),
        max(0, min(image.width, right)),
        max(0, min(image.height, bottom)),
    )


def _background_color(image: Image.Image, bbox: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    left, top, right, bottom = bbox
    samples: list[tuple[int, int, int, int]] = []
    mid_y = (top + bottom) // 2
    for x in (left - 8, left - 4, right + 4, right + 8):
        if 0 <= x < image.width and 0 <= mid_y < image.height:
            samples.append(image.getpixel((x, mid_y)))
    mid_x = (left + right) // 2
    for y in (top - 6, bottom + 6):
        if 0 <= mid_x < image.width and 0 <= y < image.height:
            samples.append(image.getpixel((mid_x, y)))
    if not samples:
        samples.append(image.getpixel((max(0, min(image.width - 1, left)), max(0, min(image.height - 1, top)))))
    return Counter(samples).most_common(1)[0][0]


def _font(size: int, *, bold: bool) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/SFNS.ttf",
    ]
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def _parse_argb(value: str) -> tuple[int, int, int, int]:
    raw = value.strip().removeprefix("#")
    if len(raw) == 8:
        alpha = int(raw[0:2], 16)
        red = int(raw[2:4], 16)
        green = int(raw[4:6], 16)
        blue = int(raw[6:8], 16)
        return red, green, blue, alpha
    if len(raw) == 6:
        red = int(raw[0:2], 16)
        green = int(raw[2:4], 16)
        blue = int(raw[4:6], 16)
        return red, green, blue, 255
    return 255, 255, 255, 255


def _draw_centered(
    draw: ImageDraw.ImageDraw,
    bbox: tuple[int, int, int, int],
    text: str,
    font: ImageFont.FreeTypeFont | ImageFont.ImageFont,
    fill: tuple[int, int, int, int],
) -> None:
    left, top, right, bottom = bbox
    max_width = max(1, right - left - 8)
    while True:
        text_bbox = draw.textbbox((0, 0), text, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]
        if text_width <= max_width or getattr(font, "size", 8) <= 8:
            break
        font = _font(getattr(font, "size", 8) - 1, bold=True)
    x = left + ((right - left) - text_width) / 2
    y = top + ((bottom - top) - text_height) / 2 - 1
    draw.text((x, y), text, font=font, fill=fill)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
