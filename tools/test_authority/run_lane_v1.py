#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
import time
import tempfile
import uuid
from pathlib import Path

from run_lane_diagnostics_v1 import append_job_summary, failure_log_lines, flutter_failure_case_index, tail

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_DIR = Path(
    os.environ.get(
        "TEST_AUTHORITY_MANIFEST_DIR",
        ROOT / "tools" / "test_authority" / "manifests",
    )
)
SUMMARY_DIR = ROOT / "build" / "test_authority"

LANES = {
    "tier-a": {
        "blocking": True,
        "label": "Tier A active/release",
        "manifest": None,
    },
    "tier-b": {
        "blocking": True,
        "label": "Tier B maintained-support",
        "manifest": MANIFEST_DIR / "tier_b_maintained_support.txt",
    },

}

TIER_A_COMMANDS = [
    {"name":"poker W4 closed-flop actor and historical compatibility","cmd":["flutter","test","test/ui_v2/act0_w4_closed_flop_actor_v1_test.dart","-r","expanded"]},
    {"name":"poker face-up physical disclosure","cmd":["flutter","test","test/ui_v2/act0_faceup_physical_disclosure_v1_test.dart","-r","expanded"]},
    {"name":"poker W6 full-house explanation","cmd":["flutter","test","test/ui_v2/act0_w6_full_house_explanation_v1_test.dart","-r","expanded"]},
    {"name":"Academy Placement Review widget-host remount default OFF","cmd":["flutter","test","test/ui_v2/act0_jrn06_placement_review_restart_v1_test.dart","-r","expanded"]},
    {"name":"Academy Placement Review widget-host remount preview ON","cmd":["flutter","test","--dart-define=SHARKY_ACADEMY_REVIEW_PREVIEW=true","test/ui_v2/act0_jrn06_placement_review_restart_v1_test.dart","-r","expanded"]},
    {
        "name": "flutter analyze",
        "cmd": ["flutter", "analyze"],
    },
    {
        "name": "feedback completeness guard",
        "cmd": ["dart", "run", "tools/w1_w6_feedback_completeness_guard.dart"],
    },
    {
        "name": "canonical truth map guard",
        "cmd": [
            "flutter",
            "test",
            "test/guards/canonical_truth_map_v1_contract_test.dart",
            "test/guards/act0_release_profile_guard_v1_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "runtime-bundle parity",
        "cmd": [
            "flutter",
            "test",
            "test/services/drill_runtime_adapter_v1_asset_bundle_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "terminology/copy guard",
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_en_alpha_residue_guard_test.dart",
            "test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart",
            "test/ui_v2/act0_shell_state_v1_feedback_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "Wave 5 telemetry",
        "cmd": ["flutter", "test", "test/ui_v2/act0_telemetry_sink_v1_test.dart", "-r", "compact"],
    },
    {
        "name": "Long-session focused save and replay cases",
        "min_timeout_seconds": 180,
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_w1_long_session_v1_test.dart",
            "--dart-define=ACT0_LONG_SESSION_FOCUSED_ONLY=true",
            "-r",
            "compact",
        ],
    },
    {
        "name": "W1-W3 long session across restarts",
        # The combined W1-W7 traversal and focused cases hit 480s in CI.
        "min_timeout_seconds": 420,
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_w1_w3_long_session_v1_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "W4-W7 long session across restarts",
        "min_timeout_seconds": 420,
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_w4_w7_long_session_v1_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "W1-W4 skill map and evidence states",
        "cmd": [
            "flutter", "test",
            "test/ui_v2/act0_w14_skill_projection_v1_test.dart",
            "test/ui_v2/act0_daily_practice_queue_v1_test.dart",
            "test/ui_v2/act0_daily_deal_generator_v1_test.dart",
            "test/ui_v2/act0_w14_skill_state_v1_test.dart",
            "-r", "compact",
        ],
    },
    {
        "name": "repair intent",
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_repair_intent_resolver_v1_test.dart",
            "test/ui_v2/act0_repair_goal_fingerprints_current_v1_test.dart",
            "test/ui_v2/act0_copy_error_classes_v1_test.dart",
            "test/ui_v2/act0_learning_order_v1_test.dart",
            "test/ui_v2/act0_catalog_truth_guards_v1_test.dart",
            "test/guards/act0_atlas_dod_v1_test.dart",
            "test/guards/act0_skin_literal_guard_v1_test.dart",
            "test/ui_v2/act0_starting_chart_v1_test.dart",
            "test/ui_v2/act0_glossary_v1_test.dart",
            "test/ui_v2/act0_bet_rules_w14_v1_test.dart",
            "test/ui_v2/act0_card_suit_colour_v1_test.dart",
            "test/ui_v2/act0_catalog_grades_unlock_v1_test.dart",
            "test/ui_v2/act0_w14_no_dead_ends_v1_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "durable learner truth and assessment interaction (LDR-01)",
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_ldr01_durable_truth_v1_test.dart",
            "test/ui_v2/act0_dat04_atomic_persistence_v1_test.dart",
            "test/ui_v2/act0_repair_obligation_integrity_v1_test.dart",
            "test/ui_v2/act0_qa_independent_rep05_replay_20261103_test.dart",
            "test/ui_v2/act0_obs04_persist_diagnostics_v1_test.dart",
            "test/ui_v2/act0_default_answer_exposure_14pro_v1_test.dart",
            "test/ui_v2/act0_asm04_seat_focus_counterexample_v1_test.dart",
            "test/ui_v2/act0_asm04_remaining_seat_inventory_v1_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "repair outcome + queue",
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_repair_outcome_projection_v1_test.dart",
            "test/ui_v2/act0_queue_resolution_contract_v1_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "source scope, showdown disclosure and replay chronology (Q0)",
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_street_replay_contract_v1_test.dart",
            "test/ui_v2/act0_source_scope_v1_test.dart",
            "test/ui_v2/act0_w7_applied_ranges_v1_test.dart",
            "test/ui_v2/act0_source_scope_runner_v1_test.dart",
            "test/ui_v2/act0_table_choreography_contract_v1_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "source task/choice identity and historical fingerprint (ASM-01/ASM-07)",
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_assessment_identity_census_v1_test.dart",
            "test/ui_v2/act0_asm07_historical_fingerprint_falsifier_v1_test.dart",
            "test/ui_v2/act0_asm07_transfer_retention_boundary_falsifier_test.dart",
            "test/ui_v2/act0_asm07_recent_epoch_semantics_test.dart",
            "-r",
            "compact",
        ],
    },
    {
        "name": "poker hand-ranking truth (#334)",
        "cmd": ["flutter", "test", "test/poker", "-r", "compact"],
    },
    {
        "name": "Academy Review adapter default OFF",
        "cmd": [
            "flutter", "test",
            "test/ui_v2/act0_academy_review_runtime_adapter_v1_test.dart",
            "-r", "expanded",
        ],
    },
    {
        "name": "Academy Review adapter ON",
        "cmd": [
            "flutter", "test",
            "--dart-define=SHARKY_ACADEMY_REVIEW_PREVIEW=true",
            "test/ui_v2/act0_academy_review_runtime_adapter_v1_test.dart",
            "test/ui_v2/academy_leaves/act0_academy_review_resume_focus_v1_test.dart",
            "test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart",
            "-r", "expanded",
        ],
    },
    {
        "name": "World 1 release gate",
        # This command runs the fast loop, including Flutter startup, and
        # can exceed the ordinary two-minute limit on a cold runner.
        "min_timeout_seconds": 240,
        "cmd": ["./tools/release_gate_world1.sh"],
    },
    {
        "name": "repair intent lifecycle (Academy Review default OFF)",
        "cmd": ["flutter","test","test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart","-r","expanded"],
    },
    {
        "name": "Academy Practice production-scale control (140%)",
        "cmd": ["flutter","test","test/ui_v2/academy_leaves/act0_academy_practice_production_scale_v1_test.dart","-r","expanded"],
    },
    {
        "name": "Academy Practice defensive component text scale (160%)",
        "cmd": ["flutter","test","test/ui_v2/academy_leaves/act0_academy_practice_text_scale_v1_test.dart","-r","expanded"],
    },
]


