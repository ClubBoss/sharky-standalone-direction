# Wave 4.2 - Premium Identity & Claim Cleanup v1

## 1. Verdict

wave4_2_premium_identity_claim_cleanup_ready

## 2. Source findings

- SP-02: Consistent Sharky avatar across Home / Profile / feedback.
- SP-03: Profile header identity pass.
- SP-08: Global / feedback XP economy reframe.

## 3. Implementation summary

- `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`: kept the existing Sharky PNG mascot as the primary shared renderer and added a deterministic Sharky SVG fallback for screenshot/test timing.
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`: moved the Profile hero from a profile/avatar placeholder read to the shared Sharky presence mascot and proof-first header copy.
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`: reframed completion toast and block-summary visible XP/level copy into local proof copy.
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`: removed selected-world visible reward XP copy.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`: removed visible lesson-start XP CTA copy.
- `test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart`: added focused Wave 4.2 proof tests.
- Existing focused Act0 tests were updated where copy contracts changed.

## 4. Sharky avatar consistency

Previous issue: Sharky surfaces could read as a generic blue placeholder/avatar block in capture and Profile used a local asset path instead of the shared presence owner.

Current fix: Home, Profile, and feedback companion surfaces now share `Act0SharkyPresenceMascotV1`. The shared owner still attempts the existing PNG mascot first and falls back to existing registered Sharky SVG assets during early frame/error states, which keeps screenshots deterministic and Sharky-shaped instead of blank.

Affected surfaces: Home top Sharky identity, Profile hero identity, and existing feedback/companion Sharky presence surfaces.

Evidence: `output/screen_review/current/full_scroll_fast/compact.home.scroll_01_top.png` and `output/screen_review/current/full_scroll_fast/compact.profile.scroll_01_top.png`.

## 5. Profile identity

Previous issue: Profile opened with `Learning profile`, a visible XP progress bar, and a blue placeholder-like avatar block.

Current fix: Profile now leads with `Proof profile`, `Sharky keeps proof, not points.`, the shared Sharky mascot identity, and the existing honest route proof lines. The Profile XP progress bar was removed from the header hierarchy; underlying profile state was not changed.

Affected surfaces: Profile tab header and hero card.

Evidence: focused Profile widget tests and `output/screen_review/current/full_scroll_fast/compact.profile.scroll_01_top.png`.

## 6. XP economy reframe

Strings found and changed:

- `+$animatedGain XP` -> `One clean read` in the session/block summary progress card.
- `Next step N` / `N/target XP` -> `Local proof saved` in the same card.
- `+$animatedGain XP · ...` -> `Proof banked` in the completion toast.
- `Level N` was removed from the completion toast.
- `N/target XP` -> `Table read improved` in the completion toast.
- `Reward +N XP` -> `Proof path` in the selected-world popup.
- `Start +N XP` -> `Start` in the lesson CTA.

Claim-safety rationale: visible feedback and local progress now describe earned proof from the current rep instead of a global RPG economy. Internal XP/progression fields remain available to existing state contracts but are not promoted as the premium-facing claim on touched surfaces.

Evidence: `test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart`, affected preview-shell tests, and first-week/full-scroll screenshot packets.

## 7. Learner-visible improvement

The app now reads more like a proof-based learning product: Sharky is visibly present as a consistent guide, Profile feels owned by the product instead of a generic account placeholder, and feedback emphasizes the table read the learner just improved instead of numeric XP rewards.

## 8. Anti-drift proof

- No Modern Table redesign.
- No new reward system.
- No AI/chat/persona expansion.
- No GTO/solver claims.
- No monetization, paywall, trial, purchase, or restore changes.
- No ratings/radar/levels surfaced in the touched feedback/profile hierarchy.
- No W5-W36 expansion.
- No route rewrite or progression mutation.
- No screenshot pipeline redesign.

## 9. Tests/checks

- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_profile_shell_v1.dart lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `flutter test test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart`
- `flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_profile_claim_safety_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Profile shows Sharky proof identity and encouraging completion line"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Canonical detached shell review shows animated proof closing summary"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Canonical detached shell keeps proof copy when internal XP crosses target"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Later locked world stays locked without premium paywall copy"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Home Sharky identity avoids duplicate status chips and footer cue"`
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

## 10. Screenshot evidence

- `./tools/screen_review_fast_v1.sh day2_return compact`
  - `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `./tools/screen_review_fast_v1.sh first_week compact`
  - `output/screen_review/current/first_week_fast/contact_sheet.png`
  - `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
  - `output/screen_review/current/full_scroll_fast/contact_sheet.png`
  - `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`
- `./tools/screen_review_fast_v1.sh profile_evidence compact`
  - `output/screen_review/current/profile_evidence_fast/contact_sheet.png`
  - `output/screen_review/current/profile_evidence_fast/screen_review_profile_evidence_fast.zip`

Generated screenshot outputs remain local-only and uncommitted.
