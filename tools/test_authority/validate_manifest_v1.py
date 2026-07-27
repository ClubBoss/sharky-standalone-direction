#!/usr/bin/env python3
import argparse
import hashlib
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
PHP2_REVIEW_ARTIFACT = (
    ROOT / "docs" / "_reviews" / "php2_legacy_corpus_ownership_disposition_v1.md"
)
PHP3_REVIEW_ARTIFACT = (
    ROOT / "docs" / "_reviews" / "php3_canonical_contract_extraction_and_manifest_v1.md"
)
FROZEN_POST_SHIM_SHA256 = (
    "6ed420cdd53bc08790c27b6581f7dcc3fead04c43b295d8e2458bd45a394cfce"
)

EXPECTED_OBSERVED_TIER_B_COUNT = 117
EXPECTED_OBSERVED_TIER_C_COUNT = 304
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
PHP3_F17_TIER_B_PATHS = {
    "test/guards/early_world_feedback_quality_family_contract_test.dart",
    "test/guards/showable_spine_handoff_coherence_contract_test.dart",
    "test/guards/targeted_content_repairs_contract_test.dart",
    "test/guards/w10_to_w11_transition_policy_contract_test.dart",
    "test/ui_v2/session_summary_gold_containment_v1_test.dart",
    "test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart",
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


def _retired_paths_from_ledger(artifact: Path, dispositions: set[str]) -> set[str]:
    if not artifact.exists():
        return set()
    retired: set[str] = set()
    for raw in artifact.read_text().splitlines():
        if not raw.startswith("| `test/"):
            continue
        cells = [cell.strip() for cell in raw.strip().strip("|").split("|")]
        if len(cells) < 6:
            continue
        path = cells[0].strip("`")
        if any(f"`{disposition}`" in raw for disposition in dispositions):
            retired.add(path)
    return retired


def _ledger_retired_paths() -> set[str]:
    return _retired_paths_from_ledger(
        PHP2_REVIEW_ARTIFACT,
        {"DELETE_ARCHIVED_NONCANONICAL"},
    ) | _retired_paths_from_ledger(
        PHP3_REVIEW_ARTIFACT,
        {
            "ARCHIVED_NONCANONICAL_TEST_RETIRED",
            "EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED",
        },
    )


def validate() -> dict[str, object]:
    artifact_text = POST_SHIM_ARTIFACT.read_text()
    _require_artifact_measurements(artifact_text)
    frozen_sha256 = hashlib.sha256(POST_SHIM_ARTIFACT.read_bytes()).hexdigest()
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
    ledger_retired = _ledger_retired_paths()
    retired_tier_b = tier_d_set & observed_b_set
    retired_tier_c = tier_d_set & observed_c_set
    observed_tier_b_missing = sorted(observed_b_set - tier_b_set - retired_tier_b)
    observed_tier_b_extra = sorted(tier_b_set - observed_b_set)
    unexpected_tier_b_extra = sorted(
        set(observed_tier_b_extra) - PHP3_F17_TIER_B_PATHS
    )
    missing_php3_f17_tier_b = sorted(PHP3_F17_TIER_B_PATHS - tier_b_set)
    observed_tier_c_missing = sorted(observed_c_set - tier_c_set - retired_tier_c)
    executable_tier_c_extra = sorted(tier_c_set - observed_c_set)
    missing_known_registry = sorted(KNOWN_TIER_C_RESIDUALS - known_tier_c_set)
    unexpected_known_registry = sorted(known_tier_c_set - KNOWN_TIER_C_RESIDUALS)
    known_missing_from_executable_tier_c = sorted(KNOWN_TIER_C_RESIDUALS - tier_c_set)
    known_unreached_missing = sorted(KNOWN_UNREACHED_TIER_C - tier_c_set)
    known_unreached_extra = sorted(set(executable_tier_c_extra) - KNOWN_UNREACHED_TIER_C)
    missing_executable_paths = sorted(
        path
        for path in tier_b + tier_c
        if path.startswith("test/") and not (ROOT / path).exists()
    )
    tier_d_existing_paths = sorted(
        path for path in tier_d if path.startswith("test/") and (ROOT / path).exists()
    )
    tier_d_missing_ledger_evidence = sorted(tier_d_set - ledger_retired)
    unexpected_tier_d_paths = sorted(tier_d_set - observed_b_set - observed_c_set)
    unexplained_historical_disappearance = sorted(
        (observed_b_set | observed_c_set) - tier_b_set - tier_c_set - tier_d_set
    )

    observed_tier_b_exact_set_match = (
        not observed_tier_b_missing
        and not unexpected_tier_b_extra
        and not missing_php3_f17_tier_b
    )
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
    if frozen_sha256 != FROZEN_POST_SHIM_SHA256:
        failures.append(
            "frozen post-shim artifact bytes changed: "
            f"expected={FROZEN_POST_SHIM_SHA256} got={frozen_sha256}"
        )
    if duplicates:
        failures.append(f"duplicate manifest paths: {duplicates[:10]}")
    if not observed_tier_b_exact_set_match:
        failures.append(
            "observed Tier B drift: "
            f"missing={observed_tier_b_missing[:10]} "
            f"unexpected_extra={unexpected_tier_b_extra[:10]} "
            f"missing_php3_f17={missing_php3_f17_tier_b[:10]}"
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
    if tier_d_set & tier_b_set or tier_d_set & tier_c_set:
        failures.append(
            "Tier D overlaps executable manifest: "
            f"{sorted((tier_d_set & tier_b_set) | (tier_d_set & tier_c_set))[:10]}"
        )
    if missing_executable_paths:
        failures.append(
            f"executable manifest paths do not exist: {missing_executable_paths[:10]}"
        )
    if tier_d_existing_paths:
        failures.append(
            f"Tier D tombstones still exist in working tree: {tier_d_existing_paths[:10]}"
        )
    if tier_d_missing_ledger_evidence:
        failures.append(
            "Tier D paths lack approved PHP-2/PHP-3 ledger evidence: "
            f"{tier_d_missing_ledger_evidence[:10]}"
        )
    if unexpected_tier_d_paths:
        failures.append(
            f"Tier D paths are absent from frozen historical inventory: {unexpected_tier_d_paths[:10]}"
        )
    if unexplained_historical_disappearance:
        failures.append(
            "historical paths disappeared without executable or Tier-D accounting: "
            f"{unexplained_historical_disappearance[:10]}"
        )

    result = {
        "observed_tier_b_exact_set_match": observed_tier_b_exact_set_match,
        "observed_tier_c_exact_set_match": observed_tier_c_exact_set_match,
        "observed_unique_non_green": len(observed),
        "observed_tier_b_count": len(observed_b),
        "observed_tier_c_count": len(observed_c),
        "executable_tier_b_count": len(tier_b),
        "executable_tier_c_count": len(tier_c),
        "tier_d_tombstone_count": len(tier_d),
        "tier_b_to_d_retired_count": len(retired_tier_b),
        "tier_c_to_d_retired_count": len(retired_tier_c),
        "frozen_post_shim_sha256": frozen_sha256,
        "observed_tier_b_missing": observed_tier_b_missing,
        "observed_tier_b_extra": observed_tier_b_extra,
        "php3_f17_tier_b_count": len(PHP3_F17_TIER_B_PATHS),
        "php3_f17_tier_b_missing": missing_php3_f17_tier_b,
        "unexpected_tier_b_extra": unexpected_tier_b_extra,
        "observed_tier_c_missing": observed_tier_c_missing,
        "tier_c_known_unreached_additions": tier_c_known_unreached_additions,
        "known_residuals_subset_of_executable_tier_c": known_residuals_subset_of_executable_tier_c,
        "known_residuals_missing_from_executable_tier_c": known_missing_from_executable_tier_c,
        "tier_b_tier_c_overlap": len(overlap),
        "duplicates": duplicates,
        "missing_executable_paths": missing_executable_paths,
        "tier_d_existing_paths": tier_d_existing_paths,
        "tier_d_missing_ledger_evidence": tier_d_missing_ledger_evidence,
        "unexplained_historical_disappearance": unexplained_historical_disappearance,
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
