#!/usr/bin/env python3
"""Build the local-only Claude Design real-text evidence pack."""

from __future__ import annotations

import json
import shutil
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "output" / "screen_review" / "current"
OUTPUT_ROOT = ROOT / "output" / "design_review" / "real_text_visual_pack_v3"

ALLOWED_CLAIMS = [
    "visual hierarchy",
    "copy readability",
    "density",
    "CTA clarity",
    "first impression",
    "premium/product feel",
    "empty-state quality",
    "navigation clarity",
    "screen-to-screen continuity",
]
DISALLOWED_CLAIMS = [
    "Human QA approval",
    "public readiness",
    "launch readiness",
    "9.0 proof",
    "10/10 proof",
    "durable learning effect",
    "beginner mastery",
    "premium commercial readiness",
]
CONTACT_SHEETS = {
    ("compact", "visible"): "compact_visible_contact_sheet.png",
    ("compact", "full_scroll"): "compact_full_scroll_contact_sheet.png",
    ("tablet", "visible"): "tablet_visible_contact_sheet.png",
    ("tablet", "full_scroll"): "tablet_full_scroll_contact_sheet.png",
}


@dataclass(frozen=True)
class Screen:
    slug: str
    name: str
    route: str
    packet: str
    surface: str
    full_scroll_base: str | None = None
    segment_surfaces: tuple[tuple[str, str], ...] = ()
    limitation: str = ""


SCREENS = (
    Screen("01_home", "Home", "Act0 Home", "core", "home", "home"),
    Screen("02_learn", "Learn", "Act0 Learn", "core", "learn", "learn"),
    Screen(
        "03_learn_lesson_detail",
        "Learn lesson detail",
        "Act0 Learn lesson detail",
        "core",
        "learn_detail",
        limitation="The detail sheet is a bounded viewport surface and does not own a separate scroll lane.",
    ),
    Screen(
        "04_placement",
        "Placement",
        "Act0 placement",
        "first_week",
        "placement",
        limitation="Placement is captured as a fixed first-step viewport.",
    ),
    Screen(
        "05_welcome",
        "Welcome",
        "Act0 welcome",
        "first_week",
        "welcome_decision",
        segment_surfaces=(
            ("welcome_decision", "decision"),
            ("welcome_feedback", "feedback"),
            ("welcome_handoff", "handoff"),
        ),
        limitation="Welcome is represented by deterministic decision, feedback, and handoff segments.",
    ),
    Screen(
        "06_first_decision",
        "First decision / play",
        "Act0 W1 runner",
        "first_week",
        "decision",
        limitation="Runner decision is a fixed viewport.",
    ),
    Screen(
        "07_correct_feedback",
        "Correct feedback",
        "Act0 W1 feedback",
        "first_week",
        "correct_feedback",
        limitation="Feedback is a fixed viewport.",
    ),
    Screen(
        "08_wrong_feedback",
        "Wrong feedback",
        "Act0 W1 feedback",
        "first_week",
        "wrong_feedback",
        limitation="Feedback is a fixed viewport.",
    ),
    Screen(
        "09_repair_focus",
        "Repair focus",
        "Act0 W1 repair",
        "first_week",
        "repair_focus",
        limitation="Repair focus is a fixed viewport.",
    ),
    Screen(
        "10_targeted_recheck",
        "Targeted recheck / repair result",
        "Act0 W1 repair result",
        "first_week",
        "repair_result",
        segment_surfaces=(
            ("repair_focus", "repair_focus"),
            ("repair_result", "repair_result"),
        ),
        limitation="The repair sequence is represented by deterministic focus and result segments.",
    ),
    Screen(
        "11_session_summary",
        "Session summary",
        "Act0 session summary",
        "first_week",
        "session_summary",
        "session_summary",
    ),
    Screen(
        "12_practice_default",
        "Practice default / repair state",
        "Act0 Practice",
        "core",
        "practice",
        "practice",
    ),
    Screen(
        "13_review_empty",
        "Review empty state",
        "Act0 Review empty bench",
        "core",
        "review_empty",
        limitation="The empty bench is a bounded viewport; the active Review scroll lane is captured separately.",
    ),
    Screen(
        "14_review_active",
        "Review active repair state",
        "Act0 Review active repair",
        "day2_return",
        "review_continuation",
        limitation="The active repair fixture is a bounded viewport.",
    ),
    Screen("15_profile", "Profile / You", "Act0 Profile", "core", "profile", "profile"),
    Screen(
        "16_day2_return_home",
        "Day-2 return Home / repair priority",
        "Act0 Day-2 Home",
        "day2_return",
        "return_home",
        limitation="The deterministic Day-2 fixture is a bounded viewport.",
    ),
    Screen(
        "17_w11_transfer",
        "W11 transfer",
        "Act0 active W11 route",
        "active_route_w7_w12",
        "w11_danger_texture_task_copy_detail",
        segment_surfaces=(
            ("w11_danger_texture_task_table", "table"),
            ("w11_danger_texture_task_copy_detail", "copy_detail"),
        ),
        limitation="Late-route evidence uses deterministic table and copy-detail segments.",
    ),
    Screen(
        "18_w12_payoff",
        "W12 payoff / mindset bridge",
        "Act0 active W12 payoff",
        "active_route_w7_w12",
        "w12_payoff_completion_copy_detail",
        segment_surfaces=(
            ("w12_payoff_completion_table", "table"),
            ("w12_payoff_completion_copy_detail", "copy_detail"),
        ),
        limitation="Late-route evidence uses deterministic table and copy-detail segments.",
    ),
    Screen(
        "19_w12_terminal",
        "W12 terminal / no-W13",
        "Act0 Volume I terminal",
        "active_route_w7_w12",
        "terminal_no_w13_copy_detail",
        segment_surfaces=(
            ("volume_i_terminal_review_table", "table"),
            ("terminal_no_w13_copy_detail", "copy_detail"),
        ),
        limitation="Terminal evidence uses deterministic table and copy-detail segments.",
    ),
)


