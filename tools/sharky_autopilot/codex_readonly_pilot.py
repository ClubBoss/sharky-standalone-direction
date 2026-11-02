"""M3A: ONE manually admitted subscription Codex read-only marker via M2C lease.

No autonomous scheduling, repository read by model, code writing, or retries.
Do not use this probe as a general-purpose Codex worker.
"""
from __future__ import annotations

import hashlib
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time

from durable_queue import (
    CODEX_ADMISSION, CODEX_BASE_SHA, CODEX_BRANCH, CODEX_PROVIDER,
    CODEX_TASK, M3C_ADMISSION, M3C_TASK, M3C_BRANCH, M3C_BASE_SHA,
    QueueStop, acknowledge_stopped, admit_codex_readonly_once,
    admit_m3c_readonly_once, connect, lease_once,
)
from process_pilot import _session_gone

MODEL = "gpt-5.6-luna"
EFFORT = "low"
WORKER = "m3a-codex-readonly-once"
MARKER = "SHARKY_M3A_READONLY_QUEUE_OK"
PROMPT = (
    "MODEL: gpt-5.6-luna. REASONING: LOW. MODE: READ-ONLY TEST. "
    "Task: reply with exactly SHARKY_M3A_READONLY_QUEUE_OK and nothing else. "
    "Do not use tools, access files, call shell, write code, or browse. "
    "This is a single authorization-bound subscription capability check. "
    "No product, repository, QA or DoD conclusions."
)
MAX_SECONDS = 70


def _safe_env():
    """Do not forward arbitrary API keys, GitHub tokens or caller options."""
    names = {"HOME", "PATH", "USER", "LOGNAME", "LANG", "LC_ALL",
             "TMPDIR", "SHELL", "TERM", "XDG_CONFIG_HOME"}
    return {k: v for k, v in os.environ.items() if k in names}


def _source_preflight(*, branch_name=CODEX_BRANCH, base_sha=CODEX_BASE_SHA):
    """Require the reviewed infra branch and its exact main ancestry."""
    root = Path(__file__).resolve().parents[2]
    cmd = ["git", "-C", str(root)]
    try:
        branch = subprocess.run(cmd + ["branch", "--show-current"],
                                capture_output=True, text=True, check=True, timeout=5)
        base = subprocess.run(cmd + ["merge-base", "HEAD", "origin/main"],
                              capture_output=True, text=True, check=True, timeout=5)
        origin = subprocess.run(cmd + ["remote", "get-url", "origin"],
                                capture_output=True, text=True, check=True, timeout=5)
        dirty = subprocess.run(cmd + ["status", "--porcelain", "--untracked-files=all"],
                               capture_output=True, text=True, check=True, timeout=5)
    except (OSError, subprocess.SubprocessError) as exc:
        raise QueueStop("untrusted or inaccessible infra source") from exc
    if (branch.stdout.strip() != branch_name
            or base.stdout.strip() != base_sha
            or origin.stdout.strip() !=
               "https://github.com/ClubBoss/sharky-standalone-direction.git"
            or dirty.stdout.strip()):
        raise QueueStop("M3A readonly source/branch not admitted or worktree dirty")


def _codex_binary():
    expected = (Path.home() / ".local/bin/codex").resolve()
    found = shutil.which("codex")
    if not found or Path(found).resolve() != expected or not expected.is_file():
        raise QueueStop("installed subscription Codex CLI not at admitted path")
    return str(expected)