def _read_manifest(path: Path) -> list[str]:
    if not path.exists():
        raise SystemExit(f"missing manifest: {path.relative_to(ROOT)}")
    entries = []
    for raw in path.read_text().splitlines():
        line = raw.strip()
        if line and not line.startswith("#"):
            entries.append(line)
    return entries


def _run_command(name: str, cmd: list[str], timeout: int, env: dict[str, str] | None = None) -> dict[str, object]:
    started = time.monotonic()
    try:
        completed = subprocess.run(
            cmd,
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            env=env,
        )
        status = "pass" if completed.returncode == 0 else "fail"
        output_tail, output_truncated, output_chars = tail(completed.stdout or "")
        return {
            "name": name,
            "cmd": cmd,
            "status": status,
            "exit_code": completed.returncode,
            "duration_seconds": round(time.monotonic() - started, 3),
            "output_tail": output_tail,
            "output_truncated": output_truncated,
            "output_chars": output_chars,
            "flutter_failure_cases": flutter_failure_case_index(completed.stdout or "") if completed.returncode != 0 else [],
        }
    except subprocess.TimeoutExpired as error:
        output = error.stdout or ""
        if isinstance(output, bytes):
            output = output.decode(errors="replace")
        output_tail, output_truncated, output_chars = tail(output)
        return {
            "name": name,
            "cmd": cmd,
            "status": "timeout",
            "exit_code": None,
            "duration_seconds": round(time.monotonic() - started, 3),
            "output_tail": output_tail,
            "output_truncated": output_truncated,
            "output_chars": output_chars,
            "flutter_failure_cases": flutter_failure_case_index(output),
        }
    except OSError as error:
        output_tail, output_truncated, output_chars = tail(str(error))
        return {
            "name": name,
            "cmd": cmd,
            "status": "error",
            "exit_code": None,
            "duration_seconds": round(time.monotonic() - started, 3),
            "output_tail": output_tail,
            "output_truncated": output_truncated,
            "output_chars": output_chars,
        }
    except KeyboardInterrupt:
        return {
            "name": name,
            "cmd": cmd,
            "status": "cancelled",
            "exit_code": None,
            "duration_seconds": round(time.monotonic() - started, 3),
            "output_tail": "",
            "output_truncated": False,
            "output_chars": 0,
        }


