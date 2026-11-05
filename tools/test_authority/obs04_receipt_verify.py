#!/usr/bin/env python3
"""Bounded OBS04 artifact verifier. Expected execution identity is an input.

An artifact is not its own authenticity authority. Independently obtain the
checkout/tree/run/attempt/job identity from GitHub before reviewing a download.
This tool verifies only two test-owned diagnostic windows, not native recovery,
durability of acknowledged writes, or original DoD acceptance.
"""

import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


TEST = "test/ui_v2/act0_obs04_persist_diagnostics_v1_test.dart"
COMMAND = "./tools/test_authority_canonical_lane_v1.sh"
CASES = {"wrong_acknowledged", "correct_indeterminate"}
SOURCE_PATHS = [
    TEST, "tools/test_authority/obs04_receipt_verify.py",
    ".github/workflows/test-authority-lanes.yml", ".fvmrc", "pubspec.yaml",
    "pubspec.lock", "tools/test_authority_canonical_lane_v1.sh",
    "tools/test_authority/run_lane_v1.py",
] + ["lib/ui_v2/act0_shell/" + name for name in [
    "act0_shell_preview_screen_v1.dart", "act0_lesson_runner_shell_v1.dart",
    "act0_progress_store_v1.dart", "act0_learning_evidence_contract_v1.dart",
    "act0_session_identity_v1.dart", "act0_shell_state_v1.dart",
]]
IDENTITY_KEYS = ("repository", "checkout_sha", "source_tree", "event_sha",
                 "head_sha", "run_id", "run_attempt", "job_key",
                 "workflow_ref", "workflow_sha")
RECORD_FIELDS = {
    "schemaVersion", "recordId", "createdOrder", "worldId", "lessonId",
    "taskId", "sourceTaskId", "choiceId", "expectedChoiceId", "isCorrect",
    "errorType", "resultKind", "assistanceKind", "runId", "runKind",
    "runOrdinal", "sessionId", "authoredSourceFingerprint", "reviewKind",
}
EVENT_FIELDS = {
    "schemaVersion", "world_id", "lesson_id", "task_id", "session_id",
    "choiceId", "correct", "is_correct", "error_type", "assistance_kind",
    "attempt_id", "review_kind", "request_generation", "operation",
    "outcome", "source_surface",
}


class Insufficient(ValueError):
    pass


def require(condition, reason):
    if not condition:
        raise Insufficient(reason)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def sha(value, width=64):
    return isinstance(value, str) and re.fullmatch(r"[0-9a-f]{%d}" % width, value)


def nonempty(value):
    return isinstance(value, str) and bool(value.strip())


def run(root, *args):
    return subprocess.check_output(args, cwd=root, text=True).strip()


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def physical_sources(root):
    sources = {}
    for name in SOURCE_PATHS:
        path = root / name
        require(path.is_file(), "missing physical build input: " + name)
        tracked = bool(run(root, "git", "ls-files", "--", name))
        if tracked:
            require(not run(root, "git", "diff", "HEAD", "--", name),
                    "tracked build input differs from checkout: " + name)
        sources[name] = {"sha256": digest(path.read_bytes()), "tracked": tracked}
    require(all(value["tracked"] for name, value in sources.items()
                if name != "pubspec.lock"), "untracked source input")
    return sources


def prepare(root, packet):
    identity = {
        "repository": os.environ.get("GITHUB_REPOSITORY", ""),
        "checkout_sha": run(root, "git", "rev-parse", "HEAD"),
        "source_tree": run(root, "git", "rev-parse", "HEAD^{tree}"),
        "event_sha": os.environ.get("GITHUB_SHA", ""),
        "head_sha": os.environ.get("OBS04_HEAD_SHA", ""),
        "run_id": os.environ.get("GITHUB_RUN_ID", ""),
        "run_attempt": os.environ.get("GITHUB_RUN_ATTEMPT", ""),
        "job_key": os.environ.get("GITHUB_JOB", ""),
        "workflow_ref": os.environ.get("GITHUB_WORKFLOW_REF", ""),
        "workflow_sha": os.environ.get("GITHUB_WORKFLOW_SHA", ""),
    }
    sdk = json.loads(run(root, "flutter", "--version", "--machine"))
    manifest = {"format": 1, "identity": identity, "command": COMMAND,
                "sdk": {key: sdk[key] for key in
                        ("frameworkVersion", "frameworkRevision", "dartSdkVersion")},
                "sources": physical_sources(root), "receipts": {}}
    write_json(packet / "manifest.json", manifest)
    # CI-local expected identity is a runtime cross-check, not independent QA.
    write_json(packet / "ci_expected_execution.json", {**identity, "sources": manifest["sources"]})


