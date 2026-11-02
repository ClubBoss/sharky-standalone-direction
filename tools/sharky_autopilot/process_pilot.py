"""M2D bounded real-process proof; explicitly NOT a Codex/Claude dispatcher.

Only one hardcoded offline, secretless Python child is permitted. No caller
supplies arbitrary command, executable, environment, code, credentials or model.
"""
from __future__ import annotations

import errno
import hashlib
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

from durable_queue import (
    ADMISSION, QueueStop, acknowledge_stopped, admit, connect, lease_once,
    snapshot,
)

EXPECTED = b"SHARKY_INFRA_PROBE_OK\n"
SCRIPT = "import sys; sys.stdout.write('SHARKY_INFRA_PROBE_OK\\n')"
TASK = "m2c-process-probe-01"
EVENT = "1" * 64
BRANCH = "infra/autopilot-m2d-process-20261102"
BASE_SHA = "d00e51957338c09fdb3e4ee4c1b13b0cf5557f86"


def _session_gone(proc: subprocess.Popen) -> bool:
    """Observe our own reaped child and absence of its process group."""
    if type(proc.pid) is not int or proc.pid <= 1 or proc.returncode is None:
        return False
    if proc.poll() is None:
        return False
    try:
        os.killpg(proc.pid, 0)
    except ProcessLookupError:
        return True
    except PermissionError:
        return False
    return False


def run_offline_process_probe(db_path: str | Path, *, initialize: bool = False) -> dict:
    """A single deterministic real subprocess under a held SQLite lease.

    This pilot does not implement a daemon or permission for AI execution.
    Repeated calls on a stopped task do not execute the child a second time.
    """
    db = connect(db_path, initialize=initialize)
    proc = None
    try:
        admitted = admit(
            db, task_id=TASK, event_id=EVENT, branch=BRANCH,
            base_sha=BASE_SHA, owner_admission=ADMISSION, at=1,
        )
        claim = lease_once(db, worker_id="m2d-local-probe", at=2)
        if claim["action"] == "IDLE":
            return {"action": "NOOP", "reason": "test-already-stopped",
                    "autonomous_model_dispatch": "OFF"}
        if claim["action"] != "LEASED":
            return {"action": claim["action"], "reason": claim.get("reason"),
                    "autonomous_model_dispatch": "OFF"}
        if claim["task_id"] != TASK or claim["provider"] != "NONE" or claim["execution_permitted"]:
            raise QueueStop("unexpected execution capability")
        with TemporaryDirectory(prefix="sharky-m2d-probe-") as cwd:
            try:
                # No inherited credentials, no shell, no user-controllable
                # command. The child only prints a fixed offline marker.
                proc = subprocess.Popen(
                    [sys.executable, "-I", "-c", SCRIPT],
                    cwd=cwd,
                    env={"PATH": "/usr/bin:/bin", "PYTHONNOUSERSITE": "1"},
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    start_new_session=True,
                    close_fds=True,
                )
                try:
                    output, _ = proc.communicate(timeout=5)
                except subprocess.TimeoutExpired:
                    os.killpg(proc.pid, 9)
                    proc.communicate(timeout=5)
                    raise QueueStop("offline probe timed out, inspect stop receipt")
            except (OSError, subprocess.SubprocessError) as exc:
                raise QueueStop("offline probe launch/stop failed") from exc
        if proc.returncode != 0 or output != EXPECTED or not _session_gone(proc):
            # The reserved lease is intentionally NOT reclaimed on uncertainty.
            raise QueueStop("offline probe not cleanly reaped, retain active lease")
        witness = hashlib.sha256(
            f"{claim['lease_id']}:{proc.pid}:{proc.returncode}:".encode("ascii") + output
        ).hexdigest()

        def verified_stop(lease_id, worker_id, receipt):
            return (lease_id == claim["lease_id"]
                    and worker_id == "m2d-local-probe"
                    and receipt == witness
                    and proc.returncode == 0
                    and _session_gone(proc))

        closed = acknowledge_stopped(
            db, lease_id=claim["lease_id"], worker_id="m2d-local-probe",
            stopped_receipt=witness, at=3, verify_stop=verified_stop,
        )
        return {"action": "PROBE_COMPLETE", "task": closed["task_id"],
                "process_exit": proc.returncode, "process_reaped": True,
                "witness_sha256": witness, "leased": True,
                "autonomous_model_dispatch": "OFF", "additional_spend_usd": 0}
    finally:
        db.close()


def main():
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", required=True)
    parser.add_argument("--initialize", action="store_true")
    args = parser.parse_args()
    import json
    print(json.dumps(run_offline_process_probe(
        args.database, initialize=args.initialize), sort_keys=True))


if __name__ == "__main__":
    main()
