#!/usr/bin/env python3
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

from ios_candidate_guard_v1 import CandidateSourceError, verify_candidate


class CandidateGuardTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='sharky-candidate-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)/'repo'
        self.root.mkdir()
        self.git('init', '-q')
        self.write('lib/main.dart', 'void main() {}\n')
        self.write('assets/room.png', b'committed image bytes')
        self.write('content/lesson.json', '{"lesson":"one"}')
        self.write('pubspec.lock', 'locked dependencies\n')
        self.write('.gitignore', '*.g.dart\n*.private\n')
        self.git('add', '.')
        self.git('-c', 'user.name=Candidate fixture', '-c', 'user.email=fixture@example.invalid',
                 'commit', '-qm', 'fixture')
        self.commit = self.git('rev-parse', 'HEAD').strip()
        self.app = Path(self.temp.name)/'Runner.app'
        self.bundle = self.app/'Frameworks/App.framework/flutter_assets'
        for relative in ('assets/room.png', 'content/lesson.json'):
            target = self.bundle/relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(self.root/relative, target)
        # Tool-generated files are not asserted to be source assets.
        (self.bundle/'AssetManifest.bin').write_bytes(b'generated')

    def git(self, *args):
        return subprocess.check_output(['git', '-C', str(self.root), *args], stderr=subprocess.DEVNULL).decode()

    def write(self, relative, value):
        path = self.root/relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(value if isinstance(value, bytes) else value.encode())

    def test_accepts_exact_assets_and_records_stable_digest(self):
        expected = {p: hashlib.sha256((self.root/p).read_bytes()).hexdigest()
                    for p in ('assets/room.png', 'content/lesson.json')}
        result = verify_candidate(self.root, self.commit, self.app)
        self.assertEqual(result['project_asset_count'], 2)
        self.assertEqual(result['project_assets_sha256'], hashlib.sha256(
            json.dumps(expected, sort_keys=True, separators=(',', ':')).encode()).hexdigest())

    def test_unknown_bundled_asset_is_refused_even_when_git_diff_is_clean(self):
        # This was accepted by the old build-script precondition.
        self.write('assets/untracked.png', b'local-only private image')
        self.assertEqual(self.git('diff', '--name-only'), '')
        shutil.copyfile(self.root/'assets/untracked.png', self.bundle/'assets/untracked.png')
        with self.assertRaisesRegex(CandidateSourceError, 'outside the named commit'):
            verify_candidate(self.root, self.commit, self.app)

    def test_ignored_bundled_asset_is_refused(self):
        self.write('content/notes.private', b'local-only notes')
        shutil.copyfile(self.root/'content/notes.private', self.bundle/'content/notes.private')
        with self.assertRaisesRegex(CandidateSourceError, 'outside the named commit'):
            verify_candidate(self.root, self.commit, self.app)

    def test_altered_bundle_bytes_are_refused(self):
        (self.bundle/'content/lesson.json').write_text('{"lesson":"different"}')
        with self.assertRaisesRegex(CandidateSourceError, 'differs from the named commit'):
            verify_candidate(self.root, self.commit, self.app)

    def test_dependency_lock_changed_during_build_is_refused(self):
        self.write('pubspec.lock', 'resolved differently\n')
        with self.assertRaisesRegex(CandidateSourceError, 'Tracked source changed'):
            verify_candidate(self.root, self.commit, self.app)

    def test_changed_commit_during_build_is_refused(self):
        self.write('pubspec.lock', 'new committed inputs\n')
        self.git('add', '.')
        self.git('-c', 'user.name=Candidate fixture', '-c', 'user.email=fixture@example.invalid',
                 'commit', '-qm', 'new inputs')
        with self.assertRaisesRegex(CandidateSourceError, 'HEAD changed'):
            verify_candidate(self.root, self.commit, self.app)

    def test_ordinary_and_ignored_dart_inputs_are_refused_before_build(self):
        for name in ('lib/extra.dart', 'lib/extra.g.dart'):
            with self.subTest(name=name):
                self.write(name, 'void localOnly() {}')
                with self.assertRaisesRegex(CandidateSourceError, 'Uncommitted Dart input'):
                    verify_candidate(self.root, self.commit)
                (self.root/name).unlink()

    def test_bundled_symlink_is_refused(self):
        (self.bundle/'assets/linked.png').symlink_to(self.root/'assets/room.png')
        with self.assertRaisesRegex(CandidateSourceError, 'Symlink'):
            verify_candidate(self.root, self.commit, self.app)


if __name__ == '__main__':
    unittest.main()
