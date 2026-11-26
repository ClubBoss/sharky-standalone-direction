"""Local stdlib tests for the unsigned release dry run (no Flutter or Xcode)."""

import base64
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
GOOD = {
    "CFBundleIdentifier": "com.example.pokerAnalyzer",
    "CFBundleShortVersionString": "1.0.0",
    "CFBundleVersion": "1",
    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
    "CFBundleDevelopmentRegion": "en",
    "CFBundleLocalizations": ["en"],
    "UIDeviceFamily": [1],
}


class ReleaseDryRunTest(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(dir=ROOT)
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.plist = self.root / "build/ios/iphoneos/Runner.app/Info.plist"
        self.plist.parent.mkdir(parents=True)
        self.config = self.root / "ios/Flutter/Generated.xcconfig"
        self.config.parent.mkdir(parents=True)
        self.write_plist()
        self.write_defines("FLUTTER_VERSION=3.35.0")

    def write_plist(self, **overrides):
        self.plist.write_bytes(plistlib.dumps({**GOOD, **overrides}, fmt=plistlib.FMT_BINARY))

    def write_defines(self, *defines):
        encoded = [base64.b64encode(define.encode()).decode() for define in defines]
        self.config.write_text("DART_DEFINES=" + ",".join(encoded) + "\n")

    def check(self):
        return subprocess.run(
            [sys.executable, str(HERE / "check_release_profile_v1.py"), str(self.plist),
             "--xcconfig", str(self.config), "--version", "1.0.0+1"],
            capture_output=True, text=True,
        )

    def test_valid_binary_plist_and_sdk_define(self):
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(result.stdout.splitlines()), 5)
        self.assertTrue(all(line.startswith("PASS:") for line in result.stdout.splitlines()))

    def test_bad_plist_values(self):
        for key, value in {
            "UISupportedInterfaceOrientations": ["UIInterfaceOrientationLandscapeLeft"],
            "UISupportedInterfaceOrientations~iphone": ["UIInterfaceOrientationLandscapeLeft"],
            "CFBundleIdentifier": "com.example.other",
            "CFBundleVersion": "2",
            "UIDeviceFamily": [1, 2],
            "CFBundleLocalizations": ["en", "ru"],
            "NSBonjourServices": ["_dartVmService._tcp"],
            "NSLocalNetworkUsageDescription": "Allow Flutter tools to debug",
            "goalRouteV1": True,
        }.items():
            with self.subTest(key=key):
                self.write_plist(**{key: value})
                result = self.check()
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(len(result.stdout.splitlines()), 5)
                self.assertIn("FAIL:", result.stdout)

    def test_custom_dart_define(self):
        self.write_defines("FLUTTER_VERSION=3.35.0", "goalRouteV1=true")
        self.assertNotEqual(self.check().returncode, 0)

    def test_missing_and_malformed_inputs(self):
        self.config.write_text("DART_DEFINES=not-base64!\n")
        self.assertNotEqual(self.check().returncode, 0)
        self.config.unlink()
        self.assertNotEqual(self.check().returncode, 0)
        self.plist.unlink()
        self.assertNotEqual(self.check().returncode, 0)

    def test_shell_build_command_and_failure_propagation(self):
        tools = self.root / "tools/release"
        tools.mkdir(parents=True)
        for name in ("ios_release_dryrun_v1.sh", "check_release_profile_v1.py"):
            shutil.copy2(HERE / name, tools / name)
        (self.root / "pubspec.yaml").write_text("name: fixture\nversion: 1.0.0+1\n")
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        flutter = bin_dir / "flutter"
        flutter.write_text(
            '#!/bin/sh\n[ "$*" = "build ios --release --no-codesign" ] || exit 99\n'
            '[ -z "${DART_DEFINES:-}" ] || exit 98\nexit "$STUB_BUILD_STATUS"\n'
        )
        flutter.chmod(0o755)
        env = {**os.environ, "PATH": str(bin_dir) + os.pathsep + os.environ["PATH"],
               "DART_DEFINES": "old-debug-defines", "STUB_BUILD_STATUS": "0"}
        command = [str(tools / "ios_release_dryrun_v1.sh")]
        result = subprocess.run(command, cwd=bin_dir, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Version: 1.0.0\nBuild number: 1", result.stdout)
        self.assertIn("Unsigned app size:", result.stdout)
        # A pre-existing valid bundle cannot turn a failed build into success.
        env["STUB_BUILD_STATUS"] = "42"
        result = subprocess.run(command, cwd=bin_dir, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 42)
        self.assertNotIn("Unsigned app size:", result.stdout)
        env["STUB_BUILD_STATUS"] = "0"
        self.write_plist(CFBundleIdentifier="incorrect")
        result = subprocess.run(command, cwd=bin_dir, env=env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("Unsigned app size:", result.stdout)


if __name__ == "__main__":
    unittest.main()
