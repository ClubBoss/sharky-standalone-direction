#!/usr/bin/env python3
"""Create a local contact sheet and zip for Act0 screen review captures."""

from __future__ import annotations

import json
import subprocess
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


SURFACE_GROUPS = {
    "core": (
        ("home", "Home"),
        ("learn", "Learn"),
        ("practice", "Practice"),
        ("review", "Review"),
        ("profile", "Profile"),
    ),
    "core_fast": (
        ("home", "Home"),
        ("learn", "Learn"),
        ("practice", "Practice"),
        ("review", "Review"),
        ("profile", "Profile"),
    ),
    "runner_fast": (
        ("decision", "Decision choice"),
        ("correct_feedback", "Correct feedback"),
        ("wrong_feedback", "Wrong feedback"),
    ),
    "first_week_fast": (
        ("placement", "Placement"),
        ("welcome_decision", "Welcome decision"),
        ("welcome_feedback", "Welcome feedback"),
        ("welcome_handoff", "Welcome handoff"),
        ("decision", "W1 decision"),
        ("correct_feedback", "Correct feedback"),
        ("wrong_feedback", "Wrong feedback"),
        ("repair_focus", "Repair focus"),
        ("repair_result", "Repair result"),
        ("session_repair", "Session repair"),
        ("review_handoff", "Review handoff"),
        ("profile_return", "Profile return"),
    ),
}
DEFAULT_GROUP = "core"
DEVICE = "compact"
TARGET_SCREEN_WIDTH = 760
PADDING = 44
GAP = 38
LABEL_HEIGHT = 64
BACKGROUND = (8, 18, 33)
PANEL = (14, 31, 52)
TEXT = (235, 243, 255)
MUTED = (142, 159, 181)


def main(argv: list[str]) -> int:
    if len(argv) not in (2, 3, 4) or argv[1] != "current":
        print(
            "Usage: ./tools/package_screen_review_v1.sh current [core|core_fast|runner_fast|first_week_fast] [capture_dir]",
            file=sys.stderr,
        )
        return 64

    root = Path(__file__).resolve().parents[1]
    group = argv[2] if len(argv) >= 3 and argv[2] else DEFAULT_GROUP
    if group not in SURFACE_GROUPS:
        print(f"Unsupported screen review group: {group}", file=sys.stderr)
        return 64

    if len(argv) == 4 and argv[3]:
        output_dir = Path(argv[3]).expanduser().resolve()
    else:
        grouped_dir = root / "output" / "screen_review" / "current" / group
        legacy_dir = root / "output" / "screen_review" / "current"
        output_dir = grouped_dir if grouped_dir.exists() else legacy_dir
    if not output_dir.exists():
        print(f"Missing capture output directory: {output_dir}", file=sys.stderr)
        return 1

    entries = _load_entries(output_dir, SURFACE_GROUPS[group])
    if not entries:
        print("No compact Act0 screenshots found to package.", file=sys.stderr)
        return 1

    contact_sheet = output_dir / "contact_sheet.png"
    zip_path = output_dir / f"screen_review_{group}.zip"
    readme = output_dir / "README.txt"
    index = output_dir / "screen_review_index.json"

    _write_contact_sheet(entries, contact_sheet)
    metadata = _metadata(root, entries, contact_sheet, zip_path, group)
    readme.write_text(_readme_text(metadata), encoding="utf-8")
    index.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    _write_zip(entries, contact_sheet, readme, index, output_dir / "manifest.json", zip_path)

    print(contact_sheet)
    print(zip_path)
    return 0


def _load_entries(
    output_dir: Path,
    surfaces: tuple[tuple[str, str], ...],
) -> list[tuple[str, str, Path]]:
    entries: list[tuple[str, str, Path]] = []
    for surface, label in surfaces:
        path = output_dir / f"{DEVICE}.{surface}.png"
        if path.exists() and path.stat().st_size > 0:
            entries.append((surface, label, path))
    return entries


