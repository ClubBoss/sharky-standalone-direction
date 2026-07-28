#!/usr/bin/env python3
"""Native iOS Simulator transport for the Sharky visual audit.

This builds one audit-enabled Runner app per invocation, changes only launch
environment between states, waits for the app's native readiness marker, and
captures with `simctl io screenshot`. Raw evidence stays outside git.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import time


ROOT = pathlib.Path(__file__).resolve().parents[1]
BUNDLE_ID = "com.example.pokerAnalyzer"
MANIFEST = ROOT / "tools" / "sharky_native_visual_audit_manifest_v1.json"


def run(*args: str, capture: bool = False, env: dict[str, str] | None = None) -> str:
    completed = subprocess.run(
        args,
        cwd=ROOT,
        env=env,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.STDOUT if capture else None,
        check=True,
    )
    return completed.stdout or ""


def best_effort(*args: str) -> None:
    subprocess.run(args, cwd=ROOT, text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def selected_simulator(device_profile: str) -> tuple[str, str, str]:
    preferred_names = {
        "compact": ("iPhone SE",),
        "canonical": ("iPhone 17 Pro", "iPhone 16 Pro"),
        "large": ("iPhone 17 Pro Max", "iPhone 16 Pro Max"),
    }[device_profile]
    devices = json.loads(run("xcrun", "simctl", "list", "devices", "available", "-j", capture=True))
    for runtime, values in devices["devices"].items():
        for device in values:
            if device.get("isAvailable") and any(device["name"].startswith(name) for name in preferred_names):
                return device["udid"], device["name"], runtime
    raise RuntimeError(f"No available {device_profile} iPhone Simulator runtime was found")


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def wait_for_ready(udid: str, state_id: str, timeout: float) -> None:
    marker = f"SHARKY_VISUAL_CAPTURE_READY:{state_id}"
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        output = run(
            "xcrun", "simctl", "spawn", udid, "log", "show", "--last", "1m",
            "--style", "compact", "--predicate", f'eventMessage CONTAINS "{marker}"',
            capture=True,
        )
        if marker in output:
            return
        time.sleep(0.25)
    raise RuntimeError(f"Timed out waiting for {marker}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scope", choices=("six-state", "full"), default="six-state")
    parser.add_argument("--device-profile", choices=("compact", "canonical", "large"), default="canonical")
    parser.add_argument("--modifier", choices=("none", "text_scale_1_4", "reduced_motion"), default="none")
    parser.add_argument("--out", type=pathlib.Path, default=ROOT / "output" / "native_visual_audit")
    parser.add_argument("--ready-timeout", type=float, default=30.0)
    args = parser.parse_args()

    source = json.loads(MANIFEST.read_text())
    states = [item for item in source["states"] if args.scope == "full" or item["fidelity_gate"]]
    output = args.out.resolve()
    raw = output / "raw"
    raw.mkdir(parents=True, exist_ok=True)
    build_log = output / "build.log"
    state_log = output / "state_transitions.jsonl"

    with build_log.open("w") as log:
        build = subprocess.run(
            ["flutter", "build", "ios", "--simulator", "--debug", "--dart-define=SHARKY_VISUAL_AUDIT=true"],
            cwd=ROOT, text=True, stdout=log, stderr=subprocess.STDOUT,
        )
    if build.returncode:
        raise RuntimeError(f"Native audit build failed; see {build_log}")

    app = ROOT / "build" / "ios" / "iphonesimulator" / "Runner.app"
    if not app.is_dir():
        raise RuntimeError(f"Expected app bundle is missing: {app}")
    udid, device_name, runtime = selected_simulator(args.device_profile)
    best_effort("xcrun", "simctl", "boot", udid)
    run("xcrun", "simctl", "bootstatus", udid, "-b")
    best_effort("xcrun", "simctl", "uninstall", udid, BUNDLE_ID)
    run("xcrun", "simctl", "install", udid, str(app))

    rows = []
    with state_log.open("w") as transitions:
        for state in states:
            query = state["query"]
            if args.modifier == "text_scale_1_4" and "text_scale=" not in query:
                query += "&text_scale=1.4"
            if args.modifier == "reduced_motion":
                query += "&reduced_motion=true"
            state_id = f"{state['visual_state_id']}.{args.device_profile}"
            if args.modifier != "none":
                state_id = f"{state_id}.{args.modifier}"
            best_effort("xcrun", "simctl", "terminate", udid, BUNDLE_ID)
            environment = os.environ | {
                "SIMCTL_CHILD_SHARKY_VISUAL_AUDIT_PAYLOAD": query,
                "SIMCTL_CHILD_SHARKY_VISUAL_AUDIT_STATE_ID": state_id,
            }
            run("xcrun", "simctl", "launch", udid, BUNDLE_ID, env=environment)
            wait_for_ready(udid, state_id, args.ready_timeout)
            png = raw / f"{state_id}.png"
            run("xcrun", "simctl", "io", udid, "screenshot", str(png))
            if not png.is_file() or png.stat().st_size == 0:
                raise RuntimeError(f"Screenshot was not created: {png}")
            row = state | {
                "visual_state_id": state_id,
                "native_route_state_seed": query,
                "modifier": args.modifier,
                "device_profile": args.device_profile,
                "capture_source": "NATIVE_IOS_SIMULATOR",
                "injected_state_classification": "NATIVE_PRODUCTION_RENDERER_INJECTED_STATE",
                "png": str(png.relative_to(output)),
                "png_sha256": sha256(png),
                "device_model": device_name,
                "ios_runtime": runtime,
            }
            transitions.write(json.dumps({"event": "captured", **row}) + "\n")
            rows.append(row)

    candidate = run("git", "rev-parse", "HEAD", capture=True).strip()
    (output / "native_capture_manifest.json").write_text(json.dumps({
        "schema": "sharky_native_visual_audit_v1",
        "candidate_sha": candidate,
        "scope": args.scope,
        "device_profile": args.device_profile,
        "modifier": args.modifier,
        "device": {"name": device_name, "udid": udid, "runtime": runtime},
        "rows": rows,
    }, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"native visual audit: {error}", file=sys.stderr)
        raise SystemExit(1)
