"""M2C pilot: durable local SQLite task queue with fail-closed exclusive leases.

No worker subprocess, code execution, GitHub mutation, subscription/API call or
product-state admission is implemented here. This is an isolated infra-test
simulation, NOT production worker scheduling.
"""
from __future__ import annotations

import hashlib
import json
import re
import sqlite3
import uuid
from contextlib import contextmanager
from pathlib import Path

SCOPE = "AUTOPILOT_INFRA_TEST_ONLY"
RESOURCE = "autopilot-infra-test"
ADMISSION = "OWNER_ADMITS_INFRA_TEST_ONLY"
PROVIDER = "NONE"
CODEX_PROVIDER = "CODEX_SUBSCRIPTION_READONLY_ONESHOT"
CODEX_ADMISSION = "OWNER_ADMITS_CODEX_READONLY_ONESHOT"
CODEX_TASK = "m2c-codex-readonly-01"
CODEX_BRANCH = "infra/autopilot-m3a-readonly-20261102"
CODEX_BASE_SHA = "a1ac8b63d397a00ddeaa5f8251694ce0b6a37baa"
CODEX_EVENT = hashlib.sha256(
    f"SHARKY_M3A_OWNER_READONLY_ONCE:{CODEX_BASE_SHA}".encode("ascii")
).hexdigest()
M3C_ADMISSION = "OWNER_ADMITS_M3C_UNATTENDED_READONLY_ONCE"
M3C_TASK = "m2c-codex-m3c-once"
M3C_BRANCH = "infra/autopilot-m3c-readonly-20261102"
M3C_BASE_SHA = "9dd166568b12758bd6c797a38dae5b8758f61c54"
M3C_EVENT = hashlib.sha256(
    f"SHARKY_M3C_OWNER_UNATTENDED_READONLY_ONCE:{M3C_BASE_SHA}".encode("ascii")
).hexdigest()
M3C_R2_ADMISSION = "OWNER_ADMITS_M3C_R2_DIAGNOSTIC_READONLY_ONCE"
M3C_R2_TASK = "m2c-codex-m3c-r2-once"
M3C_R2_EVENT = hashlib.sha256(
    f"SHARKY_M3C_R2_DIAGNOSTIC_ONCE:{M3C_BASE_SHA}".encode("ascii")
).hexdigest()
ID_PATTERN = re.compile(r"m2c-[a-z0-9][a-z0-9-]{1,70}\Z")
HEX64 = re.compile(r"[0-9a-f]{64}\Z")
HEX40 = re.compile(r"[0-9a-f]{40}\Z")
WORKER = re.compile(r"[a-zA-Z0-9][a-zA-Z0-9._-]{0,63}\Z")
BRANCH = re.compile(r"infra/autopilot-[a-z0-9][a-z0-9._-]{0,100}\Z")


class QueueStop(RuntimeError):
    """Explicit STOP, never permission to fall back to unsafe execution."""


@contextmanager
def transaction(db):
    db.execute("BEGIN IMMEDIATE")
    try:
        yield
        db.execute("COMMIT")
    except BaseException:
        db.execute("ROLLBACK")
        raise


