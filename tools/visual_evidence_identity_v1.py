#!/usr/bin/env python3
"""Source-owned Visual Evidence Identity v1 validation and aggregation helpers.

This module intentionally validates identities emitted by capture owners.  It
never derives semantic fields from filenames or pixels; a path is only used to
locate the already-declared PNG for hash and existence checks.
"""
from __future__ import annotations

import hashlib
import json
import sys
import tempfile
from pathlib import Path, PurePosixPath
from typing import Any

SCHEMA = "visual_evidence_identity_v1"
MANIFEST_SCHEMA = "VISUAL_EVIDENCE_IDENTITY_MANIFEST_V1"
UNKNOWN = "UNKNOWN_TYPED_FIELD"
REQUIRED_FIELDS = (
    "schema_version", "evidence_id", "capture_group", "capture_surface_id",
    "relative_png_path", "png_sha256", "evidence_baseline_sha", "state_id",
    "task_id", "lesson_id", "world_id", "semantic_state", "interaction_state",
    "renderer_family", "production_owner", "runtime_reachable", "capture_role",
    "device_class", "viewport_width", "viewport_height", "text_scale",
    "motion_mode", "scroll_position", "scroll_contract", "safe_area_class",
    "option_count", "control_type", "table_present", "table_presentation_class",
    "feedback_composition", "repair_capable", "recheck_capable", "completion_form",
    "source_fixture_or_route", "identity_source_owner",
)
IDENTITY_DIMENSIONS = (
    "capture_group", "capture_surface_id", "state_id", "task_id", "device_class",
    "text_scale", "motion_mode", "scroll_position",
)


def canonical_evidence_id(record: dict[str, Any]) -> str:
    """Return the recapture-stable ID from typed capture dimensions only."""
    dimensions = {key: record.get(key) for key in IDENTITY_DIMENSIONS}
    encoded = json.dumps(dimensions, sort_keys=True, separators=(",", ":"))
    return "vei1_" + hashlib.sha256(encoded.encode("utf-8")).hexdigest()


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _safe_relative(value: object) -> bool:
    if not isinstance(value, str) or not value:
        return False
    path = PurePosixPath(value.replace("\\", "/"))
    return not path.is_absolute() and ".." not in path.parts


