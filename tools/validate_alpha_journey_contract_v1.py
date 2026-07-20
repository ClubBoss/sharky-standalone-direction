#!/usr/bin/env python3
"""Fail-closed validator and local evidence manifest builder for Alpha QA."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from collections import Counter
from pathlib import Path


REQUIRED_CONTRACT_KEYS = {
    "schema",
    "journey_kind",
    "journey_id",
    "contract_version",
    "base_route",
    "owners",
    "precondition",
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


def validate_action_fixture(contract_path: Path, contract: dict) -> None:
    precondition = contract["precondition"]
    fixture_path = Path(precondition.get("fixture_path", ""))
    if not fixture_path.is_file():
        raise SystemExit("P1 Action contract precondition fixture is missing")
    fixture = load_json(fixture_path)
    if fixture.get("schema") != "act0_progression_fixture_v1":
        raise SystemExit("P1 unsupported Action progression fixture schema")
    if fixture.get("fixture_id") != precondition.get("fixture_id"):
        raise SystemExit("P1 Action precondition fixture ID drift")
    lessons = fixture.get("completed_lesson_ids")
    if not isinstance(lessons, list) or lessons != [
        "what_poker_is",
        "what_poker_is_content",
        "cards_ranks_suits",
        "your_first_hand",
    ]:
        raise SystemExit("P1 Action fixture must represent the exact four completed prerequisites")
    target = fixture.get("target")
    if not isinstance(target, dict) or target.get("lesson_id") != "fold_check_call_raise" or target.get("task_id") != "actions_theory":
        raise SystemExit("P1 Action fixture must start before Action theory")
    constraints = fixture.get("constraints")
    if not isinstance(constraints, dict) or constraints.get("all_prerequisite_tasks_completed") is not True or constraints.get("allows_dev_or_debug_shortcut") is not False or constraints.get("allows_intermediate_action_state") is not False:
        raise SystemExit("P1 Action fixture shortcut guard is missing")


def validate_contract(contract_path: Path, expected_version: int, expected_kind: str | None = None) -> dict:
    contract = load_json(contract_path)
    missing = sorted(REQUIRED_CONTRACT_KEYS - contract.keys())
    if missing:
        raise SystemExit(f"P1 contract missing keys: {', '.join(missing)}")
    if contract["schema"] != "alpha_journey_contract_v2":
        raise SystemExit("P1 unsupported Alpha journey contract schema")
    kind = contract["journey_kind"]
    if kind not in {"fresh_install", "action_capability"}:
        raise SystemExit("P1 unsupported Alpha journey kind")
    if expected_kind is not None and kind != expected_kind:
        raise SystemExit(f"P1 expected {expected_kind} journey, got {kind}")
    if contract["contract_version"] != expected_version:
        raise SystemExit(
            "P1 stale journey-contract version: "
            f"expected {expected_version}, got {contract['contract_version']}"
        )
    precondition = contract["precondition"]
    if not isinstance(precondition, dict) or precondition.get("allows_dev_or_debug_shortcut") is not False:
        raise SystemExit("P1 journey must reject Dev/debug shortcuts")
    ids = contract["canonical_ids"]
    if kind == "fresh_install":
        expected = {
            "world_id": "world_1",
            "lesson_id": "what_poker_is",
            "first_task_id": "what_poker_is_theory",
        }
        for key, value in expected.items():
            if ids.get(key) != value:
                raise SystemExit(f"P1 fresh contract {key} must be {value!r}")
        path = contract["expected_path"]
        if path.get("completed_lesson_count_before") != 0 or path.get("action_lesson_state_before") != "locked" or path.get("first_lesson_completion_advances_to") != "what_poker_is_content":
            raise SystemExit("P1 fresh-install progression truth drift")
        print(f"PASS fresh-install contract {contract['journey_id']} v{expected_version}")
        return contract

    if contract["journey_id"] != "alpha_action_repair_recovery_unlocked_v2":
        raise SystemExit("P1 unexpected Action capability journey ID")
    if precondition.get("kind") != "persisted_progression_fixture" or precondition.get("allows_intermediate_action_state") is not False:
        raise SystemExit("P1 Action capability precondition is invalid")
    validate_action_fixture(contract_path, contract)
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
    if contract["expected_path"].get("error_type") != "misread_action_legality":
        raise SystemExit("P1 contract error type drift")
    if contract["expected_path"].get("payoff") != "recoveredSuccess":
        raise SystemExit("P1 contract payoff drift")
    print(f"PASS Action capability contract {contract['journey_id']} v{expected_version}")
    return contract


def field_value(event: dict, snake_name: str, camel_name: str | None = None):
    fields = event.get("fields", {})
    if not isinstance(fields, dict):
        return None
    return fields.get(snake_name, fields.get(camel_name) if camel_name else None)


def event_index(events: list[dict], event: dict) -> int:
    return next(index for index, candidate in enumerate(events) if candidate is event)


def validate_black_box_source(replay_source: Path) -> None:
    try:
        source = replay_source.read_text()
    except OSError as error:
        raise SystemExit(f"P1 cannot inspect black-box replay source: {error}") from error
    title = "unlocked Action capability journey completes the alpha loop with ordered safe telemetry"
    marker = f"testWidgets(\n    '{title}'"
    start = source.find(marker)
    end = source.find("testWidgets(", start + len(marker))
    if start == -1 or end == -1:
        raise SystemExit("P1 canonical black-box test boundary is not discoverable")
    body = source[start:end]
    forbidden = (
        "debugHarnessEntry",
        "Act0ControlledDemoCaptureModeV1.directState",
        "initialTab: Act0ShellTabV1.play",
        "initialPhase:",
        "debugHarnessEntry:",
    )
    found = [token for token in forbidden if token in body]
    if found:
        raise SystemExit(
            "P0 canonical black-box replay contains direct-state setup: " + ", ".join(found)
        )
    required = (
        "startActionsTheoryFromLearnV1",
        "answerVisiblePromptWronglyV1",
        "answerVisiblePromptCorrectlyV1",
        "act0_shell_runner_back",
        "act0_shell_learn_screen",
    )
    missing = [token for token in required if token not in body]
    if missing:
        raise SystemExit("P1 canonical visible-control proof drift: " + ", ".join(missing))
    if "seedActionCapabilityPreconditionV1" not in source:
        raise SystemExit("P1 Action replay is missing the validated progression fixture")
    print("PASS Action source proof: validated progression precondition, visible controls, repair/recheck, safe Learn exit")


def validate_trace(trace_path: Path, contract: dict, replay_source: Path) -> dict:
    trace = load_json(trace_path)
    if trace.get("schema") != "alpha_journey_qa_trace_v1":
        raise SystemExit("P1 trace schema drift")
    if trace.get("journey_id") != contract["journey_id"]:
        raise SystemExit("P1 trace journey ID drift")
    if trace.get("contract_version") != contract["contract_version"]:
        raise SystemExit("P1 trace contract version drift")
    if trace.get("black_box_test_name") != (
        "unlocked Action capability journey completes the alpha loop with ordered safe telemetry"
    ):
        raise SystemExit("P1 trace does not identify the Action capability replay")
    if trace.get("debug_harness_used") is not False:
        raise SystemExit("P0 black-box trace used a direct-state harness")
    if trace.get("entry_mode") != "unlocked_action_visible_controls":
        raise SystemExit("P0 black-box trace did not use unlocked visible Action controls")
    starting_progression = trace.get("starting_progression")
    if not isinstance(starting_progression, dict) or starting_progression.get("kind") != "persisted_progression_fixture" or starting_progression.get("fixture_id") != contract["precondition"]["fixture_id"] or starting_progression.get("obtained_by") != "completed prerequisite learner history":
        raise SystemExit("P1 Action trace precondition provenance is absent")
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
    decision_task = contract["canonical_ids"]["decision_task_id"]
    wrong_events = [
        event for event in decision_events
        if field_value(event, "task_id", "taskId") == decision_task
        and field_value(event, "selected_action") == contract["expected_path"]["wrong_choice_id"]
        and field_value(event, "is_correct") is False
        and field_value(event, "error_type", "errorType") == contract["expected_path"]["error_type"]
        and field_value(event, "decisionTimeBucket")
        in {"under_3s", "3_to_10s", "over_10s", "unknown"}
        and "time_to_decision_ms" not in event.get("fields", {})
    ]
    if not wrong_events:
        raise SystemExit("P1 wrong decision classification or bounded time-to-decision proof is absent")
    repair_started = [event for event in events if event.get("name") == "repair_started"]
    repair_completed = [event for event in events if event.get("name") == "repair_completed"]
    recheck_started = [event for event in events if event.get("name") == "recheck_started"]
    recheck_results = [event for event in events if event.get("name") == "recheck_result"]
    if len(repair_started) != 1 or len(repair_completed) != 1 or len(recheck_started) != 1 or len(recheck_results) != 1:
        raise SystemExit("P1 repair/recheck lifecycle must have exactly one bound path")
    repair_task = contract["expected_path"]["repair_task_id"]
    recheck_task = contract["expected_path"]["recheck_task_id"]
    repair_start = repair_started[0]
    repair_done = repair_completed[0]
    recheck_start = recheck_started[0]
    recheck_done = recheck_results[0]
    if (
        field_value(repair_start, "source_task_id", "sourceTaskId") != decision_task
        or field_value(repair_start, "repair_task_id", "repairTaskId") != repair_task
        or field_value(repair_done, "source_task_id", "sourceTaskId") != decision_task
        or field_value(repair_done, "repair_task_id", "repairTaskId") != repair_task
        or field_value(repair_done, "result") != "correct"
        or field_value(recheck_start, "source_task_id", "sourceTaskId") != decision_task
        or field_value(recheck_start, "repair_task_id", "repairTaskId") != repair_task
        or field_value(recheck_start, "recheck_task_id", "recheckTaskId") != recheck_task
        or field_value(recheck_done, "source_task_id", "sourceTaskId") != decision_task
        or field_value(recheck_done, "recheck_task_id", "recheckTaskId") != recheck_task
        or field_value(recheck_done, "result") != "correct"
    ):
        raise SystemExit("P1 repair/recheck task mapping or result drift")

    wrong_index = event_index(events, wrong_events[0])
    repair_start_index = event_index(events, repair_start)
    repair_done_index = event_index(events, repair_done)
    recheck_start_index = event_index(events, recheck_start)
    recheck_done_index = event_index(events, recheck_done)
    if not wrong_index < repair_start_index < repair_done_index < recheck_start_index < recheck_done_index:
        raise SystemExit("P1 wrong-to-repair-to-recheck path is misordered")
    corrected_repair = [
        event for event in decision_events
        if repair_start_index < event_index(events, event) < repair_done_index
        and field_value(event, "task_id", "taskId") == repair_task
        and field_value(event, "selected_action") == contract["expected_path"]["correct_choice_id"]
        and field_value(event, "is_correct") is True
        and field_value(event, "error_type", "errorType") == "none"
    ]
    corrected_recheck = [
        event for event in decision_events
        if recheck_start_index < event_index(events, event) < recheck_done_index
        and field_value(event, "task_id", "taskId") == recheck_task
        and field_value(event, "selected_action") == contract["expected_path"]["correct_choice_id"]
        and field_value(event, "is_correct") is True
        and field_value(event, "error_type", "errorType") == "none"
    ]
    if not corrected_repair or not corrected_recheck:
        raise SystemExit("P1 corrected repair or corrected recheck decision proof is absent")

    session_scoped_names = {
        "theory_completed", "repair_started", "repair_completed", "recheck_started",
        "recheck_result", "action_sequence_completed", "session_exited",
    }
    session_scoped_events = [event for event in events if event.get("name") in session_scoped_names]
    session_ids = {field_value(event, "session_id", "sessionId") for event in session_scoped_events}
    if not session_scoped_events or None in session_ids or len(session_ids) != 1:
        raise SystemExit("P1 session-scoped lifecycle telemetry is not continuous within one session")
    payoff_events = [event for event in events if event.get("name") == "action_payoff_generated"]
    if not any(
        field_value(event, "payoff_type") == contract["expected_path"]["payoff"]
        and event_index(events, event) > recheck_start_index
        for event in payoff_events
    ):
        raise SystemExit("P1 recovered payoff is absent from trace")
    signal_names = {"decision_made", "action_payoff_generated", "recheck_started", "recheck_result", "action_sequence_completed"}
    sequence_events = [
        event for event in events
        if event.get("name") in signal_names
        and (field_value(event, "sequence_id", "sequenceId") is not None)
    ]
    if not sequence_events or any(
        field_value(event, "sequence_id", "sequenceId") != contract["canonical_ids"]["sequence_id"]
        for event in sequence_events
    ):
        raise SystemExit("P1 same-signal sequence continuity failed")
    validate_black_box_source(replay_source)
    print("PASS Action capability trace: ordered, bound repair/recheck, session-scoped, same-signal, recovered")
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
        directory = bundle / "07_computer_use_action" / device
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
    report = bundle / "01_report" / "admission_report.md"
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(
        "# Alpha Journey QA Factory admission\n\n"
        "- Verdict: `alpha_journey_qa_factory_progression_truth_admitted_not_pushed` pending repository publication.\n"
        f"- Base HEAD: `{base_sha}`\n"
        f"- Journey: `{contract['journey_id']}` v{contract['contract_version']}\n"
        "- Black-box mode: visible Action controls after an explicit production-equivalent persisted progression precondition; source guard rejects direct-state setup in the replay body.\n"
        "- Telemetry: ordered single-emission lifecycle, one session-scoped continuity chain, bound same-task repair/recheck, same-signal sequence, and recovered payoff.\n"
        "- Viewports: compact, tall_phone, large_phone; raster geometry metrics contain no overflow.\n"
        "- Modern Table: frozen by the commit-path boundary; Action table geometry is checked by the raster lane.\n"
        "- Integrity: manifest hashes every bundle file except itself; archive SHA-256 is a sibling `.zip.sha256` file.\n"
        "- P0: 0; P1: 0 at bundle creation.\n"
    )
    manifest_path = bundle / "10_manifest" / "manifest.json"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    files = []
    for path in sorted(bundle.rglob("*")):
        if path.is_file() and path != manifest_path:
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
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--contract", required=True, type=Path)
    parser.add_argument("--expected-version", type=int, default=1)
    parser.add_argument("--expected-kind", choices=("fresh_install", "action_capability"))
    parser.add_argument("--trace", type=Path)
    parser.add_argument("--bundle", type=Path)
    parser.add_argument("--base-sha")
    parser.add_argument("--replay-source", type=Path)
    parser.add_argument("--write-manifest", action="store_true")
    args = parser.parse_args()
    contract = validate_contract(args.contract, args.expected_version, args.expected_kind)
    if args.trace is None:
        return
    if contract["journey_kind"] != "action_capability":
        raise SystemExit("P1 only Action capability contracts may carry a repair/recheck trace")
    if args.bundle is None or not args.base_sha:
        raise SystemExit("--trace requires --bundle and --base-sha")
    if args.replay_source is None:
        raise SystemExit("--trace requires --replay-source")
    trace = validate_trace(args.trace, contract, args.replay_source)
    validate_evidence(args.bundle, contract)
    if args.write_manifest:
        build_manifest(args.bundle, contract, trace, args.base_sha)
        print("PASS local admission report and manifest")


if __name__ == "__main__":
    main()