def seal(root, packet):
    manifest = json.loads((packet / "manifest.json").read_text())
    require(physical_sources(root) == manifest["sources"], "build inputs changed")
    require(run(root, "git", "rev-parse", "HEAD") ==
            manifest["identity"]["checkout_sha"], "checkout changed")
    receipts = {}
    for name in sorted(CASES):
        path = packet / (name + ".json")
        require(path.is_file(), "missing actual capture: " + name)
        receipts[path.name] = {"sha256": digest(path.read_bytes()),
                               "size": path.stat().st_size}
    manifest["receipts"] = receipts
    write_json(packet / "manifest.json", manifest)


def validate_manifest(manifest, expected):
    require(isinstance(manifest, dict) and manifest.get("format") == 1,
            "missing or invalid manifest")
    identity = manifest.get("identity", {})
    for key in IDENTITY_KEYS:
        require(nonempty(expected.get(key)), "independent expected identity missing: " + key)
        require(identity.get(key) == expected[key], "execution mismatch: " + key)
    for key in ("checkout_sha", "source_tree", "event_sha", "head_sha", "workflow_sha"):
        require(sha(identity[key], 40), "invalid source identity: " + key)
    require(identity["checkout_sha"] == identity["event_sha"], "unexpected checkout")
    require(manifest.get("command") == COMMAND, "wrong executed command")
    sdk = manifest.get("sdk", {})
    require(sdk.get("frameworkVersion") == "3.35.0" and
            nonempty(sdk.get("dartSdkVersion")) and sha(sdk.get("frameworkRevision"), 40),
            "missing or wrong SDK receipt")
    sources = manifest.get("sources", {})
    require(set(sources) == set(SOURCE_PATHS), "partial physical source manifest")
    require(all(sha(item.get("sha256")) for item in sources.values()), "invalid source hash")
    require("sources" in expected and sources == expected["sources"],
            "independent physical source hashes missing or mismatched")
    require(set(manifest.get("receipts", {})) ==
            {name + ".json" for name in CASES}, "partial receipt manifest")


