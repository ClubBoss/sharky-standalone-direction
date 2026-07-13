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
    "alpha_journey_fast": (
        ("placement", "Entry / placement"),
        ("welcome", "Welcome"),
        ("home", "Personalized next action"),
        ("learn", "Learn"),
        ("learn_detail", "Theory / teaching detail"),
        ("play", "Live unanswered decision"),
        ("feedback", "Feedback"),
        ("practice_repair", "Targeted repair / recheck"),
        ("completion_payoff", "Completion payoff"),
        ("summary", "Session summary"),
        ("review_profile", "Return / profile"),
        ("w12_terminal", "W12 terminal"),
    ),
    "core": (
        ("home", "Home"),
        ("learn", "Learn"),
        ("learn_detail", "Learn detail"),
        ("practice", "Practice"),
        ("review", "Review"),
        ("profile", "Profile"),
    ),
    "core_fast": (
        ("home", "Home"),
        ("learn", "Learn"),
        ("learn_detail", "Learn detail"),
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
        ("session_summary", "Session summary"),
        ("review_handoff", "Review handoff"),
        ("profile_return", "Profile return"),
    ),
    "day2_return_fast": (
        ("open_repair_source", "First-session open repair"),
        ("return_home", "Day 2 Home repair priority"),
        ("practice_repair_target", "Practice same repair target"),
        ("review_continuation", "Review repair continuation"),
        ("profile_not_clear", "Profile active repair proof"),
    ),
    "profile_evidence_fast": (
        ("profile_evidence", "Profile evidence signal"),
    ),
    "full_scroll_fast": (
        ("home.scroll_01_top", "Home - top"),
        ("home.scroll_02_mid", "Home - middle"),
        ("home.scroll_03_bottom", "Home - bottom"),
        ("learn.scroll_01_top", "Learn - top"),
        ("learn.scroll_02_mid", "Learn - middle"),
        ("learn.scroll_03_bottom", "Learn - bottom"),
        ("practice.scroll_01_top", "Practice - top"),
        ("practice.scroll_02_mid", "Practice - middle"),
        ("practice.scroll_03_bottom", "Practice - bottom"),
        ("review.scroll_01_top", "Review - top"),
        ("review.scroll_02_mid", "Review - middle"),
        ("review.scroll_03_bottom", "Review - bottom"),
        ("profile.scroll_01_top", "Profile - top"),
        ("profile.scroll_02_mid", "Profile - middle"),
        ("profile.scroll_03_bottom", "Profile - bottom"),
        ("session_summary.scroll_01_top", "Session summary - top"),
        ("session_summary.scroll_02_mid", "Session summary - middle"),
        ("session_summary.scroll_03_bottom", "Session summary - bottom"),
    ),
    "route_w7_w12_fast": (
        ("w7_first_route_task", "W7 - first route task"),
        ("w8_first_route_task", "W8 - first route task"),
        ("w9_first_route_task", "W9 - first route task"),
        ("w10_first_route_task", "W10 - first route task"),
        ("w11_danger_texture_task", "W11 - danger texture task"),
        ("w12_first_review_task", "W12 - first review task"),
        ("w12_payoff_completion", "W12 - payoff completion"),
        ("volume_i_terminal_review", "Volume I terminal review"),
        ("no_w13_terminal_state", "No W13 terminal state"),
    ),
    "active_route_w7_w12_fast": (
        ("w7_first_route_task_table", "W7 - first route task table"),
        ("w7_first_route_task_copy_detail", "W7 - first route task copy detail"),
        ("w8_route_task_table", "W8 - route task table"),
        ("w8_route_task_copy_detail", "W8 - route task copy detail"),
        ("w9_first_route_task_table", "W9 - first route task table"),
        ("w9_first_route_task_copy_detail", "W9 - first route task copy detail"),
        ("w10_route_task_table", "W10 - route task table"),
        ("w10_route_task_copy_detail", "W10 - route task copy detail"),
        ("w11_danger_texture_task_table", "W11 - danger texture task table"),
        (
            "w11_danger_texture_task_copy_detail",
            "W11 - danger texture task copy detail",
        ),
        ("w12_first_review_task_table", "W12 - first review task table"),
        (
            "w12_first_review_task_copy_detail",
            "W12 - first review task copy detail",
        ),
        ("w12_payoff_completion_table", "W12 - payoff completion table"),
        (
            "w12_payoff_completion_copy_detail",
            "W12 - payoff completion copy detail",
        ),
        ("volume_i_terminal_review_table", "Volume I terminal review table"),
        ("terminal_no_w13_copy_detail", "Terminal no-W13 copy detail"),
    ),
}
DEFAULT_GROUP = "core"
DEFAULT_DEVICE = "compact"
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
            "Usage: ./tools/package_screen_review_v1.sh current [core|core_fast|runner_fast|first_week_fast|day2_return_fast|profile_evidence_fast|full_scroll_fast] [capture_dir]",
            file=sys.stderr,
        )
        return 64

    root = Path(__file__).resolve().parents[1]
    group = argv[2] if len(argv) >= 3 and argv[2] else DEFAULT_GROUP
    surface_group = _surface_group_key(group)
    if surface_group not in SURFACE_GROUPS:
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

    manifest = _load_manifest(output_dir)
    device = _device_from_manifest(manifest)
    entries = _load_entries(output_dir, SURFACE_GROUPS[surface_group], device)
    if not entries:
        print(f"No {device} Act0 screenshots found to package.", file=sys.stderr)
        return 1

    contact_sheet = output_dir / "contact_sheet.png"
    zip_path = output_dir / f"screen_review_{group}.zip"
    readme = output_dir / "README.txt"
    index = output_dir / "screen_review_index.json"

    _write_contact_sheet(entries, contact_sheet, device)
    metadata = _metadata(root, entries, contact_sheet, zip_path, group, manifest, device)
    readme.write_text(_readme_text(metadata), encoding="utf-8")
    index.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    full_scroll_metadata = output_dir / "full_scroll_meta.json"
    route_metadata = output_dir / "route_w7_w12_meta.json"
    active_route_metadata = output_dir / "active_route_w7_w12_meta.json"
    _write_zip(
        entries,
        contact_sheet,
        readme,
        index,
        output_dir / "manifest.json",
        full_scroll_metadata if full_scroll_metadata.exists() else None,
        route_metadata if route_metadata.exists() else None,
        active_route_metadata if active_route_metadata.exists() else None,
        zip_path,
    )

    print(contact_sheet)
    print(zip_path)
    return 0


