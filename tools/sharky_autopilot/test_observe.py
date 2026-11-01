import copy
import json
import unittest
from unittest.mock import patch

from observe import REPO, PR_NUMBER, ISSUE_NUMBER, api_get, normalize, observe


class ObserverTests(unittest.TestCase):
    def setUp(self):
        self.pr = {"number": 355, "head": {"sha": "a" * 40}, "draft": True, "merged_at": None}
        self.actions = {"workflow_runs": [
            {"id": 1, "name": "Health", "status": "completed", "conclusion": "success", "event": "pull_request", "head_sha": "a" * 40},
            {"id": 2, "name": "Health", "status": "completed", "conclusion": "failure", "event": "pull_request", "head_sha": "b" * 40},
            {"id": 3, "name": "Theory", "status": "completed", "conclusion": "skipped", "event": "push", "head_sha": "a" * 40},
        ]}
        self.issue = {"state": "open", "updated_at": "2026-11-02T00:00:00Z"}

    def test_exact_sha_filter(self):
        obj = normalize(self.pr, self.actions, self.issue)
        self.assertEqual(len(obj["state"]["ci"]), 1)
        self.assertEqual(obj["state"]["ci"][0]["run_id"], 1)

    def test_no_acceptance_or_mutation(self):
        obj = normalize(self.pr, self.actions, self.issue)
        self.assertFalse(obj["mutation_permitted"])
        self.assertFalse(obj["scorecard_write_permitted"])
        self.assertFalse(obj["model_dispatch_permitted"])
        self.assertEqual(obj["acceptance"], "NEVER_INFERRED_FROM_GREEN_CI")

    def test_deterministic_event_identity(self):
        x = normalize(self.pr, self.actions, self.issue)
        y = normalize(self.pr, self.actions, self.issue)
        self.assertEqual(x["event_id"], y["event_id"])

    def test_run_order_does_not_change_event(self):
        alt = copy.deepcopy(self.actions)
        alt["workflow_runs"].reverse()
        self.assertEqual(normalize(self.pr, self.actions, self.issue)["event_id"],
                         normalize(self.pr, alt, self.issue)["event_id"])

    def test_new_head_has_new_event(self):
        newer = copy.deepcopy(self.pr)
        newer["head"]["sha"] = "c" * 40
        self.assertNotEqual(normalize(self.pr, self.actions, self.issue)["event_id"],
                            normalize(newer, self.actions, self.issue)["event_id"])

    def test_wrong_pr_rejected(self):
        pr = dict(self.pr, number=224)
        with self.assertRaises(ValueError):
            normalize(pr, self.actions, self.issue)

    def test_malformed_head_rejected(self):
        pr = copy.deepcopy(self.pr)
        pr["head"]["sha"] = "short"
        with self.assertRaises(ValueError):
            normalize(pr, self.actions, self.issue)

    def test_token_missing_fails_closed(self):
        with self.assertRaises(ValueError):
            api_get(f"/repos/{REPO}/pulls/{PR_NUMBER}", "")

    def test_outside_repo_forbidden(self):
        with self.assertRaises(ValueError):
            api_get("/repos/Other/Repo/pulls/1", "abc")

    def test_observe_only_three_gets(self):
        seen = []
        def stub(path, token):
            seen.append(path)
            if path.endswith("/pulls/355"):
                return self.pr
            if "/actions/runs?" in path:
                return self.actions
            if path.endswith("/issues/356"):
                return self.issue
            self.fail(f"unexpected request {path}")
        result = observe("test-only-token", getter=stub)
        self.assertEqual(len(seen), 3)
        self.assertEqual(result["state"]["head_sha"], "a" * 40)


if __name__ == "__main__":
    unittest.main()