FAST_LOOP_ARGV = ["./tools/fast_loop_world1_v1.sh", "--force-tests", "--all-selected-guards"]


def _run_world1_gate(name: str, cmd: list[str], timeout: int) -> dict[str, object]:
    # One private receipt for this invocation only. This records execution,
    # not independent DoD acceptance or a reusable test result.
    with tempfile.TemporaryDirectory(prefix="world1-nested-") as directory:
        path = Path(directory) / "receipt.json"
        token = uuid.uuid4().hex
        receipt = {"schema": 1, "token": token, "cmd": FAST_LOOP_ARGV,
                   "state": "NOT_EXECUTED", "exit_code": None}
        path.write_text(json.dumps(receipt))
        env = dict(os.environ, SHARKY_WORLD1_STEP_RECEIPT=str(path),
                   SHARKY_WORLD1_STEP_TOKEN=token)
        result = _run_command(name, cmd, timeout, env=env)
        try:
            receipt = json.loads(path.read_text())
            if (receipt.get("schema") != 1 or receipt.get("token") != token
                    or receipt.get("cmd") != FAST_LOOP_ARGV):
                raise ValueError("receipt identity mismatch")
            state, code = receipt.get("state"), receipt.get("exit_code")
            valid = ((state in ("NOT_EXECUTED", "STARTED") and code is None)
                     or (state in ("PASS", "SKIPPED") and type(code) is int and code == 0)
                     or (state == "FAIL" and type(code) is int and 1 <= code <= 255))
            if not valid:
                raise ValueError("invalid nested terminal state")
        except (OSError, ValueError, TypeError, AttributeError):
            state, code = "UNVERIFIED", None
        result["nested_steps"] = [{"name": "fast loop", "cmd": FAST_LOOP_ARGV,
                                   "execution_state": state, "exit_code": code}]
        # The shell's success cannot satisfy the logical requirement without
        # a matching terminal PASS. Preserve the actual shell outcome too.
        if result["status"] == "pass" and state != "PASS":
            result["process_status"] = result["status"]
            result["status"] = "error"
            result["evidence_error"] = "fast loop has no valid execution PASS"
        return result


