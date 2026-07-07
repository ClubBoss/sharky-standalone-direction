#!/usr/bin/env python3
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_DIR = ROOT / "tools" / "test_authority" / "manifests"
POST_SHIM_ARTIFACT = (
    ROOT / "docs" / "_reviews" / "post_shim_global_suite_remeasurement_v1.md"
)
TIER_B_MANIFEST = MANIFEST_DIR / "tier_b_maintained_support.txt"
TIER_C_MANIFEST = MANIFEST_DIR / "tier_c_quarantine.txt"
TIER_D_MANIFEST = MANIFEST_DIR / "tier_d_retired.txt"
KNOWN_TIER_C_MANIFEST = MANIFEST_DIR / "known_tier_c_residuals.txt"
KNOWN_TIER_C_RESIDUALS = {
    "test/services/booster_pack_launcher_test.dart",
    "test/services/skill_gap_booster_service_test.dart",
    "test/training_pack_template_service_test.dart",
    "test/widgets/export_csv_button_test.dart",
    "test/widgets/review_path_card_test.dart",
}


def _read_manifest(path: Path) -> list[str]:
    if not path.exists():
        raise AssertionError(f"missing manifest: {path.relative_to(ROOT)}")
    entries: list[str] = []
    for line_number, raw in enumerate(path.read_text().splitlines(), start=1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line in entries:
            raise AssertionError(
                f"duplicate path in {path.relative_to(ROOT)}:{line_number}: {line}"
            )
        entries.append(line)
    return entries


def _parse_frozen_inventory() -> dict[str, str]:
    text = POST_SHIM_ARTIFACT.read_text()
    section = text.split("## Exact Non-Green Inventory\n", 1)[1].split(
        "\n## Minimal Next Waves", 1
    )[0]
    rows: dict[str, str] = {}
    for raw in section.splitlines():
        if not raw.startswith("| test/") and not raw.startswith("| ./"):
            continue
        cells = [cell.strip() for cell in raw.strip().strip("|").split("|")]
        if len(cells) < 5:
            raise AssertionError(f"malformed inventory row: {raw}")
        path, tier = cells[0], cells[4]
        rows[path] = tier
    return rows


def validate() -> dict[str, object]:
    frozen = _parse_frozen_inventory()
    tier_b = _read_manifest(TIER_B_MANIFEST)
    tier_c = _read_manifest(TIER_C_MANIFEST)
    tier_d = _read_manifest(TIER_D_MANIFEST)
    known_tier_c = _read_manifest(KNOWN_TIER_C_MANIFEST)
    overlap = sorted(set(tier_b) & set(tier_c))
    if overlap:
        raise AssertionError(f"tier_b/tier_c overlap: {overlap[:10]}")
    if len(tier_b) != 117:
        raise AssertionError(f"Tier B count expected 117, got {len(tier_b)}")
    if len(tier_c) != 304:
        raise AssertionError(f"Tier C count expected 304, got {len(tier_c)}")
    if len(tier_d) != 0:
        raise AssertionError(f"Tier D count expected 0, got {len(tier_d)}")
    frozen_b = sorted(path for path, tier in frozen.items() if tier == "Tier B")
    frozen_c = sorted(path for path, tier in frozen.items() if tier == "Tier C")
    if sorted(tier_b) != frozen_b:
        missing = sorted(set(frozen_b) - set(tier_b))
        extra = sorted(set(tier_b) - set(frozen_b))
        raise AssertionError(
            f"Tier B manifest drift: missing={missing[:10]} extra={extra[:10]}"
        )
    if sorted(tier_c) != frozen_c:
        missing = sorted(set(frozen_c) - set(tier_c))
        extra = sorted(set(tier_c) - set(frozen_c))
        raise AssertionError(
            f"Tier C manifest drift: missing={missing[:10]} extra={extra[:10]}"
        )
    missing_known = sorted(KNOWN_TIER_C_RESIDUALS - set(known_tier_c))
    if missing_known:
        raise AssertionError(f"known residuals not Tier C: {missing_known}")
    promoted_known = sorted(set(known_tier_c) & set(tier_b))
    if promoted_known:
        raise AssertionError(f"known residuals promoted to Tier B: {promoted_known}")
    deleted = sorted(
        path for path in tier_b + tier_c if path.startswith("test/") and not (ROOT / path).exists()
    )
    return {
        "tier_b": len(tier_b),
        "tier_c": len(tier_c),
        "tier_d": len(tier_d),
        "overlap": len(overlap),
        "missing": 0,
        "known_five_tier_c": True,
        "known_tier_c_residuals": len(known_tier_c),
        "deleted_paths": deleted,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    try:
        result = validate()
    except AssertionError as error:
        if args.json:
            print(json.dumps({"ok": False, "error": str(error)}, indent=2))
        else:
            print(f"test_authority_manifest: FAIL: {error}", file=sys.stderr)
        return 1
    if args.json:
        print(json.dumps({"ok": True, **result}, indent=2))
    else:
        print("test_authority_manifest: PASS")
        for key, value in result.items():
            print(f"- {key}: {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
