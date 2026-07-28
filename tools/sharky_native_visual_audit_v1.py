#!/usr/bin/env python3
"""One-build, row-level native iOS Simulator visual-audit transport."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import time
from collections import Counter, defaultdict

ROOT = pathlib.Path(__file__).resolve().parents[1]
BUNDLE_ID = "com.example.pokerAnalyzer"
MANIFEST = ROOT / "tools" / "sharky_native_visual_audit_manifest_v1.json"
EXPECTED = {("canonical", "none"): 20, ("compact", "none"): 14,
            ("canonical", "text_scale_1_4"): 10,
            ("canonical", "reduced_motion"): 6, ("large", "none"): 4}


def run(*args: str, capture: bool = False, env: dict[str, str] | None = None) -> str:
    result = subprocess.run(args, cwd=ROOT, env=env, text=True,
                            stdout=subprocess.PIPE if capture else None,
                            stderr=subprocess.STDOUT if capture else None, check=True)
    return result.stdout or ""


def best_effort(*args: str) -> None:
    subprocess.run(args, cwd=ROOT, text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate(rows: list[dict[str, str]]) -> None:
    counts = Counter((row["device_profile"], row["modifier"]) for row in rows)
    tuples = [(row["state"], row["device_profile"], row["modifier"]) for row in rows]
    errors = []
    if len(rows) != 54: errors.append(f"total rows must be 54, found {len(rows)}")
    if counts != EXPECTED: errors.append(f"distribution must be {EXPECTED}, found {dict(counts)}")
    if len(set(tuples)) != len(tuples): errors.append("state/device_profile/modifier tuples must be unique")
    if any(row["device_profile"] == "large" and row["modifier"] == "reduced_motion" for row in rows):
        errors.append("large + reduced_motion is not admitted")
    if not any(row["state"] == "lesson.completion" for row in rows):
        errors.append("lesson.completion row is required")
    if not any(row["state"] == "completion.world" for row in rows):
        errors.append("completion.world row is required")
    if errors: raise RuntimeError("native visual audit preflight failed: " + "; ".join(errors))


def selected_simulator(profile: str) -> tuple[str, str, str]:
    # Hosted macOS images rotate their installed Simulator catalog.  Select by
    # profile, with bounded fallbacks in the same size class, rather than
    # requiring one retired device name (for example, iPhone SE).
    names = {
        "compact": ("iPhone SE", "iPhone 16e", "iPhone 15", "iPhone 14", "iPhone 13", "iPhone 12", "iPhone 11"),
        "canonical": ("iPhone 17 Pro", "iPhone 16 Pro", "iPhone 15 Pro", "iPhone 14 Pro", "iPhone 17", "iPhone 16", "iPhone 15", "iPhone 14"),
        "large": ("iPhone 17 Pro Max", "iPhone 16 Pro Max", "iPhone 15 Pro Max", "iPhone 14 Pro Max", "iPhone 17 Plus", "iPhone 16 Plus", "iPhone 15 Plus", "iPhone 14 Plus"),
    }[profile]
    devices = json.loads(run("xcrun", "simctl", "list", "devices", "available", "-j", capture=True))
    for runtime, values in devices["devices"].items():
        for device in values:
            if device.get("isAvailable") and any(device["name"].startswith(name) for name in names):
                return device["udid"], device["name"], runtime
    available = sorted({device["name"] for values in devices["devices"].values()
                        for device in values if device.get("isAvailable")})
    raise RuntimeError(f"No available Simulator for {profile}; available: {', '.join(available)}")


def wait_for_ready(udid: str, state_id: str, timeout: float) -> None:
    marker = f"SHARKY_VISUAL_CAPTURE_READY:{state_id}"
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        output = run("xcrun", "simctl", "spawn", udid, "log", "show", "--last", "1m",
                     "--style", "compact", "--predicate", f'eventMessage CONTAINS "{marker}"', capture=True)
        if marker in output: return
        time.sleep(0.25)
    raise RuntimeError(f"Timed out waiting for {marker}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--preflight", action="store_true")
    parser.add_argument("--out", type=pathlib.Path, default=ROOT / "output" / "native_visual_audit")
    parser.add_argument("--ready-timeout", type=float, default=30.0)
    args = parser.parse_args()
    source = json.loads(MANIFEST.read_text())
    rows = source["rows"]
    validate(rows)
    if args.preflight:
        print(json.dumps({"rows": len(rows), "distribution": {f"{k[0]}/{k[1]}": v for k, v in EXPECTED.items()}}))
        return 0

    output = args.out.resolve(); raw = output / "raw"; raw.mkdir(parents=True, exist_ok=True)
    with (output / "build.log").open("w") as log:
        build = subprocess.run(["flutter", "build", "ios", "--simulator", "--debug", "--dart-define=SHARKY_VISUAL_AUDIT=true"], cwd=ROOT, text=True, stdout=log, stderr=subprocess.STDOUT)
    if build.returncode: raise RuntimeError(f"Native audit build failed; see {output / 'build.log'}")
    app = ROOT / "build" / "ios" / "iphonesimulator" / "Runner.app"
    if not app.is_dir(): raise RuntimeError(f"Expected app bundle is missing: {app}")

    simulators = {}
    for profile in {row["device_profile"] for row in rows}:
        udid, name, runtime = selected_simulator(profile)
        best_effort("xcrun", "simctl", "boot", udid); run("xcrun", "simctl", "bootstatus", udid, "-b")
        best_effort("xcrun", "simctl", "uninstall", udid, BUNDLE_ID); run("xcrun", "simctl", "install", udid, str(app))
        simulators[profile] = {"udid": udid, "name": name, "runtime": runtime}

    candidate = run("git", "rev-parse", "HEAD", capture=True).strip()
    captured = []
    with (output / "state_transitions.jsonl").open("w") as transitions:
        for row in rows:
            simulator = simulators[row["device_profile"]]; state_id = row["visual_state_id"]
            best_effort("xcrun", "simctl", "terminate", simulator["udid"], BUNDLE_ID)
            environment = os.environ | {"SIMCTL_CHILD_SHARKY_VISUAL_AUDIT_PAYLOAD": row["query"], "SIMCTL_CHILD_SHARKY_VISUAL_AUDIT_STATE_ID": state_id}
            run("xcrun", "simctl", "launch", simulator["udid"], BUNDLE_ID, env=environment)
            wait_for_ready(simulator["udid"], state_id, args.ready_timeout)
            png = raw / f"{state_id}.png"; run("xcrun", "simctl", "io", simulator["udid"], "screenshot", str(png))
            if not png.is_file() or png.stat().st_size == 0: raise RuntimeError(f"Missing screenshot: {png}")
            record = row | {"candidate_sha": candidate, "capture_source": "NATIVE_IOS_SIMULATOR", "injected_state_classification": "NATIVE_PRODUCTION_RENDERER_INJECTED_STATE", "png": str(png.relative_to(output)), "png_sha256": sha256(png), "device_model": simulator["name"], "ios_runtime": simulator["runtime"]}
            transitions.write(json.dumps({"event": "captured", **record}) + "\n"); captured.append(record)
    (output / "native_capture_manifest.json").write_text(json.dumps({"schema": "sharky_native_visual_audit_v1", "candidate_sha": candidate, "rows": captured}, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    try: raise SystemExit(main())
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"native visual audit: {error}", file=sys.stderr); raise SystemExit(1)
