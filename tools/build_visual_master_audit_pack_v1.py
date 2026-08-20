#!/usr/bin/env python3
"""Package one verified native visual-audit artifact for owner review."""
from __future__ import annotations

import hashlib
import json
import os
from collections import Counter
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "docs/evidence/visual_master_audit_v1"
ARTIFACT = Path(os.environ["VISUAL_AUDIT_NATIVE_ARTIFACT"]).resolve()
RUN_ID = os.environ["VISUAL_AUDIT_WORKFLOW_RUN_ID"]
ARTIFACT_NAME = os.environ["VISUAL_AUDIT_ARTIFACT_NAME"]
EXPECTED = {
    ("canonical", "none"): 20,
    ("compact", "none"): 14,
    ("canonical", "text_scale_1_4"): 10,
    ("canonical", "reduced_motion"): 6,
    ("large", "none"): 4,
}
SHEETS = [
    ("01_entry_and_handoff", ["placement.canonical.normal", "welcome.canonical.normal", "home.canonical.normal", "learn.canonical.normal"]),
    ("02_home_and_learn_geometry", ["home.compact.normal", "home.canonical.normal", "home.large.normal", "learn.compact.normal", "learn.canonical.normal"]),
    ("03_theory_and_table_read", ["theory.canonical.normal", "table_read.canonical.normal", "showdown.canonical.normal", "hand_comparison.canonical.normal"]),
    ("04_decision_prompts", ["action_selection.canonical.normal", "vrt02.canonical.normal", "hand_comparison.canonical.normal", "showdown.canonical.normal"]),
    ("05_feedback_and_repair", ["vrt02_correct.canonical.normal", "vrt02_incorrect.canonical.normal", "repair_focus.canonical.normal", "repair_recheck.canonical.normal"]),
    ("06_review_profile_and_summary", ["review.canonical.normal", "profile_evidence.canonical.normal", "session_summary.canonical.normal", "home.canonical.normal"]),
    ("07_completion_and_progress", ["lesson_completion.canonical.normal", "completion_world.canonical.normal", "world3.canonical.normal", "profile_evidence.canonical.normal"]),
    ("08_compact_normal", ["placement.compact.normal", "welcome.compact.normal", "home.compact.normal", "vrt02.compact.normal", "vrt02_correct.compact.normal", "vrt02_incorrect.compact.normal", "completion_world.compact.normal"]),
    ("09_compact_normal_continued", ["learn.compact.normal", "review.compact.normal", "profile_evidence.compact.normal", "session_summary.compact.normal", "lesson_completion.compact.normal", "repair_recheck.compact.normal", "showdown.compact.normal"]),
    ("10_text_scale_1_4_core", ["home.canonical.text_scale_1_4", "theory.canonical.text_scale_1_4", "vrt02.canonical.text_scale_1_4", "vrt02_incorrect.canonical.text_scale_1_4", "lesson_completion.canonical.text_scale_1_4"]),
    ("11_text_scale_1_4_support", ["learn.canonical.text_scale_1_4", "review.canonical.text_scale_1_4", "profile_evidence.canonical.text_scale_1_4", "session_summary.canonical.text_scale_1_4", "completion_world.canonical.text_scale_1_4"]),
    ("12_reduced_motion", ["home.canonical.reduced_motion", "vrt02.canonical.reduced_motion", "vrt02_incorrect.canonical.reduced_motion", "repair_recheck.canonical.reduced_motion", "session_summary.canonical.reduced_motion", "completion_world.canonical.reduced_motion"]),
    ("13_large_normal", ["home.large.normal", "vrt02.large.normal", "profile_evidence.large.normal", "completion_world.large.normal"]),
    ("14_canonical_normal_baseline", ["placement.canonical.normal", "welcome.canonical.normal", "theory.canonical.normal", "table_read.canonical.normal", "vrt02.canonical.normal", "lesson_completion.canonical.normal"]),
    ("15_native_render_fidelity", ["vrt02.compact.normal", "vrt02.canonical.normal", "vrt02.large.normal", "vrt02.canonical.text_scale_1_4", "vrt02.canonical.reduced_motion"]),
]


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def state_key(row: dict) -> str:
    return row["visual_state_id"]