def connect(path: str | Path, *, initialize: bool = False):
    """Initialize only by explicit request; otherwise refuse missing databases."""
    path = Path(path)
    if path.is_symlink():
        raise QueueStop("queue database cannot be a symlink")
    if initialize:
        if path.exists():
            raise QueueStop("existing queue cannot be silently reinitialized")
        if not path.parent.is_dir():
            raise QueueStop("queue parent directory missing")
    elif not path.is_file():
        raise QueueStop("queue missing: never silently recreate")
    db = sqlite3.connect(str(path), isolation_level=None, timeout=5)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    db.execute("PRAGMA busy_timeout = 5000")
    db.execute("PRAGMA journal_mode = WAL")
    if initialize:
        db.executescript("""
    CREATE TABLE IF NOT EXISTS tasks (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        payload_hash TEXT NOT NULL,
        scope TEXT NOT NULL CHECK (scope = 'AUTOPILOT_INFRA_TEST_ONLY'),
        resource TEXT NOT NULL CHECK (resource = 'autopilot-infra-test'),
        branch TEXT NOT NULL,
        base_sha TEXT NOT NULL,
        provider TEXT NOT NULL CHECK (provider IN ('NONE','CODEX_SUBSCRIPTION_READONLY_ONESHOT')),
        incremental_spend_cents INTEGER NOT NULL
            CHECK (incremental_spend_cents = 0),
        status TEXT NOT NULL CHECK (status IN ('READY','LEASED','STOPPED')),
        attempts INTEGER NOT NULL DEFAULT 0 CHECK (attempts >= 0),
        max_attempts INTEGER NOT NULL CHECK (max_attempts BETWEEN 1 AND 2)
    );
    CREATE TABLE IF NOT EXISTS leases (
        lease_id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL REFERENCES tasks(id),
        resource TEXT NOT NULL CHECK (resource = 'autopilot-infra-test'),
        worker_id TEXT NOT NULL,
        acquired_at INTEGER NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('ACTIVE','CLOSED')),
        stop_receipt TEXT,
        UNIQUE(task_id, lease_id)
    );
    CREATE UNIQUE INDEX IF NOT EXISTS only_one_active_resource
        ON leases(resource) WHERE status = 'ACTIVE';
    CREATE UNIQUE INDEX IF NOT EXISTS only_one_active_task
        ON leases(task_id) WHERE status = 'ACTIVE';
    CREATE TABLE IF NOT EXISTS events (
        seq INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id TEXT NOT NULL REFERENCES tasks(id),
        action TEXT NOT NULL CHECK (action IN
            ('ADMITTED','LEASED','STOPPED','REQUEUED')),
        lease_id TEXT,
        detail TEXT NOT NULL,
        at INTEGER NOT NULL
    );
    PRAGMA user_version=2;
    """)
    else:
        version = db.execute("PRAGMA user_version").fetchone()[0]
        if version != 2:
            db.close()
            raise QueueStop("untrusted or incompatible existing queue schema")
        expected = {"tasks", "leases", "events", "only_one_active_resource",
                    "only_one_active_task"}
        actual = {x[0] for x in db.execute(
            "SELECT name FROM sqlite_master WHERE type IN ('table','index')")}
        if not expected.issubset(actual):
            db.close()
            raise QueueStop("queue schema missing required objects")
    return db


def _expect_time(at):
    if type(at) is not int or at < 0:
        raise QueueStop("invalid event time")


def _task_hash(task_id, event_id, branch, base_sha, *, provider=PROVIDER, max_attempts=2):
    raw = json.dumps([task_id, event_id, SCOPE, RESOURCE, branch, base_sha,
                      provider, 0, max_attempts], separators=(",", ":"))
    return hashlib.sha256(raw.encode("ascii")).hexdigest()


