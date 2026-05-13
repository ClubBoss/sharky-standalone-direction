# Execution Rules

Status: ACTIVE FOR RELEASE CONFIDENCE
Purpose: machine-visible execution rules presence for publish-critical release
guards and canonical release checks.
Last updated: 2026-03-29

## Authority

Use this file for release-confidence execution rules that must stay in sync with
the canonical publish-path contracts and snapshot tooling.

This file does not replace:

- `docs/README.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`

Historical execution protocol reference remains at:

- `docs/reference/history/EXECUTION_RULES.md`

## Learner-Language Contract

- Purpose: keep learner-visible copy plain, trustworthy, and usable during F3/content waves without creating a separate style manual.
- Scope: learner-visible `prompt`, `why_v1`, and feedback strings.
- Rule: internal content taxonomy or modeling language may stay abstract/systemic, but learner-visible strings must translate that into natural poker language.
- Rule: internal precision does not justify unnatural learner-facing wording.
- Rule: prompts must be short and plain.
- Rule: `why_v1` should express one human poker idea.
- Rule: feedback should explain the poker reason in natural English.
- Rule: learner-visible language must be plain, natural, and non-internal.
- Rule: keep one poker idea per learner-visible line.
- Rule: do not write learner-visible copy in internal framework vocabulary.
- Direction:
  - prefer words like `safe`, `dangerous`, `pressure`, `playable`, `stronger`, `weaker`, `still good`, `getting worse`, `slow down`, `keep betting`
  - avoid wording like `context stable`, `coverage`, `upgrade`, `flattening`, `verify exposure level`, `depth-pressure`, and similar system-sounding abstractions
- Execution binding: future F3/content waves must follow this contract.
- Scope guard: this governance rule does not trigger a broad rewrite in the current wave.
- Future-proofing: this contract may later become auditable or guardrailed, but that is future work, not the purpose of this doc-only pass.

## Store Package guard

- The store guard is off by default unless `STORE_PACKAGE_GUARD=1` is set.
- The guard skips when `out/modern_table_screenshots_v1.zip` is missing and
  only activates during Store Package preparation / release checklist.
- The enforced repo proof path is `out/modern_table_screenshots_v1.zip` with
  supporting notes in `docs/release/store_assets_v1.md`.
- `assets/store/` remains optional import storage and is not the enforced
  mainline proof path.
- Guard command:
  `STORE_PACKAGE_GUARD=1 dart test test/contracts/store_package_assets_contract_test.dart -r expanded --concurrency=1 --timeout 2m`

## Store Package telemetry guard

- Purpose: verify release-critical telemetry references exist before release.
- Command:
  `dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m`

## Release Dry-Run Gate

- Run before any pre-release build run.
- Preferred tooling: run `tool/release_dry_run_gate.sh` locally.

1. `STORE_PACKAGE_GUARD=1 dart test test/contracts/store_package_assets_contract_test.dart -r expanded --concurrency=1 --timeout 2m`
2. `dart test test/contracts/store_package_docs_sync_contract_test.dart -r expanded --concurrency=1 --timeout 2m`
3. `dart test test/contracts/store_package_execution_rules_sync_contract_test.dart -r expanded --concurrency=1 --timeout 2m`
4. `dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m`
5. `RELEASE_CONTENT_GUARD=1 dart test test/contracts/release_content_meaningful_contract_test.dart -r expanded --concurrency=1 --timeout 2m`

- Passing means store docs, guard commands, telemetry guard, and release content
  guard are aligned for the canonical publish path.

## Release Smoke Baseline

- Run to verify the bounded runtime critical-flow family claimed by the current
  release-confidence owner docs.
- Preferred tooling: run `tool/release_smoke_baseline_v1.sh` locally.

1. `flutter test test/guards/app_boot_release_smoke_test.dart`
2. `flutter test test/ui_v2/onboarding_first_win_test.dart`
3. `flutter test test/guards/world1_intake_plan_flow_contract_test.dart`
4. `flutter test test/ui_v2/session_result_world1_onboarding_payoff_test.dart`
5. `flutter test test/ui_v2/today_plan_entitlement_truth_v1_test.dart`
6. `flutter test test/ui_v2/premium_hub_access_state_v1_test.dart`
7. `flutter test test/guards/world_campaign_map_home_contract_test.dart --plain-name "today plan gates world5 placement behind premium preview and restore unblocks next attempt"`
8. `flutter test test/guards/world_campaign_map_home_contract_test.dart --plain-name "today plan allows trial-active entitlement to open premium-target placement deterministically"`
9. `flutter test test/ui_v2/legal_screen_v1_test.dart`

- Passing means the bounded current-main smoke family covers:
  - boot to canonical entry
  - onboarding/intake to Today
  - first-session result continuation
  - premium entry and premium-target gating visibility
  - in-app legal surface presence
- It remains a bounded smoke family, not a full-product GO gate.

## Release Readiness Snapshot

- Snapshot path: `tools/release_readiness_snapshot_v1.dart`
- Command: `dart run tools/release_readiness_snapshot_v1.dart`
- Baseline owner: `docs/release/release_confidence_baseline_v1.md`
- Full-product checklist owner: `docs/release/final_product_release_checklist_v1.md`
- Smoke baseline owner: `docs/release/final_product_smoke_baseline_v1.md`
- Go/hold/rollback owner: `docs/release/go_hold_rollback_truth_v1.md`
- Human review owner: `docs/release/release_owner_review_v1.md`
- Rollback ownership owner: `docs/release/rollback_ownership_truth_v1.md`
- Executable smoke runner: `tool/release_smoke_baseline_v1.sh`
- Use this as the non-blocking bounded release-confidence snapshot between
  release waves.
- It is not a GO verdict and does not claim full-product release coverage on its
  own.
- The active runtime gate remains `tools/release_gate_world1.sh`; the owner
  docs above record what is covered now versus what still needs human proof.
- Launch/readiness scoring authority remains `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`.
- Active product route authority remains `docs/plan/MASTER_PLAN_v3.0.md`.

## Operational Confidence Baseline

- Baseline owner: `docs/release/operational_confidence_baseline_v1.md`
- Use this owner to state what current `main` can and cannot operationally
  observe without inventing a broader analytics program.
- Current bounded machine-proof seam:
  - `dart test test/contracts/telemetry_release_critical_integrity_test.dart`
  - `dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m`
  - `dart run tools/release_readiness_snapshot_v1.dart`
- It is a bounded operational-confidence baseline, not a governed dashboard or
  post-launch ops verdict.
- `docs/release/RELEASE_README.md` is historical snapshot material and is not
  an active operational-confidence owner.

## Operational Review Packet

- Packet owner: `docs/release/operational_review_packet_truth_v1.md`
- Packet runner: `tools/operational_review_packet_v1.dart`
- Command:
  `dart run tools/operational_review_packet_v1.dart --timestamp <iso8601> --write`
- Output artifacts:
  - `release/_reports/operational_review_packet_v1.md`
  - `release/_reports/operational_review_packet_v1.json`
- This is a bounded local operational review artifact, not a governed
  dashboard, backend analytics system, or post-launch ops verdict.
