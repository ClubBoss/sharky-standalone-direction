#!/usr/bin/env python3
"""Complete only missing Dart dependencies of the existing RED visibility adapter.

Existing baseline files remain authoritative. The pinned Guide constructor is
the sole historical-file exception; its rendering body stays byte-identical.
This does not
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



# A known historical RED source (fa079b6c) predates the price/order API.
# Candidate Runner needs the price import to compile even when the four
# Table Truth tests never exercise it. Preserve every original historical
# file; adapt ONLY the candidate-sourced, missing dependency in the private
# baseline worktree. This sentinel makes any runtime invocation an explicit
# invalid RED, not a surrogate proof.
LEGACY_HEAD = 'fa079b6c5880814e231981a7bd5ed97df192d215'
LEGACY_STREET_SHA256 = 'a0ea1b4adff04704bc83feee9397fea1c3abc03523539bd5805db3200ba7c7be'
PRICE_DEPENDENCY = 'lib/ui_v2/act0_shell/act0_betting_price_contract_v1.dart'
PRICE_CANDIDATE_SHA256 = '388f0706c51a309116bfe340507e9278af9c47716bd9bd2f0c6c781ff28322dd'
ORDER_SENTINEL = 'SHARKY_BASELINE_PRICE_ORDER_SHIM_EXECUTED'
ORDER_COMPILE_SHIM = (
    '\n// PRIVATE historical compile-only adapter. NOT production source.\n'
    'enum Act0BettingRoundOrderTruthV1 { contradiction, consistent, unproved }\n'
    'Act0BettingRoundOrderTruthV1 act0BettingRoundOrderTruthForTableV1(\n'
    '    Act0TableStateV1 table) {\n'
    "  throw StateError('SHARKY_BASELINE_PRICE_ORDER_SHIM_EXECUTED');\n"
    '}\n'
)


def add_legacy_compile_only_shim(baseline, head, dependency_result):
    baseline = baseline.resolve()
    # Do not generalize to a newer baseline or changed candidate without
    # new exact-source proof and a fresh RED/GREEN run.
    if head != LEGACY_HEAD:
        return None
    relative = pathlib.Path(PRICE_DEPENDENCY)
    copied = dependency_result['copied_missing']
    if PRICE_DEPENDENCY not in copied:
        raise RuntimeError('Expected missing candidate price dependency')
    old_street = inside(
        baseline, pathlib.Path('lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart'))
    price = inside(baseline, relative)
    if digest(old_street) != LEGACY_STREET_SHA256:
        raise RuntimeError('Historical street contract changed')
    if digest(price) != PRICE_CANDIDATE_SHA256:
        raise RuntimeError('Candidate price contract changed; revalidate shim')
    # This path is absent historically and is already recorded as copied.
    if ORDER_SENTINEL in price.read_text():
        raise RuntimeError('Historical compatibility already injected')
    price.write_text(price.read_text() + ORDER_COMPILE_SHIM)
    return {'path': PRICE_DEPENDENCY,
            'prior_sha256': PRICE_CANDIDATE_SHA256,
            'after_sha256': digest(price),
            'historical_street_sha256': LEGACY_STREET_SHA256,
            'runtime_sentinel': ORDER_SENTINEL,
            'scope': 'historical copied dependency only; fail on invocation'}



# The same pinned historical Guide predates Runner's optional scrollSupport API.
# Its rendering body must remain historical. Only false is supported: flutter
# test enables assertions, and the workflow rejects this sentinel before RED.
GUIDE_DEPENDENCY = 'lib/ui_v2/act0_shell/act0_learning_scene_v3.dart'
GUIDE_LEGACY_SHA256 = 'e57900a6057525572045246ddd5d2a1630d3c15290c9e1b50cb056ab75419a63'
GUIDE_RUNNER = ROOTS[0]
GUIDE_RUNNER_SHA256 = 'e78b770982233e1082d571670c3363754455a75723eab32137ab6f5fbff48436'
GUIDE_SENTINEL = 'SHARKY_BASELINE_GUIDE_SCROLL_SHIM_EXECUTED'
GUIDE_CONSTRUCTOR = (
    '  const Act0LearningSceneGuideV3({\n'
    '    super.key,\n'
    '    required this.phase,\n'
    '    required this.attentionPhase,\n'
    '    required this.sharkyState,\n'
    '    this.growthStage = Act0SharkyGrowthStageV1.foundation,\n'
    '    required this.eyebrow,\n'
    '    required this.headline,\n'
    '    required this.support,\n'
    '    this.focusLabel,\n'
    '    this.progressLabel,\n'
    '  });\n'
)
GUIDE_COMPATIBLE_CONSTRUCTOR = GUIDE_CONSTRUCTOR.replace(
    '    required this.support,\n',
    '    required this.support,\n    bool scrollSupport = false,\n',
).replace('  });\n', f"  }}) : assert(!scrollSupport, '{GUIDE_SENTINEL}');\n")


def add_legacy_guide_constructor_shim(baseline, head, dependency_result):
    baseline = baseline.resolve()
    if head != LEGACY_HEAD:
        return None
    kept = dependency_result['preserved_existing']
    copied = dependency_result['copied_missing']
    for relative, expected in ((GUIDE_DEPENDENCY, GUIDE_LEGACY_SHA256),
                               (GUIDE_RUNNER, GUIDE_RUNNER_SHA256)):
        if (relative in copied or kept.get(relative) != expected or
                digest(inside(baseline, pathlib.Path(relative))) != expected):
            raise RuntimeError(f'Historical Guide compatibility input changed: {relative}')
    guide = inside(baseline, pathlib.Path(GUIDE_DEPENDENCY))
    source = guide.read_text()
    if GUIDE_SENTINEL in source or source.count(GUIDE_CONSTRUCTOR) != 1:
        raise RuntimeError('Historical Guide constructor changed or already injected')
    guide.write_text(source.replace(GUIDE_CONSTRUCTOR, GUIDE_COMPATIBLE_CONSTRUCTOR, 1))
    # This explicit constructor exception is no longer byte-preserved. Do not
    # leave its old digest in the preserved-existing manifest.
    del kept[GUIDE_DEPENDENCY]
    return {'path': GUIDE_DEPENDENCY,
            'prior_sha256': GUIDE_LEGACY_SHA256,
            'after_sha256': digest(guide),
            'runner_sha256': GUIDE_RUNNER_SHA256,
            'runtime_sentinel': GUIDE_SENTINEL,
            'scope': 'historical constructor only; false preserves body; true invalid in flutter test'}


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
    result['legacy_compile_adapter'] = add_legacy_compile_only_shim(
        args.baseline, head, result)
    result['legacy_guide_compile_adapter'] = add_legacy_guide_constructor_shim(
        args.baseline, head, result)
    if result['legacy_guide_compile_adapter'] is not None:
        result['policy'] += '; exact-pinned Guide constructor exception recorded separately'
    result['baseline_head'] = head
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'baseline_head': head,
                      'copied_missing': sorted(result['copied_missing']),
                      'preserved_count': len(result['preserved_existing'])}))


if __name__ == '__main__':
    main()
