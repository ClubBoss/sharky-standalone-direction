# Beta Surface Cleanup Wave v1

## 1. Verdict

beta_surface_cleanup_ready_with_remaining_drill_blocker

## 2. Source audit alignment

Aligned to `docs/_reviews/showable_beta_readiness_audit_v1.md`.

Addressed the visible showable-beta risks called out there:

- Practice no longer presents the surface as a broad drill gym.
- Profile no longer renders Level / XP / rating-style RPG proof in the visible hero and snapshot strip.
- Review empty and recovered-note states no longer imply fake history, recovered status, or resolved/fixed semantics.
- Home repair CTA copy no longer says "Fix this now" or frames the task as a leak claim.

## 3. Surfaces changed

- `Act0PlayShellV1`
- `Act0ProfileShellV1`
- `Act0ReviewShellV1`
- `Act0HomeShellV1`
- Act0 preview recommendation copy in `Act0ShellPreviewScreenV1`
- Focused Play/Profile/Review/Preview tests

No route, progression, telemetry, data model, queue resolver, Review resolution, premium, or Modern Table code was changed.

## 4. Practice cleanup

Practice was narrowed from broad drill-gym language to showable-beta-safe short-rep language:

- `Sharpen your game` -> `Useful reps`
- `Short reps. Real spots. Stronger decisions.` -> `Repair and short reps available now.`
- `Topic reps` -> `Short reps`
- broad route-growth hints now say small practice areas open as the route grows
- locked summary now says `More drills coming later`
- disabled repair CTA fallback now says `Not ready yet`

The existing Practice repair queue CTA behavior and queue rows were not changed.

## 5. Profile/RPG claim cleanup

Profile keeps the same state inputs but no longer exposes the Level / XP presentation as visible beta proof:

- hero title now renders `Learning profile`
- hero progress text now renders `Recent route proof`
- snapshot strip no longer labels or renders XP
- repair-result copy was softened to replay-note language

The underlying profile state fields remain intact for compatibility; this wave only changed the visible beta surface.

## 6. Review empty/clean state cleanup

Review now avoids fake backlog/history and no longer frames past notes as recovered/fixed:

- empty state now says `No misses saved yet`
- empty body now says useful misses appear after a hand is worth repeating
- `Recovered lately` became `Worth replaying`
- recovered/fixed card status became `Replay`
- clean-state support now says useful replay notes stay below

No Review history implementation or resolution state was added.

## 7. Home CTA safety check

Home/preview repair CTA copy was softened:

- `Fix this now` -> `Practice this spot`
- `Fix a deep leak` -> `Practice one deep spot`
- `Deep leak` visible recommendation label -> `Deep repair`
- leak outcome copy now describes a practice pass for a spot

The CTA still uses the existing target and launch path. No route family or progression behavior changed.

## 8. Learn/future breadth cleanup

No Learn route behavior or content was changed. This wave only adjusted visible breadth language where Practice/Home/Profile/Review were overstating current beta capability.

Remaining Learn/future breadth work should stay deferred unless a future audit finds visible overclaiming on the active Learn surface.

## 9. Premium/deferred surface check

No premium/paywall mechanics, entitlement logic, trial copy, or purchase path was changed. Existing premium-preview internals remain out of scope.

Deferred surfaces not changed:

- Modern Table additive stack labels
- premium/paywall
- broader onboarding/Sharky intro
- route/content expansion

## 10. Claim-safety proof

Focused tests now assert the cleaned surfaces avoid the risky visible claim families:

- Profile visible text does not contain Level, Lv, XP, rating/radar/skill-score, strongest/weakest, or mastered wording.
- Review past notes do not render Recovered, Fixed, Cleared, or Resolved copy.
- Practice repair queue tests continue to assert no fixed/cleared/resolved, AI, GTO, solver, premium, mastery, or leak claims in queue rows.

Internal identifiers such as `fixedMistakes`, XP fields, and premium preview APIs were not renamed because that would be a data/model or entitlement refactor outside this wave.

## 11. Tests / validation

Passed:

- `flutter test test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_profile_claim_safety_v1_test.dart test/ui_v2/act0_profile_evidence_consumer_v1_test.dart test/ui_v2/act0_achievement_seed_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Debug Day 2 proof surfaces expose open repair return story|Practice CTA for repair recommendation launches the owned repair target"`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `graphify hook-check`
- `flutter analyze`
- `dart format --set-exit-if-changed` on touched Dart/test files
- `git diff --check`

Known baseline not opened:

- The full preview file remains broad baseline debt and was not used as a repo-wide repair target in this wave.

## 12. Screenshot proof

Generated local-only screenshot packets:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/full_scroll_fast/`

Generated screenshots/zips remain untracked and must not be committed.

## 13. Remaining beta blockers

Remaining blockers after this cleanup:

- Real drill-quality/readiness still needs its own bounded drill proof wave.
- Full preview baseline debt remains outside this wave.
- Any future premium/paywall readiness must stay under the monetization SSOT.
- Modern Table additive labels remain deferred.

## 14. Next recommended wave

Run a bounded Drill Readiness / Beta Proof wave next, focused on proving that the currently exposed short reps are sufficiently useful and not just cleaner copy.
