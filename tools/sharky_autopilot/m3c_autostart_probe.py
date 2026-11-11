"""M3C: one manually armed unattended read-only subscription Codex marker.

The macOS service launches ONCE on registration: no cron, daemon, code
writing, provider fallback, generic agent task, or product authority.
"""
from __future__ import annotations

import json
import os
import pwd
from pathlib import Path
import plistlib
import subprocess
import sys

from durable_queue import (
    M3C_ADMISSION, M3C_R2_ADMISSION, M3C_TASK, M3C_R2_TASK,
    QueueStop, connect, snapshot,
)
from codex_readonly_pilot import run_once as run_codex_once

REPO = "https://github.com/ClubBoss/sharky-standalone-direction.git"
BRANCH = "infra/autopilot-m3c-readonly-20261102"
BASE = "9dd166568b12758bd6c797a38dae5b8758f61c54"
LABEL = "com.sharky.autopilot.m3c.codex-readonly-once"
HOME_SUBDIR = "Sharky_Autopilot_Pilot/m3c_state"
DATABASE = "codex-readonly-once.sqlite3"
PLIST = LABEL + ".plist"
STOP_FILENAME = "stop_receipt.json"
R2_LABEL = "com.sharky.autopilot.m3c.r2-readonly-once"
R2_PLIST = R2_LABEL + ".plist"
R2_STOP_FILENAME = "r2_stop_receipt.json"


def _root():
    root = Path(__file__).resolve().parents[2]
    args = ["git", "-C", str(root)]
    try:
        def read(*values):
            return subprocess.run(
                args + list(values), check=True, capture_output=True,
                text=True, timeout=5,
            ).stdout.strip()
        branch = read("branch", "--show-current")
        base = read("merge-base", "HEAD", "origin/main")
        origin = read("remote", "get-url", "origin")
        dirty = read("status", "--porcelain", "--untracked-files=all")
    except (OSError, subprocess.SubprocessError) as exc:
        raise QueueStop("M3C source provenance inaccessible") from exc
    if (branch != BRANCH or base != BASE or origin != REPO or dirty):
        raise QueueStop("M3C requires exact clean trusted infra branch/base")
    return root


def _state_path(*, create=False):
    home = Path.home()
    root = home / "Sharky_Autopilot_Pilot"
    state = root / "m3c_state"
    if not root.is_dir() or root.is_symlink():
        raise QueueStop("M3C parent missing or symlinked")
    if state.is_symlink():
        raise QueueStop("M3C state cannot be a symlink")
    if not state.exists():
        if not create:
            raise QueueStop("M3C not armed")
        state.mkdir(mode=0o700)
    if not state.is_dir() or state.stat().st_mode & 0o077:
        raise QueueStop("M3C local state permissions not private")
    return state


def prepare_plist():
    """Prepare one fixed launchd job; does NOT register or launch it."""
    root = _root()
    state = _state_path(create=True)
    plist = state / PLIST
    db = state / DATABASE
    if db.is_symlink() or plist.is_symlink():
        raise QueueStop("M3C state files may not be symlinked")
    if db.exists() or plist.exists():
        raise QueueStop("M3C previously armed or run; no re-arm")
    target = root / "tools/sharky_autopilot/m3c_autostart_probe.py"
    if not target.is_file() or target.is_symlink():
        raise QueueStop("M3C fixed source missing")
    # launchd GUI services may lack the interactive shell environment.
    # Supply only fixed login-derived variables, not arbitrary caller data.
    account = pwd.getpwuid(os.getuid()).pw_name
    home = str(Path.home())
    job = {
        "EnvironmentVariables": {
            "HOME": home,
            "USER": account,
            "LOGNAME": account,
            "PATH": home + "/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            "LANG": "en_US.UTF-8",
        },
        "Label": LABEL,
        "ProgramArguments": [sys.executable, "-E", "-s", str(target), "--run"],
        "RunAtLoad": True,
        "KeepAlive": False,
        "WorkingDirectory": str(root),
        "StandardOutPath": str(state / "launchd.stdout.log"),
        "StandardErrorPath": str(state / "launchd.stderr.log"),
        "ProcessType": "Background",
        "ThrottleInterval": 60,
    }
    with plist.open("xb") as fh:
        plistlib.dump(job, fh)
    os.chmod(plist, 0o600)
    return {"action": "ARMED_NOT_STARTED", "plist": str(plist),
            "label": LABEL, "model_dispatch": "M3C_ONESHOT_ONLY"}


def run_once():
    """Run only the fixed M3C read-only model under SQLite one-shot lease."""
    _root()
    state = _state_path()
    db_path = state / DATABASE
    if db_path.is_symlink():
        raise QueueStop("M3C database symlink rejected")
    # This is safe to replay: the M2C lease guarantees one active child.
    result = run_codex_once(
        db_path, owner_admission=M3C_ADMISSION,
        initialize=not db_path.exists(), profile="M3C",
    )
    if result["action"] not in ("PASS_SCOPED", "STOP_FAILED", "NOOP", "BUSY"):
        raise QueueStop("M3C unexpected offline state")
    if result["action"] in ("PASS_SCOPED", "STOP_FAILED"):
        receipt = {"action": result["action"], "model_calls": 1,
                   "product_dod": "NOT_INFERRED",
                   "stop_verified": result["stop_verified"],
                   "lease_closed": result["lease_closed"],
                   "sha256": result["receipt_sha256"],
                   "exit_code": result["exit_code"],
                   "failure_class": result["failure_class"],
                   "timed_out": result["timed_out"],
                   "elapsed_seconds": result["elapsed_seconds"],
                   "autonomous_model_dispatch": "OFF"}
        path = state / STOP_FILENAME
        with path.open("x", encoding="ascii") as fh:
            json.dump(receipt, fh, sort_keys=True)
        os.chmod(path, 0o600)
    return {"action": result["action"],
            "model_calls": result.get("model_calls", 0),
            "autonomous_model_dispatch": "OFF"}


