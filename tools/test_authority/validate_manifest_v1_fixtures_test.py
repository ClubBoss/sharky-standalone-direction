#!/usr/bin/env python3
"""Negative schema-v2 fixtures executed through validate_manifest_v1.py."""

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE_MANIFESTS = ROOT / "tools" / "test_authority" / "manifests"
VALIDATOR = ROOT / "tools" / "test_authority" / "validate_manifest_v1.py"


def _run(mutator) -> None:
    with tempfile.TemporaryDirectory() as directory:
        manifests = Path(directory) / "manifests"
        shutil.copytree(SOURCE_MANIFESTS, manifests)
        records_path = manifests / "tier_c_quarantine_records_v1.json"
        payload = json.loads(records_path.read_text())
        mutator(payload, manifests)
        records_path.write_text(json.dumps(payload, indent=2) + "\n")
        result = subprocess.run(
            ["python3", str(VALIDATOR), "--json"],
            cwd=ROOT,
            env={**os.environ, "TEST_AUTHORITY_MANIFEST_DIR": str(manifests)},
            text=True,
            capture_output=True,
            check=False,
        )
        assert result.returncode == 1, result.stdout + result.stderr


def test_generic_owner_placeholder() -> None:
    _run(lambda payload, _: payload["records"][0].update(owner="unknown"))


def test_generic_reason_placeholder() -> None:
    _run(lambda payload, _: payload["records"][0].update(reason="none"))


def test_absent_owner_evidence() -> None:
    _run(lambda payload, _: payload["records"][0].update(owner_evidence=""))


def test_absent_reentry_condition() -> None:
    _run(lambda payload, _: payload["records"][0].update(reentry_condition=""))


def test_unsupported_reason_code() -> None:
    _run(lambda payload, _: payload["records"][0].update(reason_code="UNSUPPORTED"))


def test_tier_c_path_without_record() -> None:
    _run(lambda payload, _: payload["records"].pop())


def test_record_without_tier_c_path() -> None:
    def mutate(payload, _):
        payload["records"][0]["path"] = "test/not_in_manifest_test.dart"
    _run(mutate)


def test_duplicate_carrier_identity() -> None:
    def mutate(payload, _):
        payload["records"][1]["carrier_identity"] = payload["records"][0]["carrier_identity"]
    _run(mutate)


def test_tier_c_tier_b_overlap() -> None:
    def mutate(payload, manifests):
        path = payload["records"][0]["path"]
        with (manifests / "tier_b_maintained_support.txt").open("a") as stream:
            stream.write(path + "\n")
    _run(mutate)


if __name__ == "__main__":
    for name, value in sorted(globals().items()):
        if name.startswith("test_") and callable(value):
            value()
            print(f"PASS {name}")
