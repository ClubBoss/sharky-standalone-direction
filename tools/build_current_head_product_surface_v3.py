#!/usr/bin/env python3
"""Build the local-only identity-complete current-head visual review bundle."""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
import sys
import zipfile
from collections import Counter
from pathlib import Path

from visual_evidence_identity_v1 import MANIFEST_SCHEMA, validate_records

ROOT = Path(__file__).resolve().parents[1]
PRODUCT_EVIDENCE_BASELINE = "b7db47a3145ba8653b90403a9aa48538c378cdb7"
OUT = ROOT / "output/screen_review/current/current_head_product_surface_v3"


def _git(*args: str) -> str:
    return subprocess.run(["git", "-C", str(ROOT), *args], check=True, capture_output=True, text=True).stdout.strip()


def _sidecars() -> list[Path]:
    roots = [ROOT / "output/screen_review/current", ROOT / "output/visual_master_audit/raw"]
    return sorted(
        path for root in roots if root.exists() for path in root.rglob("visual_evidence_identity_v1.json")
        if OUT not in path.parents
    )


def main() -> int:
    sidecars = _sidecars()
    if not sidecars:
        print("IDENTITY_UNMAPPED: no capture-owner identity sidecars found", file=sys.stderr)
        return 1
    if OUT.exists():
        shutil.rmtree(OUT)
    (OUT / "png").mkdir(parents=True)
    aggregate: list[dict[str, object]] = []
    lane_reports: list[dict[str, object]] = []
    for sidecar in sidecars:
        lane = sidecar.parent
        payload = json.loads(sidecar.read_text(encoding="utf-8"))
        records = payload.get("records", [])
        if not isinstance(records, list) or not all(isinstance(row, dict) for row in records):
            print(f"IDENTITY_CONFLICT: invalid sidecar {sidecar}", file=sys.stderr)
            return 1
        admitted = {str(row.get("relative_png_path")) for row in records}
        report, records = validate_records(records, lane, admitted_paths=admitted, expected_baseline=PRODUCT_EVIDENCE_BASELINE)
        report["capture_lane"] = lane.relative_to(ROOT).as_posix()
        lane_reports.append(report)
        if report["disposition"] != "IDENTITY_MAPPED":
            print(json.dumps(report, indent=2), file=sys.stderr)
            return 1
        lane_id = lane.relative_to(ROOT).as_posix().replace("output/", "").replace("/", "__")
        lane_artifacts = OUT / "lanes" / lane_id
        lane_artifacts.mkdir(parents=True, exist_ok=True)
        for name in (
            "manifest.json", "VISUAL_EVIDENCE_IDENTITY_MANIFEST_V1.json",
            "visual_evidence_identity_validation_report_v1.json", "contact_sheet.png",
            "screen_review_index.json", "README.txt",
        ):
            artifact = lane / name
            if artifact.exists():
                shutil.copy2(artifact, lane_artifacts / name)
        for artifact in lane.glob("*.zip"):
            shutil.copy2(artifact, lane_artifacts / artifact.name)
        for record in records:
            source = lane / str(record["relative_png_path"])
            target_relative = f"png/{lane_id}/{record['relative_png_path']}"
            target = OUT / target_relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
            enriched = dict(record)
            enriched["capture_lane"] = lane.relative_to(ROOT).as_posix()
            enriched["relative_png_path"] = target_relative
            aggregate.append(enriched)
    aggregate_report, aggregate = validate_records(
        aggregate, OUT, admitted_paths={str(row["relative_png_path"]) for row in aggregate},
        expected_baseline=PRODUCT_EVIDENCE_BASELINE,
    )
    if aggregate_report["disposition"] != "IDENTITY_MAPPED":
        print(json.dumps(aggregate_report, indent=2), file=sys.stderr)
        return 1
    dimensions = Counter()
    for row in aggregate:
        dimensions[(row.get("state_id"), row.get("task_id"), row.get("device_class"), row.get("text_scale"), row.get("motion_mode"), row.get("scroll_position"))] += 1
    inventory = [{
        "evidence_id": row["evidence_id"], "relative_png_path": row["relative_png_path"],
        "state_id": row["state_id"], "task_id": row["task_id"], "capture_role": row["capture_role"],
        "production_owner": row["production_owner"], "evidence_dimensions": {
            key: row.get(key) for key in ("device_class", "text_scale", "motion_mode", "scroll_position")
        },
    } for row in aggregate]
    manifest = {
        "schema_version": MANIFEST_SCHEMA, "product_evidence_baseline_sha": PRODUCT_EVIDENCE_BASELINE,
        "eid1_tooling_baseline_sha": _git("rev-parse", "HEAD"), "records": aggregate,
        "capture_lane_reports": lane_reports, "completeness": aggregate_report,
        "counts": {
            "production_representatives": sum(row.get("capture_role") == "production_representative" for row in aggregate),
            "stress_representatives": sum(row.get("capture_role") == "stress_representative" for row in aggregate),
            "accessibility_representatives": sum(row.get("capture_role") == "accessibility_representative" for row in aggregate),
            "scroll_evidence": sum(row.get("capture_role") == "scroll_evidence" for row in aggregate),
            "fixture_only_records": sum(row.get("capture_role") == "fixture_only" for row in aggregate),
            "negative_assertions": sum(row.get("capture_role") == "negative_assertion" for row in aggregate),
            "distinct_state_ids": len({row.get("state_id") for row in aggregate}),
            "distinct_task_ids": len({row.get("task_id") for row in aggregate if row.get("task_id") is not None}),
            "distinct_evidence_dimensions": len(dimensions),
        },
    }
    (OUT / "VISUAL_EVIDENCE_IDENTITY_MANIFEST_V1.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    (OUT / "visual_evidence_identity_validation_report_v1.json").write_text(json.dumps(aggregate_report, indent=2) + "\n", encoding="utf-8")
    (OUT / "screen_inventory.json").write_text(json.dumps(inventory, indent=2) + "\n", encoding="utf-8")
    hashes = {path.relative_to(OUT).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest() for path in sorted(OUT.rglob("*.png"))}
    (OUT / "SHA256SUMS.json").write_text(json.dumps(hashes, indent=2) + "\n", encoding="utf-8")
    zip_path = OUT / "current_head_product_surface_v3.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(OUT.rglob("*")):
            if path.is_file() and path != zip_path:
                archive.write(path, path.relative_to(OUT))
    print(json.dumps({"output": str(OUT), "zip": str(zip_path), "completeness": aggregate_report, "counts": manifest["counts"]}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
