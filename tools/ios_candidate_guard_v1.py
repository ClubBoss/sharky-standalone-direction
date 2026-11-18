#!/usr/bin/env python3
"""Check candidate source and bundled project assets against the named Git commit."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


class CandidateSourceError(RuntimeError):
    pass


def git(root: Path, *args: str) -> bytes:
    return subprocess.check_output(['git', '-C', str(root), *args])


def committed_files(root: Path, commit: str) -> dict[str, tuple[str, str]]:
    files = {}
    for entry in git(root, 'ls-tree', '-r', '-z', commit).split(b'\0'):
        if not entry:
            continue
        meta, path = entry.split(b'\t', 1)
        mode, kind, oid = meta.decode().split()
        if kind == 'blob':
            files[path.decode()] = (mode, oid)
    return files


def verify_source(root: Path, commit: str) -> dict[str, tuple[str, str]]:
    if git(root, 'rev-parse', 'HEAD').decode().strip() != commit:
        raise CandidateSourceError('HEAD changed: rebuild from the named commit')
    if git(root, 'status', '--porcelain', '--untracked-files=no').strip():
        raise CandidateSourceError('Tracked source changed: commit it and rebuild')
    files = committed_files(root, commit)
    # Git diff alone misses both ordinary and ignored local Dart files.
    for path in (root/'lib').rglob('*.dart'):
        relative = path.relative_to(root).as_posix()
        if path.is_symlink() or relative not in files:
            raise CandidateSourceError(f'Uncommitted Dart input: {relative}')
    return files


def verify_candidate(root: Path, commit: str, app: Path | None = None) -> dict:
    files = verify_source(root, commit)
    result = {'source_commit': commit, 'source_check': 'passed'}
    if app is None:
        return result
    bundle = app/'Frameworks/App.framework/flutter_assets'
    if not bundle.is_dir() or bundle.is_symlink():
        raise CandidateSourceError('Flutter asset bundle is missing or is a symlink')
    algorithm = git(root, 'rev-parse', '--show-object-format').decode().strip()
    hashes = {}
    # Own Flutter assets are copied byte-for-byte. SDK/package-generated
    # files (fonts, shaders, manifests, notices) are outside this source check.
    for prefix in ('assets', 'content'):
        directory = bundle/prefix
        if directory.is_symlink():
            raise CandidateSourceError(f'Symlink in project asset bundle: {prefix}')
        for path in sorted(directory.rglob('*')):
            relative = path.relative_to(bundle).as_posix()
            if path.is_symlink():
                raise CandidateSourceError(f'Symlink in project asset bundle: {relative}')
            if not path.is_file():
                continue
            mode, expected_oid = files.get(relative, ('', ''))
            if mode not in ('100644', '100755'):
                raise CandidateSourceError(f'Bundled asset is outside the named commit: {relative}')
            raw = path.read_bytes()
            actual_oid = hashlib.new(algorithm, b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
            if actual_oid != expected_oid:
                raise CandidateSourceError(f'Bundled asset differs from the named commit: {relative}')
            hashes[relative] = hashlib.sha256(raw).hexdigest()
    if not hashes:
        raise CandidateSourceError('No project assets found in the candidate')
    digest = hashlib.sha256(json.dumps(hashes, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    result.update(project_asset_count=len(hashes), project_assets_sha256=digest)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-commit', required=True)
    parser.add_argument('--app', type=Path)
    args = parser.parse_args()
    try:
        result = verify_candidate(ROOT, args.source_commit, args.app)
    except (CandidateSourceError, subprocess.CalledProcessError) as error:
        parser.exit(1, f'Candidate refused: {error}\n')
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