def _load_entries(
    output_dir: Path,
    surfaces: tuple[tuple[str, str], ...],
    device: str,
) -> list[tuple[str, str, Path]]:
    entries: list[tuple[str, str, Path]] = []
    for surface, label in surfaces:
        path = output_dir / f"{device}.{surface}.png"
        if path.exists() and path.stat().st_size > 0:
            entries.append((surface, label, path))
    return entries


def _surface_group_key(group: str) -> str:
    for device in ("tablet", "tall_phone", "large_phone"):
        suffix = f"_{device}_fast"
        if group.endswith(suffix):
            return group.replace(suffix, "_fast")
    return group


def _load_manifest(output_dir: Path) -> dict[str, object]:
    path = output_dir / "manifest.json"
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def _device_from_manifest(manifest: dict[str, object]) -> str:
    value = manifest.get("device")
    return value if isinstance(value, str) and value else DEFAULT_DEVICE


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


def _write_contact_sheet(
    entries: list[tuple[str, str, Path]],
    output: Path,
    device: str,
) -> None:
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
        draw.text((x + 160, y + 8), f"{device}.{surface}.png", font=meta_font, fill=MUTED)
        sheet.paste(image, (x, y + LABEL_HEIGHT))

    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, format="PNG", optimize=True)


def _metadata(
    root: Path,
    entries: list[tuple[str, str, Path]],
    contact_sheet: Path,
    zip_path: Path,
    group: str,
    manifest: dict[str, object],
    device: str,
) -> dict[str, object]:
    metadata = {
        "packet": f"screen_review_{group}",
        "group": group,
        "device": device,
        "created_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "git_commit": _git(root, "rev-parse", "HEAD"),
        "git_status": "clean" if _git(root, "status", "--short") == "" else "dirty",
        "manifest_git_commit": manifest.get("git_commit"),
        "manifest_git_status": manifest.get("git_status"),
        "matches_current_head": manifest.get("git_commit") == _git(root, "rev-parse", "HEAD"),
        "source_command": _source_command(group),
        "package_command": f"./tools/package_screen_review_v1.sh current {group}",
        "scenario_family": _scenario_family(group),
        "lane_type": manifest.get("lane_type", "real_text_product_proof"),
        "render_kind": manifest.get("render_kind", "flutter_widget_test_real_text"),
        "is_real_text": manifest.get("is_real_text", True),
        "allowed_claims": manifest.get("allowed_claims", []),
        "unsupported_claims": manifest.get("unsupported_claims", []),
        "duplicate_hash_policy": manifest.get("duplicate_hash_policy", {}),
        "content_reflects_latest_post_idealization_copy": group
        in ("route_w7_w12_fast", "active_route_w7_w12_fast"),
        "surfaces": [surface for surface, _, _ in entries],
        "files": [str(path.relative_to(root)) for _, _, path in entries],
        "contact_sheet": str(contact_sheet.relative_to(root)),
        "zip": str(zip_path.relative_to(root)),
        "note": "Generated packet artifacts are local-only and uncommitted.",
    }
    metadata.update(_audit_policy_metadata(group))
    return metadata