def main() -> None:
    if len(SCREENS) != 19:
        raise RuntimeError("The visual pack contract must contain exactly 19 screens.")

    if OUTPUT_ROOT.exists():
        shutil.rmtree(OUTPUT_ROOT)
    for device in ("compact", "tablet"):
        (OUTPUT_ROOT / device / "visible").mkdir(parents=True, exist_ok=True)
        (OUTPUT_ROOT / device / "full_scroll").mkdir(parents=True, exist_ok=True)
    (OUTPUT_ROOT / "contact_sheets").mkdir(parents=True, exist_ok=True)

    commit = _git("rev-parse", "HEAD")
    status = _git_status()
    entries: list[dict[str, object]] = []
    coverage_rows: list[dict[str, object]] = []

    for screen in SCREENS:
        row = {"screen": screen.name, "compact": [], "tablet": [], "limitation": screen.limitation}
        for device in ("compact", "tablet"):
            visible_source = _source_path(screen.packet, device, screen.surface)
            visible_output = OUTPUT_ROOT / device / "visible" / f"{screen.slug}.png"
            _copy_required(visible_source, visible_output)
            entries.append(
                _entry(
                    screen,
                    device,
                    "visible_viewport",
                    visible_source,
                    visible_output,
                    commit,
                    status,
                )
            )
            row[device].append(str(visible_output.relative_to(ROOT)))

            full_outputs = _build_full_evidence(screen, device)
            for source, output, segment in full_outputs:
                entries.append(
                    _entry(
                        screen,
                        device,
                        "full_scroll" if screen.full_scroll_base else "full_page",
                        source,
                        output,
                        commit,
                        status,
                        segment=segment,
                    )
                )
                row[device].append(str(output.relative_to(ROOT)))
        coverage_rows.append(row)

    sheet_paths = {
        "compact_visible": _contact_sheet("compact", "visible"),
        "compact_full_scroll": _contact_sheet("compact", "full_scroll"),
        "tablet_visible": _contact_sheet("tablet", "visible"),
        "tablet_full_scroll": _contact_sheet("tablet", "full_scroll"),
    }
    manifest = {
        "schema": "real_text_visual_pack_v3",
        "artifact_dir": str(OUTPUT_ROOT.relative_to(ROOT)),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "screen_count": 19,
        "is_real_text": True,
        "phone_first": True,
        "tablet_smoke": "visible_all_19_with_supported_full_scroll",
        "git_commit": commit,
        "git_status": status,
        "current_head_match": commit == _git("rev-parse", "HEAD"),
        "allowed_claims": ALLOWED_CLAIMS,
        "disallowed_claims": DISALLOWED_CLAIMS,
        "contact_sheets": {
            key: str(path.relative_to(ROOT)) for key, path in sheet_paths.items()
        },
        "entries": entries,
    }
    (OUTPUT_ROOT / "manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n",
        encoding="utf-8",
    )
    _write_coverage(coverage_rows, commit, status)
    _write_claude_prompt()
    print(OUTPUT_ROOT)


