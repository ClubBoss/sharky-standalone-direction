# Wave 3.9 - English-First / RU Localization Boundary v1

## 1. Verdict

wave3_9_english_first_ru_localization_boundary_ready

## 2. TOP1 Matrix Row Target

This closes the English-first release safety row for the TOP1 public-readiness sequence: the showable v1 route must not look like a partially mixed English/Russian product unless RU localization is intentionally launched.

## 3. Wave Goal / Scope

Goal: prove the active Act0 release path is English-first and that any Russian/Cyrillic source remains dormant, opted-in, test/dev-only, or explicitly deferred.

Scope kept narrow:

- Active route/source inventory audit.
- Screenshot packet proof for release-visible packets.
- One P1 release-safety fix where the app default locale was Russian on fresh install.
- No RU localization rollout.
- No broad copy rewrite.
- No selector, i18n migration, route, progression, monetization, telemetry, achievement, table, or content change.

## 4. Evidence Inspected

Active route and source inventory:

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/wave3_7_release_visible_content_depth_gate_v1.md`
- `docs/_reviews/wave3_8_value_packaging_premium_timing_v1.md`
- `lib/ui_v2/app_root.dart`
- `lib/services/app_language_controller.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
- `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- Active Act0 shell files under `lib/ui_v2/act0_shell/`
- Focused localization tests under `test/services/` and `test/guards/`

Screenshot packets inspected:

- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/full_scroll_fast/`

## 5. English-First Release Finding

The release path is now English-first by default.

Before this wave, `AppLanguageController` initialized, defaulted, and failed over to `Locale('ru')` when no saved preference existed. That made a fresh public install capable of entering Russian copy paths in active surfaces that use `Localizations.localeOf(context)` directly.

This was fixed by changing the launch default and error fallback to `Locale('en')`. Saved preferences are still respected, including saved RU, so this is not a localization removal.

Screenshot text metadata after the fix contains no Cyrillic for:

- `day2_return_fast`
- `first_week_fast`
- `full_scroll_fast`

## 6. Russian / Cyrillic Source Audit

Russian/Cyrillic source remains present, but it is not treated as launched release copy.

Findings:

- `act0_content_copy_v1.dart` keeps active content atom routing English-first through the current fallback path.
- Several active Act0 shell files still contain RU branches behind helpers that currently return `false`; these are dormant branches, not public release copy.
- `act0_copy_ru_v1.dart` remains a RU copy bundle. It is deferred source, not a Wave 3.9 launch.
- The Act0 preview shell contains dev/preview language controls with Russian labels. This is preview/dev tooling, not a new public language selector.
- Docs, tests, and comments contain Russian/Cyrillic strings. Those are not release UI blockers unless surfaced through the active runtime route.

## 7. Mixed-Copy Finding

No release-visible mixed English/Russian copy was found after the fix.

The concrete P1 was not a screenshot-visible mixed string; it was the fresh-install locale default. With the app defaulting to English, active route surfaces are protected from accidental RU selection unless a saved/explicit RU preference exists.

## 8. Localization Boundary Finding

RU localization remains deferred.

This wave did not:

- Launch Russian localization.
- Add a public language selector.
- Translate the app.
- Migrate or expand localization architecture.
- Remove existing RU assets or supported locale definitions.
- Rewrite dormant RU branches.

The boundary is now: public v1 defaults to English; RU remains source-available and opt-in/deferred until a deliberate localization rollout.

## 9. Claim-Safety Finding

The change does not add or activate claims about AI, leak detection, mastery, GTO, solver behavior, premium entitlement, pricing, or all-course completion.

Claim-related search hits remain in existing docs, tests, internal review artifacts, or unrelated source contexts. No new launch-facing claim family was introduced by this wave.

## 10. P0 Blockers

None found.

No screenshot packet showed Cyrillic or mixed release copy after the default-locale fix.

## 11. P1 Blockers

One P1 was found and fixed.

Issue: fresh installs defaulted to Russian through `AppLanguageController`.

Impact: release users without a saved preference could see RU copy from active surfaces that read `Localizations.localeOf(context)`.

Fix: change the controller default and fallback locale to English while preserving saved RU restoration.

## 12. P2 / Deferred Mapping

Deferred work:

- Full RU localization rollout and QA.
- Public language selector policy, if localization becomes a release feature.
- Copy architecture cleanup if future localization work needs a stronger contract.
- Store/public readiness packet proof after this English-first boundary is closed.

## 13. Implementation Summary

Changed:

- `lib/services/app_language_controller.dart`
  - Default locale changed from RU to EN.
  - No-saved-preference fallback changed from RU to EN.
  - Error fallback changed from RU to EN.
  - Comment updated to state English-first public v1 and deferred RU rollout.
- `test/services/app_language_controller_test.dart`
  - Default expectation updated to English.
  - Same-language behavior adjusted from an English default.
  - Invalid-language guard now confirms English remains selected.
  - Saved RU restoration remains covered.

## 14. Copy Changes, If Any

The only release-facing copy-adjacent change is the locale default policy.

Old behavior:

- Fresh install selected RU by default.

New behavior:

- Fresh install selects EN by default.
- Saved RU preference still restores RU.

Why safe:

- This enforces the English-first v1 boundary without pretending RU localization is complete.
- It avoids mixed release copy without deleting localization source.

## 15. Boundary Proof

No route, progression, telemetry, monetization, achievement, table, drill, review, profile, session-summary, or content model was changed.

No generated screenshot or output directory was staged.

Only the locale controller, its focused test, and this review artifact are in scope.

## 16. Anti-Theater Proof

This was not a visual-only screenshot pass. The audit found a real runtime default-locale risk and fixed it at the source of app locale selection.

The proof includes:

- Source inventory scan.
- Screenshot packet reruns.
- Metadata scan for Cyrillic in generated packet text.
- Focused controller test.
- AppRoot localization wiring guard.

## 17. Expected TOP1 Confidence Movement

Expected movement: modest but real.

Reason: this closes a release-trust risk where a premium/public packet could accidentally look partially localized. It does not expand product value, content depth, or monetization, but it improves showability and commercial readiness hygiene.

## 18. Validation Run

Passed:

- `flutter test test/services/app_language_controller_test.dart`
- `flutter test test/guards/app_root_localizations_contract_test.dart`
- `dart format --set-exit-if-changed lib/services/app_language_controller.dart test/services/app_language_controller_test.dart`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `flutter analyze`
- `git diff --check`
- `graphify hook-check`

Post-screenshot text metadata scan found no Cyrillic in the three current compact packet output directories.

## 19. Screenshot Packets Run

Rerun after the fix:

- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/full_scroll_fast/`

Generated artifacts are local-only and remain untracked.

## 20. Caveats

The codebase still contains RU source and dev/test references. That is acceptable for this wave because the release boundary is English-first default behavior, not deletion of localization source.

Future localization work should be an explicit rollout with its own public selector, QA packet, and acceptance criteria.

## 21. Next Recommendation

Proceed to Wave 4.0 Store / Public Readiness Packet v1.
