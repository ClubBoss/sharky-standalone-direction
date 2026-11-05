#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

from run_lane_diagnostics_v1 import append_job_summary, failure_log_lines, tail

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
    "tier-c": {
        "blocking": False,
        "label": "Tier C quarantine",
        "manifest": MANIFEST_DIR / "tier_c_quarantine.txt",
    },
    "tier-d": {
        "blocking": False,
        "label": "Tier D retired/excluded",
        "manifest": MANIFEST_DIR / "tier_d_retired.txt",
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
        "name": "repair intent",
        "cmd": [
            "flutter",
            "test",
            "test/ui_v2/act0_repair_intent_resolver_v1_test.dart",
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
            "-r", "expanded",
        ],
    },
    {
        "name": "fast loop",
        "cmd": ["./tools/fast_loop_world1_v1.sh", "--force-tests", "--all-selected-guards"],
    },
    {
        "name": "World 1 release gate",
        "cmd": ["./tools/release_gate_world1.sh"],
    },
    {
        "name": "Academy Review mapped repair roundtrip",
        "cmd": ["flutter","test","--dart-define=SHARKY_ACADEMY_REVIEW_PREVIEW=true","test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart","--plain-name","Academy Review mapped repair","-r","expanded"],
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


def _run_command(name: str, cmd: list[str], timeout: int) -> dict[str, object]:
    started = time.monotonic()
    try:
        completed = subprocess.run(
            cmd,
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
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


def _run_tier_a(timeout: int, smoke: bool) -> list[dict[str, object]]:
    commands = TIER_A_COMMANDS
    if smoke:
        commands = TIER_A_COMMANDS[:1]
    results = []
    for command in commands:
        result = _run_command(command["name"], command["cmd"], timeout)
        results.append(result)
        if result["status"] == "cancelled":
            break
    return results


def _run_manifest_lane(lane: str, timeout: int, smoke: bool) -> list[dict[str, object]]:
    manifest = LANES[lane]["manifest"]
    assert manifest is not None
    files = _read_manifest(manifest)
    if smoke:
        # Include first files plus known timeout residual when present so smoke
        # proves continuation past the historically unfinished file.
        selected = files[:2]
        if lane == "tier-c" and "test/services/booster_pack_launcher_test.dart" in files:
            selected.append("test/services/booster_pack_launcher_test.dart")
            selected.extend(files[-1:])
        files = list(dict.fromkeys(selected))
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
        "files_attempted": len(results),
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
    parser.add_argument("--timeout-seconds", type=int, default=int(os.environ.get("TEST_AUTHORITY_TIMEOUT_SECONDS", "120")))
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
    if args.lane == "tier-c":
        return 0
    if summary["blocking_verdict"] == "BLOCK":
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