def _font(size: int, *, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Helvetica.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
    ]
    for candidate in candidates:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def _write_contact_sheet(entries: list[tuple[str, str, Path]], output: Path) -> None:
    label_font = _font(36, bold=True)
    meta_font = _font(24)
    scaled: list[tuple[str, str, Image.Image]] = []
    for surface, label, path in entries:
        image = Image.open(path).convert("RGB")
        ratio = TARGET_SCREEN_WIDTH / image.width
        size = (TARGET_SCREEN_WIDTH, round(image.height * ratio))
        scaled.append((surface, label, image.resize(size, Image.Resampling.LANCZOS)))

    columns = 2 if len(scaled) > 1 else 1
    cell_width = TARGET_SCREEN_WIDTH
    cell_height = max(image.height for _, _, image in scaled) + LABEL_HEIGHT
    rows = (len(scaled) + columns - 1) // columns
    width = (PADDING * 2) + (columns * cell_width) + ((columns - 1) * GAP)
    height = (PADDING * 2) + (rows * cell_height) + ((rows - 1) * GAP)

    sheet = Image.new("RGB", (width, height), BACKGROUND)
    draw = ImageDraw.Draw(sheet)
    for index, (surface, label, image) in enumerate(scaled):
        row = index // columns
        column = index % columns
        x = PADDING + column * (cell_width + GAP)
        y = PADDING + row * (cell_height + GAP)
        draw.rounded_rectangle(
            [x - 12, y - 12, x + cell_width + 12, y + cell_height + 12],
            radius=24,
            fill=PANEL,
        )
        draw.text((x, y), label, font=label_font, fill=TEXT)
        draw.text((x + 160, y + 8), f"compact.{surface}.png", font=meta_font, fill=MUTED)
        sheet.paste(image, (x, y + LABEL_HEIGHT))

    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, format="PNG", optimize=True)


def _metadata(
    root: Path,
    entries: list[tuple[str, str, Path]],
    contact_sheet: Path,
    zip_path: Path,
    group: str,
) -> dict[str, object]:
    return {
        "packet": f"screen_review_{group}",
        "group": group,
        "created_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "git_commit": _git(root, "rev-parse", "HEAD"),
        "git_status": "clean" if _git(root, "status", "--short") == "" else "dirty",
        "source_command": _source_command(group),
        "package_command": f"./tools/package_screen_review_v1.sh current {group}",
        "surfaces": [surface for surface, _, _ in entries],
        "files": [str(path.relative_to(root)) for _, _, path in entries],
        "contact_sheet": str(contact_sheet.relative_to(root)),
        "zip": str(zip_path.relative_to(root)),
        "note": "Generated packet artifacts are local-only and uncommitted.",
    }


def _source_command(group: str) -> str:
    if group == "core_fast":
        return "./tools/screen_review_fast_v1.sh core compact"
    if group == "runner_fast":
        return "./tools/screen_review_fast_v1.sh runner compact"
    if group == "first_week_fast":
        return "./tools/screen_review_fast_v1.sh first_week compact"
    return f"./tools/screen_review_v1.sh {group} compact"


def _git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), *args],
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip()


def _readme_text(metadata: dict[str, object]) -> str:
    return "\n".join(
        [
            "Act0 Screen Review Packet v1",
            "",
            f"Created: {metadata['created_at']}",
            f"Git commit: {metadata['git_commit']}",
            f"Git status: {metadata['git_status']}",
            f"Capture command: {metadata['source_command']}",
            f"Package command: {metadata['package_command']}",
            "",
            "Use contact_sheet.png for quick visual review.",
            "Use the original compact.*.png files for detailed per-screen inspection.",
            "Generated packet artifacts are local-only and should not be committed.",
            "",
        ]
    )


def _write_zip(
    entries: list[tuple[str, str, Path]],
    contact_sheet: Path,
    readme: Path,
    index: Path,
    manifest: Path,
    zip_path: Path,
) -> None:
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for _, _, path in entries:
            archive.write(path, path.name)
        if manifest.exists():
            archive.write(manifest, manifest.name)
        archive.write(contact_sheet, contact_sheet.name)
        archive.write(readme, readme.name)
        archive.write(index, index.name)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
