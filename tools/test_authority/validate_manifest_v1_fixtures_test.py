#!/usr/bin/env python3
"""Exercise executable-manifest failures without invoking Flutter."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "tools/test_authority/manifests"
VALIDATOR = ROOT / "tools/test_authority/validate_manifest_v1.py"


def _run(mutator=None, expected=None):
    with tempfile.TemporaryDirectory() as directory:
        manifests = Path(directory) / "manifests"
        shutil.copytree(SOURCE, manifests)
        path = manifests / "tier_b_maintained_support.txt"
        if mutator:
            path.write_text(mutator(path.read_text()))
        result = subprocess.run(
            ["python3", str(VALIDATOR), "--json"], cwd=ROOT,
            env={**os.environ, "TEST_AUTHORITY_MANIFEST_DIR": str(manifests)},
            text=True, capture_output=True, check=False,
        )
        assert result.returncode == (1 if expected else 0), result.stdout + result.stderr
        if expected:
            assert expected in result.stdout + result.stderr, result.stdout + result.stderr


def test_current_manifest():
    _run()


def test_duplicate():
    _run(lambda text: text + "test/ui_v2/act0_main01_app_root_cycle_v1_test.dart\n", "duplicates")


def test_missing_executable():
    _run(lambda text: text + "test/missing_a0b_fixture_test.dart\n", "missing_executable_paths")


def test_path_escape():
    _run(lambda text: text + "test/../lib/main.dart\n", "invalid_test_paths")


def test_required_main01_missing():
    _run(lambda text: text.replace("test/ui_v2/act0_main01_app_root_cycle_v1_test.dart\n", ""),
         "required_pr_contracts_missing")


def test_a_b_overlap():
    _run(lambda text: text + "test/ui_v2/act0_w4_closed_flop_actor_v1_test.dart\n",
         "tier_a_tier_b_overlap")


if __name__ == "__main__":
    for name, value in sorted(globals().items()):
        if name.startswith("test_") and callable(value):
            value()
            print(f"PASS {name}")
