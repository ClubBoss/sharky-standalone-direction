#!/usr/bin/env python3
"""Negative packaging controls; synthetic fixtures are not browser/native proof."""

import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "evidence", ROOT / "tools/package_sharky_evidence_v1.py"
)
EVIDENCE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(EVIDENCE)
SHA = "a" * 40


class ScopedEvidenceTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.proof_dir = Path(self.temp.name) / "proof"
        self.proof_dir.mkdir()
        self.proof = self.make_proof(EVIDENCE.DEVELOPMENT_SCOPE)

    def write_capture(self, name, data):
        # Deliberately tagged fixture bytes; this tests packaging, not rendering.
        (self.proof_dir / name).write_bytes(data)
        return hashlib.sha256(data).hexdigest()

    def make_proof(self, scope):
        profiles = EVIDENCE.expected_profiles(scope)
        proof = {
            "schema": EVIDENCE.SOURCE_SCHEMA,
            "capture_scope": scope,
            "language": "en",
            "browser_language": "en-US",
            "target_sha": SHA,
            "terminal_classification": "PASS",
            "exact_sha_identity": "PASS",
            "fit_mode": "PASS",
            "interaction": "PASS",
            "profiles": {},
            "console_overflow_signals": {},
        }
        for name, dimensions in profiles.items():
            home = f"{name}-home-fit.png"
            theory = f"{name}-runner-theory.png"
            proof["profiles"][name] = {
                "expected": dimensions,
                "measured_inner": dimensions,
                "product_sha": SHA,
                "screenshot": home,
                "screenshot_sha256": self.write_capture(home, b"fixture-home"),
            }
            proof["console_overflow_signals"][name] = {
                "screenshot": theory,
                "screenshot_sha256": self.write_capture(theory, b"fixture-theory"),
            }
        name = next(iter(profiles))
        proof["interaction_details"] = {
            key: self.write_capture(f"{name}-live-{phase}.png", value)
            for phase, key, value in (
                ("before", "before_sha256", b"fixture-before"),
                ("after", "after_sha256", b"fixture-after"),
                ("stable", "stable_sha256", b"fixture-after"),
            )
        }
        return proof

    def checks(self, proof=None, scope=EVIDENCE.DEVELOPMENT_SCOPE):
        return EVIDENCE.validate_proof(
            self.proof_dir, self.proof if proof is None else proof, SHA, scope
        )

    def test_exact_development_package_passes_and_names_only_14pro(self):
        self.assertTrue(all(self.checks().values()))
        (self.proof_dir / "browser-proof.json").write_text(json.dumps(self.proof))
        output = Path(self.temp.name) / "output"
        result = subprocess.run(
            [sys.executable, str(ROOT / "tools/package_sharky_evidence_v1.py"),
             "--proof-dir", str(self.proof_dir), "--out-dir", str(output),
             "--repository", "fixture/repository", "--candidate-sha", SHA,
             "--base-sha", "b" * 40, "--run-id", "1", "--tooling-sha", SHA],
            capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        manifest = json.loads((output / f"sharky-evidence-{SHA}/manifest.json").read_text())
        self.assertEqual([p["name"] for p in manifest["capture_profiles"]], ["iphone14_pro"])
        self.assertFalse(manifest["native_acceptance_claimed"])
        self.assertEqual(manifest["other_device_release_qualification"], "HOLD")

    def test_wrong_actual_or_declared_dimensions_are_rejected(self):
        for field in ("measured_inner", "expected"):
            with self.subTest(field=field):
                proof = copy.deepcopy(self.proof)
                proof["profiles"]["iphone14_pro"][field] = [402, 874]
                self.assertFalse(all(self.checks(proof).values()))

    def test_extra_or_missing_profile_is_rejected(self):
        proof = copy.deepcopy(self.proof)
        proof["profiles"]["compact"] = proof["profiles"]["iphone14_pro"]
        self.assertFalse(self.checks(proof)["profile_set"])
        proof["profiles"] = {}
        self.assertFalse(all(self.checks(proof).values()))

    def test_scope_schema_language_and_terminal_status_fail_closed(self):
        for field, invalid in (
            ("capture_scope", "arbitrary"), ("capture_scope", None),
            ("schema", "unknown"), ("language", "ru"),
            ("browser_language", "ru-RU"),
            ("terminal_classification", "ASSERTION_FAILURE"),
            ("fit_mode", "FAIL"), ("interaction", "FAIL"),
            ("exact_sha_identity", "FAIL"),
        ):
            with self.subTest(field=field, invalid=invalid):
                proof = copy.deepcopy(self.proof)
                proof[field] = invalid
                self.assertFalse(all(self.checks(proof).values()))

    def test_candidate_and_profile_sha_are_both_required(self):
        proof = copy.deepcopy(self.proof)
        proof["target_sha"] = "b" * 40
        self.assertFalse(self.checks(proof)["candidate_sha_matches_proof"])
        proof = copy.deepcopy(self.proof)
        proof["profiles"]["iphone14_pro"]["product_sha"] = "b" * 40
        self.assertFalse(all(self.checks(proof).values()))

    def test_tampered_capture_hash_is_rejected(self):
        (self.proof_dir / "iphone14_pro-home-fit.png").write_bytes(b"tampered")
        self.assertFalse(self.checks()["source_hashes_match"])

    def test_missing_home_overflow_or_interaction_receipt_is_rejected(self):
        for part in ("home", "overflow", "interaction"):
            with self.subTest(part=part):
                proof = copy.deepcopy(self.proof)
                if part == "home":
                    del proof["profiles"]["iphone14_pro"]["screenshot_sha256"]
                elif part == "overflow":
                    proof["console_overflow_signals"] = {}
                else:
                    del proof["interaction_details"]["stable_sha256"]
                self.assertFalse(self.checks(proof)["source_hashes_match"])

    def test_relabelled_or_missing_screenshot_is_rejected(self):
        proof = copy.deepcopy(self.proof)
        proof["profiles"]["iphone14_pro"]["screenshot"] = "compact-home-fit.png"
        self.assertFalse(self.checks(proof)["source_hashes_match"])
        (self.proof_dir / "iphone14_pro-live-after.png").unlink()
        self.assertFalse(self.checks()["source_hashes_match"])

    def test_historical_reader_cannot_satisfy_current_development_scope(self):
        historical = self.make_proof(EVIDENCE.HISTORICAL_SCOPE)
        del historical["capture_scope"]  # Older retained proof had no scope key.
        self.assertTrue(all(self.checks(historical, EVIDENCE.HISTORICAL_SCOPE).values()))
        self.assertFalse(all(self.checks(historical).values()))
        with self.assertRaises(ValueError):
            EVIDENCE.expected_profiles("arbitrary")

    def test_workflow_preserves_triggers_and_same_scenario_at_14pro(self):
        workflow = (ROOT / ".github/workflows/sharky-web-qa-mirror.yml").read_text()
        self.assertRegex(workflow, r"on:\n  pull_request:\n  push:\n    branches: \[main\]\n  workflow_dispatch:")
        self.assertEqual(re.findall(r"ACTION_EVIDENCE_DEVICE=(\w+)", workflow), ["iphone14_pro", "iphone14_pro"])
        self.assertEqual(workflow.count("--plain-name 'captures canonical W1 Action production states'"), 2)
        self.assertIn("--dart-define=ACTION_EVIDENCE_EXPECT_WAVE_A=false", workflow)
        self.assertEqual(workflow.count('--capture-scope "$CAPTURE_SCOPE"'), 3)

    def test_html_profile_and_probe_reject_unknown_scope_before_browser_start(self):
        html = (ROOT / "tools/sharky_phone_lab_v1.html").read_text()
        profile_source = re.search(r"const PROFILES = (\{[^\n]+\});", html).group(1)
        result = subprocess.run(
            ["node", "-e", f"console.log(JSON.stringify(({profile_source}).iphone14_pro))"],
            capture_output=True, text=True, check=True,
        )
        profile = json.loads(result.stdout)
        self.assertEqual([profile["w"], profile["h"]], [393, 852])
        result = subprocess.run(
            ["node", str(ROOT / "tools/sharky_phone_lab_browser_probe_v1.mjs"),
             "--capture-scope", "arbitrary"],
            capture_output=True, text=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Unsupported development capture scope", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