def validate_window(window, case_id):
    require(set(window) == {"name", "baseline_payload_sha256", "baseline_record_ids", "entries"},
            "non-whitelisted window data")
    entries = window.get("entries", [])
    require(entries and [entry.get("seq") for entry in entries] ==
            list(range(1, len(entries) + 1)), "partial or reordered window")
    require(entries[0] == {"seq": 1, "kind": "window_start", "store_drained": True},
            "missing fresh drained boundary")
    end = entries[-1]
    require(end.get("kind") == "window_end" and end.get("store_drained") is True and
            sha(end.get("persisted_payload_sha256")), "missing terminal drained boundary")
    baseline_hash = window.get("baseline_payload_sha256")
    baseline_ids = window.get("baseline_record_ids")
    require(sha(baseline_hash) and isinstance(baseline_ids, list) and
            len(set(baseline_ids)) == len(baseline_ids), "invalid baseline")
    require(all(entry.get("kind") in {"window_start", "window_end", "event",
                "write_start", "write_result", "coalescing_control"} for entry in entries),
            "unknown window entry")
    allowed = {
        "window_start": {"seq", "kind", "store_drained"},
        "window_end": {"seq", "kind", "store_drained", "persisted_payload_sha256"},
        "event": {"seq", "kind", "name", "fields"},
        "write_start": {"seq", "kind", "key", "held", "value_sha256", "payload_sha256",
                        "revision", "digest", "records", "new_record_ids"},
        "write_result": {"seq", "kind", "attempt_seq", "returned"},
        "coalescing_control": {"seq", "kind", "scheduled_requests", "previous_result_generation"},
    }
    require(all(set(entry) <= allowed[entry["kind"]] for entry in entries),
            "non-whitelisted receipt data")
    starts = {entry["seq"]: entry for entry in entries if entry["kind"] == "write_start"}
    returns = [entry for entry in entries if entry["kind"] == "write_result"]
    require(starts and len(returns) == len(starts) and
            {entry.get("attempt_seq") for entry in returns} == set(starts),
            "partial backend write result pairing")
    returned = {entry["attempt_seq"]: entry for entry in returns}
    records = {}
    for seq, entry in starts.items():
        require(returned[seq]["seq"] > seq and type(returned[seq].get("returned")) is bool,
                "invalid backend completion")
        require(entry.get("key") in {"head", "recovery", "backup", "mirror"} and
                sha(entry.get("value_sha256")) and sha(entry.get("payload_sha256")),
                "unknown or incomplete backend write")
        if entry["key"] != "mirror":
            require(type(entry.get("revision")) is int and entry["revision"] > 0 and
                    sha(entry.get("digest")), "invalid checkpoint envelope identity")
        record_list = entry.get("records", [])
        require(isinstance(record_list, list), "missing actual checkpoint records")
        ids = []
        for record in record_list:
            require(set(record) <= RECORD_FIELDS, "non-whitelisted record data")
            require(all(value is None or type(value) in (str, int, bool) for value in record.values()),
                    "non-scalar record data")
            require(nonempty(record.get("recordId")), "record identity missing")
            ids.append(record["recordId"])
            if record["recordId"] not in baseline_ids:
                previous = records.setdefault(record["recordId"], record)
                require(previous == record, "conflicting source-owned record")
        require(len(ids) == len(set(ids)) and entry.get("new_record_ids") ==
                [value for value in ids if value not in baseline_ids], "ambiguous snapshot membership")
        if not entry["new_record_ids"] and window["name"] == "diagnostic":
            require(entry["key"] == "head" and entry["payload_sha256"] == baseline_hash,
                    "unrelated snapshot in diagnostic operation")
    events = [entry for entry in entries if entry["kind"] == "event"]
    for entry in events:
        require(entry.get("name") in {"decision_made", "progress_persist_result"} and
                set(entry.get("fields", {})) <= EVENT_FIELDS,
                "non-whitelisted producer event")
        require(all(value is None or type(value) in (str, int, bool)
                    for value in entry["fields"].values()), "non-scalar event data")
    decisions = [entry for entry in events if entry["name"] == "decision_made"]
    results = [entry for entry in events if entry["name"] == "progress_persist_result"]
    require(results, "missing actual persistence event")
    generations = [entry["fields"].get("request_generation") for entry in results]
    require(all(type(value) is int and value > 0 for value in generations) and
            generations == sorted(set(generations)), "ambiguous result generations")
    for entry in results:
        fields = entry["fields"]
        require(fields.get("schemaVersion") == 1 and fields.get("operation") == "save" and
                fields.get("source_surface") == "act0_progress_store" and
                fields.get("outcome") in {"acknowledged", "indeterminate"}, "unknown IO result")
    # Exact cases have successful head writes. Each non-rollback head therefore
    # starts an invoked save; recovery/backup retries do not start another save.
    heads = [entry for entry in starts.values() if entry["key"] == "head" and
             not (window["name"] == "diagnostic" and
                  entry["payload_sha256"] == baseline_hash)]
    require(heads and len(heads) == len(results) and
            all(returned[entry["seq"]]["returned"] for entry in heads),
            "ambiguous invoked-save to result cardinality")
    if window["name"] == "coalescing":
        controls = [entry for entry in entries if entry["kind"] == "coalescing_control"]
        require(not decisions and not records and len(results) == 1 and len(controls) == 1,
                "coalescing window contains learner decision or ambiguous saves")
        control = controls[0]
        require(control.get("scheduled_requests") == 2 and
                generations[0] == control.get("previous_result_generation", -10) + 2 and
                results[0]["fields"]["outcome"] == "acknowledged",
                "unproved coalesced request")
        return {"classification": "IO_only_run_not_applicable", "invoked_saves": 1,
                "coalesced_unattempted_requests": 1, "last_generation": generations[-1]}
    require(window["name"] == "diagnostic" and not baseline_ids and len(decisions) == 1 and
            len(records) == 1, "missing or ambiguous one-decision lineage")
    decision = decisions[0]["fields"]
    attempt = decision.get("attempt_id")
    require(nonempty(attempt) and attempt in records, "decision to record join missing")
    record = records[attempt]
    for field in ("runId", "runKind", "sessionId", "authoredSourceFingerprint"):
        require(nonempty(record.get(field)), "record lineage missing: " + field)
    require(sha(record["authoredSourceFingerprint"]), "invalid authored fingerprint")
    require(attempt.startswith("v3|" + record["runId"] + "|"), "run to attempt mismatch")
    require(record.get("taskId") == decision.get("task_id") == "actions_check_drill" and
            record.get("sessionId") == decision.get("session_id") and
            record.get("choiceId") == decision.get("choiceId") and
            record.get("isCorrect") == decision.get("correct") and
            record.get("assistanceKind") == decision.get("assistance_kind"),
            "decision record attribution conflict")
    require(all(entry.get("new_record_ids") == [attempt] for entry in heads),
            "attempt not present in every invoked snapshot")
    matching = [entry for entry in results if
                entry["fields"].get("task_id") == record["taskId"] and
                entry["fields"].get("session_id") == record["sessionId"]]
    require(matching and decisions[0]["seq"] < heads[0]["seq"], "missing decision/save window join")
    outcomes = [entry["fields"]["outcome"] for entry in matching]
    if case_id == "wrong_acknowledged":
        require(decision.get("correct") is False and len(matching) == len(results) and
                all(value == "acknowledged" for value in outcomes) and
                all(item["returned"] for item in returns),
                "wrong case outcome mismatch")
        require(end["persisted_payload_sha256"] in {entry["payload_sha256"] for entry in heads},
                "acknowledged snapshot not observed after drain")
        classification = "learner_error_observed"
    else:
        require(decision.get("correct") is True and "indeterminate" in outcomes and
                all(entry["fields"]["outcome"] == "indeterminate" for entry in results) and
                any(entry.get("held") is True for entry in heads) and
                any(entry["key"] == "recovery" and not returned[seq]["returned"]
                    for seq, entry in starts.items()) and
                end["persisted_payload_sha256"] == baseline_hash,
                "indeterminate fault or old-survivor receipt missing")
        classification = "save_acknowledgement_indeterminate"
    return {"classification": classification, "attempt_id": attempt,
            "run_id": record["runId"], "session_id": record["sessionId"],
            "invoked_saves": len(heads), "backend_write_attempts": len(starts),
            "last_generation": generations[-1],
            "mapping": "complete isolated window and actual snapshot membership; no per-generation attempt claim"}


