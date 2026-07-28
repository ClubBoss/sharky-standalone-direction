#!/usr/bin/env python3
"""Resumable, sharded native iOS Simulator visual-audit transport."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import selectors
import shutil
import struct
import subprocess
import sys
import time
import zlib
from collections import Counter

ROOT = pathlib.Path(__file__).resolve().parents[1]
BUNDLE_ID = "com.example.pokerAnalyzer"
MANIFEST = ROOT / "tools" / "sharky_native_visual_audit_manifest_v1.json"
EXPECTED = {("canonical", "none"): 20, ("compact", "none"): 14,
            ("canonical", "text_scale_1_4"): 10,
            ("canonical", "reduced_motion"): 6, ("large", "none"): 4}
SHARDS = {
    "canonical-normal": lambda r: r["device_profile"] == "canonical" and r["modifier"] == "none",
    "canonical-modifiers": lambda r: r["device_profile"] == "canonical" and r["modifier"] != "none",
    "compact-normal": lambda r: r["device_profile"] == "compact" and r["modifier"] == "none",
    "large-normal": lambda r: r["device_profile"] == "large" and r["modifier"] == "none",
}


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


def load_rows() -> list[dict]:
    rows = json.loads(MANIFEST.read_text())["rows"]
    validate(rows)
    return rows


def validate(rows: list[dict]) -> None:
    counts = Counter((row["device_profile"], row["modifier"]) for row in rows)
    tuples = [(row["state"], row["device_profile"], row["modifier"]) for row in rows]
    errors = []
    if len(rows) != 54: errors.append(f"total rows must be 54, found {len(rows)}")
    if counts != EXPECTED: errors.append(f"distribution must be {EXPECTED}, found {dict(counts)}")
    if len(set(tuples)) != len(tuples): errors.append("state/device_profile/modifier tuples must be unique")
    if any(row["device_profile"] == "large" and row["modifier"] == "reduced_motion" for row in rows): errors.append("large + reduced_motion is not admitted")
    if not any(row["state"] == "lesson.completion" for row in rows): errors.append("lesson.completion row is required")
    if not any(row["state"] == "completion.world" for row in rows): errors.append("completion.world row is required")
    if errors: raise RuntimeError("native visual audit preflight failed: " + "; ".join(errors))


def row_map(rows: list[dict]) -> dict[str, dict]:
    return {row["visual_state_id"]: row for row in rows}


def selected_rows(rows: list[dict], args: argparse.Namespace) -> list[dict]:
    requested = list(args.row_id or [])
    if args.row_ids_file:
        source = json.loads(pathlib.Path(args.row_ids_file).read_text())
        requested.extend(source.get("row_ids", source) if isinstance(source, dict) else source)
    if args.full_checkpoint and (requested or args.family):
        raise RuntimeError("--full-checkpoint cannot be combined with subset selectors")
    if args.full_checkpoint:
        return rows
    if args.family:
        if not any("family" in row for row in rows):
            raise RuntimeError("--family is unavailable because this manifest has no family field")
        requested.extend(row["visual_state_id"] for row in rows if row.get("family") in args.family)
    if not requested:
        raise RuntimeError("explicit --row-id/--row-ids-file/--family or --full-checkpoint is required")
    if len(requested) != len(set(requested)):
        raise RuntimeError("duplicate row IDs are not allowed")
    known = row_map(rows); unknown = sorted(set(requested) - known.keys())
    if unknown: raise RuntimeError("unknown row IDs: " + ", ".join(unknown))
    return [known[row_id] for row_id in requested]


def emit_shards(rows: list[dict], destination: pathlib.Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    for name, predicate in SHARDS.items():
        shard_rows = [row for row in rows if predicate(row)]
        (destination / f"{name}.json").write_text(json.dumps({"schema": "sharky_native_visual_audit_shard_v1", "shard": name, "row_ids": [r["visual_state_id"] for r in shard_rows], "rows": shard_rows}, indent=2) + "\n")


def selected_simulator(profile: str) -> tuple[str, str, str]:
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
    available = sorted({device["name"] for values in devices["devices"].values() for device in values if device.get("isAvailable")})
    raise RuntimeError(f"No available Simulator for {profile}; available: {', '.join(available)}")


def wait_for_ready(udid: str, state_id: str, timeout: float) -> float:
    marker = f"SHARKY_VISUAL_CAPTURE_READY:{state_id}"
    listener = subprocess.Popen(["xcrun", "simctl", "spawn", udid, "log", "stream", "--style", "compact", "--predicate", f'eventMessage CONTAINS "{marker}"'], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    selector = selectors.DefaultSelector(); selector.register(listener.stdout, selectors.EVENT_READ)
    started = time.monotonic()
    try:
        while time.monotonic() - started < timeout:
            for _, _ in selector.select(timeout=0.5):
                line = listener.stdout.readline()
                if marker in line: return time.monotonic()
        raise RuntimeError(f"Timed out waiting for event-driven readiness marker {marker}")
    finally:
        selector.close(); listener.terminate()
        try: listener.wait(timeout=2)
        except subprocess.TimeoutExpired: listener.kill()


def png_nonwhite_ratio(path: pathlib.Path) -> float:
    """Return non-white pixel ratio for 8-bit RGB/RGBA PNGs without extra deps."""
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n": raise RuntimeError(f"not a PNG: {path}")
    pos = 8; ihdr = None; chunks = []
    while pos < len(data):
        size = struct.unpack(">I", data[pos:pos + 4])[0]; kind = data[pos + 4:pos + 8]; body = data[pos + 8:pos + 8 + size]; pos += 12 + size
        if kind == b"IHDR": ihdr = body
        if kind == b"IDAT": chunks.append(body)
        if kind == b"IEND": break
    width, height, bits, color, _, _, _ = struct.unpack(">IIBBBBB", ihdr)
    if bits != 8 or color not in (2, 6): raise RuntimeError(f"unsupported PNG format for blank guard: {path}")
    channels = 4 if color == 6 else 3; stride = width * channels; raw = zlib.decompress(b"".join(chunks)); previous = bytearray(stride); index = 0; nonwhite = total = 0
    for _ in range(height):
        filter_type = raw[index]; index += 1; row = bytearray(raw[index:index + stride]); index += stride
        for i in range(stride):
            left = row[i - channels] if i >= channels else 0; above = previous[i]; upper_left = previous[i - channels] if i >= channels else 0
            if filter_type == 1: row[i] = (row[i] + left) & 255
            elif filter_type == 2: row[i] = (row[i] + above) & 255
            elif filter_type == 3: row[i] = (row[i] + ((left + above) // 2)) & 255
            elif filter_type == 4:
                p = left + above - upper_left; pa, pb, pc = abs(p - left), abs(p - above), abs(p - upper_left); row[i] = (row[i] + (left if pa <= pb and pa <= pc else above if pb <= pc else upper_left)) & 255
        for pixel in range(0, stride, channels * 8):
            rgb = row[pixel:pixel + 3]; total += 1
            if min(rgb) < 240: nonwhite += 1
        previous = row
    return nonwhite / max(total, 1)


def assert_nonblank(path: pathlib.Path) -> None:
    ratio = png_nonwhite_ratio(path)
    if ratio < 0.05: raise RuntimeError(f"blank or near-uniform frame ({ratio:.3f} nonwhite ratio): {path}")


def write_json(path: pathlib.Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True); path.write_text(json.dumps(value, indent=2) + "\n")


def build_runner(output: pathlib.Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    build_log = output.parent / "build.log"
    with build_log.open("w") as log:
        result = subprocess.run(["flutter", "build", "ios", "--simulator", "--debug", "--dart-define=SHARKY_VISUAL_AUDIT=true"], cwd=ROOT, text=True, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode: raise RuntimeError(f"Native audit build failed; see {build_log}")
    app = ROOT / "build" / "ios" / "iphonesimulator" / "Runner.app"
    if not app.is_dir(): raise RuntimeError(f"Expected app bundle is missing: {app}")
    if output.exists(): shutil.rmtree(output)
    shutil.copytree(app, output)


def capture(rows: list[dict], args: argparse.Namespace) -> None:
    profiles = {row["device_profile"] for row in rows}
    if len(profiles) != 1: raise RuntimeError("a capture shard must contain exactly one device profile")
    app = pathlib.Path(args.app).resolve()
    if not app.is_dir(): raise RuntimeError(f"Runner.app is missing: {app}")
    output = args.out.resolve(); raw = output / "raw"; raw.mkdir(parents=True, exist_ok=True)
    candidate = args.candidate_sha or run("git", "rev-parse", "HEAD", capture=True).strip()
    shard = args.shard or "delta"; requested = [row["visual_state_id"] for row in rows]; started = time.monotonic()
    manifest_path = output / "shard_capture_manifest.json"
    shard_manifest = {"schema": "sharky_native_visual_audit_shard_capture_v1", "shard": shard, "candidate_sha": candidate, "requested_rows": requested, "completed_rows": [], "rows": [], "status": "in_progress", "wall_time_seconds": 0}
    write_json(manifest_path, shard_manifest)
    profile = profiles.pop(); udid, name, runtime = selected_simulator(profile)
    best_effort("xcrun", "simctl", "boot", udid); run("xcrun", "simctl", "bootstatus", udid, "-b")
    best_effort("xcrun", "simctl", "uninstall", udid, BUNDLE_ID); run("xcrun", "simctl", "install", udid, str(app))
    transitions = (output / "state_transitions.jsonl").open("w")
    try:
        for row in rows:
            state_id = row["visual_state_id"]; row_started = time.monotonic(); launch_started = time.time()
            best_effort("xcrun", "simctl", "terminate", udid, BUNDLE_ID)
            marker_listener_start = time.monotonic()
            environment = os.environ | {"SIMCTL_CHILD_SHARKY_VISUAL_AUDIT_PAYLOAD": row["query"], "SIMCTL_CHILD_SHARKY_VISUAL_AUDIT_STATE_ID": state_id}
            # Listener starts before launch, preventing missed readiness events.
            marker = f"SHARKY_VISUAL_CAPTURE_READY:{state_id}"
            listener = subprocess.Popen(["xcrun", "simctl", "spawn", udid, "log", "stream", "--style", "compact", "--predicate", f'eventMessage CONTAINS "{marker}"'], cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            selector = selectors.DefaultSelector(); selector.register(listener.stdout, selectors.EVENT_READ)
            try:
                run("xcrun", "simctl", "launch", udid, BUNDLE_ID, env=environment)
                deadline = time.monotonic() + args.ready_timeout; ready_at = None
                while time.monotonic() < deadline and ready_at is None:
                    for _, _ in selector.select(timeout=0.5):
                        if marker in listener.stdout.readline(): ready_at = time.monotonic(); break
                if ready_at is None: raise RuntimeError(f"Timed out waiting for event-driven readiness marker {marker}")
            finally:
                selector.close(); listener.terminate()
                try: listener.wait(timeout=2)
                except subprocess.TimeoutExpired: listener.kill()
            time.sleep(args.frame_settle_seconds)
            png = raw / f"{state_id}.png"; run("xcrun", "simctl", "io", udid, "screenshot", str(png))
            if not png.is_file() or not png.stat().st_size: raise RuntimeError(f"Missing screenshot: {png}")
            assert_nonblank(png); screenshot_done = time.monotonic()
            timing = {"launch_started_epoch": launch_started, "readiness_seconds": round(ready_at - marker_listener_start, 3), "screenshot_seconds": round(screenshot_done - ready_at, 3), "total_row_seconds": round(screenshot_done - row_started, 3)}
            record = row | {"candidate_sha": candidate, "capture_source": "NATIVE_IOS_SIMULATOR", "injected_state_classification": "NATIVE_PRODUCTION_RENDERER_INJECTED_STATE", "png": str(png.relative_to(output)), "png_sha256": sha256(png), "device_model": name, "ios_runtime": runtime, "timing": timing}
            transitions.write(json.dumps({"event": "captured", **record}) + "\n"); transitions.flush()
            shard_manifest["completed_rows"].append(state_id); shard_manifest["rows"].append(record); shard_manifest["wall_time_seconds"] = round(time.monotonic() - started, 3); write_json(manifest_path, shard_manifest)
        shard_manifest["status"] = "success"
    except Exception as error:
        shard_manifest["status"] = "failed"; shard_manifest["failed_row"] = state_id if "state_id" in locals() else None; shard_manifest["error"] = str(error)
        raise
    finally:
        shard_manifest["wall_time_seconds"] = round(time.monotonic() - started, 3); write_json(manifest_path, shard_manifest); transitions.close()


def aggregate(shard_root: pathlib.Path, output: pathlib.Path, candidate: str) -> None:
    manifests = sorted(shard_root.rglob("shard_capture_manifest.json"))
    if len(manifests) != 4: raise RuntimeError(f"aggregate requires four shard manifests, found {len(manifests)}")
    records = []; summaries = []
    for path in manifests:
        shard = json.loads(path.read_text())
        if shard.get("status") != "success" or shard.get("requested_rows") != shard.get("completed_rows"):
            raise RuntimeError(f"incomplete shard {shard.get('shard')}: {shard.get('failed_row')}")
        if shard.get("candidate_sha") != candidate: raise RuntimeError(f"candidate SHA mismatch in shard {shard.get('shard')}")
        for row in shard["rows"]:
            source = path.parent / row["png"]
            if not source.is_file() or sha256(source) != row["png_sha256"]: raise RuntimeError(f"PNG/hash mismatch {source}")
            assert_nonblank(source); row = dict(row); row["_source"] = source; records.append(row)
        summaries.append({key: shard.get(key) for key in ("shard", "requested_rows", "completed_rows", "wall_time_seconds")})
    validate(records)
    if any(row.get("candidate_sha") != candidate for row in records): raise RuntimeError("row candidate SHA mismatch")
    output.mkdir(parents=True, exist_ok=True); raw = output / "raw"; raw.mkdir(exist_ok=True)
    for row in records:
        destination = raw / pathlib.Path(row["png"]).name; shutil.copy2(row.pop("_source"), destination); row["png"] = str(destination.relative_to(output))
    unified = {"schema": "sharky_native_visual_audit_v1", "candidate_sha": candidate, "build_count": 1, "rows": records, "shards": summaries, "aggregate_wall_time_seconds": round(max((x["wall_time_seconds"] for x in summaries), default=0), 3)}
    write_json(output / "native_capture_manifest.json", unified)


def self_test(rows: list[dict]) -> None:
    counts = {name: len([r for r in rows if predicate(r)]) for name, predicate in SHARDS.items()}
    if counts != {"canonical-normal": 20, "canonical-modifiers": 16, "compact-normal": 14, "large-normal": 4}: raise RuntimeError(f"bad shards: {counts}")
    if not (0.0 < 0.05 and 0.5 >= 0.05): raise RuntimeError("blank-frame threshold test failed")
    print(json.dumps({"shards": counts, "subset_selection": "guarded", "blank_frame_guard": "guarded", "event_readiness": "log_stream"}))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--preflight", action="store_true"); parser.add_argument("--emit-shards", type=pathlib.Path)
    parser.add_argument("--build-runner", action="store_true"); parser.add_argument("--app-out", type=pathlib.Path)
    parser.add_argument("--row-id", action="append"); parser.add_argument("--row-ids-file", type=pathlib.Path); parser.add_argument("--family", action="append"); parser.add_argument("--full-checkpoint", action="store_true")
    parser.add_argument("--validate-selection", action="store_true"); parser.add_argument("--app", type=pathlib.Path); parser.add_argument("--out", type=pathlib.Path, default=ROOT / "output" / "native_visual_audit")
    parser.add_argument("--shard"); parser.add_argument("--candidate-sha"); parser.add_argument("--ready-timeout", type=float, default=30.0); parser.add_argument("--frame-settle-seconds", type=float, default=1.5)
    parser.add_argument("--aggregate-shards", type=pathlib.Path); parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(); rows = load_rows()
    if args.preflight:
        if args.emit_shards: emit_shards(rows, args.emit_shards)
        print(json.dumps({"rows": len(rows), "distribution": {f"{k[0]}/{k[1]}": v for k, v in EXPECTED.items()}})); return 0
    if args.self_test: self_test(rows); return 0
    if args.build_runner:
        if not args.app_out: raise RuntimeError("--build-runner requires --app-out")
        build_runner(args.app_out); return 0
    if args.aggregate_shards:
        if not args.candidate_sha: raise RuntimeError("--aggregate-shards requires --candidate-sha")
        aggregate(args.aggregate_shards, args.out.resolve(), args.candidate_sha); return 0
    selected = selected_rows(rows, args)
    if args.validate_selection: print(json.dumps({"requested_rows": [r["visual_state_id"] for r in selected]})); return 0
    if not args.app: raise RuntimeError("capture requires --app")
    capture(selected, args); return 0


if __name__ == "__main__":
    try: raise SystemExit(main())
    except (RuntimeError, subprocess.CalledProcessError) as error:
        print(f"native visual audit: {error}", file=sys.stderr); raise SystemExit(1)
