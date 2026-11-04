#!/usr/bin/env python3
"""Complete only missing Dart dependencies of the existing RED visibility adapter.

Existing baseline files remain authoritative and byte-identical. This does not
copy the candidate state/model over the historical RED source, enable F7, or
decide whether RED/GREEN passed; the existing evidence validator owns that.
"""
import argparse
import hashlib
import json
import pathlib
import re
import shutil
import subprocess


ROOTS = (
    'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    'test/support/act0_table_truth_v1.dart',
    'test/ui_v2/act0_table_truth_catalog_v1_test.dart',
    'test/ui_v2/act0_first_hand_truth_v1_test.dart',
    'test/ui_v2/act0_table_truth_falsifiers_v1_test.dart',
    'test/ui_v2/act0_table_truth_render_v1_test.dart',
)
DIRECTIVE = re.compile(r'^\s*(?:import|export|part(?!\s+of\b))\s+([^;]+);', re.M)
URI = re.compile(r"['\"]([^'\"]+)['\"]")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inside(root, relative):
    path = (root / relative).resolve()
    if not path.is_relative_to(root):
        raise ValueError(f'Dependency escapes source root: {relative}')
    return path


def dependencies(relative, text):
    for directive in DIRECTIVE.finditer(text):
        for uri in URI.findall(directive[1]):
            if uri.startswith('dart:'):
                continue
            if uri.startswith('package:'):
                if not uri.startswith('package:poker_analyzer/'):
                    continue  # Resolved by the unchanged pub get step.
                yield pathlib.Path('lib') / uri.removeprefix('package:poker_analyzer/')
            elif ':' in uri:
                raise ValueError(f'Unsupported local dependency URI: {uri}')
            else:
                yield relative.parent / uri


def complete_dependencies(candidate, baseline, roots=ROOTS):
    candidate, baseline = candidate.resolve(), baseline.resolve()
    pending = list(map(pathlib.Path, roots))
    visited, kept, copied = set(), {}, {}
    while pending:
        relative = pending.pop()
        target = inside(baseline, relative)
        relative = target.relative_to(baseline)
        if relative in visited:
            continue
        visited.add(relative)
        if target.is_file():
            kept[str(relative)] = digest(target)
        else:
            source = inside(candidate, relative)
            if not source.is_file():
                raise FileNotFoundError(f'Missing dependency in both sources: {relative}')
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
            copied[str(relative)] = digest(target)
        # Traverse the actual baseline file, never a newer candidate substitute
        # for a dependency already present in the historical baseline.
        pending.extend(dependencies(relative, target.read_text()))
    for relative, before in kept.items():
        if digest(inside(baseline, relative)) != before:
            raise RuntimeError(f'Existing baseline dependency changed: {relative}')
    return {'copied_missing': copied, 'preserved_existing': kept,
            'policy': 'missing-only; existing baseline dependencies retained'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=pathlib.Path, required=True)
    parser.add_argument('--expected-head', required=True)
    parser.add_argument('--output', type=pathlib.Path, required=True)
    args = parser.parse_args()
    head = subprocess.check_output(
        ['git', '-C', str(args.baseline), 'rev-parse', 'HEAD'], text=True).strip()
    if head != args.expected_head:
        raise SystemExit(f'Baseline HEAD mismatch: {head} != {args.expected_head}')
    candidate = pathlib.Path(__file__).resolve().parent.parent
    result = complete_dependencies(candidate, args.baseline)
    result['baseline_head'] = head
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'baseline_head': head,
                      'copied_missing': sorted(result['copied_missing']),
                      'preserved_count': len(result['preserved_existing'])}))


if __name__ == '__main__':
    main()
