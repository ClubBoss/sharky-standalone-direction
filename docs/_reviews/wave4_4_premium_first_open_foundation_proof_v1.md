# Wave 4.4 - Premium First-Open & W1-W4 Foundation Proof v1

## 1. Verdict

wave4_4_premium_first_open_foundation_proof_ready

## 2. Source findings

- SP-01: Premium first-open / brand impression.
- SP-06: W1-W4 Foundation visual proof.

## 3. Implementation summary

- `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`
  - Added a single first-open Sharky Poker brand beat above the existing placement handoff.
  - Reused the existing Sharky presence mascot and placement route.
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
  - Added a bounded W1-W4 Foundation proof card inside the existing Learn mission-first body.
  - Used existing world metadata/status and claim-safe W1-W4 public framing.
- `test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
  - Added focused tests for the first-open brand beat, Foundation proof card, and forbidden claim/copy boundaries.

## 4. First-open / brand impression

Previous issue:
- The first public/beta impression opened directly into a functional placement surface, so the product identity appeared after the form rather than before it.

Current fix:
- Placement intro now starts with a single premium Sharky Poker brand beat.
- The beat resolves into the existing placement route and keeps the existing primary handoff behavior.

Copy used:
- `Sharky Poker`
- `Read the table from your first hand.`
- `One clue. One decision. One proof.`
- `Your table coach is ready.`

Route behavior:
- No new route family.
- No onboarding redesign.
- No new intro sequence.
- Existing placement callbacks and handoff behavior remain unchanged.

Evidence:
- Focused widget test verifies the brand beat key, Sharky identity, safe copy, and absence of AI/GTO/solver/premium/trial/purchase copy.
- Screenshot packet: `output/screen_review/current/first_week_fast/compact.placement.png`.

## 5. W1-W4 Foundation visual proof

Previous issue:
- Learn proved route presence but the W1-W4 foundation read like an internal route list instead of a designed public-v1 foundation.

Current fix:
- Learn now shows a Foundation path card directly under the current world context.
- The card groups W1-W4 as a coherent foundation with visible current/locked status.

World data used:
- Existing `Act0WorldCardV1` list.
- Existing world numbers and world status.
- Public-safe labels:
  - `W1 - Table Basics`
  - `W2 - Hand Discipline`
  - `W3 - Position Thinking`
  - `W4 - Preflop Framework`

Claim-safety rationale:
- The section only renders when W1-W4 are present in the existing world list.
- The `36-world` line is framed as path start, not built runtime coverage.
- No W5-W36 content, unlocks, completion, or production-depth claims were added.

Evidence:
- Focused widget test verifies the Foundation proof card, W1-W4 labels, claim-safe 36-world path framing, and absence of W5/built/complete-course/premium/paywall copy.
- Screenshot packets:
  - `output/screen_review/current/core_fast/compact.learn.png`
  - `output/screen_review/current/full_scroll_fast/compact.learn.scroll_01_top.png`

## 6. Claim safety

Confirmed:
- No W5-W36 built-content claim.
- No AI/GTO/solver claim.
- No guaranteed improvement claim.
- No pro/mastery claim.
- No monetization CTA.

## 7. Learner-visible improvement

- First open now presents Sharky as an intentional table-coach product before the placement route asks for input.
- Learn now makes the W1-W4 Foundation feel like a designed path with visible early-world structure instead of an internal list.
- The added proof is compact and sits inside existing surfaces, so it improves premium perception without changing progression or route truth.

## 8. Anti-drift proof

Confirmed:
- No onboarding redesign.
- No broad Learn redesign.
- No Modern Table work.
- No W5-W36 expansion.
- No AI/chat/persona expansion.
- No GTO/solver claim.
- No monetization or paywall change.
- No route rewrite.

## 9. Tests/checks

Passed:
- `flutter test test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "First-run placement asks questions before the app shell"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Placement reduces first-run intake to experience then confidence before the live check"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Placement intake keeps non-beginner questions scan-first"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Learn tab shows current mission without expanding journey row"`
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_placement_shell_v1.dart lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
- `flutter analyze`
- `git diff --check`
- `graphify hook-check`
- `git diff --cached --check`
- `git status --short`

## 10. Screenshot evidence

Generated locally:
- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/full_scroll_fast/`
- `output/screen_review/current/core_fast/`

Key proof files:
- `output/screen_review/current/first_week_fast/compact.placement.png`
- `output/screen_review/current/full_scroll_fast/compact.learn.scroll_01_top.png`
- `output/screen_review/current/core_fast/compact.learn.png`

Generated screenshot outputs remain local-only and are not intended for commit.
