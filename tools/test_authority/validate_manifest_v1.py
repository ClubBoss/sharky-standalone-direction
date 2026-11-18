#!/usr/bin/env python3
"""Validate the executable PR test lanes; historical measurements are not roots."""

import argparse
import ast
import collections
import json
import os
from pathlib import Path, PurePosixPath
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_DIR = Path(os.environ.get(
    "TEST_AUTHORITY_MANIFEST_DIR", ROOT / "tools/test_authority/manifests"
))

# Keep the pre-A0b PR contracts in either active lane. Proven additions need only join the manifest,
# rather than a second whitelist or a historical quarantine accounting ledger.
REQUIRED_PR_CONTRACTS = {
    'test/guards/early_world_feedback_quality_family_contract_test.dart',
    'test/guards/showable_spine_handoff_coherence_contract_test.dart',
    'test/guards/targeted_content_repairs_contract_test.dart',
    'test/guards/w10_to_w11_transition_policy_contract_test.dart',
    'test/services/loc01_language_persistence_test.dart',
    'test/tools/session_world_truth_surface_audit_v1_test.dart',
    'test/tools/world0_dealer_button_index_copy_convergence_test.dart',
    'test/tools/world3_preflop_hand_chain_validator_convergence_test.dart',
    'test/tools/world_route_ownership_inventory_v1_test.dart',
    'test/tools/world_screenshot_evidence_audit_v1_test.dart',
    'test/tools/world_visual_instrumentation_audit_v1_test.dart',
    'test/ui_v2/act0_completed_decision_callback_contract_v1_test.dart',
    'test/ui_v2/act0_first_table_setup_grading_v1_test.dart',
    'test/ui_v2/act0_instruction_content_policy_v1_test.dart',
    'test/ui_v2/act0_main01_app_root_cycle_v1_test.dart',
    'test/ui_v2/act0_onb02_disposition_ack_v1_test.dart',
    'test/ui_v2/act0_persistence_roundtrip_v1_test.dart',
    'test/ui_v2/act0_positions_theory_persistence_truth_v1_test.dart',
    'test/ui_v2/act0_repair_day2_reference_v1_test.dart',
    'test/ui_v2/act0_repair_learning_goal_v1_test.dart',
    'test/ui_v2/act0_skl01_evidence_state_v1_test.dart',
    'test/ui_v2/act0_w01_theory_source_truth_v1_test.dart',
    'test/ui_v2/act0_w24_context_recap_v1_test.dart',
    'test/ui_v2/act0_w4_w7_owner_contract_decomposition_v1_test.dart',
    'test/ui_v2/cnt01_role_inventory_v1_test.dart',
    'test/ui_v2/session_result_world1_onboarding_payoff_test.dart',
    'test/ui_v2/session_summary_gold_containment_v1_test.dart',
    'test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart',
}


def _entries(path):
    if not path.is_file():
        raise AssertionError(f"missing manifest: {path}")
    return [line.strip() for line in path.read_text().splitlines()
            if line.strip() and not line.lstrip().startswith("#")]


def _tier_a_paths():
    paths = set()
    runner = ROOT / "tools/test_authority/run_lane_v1.py"
    for node in ast.parse(runner.read_text()).body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "TIER_A_COMMANDS"
            for target in node.targets
        ):
            for command in ast.literal_eval(node.value):
                for arg in command["cmd"]:
                    if not arg.startswith("test/"):
                        continue
                    path = ROOT / arg
                    if path.is_dir():
                        paths.update(str(p.relative_to(ROOT)) for p in path.rglob("*_test.dart"))
                    else:
                        paths.add(arg)
    selected = ROOT / "tools/_world1_selected_tests_v1.sh"
    paths.update(re.findall(r"test/[\w/.-]+_test\.dart", selected.read_text()))
    return paths


def validate():
    tier_b = _entries(MANIFEST_DIR / "tier_b_maintained_support.txt")
    tier_a = _tier_a_paths()
    duplicates = sorted(path for path, count in collections.Counter(tier_b).items() if count > 1)
    invalid = sorted(path for path in tier_b if (
        not path.startswith("test/") or not path.endswith("_test.dart")
        or ".." in PurePosixPath(path).parts or PurePosixPath(path).as_posix() != path
        or not (ROOT / path).resolve().is_relative_to(ROOT / "test")
    ))
    missing = sorted(path for path in tier_a | set(tier_b) if not (ROOT / path).is_file())
    required_missing = sorted(REQUIRED_PR_CONTRACTS - (tier_a | set(tier_b)))
    overlap = sorted(tier_a & set(tier_b))
    result = {
        "tier_a_file_count": len(tier_a),
        "executable_tier_b_count": len(tier_b),
        "duplicates": duplicates,
        "invalid_test_paths": invalid,
        "missing_executable_paths": missing,
        "required_pr_contracts_missing": required_missing,
        "tier_a_tier_b_overlap": overlap,
    }
    if duplicates or invalid or missing or required_missing or overlap:
        raise AssertionError(json.dumps(result, indent=2))
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    try:
        result = validate()
    except (AssertionError, OSError, ValueError) as error:
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
