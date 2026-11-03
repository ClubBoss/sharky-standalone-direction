"""Exercise the real summary under dependency/report failure and optional input absence."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('coverage_informational_summary.sh').resolve()


class CoverageTruthTest(unittest.TestCase):
    def check_result(self, *, pub='success', l2='success', l3='success',
                     result='SKIP', job='success', files=('l2',), expected='PASS'):
        with tempfile.TemporaryDirectory() as root:
            reports = Path(root, 'build/reports')
            reports.mkdir(parents=True)
            for level in files:
                (reports / f'{level}_report.md').write_text(f'# {level} metrics\n')
            summary = Path(root, 'summary.md')
            env = dict(os.environ, PUB_OUTCOME=pub, L2_OUTCOME=l2,
                       L3_OUTCOME=l3, L3_RESULT=result, COVERAGE_JOB_STATUS=job,
                       GITHUB_STEP_SUMMARY=str(summary))
            run = subprocess.run(['bash', str(SCRIPT)], cwd=root, env=env,
                                 capture_output=True, text=True)
            self.assertEqual(run.returncode, 0 if expected == 'PASS' else 1, run.stderr)
            text = summary.read_text()
            self.assertIn(f'Informational coverage: {expected}', text)
            self.assertEqual(text, (reports / 'coverage_status.md').read_text())
            self.assertIn('required Test Authority Lanes', text)
            return text

    def test_no_l3_input_is_explicit_skip(self):
        self.assertIn('L3: SKIP', self.check_result())

    def test_both_reports_pass(self):
        self.assertIn('L3: PASS', self.check_result(result='PASS', files=('l2', 'l3')))

    def test_pub_failure_preserves_failure_and_skipped_reports(self):
        text = self.check_result(pub='failure', l2='skipped', l3='skipped',
                                 result='', job='failure', files=(), expected='FAIL')
        self.assertIn('Dependency resolution: FAIL', text)
        self.assertIn('L2: SKIP', text)

    def test_successful_command_without_report_is_failure(self):
        self.check_result(files=(), expected='FAIL')
        self.check_result(result='PASS', expected='FAIL')

    def test_l3_failure_even_with_partial_file_stays_failed(self):
        self.check_result(l3='failure', result='', job='failure',
                          files=('l2', 'l3'), expected='FAIL')

    def test_setup_failure_or_cancellation_never_passes(self):
        for status in ('failure', 'cancelled'):
            self.check_result(pub='skipped', l2='skipped', l3='skipped',
                              job=status, files=(), expected='FAIL')


if __name__ == '__main__':
    unittest.main()
