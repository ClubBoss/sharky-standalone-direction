# Top-1 UX/Product Lift PR1b Cleanup v1

## 1. Summary

PR1b closes the remaining information-architecture and wrong-feedback copy
residue from PR1 without opening a new product layer. The result is one clear
Home action, an honest non-actionable Review context, and calmer amber
wrong-feedback language.

## 2. Screens touched

- Home: the duplicate outlined next-action block below the mission card is
  removed. The remaining Learn, Practice, and Review rows describe the session
  shape/status only.
- Review: an open repair is labeled as `Active repair`; the header is neutral
  `Review`; the subtitle truthfully says that the active repair is waiting on
  Home. The card is now `Repair context`, not an action source.
- Feedback: wrong feedback uses `Table clue` instead of `Missed clue` while
  preserving the existing gold/amber tone and `Try one like this` CTA.

## 3. Before/after UX intent

| Surface | Before | After |
| --- | --- | --- |
| Home | Hero `Continue` competed with a second outlined `Continue your first lesson` block. | The hero owns the only primary next action; the lower card gives neutral session shape. |
| Review | `1 fix waiting` and repair coaching implied an action that no longer existed on Review. | Review preserves the clue context and clearly redirects the active repair to Home. |
| Wrong feedback | `Missed clue` retained a failure-first label after the amber coach treatment landed. | `Table clue` leads with a concrete, non-shaming coaching frame. |

Correct-feedback hierarchy was inspected and left unchanged: a further rewrite
would broaden this cleanup without a single isolated duplicate verdict/reward
failure.

## 4. Boundary proof

- No table, mascot, Profile, Learn-numbering, session-summary, Review-history,
  repair-variant, content, or product-layer work was added.
- No fake mistake counts, history, leak, personalization, mastery, AI, or
  commerce claim was introduced.
- The Review session-drill recheck card remains the separate real-action owner
  when an actual queue item exists.

## 5. Route/progression truth proof

- Home still starts the existing next useful hand through its mission CTA.
- Repair launch tests now use that Home CTA rather than the retired Review CTA.
- No route, progression, `ProgressService`, or telemetry schema code changed.

## 6. W11/W12/W13 truth preservation

- No W11/W12 activation or handoff changed.
- No W13+ entry, unlock, completion, premium, or paywall state changed.

## 7. Validation

- `flutter test test/ui_v2/act0_review_shell_v1_test.dart test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- Targeted Review debug-capture test in
  `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- Focused capture tests passed during both packet commands.

Packet evidence is local-only:

- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/contact_sheet.png`

## 8. Remaining follow-ups

- This does not add Review mistake-history/backlog ownership; Review stays a
  context/proof surface while Home owns the active next repair.
- Correct feedback can be revisited only if future evidence isolates a real
  duplicate-verdict or reward-priority defect.
- The next visual product work remains outside PR1b scope.
