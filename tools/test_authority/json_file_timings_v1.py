#!/usr/bin/env python3
"""Summarize observed per-file windows from Dart test JSON events.

This is an opt-in diagnostic. It does not change a Test Authority verdict and
its file windows may overlap when the test runner uses concurrency.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Iterable


SCHEMA = "SHARKY_DART_TEST_FILE_TIMINGS_V1"
SUPPORTED_PROTOCOLS = {"0.1.1"}
# JsonReporter normalizes Result.skipped to success and emits the flag separately.
TEST_RESULTS = {"success", "failure", "error"}


class TimingInputError(ValueError):
    """The event stream cannot support an honest timing report."""


def _integer(value: object, field: str, *, minimum: int = 0) -> int:
    if type(value) is not int or value < minimum:
        raise TimingInputError(f"{field} must be an integer >= {minimum}")
    return value


def _mapping(value: object, field: str) -> dict:
    if not isinstance(value, dict):
        raise TimingInputError(f"{field} must be an object")
    return value


def parse_events(lines: Iterable[str]) -> dict[str, object]:
    """Parse one Dart test JSON-lines run into conservative file timings."""
    suites: dict[int, dict[str, object]] = {}
    tests: dict[int, dict[str, object]] = {}
    protocol: str | None = None
    runner_version: str | None = None
    expected_suites: int | None = None
    done_success: bool | None = None
    done_seen = False
    done_ms: int | None = None
    prior_ms = -1
    event_count = 0

    for line_number, raw in enumerate(lines, start=1):
        if not raw.strip():
            continue
        try:
            event = json.loads(raw)
        except json.JSONDecodeError as error:
            raise TimingInputError(
                f"line {line_number}: not a JSON event ({error.msg})"
            ) from error
        if not isinstance(event, dict):
            raise TimingInputError(f"line {line_number}: event must be an object")
        event_type = event.get("type")
        if not isinstance(event_type, str):
            raise TimingInputError(f"line {line_number}: event type is missing")
        event_ms = _integer(event.get("time"), f"line {line_number} time")
        if event_ms < prior_ms:
            raise TimingInputError(
                f"line {line_number}: event time moved backwards; input may contain multiple runs"
            )
        prior_ms = event_ms
        event_count += 1

        if done_seen:
            raise TimingInputError("event found after done; input may be concatenated or corrupt")

        if event_type == "start":
            if protocol is not None:
                raise TimingInputError("multiple start events; provide exactly one test run")
            protocol_value = event.get("protocolVersion")
            if not isinstance(protocol_value, str) or protocol_value not in SUPPORTED_PROTOCOLS:
                raise TimingInputError(
                    f"unsupported Dart test JSON protocol {protocol_value!r}; "
                    f"supported: {', '.join(sorted(SUPPORTED_PROTOCOLS))}"
                )
            protocol = protocol_value
            value = event.get("runnerVersion")
            runner_version = value if isinstance(value, str) else None
        elif event_type == "allSuites":
            if expected_suites is not None:
                raise TimingInputError("multiple allSuites events")
            expected_suites = _integer(event.get("count"), "allSuites count")
        elif event_type == "suite":
            suite = _mapping(event.get("suite"), "suite")
            suite_id = _integer(suite.get("id"), "suite id")
            if suite_id in suites:
                raise TimingInputError(f"duplicate suite id {suite_id}")
            path = suite.get("path")
            platform = suite.get("platform")
            suites[suite_id] = {
                "suite_id": suite_id,
                "path": path if isinstance(path, str) and path else None,
                "platform": platform if isinstance(platform, str) else None,
                "start_ms": event_ms,
                "tests": [],
            }
        elif event_type == "testStart":
            test = _mapping(event.get("test"), "testStart test")
            test_id = _integer(test.get("id"), "test id")
            suite_id = _integer(test.get("suiteID"), "test suite id")
            if test_id in tests:
                raise TimingInputError(f"duplicate test id {test_id}")
            if suite_id not in suites:
                raise TimingInputError(f"test {test_id} refers to unknown suite {suite_id}")
            tests[test_id] = {
                "suite_id": suite_id,
                "start_ms": event_ms,
                "done_ms": None,
                "result": None,
                "skipped": None,
                "hidden": None,
            }
            suites[suite_id]["tests"].append(test_id)
        elif event_type == "testDone":
            test_id = _integer(event.get("testID"), "testDone test id")
            if test_id not in tests:
                raise TimingInputError(f"testDone refers to unknown test {test_id}")
            if tests[test_id]["done_ms"] is not None:
                raise TimingInputError(f"duplicate testDone for test {test_id}")
            result = event.get("result")
            if not isinstance(result, str) or result not in TEST_RESULTS:
                raise TimingInputError(
                    f"testDone result {result!r} is invalid for test {test_id}; "
                    f"expected one of {', '.join(sorted(TEST_RESULTS))}"
                )
            skipped = event.get("skipped")
            if type(skipped) is not bool:
                raise TimingInputError(f"testDone skipped flag missing for test {test_id}")
            hidden = event.get("hidden")
            if type(hidden) is not bool:
                raise TimingInputError(f"testDone hidden flag missing for test {test_id}")
            tests[test_id].update(
                done_ms=event_ms, result=result, skipped=skipped, hidden=hidden
            )
        elif event_type == "done":
            if done_seen:
                raise TimingInputError("multiple done events; provide exactly one test run")
            success = event.get("success")
            if success is not None and type(success) is not bool:
                raise TimingInputError("done success must be true, false, or null")
            done_seen = True
            done_success = success
            done_ms = event_ms

    if protocol is None:
        raise TimingInputError("start event missing")
    if not suites:
        raise TimingInputError("no suite events; no per-file timing is available")

    terminal_run = done_seen and done_success is not None
    file_rows: list[dict[str, object]] = []
    intervals: dict[int, tuple[int, int]] = {}
    for suite_id, suite in suites.items():
        test_ids = suite["tests"]
        terminal_tests = [
            tests[test_id]
            for test_id in test_ids
            if tests[test_id]["done_ms"] is not None
        ]
        visible_tests = [test for test in terminal_tests if not test["hidden"]]
        missing_test_done = len(test_ids) - len(terminal_tests)
        end_ms = max((test["done_ms"] for test in terminal_tests), default=None)
        complete = terminal_run and bool(test_ids) and missing_test_done == 0

        if not complete:
            status = "incomplete"
        elif any(test["result"] != "success" for test in terminal_tests):
            status = "fail"
        elif not visible_tests:
            status = "no_visible_tests"
        elif visible_tests and all(test["skipped"] for test in visible_tests):
            status = "skipped"
        else:
            status = "pass"

        duration_seconds = None
        observed_lower_bound_seconds = None
        if end_ms is not None:
            elapsed = max(0, end_ms - suite["start_ms"]) / 1000
            if complete:
                duration_seconds = elapsed
                intervals[suite_id] = (suite["start_ms"], end_ms)
            else:
                observed_lower_bound_seconds = elapsed

        file_rows.append(
            {
                "suite_id": suite_id,
                "path": suite["path"],
                "platform": suite["platform"],
                "status": status,
                "observed_window_seconds": duration_seconds,
                "observed_lower_bound_seconds": observed_lower_bound_seconds,
                "started_test_count": len(test_ids),
                "visible_test_count": len(visible_tests),
                "hidden_test_count": sum(test["hidden"] is True for test in terminal_tests),
                "skipped_count": sum(test["skipped"] is True for test in visible_tests),
                "missing_test_done_count": missing_test_done,
                "overlaps_with_suite_ids": [],
            }
        )

    for suite_id, (start_ms, end_ms) in intervals.items():
        overlaps = sorted(
            other_id
            for other_id, (other_start, other_end) in intervals.items()
            if other_id != suite_id and start_ms < other_end and other_start < end_ms
        )
        next(row for row in file_rows if row["suite_id"] == suite_id)[
            "overlaps_with_suite_ids"
        ] = overlaps

    file_rows.sort(
        key=lambda row: (
            row["observed_window_seconds"] is None,
            -(row["observed_window_seconds"] or 0),
            str(row["path"]),
        )
    )
    observed_suite_count = len(file_rows)
    if expected_suites is not None and expected_suites < observed_suite_count:
        raise TimingInputError(
            "announced suite count is smaller than the observed suite count"
        )
    missing_suite_count = (
        max(0, expected_suites - observed_suite_count)
        if expected_suites is not None
        else None
    )
    warnings = [
        "Observed file windows are not CPU time and may include load/scheduling time.",
        "Concurrent file windows overlap; do not sum them to estimate batch wall time.",
    ]
    if not terminal_run:
        warnings.append(
            "The run has no terminal boolean done event; incomplete windows are lower bounds only."
        )
    if missing_suite_count:
        warnings.append(
            f"{missing_suite_count} announced suite(s) had no observable suite event or path."
        )

    return {
        "schema": SCHEMA,
        "protocol_version": protocol,
        "runner_version": runner_version,
        "event_count": event_count,
        "run": {
            "terminal": terminal_run,
            "success": done_success if terminal_run else None,
            "observed_wall_seconds": (
                done_ms / 1000 if terminal_run and done_ms is not None else None
            ),
            "announced_suite_count": expected_suites,
            "observed_suite_count": observed_suite_count,
            "missing_suite_count": missing_suite_count,
            "has_overlapping_file_windows": any(
                row["overlaps_with_suite_ids"] for row in file_rows
            ),
        },
        "files": file_rows,
        "warnings": warnings,
    }


def _seconds(value: object) -> str:
    return "unknown" if value is None else f"{value:.3f}"


def render_text(report: dict[str, object]) -> str:
    """Render a compact diagnostic table without implying additive timings."""
    run = report["run"]
    lines = [
        "Dart test observed per-file windows",
        (
            f"run_wall={_seconds(run['observed_wall_seconds'])}s "
            f"terminal={str(run['terminal']).lower()} success={run['success']} "
            f"overlap={str(run['has_overlapping_file_windows']).lower()}"
        ),
        "",
        "seconds  status            tests  overlaps  path",
    ]
    for row in report["files"]:
        overlap_count = len(row["overlaps_with_suite_ids"])
        value = row["observed_window_seconds"]
        if value is None and row["observed_lower_bound_seconds"] is not None:
            duration = ">=" + _seconds(row["observed_lower_bound_seconds"])
        else:
            duration = _seconds(value)
        lines.append(
            f"{duration:>7}  {row['status']:<16}  {row['visible_test_count']:>5}  "
            f"{overlap_count:>8}  {row['path'] or '[path unavailable]'}"
        )
    lines.extend(["", *(f"NOTE: {warning}" for warning in report["warnings"])])
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Report honest per-file windows from `flutter test -r json` output."
    )
    parser.add_argument(
        "events",
        nargs="?",
        type=Path,
        help="JSON-lines event file (stdin when omitted)",
    )
    parser.add_argument("--json", action="store_true", help="emit the report as JSON")
    args = parser.parse_args(argv)

    try:
        if args.events is None:
            report = parse_events(sys.stdin)
        else:
            with args.events.open(encoding="utf-8") as stream:
                report = parse_events(stream)
    except (OSError, TimingInputError) as error:
        print(f"timing report unavailable: {error}", file=sys.stderr)
        return 2

    if args.json:
        print(json.dumps(report, indent=2, sort_keys=True))
    else:
        print(render_text(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
