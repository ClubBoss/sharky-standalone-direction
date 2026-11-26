"""Stdlib tests for owner-day preflight; no Flutter, device or signing."""

from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest


HERE = Path(__file__).resolve().parent


class OwnerDayPreflightTest(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(dir=HERE.parents[1])
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        tools = self.root / "tools/release"
        tools.mkdir(parents=True)
        for name in ("owner_day_preflight_v1.py", "check_release_profile_v1.py"):
            shutil.copy2(HERE / name, tools / name)
        self.sheet = self.root / "docs/release/OWNER_DEVICE_DAY_v1.md"
        self.sheet.parent.mkdir(parents=True)
        self.sheet.write_text(
            "[phone checks](GRO_PHONE_CHECKLIST_v1.md)\n"
            "[report](../../tools/f1m_report_v1.py)\n"
        )
        self.doc = self.sheet.parent / "GRO_PHONE_CHECKLIST_v1.md"
        self.doc.write_text("Fixture checklist\n")
        self.script = self.root / "tools/f1m_report_v1.py"
        self.script.touch()
        (self.root / "pubspec.yaml").write_text("version: 1.0.0+1\n")
        self.config = self.root / "ios/Flutter/Generated.xcconfig"
        self.config.parent.mkdir(parents=True)
        self.config.write_text("DART_DEFINES=\n")
        self.plist = self.root / "build/ios/iphoneos/Runner.app/Info.plist"
        self.plist.parent.mkdir(parents=True)
        self.plist.write_bytes(plistlib.dumps({
            "CFBundleIdentifier": "com.example.pokerAnalyzer",
            "CFBundleShortVersionString": "1.0.0",
            "CFBundleVersion": "1",
            "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
            "CFBundleDevelopmentRegion": "en",
            "CFBundleLocalizations": ["en"],
            "UIDeviceFamily": [1],
        }))

    def check(self):
        return subprocess.run(
            [sys.executable, str(self.root / "tools/release/owner_day_preflight_v1.py")],
            cwd=self.root / "docs", capture_output=True, text=True,
        )

    def test_ready(self):
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("READY: owner device day prerequisites", result.stdout.splitlines())

    def test_missing_linked_file(self):
        for target in (self.doc, self.script):
            with self.subTest(target=target.name):
                content = target.read_bytes()
                target.unlink()
                result = self.check()
                self.assertEqual(result.returncode, 1)
                self.assertIn(f"NOT READY: {target.relative_to(self.root)}", result.stdout.splitlines())
                self.assertIn("READY: unsigned release profile", result.stdout.splitlines())
                self.assertIn("NOT READY: owner device day prerequisites", result.stdout.splitlines())
                target.write_bytes(content)

    def test_release_profile_failure(self):
        (self.root / "pubspec.yaml").write_text("version: 1.0.0+2\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("NOT READY: unsigned release profile", result.stdout.splitlines())
        self.assertIn("NOT READY: owner device day prerequisites", result.stdout.splitlines())

    def test_missing_profile_input(self):
        self.config.unlink()
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("NOT READY: unsigned release profile", result.stdout.splitlines())


if __name__ == "__main__":
    unittest.main()
