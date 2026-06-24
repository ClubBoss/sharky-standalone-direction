# W1-W6 First-Week Content Trust Pass v1

## Verdict

`accepted`

The first-week trust-cleanup lane is closed for the known P0/P1 issues. The
proof packets now keep the same concrete table signal through miss, repair,
Review, and Day 2 return:

`no bet yet -> check is free -> repair this clue -> try/continue`

No product redesign, route change, Modern Table polish, monetization work, AI
claim, new repair family, or generated screenshot artifact was committed.

## Evidence inspected

Commands and evidence:

```bash
git status --short
git log --oneline -5
graphify query "repair continuation copy clue signal naming repair result receipt session repair summary first_week day2_return proof packet source states W1 W6"
rg -n "<problematic continuation strings and no-bet variants>" lib test tools assets content docs -g '!docs/archive/**' -g '!docs/_archive/**'
flutter test test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart
flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart
flutter test test/ui_v2/act0_review_shell_v1_test.dart
flutter test test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart
./tools/screen_review_fast_v1.sh first_week compact
./tools/screen_review_fast_v1.sh day2_return compact
```

Source seams inspected:

- `lib/ui_v2/act0_shell/act0_repair_intent_copy_guard_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `tools/act0_real_text_surface_capture_v1.dart`

Proof outputs inspected, local-only:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/compact.repair_result.png`
- `output/screen_review/current/first_week_fast/compact.session_repair.png`
- `output/screen_review/current/first_week_fast/compact.review_handoff.png`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/compact.open_repair_source.png`
- `output/screen_review/current/day2_return_fast/compact.review_continuation.png`

## Issues found

1. Repair-continuation copy was a template problem.
   The Review repair coach used abstract task labels such as `Legal actions`
   and `Meet the table` as learner-facing clue names.

2. Duplicate exact-replay receipt copy was a composition problem.
   The per-hand repair result and session repair summary both repeated near
   identical `Replay fixed` / `Replay missed` lines.

3. Miss-path clipping was partly content-height pressure.
   The compact portrait miss state had enough repeated receipt/session content
   that the next action could fall below the captured edge.

No source content expansion, W1-W6 curriculum rewrite, route mapping change, or
renderer blocker was found.

## Changes made

- Normalized first-week abstract repair labels `Legal actions` and
  `Meet the table` to the concrete learner clue `no bet yet` inside the Act0
  repair-copy guard.
- Changed Review repair coach copy from abstract label phrasing to:
  `The no-bet-yet clue is still the one to fix.`
- Collapsed exact-replay session summaries to avoid duplicating the per-hand
  repair result receipt.
- Updated targeted tests for the new copy contract and duplicate-removal rule.
- Added this review artifact.

## First-week proof after fix

The refreshed `first_week compact` packet is accepted.

- Decision made: the learner chooses in a W1 table spot with `A K` on
  `A 7 2`.
- Missed table signal: `Nobody had bet yet - that was the clue.`
- Better action: `Check`.
- Repair reason: the hand repeats the same table clue before choosing.
- Miss-path next action: `Continue` is visible in compact portrait.
- Success proof: `Replay fixed: you handled this spot correctly.` remains
  clear, without a duplicated session-level replay sentence.
- Review handoff: the card now says the no-bet-yet clue is still the one to
  fix and offers `Repair this clue`.

## Day-2 return proof after fix

The refreshed `day2_return compact` packet is accepted.

- Persisted open repair: the source miss still shows the missed clue, better
  option, repair focus, replay result, and visible `Continue` CTA.
- Home repair priority: `Repair one weak spot` and `Fix this now` remain clear.
- Practice same repair target: the same no-bet table state and check repair
  target remain visible.
- Review active continuation: the repair coach now says
  `The no-bet-yet clue is still the one to fix.`
- Profile not falsely clear: Profile still shows current focus and return value
  instead of a falsely clean state.

## Remaining residue

No P0/P1 residue remains in the first-week trust-cleanup lane.

Accepted minor residue:

- Contact-sheet headers still crowd long filenames.
- `session_repair` remains a deterministic local proof state, not a native
  persisted app replay.
- Historical review docs may still quote older copy as past evidence.

These do not justify another first-week polish wave without new P0/P1 evidence.

## Next recommended wave

`Daily Repair Depth / Mastery Loop Decision v1`

Reason: the first-week proof chain is now understandable and copy-safe enough.
The next top-1 EV is deciding how daily repair depth and mastery progression
should build durable improvement without opening dashboards, economy systems,
paywalls, or external packaging.

External Review Packaging v1 remains deferred until there is a real recipient.