def validate_case(case, case_id):
    require(set(case) == {"format", "case_id", "test_data_only", "unexercised", "windows"},
            "non-whitelisted case data")
    require(case.get("format") == 1 and case.get("case_id") == case_id and
            case.get("test_data_only") is True and
            case.get("unexercised") == ["repair", "transfer", "elapsed_retention", "native_restart"],
            "wrong case scope")
    windows = case.get("windows", [])
    require([window.get("name") for window in windows] ==
            (["diagnostic", "coalescing"] if case_id == "wrong_acknowledged" else ["diagnostic"]),
            "missing or mixed case window")
    results = [validate_window(window, case_id) for window in windows]
    if len(results) == 2:
        control = next(entry for entry in windows[1]["entries"]
                       if entry["kind"] == "coalescing_control")
        require(control["previous_result_generation"] == results[0]["last_generation"] and
                windows[1]["baseline_payload_sha256"] ==
                windows[0]["entries"][-1]["persisted_payload_sha256"], "mixed coalescing baseline")
    return results


def negative_controls(manifest, expected, cases):
    controls = {}

    def rejected(name, callback):
        try:
            callback()
        except (Insufficient, KeyError, TypeError, ValueError):
            controls[name] = "insufficient"
        else:
            raise Insufficient("negative accepted: " + name)

    rejected("missing_manifest", lambda: validate_manifest(None, expected))
    for field, replacement in (("checkout_sha", "0" * 40), ("run_id", "other-run"),
                               ("head_sha", "1" * 40)):
        altered = copy.deepcopy(manifest)
        altered["identity"][field] = replacement
        rejected("wrong_" + field, lambda value=altered: validate_manifest(value, expected))
    source = copy.deepcopy(manifest)
    source["sources"].pop(TEST)
    rejected("partial_source_manifest", lambda: validate_manifest(source, expected))
    wrong_source = copy.deepcopy(manifest)
    wrong_source["sources"][TEST]["sha256"] = "0" * 64
    rejected("wrong_physical_source", lambda: validate_manifest(wrong_source, expected))
    for field in ("runId", "recordId", "sessionId", "authoredSourceFingerprint"):
        altered = copy.deepcopy(cases["correct_indeterminate"])
        for entry in altered["windows"][0]["entries"]:
            for record in entry.get("records", []):
                record.pop(field, None)
        rejected("missing_" + field, lambda value=altered: validate_case(value, "correct_indeterminate"))
    partial = copy.deepcopy(cases["correct_indeterminate"])
    partial["windows"][0]["entries"].pop(-1)
    rejected("partial_window", lambda: validate_case(partial, "correct_indeterminate"))
    mixed = copy.deepcopy(cases["correct_indeterminate"])
    for entry in mixed["windows"][0]["entries"]:
        if entry.get("name") == "decision_made":
            entry["fields"]["attempt_id"] = "unrelated_same_task_session_attempt"
    rejected("mixed_same_task_session_attempt", lambda: validate_case(mixed, "correct_indeterminate"))
    return controls


