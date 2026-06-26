# Repair Loop Copy / Claim-Safety Pass v1

## 1. Verdict

repair_loop_copy_pass_ready_skill_snapshot_gated

## 2. Claude audit input summarized

The repair-loop audit found that the underlying loop is real, but some visible language still described internal plumbing instead of learner progress.

Main risks addressed:

- repair outcome copy used `rep`/`repair rep` terminology;
- Review and achievement labels exposed implementation-ish route language;
- Profile skill copy implied measured levels or numeric skill gains that are not yet backed by a durable evidence model;
- earned badge count copy could overstate exact count consistency.

## 3. Copy changes made

Repair outcome and receipt copy now use learner-facing fix language:

- `Repair rep` -> `Fix attempt`
- `Repair rep attempted.` -> `You gave the fix a try.`
- `Good rep - you chose the better action.` -> `Nice — you chose the better action.`
- `Still worth repeating.` -> `Not fixed yet — one more.`
- `Repair reps` -> `Fix attempts`
- `Good reps: X` -> `Good fixes: X`
- `Worth repeating: Y` -> `Still to fix: Y`
- `Attempted reps: Z` -> `Fixes tried: Z`
- `Active repair note` -> `What to fix next`
- `Repair route clear` -> `Cleared a fix`
- `One clue to keep in view` -> `One miss to fix`

Session Summary skill payoff copy now says `Practiced: ...` instead of displaying unitless `+N` gains.

## 4. Skill snapshot claim-safety decision

Profile skill snapshot copy was gated to evidence-safe language.

Visible copy now avoids `Skill snapshot`, `Lv N`, and unitless `+N` skill gain claims. The Profile surface keeps the existing data ordering and proof payloads, but presents them as practiced skills:

- `Skills practiced`
- `Recent proof from this route.`
- `Practiced: <skill label>`
- `<skill label> — practiced`

No durable evidence model, skill scoring model, or capability-level claim was added.

## 5. Badge/earned-count consistency decision

The Profile earned proof card no longer displays an exact badge count.

It now uses neutral proof copy: `Small wins Sharky can prove`.

This avoids implying a stronger badge-count contract while preserving the existing achievement state and earned-proof surface.

## 6. Logic boundary

This PR changes UI copy and claim presentation only.

It does not change repair outcome projection, queue projection, repair intent resolution, achievement unlock rules, skill stat values, session state, progression, routing, storage, or telemetry.

## 7. Queue/Review resolution boundary

The copy `Not fixed yet — one more.` is a local learner-facing repeat cue only.

No fixed, cleared, resolved, completed, mastered, or removed state was added to the repair queue, Review history, Session Summary, or Practice launch path.

## 8. Forbidden-claim proof

Source scan over `lib/ui_v2/act0_shell` found no remaining learner-visible uses of the old plumbing labels:

- `Repair rep`
- `Repair reps`
- `Repair rep attempted`
- `Good rep -`
- `Still worth repeating`
- `Active repair note`
- `Repair route clear`
- `One clue to keep in view`
- `Skill snapshot`
- unitless skill labels such as `Table sense +N`, `Board reading +N`, `Betting decisions +N`, `Hand reading +N`
- `Lv 1` / `Lv 2`

Remaining old-string hits are negative assertions in focused tests.

Forbidden claim families were not added: premium, paywall, AI, leak, mastery, GTO, solver.

## 9. Screenshot proof

Required local screenshot commands:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Generated packets remain local under `output/screen_review/current/` and are not source artifacts.

Captured locally:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

## 10. Tests / validation

Focused tests cover:

- repair outcome projection remains state-only;
- repair outcome consumer copy uses learner-facing fix language;
- Session Summary repair receipt copy uses `Fix attempts`;
- repair feedback receipt uses `Fix attempt`;
- Review active repair note uses `What to fix next`;
- Profile claim-safety hides unbacked levels, unitless `+N` skill claims, and exact badge count copy;
- Practice repair queue projection/consumer contracts remain green.

Validation run:

- `flutter test test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_review_shell_v1_test.dart test/ui_v2/act0_profile_claim_safety_v1_test.dart test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart` - passed.
- Focused `test/ui_v2/act0_shell_preview_screen_v1_test.dart` Review/Profile/summary cases affected by copy changes - passed.
- Screenshot commands listed above - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed` on touched Dart/test files - passed.
- `git diff --check` - passed.

## 11. Next recommended PR

Run a post-copy repair-loop audit/recheck using the fresh first-week, day2-return, and full-scroll screenshot packets before opening any new repair semantics or Profile evidence model work.