def admit(db, *, task_id, event_id, branch, base_sha, owner_admission, at):
    """One explicit simulated infra-test scope. Conflicting replay is STOP."""
    _expect_time(at)
    if (owner_admission != ADMISSION or not isinstance(task_id, str)
            or not ID_PATTERN.fullmatch(task_id)
            or not isinstance(event_id, str) or not HEX64.fullmatch(event_id)
            or not isinstance(base_sha, str) or not HEX40.fullmatch(base_sha)
            or not isinstance(branch, str) or not BRANCH.fullmatch(branch)):
        raise QueueStop("task identity/scope/owner gate rejected")
    digest = _task_hash(task_id, event_id, branch, base_sha)
    with transaction(db):
        existing = db.execute("SELECT payload_hash FROM tasks WHERE id=?", (task_id,)).fetchone()
        if existing:
            if existing["payload_hash"] != digest:
                raise QueueStop("task-id replay with changed payload")
            return {"action": "NOOP", "task_id": task_id}
        db.execute("""INSERT INTO tasks
            (id,event_id,payload_hash,scope,resource,branch,base_sha,provider,
             incremental_spend_cents,status,attempts,max_attempts)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
            (task_id,event_id,digest,SCOPE,RESOURCE,branch,base_sha,PROVIDER,
             0,"READY",0,2))
        db.execute("INSERT INTO events(task_id,action,detail,at) VALUES (?,?,?,?)",
                   (task_id,"ADMITTED","owner-gated infra-test only",at))
    return {"action": "ADMITTED", "task_id": task_id}


def admit_codex_readonly_once(db, *, owner_admission, at):
    """Fixed owner-admitted one-shot infra marker; no arbitrary task inputs.

    There is intentionally no general provider/admission API. This does not
    authorize a code-writing worker, scheduled model calls, or other scope.
    """
    _expect_time(at)
    if owner_admission != CODEX_ADMISSION:
        raise QueueStop("Codex readonly owner admission absent")
    digest = _task_hash(
        CODEX_TASK, CODEX_EVENT, CODEX_BRANCH, CODEX_BASE_SHA,
        provider=CODEX_PROVIDER, max_attempts=1,
    )
    with transaction(db):
        existing = db.execute("SELECT * FROM tasks WHERE id=?", (CODEX_TASK,)).fetchone()
        if existing:
            if (existing["payload_hash"] != digest
                    or existing["provider"] != CODEX_PROVIDER
                    or existing["max_attempts"] != 1):
                raise QueueStop("Codex one-shot identity changed")
            return {"action": "NOOP", "task_id": CODEX_TASK}
        db.execute("""INSERT INTO tasks
            (id,event_id,payload_hash,scope,resource,branch,base_sha,provider,
             incremental_spend_cents,status,attempts,max_attempts)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
            (CODEX_TASK, CODEX_EVENT, digest, SCOPE, RESOURCE, CODEX_BRANCH,
             CODEX_BASE_SHA, CODEX_PROVIDER, 0, "READY", 0, 1))
        db.execute("INSERT INTO events(task_id,action,detail,at) VALUES (?,?,?,?)",
                   (CODEX_TASK, "ADMITTED", "fixed Codex readonly once; manual only", at))
    return {"action": "ADMITTED", "task_id": CODEX_TASK}


