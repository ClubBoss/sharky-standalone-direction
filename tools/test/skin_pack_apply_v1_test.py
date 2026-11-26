#!/usr/bin/env python3
"""Exercise the CLI against a scratch repository, never change app assets."""
import json
import runpy
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = Path('tools/skin_pack_apply_v1.py')
SOURCE = Path('lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart')
CONTRACT = Path('docs/plan/SKIN_LAYER_v1.md')
SLOTS = Path('assets/skin_v1')
SAMPLE = ROOT / 'test/fixtures/skin_pack_sample_v1'
VARIANT = ROOT / 'test/ui_v2/skin/act0_skin_tokens_rehearsal_v1.dart'
IMPORTER = runpy.run_path(str(ROOT / SCRIPT))


class SkinPackTest(unittest.TestCase):
    def setUp(self):
        scratch = tempfile.TemporaryDirectory()
        self.addCleanup(scratch.cleanup)
        self.repo = Path(scratch.name)
        for path in (SCRIPT, SOURCE, CONTRACT, SLOTS / 'README.md'):
            dest = self.repo / path
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / path, dest)
        self.pack = self.repo / 'pack'
        shutil.copytree(SAMPLE, self.pack)

    def invoke(self, mode):
        return subprocess.run([sys.executable, str(self.repo / SCRIPT), mode, str(self.pack)],
                              capture_output=True, text=True, cwd=self.repo)

    def snapshot(self):
        return {path.relative_to(self.repo): path.read_bytes()
                for base in (self.repo / SOURCE, self.repo / SLOTS)
                for path in ([base] if base.is_file() else base.iterdir())}

    def test_check_is_read_only_and_apply_matches_rehearsal(self):
        before = self.snapshot()
        result = self.invoke('--check')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), before)
        result = self.invoke('--apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        source = (self.repo / SOURCE).read_text()
        # Compare B101 values, not formatting (e.g. 20 vs 20.0 after a future skin swap).
        names = set(IMPORTER['token_names']())
        fields = IMPORTER['declarations']
        spec = IMPORTER['spec']
        variant = fields(VARIANT.read_text())
        applied_fields = fields(source)
        for name in names:
            self.assertEqual(spec(applied_fields[name][2]).current,
                             spec(variant[name][2]).current, name)

        def outside_editable_values(text):
            for field in reversed(list(fields(text).values())):
                if field[1] in names - IMPORTER['FROZEN']:
                    text = text[:field.start(2)] + '<skin value>' + text[field.end(2):]
            return text

        self.assertEqual(outside_editable_values(source),
                         outside_editable_values(before[SOURCE].decode()))
        self.assertEqual((self.repo / SLOTS / 'README.md').read_bytes(), before[SLOTS / 'README.md'])
        for path in (self.pack / 'assets').iterdir():
            self.assertEqual((self.repo / SLOTS / path.name).read_bytes(), path.read_bytes())
        applied = self.snapshot()
        result = self.invoke('--apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.snapshot(), applied)

    def test_invalid_pack_reports_all_errors_and_never_writes(self):
        tokens = self.pack / 'tokens.json'
        values = json.loads(tokens.read_text())
        values.pop('background')
        values['tableGeometry'] = 123
        values['gapSm'] = True
        values['title']['fontWeight'] = 'bold'
        values['feltCenter'] = '#FFFFFFFF'
        tokens.write_text(json.dumps(values))
        assets = self.pack / 'assets'
        (assets / 'sharky_concerned.png').unlink()
        (assets / 'extra.png').write_bytes(b'not a PNG')
        shutil.copy2(assets / 'sharky_happy.png', assets / 'app_icon.png')
        before = self.snapshot()
        for mode in ('--check', '--apply'):
            result = self.invoke(mode)
            self.assertEqual(result.returncode, 1)
            for message in ('missing token key: background', 'unknown token key: tableGeometry',
                            'token gapSm: expected finite number', 'token title: expected TextStyle',
                            'token feltCenter: protected table token cannot change',
                            'missing asset file: sharky_concerned.png', 'unknown asset file: extra.png',
                            'asset app_icon.png: wrong image size 360x360; expected 1024x1024'):
                self.assertIn(message, result.stderr)
            self.assertEqual(self.snapshot(), before)

    def test_non_palette_values_are_applied_and_checked_again(self):
        tokens = self.pack / 'tokens.json'
        values = json.loads(tokens.read_text())
        values['gapSm'] = 10
        values['motion'] = 400
        values['motionCurve'] = 'linear'
        values['title']['fontSize'] = 29
        values['editorialDisplayFont'] = 'New Serif'
        values['navyStatShadow']['offset'] = [1, 11]
        tokens.write_text(json.dumps(values))
        result = self.invoke('--apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        source = (self.repo / SOURCE).read_text()
        for expected in ('gapSm = 10.0;', 'Duration(milliseconds: 400)', 'Curves.linear',
                         'fontSize: 29.0,', "editorialDisplayFont = 'New Serif';", 'Offset(1.0, 11.0)'):
            self.assertIn(expected, source)
        result = self.invoke('--check')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_duplicate_keys_and_bad_png_fail(self):
        tokens = self.pack / 'tokens.json'
        tokens.write_text(tokens.read_text().replace('{', '{"background": "#FF000000",', 1))
        (self.pack / 'assets' / 'sharky_neutral.png').write_bytes(b'bad')
        result = self.invoke('--check')
        self.assertEqual(result.returncode, 1)
        self.assertIn('duplicate key: background', result.stderr)
        self.assertIn('asset sharky_neutral.png: not a PNG', result.stderr)

    def test_apply_refuses_redirected_asset_destination(self):
        protected = self.repo / 'protected.txt'
        protected.write_text('must remain unchanged')
        (self.repo / SLOTS / 'app_icon.png').symlink_to(protected)
        before = (self.repo / SOURCE).read_bytes()
        result = self.invoke('--apply')
        self.assertEqual(result.returncode, 1)
        self.assertIn('refusing redirected destination: assets/skin_v1/app_icon.png', result.stderr)
        self.assertEqual(protected.read_text(), 'must remain unchanged')
        self.assertEqual((self.repo / SOURCE).read_bytes(), before)


if __name__ == '__main__':
    unittest.main()
