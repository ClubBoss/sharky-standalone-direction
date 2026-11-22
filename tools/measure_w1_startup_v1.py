#!/usr/bin/env python3
"""Capture a cold iOS Flutter startup and an interactive W1 first decision."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time


ROOT = Path(__file__).resolve().parents[1]
REFERENCE_SIM = "Sharky-EN-V1-iPhone-14-Pro-Reference"
DECISION = re.compile(r"SHARKY_F1_FIRST_DECISION_US=(\d+)")


def select_device(requested):
    available = json.loads(
        subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"])
    )
    simulators = [
        device for runtime in available["devices"].values() for device in runtime
    ]
    if requested:
        matches = [device for device in simulators if device["udid"] == requested.upper()]
        if not matches:
            return requested, None
    else:
        matches = [device for device in simulators if device["name"] == REFERENCE_SIM]
        if len(matches) != 1:
            raise ValueError(f"Select a simulator UDID explicitly; expected one {REFERENCE_SIM}.")
    return matches[0]["udid"], matches[0]


def wait_for_decision(device, log_file, first_frame_us, seconds):
    command = ["flutter", "logs", "-d", device]
    with log_file.open("wb") as output, log_file.open() as reader:
        logs = subprocess.Popen(command, cwd=ROOT, stdout=output, stderr=subprocess.STDOUT)
        try:
            print("On the device, tap Start with the basics, then Next. Leave the first question open.")
            deadline = time.monotonic() + seconds
            while time.monotonic() < deadline:
                for line in reader:
                    marker = DECISION.search(line)
                    if marker and (timestamp := int(marker.group(1))) >= first_frame_us:
                        return timestamp
                if logs.poll() is not None:
                    raise RuntimeError(f"Device log stream ended. See {log_file}.")
                time.sleep(0.2)
            raise RuntimeError(f"No new W1 decision marker within {seconds}s. See {log_file}.")
        finally:
            if logs.poll() is None:
                logs.terminate()
                try:
                    logs.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    logs.kill()
                    logs.wait()


def measure(requested, seconds):
    device, simulator = select_device(requested)
    mode = "debug" if simulator else "profile"
    if simulator and simulator["state"] != "Booted":
        subprocess.run(["xcrun", "simctl", "bootstatus", device, "-b"], check=True)

    parent = ROOT / "output" / "w1-startup"
    parent.mkdir(parents=True, exist_ok=True)
    output = Path(tempfile.mkdtemp(dir=parent))
    print(f"{mode} startup trace and report: {output}", flush=True)
    subprocess.run(
        [
            "flutter", "run", "-d", device, f"--{mode}", "--no-hot",
            "--trace-startup", "--dart-define=SHARKY_F1_STARTUP_TRACE=true",
        ],
        cwd=ROOT,
        env={**os.environ, "FLUTTER_TEST_OUTPUTS_DIR": str(output)},
        check=True,
    )
    info = json.loads((output / "start_up_info.json").read_text())
    engine_us = info["engineEnterTimestampMicros"]
    frame_us = info["timeToFirstFrameRasterizedMicros"]
    decision_us = wait_for_decision(device, output / "device.log", engine_us + frame_us, seconds)
    report = {
        "source_commit": subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
        ).strip(),
        "device": simulator["name"] if simulator else device,
        "mode": mode,
        "engine_to_first_rasterized_frame_ms": frame_us / 1000,
        "engine_to_first_graded_decision_ms": (decision_us - engine_us) / 1000,
        "first_frame_to_decision_ms": (decision_us - engine_us - frame_us) / 1000,
    }
    rendered = json.dumps(report, indent=2)
    (output / "report.json").write_text(rendered + "\n")
    print(rendered)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("device", nargs="?", help="iPhone device ID or simulator UDID")
    parser.add_argument("--decision-timeout", type=int, default=180, metavar="SECONDS")
    args = parser.parse_args()
    if args.decision_timeout <= 0:
        parser.error("--decision-timeout must be positive")
    try:
        measure(args.device, args.decision_timeout)
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Startup measurement failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