def prepare_r2_plist():
    """Arm only the separately admitted R2 in the SAME persistent M3C queue."""
    root = _root()
    state = _state_path()
    db_path = state / DATABASE
    if not db_path.is_file() or db_path.is_symlink():
        raise QueueStop("M3C original queue must be retained, not recreated")
    db = connect(db_path)
    try:
        prior = db.execute(
            "SELECT status,attempts,max_attempts FROM tasks WHERE id=?",
            (M3C_TASK,)).fetchone()
        if (prior is None or prior["status"] != "STOPPED"
                or prior["attempts"] != 1 or prior["max_attempts"] != 1):
            raise QueueStop("M3C original attempt not consumed")
        if db.execute("SELECT 1 FROM leases WHERE status='ACTIVE'").fetchone():
            raise QueueStop("active worker forbids R2")
        if db.execute("SELECT 1 FROM tasks WHERE id=?", (M3C_R2_TASK,)).fetchone():
            raise QueueStop("R2 already admitted, no re-arming")
    finally:
        db.close()
    old = state / STOP_FILENAME
    if not old.is_file() or old.is_symlink():
        raise QueueStop("original stop evidence missing")
    if json.loads(old.read_text(encoding="ascii")).get("action") != "STOP_FAILED":
        raise QueueStop("R2 only follows known M3C STOP_FAILED")
    template = state / PLIST
    if not template.is_file() or template.is_symlink():
        raise QueueStop("reviewed original launcher missing")
    job = plistlib.loads(template.read_bytes())
    target = root / "tools/sharky_autopilot/m3c_autostart_probe.py"
    if not target.is_file() or target.is_symlink():
        raise QueueStop("fixed M3C executable missing")
    job["Label"] = R2_LABEL
    job["ProgramArguments"] = [sys.executable, "-E", "-s",
                               str(target), "--run-r2"]
    job["StandardOutPath"] = str(state / "r2.stdout.log")
    job["StandardErrorPath"] = str(state / "r2.stderr.log")
    if job.get("KeepAlive") is not False or job.get("RunAtLoad") is not True:
        raise QueueStop("R2 launchd one-shot contract changed")
    path = state / R2_PLIST
    if path.is_symlink() or path.exists() or (state / R2_STOP_FILENAME).exists():
        raise QueueStop("R2 already armed or completed")
    with path.open("xb") as fh:
        plistlib.dump(job, fh)
    os.chmod(path, 0o600)
    return {"action": "R2_ARMED_NOT_STARTED", "label": R2_LABEL,
            "plist": str(path), "model_calls": 0}


def run_r2_once():
    """One diagnostic model under old DB's new explicit one-attempt identity."""
    _root()
    state = _state_path()
    plist = state / R2_PLIST
    db_path = state / DATABASE
    if (not plist.is_file() or plist.is_symlink()
            or not db_path.is_file() or db_path.is_symlink()):
        raise QueueStop("M3C R2 not armed with immutable original queue")
    result = run_codex_once(
        db_path, owner_admission=M3C_R2_ADMISSION,
        initialize=False, profile="M3C_R2",
    )
    if result["action"] not in ("PASS_SCOPED", "STOP_FAILED", "NOOP", "BUSY"):
        raise QueueStop("M3C R2 unexpected outcome")
    if result["action"] in ("PASS_SCOPED", "STOP_FAILED"):
        receipt = {
            "action": result["action"],
            "model_calls": 1,
            "exit_code": result["exit_code"],
            "timed_out": result["timed_out"],
            "elapsed_seconds": result["elapsed_seconds"],
            "failure_class": result["failure_class"],
            "progress": result["progress"],
            "stderr_class": result["stderr_class"],
            "stop_verified": result["stop_verified"],
            "lease_closed": result["lease_closed"],
            "sha256": result["receipt_sha256"],
            "autonomous_model_dispatch": "OFF",
            "product_dod": "NOT_INFERRED",
        }
        out = state / R2_STOP_FILENAME
        with out.open("x", encoding="ascii") as fh:
            json.dump(receipt, fh, sort_keys=True)
        os.chmod(out, 0o600)
    return {"action": result["action"],
            "model_calls": result.get("model_calls", 0),
            "autonomous_model_dispatch": "OFF"}


def status():
    state = _state_path()
    db_path = state / DATABASE
    if not db_path.is_file():
        return {"action": "ARMED_NO_EXECUTION"}
    db = connect(db_path)
    try:
        data = snapshot(db)
        return {"action": "READBACK", "tasks": [
            {"id": t["id"], "status": t["status"],
             "attempts": t["attempts"]} for t in data["tasks"]],
            "leases": [x["status"] for x in data["leases"]],
            "events": [e["action"] for e in data["events"]]}
    finally:
        db.close()


def main():
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    opts = parser.add_mutually_exclusive_group(required=True)
    opts.add_argument("--prepare", action="store_true")
    opts.add_argument("--run", action="store_true")
    opts.add_argument("--status", action="store_true")
    opts.add_argument("--prepare-r2", action="store_true")
    opts.add_argument("--run-r2", action="store_true")
    args = parser.parse_args()
    if args.prepare:
        result = prepare_plist()
    elif args.run:
        result = run_once()
    elif args.prepare_r2:
        result = prepare_r2_plist()
    elif args.run_r2:
        result = run_r2_once()
    else:
        result = status()
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