def verify(packet, expected, source_root=None):
    manifest = json.loads((packet / "manifest.json").read_text())
    validate_manifest(manifest, expected)
    if source_root is not None:
        require(run(source_root, "git", "rev-parse", "HEAD") == expected["checkout_sha"] and
                run(source_root, "git", "rev-parse", "HEAD^{tree}") == expected["source_tree"] and
                physical_sources(source_root) == manifest["sources"], "actual checkout/source mismatch")
    cases, result = {}, {}
    for name in sorted(CASES):
        path = packet / (name + ".json")
        raw = path.read_bytes()
        require(manifest["receipts"][path.name] == {"sha256": digest(raw), "size": len(raw)},
                "capture hash/size mismatch")
        cases[name] = json.loads(raw)
        result[name] = validate_case(cases[name], name)
    return {"verdict": "PASS_SCOPED_MACHINE_CAPTURE", "cases": result,
            "negative_controls": negative_controls(manifest, expected, cases),
            "authenticity": "requires independently supplied GitHub execution identity",
            "not_proved": ["native", "release", "REP01_rebase", "full_OBS04_acceptance"]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("prepare", "seal", "verify"))
    parser.add_argument("--packet", type=Path, required=True)
    parser.add_argument("--source-root", type=Path)
    parser.add_argument("--expected-execution", type=Path)
    args = parser.parse_args()
    try:
        if args.mode == "prepare":
            prepare(args.source_root or Path.cwd(), args.packet)
        elif args.mode == "seal":
            seal(args.source_root or Path.cwd(), args.packet)
        else:
            require(args.expected_execution is not None, "independent expected execution input required")
            result = verify(args.packet, json.loads(args.expected_execution.read_text()), args.source_root)
            write_json(args.packet / "verification.json", result)
            print(json.dumps(result, sort_keys=True))
        return 0
    except (Insufficient, KeyError, TypeError, ValueError, OSError, subprocess.SubprocessError) as error:
        result = {"verdict": "insufficient", "reason": str(error)}
        write_json(args.packet / "verification.json", result)
        print(json.dumps(result), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
