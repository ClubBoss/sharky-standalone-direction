"""Static trust boundaries for the *proposed* default-branch-only writer."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
M2 = ROOT / ".github/workflows/sharky-autopilot-journal.yml"
M1 = ROOT / ".github/workflows/sharky-autopilot-observer.yml"


class WorkflowTrustTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.workflow = M2.read_text()
        cls.observer = M1.read_text()

    def test_never_runs_pr_code_with_write_token(self):
        self.assertNotIn("pull_request:", self.workflow)
        self.assertNotIn("pull_request_target:", self.workflow)
        self.assertIn("persist-credentials: false", self.workflow)

    def test_exact_repo_main_default_branch_only(self):
        self.assertIn("github.repository == 'ClubBoss/sharky-standalone-direction'", self.workflow)
        self.assertIn("github.ref == 'refs/heads/main'", self.workflow)
        self.assertIn("github.event_name == 'workflow_dispatch'", self.workflow)
        self.assertIn("github.event_name == 'schedule'", self.workflow)
        self.assertIn("runs-on: ubuntu-latest", self.workflow)
        self.assertNotIn("self-hosted", self.workflow.split("jobs:", 1)[1])

    def test_one_serial_writer_with_scoped_permission(self):
        self.assertIn("group: sharky-autopilot-journal-global", self.workflow)
        self.assertIn("cancel-in-progress: false", self.workflow)
        self.assertEqual(self.workflow.count("issues: write"), 1)
        self.assertIn("SHARKY_M2_POST_OWNER_ADMITTED: YES_AFTER_INDEPENDENT_REVIEW", self.workflow)
        self.assertIn("journal_issue_runner.py", self.workflow)

    def test_m1_observer_remains_read_only(self):
        self.assertIn("issues: read", self.observer)
        self.assertNotIn("issues: write", self.observer)
        self.assertNotIn("journal_issue_runner.py", self.observer)


if __name__ == "__main__":
    unittest.main()
