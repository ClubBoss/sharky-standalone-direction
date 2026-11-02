"""Deterministic M2C queue pilot tests: no real worker or provider calls."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from tempfile import TemporaryDirectory
from threading import Barrier
import sqlite3
import unittest

from durable_queue import (
    ADMISSION, QueueStop, acknowledge_stopped, admit, connect, lease_once,
    requeue_stopped, snapshot, stale_leases,
)

EVENT = "a" * 64
BASE = "b" * 40
BRANCH = "infra/autopilot-m2c-queue-20261102"
TASK = "m2c-test-01"


class DurableQueueTests(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.path = Path(self.tmp.name) / "pilot.db"
        self.db = connect(self.path, initialize=True)

    def tearDown(self):
        self.db.close()
        self.tmp.cleanup()

    def enqueue(self, **kw):
        args = dict(task_id=TASK, event_id=EVENT, branch=BRANCH,
                    base_sha=BASE, owner_admission=ADMISSION, at=1)
        args.update(kw)
        return admit(self.db, **args)

    def test_empty_queue_does_not_dispatch(self):
        self.assertEqual(lease_once(self.db, worker_id="test-worker", at=2)["action"], "IDLE")
        self.assertEqual(snapshot(self.db)["autonomous_dispatch"], "OFF")

    def test_requires_explicit_initialization(self):
        with self.assertRaises(QueueStop):
            connect(Path(self.tmp.name) / "missing.db")
        self.assertFalse((Path(self.tmp.name) / "missing.db").exists())

    def test_unknown_existing_database_fails_closed(self):
        path = Path(self.tmp.name) / "wrong.db"
        sqlite3.connect(path).close()
        with self.assertRaises(QueueStop):
            connect(path)

    def test_schema_drop_is_not_silently_recreated(self):
        self.db.execute("DROP INDEX only_one_active_resource")
        self.db.close()
        with self.assertRaises(QueueStop):
            connect(self.path)
        self.db = sqlite3.connect(self.path)

    def test_rejects_second_initialization(self):
        with self.assertRaises(QueueStop):
            connect(self.path, initialize=True)

    def test_owner_admission_enforced(self):
        with self.assertRaises(QueueStop):
            self.enqueue(owner_admission="owner-unknown")
        self.assertEqual(snapshot(self.db)["tasks"], [])

    def test_scope_is_fixed_to_infra_test_branch(self):
        for branch in ("codex/product-writer", "infra/autopilot-../../escape",
                       "infra/autopilot-x; rm -rf /", "infra/autopilot-"):
            with self.subTest(branch=branch), self.assertRaises(QueueStop):
                self.enqueue(branch=branch)

    def test_rejects_bad_exact_source_and_task_identity(self):
        for kw in ({"event_id": "a"}, {"base_sha": "0"},
                   {"task_id": "../../oops"}, {"at": True}):
            with self.subTest(kw=kw), self.assertRaises(QueueStop):
                self.enqueue(**kw)

    def test_replay_is_noop_and_no_duplicate_audit(self):
        self.assertEqual(self.enqueue()["action"], "ADMITTED")
        self.assertEqual(self.enqueue()["action"], "NOOP")
        self.assertEqual(len(snapshot(self.db)["events"]), 1)

    def test_same_task_id_changed_payload_stops(self):
        self.enqueue()
        with self.assertRaises(QueueStop):
            self.enqueue(event_id="c" * 64)

    def test_lease_is_durable_across_reopen(self):
        self.enqueue()
        first = lease_once(self.db, worker_id="test-worker", at=3)
        self.assertEqual(first["action"], "LEASED")
        self.assertFalse(first["execution_permitted"])
        self.db.close()
        self.db = connect(self.path)
        self.assertEqual(lease_once(self.db, worker_id="other", at=9)["action"], "BUSY")
        self.assertEqual(snapshot(self.db)["leases"][0]["lease_id"], first["lease_id"])

    def test_stale_is_diagnostic_not_automatic_reclaim(self):
        self.enqueue()
        first = lease_once(self.db, worker_id="worker-1", at=4)
        self.assertEqual(stale_leases(self.db, now=999, after_seconds=10)[0]["lease_id"],
                         first["lease_id"])
        self.assertEqual(lease_once(self.db, worker_id="worker-2", at=999)["action"], "BUSY")

    def test_two_connections_cannot_lease_same_resource(self):
        self.enqueue(task_id="m2c-task-a")
        self.enqueue(task_id="m2c-task-b")
        barrier = Barrier(2)
        def contender(n):
            db = connect(self.path)
            try:
                barrier.wait(timeout=5)
                return lease_once(db, worker_id=f"worker-{n}", at=8)["action"]
            finally:
                db.close()
        with ThreadPoolExecutor(max_workers=2) as pool:
            actions = sorted(pool.map(contender, (1, 2)))
        self.assertEqual(actions, ["BUSY", "LEASED"])
        self.assertEqual(len([x for x in snapshot(self.db)["leases"] if x["status"]=="ACTIVE"]), 1)

    def test_no_implicit_stopped_receipt_or_expiry(self):
        self.enqueue()
        lease = lease_once(self.db, worker_id="worker-1", at=4)
        for bad in (None, "", "operator-confirmed"):
            with self.subTest(bad=bad), self.assertRaises(QueueStop):
                acknowledge_stopped(self.db, lease_id=lease["lease_id"], worker_id="worker-1",
                                    stopped_receipt=bad, at=500)
        self.assertEqual(lease_once(self.db, worker_id="worker-2", at=1000)["action"], "BUSY")

    def test_even_formatted_receipt_requires_independent_verifier(self):
        self.enqueue()
        lease = lease_once(self.db, worker_id="worker-1", at=4)
        with self.assertRaises(QueueStop):
            acknowledge_stopped(self.db, lease_id=lease["lease_id"], worker_id="worker-1",
                                stopped_receipt="e" * 64, at=5)
        with self.assertRaises(QueueStop):
            acknowledge_stopped(self.db, lease_id=lease["lease_id"], worker_id="worker-1",
                                stopped_receipt="e" * 64, at=5, verify_stop=lambda *_: False)
        self.assertEqual(lease_once(self.db, worker_id="worker-2", at=6)["action"], "BUSY")

    def test_external_verifier_must_return_exact_true(self):
        self.enqueue()
        lease = lease_once(self.db, worker_id="worker-1", at=4)
        with self.assertRaises(QueueStop):
            acknowledge_stopped(self.db, lease_id=lease["lease_id"], worker_id="worker-1",
                                stopped_receipt="e" * 64, at=5, verify_stop=lambda *_: 1)

    def test_mismatched_worker_cannot_close_lease(self):
        self.enqueue()
        lease = lease_once(self.db, worker_id="worker-1", at=4)
        with self.assertRaises(QueueStop):
            acknowledge_stopped(self.db, lease_id=lease["lease_id"], worker_id="imposter",
                                stopped_receipt="d" * 64, at=5)

    def test_explicit_stop_and_owner_requeue_only(self):
        self.enqueue()
        lease = lease_once(self.db, worker_id="worker-1", at=4)
        self.assertEqual(acknowledge_stopped(
            self.db, lease_id=lease["lease_id"], worker_id="worker-1",
            stopped_receipt="d" * 64, at=5, verify_stop=lambda *_: True)["action"], "STOPPED")
        with self.assertRaises(QueueStop):
            requeue_stopped(self.db, task_id=TASK, owner_admission="NONE", at=6)
        self.assertEqual(requeue_stopped(
            self.db, task_id=TASK, owner_admission=ADMISSION, at=6)["action"], "REQUEUED")

    def test_max_attempts_hard_stop(self):
        self.enqueue()
        for n in (0, 1):
            lease = lease_once(self.db, worker_id=f"worker-{n}", at=n + 10)
            self.assertEqual(lease["action"], "LEASED")
            acknowledge_stopped(self.db, lease_id=lease["lease_id"],
                                worker_id=f"worker-{n}", stopped_receipt="f" * 64, at=n+20, verify_stop=lambda *_: True)
            if n == 0:
                requeue_stopped(self.db, task_id=TASK, owner_admission=ADMISSION, at=n+30)
        with self.assertRaises(QueueStop):
            requeue_stopped(self.db, task_id=TASK, owner_admission=ADMISSION, at=100)
        self.assertEqual(snapshot(self.db)["tasks"][0]["attempts"], 2)

    def test_never_authorizes_payment_or_provider(self):
        self.enqueue()
        lease_once(self.db, worker_id="worker-1", at=1)
        state = snapshot(self.db)
        self.assertEqual(state["tasks"][0]["incremental_spend_cents"], 0)
        self.assertEqual(state["tasks"][0]["provider"], "NONE")
        self.assertEqual(state["product_dod"], "NOT_INFERRED")
        self.assertNotIn("exec", state["events"][1]["detail"].lower())

    def test_rejects_mutation_without_active_lease(self):
        self.enqueue()
        with self.assertRaises(QueueStop):
            acknowledge_stopped(self.db, lease_id="unknown", worker_id="worker-1",
                                stopped_receipt="a" * 64, at=1)

    def test_event_audit_is_append_only_under_replay(self):
        self.enqueue()
        lease = lease_once(self.db, worker_id="worker-1", at=2)
        acknowledge_stopped(self.db, lease_id=lease["lease_id"], worker_id="worker-1",
                            stopped_receipt="a" * 64, at=3, verify_stop=lambda *_: True)
        self.assertEqual([e["action"] for e in snapshot(self.db)["events"]],
                         ["ADMITTED","LEASED","STOPPED"])
        with self.assertRaises(QueueStop):
            acknowledge_stopped(self.db, lease_id=lease["lease_id"], worker_id="worker-1",
                                stopped_receipt="a" * 64, at=4, verify_stop=lambda *_: True)
        self.assertEqual(len(snapshot(self.db)["events"]), 3)


if __name__ == "__main__":
    unittest.main()
