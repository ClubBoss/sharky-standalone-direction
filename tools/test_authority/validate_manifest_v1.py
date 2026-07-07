#!/usr/bin/env python3
import argparse
import json
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

EXPECTED_OBSERVED_TIER_B_COUNT = 117
EXPECTED_OBSERVED_TIER_C_COUNT = 304
EXPECTED_EXECUTABLE_TIER_B_COUNT = 117
EXPECTED_EXECUTABLE_TIER_C_COUNT = 307
EXPECTED_TIER_D_COUNT = 0
EXPECTED_OBSERVED_UNIQUE_NON_GREEN = 421
EXPECTED_MEASUREMENT_COUNTS = {
    "Started": "3519",
    "Done": "3518",
    "Success": "3044",
    "Failure": "84",
    "Error": "390",
    "Skipped": "2",
}
KNOWN_TIER_C_RESIDUALS = {
    "test/services/booster_pack_launcher_test.dart",
    "test/services/skill_gap_booster_service_test.dart",
    "test/training_pack_template_service_test.dart",
    "test/widgets/export_csv_button_test.dart",
    "test/widgets/review_path_card_test.dart",
}
KNOWN_UNREACHED_TIER_C = {
    "test/services/skill_gap_booster_service_test.dart",
    "test/widgets/export_csv_button_test.dart",
    "test/widgets/review_path_card_test.dart",
}


