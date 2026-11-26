#!/usr/bin/env python3
"""Exercise the B118 CLI against a scratch repository, not the real skin."""

import importlib.util
import json
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = Path('tools/skin_drop_in_dryrun_v1.py')
SOURCE = Path('lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart')
SLOTS = Path('assets/skin_v1')
GUARD = Path('test/guards/act0_skin_literal_guard_v1_test.dart')
TABLE = SOURCE.parent.parent / 'act0_table_geometry_v1.dart'
SAMPLE = ROOT / 'test/fixtures/skin_pack_sample_v1'


class SkinDropInTest(unittest.TestCase):
    def setUp(self):
        output = ROOT / 'out'
        output.mkdir(exist_ok=True)
        scratch = tempfile.TemporaryDirectory(prefix='b118-test-', dir=output)
        self.addCleanup(scratch.cleanup)
        self.repo = Path(scratch.name)
        for path in (SCRIPT, Path('tools/skin_pack_apply_v1.py'),
                     Path('tools/affected_tests_v1.py'), SOURCE, GUARD, TABLE,
                     Path('docs/plan/SKIN_LAYER_v1.md'), Path('pubspec.yaml')):
            self.copy(ROOT / path, self.repo / path)
        # B117 is a separate package; use its actual implementation, not a stub.
        preview = ROOT / 'tools/skin_pack_preview_v1.py'
        if not preview.is_file():
            spec = importlib.util.find_spec('skin_pack_preview_v1')
            self.assertIsNotNone(spec, 'B117 must be available for integration tests')
            preview = Path(spec.origin)
        self.copy(preview, self.repo / 'tools/skin_pack_preview_v1.py')
        shutil.copytree(ROOT / SLOTS, self.repo / SLOTS)
        self.pack = self.repo / 'pack'
        shutil.copytree(SAMPLE, self.pack)
        # The unapproved B101 palette fails three B112 pairs. Use B117's
        # contrast-corrected scratch fixture to exercise the success path.
        self.set_tokens(bad='#FFFFB0A0', editorialNeedsReviewFg='#FFF2E5CD',
                        editorialNeedsReviewBg='#FF19283D')
        package = re.search(r'^name:\s*(\w+)', (self.repo / 'pubspec.yaml').read_text(), re.M)[1]
        (self.repo / 'test/skin_test.dart').write_text(
            f"import 'package:{package}/{SOURCE.as_posix()[4:]}';\n")
        (self.repo / 'test/term_test.dart').write_text('void main() { editorialNeedsReviewFg; }\n')
        (self.repo / 'test/unrelated_test.dart').write_text('void main() {}\n')

    def copy(self, source, destination):
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)

    def set_tokens(self, **changes):
        path = self.pack / 'tokens.json'
        values = json.loads(path.read_text())
        values.update(changes)
        path.write_text(json.dumps(values))

    def snapshot(self):
        # out/ contains only the intentionally retained local HTML report.
        return {p.relative_to(self.repo): p.read_bytes() for p in self.repo.rglob('*')
                if p.is_file() and p.relative_to(self.repo).parts[0] != 'out'}

    def invoke(self, *args):
        result = subprocess.run([sys.executable, '-B', str(self.repo / SCRIPT),
                                 str(self.pack), *args], cwd=self.repo,
                                capture_output=True, text=True)
        preview = re.search(r'^Preview HTML: (.+)$', result.stdout, re.M)
        self.assertIsNotNone(preview, result.stdout + result.stderr)
        sheet = Path(preview[1])
        self.assertTrue(sheet.is_file())
        self.assertEqual(list((self.repo / 'out').iterdir()), [sheet])
        return result, sheet.read_text()

    def test_good_pack_is_read_only_and_reports_affected_tests(self):
        before = self.snapshot()
        result, sheet = self.invoke()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('65/65 contrast pairs passed', sheet)
        self.assertIn(str(SOURCE), result.stdout)
        self.assertIn(str(SLOTS / 'sharky_neutral.png'), result.stdout)
        self.assertIn('test/skin_test.dart', result.stdout)
        self.assertIn('test/term_test.dart', result.stdout)
        self.assertNotIn('test/unrelated_test.dart', result.stdout)
        self.assertIn('Modern Table paths unchanged', result.stdout)
        self.assertEqual(self.snapshot(), before)

    def test_low_contrast_fails_before_apply_even_with_keep(self):
        self.set_tokens(onAccent='#FF777777', accent='#FFFFFFFF')
        before = self.snapshot()
        result, sheet = self.invoke('--keep')
        self.assertEqual(result.returncode, 1)
        self.assertIn('0 validation errors', sheet)
        self.assertIn('onAccent/accent</th><td>4.4781:1', sheet)
        self.assertNotIn('Would-change files', result.stdout)
        self.assertEqual(self.snapshot(), before)

    def test_protected_table_token_fails(self):
        self.set_tokens(feltCenter='#FFFFFFFF')
        before = self.snapshot()
        result, sheet = self.invoke('--keep')
        self.assertEqual(result.returncode, 1)
        self.assertIn('token feltCenter: protected table token cannot change', sheet)
        self.assertNotIn('Would-change files', result.stdout)
        self.assertEqual(self.snapshot(), before)

    def test_keep_applies_only_reported_files(self):
        before = self.snapshot()
        result, _ = self.invoke('--keep')
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        after = self.snapshot()
        changed = {path for path in before.keys() | after.keys()
                   if before.get(path) != after.get(path)}
        reported = result.stdout.split('Would-change files', 1)[1].split('B103 affected tests', 1)[0]
        self.assertEqual(changed, {Path(line.strip()) for line in reported.splitlines()[1:]})
        self.assertIn(SOURCE, changed)
        self.assertNotIn(TABLE, changed)
        for asset in (self.pack / 'assets').iterdir():
            self.assertEqual((self.repo / SLOTS / asset.name).read_bytes(), asset.read_bytes())

    def test_protected_table_path_diff_fails_closed(self):
        # Simulate a future importer accidentally writing a table owner. The
        # path guard must reject it independently of B111 token validation.
        before = self.snapshot()
        code = f"""
import sys
from pathlib import Path
sys.path.insert(0, 'tools')
import skin_drop_in_dryrun_v1 as dryrun
original = dryrun.apply_in_scratch
def unexpected_write(pack, scratch):
    original(pack, scratch)
    with (scratch / {TABLE.as_posix()!r}).open('a') as file:
        file.write('// unintended table edit')
dryrun.apply_in_scratch = unexpected_write
sys.exit(dryrun.main())
"""
        result = subprocess.run([sys.executable, '-B', '-c', code, str(self.pack), '--keep'],
                                cwd=self.repo, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn('protected Modern Table paths changed: ' + str(TABLE), result.stderr)
        self.assertEqual(self.snapshot(), before)

    def test_redirected_destination_fails_without_writes(self):
        target = self.repo / 'protected.txt'
        target.write_text('protected')
        (self.repo / SLOTS / 'sharky_neutral.png').symlink_to(target)
        before = self.snapshot()
        result, _ = self.invoke('--keep')
        self.assertEqual(result.returncode, 1)
        self.assertIn('refusing redirected destination', result.stderr)
        self.assertEqual(self.snapshot(), before)


if __name__ == '__main__':
    unittest.main()