def run_once(db_path: str | Path, *, owner_admission, initialize=False,
             profile="M3A") -> dict:
    """Only two exact accepted marker profiles, never a general Codex worker."""
    if profile == "M3A":
        task_id, worker, marker, prompt, admit_fn = (
            CODEX_TASK, WORKER, MARKER, PROMPT, admit_codex_readonly_once)
        if owner_admission != CODEX_ADMISSION:
            raise QueueStop("explicit one-shot owner admission missing")
        _source_preflight()
    elif profile == "M3C":
        task_id, worker, marker = M3C_TASK, "m3c-codex-readonly-once", (
            "SHARKY_M3C_UNATTENDED_READONLY_QUEUE_OK")
        prompt = (
            "MODEL: gpt-5.6-luna. REASONING: LOW. MODE: READ-ONLY TEST. "
            "Reply with exactly SHARKY_M3C_UNATTENDED_READONLY_QUEUE_OK "
            "and nothing else. No tools, files, shell, code changes or browsing. "
            "One unattended subscription marker only; no product or DoD proof.")
        admit_fn = admit_m3c_readonly_once
        if owner_admission != M3C_ADMISSION:
            raise QueueStop("M3C owner admission missing")
        _source_preflight(branch_name=M3C_BRANCH,base_sha=M3C_BASE_SHA)
    else:
        raise QueueStop("unknown Codex profile")
    binary = _codex_binary()
    db = connect(db_path, initialize=initialize)
    try:
        now = int(time.time())
        admit_fn(db, owner_admission=owner_admission, at=now)
        claim = lease_once(db, worker_id=worker, at=now)
        if claim["action"] == "IDLE":
            return {"action": "NOOP", "model_calls": 0, "reason": "one-shot-already-consumed"}
        if claim["action"] != "LEASED":
            return {"action": claim["action"], "model_calls": 0,
                    "reason": claim.get("reason", "held-lease")}
        if (claim["task_id"] != task_id or claim["provider"] != CODEX_PROVIDER
                or claim["execution_permitted"] is not False
                or claim["codex_readonly_probe_permitted"] is not True):
            raise QueueStop("unexpected model capability under task lease")
        proc = None
        with tempfile.TemporaryDirectory(prefix="sharky-codex-readonly-") as cwd:
            output_path = Path(cwd) / "final-marker.txt"
            cmd = [
                binary, "exec", "--model", MODEL, "--sandbox", "read-only",
                "-c", 'model_reasoning_effort="low"',
                "--ephemeral", "--ignore-user-config", "--skip-git-repo-check",
                "--output-last-message", str(output_path), "-C", cwd, prompt,
            ]
            try:
                proc = subprocess.Popen(
                    cmd, cwd=cwd, env=_safe_env(), stdin=subprocess.DEVNULL,
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                    start_new_session=True, close_fds=True,
                )
                try:
                    proc.wait(timeout=MAX_SECONDS)
                except subprocess.TimeoutExpired:
                    # Uncertain stop => persistent ACTIVE lease and STOP.
                    os.killpg(proc.pid, signal.SIGKILL)
                    proc.wait(timeout=5)
            except (OSError, subprocess.SubprocessError) as exc:
                raise QueueStop("Codex failed or timed out; preserve lease if uncertain") from exc
            if not _session_gone(proc):
                raise QueueStop("Codex process group not conclusively gone; lease remains ACTIVE")
            result = "STOP_FAILED"
            if proc.returncode == 0 and output_path.is_file():
                try:
                    if output_path.stat().st_size <= 512 and (
                        output_path.read_text(encoding="utf-8").strip() == marker
                    ):
                        result = "PASS_SCOPED"
                except (OSError, UnicodeError):
                    result = "STOP_FAILED"
            evidence = hashlib.sha256(
                f"{claim['lease_id']}:{proc.pid}:{proc.returncode}:{result}".encode("ascii")
            ).hexdigest()

            def verified_stop(lease_id, worker_id, receipt):
                return (lease_id == claim["lease_id"]
                        and worker_id == worker and receipt == evidence
                        and _session_gone(proc))

            acknowledge_stopped(
                db, lease_id=claim["lease_id"], worker_id=worker,
                stopped_receipt=evidence, at=int(time.time()),
                verify_stop=verified_stop,
            )
            return {"action": result, "task": task_id,
                    "model": MODEL, "reasoning": EFFORT, "sandbox": "read-only",
                    "model_calls": 1, "exit_code": proc.returncode,
                    "stop_verified": True, "lease_closed": True,
                    "receipt_sha256": evidence, "additional_paid_usd": 0,
                    "product_dod": "NOT_INFERRED", "autonomous_dispatch": "OFF"}
    finally:
        db.close()


def main():
    import argparse
    import json
    parser = argparse.ArgumentParser(description=__doc__)
    # CLI deliberately has one persistent local state path. It does NOT accept
    # task/provider/model/branch/database overrides or a future schedule.
    parser.add_argument("--initialize", action="store_true")
    parser.add_argument("--owner-admit-readonly-once", action="store_true")
    args = parser.parse_args()
    state = Path.home() / "Sharky_Autopilot_Pilot" / "m3a_state"
    if not state.is_dir() or state.is_symlink():
        raise QueueStop("fixed M3A state directory missing or a symlink")
    result = run_once(
        state / "codex-readonly-once.sqlite3",
        owner_admission=CODEX_ADMISSION if args.owner_admit_readonly_once else "",
        initialize=args.initialize,
    )
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
