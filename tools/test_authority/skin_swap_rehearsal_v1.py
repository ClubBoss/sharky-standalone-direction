#!/usr/bin/env python3
"""Compile the real Act0 widgets in isolated passes without touching the working tree's lib/."""

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TOKENS = Path('lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart')
VARIANT = Path('test/ui_v2/skin/act0_skin_tokens_rehearsal_v1.dart')
TEST = Path('test/ui_v2/skin/act0_skin_swap_rehearsal_v1_test.dart')
PALETTE = Path('lib/ui_v2/act0_shell/academy_leaves/act0_academy_leaf_style_v1.dart')
# Exact previous literals, solely for the default-parity control. Resolve them
# from the current tokens so a later approved designer palette can be rehearsed
# without making the old palette a permanent production constraint.
ACADEMY_ALIASES = {
    'ink': 'academyBackground',
    'inkRaised': 'academyRaised',
    'tealDeep': 'academyTealDeep',
    'teal': 'academyTeal',
    'aqua': 'academyAccent',
    'aquaSoft': 'academyAccentSoft',
    'text': 'academyOnSurface',
    'textMuted': 'academyMuted',
    'rule': 'academyLine',
    'repair': 'academyWarn',
}


def literal_control(palette: str, default: str) -> str:
    for role, token in ACADEMY_ALIASES.items():
        literal = re.search(rf'\b{token} = (Color\(0x[0-9a-fA-F]{{8}}\));', default)
        alias = f'static const {role} = Act0SkinTokensV1.{token};'
        if literal is None or palette.count(alias) != 1:
            raise ValueError(f'Missing exact literal-to-token migration: {role}')
        palette = palette.replace(alias, f'static const {role} = {literal[1]};')
    return palette


def validate_pack(default: str, variant: str) -> None:
    # Prevent fixture drift: same complete static API, implementation, metrics,
    # and assets; only the literal colours may differ in a rehearsal.
    def interface(source):
        source = re.sub(r'//[^\n]*', '', source)
        source = re.sub(r'Color\(0x[0-9a-fA-F]{8}\)', 'Color(PALETTE)', source)
        return re.sub(r'\s+', '', source)

    if interface(default) != interface(variant):
        raise ValueError('Variant C must match the full production token API (colour literals only)')
    if re.findall(r'Color\(0x[0-9a-fA-F]{8}\)', default) == re.findall(r'Color\(0x[0-9a-fA-F]{8}\)', variant):
        raise ValueError('Variant C must differ from the default pack')


def run():
    default = (ROOT / TOKENS).read_text()
    variant = (ROOT / VARIANT).read_text()
    validate_pack(default, variant)
    # A scratch project, NOT a git worktree: no mutation of tracked app source,
    # even if Flutter exits, the comparison fails, or the process is cancelled.
    scratch = ROOT / '.dart_tool'
    scratch.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='b101-', dir=scratch) as directory:
        work = Path(directory) / 'project'
        work.mkdir()
        capture = Path(directory) / 'baseline'
        capture.mkdir()
        for name in ('lib', 'assets', 'content', 'test', 'third_party', 'appinio_swiper_stub'):
            shutil.copytree(ROOT / name, work / name)
        for name in ('pubspec.yaml', 'pubspec.lock', 'l10n.yaml', 'analysis_options.yaml'):
            shutil.copy2(ROOT / name, work / name)
        subprocess.run(['flutter', 'pub', 'get', '--offline'], cwd=work, check=True)
        command = [
            'flutter', 'test', '--no-pub', str(TEST), '-r', 'expanded',
            f'--dart-define=B101_CAPTURE_DIR={capture}',
        ]
        palette = (work / PALETTE).read_text()
        (work / PALETTE).write_text(literal_control(palette, default))
        subprocess.run(command, cwd=work, check=True)
        (work / PALETTE).write_text(palette)
        subprocess.run(command + ['--dart-define=B101_DEFAULT_PARITY=true'], cwd=work, check=True)
        (work / TOKENS).write_text(variant)
        subprocess.run(command + ['--dart-define=B101_VARIANT_C=true'], cwd=work, check=True)


if __name__ == '__main__':
    if sys.argv[1:] == ['--validate-pack']:
        validate_pack((ROOT / TOKENS).read_text(), (ROOT / VARIANT).read_text())
        literal_control((ROOT / PALETTE).read_text(), (ROOT / TOKENS).read_text())
        print('B101 static token API and literal-control parity passed')
    elif sys.argv[1:] in ([], [str(TEST)]):
        run()
    else:
        raise SystemExit(f"usage: {sys.argv[0]} [--validate-pack | {TEST}]")
