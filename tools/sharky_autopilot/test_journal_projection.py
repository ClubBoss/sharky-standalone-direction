import copy
import unittest

from journal_projection import canonical_state, fingerprint, marker, plan_append


def fixture():
    return {"schema": "sharky.autopilot.observation.v0.1",
            "observed_utc": "2026-11-02T00:00:00Z",
            "mutation_permitted": False, "model_dispatch_permitted": False,
            "scorecard_write_permitted": False,
            "state": {"repo": "ClubBoss/sharky-standalone-direction",
                      "pr": 355, "head_sha": "a" * 40, "draft": True, "merged": False,
                      "ci": [{"name": "Health", "run_id": 12,
                              "status": "completed", "conclusion": "success"}],
                      "autopilot_issue": {"number": 356,"state": "open","updated_at":"t0"}}}


class JournalTests(unittest.TestCase):
    def test_self_updated_issue_does_not_loop(self):
        a, b = fixture(), fixture()
        b["state"]["autopilot_issue"]["updated_at"] = "t100"
        self.assertEqual(fingerprint(a), fingerprint(b))

    def test_observer_timestamp_does_not_loop(self):
        a, b = fixture(), fixture()
        b["observed_utc"] = "another hour"
        self.assertEqual(fingerprint(a), fingerprint(b))

    def test_changed_ci_changes_event(self):
        a, b = fixture(), fixture()
        b["state"]["ci"][0]["conclusion"] = "failure"
        self.assertNotEqual(fingerprint(a), fingerprint(b))

    def test_new_head_changes_event(self):
        a, b = fixture(), fixture()
        b["state"]["head_sha"] = "b" * 40
        self.assertNotEqual(fingerprint(a), fingerprint(b))

    def test_reordered_ci_does_not_change_event(self):
        a, b = fixture(), fixture()
        a["state"]["ci"].append({"name":"Other", "run_id":13,"status":"completed","conclusion":"skipped"})
        b["state"]["ci"] = list(reversed(a["state"]["ci"]))
        self.assertEqual(fingerprint(a), fingerprint(b))

    def test_original_event_duplicate_noop(self):
        a = fixture(); eid = fingerprint(a)
        comments = [{"user":{"login":"github-actions[bot]"},"body": marker(eid)}]
        self.assertEqual(plan_append(a, comments, complete_history=True)["action"], "NOOP")

    def test_forged_user_receipt_not_trusted(self):
        a = fixture(); eid = fingerprint(a)
        comments = [{"user":{"login":"random"},"body": marker(eid)}]
        self.assertEqual(plan_append(a, comments, complete_history=True)["action"], "PREPARE_ONLY")

    def test_incomplete_history_stop(self):
        self.assertEqual(plan_append(fixture(), [],complete_history=False)["action"], "STOP")

    def test_no_implicit_mutation(self):
        a=fixture();a["mutation_permitted"] = True
        with self.assertRaises(ValueError): fingerprint(a)

    def test_wrong_pr_stop(self):
        a=fixture();a["state"]["pr"] = 224
        with self.assertRaises(ValueError): fingerprint(a)

    def test_invalid_ci_fails_closed(self):
        a=fixture();a["state"]["ci"][0]["status"] = "unknown"
        with self.assertRaises(ValueError): fingerprint(a)

    def test_duplicate_ci_run_fails_closed(self):
        a=fixture();a["state"]["ci"].append(copy.deepcopy(a["state"]["ci"][0]))
        with self.assertRaises(ValueError): fingerprint(a)


if __name__ == "__main__": unittest.main()
