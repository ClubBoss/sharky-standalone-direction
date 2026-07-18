#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_DIR = ROOT / "tools" / "test_authority" / "manifests"
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
        "name": "fast loop",
        "cmd": ["./tools/fast_loop_world1_v1.sh", "--force-tests", "--all-selected-guards"],
    },
    {
        "name": "World 1 release gate",
        "cmd": ["./tools/release_gate_world1.sh"],
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
        return {
            "name": name,
            "cmd": cmd,
            "status": status,
            "exit_code": completed.returncode,
            "duration_seconds": round(time.monotonic() - started, 3),
            "output_tail": completed.stdout[-4000:],
        }
    except subprocess.TimeoutExpired as error:
        output = error.stdout or ""
        if isinstance(output, bytes):
            output = output.decode(errors="replace")
        return {
            "name": name,
            "cmd": cmd,
            "status": "timeout",
            "exit_code": None,
            "duration_seconds": round(time.monotonic() - started, 3),
            "output_tail": output[-4000:],
        }


def _run_tier_a(timeout: int, smoke: bool) -> list[dict[str, object]]:
    commands = TIER_A_COMMANDS
    if smoke:
        commands = TIER_A_COMMANDS[:1]
    return [
        _run_command(command["name"], command["cmd"], timeout)
        for command in commands
    ]


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
    if args.lane == "tier-c":
        return 0
    if summary["blocking_verdict"] == "BLOCK":
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
