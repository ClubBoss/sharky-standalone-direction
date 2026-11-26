#!/usr/bin/env python3
"""Designer CLI checks against temporary copies of the B111 sample pack."""
import base64
import json
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'tools/skin_pack_preview_v1.py'
SAMPLE = ROOT / 'test/fixtures/skin_pack_sample_v1'


class SkinPackPreviewTest(unittest.TestCase):
    def setUp(self):
        scratch = tempfile.TemporaryDirectory()
        self.addCleanup(scratch.cleanup)
        self.directory = Path(scratch.name)
        self.pack = self.directory / 'pack'
        shutil.copytree(SAMPLE, self.pack)
        self.out = self.directory / 'skin_pack_preview.html'
        # B101's sample is not an approved AA palette. Fix its three B112
        # failures only in this scratch pack to exercise the positive path.
        self.set_tokens(bad='#FFFFB0A0', editorialNeedsReviewFg='#FFF2E5CD',
                        editorialNeedsReviewBg='#FF19283D')

    def set_tokens(self, **changes):
        path = self.pack / 'tokens.json'
        values = json.loads(path.read_text())
        values.update(changes)
        path.write_text(json.dumps(values))

    def invoke(self, default_out=False):
        args = [sys.executable, str(SCRIPT), str(self.pack)]
        if not default_out:
            args += ['--out', str(self.out)]
        result = subprocess.run(args, capture_output=True, text=True, cwd=self.directory)
        self.assertTrue(self.out.is_file(), result.stderr)
        return result, self.out.read_text()

    def test_good_pack_is_self_contained(self):
        result, sheet = self.invoke(default_out=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('65/65 contrast pairs passed', sheet)
        self.assertIn('test/ui_v2/skin_contrast_guard_v1_test.dart', sheet)
        self.assertEqual(sheet.count('<td class="pass">PASS</td>'), 65)
        values = json.loads((self.pack / 'tokens.json').read_text())
        for name, value in values.items():
            self.assertIn(f'<strong>{name}</strong>', sheet)
            if isinstance(value, str) and value.startswith('#'):
                self.assertIn(f'<code>{value}</code>', sheet)
        self.assertIn('style="background:#A4DCD51A"', sheet)
        self.assertIn('<strong>courseProgressFill</strong>', sheet)
        images = dict((name, base64.b64decode(data)) for data, name in
                      re.findall(r'<img src="data:image/png;base64,([^"]+)" alt="([^"]+)"', sheet))
        self.assertEqual(images, {p.name: p.read_bytes() for p in (self.pack / 'assets').iterdir()})

    def test_low_contrast_pack_fails_unrounded_threshold(self):
        self.set_tokens(onAccent='#FF777777', accent='#FFFFFFFF')
        result, sheet = self.invoke()
        self.assertEqual(result.returncode, 1)
        self.assertIn('0 validation errors', sheet)
        self.assertIn('onAccent/accent</th><td>4.4781:1</td><td>4.5:1</td>'
                      '<td class="fail">FAIL</td>', sheet)

    def test_missing_asset_is_listed_and_fails_validation(self):
        (self.pack / 'assets' / 'sharky_concerned.png').unlink()
        result, sheet = self.invoke()
        self.assertEqual(result.returncode, 1)
        self.assertIn('missing asset file: sharky_concerned.png', sheet)
        self.assertIn('<strong>sharky_concerned.png</strong><p>360 × 360 px</p>'
                      '<p class="fail">missing</p>', sheet)
        self.assertEqual(sheet.count('src="data:image/png;base64,'), 4)
        self.assertIn('65/65 contrast pairs passed', sheet)

    def test_alpha_compositing_and_alias(self):
        self.set_tokens(onSurface='#00FFFFFF', background='#FF000000',
                        accent='#FFFFFFFF', accentSoft='#80FFFFFF',
                        academyAccent='#FF30465D')
        result, sheet = self.invoke()
        self.assertEqual(result.returncode, 1)
        self.assertIn('onSurface/background</th><td>1.0000:1</td><td>4.5:1</td>'
                      '<td class="fail">FAIL</td>', sheet)
        self.assertIn('accent/accentSoft@background</th><td>3.9494:1</td><td>4.5:1</td>'
                      '<td class="fail">FAIL</td>', sheet)
        self.assertIn('courseProgressFill/courseProgressTrack</th><td>1.0000:1</td>'
                      '<td>3:1</td><td class="fail">FAIL</td>', sheet)

    def test_translucent_backing_fails_instead_of_assuming_opaque(self):
        self.set_tokens(background='#80101B2D')
        result, sheet = self.invoke()
        self.assertEqual(result.returncode, 1)
        self.assertIn('onSurface/background</th><td>Contrast requires an opaque backing surface</td>'
                      '<td>4.5:1</td><td class="fail">FAIL</td>', sheet)


if __name__ == '__main__':
    unittest.main()