# Rough CI seconds per Tier A command, used only to balance parallel shards.
# Unknown names count as 10s. A stale number only makes shards less even.
TIER_A_WEIGHTS = {
    "World 1 release gate": 55,
    "durable learner truth and assessment interaction (LDR-01)": 53,
    "flutter analyze": 49,
    "Academy Placement Review widget-host remount preview ON": 39,
    "Wave 5 telemetry": 38,
    "Academy Placement Review widget-host remount default OFF": 29,
    "repair intent": 35,
    "Long-session focused save and replay cases": 75,
    "W1-W3 long session across restarts": 290,
    "W4-W7 long session across restarts": 250,
    "poker W4 closed-flop actor and historical compatibility": 15,
    "source scope, showdown disclosure and replay chronology (Q0)": 13,
    "source task/choice identity and historical fingerprint (ASM-01/ASM-07)": 11,
}
# LDR-01 writes the OBS04 captures; the CI job sealing them runs shard 0.
TIER_A_SHARD0 = ("durable learner truth and assessment interaction (LDR-01)",)

# Rough weights from a serial run of the Tier B manifest, with per-file setup.
# Ordinary files count as 3; the full app-root route alone took about 120s.
TIER_B_WEIGHTS = {
    "test/ui_v2/act0_main01_app_root_cycle_v1_test.dart": 122,
    "test/ui_v2/act0_w01_theory_source_truth_v1_test.dart": 8,
    "test/ui_v2/act0_w24_context_recap_v1_test.dart": 8,
    "test/ui_v2/act0_positions_theory_persistence_truth_v1_test.dart": 7,
    "test/ui_v2/academy_leaves/act0_academy_onboarding_leaf_v1_test.dart": 6,
    "test/ui_v2/act0_s11_learn_run_provenance_v1_test.dart": 6,
}


def _shard_owners(
    names: list[str],
    count: int,
    weights: dict[str, int],
    default_weight: int,
    pinned_shard_zero: tuple[str, ...] = (),
) -> dict[str, int]:
    """Assign the longest remaining item to the lightest shard."""
    loads = [0] * count
    owner = {name: 0 for name in pinned_shard_zero}
    loads[0] = sum(weights.get(name, default_weight) for name in pinned_shard_zero)
    for name in sorted(names, key=lambda name: -weights.get(name, default_weight)):
        if name in owner:
            continue
        target = loads.index(min(loads))
        owner[name] = target
        loads[target] += weights.get(name, default_weight)
    return owner


def _tier_a_shard(commands: list[dict[str, object]], index: int, count: int) -> list[dict[str, object]]:
    owner = _shard_owners(
        [str(command["name"]) for command in commands],
        count,
        TIER_A_WEIGHTS,
        default_weight=10,
        pinned_shard_zero=TIER_A_SHARD0,
    )
    return [command for command in commands if owner[str(command["name"])] == index]


def _run_tier_a(timeout: int, smoke: bool) -> list[dict[str, object]]:
    commands = TIER_A_COMMANDS
    if smoke:
        commands = TIER_A_COMMANDS[:1]
    shard = os.environ.get("TEST_AUTHORITY_SHARD", "")
    if shard and not smoke:
        index, count = (int(x) for x in shard.split("/"))
        commands = _tier_a_shard(commands, index, count)
    results = []
    for command in commands:
        command_timeout = max(timeout, int(command.get("min_timeout_seconds", 0)))
        if command["cmd"] == ["./tools/release_gate_world1.sh"]:
            result = _run_world1_gate(command["name"], command["cmd"], command_timeout)
        else:
            result = _run_command(command["name"], command["cmd"], command_timeout)
        results.append(result)
        if result["status"] == "cancelled":
            break
    return results


