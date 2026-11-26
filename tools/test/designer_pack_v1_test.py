"""Exercise the designer sheet with local capture fixtures (no Flutter needed)."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from tools import designer_pack_v1 as pack


class DesignerPackTest(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.compact = self.root / "compact"
        self.world = self.root / "v9/w01"
        self.output = self.root / "designer pack"
        self.compact.mkdir()
        self.world.mkdir(parents=True)
        self.inventory = self.root / "COMPONENT_INVENTORY_v1.md"
        self.inventory.write_text(
            "# Fixture\n\n## Components\n"
            "| Component | Source | Props (data) | States | Screens |\n"
            "|---|---|---|---|---|\n"
            "| PrimaryButton | Kit | label | pressed | Ho |\n"
            "| FeedbackPanel | New | grade & reason | correct · wrong | Ta |\n"
            "| <Custom> | Kit | value | disabled | Se |\n\n"
            "## Table skin pieces\n| Piece | States | Screens |\n"
            "|---|---|---|\n| Seat plate | occupied | Ta |\n",
            encoding="utf-8",
        )
        self.write_json(self.compact / "manifest.json", {
            "git_commit": "fixture-head", "device": "compact",
            "output_files": ["output/screen_review/current/compact.home.png"],
        })
        self.write_json(self.world / "row.json", {
            "world": 1, "screens": ["lesson_start.png", "decision_seat_table_family.png"],
            "wrong_answer_repair": "ok", "overflow_errors": [], "exceptions": [],
        })
        self.png(self.compact / "compact.home.png")
        self.png(self.world / "lesson_start.png")
        self.png(self.world / "decision_seat_table_family.png")

    @staticmethod
    def write_json(path, data):
        path.write_text(json.dumps(data), encoding="utf-8")

    @staticmethod
    def png(path):
        # Capture transport checks the PNG signature; no real image is needed.
        path.write_bytes(pack.PNG_SIGNATURE + b"fixture")

    def run_pack(self):
        passed = pack.render(self.compact, self.world.parent, self.inventory,
                             self.output, last_world=1)
        return passed, (self.output / "index.html").read_text(encoding="utf-8")

    def test_every_fixture_screen_and_component_and_missing_expected_screen(self):
        passed, page = self.run_pack()
        self.assertFalse(passed)  # three captures cannot satisfy the full pack
        for path in ("../compact/compact.home.png", "../v9/w01/lesson_start.png",
                     "../v9/w01/decision_seat_table_family.png"):
            self.assertIn(f'src="{path}"', page)
        for text in ("PrimaryButton", "FeedbackPanel", "&lt;Custom&gt;", "Seat plate",
                     "grade &amp; reason", "Decision Seat Table Family", "fixture-head"):
            self.assertIn(text, page)
        self.assertNotIn("<Custom>", page)
        self.assertIn("Missing or invalid screen:", page)
        self.assertIn("compact.review.png", page)
        self.assertIn("wrong_feedback.png", page)
        self.assertIn("MISSING / INVALID PNG", page)

    def test_manifest_listed_screen_removed_is_reported_without_broken_image(self):
        (self.world / "decision_seat_table_family.png").unlink()
        passed, page = self.run_pack()
        self.assertFalse(passed)
        self.assertIn(f"Missing or invalid screen: {self.world / 'decision_seat_table_family.png'}", page)
        self.assertNotIn('src="../v9/w01/decision_seat_table_family.png"', page)

    def test_invalid_png_and_stale_capture_are_flagged(self):
        (self.compact / "compact.home.png").write_bytes(b"not a PNG")
        passed = pack.render(self.compact, self.world.parent, self.inventory,
                             self.output, last_world=1, checkout_commit="new-head")
        page = (self.output / "index.html").read_text(encoding="utf-8")
        self.assertFalse(passed)
        self.assertIn("does not match checkout new-head", page)
        self.assertIn(f"Missing or invalid screen: {self.compact / 'compact.home.png'}", page)
        self.assertNotIn('src="../compact/compact.home.png"', page)

    def test_complete_capture_inputs_and_rerun(self):
        compact_names = [f"compact.{surface}.png" for surface in pack.COMPACT_SURFACES]
        world_names = [f"{state}.png" for state in pack.V9_REQUIRED] + ["decision_seat_table_family.png"]
        for folder, names in ((self.compact, compact_names), (self.world, world_names)):
            for name in names:
                self.png(folder / name)
        self.write_json(self.compact / "manifest.json", {"output_files": compact_names})
        row = json.loads((self.world / "row.json").read_text())
        row["screens"] = world_names
        self.write_json(self.world / "row.json", row)
        passed, page = self.run_pack()
        self.assertTrue(passed)
        self.assertIn("Capture issues (0)", page)
        self.assertEqual(page.count('src="'), len(compact_names) + len(world_names))
        # The previous sheet must not hide a missing capture on the next run.
        (self.compact / compact_names[0]).unlink()
        passed, page = self.run_pack()
        self.assertFalse(passed)
        self.assertNotIn(f'src="../compact/{compact_names[0]}"', page)

    def test_cli_writes_report_and_returns_nonzero_for_missing_capture(self):
        result = subprocess.run([
            sys.executable, str(Path(pack.__file__).resolve()),
            "--compact-dir", str(self.compact), "--v9-dir", str(self.world.parent),
            "--inventory", str(self.inventory), "--output-dir", str(self.output),
            "--last-world", "1",
        ], capture_output=True, text=True)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertTrue((self.output / "index.html").is_file())
        self.assertIn("capture issues", result.stdout)


if __name__ == "__main__":
    unittest.main()
