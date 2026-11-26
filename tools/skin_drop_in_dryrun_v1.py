#!/usr/bin/env python3
"""Preview, rehearse and report a designer pack before a skin landing PR."""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

# A dry run must not leave Python caches alongside the source tools.
sys.dont_write_bytecode = True
import affected_tests_v1 as affected
import skin_pack_apply_v1 as importer

ROOT = importer.ROOT
# B101 preserves Modern Table pixels; the B66 literal guard owns the frozen
# presentation path inventory (including shared token owners). B111.FROZEN
# additionally protects table felt initializers inside the editable token file.
TABLE_PATH_SOURCE = Path('test/guards/act0_skin_literal_guard_v1_test.dart')
SHELL = importer.SOURCE.parent.parent


def table_paths(root):
    text = (root / TABLE_PATH_SOURCE).read_text()
    match = re.search(r'const _excluded = \{(.*?)\};', text, re.S)
    if not match:
        raise ValueError(f'cannot read protected paths from {TABLE_PATH_SOURCE}')
    names = re.findall(r"'([^']+\.dart)'", match[1])
    if not names:
        raise ValueError(f'empty protected path list in {TABLE_PATH_SOURCE}')
    return {SHELL / name for name in names}


def safe_path(root, relative):
    path = root / relative
    importer.require(path.resolve() == path, f'refusing redirected destination: {relative}')
    return path


def snapshot(root):
    return {path.relative_to(root): path.read_bytes()
            for path in root.rglob('*') if path.is_file()}


def apply_in_scratch(pack, scratch):
    # B111's check is its shared validate-and-render API: the CLI --apply
    # writes precisely these returned bytes, and only after validation succeeds.
    errors, source, assets = importer.check(pack, root=scratch)
    if errors:
        raise ValueError('\n'.join(errors))
    (scratch / importer.SOURCE).write_text(source)
    for name, data in assets.items():
        (scratch / importer.SLOTS / name).write_bytes(data)


def assert_safe(before, after, changed, protected, allowed):
    forbidden = changed & protected
    if forbidden:
        raise ValueError('protected Modern Table paths changed: ' +
                         ', '.join(str(path) for path in sorted(forbidden)))
    # A strict allowlist also rejects additions/deletions outside the skin slots,
    # including table owners not enumerated by the literal guard.
    if changed - allowed:
        raise ValueError('unexpected paths changed: ' +
                         ', '.join(str(path) for path in sorted(changed - allowed)))
    old = importer.declarations(before[importer.SOURCE].decode())
    new = importer.declarations(after[importer.SOURCE].decode())
    for name in sorted(importer.FROZEN):
        if name not in old or name not in new or old[name][2] != new[name][2]:
            raise ValueError(f'protected table token cannot change: {name}')


def dry_run(pack, keep=False):
    # B117 must be present before a pack can pass the composition gate.
    import skin_pack_preview_v1 as preview

    document, passed = preview.preview(pack)
    output = safe_path(ROOT, Path('out'))
    output.mkdir(exist_ok=True)
    with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=output,
                                     prefix='skin-drop-in-preview-', suffix='.html',
                                     delete=False) as sheet:
        sheet.write(document)
    print(f'Preview HTML: {sheet.name}')
    if not passed:
        print('FAIL: skin pack validation or contrast; see preview.', file=sys.stderr)
        return 1

    protected = table_paths(ROOT)
    allowed = {importer.SOURCE, *(importer.SLOTS / name for name in importer.ASSETS)}
    inputs = allowed | protected | {importer.CONTRACT}
    safe_path(ROOT, importer.SLOTS)
    paths = {relative: safe_path(ROOT, relative) for relative in inputs}
    with tempfile.TemporaryDirectory(prefix='skin-drop-in-', dir=output) as directory:
        scratch = Path(directory) / 'project'
        for relative, source in paths.items():
            if source.is_file():
                dest = scratch / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, dest)
        (scratch / importer.SLOTS).mkdir(parents=True, exist_ok=True)
        before = snapshot(scratch)
        apply_in_scratch(pack, scratch)
        after = snapshot(scratch)
        changed = {path for path in before.keys() | after.keys()
                   if before.get(path) != after.get(path)}
        assert_safe(before, after, changed, protected, allowed)

        # Use the same zero-context Git diff and term extractor as B103,
        # against two scratch files. No index or repository changes are needed.
        changed_terms = set()
        if importer.SOURCE in changed:
            original = Path(directory) / 'before.dart'
            original.write_bytes(before[importer.SOURCE])
            diff = subprocess.run(
                ['git', '-c', 'core.fsmonitor=false', 'diff', '--no-index',
                 '--no-ext-diff', '--no-textconv', '--no-renames', '--no-color',
                 '-U0', '--', str(original), str(scratch / importer.SOURCE)],
                capture_output=True)
            if diff.returncode != 1:
                raise ValueError(f'could not calculate B103 diff: {diff.stderr.decode(errors="replace")}')
            for line in affected.changed_lines(diff.stdout):
                changed_terms.update(affected.terms(line))
        tests = affected.select_tests({path.as_posix() for path in changed}, changed_terms)
        print(f'Would-change files ({len(changed)}):')
        for path in sorted(changed):
            print(f'  {path}')
        print(f'B103 affected tests ({len(tests)}):')
        for test in tests:
            print(f'  {test}')
        print(f'Modern Table paths unchanged ({TABLE_PATH_SOURCE}); B111 frozen tokens unchanged.')
        if keep:
            # Check every destination before writing any of them. Do not apply
            # if the working files changed during our rehearsal.
            for relative in inputs:
                path = safe_path(ROOT, relative)
                current = path.read_bytes() if path.is_file() else None
                importer.require(current == before.get(relative),
                                 f'working file changed during dry run: {relative}')
            for relative in sorted(changed):
                paths[relative].write_bytes(after[relative])
            print('Kept applied skin files in the working tree.')
        else:
            print('Dry run only; working skin files unchanged.')
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('pack_dir', type=Path)
    parser.add_argument('--keep', action='store_true', help='apply the checked changes to the working tree')
    args = parser.parse_args()
    pack = args.pack_dir.resolve()
    os.chdir(ROOT)  # B103 reads lib/test/pubspec relative to the repository.
    try:
        return dry_run(pack, args.keep)
    except (OSError, ValueError, ImportError) as exc:
        print(f'skin drop-in: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
