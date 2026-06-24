# Top-1 UX/Product Lift PR2 - Table, Feedback, Mascot v1

## Summary

PR2 makes the active Act0 table easier to read without changing its layout,
route, or underlying state. An active opponent now keeps an authored BB stack
visible when the center card already owns the decision price. Opponent
face-down cards use a quieter navy back without an ornamental diamond.

## Screens touched

- Active Act0 runner table in `act0_lesson_runner_shell_v1.dart`.
- No Home, Practice, Review, Profile, Learn, route, progression, or Modern
  Table surface changed.

## Before / after UX intent

- Before: an active opponent could lose its authored stack label whenever the
  center card owned the price.
- After: the seat retains its authored stack, for example `80 BB`; the center
  still remains the owner of the decision price. When no authored stack is
  available, the existing behavior is unchanged.
- Before: face-down opponent cards used a high-contrast blue gem treatment.
- After: they are quiet navy cards with a thin low-contrast edge, preserving
  their decorative role rather than competing with the table decision.

## Feedback and mascot review

- Correct feedback already leads with the action/capability and supporting
  reason. XP only appears in completion summaries, not as a competing feedback
  verdict, so no low-risk copy or hierarchy change was needed.
- PR1b wrong-feedback behavior remains unchanged: amber coaching tone,
  `Table clue`, no replay-missed receipt block, and `Try one like this` CTA.
- Mascot assets are declared in `pubspec.yaml`, present under
  `assets/images/mascot/`, and rendered directly by the active mascot widgets;
  there is no active fallback-circle branch to fix. The compact cropped mascot
  frame in fast capture is the existing image treatment, not a missing-asset
  fallback. No speculative mascot redesign was made.

## Boundary proof

- Stack labels come only from `Act0SeatStateV1.stackLabel`; no values are
  invented.
- The change only applies when the table center owns the price, preventing a
  duplicate `To act` price on the seat.
- Existing no-stack and no-center-price behavior is preserved by the focused
  runner test suite.
- No Modern Table source or asset was changed. The card-back adjustment uses
  existing Flutter decoration only; no external asset dependency was added.

## Route / progression / content truth

- No route, progression, telemetry, content, glossary, W11/W12 activation, or
  W13+ work changed.

## Visual evidence

- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/contact_sheet.png`

Both remain local-only generated evidence and are not committed.

## Validation

- Focused active-seat stack and opponent-card-back tests.
- Focused feedback-rhythm surface suite.
- `./tools/screen_review_fast_v1.sh core compact`.
- `./tools/screen_review_fast_v1.sh first_week compact`.
- `graphify hook-check`, `flutter analyze`, `git diff --check`, and status
  review before commit.

## Remaining follow-ups

- PR3 Profile evidence and PR4 broader visual/system work remain out of scope.
- This pass does not change table geometry, opponent-stack source data, or
  Review history.
