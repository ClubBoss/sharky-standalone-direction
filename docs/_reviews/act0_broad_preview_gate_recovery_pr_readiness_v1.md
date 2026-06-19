# Act0 Broad Preview Gate Recovery PR Readiness v1

## 1. Files changed in the total recovery diff

The current worktree is a broad accumulated recovery diff, not a narrow single-file patch.

Tracked modified files currently include:

- Act0 shell/runtime files:
  - `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
  - `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart`
  - `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
  - `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
  - `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
  - `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
  - `lib/ui_v2/app_root.dart`
- Tests:
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - premium/payment/entitlement tests touched by earlier waves
- Monetization/payment/entitlement service files:
  - `lib/payments/payment_service.dart`
  - `lib/services/entitlement_ssot_v1.dart`
  - `lib/services/premium_restore_flow_v1.dart`
  - `lib/services/premium_service.dart`
  - `lib/services/premium_value_package_v1.dart`
  - `lib/services/release_premium_access_action_v1.dart`
  - `lib/services/subscription_surface_copy_v1.dart`
  - `lib/services/trial_service_v1.dart`
- Plan/docs files:
  - monetization and readiness plan docs
  - accumulated `docs/_reviews/*` review artifacts
- Tooling:
  - `tools/act0_controlled_demo_capture_v1.sh`
  - `.gitignore`

Untracked files also include review artifacts, repair-intent files/tests, entitlement ledger files/tests, first-week capture tooling, and `output/playwright/*` proof outputs.

This wave added:

- `docs/_reviews/act0_broad_preview_gate_recovery_pr_readiness_v1.md`

This wave also allowed `./tools/release_gate_world1.sh` to mechanically format:

- `test/ui_v2/premium_hub_access_state_v1_test.dart`

## 2. Gate status

Green.

The broad Act0 preview recovery gate is currently passing.

## 3. Product decisions locked

- Act0 shell preview remains the active runtime surface.
- World-completion retention return behavior remains product truth.
- The stale retention copy `Still yours? Run this spot once more.` is not the locked product copy.
- The locked retention return copy is `Still yours? One calm replay keeps it honest.`
- Home continues to expose the safe return path through `Check confidence` without exposing `retentionSequence` or `agedRecheck`.
- Repair-intent work remains deterministic and local; no AI, ML, solver, GTO, win-rate, commerce, trial, or paywall claims were added by this verification wave.

## 4. Test-contract updates

The accumulated preview recovery refreshed stale assertions across:

- Home route and retention harnesses.
- Learn route harnesses.
- Profile dead-layout contracts.
- Review repair harnesses.
- Placement and Welcome harnesses.
- Compact runner geometry/navigation assertions.
- World-completion retention return copy.

The final blocker test now protects the current calmer retention copy.

## 5. Product fixes

Accumulated product fixes in the current recovery branch include Act0 shell/runtime fixes around:

- repair-intent contract/lifecycle/resolver/copy guard;
- review repair and retention behavior;
- first-value/retention return paths;
- Act0 shell route/test contract stabilization.

This pre-PR gate wave did not add product behavior. It only ran verification, allowed mechanical format cleanup, and added this readiness report.

## 6. Deferred items, if any

No release-gate failures remain.

Scope deferred for PR packaging:

- The current worktree contains monetization/payment/entitlement changes and screenshot/capture output/tooling files that are outside a narrow Act0 broad-preview recovery PR.
- Those files may be valid from prior accepted waves, but they should not be silently bundled into a PR titled only as Act0 broad preview gate recovery without explicit PR scope.

## 7. Scope-safety verdict

Gate safety: green.

PR scope safety: conditional.

The Act0 recovery gate is verified, and this verification wave did not introduce new features, visual polish, route changes, commerce behavior, screenshot tooling, or repair-intent expansion.

However, the current total worktree diff is not scope-clean for a narrow Act0-only PR because it already includes:

- monetization/payment/entitlement files;
- premium/trial/restore tests;
- capture tooling;
- untracked Playwright proof outputs.

Recommendation: either split the PR into scope-specific commits/PRs or make the PR description explicitly declare the broader accumulated recovery scope.

## 8. Release-gate result

First attempt:

- `./tools/release_gate_world1.sh`
- Result: stopped at format step after formatting `test/ui_v2/premium_hub_access_state_v1_test.dart`.

Second attempt:

- `./tools/release_gate_world1.sh`
- Result: passed.
- Output ended with `World1 release gate passed.`

Additional checks:

- `flutter analyze`: passed, no issues.
- `git diff --check`: passed.
- `./tools/fast_loop_world1_v1.sh`: passed, `+679`, `FAST LOOP PASS`.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`: passed, `+656`.
- Four repair-intent tests: passed, `+28`.

## 9. PR recommendation

Technically ready from a gate perspective.

Not ready as a narrow Act0-only PR unless the existing monetization/payment/capture/output changes are split out or explicitly admitted into the PR scope.

Recommended PR framing if kept together:

- "Act0 broad preview gate recovery and associated readiness artifacts"

Recommended safer integration path:

1. Keep the verified Act0 gate recovery changes together.
2. Split commerce/premium/payment and capture-output artifacts into their own scoped PRs, unless already intentionally accepted as part of this release bundle.
3. Re-run `./tools/release_gate_world1.sh` after any split.