def validate(rows: list[dict], candidate: str) -> None:
    counts = Counter((r["device_profile"], r["modifier"]) for r in rows)
    tuples = {(r["state"], r["device_profile"], r["modifier"]) for r in rows}
    errors = []
    if len(rows) != 54: errors.append(f"expected 54 rows, found {len(rows)}")
    if counts != EXPECTED: errors.append(f"unexpected distribution: {dict(counts)}")
    if len(tuples) != 54: errors.append("state/device/modifier tuples are not unique")
    if any(r.get("candidate_sha") != candidate for r in rows): errors.append("not every row carries the final candidate SHA")
    if any(r.get("capture_source") != "NATIVE_IOS_SIMULATOR" for r in rows): errors.append("non-native capture source found")
    if any(r["device_profile"] == "large" and r["modifier"] == "reduced_motion" for r in rows): errors.append("large + reduced motion is not admitted")
    if not any(r["state"] == "lesson.completion" for r in rows): errors.append("missing lesson.completion")
    if not any(r["state"] == "completion.world" for r in rows): errors.append("missing completion.world")
    for row in rows:
        image = ARTIFACT / row["png"]
        if not image.is_file() or image.stat().st_size == 0 or digest(image) != row["png_sha256"]:
            errors.append(f"invalid native PNG: {row['png']}")
    if errors: raise SystemExit("native visual pack validation failed: " + "; ".join(errors))


def label(row: dict) -> str:
    return "\n".join((
        f"state={row['visual_state_id']}",
        f"profile={row['device_profile']} modifier={row['modifier']}",
        f"model={row['device_model']}",
        f"sha={row['png_sha256'][:12]}",
    ))