def _packet_name(packet: str, device: str) -> str:
    return f"{packet}_{'tablet_' if device == 'tablet' else ''}fast"


def _source_path(packet: str, device: str, surface: str) -> Path:
    packet_dir = SOURCE_ROOT / _packet_name(packet, device)
    return packet_dir / f"{device}.{surface}.png"


def _build_full_evidence(
    screen: Screen, device: str
) -> list[tuple[Path, Path, str | None]]:
    target_dir = OUTPUT_ROOT / device / "full_scroll"
    if screen.full_scroll_base:
        result = []
        for index, position in enumerate(("top", "mid", "bottom"), start=1):
            surface = f"{screen.full_scroll_base}.scroll_0{index}_{position}"
            source = _source_path("full_scroll", device, surface)
            output = target_dir / f"{screen.slug}_segment_0{index}_{position}.png"
            _copy_required(source, output)
            result.append((source, output, position))
        return result

    if screen.segment_surfaces:
        result = []
        for index, (surface, label) in enumerate(screen.segment_surfaces, start=1):
            source = _source_path(screen.packet, device, surface)
            output = target_dir / f"{screen.slug}_segment_{index:02d}_{label}.png"
            _copy_required(source, output)
            result.append((source, output, label))
        return result

    source = _source_path(screen.packet, device, screen.surface)
    output = target_dir / f"{screen.slug}_full_page.png"
    _copy_required(source, output)
    return [(source, output, None)]


def _entry(
    screen: Screen,
    device: str,
    capture_type: str,
    source: Path,
    output: Path,
    commit: str,
    status: str,
    *,
    segment: str | None = None,
) -> dict[str, object]:
    with Image.open(output) as image:
        width, height = image.size
    return {
        "screen": screen.name,
        "surface": screen.slug,
        "route_source": screen.route,
        "viewport_device": device,
        "phone_first": device == "compact",
        "tablet_smoke": device == "tablet",
        "capture_type": capture_type,
        "segment": segment,
        "git_commit": commit,
        "git_status": status,
        "current_head_match": commit == _git("rev-parse", "HEAD"),
        "image_path": str(output.relative_to(ROOT)),
        "source_image_path": str(source.relative_to(ROOT)),
        "dimensions": {"width": width, "height": height},
        "is_real_text": True,
        "allowed_claims": ALLOWED_CLAIMS,
        "disallowed_claims": DISALLOWED_CLAIMS,
        "limitation": screen.limitation or None,
        "limits_claude_review": bool(screen.limitation),
    }


def _copy_required(source: Path, output: Path) -> None:
    if not source.exists():
        raise FileNotFoundError(
            f"Missing real-text source: {source.relative_to(ROOT)}. "
            "Regenerate the required screen-review packet first."
        )
    shutil.copy2(source, output)