def _read_manifest(path: Path) -> tuple[list[str], list[str]]:
    if not path.exists():
        raise AssertionError(f"missing manifest: {path.relative_to(ROOT)}")
    entries: list[str] = []
    duplicates: list[str] = []
    seen: set[str] = set()
    for line_number, raw in enumerate(path.read_text().splitlines(), start=1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line in seen:
            duplicates.append(f"{path.relative_to(ROOT)}:{line_number}: {line}")
        seen.add(line)
        entries.append(line)
    return entries, duplicates


def _parse_observed_inventory() -> dict[str, str]:
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


def _require_artifact_measurements(text: str) -> None:
    required_literals = [
        "| Command | `flutter test -r json` |",
        "| No-progress timeout | `240` seconds |",
        "| Wall duration | `2373.3` seconds |",
        "Reconciliation: `0 + 117 + 304 + 0 + 0 = 421` unique non-green files.",
    ]
    for literal in required_literals:
        if literal not in text:
            raise AssertionError(f"missing frozen artifact literal: {literal}")
    for label, value in EXPECTED_MEASUREMENT_COUNTS.items():
        if f"| {label} |" not in text or f"| `{value}` |" not in text:
            raise AssertionError(f"missing frozen measurement count: {label}={value}")


def validate() -> dict[str, object]:
    artifact_text = POST_SHIM_ARTIFACT.read_text()
    _require_artifact_measurements(artifact_text)
    observed = _parse_observed_inventory()
    observed_b = sorted(path for path, tier in observed.items() if tier == "Tier B")
    observed_c = sorted(path for path, tier in observed.items() if tier == "Tier C")

    tier_b, tier_b_duplicates = _read_manifest(TIER_B_MANIFEST)
    tier_c, tier_c_duplicates = _read_manifest(TIER_C_MANIFEST)
    tier_d, tier_d_duplicates = _read_manifest(TIER_D_MANIFEST)
    known_tier_c, known_duplicates = _read_manifest(KNOWN_TIER_C_MANIFEST)
    duplicates = tier_b_duplicates + tier_c_duplicates + tier_d_duplicates + known_duplicates

    observed_b_set = set(observed_b)
    observed_c_set = set(observed_c)
    tier_b_set = set(tier_b)
    tier_c_set = set(tier_c)
    tier_d_set = set(tier_d)
    known_tier_c_set = set(known_tier_c)
    overlap = sorted(tier_b_set & tier_c_set)
    observed_tier_b_missing = sorted(observed_b_set - tier_b_set)
    observed_tier_b_extra = sorted(tier_b_set - observed_b_set)
    observed_tier_c_missing = sorted(observed_c_set - tier_c_set)
    executable_tier_c_extra = sorted(tier_c_set - observed_c_set)
    missing_known_registry = sorted(KNOWN_TIER_C_RESIDUALS - known_tier_c_set)
    unexpected_known_registry = sorted(known_tier_c_set - KNOWN_TIER_C_RESIDUALS)
    known_missing_from_executable_tier_c = sorted(KNOWN_TIER_C_RESIDUALS - tier_c_set)
    known_unreached_missing = sorted(KNOWN_UNREACHED_TIER_C - tier_c_set)
    known_unreached_extra = sorted(set(executable_tier_c_extra) - KNOWN_UNREACHED_TIER_C)
    deleted_paths = sorted(
        path
        for path in tier_b + tier_c + tier_d
        if path.startswith("test/") and not (ROOT / path).exists()
    )

    observed_tier_b_exact_set_match = not observed_tier_b_missing and not observed_tier_b_extra
    observed_tier_c_exact_set_match = not observed_tier_c_missing
    known_residuals_subset_of_executable_tier_c = not known_missing_from_executable_tier_c
    tier_c_known_unreached_additions = sorted(tier_c_set - observed_c_set)

    failures: list[str] = []
    if len(observed) != EXPECTED_OBSERVED_UNIQUE_NON_GREEN:
        failures.append(
            f"observed inventory count expected {EXPECTED_OBSERVED_UNIQUE_NON_GREEN}, got {len(observed)}"
        )
    if len(observed_b) != EXPECTED_OBSERVED_TIER_B_COUNT:
        failures.append(f"observed Tier B expected 117, got {len(observed_b)}")
    if len(observed_c) != EXPECTED_OBSERVED_TIER_C_COUNT:
        failures.append(f"observed Tier C expected 304, got {len(observed_c)}")
    if len(tier_b) != EXPECTED_EXECUTABLE_TIER_B_COUNT:
        failures.append(f"executable Tier B expected 117, got {len(tier_b)}")
    if len(tier_c) != EXPECTED_EXECUTABLE_TIER_C_COUNT:
        failures.append(f"executable Tier C expected 307, got {len(tier_c)}")
    if len(tier_d) != EXPECTED_TIER_D_COUNT:
        failures.append(f"Tier D expected 0, got {len(tier_d)}")
    if duplicates:
        failures.append(f"duplicate manifest paths: {duplicates[:10]}")
    if not observed_tier_b_exact_set_match:
        failures.append(
            f"observed Tier B drift: missing={observed_tier_b_missing[:10]} extra={observed_tier_b_extra[:10]}"
        )
    if not observed_tier_c_exact_set_match:
        failures.append(f"observed Tier C missing from executable manifest: {observed_tier_c_missing[:10]}")
    if executable_tier_c_extra != sorted(KNOWN_UNREACHED_TIER_C):
        failures.append(
            "Tier C executable extra-over-observed set mismatch: "
            f"missing_known_unreached={known_unreached_missing[:10]} "
            f"unexpected={known_unreached_extra[:10]}"
        )
    if missing_known_registry or unexpected_known_registry:
        failures.append(
            f"known residual registry drift: missing={missing_known_registry[:10]} "
            f"unexpected={unexpected_known_registry[:10]}"
        )
    if not known_residuals_subset_of_executable_tier_c:
        failures.append(
            f"known residuals missing from executable Tier C: {known_missing_from_executable_tier_c[:10]}"
        )
    if overlap:
        failures.append(f"tier_b/tier_c overlap: {overlap[:10]}")
    if tier_d_set:
        failures.append(f"Tier D should be empty: {sorted(tier_d_set)[:10]}")
    if deleted_paths:
        failures.append(f"manifest paths do not exist: {deleted_paths[:10]}")

    result = {
        "observed_tier_b_exact_set_match": observed_tier_b_exact_set_match,
        "observed_tier_c_exact_set_match": observed_tier_c_exact_set_match,
        "observed_unique_non_green": len(observed),
        "observed_tier_b_count": len(observed_b),
        "observed_tier_c_count": len(observed_c),
        "executable_tier_b_count": len(tier_b),
        "executable_tier_c_count": len(tier_c),
        "executable_tier_d_count": len(tier_d),
        "observed_tier_b_missing": observed_tier_b_missing,
        "observed_tier_b_extra": observed_tier_b_extra,
        "observed_tier_c_missing": observed_tier_c_missing,
        "tier_c_known_unreached_additions": tier_c_known_unreached_additions,
        "known_residuals_subset_of_executable_tier_c": known_residuals_subset_of_executable_tier_c,
        "known_residuals_missing_from_executable_tier_c": known_missing_from_executable_tier_c,
        "tier_b_tier_c_overlap": len(overlap),
        "duplicates": duplicates,
        "missing_paths": deleted_paths,
    }
    if failures:
        raise AssertionError(json.dumps({"failures": failures, **result}, indent=2))
    return result


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
