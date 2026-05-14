# Final Product Release Checklist v1

## Purpose

This file is the canonical owner for current-main full-product release checklist
truth.

It is not a GO verdict, not a completion claim, and not a substitute for final
human release review.

## Checklist Scope

- Scope: current-main final-product release checklist baseline
- Coverage policy: record what current `main` can actually prove today
- Decision policy: checklist presence does not imply launch approval

## Machine-Proven Checklist Items On Current Main

- Release-confidence baseline owner exists:
  `docs/release/release_confidence_baseline_v1.md`
- Release dry-run gate owner exists:
  `tool/release_dry_run_gate.sh`
- Active scoped runtime release gate exists:
  `tools/release_gate_world1.sh`
- Executable bounded smoke runner exists:
  `tool/release_smoke_baseline_v1.sh`
- Boot-to-canonical-entry smoke exists:
  `test/guards/app_boot_release_smoke_test.dart`
- Onboarding starter pack host proof exists:
  `test/ui_v2/onboarding_first_win_test.dart`
- Cold-start intake to Today/start proof exists:
  `test/guards/world1_app_root_startup_contract_test.dart`
- Session-result continuation proof exists:
  `test/ui_v2/session_result_world1_onboarding_payoff_test.dart`
- Premium-target gating truth exists on the canonical Today family:
  `test/guards/world_campaign_map_home_contract_test.dart`
- Premium entry/lifecycle access-state proof exists:
  `test/ui_v2/premium_hub_access_state_v1_test.dart`
- Branch progression boundary proof exists:
  `test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart`
- Legal surface presence proof exists:
  `test/ui_v2/legal_screen_v1_test.dart`
- Store/support/legal/package truth guards exist:
  `test/contracts/store_package_docs_sync_contract_test.dart`

## What This Widens Beyond The Older Bounded Beta Slice

- Current-main release checklist proof is wider than the old world1-only beta
  reading.
- The bounded checklist now includes:
  - continuation after first-session result
  - premium-entry and premium-target route truth
  - branch progression boundary isolation
  - legal/runtime support presence
  - release-doc/store-package guard families
- It still does not prove complete full-product route breadth.

## Current Bounded Proof On Main

- `dart run tools/release_readiness_snapshot_v1.dart` must continue to report:
  - `fullProductChecklistPresent = true`
  - `fullProductChecklistSaysCurrentMain = true`
  - `fullProductChecklistSaysNotGo = true`
  - `goNoGoStateIsHold = true`
  - `moduleLauncherBoundaryContractPresent = true`
- This owner records current-main checklist truth only; it does not prove final
  release completion or whole-product machine clearance

## Human-Proof Required Before Final Launch

- Human walkthrough of the final-product path breadth beyond the bounded world1
  runtime gate
- Release-owner review that the machine checklist still matches the actual
  product surface
- Store-console verification of submission materials and policy-facing fields
- Bounded operational review using
  `docs/release/operational_review_packet_truth_v1.md`
- Explicit decision review using `docs/release/go_hold_rollback_truth_v1.md`
- Any stronger human decision artifact must use
  `docs/release/release_owner_decision_template_v1.md`
- Human review owner:
  `docs/release/release_owner_review_v1.md`

## Unresolved On Current Main

- No machine owner proves every finished world/path in one full-product runtime
  pass
- The active runtime release gate is still world1-scoped
- The checklist is a truth owner for current main, not proof that all required
  human steps are complete
- Rollback ownership remains explicit but unresolved in:
  `docs/release/rollback_ownership_truth_v1.md`

## Guardrail

If a release-confidence surface claims the full finished app is machine-cleared,
that claim must be backed by a newer active owner than this checklist.
Otherwise it is overclaimed.