def _contact_sheet(device: str, capture_dir: str) -> Path:
    source_dir = OUTPUT_ROOT / device / capture_dir
    files = sorted(source_dir.glob("*.png"))
    primary_files = []
    for screen in SCREENS:
        candidates = [path for path in files if path.name.startswith(screen.slug)]
        if not candidates:
            raise RuntimeError(f"No {device} {capture_dir} image for {screen.name}")
        primary_files.append(candidates[0])

    thumb_width = 330 if device == "compact" else 430
    columns = 4 if device == "compact" else 3
    margin, gap, label_height = 28, 22, 54
    cells = []
    font = _font(22)
    for screen, path in zip(SCREENS, primary_files):
        with Image.open(path) as image:
            rendered = image.convert("RGB")
            scale = thumb_width / rendered.width
            thumb = rendered.resize(
                (thumb_width, max(1, int(rendered.height * scale))),
                Image.Resampling.LANCZOS,
            )
        cells.append((screen.name, thumb))
    cell_height = max(image.height for _, image in cells) + label_height
    rows = (len(cells) + columns - 1) // columns
    canvas = Image.new(
        "RGB",
        (
            margin * 2 + columns * thumb_width + (columns - 1) * gap,
            margin * 2 + rows * cell_height + (rows - 1) * gap,
        ),
        (7, 18, 33),
    )
    draw = ImageDraw.Draw(canvas)
    for index, (label, image) in enumerate(cells):
        row, column = divmod(index, columns)
        x = margin + column * (thumb_width + gap)
        y = margin + row * (cell_height + gap)
        draw.text((x, y), label, fill=(232, 241, 252), font=font)
        canvas.paste(image, (x, y + label_height))
    filename = CONTACT_SHEETS[(device, capture_dir)]
    output = OUTPUT_ROOT / "contact_sheets" / filename
    canvas.save(output, format="PNG", optimize=True)
    return output


def _font(size: int) -> ImageFont.ImageFont:
    for path in (
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ):
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def _write_coverage(rows: list[dict[str, object]], commit: str, status: str) -> None:
    lines = [
        "# Real-Text Visual Pack v3 Coverage",
        "",
        f"- Git commit: `{commit}`",
        f"- Git status: `{status}`",
        "- Screens: 19/19",
        "- Devices: compact phone and tablet",
        "- Primary target: compact phone portrait",
        "- Tablet target: clipping, overflow, CTA access, and layout smoke only",
        "- Evidence: rendered real copy and real UI only",
        "",
        "| # | Screen | Compact | Tablet | Limitation |",
        "| --- | --- | --- | --- | --- |",
    ]
    for index, row in enumerate(rows, start=1):
        compact = len(row["compact"])
        tablet = len(row["tablet"])
        limitation = row["limitation"] or "None"
        lines.append(
            f"| {index} | {row['screen']} | {compact} image(s) | "
            f"{tablet} image(s) | {limitation} |"
        )
    lines.extend(
        [
            "",
            "Allowed review claims: " + ", ".join(ALLOWED_CLAIMS) + ".",
            "",
            "Disallowed claims: " + ", ".join(DISALLOWED_CLAIMS) + ".",
        ]
    )
    (OUTPUT_ROOT / "coverage.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def _write_claude_prompt() -> None:
    text = """# Claude Design Re-review Prompt

Review the 19-screen real-text evidence pack as a phone-first product-surface
audit. Compact phone portrait is the quality target. Tablet is smoke evidence
for clipping, overflow, inaccessible actions, and broken layout only.

Evaluate compact and tablet evidence for visual hierarchy, copy readability,
density, CTA clarity, first impression, premium/product feel, empty-state
quality, navigation clarity, and screen-to-screen continuity.

Use the individual images for detailed judgment and the four contact sheets for
cross-screen consistency. Respect every limitation recorded in `coverage.md`
and `manifest.json`. Do not infer behavior, learner outcomes, or release state
from static screenshots.

Do not claim Human QA approval, public readiness, launch readiness, 9.0 or
10/10 proof, durable learning effect, beginner mastery, or premium commercial
readiness.

Return:
1. screen-by-screen findings;
2. cross-screen system findings;
3. compact findings first, then tablet blocker regressions only;
4. prioritized remaining issues with screenshot paths;
5. explicit accepted screens;
6. questions that require Human QA rather than visual evidence.
"""
    (OUTPUT_ROOT / "claude_design_final_rereview_prompt.md").write_text(
        text, encoding="utf-8"
    )


def _git(*args: str) -> str:
    return subprocess.check_output(
        ["git", *args], cwd=ROOT, text=True
    ).strip()


def _git_status() -> str:
    lines = []
    for line in _git("status", "--short", "--untracked-files=all").splitlines():
        path = line[3:]
        if path.startswith("output/"):
            continue
        if path == "macos/Flutter/GeneratedPluginRegistrant.swift":
            continue
        lines.append(line)
    return "clean_or_output_only" if not lines else "dirty_tracked_changes"


if __name__ == "__main__":
    main()
