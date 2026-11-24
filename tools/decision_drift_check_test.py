"""Exercise the checker against isolated Markdown fixtures."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("decision_drift_check.py").resolve()
REGISTRY = Path("docs/plan/RETIRED_DECISIONS_v1.md")


class DecisionDriftCheckTest(unittest.TestCase):
    def run_checker(self, content, fixture="docs/plan/fixture.md"):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "repo"
            registry = root / REGISTRY
            registry.parent.mkdir(parents=True)
            registry.write_bytes((SCRIPT.parents[1] / REGISTRY).read_bytes())
            document = root / fixture
            document.parent.mkdir(parents=True, exist_ok=True)
            document.write_text(content, encoding="utf-8")
            return subprocess.run(
                [sys.executable, str(SCRIPT), "--root", str(root)],
                capture_output=True,
                text=True,
                check=False,
            )

    def test_retired_phrase_fails(self):
        result = self.run_checker("3 tabs\n")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(
            result.stdout.strip(),
            "docs/plan/fixture.md:1 | NAV-3-TABS | 5 tabs kept (24.11, Codex option A)",
        )

    def test_retired_marker_allows_phrase(self):
        result = self.run_checker("RETIRED: 3 tabs\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "")

    def test_history_ends_at_next_peer_heading_in_audit_brief(self):
        fixture = "../l0-audit/lead/b00_fixture.md"
        result = self.run_checker(
            "History\n-------\n3 tabs\n### Nested\nThree tabs\n## Current\nthree tabs\n",
            fixture,
        )
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(len(result.stdout.splitlines()), 1)
        self.assertTrue(result.stdout.startswith(f"{fixture}:7 | NAV-3-TABS |"))

    def test_heading_in_code_does_not_hide_drift(self):
        result = self.run_checker("```md\n## History\n```\n3 tabs\n")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertTrue(result.stdout.startswith("docs/plan/fixture.md:4 | NAV-3-TABS |"))


if __name__ == "__main__":
    unittest.main()
