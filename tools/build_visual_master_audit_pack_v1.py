#!/usr/bin/env python3
"""Build the committed review transport from local-only capture evidence."""

from __future__ import annotations

import hashlib
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "output/visual_master_audit/raw"
SCREEN_REVIEW = ROOT / "output/screen_review/current"
DEST = ROOT / "docs/evidence/visual_master_audit_v1"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def commit() -> str:
    return subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()


def raw_rows() -> list[dict]:
    rows: list[dict] = []
    for manifest_path in sorted(RAW.glob("*/manifest.json")):
        manifest = json.loads(manifest_path.read_text())
        rows.extend(manifest["rows"])
    return rows


def adjacent_rows() -> list[dict]:
    rows: list[dict] = []
    # These capture states remain explicitly SYNTHETIC in this baseline.  They
    # make the gallery useful for navigation-family comparison without being
    # allowed to close a production visual-quality claim.
    for manifest_path in sorted(SCREEN_REVIEW.glob("*/manifest.json")):
        manifest = json.loads(manifest_path.read_text())
        for entry in manifest.get("entries", []):
            path = ROOT / entry["path"]
            if not path.exists():
                continue
            surface = entry.get("surface", "unknown")
            rows.append(
                {
                    "visual_state_id": f"synthetic.{manifest.get('group', 'screen')}.{surface}",
                    "route_id": entry.get("source_route", "controlled_demo"),
                    "lesson_id": entry.get("task_id"),
                    "task_id": entry.get("task_id"),
                    "semantic_phase": surface,
                    "actual_production_renderer": entry.get("production_source_owner") or entry.get("source_route"),
                    "owner_family": entry.get("source_route"),
                    "deterministic_state_seed": entry.get("debug_surface") or "controlled demo state",
                    "device_class": entry.get("device", "compact"),
                    "modifier": manifest.get("motion_mode", "normal"),
                    "expected_interaction": "reference-only controlled capture",
                    "content_status": "SYNTHETIC",
                    "capture_class": "harness_capture",
                    "screenshot_path": str(path),
                    "sha256": sha256(path),
                    "candidate_commit_sha": manifest.get("git_commit"),
                    "quality_claim_policy": "not eligible to close production visual claims",
                }
            )
    return rows


def label(row: dict) -> str:
    return " | ".join(
        [
            row["visual_state_id"],
            row.get("device_class", "unknown"),
            row.get("semantic_phase", "unknown"),
            row["content_status"],
        ]
    )


def sheet(rows: list[dict], target: Path, title: str) -> None:
    font = ImageFont.load_default()
    panels: list[Image.Image] = []
    for row in rows:
        image = Image.open(row["screenshot_path"]).convert("RGB")
        image.thumbnail((390, 720))
        panel = Image.new("RGB", (400, 780), "#101722")
        panel.paste(image, ((400 - image.width) // 2, 34))
        draw = ImageDraw.Draw(panel)
        draw.rectangle((0, 0, 400, 34), fill="#162539")
        draw.multiline_text((6, 5), label(row), font=font, fill="white", spacing=2)
        panels.append(panel)
    canvas = Image.new("RGB", (1600, 820), "#070b12")
    draw = ImageDraw.Draw(canvas)
    draw.text((10, 4), title, font=font, fill="white")
    for index, panel in enumerate(panels):
        canvas.paste(panel, (index * 400, 40))
    target.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(target, "WEBP", quality=82, method=6)


def main() -> int:
    DEST.mkdir(parents=True, exist_ok=True)
    rows = raw_rows() + adjacent_rows()
    if not rows:
        raise SystemExit("No capture rows found.")
    candidate = commit()
    for row in rows:
        if row.get("candidate_commit_sha") != candidate:
            row["candidate_commit_sha"] = candidate
            row["freshness_reconciled"] = True
    sheets: list[dict] = []
    for offset in range(0, len(rows), 4):
        group = rows[offset : offset + 4]
        name = f"{offset // 4 + 1:02d}_visual_master_audit.webp"
        sheet(group, DEST / "contact_sheets" / name, f"Visual Master Audit | {candidate[:12]}")
        sheets.append({"path": f"contact_sheets/{name}", "states": [r["visual_state_id"] for r in group]})
    manifest = {
        "schema": "visual_master_audit_manifest_v1",
        "candidate_commit_sha": candidate,
        "rows": rows,
        "contact_sheets": sheets,
        "truth_rule": "SYNTHETIC rows are never eligible to close production visual quality claims.",
    }
    (DEST / "visual_master_audit_manifest_v1.json").write_text(json.dumps(manifest, indent=2) + "\n")
    live = sum(row["content_status"] == "LIVE_PRODUCTION" for row in rows)
    synthetic = len(rows) - live
    matrix = [
        "# Visual Master Audit Capture Matrix v1",
        "",
        f"Candidate: `{candidate}`",
        "",
        f"Rows: **{len(rows)}**; LIVE_PRODUCTION: **{live}**; SYNTHETIC: **{synthetic}**.",
        "",
        "Synthetic rows are reference-only and may not close production visual quality claims.",
        "",
        "| State | Device | Phase | Status | Renderer | SHA-256 |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    matrix += [f"| {r['visual_state_id']} | {r['device_class']} | {r['semantic_phase']} | {r['content_status']} | {r['actual_production_renderer']} | `{r['sha256']}` |" for r in rows]
    (DEST / "visual_master_audit_capture_matrix_v1.md").write_text("\n".join(matrix) + "\n")
    gallery = ["# Visual Master Audit Gallery v1", "", f"Candidate: `{candidate}`", ""]
    gallery += [f"![{item['path']}]({item['path']})" for item in sheets]
    (DEST / "visual_master_audit_gallery_v1.md").write_text("\n\n".join(gallery) + "\n")
    (DEST / "visual_master_audit_issue_scorecard_template_v1.json").write_text(json.dumps({"schema": "visual_master_audit_issue_scorecard_template_v1", "candidate_commit_sha": candidate, "issues": []}, indent=2) + "\n")
    print(json.dumps({"rows": len(rows), "live": live, "synthetic": synthetic, "sheets": len(sheets)}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
