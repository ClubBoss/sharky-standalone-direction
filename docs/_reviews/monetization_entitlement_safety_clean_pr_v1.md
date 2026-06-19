# Monetization Entitlement Safety Clean PR v1

## Branch and Base

- Branch: `codex/monetization-entitlement-safety`
- Base: `main` at `87ca103`
- Backup source: `origin/codex/backup-full-project-worktree-2026-06-19`

## Scope Restored From Backup

This PR slice restores the monetization safety layer only: entitlement ledger state, local restore/purchase convergence, trial safety projection, premium value package contracts, and matching service/UI contract tests.

Included files are limited to:

- `lib/payments/payment_service.dart`
- `lib/services/entitlement_ledger_v1.dart`
- `lib/services/entitlement_ssot_v1.dart`
- `lib/services/premium_restore_flow_v1.dart`
- `lib/services/premium_service.dart`
- `lib/services/premium_value_package_v1.dart`
- `lib/services/release_premium_access_action_v1.dart`
- `lib/services/subscription_surface_copy_v1.dart`
- `lib/services/trial_service_v1.dart`
- matching payment/service/UI contract tests
- monetization and entitlement review artifacts

## Files Explicitly Excluded

Excluded from this branch:

- capture tooling
- generated proof outputs
- Playwright output folders
- CI/workflow rationalization
- competitive or external research
- broad route changes
- Act0 gate recovery work already merged in PR #1

`external_competitors/` remains local and untracked.

## Product Constraints Confirmed

This branch does not introduce:

- public purchase UI launch
- hard paywall
- public pricing surface
- public trial launch
- Premium Hub route activation as a launch default
- commerce entitlement claims outside local safety contracts

The restored contracts keep public paywall exposure hidden and commerce safety false unless a future production commerce wave explicitly changes that policy.

## Public Monetization Launch Status

Public monetization remains inactive in this slice. The entitlement ledger records local states and restore outcomes, but it does not make trial, purchase, paywall, pricing, or Premium Hub a public launch route.

## Entitlement, Restore, and Trial Safety Contracts

The restored contract covers:

- legacy premium/trial key migration into an append-only ledger projection
- trial active, expired, rollback, and eligibility states
- local restore pending, restored, no-purchase, and failed outcomes
- non-authoritative product-cache convergence
- local premium access projection without public-commerce safety
- paywall and Premium Hub hidden flags for MVP states

## Tests Run

- `flutter test test/payments/payment_service_restore_verification_policy_v1_test.dart test/services/entitlement_ledger_v1_test.dart test/services/premium_restore_flow_v1_test.dart test/services/premium_value_package_v1_contract_test.dart test/services/release_premium_access_action_v1_test.dart test/ui_v2/premium_hub_access_state_v1_test.dart test/ui_v2/today_plan_entitlement_truth_v1_test.dart --reporter expanded`

Further gate verification should run before commit:

- `dart format` on touched Dart files
- `flutter analyze`
- `git diff --check`
- `./tools/fast_loop_world1_v1.sh`
- `./tools/release_gate_world1.sh`

## Known Non-Goals

This wave does not create or expose a production commerce path. It does not add payment provider configuration, subscription validation backend work, trial onboarding, pricing, purchase/restore UI activation, analytics dashboards, capture tooling, screenshot tooling, or competitive research.

## PR Readiness Verdict

Ready for clean PR verification once the remaining required gates pass on this branch.