def admit_m3c_readonly_once(db, *, owner_admission, at):
    """Dedicated owner-approved second one-shot; no arbitrary job inputs."""
    _expect_time(at)
    if owner_admission != M3C_ADMISSION:
        raise QueueStop("M3C owner admission absent")
    digest = _task_hash(M3C_TASK, M3C_EVENT, M3C_BRANCH, M3C_BASE_SHA,
                        provider=CODEX_PROVIDER, max_attempts=1)
    with transaction(db):
        existing = db.execute("SELECT * FROM tasks WHERE id=?", (M3C_TASK,)).fetchone()
        if existing:
            if (existing["payload_hash"] != digest
                    or existing["provider"] != CODEX_PROVIDER
                    or existing["max_attempts"] != 1):
                raise QueueStop("M3C changed payload replay")
            return {"action": "NOOP", "task_id": M3C_TASK}
        db.execute("""INSERT INTO tasks
            (id,event_id,payload_hash,scope,resource,branch,base_sha,provider,
             incremental_spend_cents,status,attempts,max_attempts)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
            (M3C_TASK,M3C_EVENT,digest,SCOPE,RESOURCE,M3C_BRANCH,M3C_BASE_SHA,
             CODEX_PROVIDER,0,"READY",0,1))
        db.execute("INSERT INTO events(task_id,action,detail,at) VALUES (?,?,?,?)",
                   (M3C_TASK,"ADMITTED","fixed M3C launchd Codex read-only once",at))
    return {"action":"ADMITTED","task_id":M3C_TASK}


def admit_m3c_r2_readonly_once(db, *, owner_admission, at):
    """Separate, explicitly admitted diagnostic attempt in the SAME queue."""
    _expect_time(at)
    if owner_admission != M3C_R2_ADMISSION:
        raise QueueStop("M3C R2 owner admission absent")
    digest = _task_hash(M3C_R2_TASK, M3C_R2_EVENT, M3C_BRANCH, M3C_BASE_SHA,
                        provider=CODEX_PROVIDER, max_attempts=1)
    with transaction(db):
        prior = db.execute(
            "SELECT status,attempts,max_attempts FROM tasks WHERE id=?",
            (M3C_TASK,)).fetchone()
        if (prior is None or prior["status"] != "STOPPED"
                or prior["attempts"] != 1 or prior["max_attempts"] != 1):
            raise QueueStop("original M3C must be consumed before R2")
        if db.execute("SELECT 1 FROM leases WHERE status='ACTIVE'").fetchone():
            raise QueueStop("active lease blocks R2 admission")
        existing = db.execute("SELECT * FROM tasks WHERE id=?",
                              (M3C_R2_TASK,)).fetchone()
        if existing:
            if (existing["payload_hash"] != digest
                    or existing["provider"] != CODEX_PROVIDER
                    or existing["max_attempts"] != 1):
                raise QueueStop("M3C R2 changed payload replay")
            return {"action": "NOOP", "task_id": M3C_R2_TASK}
        db.execute("""INSERT INTO tasks
            (id,event_id,payload_hash,scope,resource,branch,base_sha,provider,
             incremental_spend_cents,status,attempts,max_attempts)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)""",
            (M3C_R2_TASK,M3C_R2_EVENT,digest,SCOPE,RESOURCE,M3C_BRANCH,
             M3C_BASE_SHA,CODEX_PROVIDER,0,"READY",0,1))
        db.execute("INSERT INTO events(task_id,action,detail,at) VALUES (?,?,?,?)",
                   (M3C_R2_TASK,"ADMITTED","separate R2 diagnostics once",at))
    return {"action": "ADMITTED", "task_id": M3C_R2_TASK}


def lease_once(db, *, worker_id, at):
    """Atomic reservation. Never runs a model or invokes a shell command."""
    _expect_time(at)
    if not isinstance(worker_id, str) or not WORKER.fullmatch(worker_id):
        raise QueueStop("invalid worker identity")
    with transaction(db):
        # Explicitly fail closed if any previous worker has no stop receipt.
        busy = db.execute("SELECT lease_id FROM leases WHERE status='ACTIVE' LIMIT 1").fetchone()
        if busy:
            return {"action": "BUSY", "reason": "active-resource-lease"}
        task = db.execute("""SELECT * FROM tasks
             WHERE status='READY' AND attempts < max_attempts
             ORDER BY rowid LIMIT 1""").fetchone()
        if task is None:
            return {"action": "IDLE", "reason": "no-admitted-ready-task"}
        if task["scope"] != SCOPE or task["resource"] != RESOURCE or task["incremental_spend_cents"] != 0:
            raise QueueStop("unexpected task scope/resource/budget")
        is_codex = task["provider"] == CODEX_PROVIDER
        if task["provider"] not in (PROVIDER, CODEX_PROVIDER):
            raise QueueStop("unadmitted provider")
        codex_spec = {
            CODEX_TASK: (CODEX_EVENT, CODEX_BRANCH, CODEX_BASE_SHA),
            M3C_TASK: (M3C_EVENT, M3C_BRANCH, M3C_BASE_SHA),
            M3C_R2_TASK: (M3C_R2_EVENT, M3C_BRANCH, M3C_BASE_SHA),
        }.get(task["id"])
        if is_codex:
            if codex_spec is None:
                raise QueueStop("unadmitted Codex task identity")
            evt, branch, base_sha = codex_spec
            if (task["event_id"] != evt or task["branch"] != branch
                    or task["base_sha"] != base_sha
                    or task["attempts"] != 0 or task["max_attempts"] != 1
                    or task["payload_hash"] != _task_hash(
                        task["id"],evt,branch,base_sha,
                        provider=CODEX_PROVIDER,max_attempts=1)):
                raise QueueStop("Codex probe capability mismatch")
        lease_id = str(uuid.uuid4())
        db.execute("UPDATE tasks SET status='LEASED',attempts=attempts+1 WHERE id=?",
                   (task["id"],))
        db.execute("""INSERT INTO leases(lease_id,task_id,resource,worker_id,acquired_at,status)
            VALUES (?,?,?,?,?,'ACTIVE')""",
            (lease_id,task["id"],RESOURCE,worker_id,at))
        db.execute("""INSERT INTO events(task_id,action,lease_id,detail,at)
            VALUES (?,?,?,?,?)""",
            (task["id"],"LEASED",lease_id,"reservation only; provider OFF",at))
        return {"action": "LEASED", "task_id": task["id"], "lease_id": lease_id,
                "resource": RESOURCE, "branch": task["branch"],
                "provider": task["provider"], "execution_permitted": False,
                "codex_readonly_probe_permitted": is_codex}


def stale_leases(db, *, now, after_seconds):
    """Visibility only: a stale lease is NOT permission to reclaim or execute."""
    _expect_time(now)
    if type(after_seconds) is not int or after_seconds < 1:
        raise QueueStop("invalid stale threshold")
    return [dict(row) for row in db.execute(
        """SELECT lease_id,task_id,worker_id,acquired_at
           FROM leases WHERE status='ACTIVE' AND acquired_at <= ?
           ORDER BY acquired_at,lease_id""", (now - after_seconds,))]


def acknowledge_stopped(db, *, lease_id, worker_id, stopped_receipt, at, verify_stop=None):
    """Explicit STOP receipt; no automatic dead-worker or TTL reclamation.

    The caller must supply an independent trusted verifier. The pilot
    does not provide one: default behavior is STOP, not worker reclamation.
    """
    _expect_time(at)
    if (not isinstance(lease_id, str) or not lease_id
            or not isinstance(worker_id, str) or not WORKER.fullmatch(worker_id)
            or not isinstance(stopped_receipt, str) or not HEX64.fullmatch(stopped_receipt)):
        raise QueueStop("independent stopped-worker receipt required")
    if verify_stop is None or verify_stop(lease_id, worker_id, stopped_receipt) is not True:
        raise QueueStop("no independently verified worker-stop evidence")
    with transaction(db):
        row = db.execute("SELECT * FROM leases WHERE lease_id=?", (lease_id,)).fetchone()
        if row is None or row["worker_id"] != worker_id or row["status"] != "ACTIVE":
            raise QueueStop("no matching active worker lease")
        db.execute("UPDATE leases SET status='CLOSED',stop_receipt=? WHERE lease_id=?",
                   (stopped_receipt, lease_id))
        db.execute("UPDATE tasks SET status='STOPPED' WHERE id=?", (row["task_id"],))
        db.execute("INSERT INTO events(task_id,action,lease_id,detail,at) VALUES (?,?,?,?,?)",
                   (row["task_id"],"STOPPED",lease_id,"operator supplied worker stopped receipt",at))
        return {"action": "STOPPED", "task_id": row["task_id"]}


def requeue_stopped(db, *, task_id, owner_admission, at):
    _expect_time(at)
    if owner_admission != ADMISSION:
        raise QueueStop("explicit owner re-admission required")
    with transaction(db):
        task = db.execute("SELECT * FROM tasks WHERE id=?", (task_id,)).fetchone()
        if task is None or task["status"] != "STOPPED":
            raise QueueStop("only fully stopped tasks may be requeued")
        if task["attempts"] >= task["max_attempts"]:
            raise QueueStop("attempt limit reached; no automatic retries")
        if db.execute("SELECT 1 FROM leases WHERE task_id=? AND status='ACTIVE'",
                      (task_id,)).fetchone():
            raise QueueStop("worker lease not closed")
        db.execute("UPDATE tasks SET status='READY' WHERE id=?", (task_id,))
        db.execute("INSERT INTO events(task_id,action,detail,at) VALUES (?,?,?,?)",
                   (task_id,"REQUEUED","owner re-admitted stopped infra-test",at))
        return {"action": "REQUEUED", "task_id": task_id}


def snapshot(db):
    """Read-only operational truth. NOT product learning acceptance."""
    return {
        "tasks": [dict(x) for x in db.execute(
            "SELECT id,event_id,scope,resource,branch,base_sha,provider,"
            "incremental_spend_cents,status,attempts,max_attempts FROM tasks ORDER BY rowid")],
        "leases": [dict(x) for x in db.execute(
            "SELECT lease_id,task_id,worker_id,acquired_at,status,stop_receipt "
            "FROM leases ORDER BY rowid")],
        "events": [dict(x) for x in db.execute(
            "SELECT seq,task_id,action,lease_id,detail,at FROM events ORDER BY seq")],
        "autonomous_dispatch": "OFF",
        "product_dod": "NOT_INFERRED",
    }
