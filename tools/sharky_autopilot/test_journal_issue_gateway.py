import copy
import io
import json
import unittest

from journal_projection import BOT, fingerprint, marker
from journal_issue_gateway import (
    EXPECTED_WORKFLOW_REF, JournalStop, IssueClient,
    read_stable_history, render_receipt, run_once, trusted_main_gate,
)
from test_journal_projection import fixture


def gate_env():
    return {
        "SHARKY_M2_POST_OWNER_ADMITTED": "YES_AFTER_INDEPENDENT_REVIEW",
        "GITHUB_REPOSITORY": "ClubBoss/sharky-standalone-direction",
        "GITHUB_REF": "refs/heads/main",
        "GITHUB_EVENT_NAME": "workflow_dispatch",
        "GITHUB_WORKFLOW_REF": EXPECTED_WORKFLOW_REF,
    }


class FakeIssue:
    def __init__(self, comments=None):
        self.comments = copy.deepcopy(comments or [])
        self.posts = []
        self.count_calls = 0
        self.on_count = None
        self.bad_receipt = False

    def issue_comments_count(self):
        self.count_calls += 1
        if self.on_count:
            self.on_count(self)
        return len(self.comments)

    def comments_page(self, page):
        start = (page - 1) * 100
        return copy.deepcopy(self.comments[start:start + 100])

    def post_comment(self, body):
        self.posts.append(body)
        latest = max([item["id"] for item in self.comments], default=0)
        item = {"id": latest + 1, "user": {"login": BOT}, "body": body}
        self.comments.append(item)
        return {"id": item["id"], "user": {"login": BOT},
                "body": "spoofed" if self.bad_receipt else body}


def make_comment(n, body="ordinary issue comment", login="ClubBoss"):
    return {"id": n, "user": {"login": login}, "body": body}


class GatewayTests(unittest.TestCase):
    def test_default_dry_run_even_if_all_env_flags_present(self):
        client = FakeIssue()
        result = run_once(fixture(), client, env=gate_env())
        self.assertEqual(result["action"], "PREPARE_ONLY")
        self.assertEqual(client.posts, [])

    def test_missing_owner_admission_never_posts(self):
        client = FakeIssue()
        env = gate_env()
        del env["SHARKY_M2_POST_OWNER_ADMITTED"]
        result = run_once(fixture(), client, admit_post=True, env=env)
        self.assertEqual(result["action"], "PREPARE_ONLY")
        self.assertEqual(client.posts, [])

    def test_untrusted_pr_branch_never_posts(self):
        client = FakeIssue()
        env = gate_env()
        env["GITHUB_REF"] = "refs/pull/355/merge"
        self.assertFalse(trusted_main_gate(env))
        run_once(fixture(), client, admit_post=True, env=env)
        self.assertEqual(client.posts, [])

    def test_untrusted_workflow_never_posts(self):
        client = FakeIssue()
        env = gate_env()
        env["GITHUB_WORKFLOW_REF"] = "attacker.yml@refs/heads/main"
        run_once(fixture(), client, admit_post=True, env=env)
        self.assertEqual(client.posts, [])

    def test_wrong_repository_never_posts(self):
        client = FakeIssue()
        env = gate_env()
        env["GITHUB_REPOSITORY"] = "attacker/other"
        run_once(fixture(), client, admit_post=True, env=env)
        self.assertEqual(client.posts, [])

    def test_atomicity_not_claimed_but_serial_readback_succeeds(self):
        client = FakeIssue()
        result = run_once(fixture(), client, admit_post=True, env=gate_env())
        self.assertEqual(result["action"], "POSTED_READBACK")
        self.assertEqual(len(client.posts), 1)
        self.assertIn("DoD: **NOT INFERRED**", client.posts[0])
        self.assertEqual(result["acceptance"], "NEVER_INFERRED")
        self.assertEqual(run_once(fixture(), client, admit_post=True, env=gate_env())["action"], "NOOP")
        self.assertEqual(len(client.posts), 1)

    def test_nonbot_spoof_does_not_dedup(self):
        event_id = fingerprint(fixture())
        client = FakeIssue([make_comment(7, marker(event_id), login="ordinary-user")])
        result = run_once(fixture(), client)
        self.assertEqual(result["action"], "PREPARE_ONLY")

    def test_bot_matching_receipt_is_noop_without_post(self):
        event_id = fingerprint(fixture())
        client = FakeIssue([make_comment(10, marker(event_id), login=BOT)])
        result = run_once(fixture(), client, admit_post=True, env=gate_env())
        self.assertEqual(result["action"], "NOOP")
        self.assertEqual(client.posts, [])

    def test_page_full_history_101(self):
        client = FakeIssue([make_comment(i + 1) for i in range(101)])
        self.assertEqual(len(read_stable_history(client)), 101)
        self.assertEqual(client.count_calls, 2)

    def test_page_short_history_stops(self):
        class MissingPage(FakeIssue):
            def comments_page(self, page):
                return [] if page == 2 else super().comments_page(page)
        client = MissingPage([make_comment(i + 1) for i in range(101)])
        with self.assertRaisesRegex(JournalStop, "incomplete"):
            read_stable_history(client)

    def test_change_during_read_stops(self):
        client = FakeIssue([make_comment(1)])
        def mutate(x):
            if x.count_calls == 2:
                x.comments.append(make_comment(2))
        client.on_count = mutate
        with self.assertRaisesRegex(JournalStop, "changed"):
            read_stable_history(client)

    def test_change_before_post_stops(self):
        client = FakeIssue([make_comment(1)])
        def mutate(x):
            if x.count_calls == 3:
                x.comments.append(make_comment(2))
        client.on_count = mutate
        with self.assertRaisesRegex(JournalStop, "before append"):
            run_once(fixture(), client, admit_post=True, env=gate_env())
        self.assertEqual(client.posts, [])

    def test_duplicate_comment_id_rejected(self):
        client = FakeIssue([make_comment(1), make_comment(1)])
        with self.assertRaisesRegex(JournalStop, "duplicated"):
            read_stable_history(client)

    def test_missing_comment_author_rejected(self):
        client = FakeIssue([{"id": 1, "body": "x"}])
        with self.assertRaisesRegex(JournalStop, "author"):
            read_stable_history(client)

    def test_write_acknowledgement_mismatch_fail_closed(self):
        client = FakeIssue()
        client.bad_receipt = True
        with self.assertRaisesRegex(JournalStop, "acknowledgement"):
            run_once(fixture(), client, admit_post=True, env=gate_env())
        self.assertEqual(len(client.posts), 1)  # Real post MAY have happened.
        self.assertEqual(run_once(fixture(), client)["action"], "NOOP")

    def test_receipt_excludes_timestamps_and_untrusted_names(self):
        obs = fixture()
        obs["state"]["ci"][0]["name"] = "malicious\n@everyone"
        body = render_receipt(obs, fingerprint(obs))
        self.assertNotIn("malicious", body)
        self.assertNotIn("@everyone", body)
        self.assertNotIn("observed_utc", body)
        self.assertIn("Autonomous AI dispatch: **OFF**", body)

    def test_client_rejects_out_of_scope_request_before_network(self):
        client = IssueClient("fake", opener=lambda *args, **kwargs: None)
        with self.assertRaisesRegex(JournalStop, "outside"):
            client._request("POST", "/repos/ClubBoss/sharky-standalone-direction/issues/224/comments", {"body": "bad"})
        with self.assertRaisesRegex(JournalStop, "outside"):
            client._request("PATCH", "/repos/ClubBoss/sharky-standalone-direction/issues/356", {"state": "closed"})


if __name__ == "__main__":
    unittest.main()
