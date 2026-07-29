#!/usr/bin/env python3
"""Exact-row hosted native visual delta transport.

This intentionally reuses the audited simulator capture implementation while
keeping one-off delta rows out of the canonical 54-row baseline manifest.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import shutil
import sys

import sharky_native_visual_audit_v1 as native

ROOT = pathlib.Path(__file__).resolve().parents[1]
PROFILES = {"canonical", "compact", "large"}
MODIFIERS = {"none", "text_scale_1_4", "reduced_motion"}
REQUIRED = {
    "visual_state_id", "state", "semantic_phase", "device_profile",
    "modifier", "logical_viewport", "query",
}


def load_spec(path: pathlib.Path) -> list[dict]:
    payload = json.loads(path.read_text())
    rows = payload.get("rows", payload) if isinstance(payload, dict) else payload
    if not isinstance(rows, list) or not rows:
        raise RuntimeError("delta specification requires a non-empty rows list")
    missing = [f"row {i} missing {sorted(REQUIRED - set(row))}" for i, row in enumerate(rows) if not isinstance(row, dict) or REQUIRED - set(row)]
    if missing:
        raise RuntimeError("; ".join(missing))
    ids = [row["visual_state_id"] for row in rows]
    tuples = [(row["state"], row["device_profile"], row["modifier"]) for row in rows]
    if len(ids) != len(set(ids)):
        raise RuntimeError("delta visual_state_id values must be unique")
    if len(tuples) != len(set(tuples)):
        raise RuntimeError("delta state/device_profile/modifier tuples must be unique")
    for row in rows:
        if row["device_profile"] not in PROFILES:
            raise RuntimeError(f"unadmitted device profile: {row['device_profile']}")
        if row["modifier"] not in MODIFIERS:
            raise RuntimeError(f"unadmitted modifier: {row['modifier']}")
        if not row["query"].strip():
            raise RuntimeError(f"empty truthful query: {row['visual_state_id']}")
    return rows


def emit_shards(rows: list[dict], output: pathlib.Path) -> list[str]:
    output.mkdir(parents=True, exist_ok=True)
    groups: dict[tuple[str, str], list[dict]] = {}
    for row in rows:
        groups.setdefault((row["device_profile"], row["modifier"]), []).append(row)
    names = []
    for (profile, modifier), group in sorted(groups.items()):
        name = f"{profile}-{modifier}"; names.append(name)
        (output / f"{name}.json").write_text(json.dumps({"schema": "sharky_native_visual_delta_shard_v1", "shard": name, "rows": group}, indent=2) + "\n")
    return names


def capture_shard(spec: pathlib.Path, app: pathlib.Path, output: pathlib.Path, candidate: str) -> None:
    rows = load_spec(spec)
    profiles = {row["device_profile"] for row in rows}
    if len(profiles) != 1:
        raise RuntimeError("a delta shard must contain one device profile")
    args = argparse.Namespace(app=app, out=output, candidate_sha=candidate, shard=spec.stem, resume_from=None, ready_timeout=30.0, frame_settle_seconds=1.5)
    native.capture(rows, args)


def aggregate(spec: pathlib.Path, shards: pathlib.Path, output: pathlib.Path, candidate: str) -> None:
    expected = load_spec(spec); expected_ids = [row["visual_state_id"] for row in expected]
    records = []
    for manifest in shards.rglob("shard_capture_manifest.json"):
        payload = json.loads(manifest.read_text())
        if payload.get("status") != "success" or payload.get("candidate_sha") != candidate:
            raise RuntimeError(f"incomplete or foreign delta shard: {manifest}")
        for row in payload["rows"]:
            image = manifest.parent / row["png"]
            if not image.is_file() or native.sha256(image) != row["png_sha256"]:
                raise RuntimeError(f"delta PNG/hash mismatch: {image}")
            native.assert_valid_frame(image)
            records.append((row, image))
    if {row["visual_state_id"] for row, _ in records} != set(expected_ids) or len(records) != len(expected_ids):
        raise RuntimeError("captured delta rows do not exactly match requested rows")
    raw = output / "raw"; raw.mkdir(parents=True, exist_ok=True)
    manifest_rows = []
    for row, image in records:
        copied = raw / f"{row['visual_state_id']}.png"; shutil.copy2(image, copied)
        manifest_rows.append(row | {"png": str(copied.relative_to(output)), "png_sha256": native.sha256(copied)})
    (output / "native_delta_manifest.json").write_text(json.dumps({"schema": "sharky_native_visual_delta_v1", "candidate_sha": candidate, "requested_rows": expected_ids, "rows": manifest_rows, "status": "success"}, indent=2) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=pathlib.Path, required=True)
    parser.add_argument("--emit-shards", type=pathlib.Path)
    parser.add_argument("--capture-shard", type=pathlib.Path)
    parser.add_argument("--app", type=pathlib.Path); parser.add_argument("--out", type=pathlib.Path)
    parser.add_argument("--candidate-sha"); parser.add_argument("--aggregate-shards", type=pathlib.Path)
    args = parser.parse_args(); rows = load_spec(args.spec)
    if args.emit_shards:
        print(json.dumps({"row_count": len(rows), "shards": emit_shards(rows, args.emit_shards)})); return 0
    if args.capture_shard:
        if not args.app or not args.out or not args.candidate_sha: raise RuntimeError("capture requires app, out, candidate SHA")
        capture_shard(args.capture_shard, args.app, args.out, args.candidate_sha); return 0
    if args.aggregate_shards:
        if not args.out or not args.candidate_sha: raise RuntimeError("aggregate requires out and candidate SHA")
        aggregate(args.spec, args.aggregate_shards, args.out, args.candidate_sha); return 0
    raise RuntimeError("explicit delta operation required")


if __name__ == "__main__":
    try: raise SystemExit(main())
    except RuntimeError as error: print(f"native visual delta: {error}", file=sys.stderr); raise SystemExit(1)
