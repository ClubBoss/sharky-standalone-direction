---
status: "cta_rhythm_learn_cleanup_landed"
status_source: "derived"
baseline: "611f413625e5"
generated_by: "docs_frontmatter_v1"
---

# CTA Rhythm + Learn Cleanup PR v1

## 1. Verdict

`cta_rhythm_learn_cleanup_landed`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `611f413625e5753962c6bd2acd370a87b1a05726`
- Starting tracked state: clean, aside from local `output/**` directories.
- `graphify hook-check`: passed.

## 3. CTA Ownership

- Active shared shell CTA tokens live in `lib/ui_v2/act0_shell/act0_shell_tokens_v1.dart`.
- Home and other primary filled CTAs resolve through `Act0ShellTokensV1.primaryButtonStyle` or delegated primary action styles.
- Learn Start previously owned a local cyan-to-blue gradient in `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`, bypassing the shared primary token.
- The failing contrast guard is in `test/ui_v2/act0_shell_tokens_v1_test.dart`.

## 4. Contrast Failure Root Cause

The old primary blue was `#1598FF` with white label text. That pair measured `3.014131782536772`, below the required `4.5` contrast ratio. The spec target `#1E90FF` was still too light with white text, measuring `3.2364916476061145`, so it could not satisfy the existing guard without weakening accessibility.

## 5. Primary Token Fix

- Primary CTA color: `#0A64D8`
- Pressed CTA color: `#0858BE`
- Label: white, 16sp, w700
- Radius: 16dp
- Default shared token height: 52dp
- Learn preserves its existing explicit CTA height to avoid geometry drift while adopting the shared primary token.
- Disabled state remains blue-derived with reduced alpha.

## 6. Secondary Token Normalization

`Act0ShellTokensV1.quietButtonStyle` now uses:

- transparent fill
- white label
- `rgba(255,255,255,0.28)` equivalent border
- same 16dp radius family
- 15sp, w600 label

Gold remains an earned/proof accent, not a button identity.

## 7. Learn Cleanup

- Replaced the local cyan/blue gradient Learn Start implementation with a shared `FilledButton` using `Act0ShellTokensV1.primaryButtonStyle`.
- Preserved Learn Start label, callback, route, full-width position, and explicit height.
- Replaced `World progress · 9 lessons · 4 of 9 lessons` with `4 of 9 lessons · 44%`, derived from the same progress fraction used by the bar.
- Removed the decorative translucent blob from the current lesson card.
- Preserved lesson title, card content, lock grammar, route state, and world structure.

## 8. Screenshot Evidence

Local-only evidence lives under `output/cta_learn_cleanup_pr_v1/` and was not committed.

- `comparison_cta_system.png`
- `comparison_learn_before_after.png`
- `after/home.png`
- `after/learn.png`
- `after/welcome.png`
- `after/review.png`
- `after/session_summary.png`
- `after/correct_feedback.png`
- `after/wrong_feedback.png`

`./tools/screen_review_fast_v1.sh core compact` passed.
`./tools/screen_review_fast_v1.sh first_week compact` passed.

## 9. Contrast Result

- Old `#1598FF` on white: `3.014131782536772`
- Spec sample `#1E90FF` on white: `3.2364916476061145`
- Final `#0A64D8` on white: `5.486827755111269`
- Pressed `#0858BE` on white: `6.66718459855596`

## 10. Regression Sweep

Inspected generated compact evidence for:

- Home
- Learn
- Practice
- Review
- Welcome
- Session Summary
- correct feedback
- wrong feedback

Result: primary CTAs share one blue voice; Learn Start no longer uses a cyan gradient; no gold button identity was introduced; the visible changes outside Learn are limited to shared CTA token effects.

## 11. Tests/Validation

Required validation:

- `flutter test test/ui_v2/act0_shell_tokens_v1_test.dart`: passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Learn tab CTA opens runner from expanded current lesson|Learn module header shows progress bar|Learn route labels current world lesson and progress without false future activation|Learn v5 mission hub removes placeholder motif without moving Start|Learn v5 uses ambient mission depth instead of decision motif art|Learn correction removes compact side motif from mission layout|Learn v6 pivots to luminous reference-led mission styling'`: passed.
- `flutter analyze`: passed.
- `graphify hook-check`: passed.
- `git diff --check`: passed.
- `git diff --cached --check`: passed.

Additional exploratory validation:

- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`: resolver file passed; lifecycle file failed on pre-existing repair-flow expectations unrelated to CTA token or Learn key cleanup.

## 12. Scope Safety

Touched scope:

- shared Act0 CTA token file
- Learn current mission CTA and progress copy
- focused tests for CTA token, Learn cleanup, and stale Learn CTA key helpers
- this review artifact

Not touched:

- Welcome composition
- Review layout
- table felt/material tokens
- routes
- mapper
- Profile
- Practice structure
- monetization
- achievements
- Sharky progression
- motion

`macos/Flutter/GeneratedPluginRegistrant.swift` was regenerated by Flutter during validation and restored as generated drift.

## 13. Remaining Evidence Gaps

No visual follow-up is required for the accepted CTA/Learn scope. The only noted gap is the unrelated repair lifecycle test failure observed during exploratory validation, which should not be bundled into this PR.

## 14. Next Recommendation

`Session Summary Gold Containment PR`