def _audit_policy_metadata(group: str) -> dict[str, object]:
    if group == "route_w7_w12_fast":
        return {
            "visual_audit_validity": "legacy_reference_not_for_audit",
            "final_visual_audit_eligible": False,
            "invalid_for_final_visual_ux_judgment": True,
            "allowed_use": "route_state_smoke_evidence_only",
            "capture_source_policy": "legacy_reference_not_for_audit",
            "required_replacement": "active_runtime_route_pack_capture_lane_v1",
        }
    if group == "active_route_w7_w12_fast":
        return {
            "visual_audit_validity": "active_runtime_visual_evidence",
            "final_visual_audit_eligible": True,
            "invalid_for_final_visual_ux_judgment": False,
            "allowed_use": "final_pre_human_visual_ux_audit",
            "capture_source_policy": "active_act0_runtime_test_only_wrapper",
            "active_surface": "Act0LessonRunnerShellV1",
            "legacy_archive_runner_used": False,
        }
    return {
        "visual_audit_validity": "active_surface_fast_review",
        "final_visual_audit_eligible": True,
        "invalid_for_final_visual_ux_judgment": False,
        "allowed_use": "final_visual_audit_candidate",
        "capture_source_policy": "active_surface_allowlisted",
    }


def _source_command(group: str) -> str:
    for device in ("tablet", "tall_phone", "large_phone"):
        suffix = f"_{device}_fast"
        if group.endswith(suffix):
            base = group.replace(suffix, "")
            return f"./tools/screen_review_fast_v1.sh {base} {device}"
    if group == "core_fast":
        return "./tools/screen_review_fast_v1.sh core compact"
    if group == "runner_fast":
        return "./tools/screen_review_fast_v1.sh runner compact"
    if group == "first_week_fast":
        return "./tools/screen_review_fast_v1.sh first_week compact"
    if group == "day2_return_fast":
        return "./tools/screen_review_fast_v1.sh day2_return compact"
    if group == "profile_evidence_fast":
        return "./tools/screen_review_fast_v1.sh profile_evidence compact"
    if group == "full_scroll_fast":
        return "./tools/screen_review_fast_v1.sh full_scroll compact"
    if group == "route_w7_w12_fast":
        return "./tools/screen_review_fast_v1.sh route_w7_w12 compact"
    if group == "active_route_w7_w12_fast":
        return "./tools/screen_review_fast_v1.sh active_route_w7_w12 compact"
    return f"./tools/screen_review_v1.sh {group} compact"


def _scenario_family(group: str) -> str:
    group = _surface_group_key(group)
    if group == "route_w7_w12_fast":
        return "late_route_w7_w12_visual_coverage"
    if group == "active_route_w7_w12_fast":
        return "active_runtime_late_route_w7_w12_visual_coverage"
    return "act0_fast_screen_review"


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
    full_scroll_metadata: Path | None,
    route_metadata: Path | None,
    active_route_metadata: Path | None,
    zip_path: Path,
) -> None:
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for _, _, path in entries:
            archive.write(path, path.name)
        if manifest.exists():
            archive.write(manifest, manifest.name)
        if full_scroll_metadata is not None:
            archive.write(full_scroll_metadata, full_scroll_metadata.name)
        if route_metadata is not None:
            archive.write(route_metadata, route_metadata.name)
        if active_route_metadata is not None:
            archive.write(active_route_metadata, active_route_metadata.name)
        archive.write(contact_sheet, contact_sheet.name)
        archive.write(readme, readme.name)
        archive.write(index, index.name)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