def _run_manifest_lane(lane: str, timeout: int, smoke: bool) -> list[dict[str, object]]:
    manifest = LANES[lane]["manifest"]
    assert manifest is not None
    files = _read_manifest(manifest)
    if smoke:
        files = files[:2]

    shard = os.environ.get("TEST_AUTHORITY_SHARD", "")
    if shard:
        index, count = (int(x) for x in shard.split("/"))
        if lane == "tier-b" and not smoke:
            owner = _shard_owners(files, count, TIER_B_WEIGHTS, default_weight=3)
            files = [path for path in files if owner[path] == index]
        else:
            files = files[index::count]
    if lane == "tier-b" and not smoke and len(files) > 1:
        # One `flutter test` process for the whole blocking lane: each separate
        # process spends ~9s on startup, which dominated this lane. A green batch
        # is a green lane. Preserve a failed batch and its diagnostics immediately;
        # rerunning every file hid the first failure behind minutes of duplicate work.
        batch = _run_command(
            "tier-b batch",
            ["flutter", "test", *files, "-r", "compact"],
            timeout * len(files),
        )
        if batch["status"] != "pass":
            batch["file_count"] = len(files)
            return [batch]
        if batch["status"] == "pass":
            share = round(float(batch["duration_seconds"]) / len(files), 3)
            return [
                {
                    "name": path,
                    "cmd": ["flutter", "test", path, "-r", "compact"],
                    "status": "pass",
                    "exit_code": 0,
                    "duration_seconds": share,
                    "output_tail": "",
                    "output_truncated": False,
                    "output_chars": 0,
                    "flutter_failure_cases": [],
                    "batched": True,
                }
                for path in files
            ]
    results = []
    for path in files:
        results.append(
            _run_command(
                path,
                ["flutter", "test", path, "-r", "compact"],
                timeout,
            )
        )
        if results[-1]["status"] == "cancelled":
            break
    return results


def _counts(results: list[dict[str, object]]) -> dict[str, int]:
    counts = {"pass": 0, "fail": 0, "error": 0, "timeout": 0, "skip": 0}
    for result in results:
        status = str(result["status"])
        if status == "timeout":
            counts["timeout"] += 1
        elif status == "pass":
            counts["pass"] += 1
        else:
            counts["fail"] += 1
    return counts


def run_lane(lane: str, timeout: int, smoke: bool) -> dict[str, object]:
    started = time.monotonic()
    if lane == "tier-a":
        results = _run_tier_a(timeout, smoke)
    else:
        results = _run_manifest_lane(lane, timeout, smoke)
    counts = _counts(results)
    blocking = bool(LANES[lane]["blocking"])
    has_non_green = counts["fail"] or counts["error"] or counts["timeout"]
    blocking_verdict = "BLOCK" if blocking and has_non_green else "NON_BLOCKING_SIGNAL" if has_non_green else "PASS"
    return {
        "lane": lane,
        "label": LANES[lane]["label"],
        "blocking": blocking,
        "smoke": smoke,
        "files_attempted": sum(int(result.get("file_count", 1)) for result in results),
        **counts,
        "duration_seconds": round(time.monotonic() - started, 3),
        "blocking_verdict": blocking_verdict,
        "results": results,
    }


def _print_summary(summary: dict[str, object]) -> None:
    print(f"lane: {summary['lane']} ({summary['label']})")
    print(f"files attempted: {summary['files_attempted']}")
    print(
        "counts: "
        f"pass={summary['pass']} fail={summary['fail']} "
        f"error={summary['error']} timeout={summary['timeout']} "
        f"skip={summary['skip']}"
    )
    print(f"duration: {summary['duration_seconds']}s")
    print(f"final blocking verdict: {summary['blocking_verdict']}")
    for result in summary["results"]:
        print(f"- {result['status']}: {result['name']} ({result['duration_seconds']}s)")
        for line in failure_log_lines(result):
            print(line)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("lane", choices=sorted(LANES))
    parser.add_argument("--timeout-seconds", type=int, default=int(os.environ.get("TEST_AUTHORITY_TIMEOUT_SECONDS", "120")), help="Default command watchdog; named minimum budgets still apply")
    parser.add_argument("--smoke", action="store_true")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    summary = run_lane(args.lane, args.timeout_seconds, args.smoke)
    SUMMARY_DIR.mkdir(parents=True, exist_ok=True)
    summary_path = SUMMARY_DIR / f"{args.lane}_summary.json"
    summary_path.write_text(json.dumps(summary, indent=2) + "\n")
    if args.json:
        print(json.dumps(summary, indent=2))
    else:
        _print_summary(summary)
        print(f"summary: {summary_path.relative_to(ROOT)}")
    try:
        append_job_summary(summary)
    except Exception:
        # Optional diagnostics must never replace the lane's original verdict.
        # Do not echo exception text: it may contain paths or other free text.
        print("Job Summary unavailable; lane verdict unchanged.", file=sys.stderr)
    if any(result["status"] == "cancelled" for result in summary["results"]):
        return 130
    # Infrastructure errors are fatal even in nonblocking test lanes.
    if any(result["status"] == "error" for result in summary["results"]):
        return 1
    if summary["blocking_verdict"] == "BLOCK":
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
