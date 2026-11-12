"""Synthetic packaging regressions, not rendered browser evidence."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location('packager', Path(__file__).with_name('package_sharky_evidence_v1.py'))
PACKAGER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PACKAGER)
SHA = 'a' * 40

class ReferenceScopeTests(unittest.TestCase):
    def package(self, change=None):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            proof_dir = root / 'proof'
            proof_dir.mkdir()
            fixture = b'SYNTHETIC hash fixture; not a rendered PNG'
            (proof_dir / 'iphone14_pro-home-fit.png').write_bytes(fixture)
            proof = {'schema': PACKAGER.SOURCE_SCHEMA, 'target_sha': SHA,
                     'exact_sha_identity': 'PASS', 'fit_mode': 'PASS', 'interaction': 'PASS',
                     'profiles': {'iphone14_pro': {'measured_inner': [393, 852], 'product_sha': SHA,
                     'screenshot': 'iphone14_pro-home-fit.png', 'screenshot_sha256': hashlib.sha256(fixture).hexdigest()}}}
            if change:
                change(proof)
            (proof_dir / 'browser-proof.json').write_text(json.dumps(proof))
            argv = ['packager', '--proof-dir', str(proof_dir), '--out-dir', str(root / 'out'),
                    '--repository', 'ClubBoss/sharky-standalone-direction', '--candidate-sha', SHA,
                    '--base-sha', 'b' * 40, '--run-id', '1', '--tooling-sha', SHA]
            with patch('sys.argv', argv):
                return PACKAGER.main()

    def test_reference_profile_passes(self):
        self.assertEqual(self.package(), 0)

    def test_old_viewport_fails(self):
        self.assertEqual(self.package(lambda p: p['profiles']['iphone14_pro'].update(measured_inner=[402, 874])), 1)

    def test_extra_profile_fails(self):
        self.assertEqual(self.package(lambda p: p['profiles'].update(compact=copy.deepcopy(p['profiles']['iphone14_pro']))), 1)

    def test_hash_mismatch_still_fails(self):
        self.assertEqual(self.package(lambda p: p['profiles']['iphone14_pro'].update(screenshot_sha256='0' * 64)), 1)

    def test_interaction_failure_still_fails(self):
        self.assertEqual(self.package(lambda p: p.update(interaction='FAIL')), 1)

if __name__ == '__main__':
    unittest.main()