def render(rows: list[dict], destination: Path, title: str) -> None:
    font = ImageFont.load_default()
    panels = []
    for row in rows:
        image = Image.open(ARTIFACT / row["png"]).convert("RGB")
        image.thumbnail((300, 600))
        panel = Image.new("RGB", (310, 710), "#07111f")
        panel.paste(image, ((310 - image.width) // 2, 95))
        draw = ImageDraw.Draw(panel)
        draw.rectangle((0, 0, 310, 95), fill="#142842")
        draw.multiline_text((5, 4), label(row), font=font, fill="white", spacing=2)
        panels.append(panel)
    canvas = Image.new("RGB", (310 * len(panels), 740), "#030812")
    ImageDraw.Draw(canvas).text((8, 6), title, font=font, fill="white")
    for index, panel in enumerate(panels): canvas.paste(panel, (310 * index, 30))
    destination.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(destination, "WEBP", quality=82, method=6)


def main() -> None:
    source = json.loads((ARTIFACT / "native_capture_manifest.json").read_text())
    candidate = source["candidate_sha"]
    rows = source["rows"]
    validate(rows, candidate)
    by_key = {state_key(row): row for row in rows}
    if len(by_key) != len(rows): raise SystemExit("visual_state_id must be unique")
    sheet_dir = DEST / "contact_sheets"
    for path in sheet_dir.glob("*.webp"): path.unlink()
    sheets = []
    for name, keys in SHEETS:
        group = [by_key[key] for key in keys]
        path = sheet_dir / f"{name}.webp"
        render(group, path, f"Native Visual Audit | {candidate[:12]} | {name}")
        sheets.append({"path": str(path.relative_to(DEST)), "states": keys})
    if len(sheets) != 15: raise SystemExit("exactly 15 contact sheets are required")
    artifact = {"workflow_run_id": RUN_ID, "name": ARTIFACT_NAME, "candidate_sha": candidate}
    manifest = {
        "schema": "visual_master_audit_manifest_v1", "candidate_commit_sha": candidate, "artifact": artifact, "rows": rows, "contact_sheets": sheets,
        "acceptance_gates": {"exact_54_native_rows": True, "distribution_20_14_10_6_4": True, "unique_state_device_modifier": True, "every_row_final_candidate_sha": True, "native_ios_simulator_only": True, "no_large_reduced_motion": True, "lesson_completion_separate_from_completion_world": True, "raw_pngs_remain_workflow_artifact_only": True},
        "truth_rule": "Every image is from the final native iOS Simulator artifact. Native state payload injection renders the production app; it is not a widget test or a Human Novice proof.",
    }
    DEST.mkdir(parents=True, exist_ok=True)
    (DEST / "visual_master_audit_manifest_v1.json").write_text(json.dumps(manifest, indent=2) + "\n")
    distribution = "; ".join(f"{profile}/{modifier}: {count}" for (profile, modifier), count in EXPECTED.items())
    matrix = ["# Visual Master Audit Capture Matrix v1", "", f"Final candidate: `{candidate}`", f"Native workflow run: `{RUN_ID}`", f"Unified artifact: `{ARTIFACT_NAME}`", "", "This supersedes all prior widget-test contact sheets. The 54 source PNGs remain in the GitHub Actions artifact; only derived native-only contact sheets are committed here.", "", "## Pre-dispatch and artifact gates", "", "- total rows: `54`", f"- distribution: `{distribution}`", "- unique `(state, device_profile, modifier)`: `54`", "- all row candidate SHAs: final candidate", "- capture source: `NATIVE_IOS_SIMULATOR` only", "- `lesson.completion` and `completion.world`: separate states", "- `large + reduced_motion`: absent", "", "## Rows", "", "| State | Profile | Modifier | Simulator | iOS runtime | PNG SHA-256 |", "| --- | --- | --- | --- | --- | --- |"]
    matrix.extend(f"| {r['state']} | {r['device_profile']} | {r['modifier']} | {r['device_model']} | {r['ios_runtime']} | `{r['png_sha256']}` |" for r in rows)
    (DEST / "visual_master_audit_capture_matrix_v1.md").write_text("\n".join(matrix) + "\n")
    gallery = ["# Visual Master Audit Gallery v1", "", f"Final candidate: `{candidate}`", f"Native workflow run: `{RUN_ID}`", "", "All sheets below derive only from the unified 54-row native artifact. Earlier widget-test sheets are superseded and removed.", ""]
    gallery.extend(f"## {sheet['path'].split('/')[-1].replace('_', ' ').replace('.webp', '')}\n\n![{sheet['path']}]({sheet['path']})\n" for sheet in sheets)
    (DEST / "visual_master_audit_gallery_v1.md").write_text("\n".join(gallery))
    provenance = ["# Native Capture Method and Provenance v1", "", f"- Final candidate SHA: `{candidate}`", f"- GitHub Actions workflow run: `{RUN_ID}`", f"- Unified artifact: `{ARTIFACT_NAME}`", "- Build: one `Runner.app` build, installed unchanged on compact, canonical, and large simulators.", "- Capture: one row-level manifest supplies each device profile and modifier payload.", "- Evidence class: native iOS Simulator production renderer with deterministic capture payload; this is not widget-test, synthetic, or Human Novice evidence.", "- Raw PNG policy: the 54 PNGs and their hashes stay in the workflow artifact; this PR commits only review contact sheets.", ""]
    (DEST / "native_capture_method_and_provenance_v1.md").write_text("\n".join(provenance))
    scorecard = {"schema": "visual_master_audit_issue_scorecard_template_v1", "candidate_commit_sha": candidate, "workflow_run_id": RUN_ID, "issues": []}
    (DEST / "visual_master_audit_issue_scorecard_template_v1.json").write_text(json.dumps(scorecard, indent=2) + "\n")
    print(json.dumps({"rows": len(rows), "sheets": len(sheets), "candidate": candidate}, indent=2))


if __name__ == "__main__": main()
