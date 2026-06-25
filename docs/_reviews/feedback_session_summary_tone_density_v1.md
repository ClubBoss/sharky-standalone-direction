# Feedback + Session Summary Tone/Density v1

## Verdict

feedback_summary_tone_density_ready

## Claude audit findings addressed

- Correct feedback could let XP/reward appear before the capability gained.
- Wrong repair feedback could stack better option, signal proof, reason, and
  repair focus as visually equal teaching rows.
- Session Summary could say `Lesson complete` while the learner still needed a
  replay to unlock the next step.

## Surface owner map

- Feedback card: `Act0FeedbackShellV1` in
  `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- Repair focus block: `_FeedbackVisibleRepairReasonBlockV1`
- Session Summary / block completion: `Act0BlockCompletionShellV1` and
  `Act0BlockCompletionSummaryV1`
- Proof coverage: feedback rhythm tests plus targeted Act0 shell preview tests

## Implemented copy/hierarchy changes

- Correct feedback now renders the first-value skill/capability receipt before
  the XP completion toast.
- Wrong repair feedback now keeps one teaching stack: verdict, better action,
  compact repair focus, then the single primary CTA.
- When repair focus is visible for wrong feedback, duplicate signal-proof and
  reason rows are suppressed because the compact repair block already carries
  the same teaching job.
- Session Summary now uses `Almost there - replay to unlock` when the current
  run is below the unlock threshold.

## Evidence and claim boundary proof

- Existing evidence-backed skill receipt, repair focus, repair result, and
  current-run summary facts remain sourced from existing state.
- No new evidence claim, long-term history claim, mastery claim, leak claim,
  AI/personalization claim, or profile/review history claim was added.
- XP remains visible, but secondary to the feedback proof.

## Session Summary headline/tone rule

- If unlock criteria are satisfied, completion language remains allowed.
- If the learner is below the unlock gate, the dominant headline is replay
  guidance: `Almost there - replay to unlock`.
- The gate message still states the exact threshold and next lesson truth.

## Boundary proof

- No route, progression, telemetry, durable evidence model, content, glossary,
  Modern Table, premium/paywall, Profile, Review history, Home, Learn, or
  Practice behavior changed.
- No generated screenshot/output artifact is intended for commit.

## Screenshot/capture proof

Final local proof commands:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Expected local artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`

These artifacts are local-only evidence and must remain uncommitted.

## Tests / validation

Required validation for this wave:

- focused feedback rhythm tests
- focused Session Summary / block-completion tests
- first-week, day-2 return, and full-scroll fast screenshot packets
- `graphify hook-check`
- `flutter analyze`
- touched-file format check
- `git diff --check`
- `git status --short`

## Next recommended wave

Review the generated screenshot packets. If accepted, run a gated push for this
local commit, then continue with the next Claude UX/UI v2 safe-now cleanup item.