def validate_records(
    records: list[dict[str, Any]],
    png_root: Path,
    *,
    admitted_paths: set[str] | None = None,
    expected_baseline: str | None = None,
) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    """Validate the join without reconstructing any semantic identity."""
    invalid_fields: list[str] = []
    duplicate_ids: set[str] = set()
    duplicate_paths: set[str] = set()
    seen_ids: set[str] = set()
    seen_paths: set[str] = set()
    normalized: list[dict[str, Any]] = []
    for index, record in enumerate(records):
        if not isinstance(record, dict):
            invalid_fields.append(f"record[{index}]:not_object")
            continue
        missing = [field for field in REQUIRED_FIELDS if field not in record]
        if missing:
            invalid_fields.append(f"record[{index}]:missing:{','.join(missing)}")
        if record.get("schema_version") != SCHEMA:
            invalid_fields.append(f"record[{index}]:schema_version")
        evidence_id = record.get("evidence_id")
        relative = record.get("relative_png_path")
        if not isinstance(evidence_id, str) or evidence_id != canonical_evidence_id(record):
            invalid_fields.append(f"record[{index}]:noncanonical_evidence_id")
        if not _safe_relative(relative):
            invalid_fields.append(f"record[{index}]:unsafe_relative_png_path")
        if isinstance(evidence_id, str):
            if evidence_id in seen_ids:
                duplicate_ids.add(evidence_id)
            seen_ids.add(evidence_id)
        if isinstance(relative, str):
            if relative in seen_paths:
                duplicate_paths.add(relative)
            seen_paths.add(relative)
        normalized.append(record)

    admitted = admitted_paths if admitted_paths is not None else {
        path.relative_to(png_root).as_posix()
        for path in png_root.rglob("*.png")
        if path.is_file()
    }
    declared = {str(record.get("relative_png_path")) for record in normalized if _safe_relative(record.get("relative_png_path"))}
    unmapped = sorted(admitted - declared)
    orphan = sorted(declared - admitted)
    hash_mismatches = sorted(
        relative for relative in admitted & declared
        if sha256_file(png_root / relative) != next(
            record.get("png_sha256") for record in normalized
            if record.get("relative_png_path") == relative
        )
    )
    baselines = {record.get("evidence_baseline_sha") for record in normalized}
    baseline_mismatch = (
        not baselines or None in baselines or len(baselines) != 1 or
        (expected_baseline is not None and baselines != {expected_baseline})
    )
    negative_masquerades = sorted(
        str(record.get("evidence_id")) for record in normalized
        if record.get("capture_role") in ("negative_assertion", "fixture_only")
        and record.get("runtime_reachable") is True
    )
    disposition = "IDENTITY_MAPPED"
    if duplicate_ids or duplicate_paths or invalid_fields:
        disposition = "IDENTITY_CONFLICT"
    elif unmapped:
        disposition = "IDENTITY_UNMAPPED"
    elif orphan:
        disposition = "IDENTITY_ORPHAN"
    elif hash_mismatches:
        disposition = "IDENTITY_HASH_MISMATCH"
    elif baseline_mismatch:
        disposition = "IDENTITY_BASELINE_MISMATCH"
    report: dict[str, Any] = {
        "schema_version": "visual_evidence_identity_validation_report_v1",
        "disposition": disposition,
        "total_admitted_pngs": len(admitted), "total_identity_records": len(records),
        "mapped_png_count": len(admitted - set(unmapped)), "unmapped_png_count": len(unmapped),
        "conflicting_identity_count": len(duplicate_ids) + len(duplicate_paths) + len(invalid_fields),
        "orphan_identity_count": len(orphan), "hash_mismatch_count": len(hash_mismatches),
        "baseline_mismatch_count": int(baseline_mismatch),
        "negative_assertion_masquerade_count": len(negative_masquerades),
        "unmapped_pngs": unmapped, "orphan_identity_paths": orphan,
        "hash_mismatches": hash_mismatches, "duplicate_evidence_ids": sorted(duplicate_ids),
        "duplicate_relative_png_paths": sorted(duplicate_paths), "invalid_records": invalid_fields,
        "negative_assertion_masquerades": negative_masquerades,
    }
    return report, normalized


def _self_test() -> int:
    """Focused executable proof for joins, hashes, baseline, and lookalikes."""
    with tempfile.TemporaryDirectory(prefix="vei1-") as temporary:
        root = Path(temporary)
        png = root / "owner.png"
        png.write_bytes(b"source-owned-png")
        record: dict[str, Any] = {field: None for field in REQUIRED_FIELDS}
        record.update({
            "schema_version": SCHEMA, "capture_group": "test", "capture_surface_id": "owner",
            "relative_png_path": "owner.png", "png_sha256": sha256_file(png),
            "evidence_baseline_sha": "baseline", "state_id": "owner", "task_id": None,
            "device_class": "compact", "text_scale": 1.0, "motion_mode": "normal",
            "scroll_position": "top", "runtime_reachable": True,
            "capture_role": "production_representative", "identity_source_owner": "test",
        })
        record["evidence_id"] = canonical_evidence_id(record)
        valid, _ = validate_records([record], root, admitted_paths={"owner.png"}, expected_baseline="baseline")
        assert valid["disposition"] == "IDENTITY_MAPPED"
        # A filename lookalike cannot acquire an identity without a source record.
        (root / "owner.lookalike.png").write_bytes(b"not mapped")
        unmapped, _ = validate_records([record], root, admitted_paths={"owner.png", "owner.lookalike.png"}, expected_baseline="baseline")
        assert unmapped["disposition"] == "IDENTITY_UNMAPPED"
        duplicate, _ = validate_records([record, dict(record)], root, admitted_paths={"owner.png"}, expected_baseline="baseline")
        assert duplicate["disposition"] == "IDENTITY_CONFLICT"
        mutated = dict(record); mutated["png_sha256"] = "0" * 64
        mismatch, _ = validate_records([mutated], root, admitted_paths={"owner.png"}, expected_baseline="baseline")
        assert mismatch["disposition"] == "IDENTITY_HASH_MISMATCH"
    print("visual_evidence_identity_v1: self-test passed")
    return 0


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        raise SystemExit(_self_test())
    raise SystemExit("usage: visual_evidence_identity_v1.py --self-test")
