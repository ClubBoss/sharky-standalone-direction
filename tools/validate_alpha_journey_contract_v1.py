#!/usr/bin/env python3
"""Fail-closed validator and local evidence manifest builder for Alpha QA v1."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from collections import Counter
from pathlib import Path


REQUIRED_CONTRACT_KEYS = {
    "schema",
    "journey_id",
    "contract_version",
    "base_route",
    "owners",
    "canonical_ids",
    "expected_path",
    "required_telemetry_order",
    "single_emission_events",
    "viewport_matrix",
    "visible_checkpoints",
    "frozen_geometry",
    "allowed_variation",
    "invalidating_changes",
}


def load_json(path: Path) -> dict:
    try:
        value = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as error:
        raise SystemExit(f"P0 invalid JSON at {path}: {error}") from error
    if not isinstance(value, dict):
        raise SystemExit(f"P0 JSON root must be an object: {path}")
    return value


def validate_contract(contract_path: Path, expected_version: int) -> dict:
    contract = load_json(contract_path)
    missing = sorted(REQUIRED_CONTRACT_KEYS - contract.keys())
    if missing:
        raise SystemExit(f"P1 contract missing keys: {', '.join(missing)}")
    if contract["schema"] != "alpha_journey_contract_v1":
        raise SystemExit("P1 unsupported Alpha journey contract schema")
    if contract["journey_id"] != "alpha_action_repair_recovery_v1":
        raise SystemExit("P1 unexpected Alpha journey ID")
    if contract["contract_version"] != expected_version:
        raise SystemExit(
            "P1 stale journey-contract version: "
            f"expected {expected_version}, got {contract['contract_version']}"
        )
    ids = contract["canonical_ids"]
    expected = {
        "world_id": "world_1",
        "lesson_id": "fold_check_call_raise",
        "theory_task_id": "actions_theory",
        "decision_task_id": "actions_check_drill",
        "sequence_id": "w1_action_words_check_v1",
        "concept_id": "action_words_no_bet_read",
    }
    for key, value in expected.items():
        if ids.get(key) != value:
            raise SystemExit(f"P1 contract {key} must be {value!r}")
    if contract["expected_path"].get("error_type") != "missed_action_read":
        raise SystemExit("P1 contract error type drift")
    if contract["expected_path"].get("payoff") != "recoveredSuccess":
        raise SystemExit("P1 contract payoff drift")
    print(f"PASS contract {contract['journey_id']} v{expected_version}")
    return contract


def validate_trace(trace_path: Path, contract: dict) -> dict:
    trace = load_json(trace_path)
    if trace.get("schema") != "alpha_journey_qa_trace_v1":
        raise SystemExit("P1 trace schema drift")
    if trace.get("debug_harness_used") is not False:
        raise SystemExit("P0 black-box trace used a direct-state harness")
    if trace.get("entry_mode") != "canonical_learn_visible_controls":
        raise SystemExit("P0 black-box trace did not start from canonical Learn controls")
    if trace.get("cta_reachability") != "ensureVisible_before_each_visible_control_tap":
        raise SystemExit("P1 CTA reachability proof is absent")
    events = trace.get("events")
    if not isinstance(events, list) or not events:
        raise SystemExit("P1 missing telemetry trace")
    names = [event.get("name") for event in events if isinstance(event, dict)]
    required = contract["required_telemetry_order"]
    positions = []
    for name in required:
        if name not in names:
            raise SystemExit(f"P1 missing required telemetry event: {name}")
        positions.append(names.index(name))
    if positions != sorted(positions):
        raise SystemExit("P1 required telemetry events are misordered")
    counts = Counter(names)
    for name in contract["single_emission_events"]:
        if counts[name] != 1:
            raise SystemExit(f"P1 {name} must be emitted once, got {counts[name]}")

    decision_events = [event for event in events if event.get("name") == "decision_made"]
    if not any(
        event.get("fields", {}).get("selected_action") == contract["expected_path"]["wrong_choice_id"]
        and event.get("fields", {}).get("is_correct") is False
        and event.get("fields", {}).get("error_type") == contract["expected_path"]["error_type"]
        and isinstance(event.get("fields", {}).get("time_to_decision_ms"), int)
        for event in decision_events
    ):
        raise SystemExit("P1 wrong decision classification or time-to-decision proof is absent")
    if not any(
        event.get("fields", {}).get("is_correct") is True
        and event.get("fields", {}).get("error_type") == "none"
        for event in decision_events
    ):
        raise SystemExit("P1 corrected decision proof is absent")

    session_ids = {
        event.get("fields", {}).get("session_id")
        for event in events
        if event.get("name") in required and event.get("fields", {}).get("session_id")
    }
    if len(session_ids) != 1:
        raise SystemExit("P1 required telemetry is not continuous within one session")
    payoff_events = [event for event in events if event.get("name") == "action_payoff_generated"]
    if not any(event.get("fields", {}).get("payoff_type") == "recoveredSuccess" for event in payoff_events):
        raise SystemExit("P1 recovered payoff is absent from trace")
    sequence_events = [event for event in events if event.get("fields", {}).get("sequence_id")]
    if not sequence_events or any(
        event["fields"].get("sequence_id") != contract["canonical_ids"]["sequence_id"]
        for event in sequence_events
    ):
        raise SystemExit("P1 same-signal sequence continuity failed")
    print("PASS canonical black-box trace: ordered, single-emission, same-session, recovered")
    return trace


def validate_evidence(bundle: Path, contract: dict) -> None:
    required_names = (
        "canonical_sequence_contact_sheet.png",
        "wrong_repair_recheck_contact_sheet.png",
        "correct_completion_contact_sheet.png",
        "raster_geometry_metrics.json",
        "raster_state_inventory.md",
    )
    for device in contract["viewport_matrix"]:
        directory = bundle / "05_phone_evidence" / device
        missing = [name for name in required_names if not (directory / name).is_file()]
        if missing:
            raise SystemExit(f"P1 {device} evidence incomplete: {', '.join(missing)}")
        metrics = load_json(directory / "raster_geometry_metrics.json")
        for row in metrics.get("states", []):
            if row.get("overflow"):
                raise SystemExit(f"P1 {device} raster overflow: {row.get('name')}")
        expected_size = contract["viewport_matrix"][device]
        viewport = metrics.get("viewport", {})
        if [viewport.get("width"), viewport.get("height")] != expected_size:
            raise SystemExit(f"P1 {device} viewport drift")
    print("PASS compact/tall/large raster evidence and geometry metrics")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_manifest(bundle: Path, contract: dict, trace: dict, base_sha: str) -> None:
    files = []
    for path in sorted(bundle.rglob("*")):
        if path.is_file():
            files.append({"path": str(path.relative_to(bundle)), "sha256": sha256(path), "bytes": path.stat().st_size})
    manifest = {
        "schema": "alpha_journey_qa_manifest_v1",
        "journey_id": contract["journey_id"],
        "contract_version": contract["contract_version"],
        "base_head": base_sha,
        "execution_mode": trace["execution_mode"],
        "black_box_direct_state": trace["debug_harness_used"],
        "required_viewports": list(contract["viewport_matrix"].keys()),
        "required_telemetry_order": contract["required_telemetry_order"],
        "files": files,
    }
    manifest_path = bundle / "09_manifest" / "manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    report = bundle / "01_report" / "admission_report.md"
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(
        "# Alpha Journey QA Factory v1 admission\n\n"
        "- Verdict: `alpha_journey_qa_factory_v1_admitted_not_pushed` pending repository publication.\n"
        f"- Base HEAD: `{base_sha}`\n"
        f"- Journey: `{contract['journey_id']}` v{contract['contract_version']}\n"
        "- Black-box mode: deterministic widget replay from the canonical Learn controls; no direct-state harness.\n"
        "- Telemetry: required sequence ordered; required lifecycle events emitted once; recovered payoff present.\n"
        "- Viewports: compact, tall_phone, large_phone; raster geometry metrics contain no overflow.\n"
        "- Modern Table: frozen by the commit-path boundary; Action table geometry is checked by the raster lane.\n"
        "- P0: 0; P1: 0 at bundle creation.\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", required=True, type=Path)
    parser.add_argument("--expected-version", type=int, default=1)
    parser.add_argument("--trace", type=Path)
    parser.add_argument("--bundle", type=Path)
    parser.add_argument("--base-sha")
    args = parser.parse_args()
    contract = validate_contract(args.contract, args.expected_version)
    if args.trace is None:
        return
    if args.bundle is None or not args.base_sha:
        raise SystemExit("--trace requires --bundle and --base-sha")
    trace = validate_trace(args.trace, contract)
    validate_evidence(args.bundle, contract)
    build_manifest(args.bundle, contract, trace, args.base_sha)
    print("PASS local admission report and manifest")


if __name__ == "__main__":
    main()
