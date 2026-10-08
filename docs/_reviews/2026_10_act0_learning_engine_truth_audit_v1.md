# Oct 2026 Act0 Learning Engine Truth Audit v1

Status: WAVE_W1_MACHINE_AUDIT_CLOSED / NEXT_MECHANICS_FLOW_EVIDENCE_REQUIRED
Date: 2026-10-08
Repository: ClubBoss/sharky-standalone-direction

## Authority, protection and baseline

Owner requests mechanics / learning / personalization ahead of unfinished visual art.
Main remains `bdf560f0d90d9659335f6492149c373842f655b1`, through merged PR #223.
A clean isolated `main` worktree was used at
`/Users/elmarsalimzade/Sharky_Brain_Audit_2026-10-08`.
The protected local `/Users/elmarsalimzade/Sharky_1.0` checkout (dirty, 106 commits behind main) was neither modified nor synchronized.
The separate PR #224 review checkout was not mutated. PR #224 remains open and unmerged.
Toolchain on Mac: Flutter 3.35.7, Dart 3.9.2.
All observations below are machine evidence only. No new Human, real-poker, longitudinal, native simulator or market efficacy claim is made.

## Executed checks (real local Mac, exact main)

1. `flutter pub get`: exit 0.
2. `flutter analyze --no-pub`: exit 0, no issues found.
3. `./tools/fast_loop_world1_v1.sh`: exit 0, `FAST LOOP PASS`.
4. Six core-policy tests for action sequence, causal feedback/receipt,
   transfer measurement, durable retention, personalized return reason and durable
   learning evidence: 70/70 pass, exit 0.
5. Six route/learning experience test files
   (`act0_due_review_route`, `act0_review_recovery_route`,
   `act0_shell_preview_screen`, `e2e_product_integrity_checkpoint`,
   `act0_same_session_learning_delta`, `act0_learning_run_payoff`):
   39 pass / 5 fail, exit 1.
6. Independent reruns reproduced the failing groups without shared-suite
   contamination: `review_recovery` 0 pass / 1 fail;
   `e2e_integrity` 4 pass / 1 fail;
   `same_session_delta` 6 pass / 3 fail.

Ignored raw/summary logs remain local only under
`output/context-economy/oct08-*.{raw,summary}.log`.
The only tracked change caused by Flutter tooling was
`macos/Flutter/GeneratedPluginRegistrant.swift`, which was restored in the
ISOLATED AUDIT WORKTREE ONLY. Final isolated worktree is clean; no app source,
test source or asset mutation was retained.

## Finding A - Old E2E lesson-key assumption (NOT A PROVEN PRODUCT DEFECT)

The failed test expects `act0_shell_lesson_The 6 positions` after selecting W3.
An ephemeral *read-only product diagnostic* on the same route found that the
lesson is in fact rendered as the current top mission (`Current table read`,
`The 6 positions`, `Current step 1 of 10`, `Start`), while five other
completed W3 lesson entries are rendered with `Replay available` and lesson
keys. The test's desired key is not mounted in the older lower-list location.
The actual learner-facing alternative has not been falsified.
Disposition: `OLD_TEST_LOCATION_ASSUMPTION` hypothesis. Do not change
production route or create tests-for-tests without a real learner blocker.

## Finding B - Review-recovery feedback reason finder (NOT YET A PRODUCT DEFECT)

`act0_review_recovery_route_v1_test.dart` expects
`act0_shell_feedback_reason` after the correct review recheck.
The present runner source deliberately gates that key off when a wrong-result
repair-teaching block owns the explanation
(`showReason = !rapidMode && !hasRepairTeachingBlock`).
Exact production-path visibility should be examined if a learner cannot see
a causal explanation; mere absence of this old widget key is not enough.
Disposition: `ALTERNATIVE_FEEDBACK_PRESENTATION_TO_VERIFY`.
Do not add duplicate reason widgets to satisfy a stale key.

## Finding C - W2 failed original read / return to Review (PRODUCT PATH PRESENT)

The failing test expects the exact label
`Original read needs one more rep`, which is absent.
An ephemeral diagnostic printed actual visible learning feedback after the
failed source recheck: `MISSED CLUE`, `Raise was the better play`,
a contextual KQo-in-HJ explanation and `Continue to Review`.
The trace includes `user_choice`, `decision_made`, `task_result`,
`repair_started`, `repair_completed`, `recheck_started`,
`starting_hand_personalization_recheck` and `feedback_viewed`.
This disproves the inference that the absent exact label alone establishes
a dead-end. It does not prove that a real novice understood it.
Disposition: `PRESENTATION_COPY_OR_EXPECTATION_DRIFT`, not a justified engine rewrite.

## Finding D - W2 table-to-feedback/action geometry (UNADJUDICATED)

Two widget geometry assertions fail in the W2 same-session delta route:
- measured feedback gap 94.12 logical px against test maximum 48;
- measured recheck action-dock gap 143.12 logical px against maximum 32.

These are reproducible real widget geometry readings, but the threshold alone
does not establish a user actionability blocker. Assess with the existing
Learning Scene and explicit task affordance under the accepted viewport before
any bounded flow repair. It is not license to reopen V4 art, table geometry,
camera, general visual polish or the screenshot design pipeline.

## One-family next route

`CURRENT_NEXT_FAMILY = ACT0_POST_CHOICE_CONTINUATION_AND_ACTIONABILITY_EVIDENCE_V1`

Admitted first step is a cheap falsifier, not an implementation claim:
- use existing exact-main current learner flow and accepted compact/402 viewport
  to test decision -> corrective feedback -> recheck -> continue -> Review;
- check the 94/143 px dead bands for genuine affordance loss or unreadable
  instruction hierarchy, independently of final opponent art;
- verify current and completed W3 lesson navigation on actual learner-visible
  controls, not the stale key;
- preserve required telemetry and truth that a fresh learner starts at 0/9
  and must earn Action unlock; a progressed seed is not a fresh-user pass;
- classify `CLOSED_PASS`, `EVIDENCE_ONLY_DEBT`, or one concrete
  `IMPLEMENT_NOW` high-EV actionability defect, no speculative tests.

Once the mechanics-first route is acceptable, request a bounded early Human
novice pilot on the legible placeholder surface, separately from full P02:
independent action recognition; causal feedback comprehension; corrected
same-signal recheck; an unseen alternative; useful next rep; safe Review/exit.
Collect choice, result/error type, decision time and ordered repair/recheck
evidence without personal identifiers. An early pilot does not establish
P02, Day-2/Day-7 retention or market willingness to pay.

## Art freeze and no-change verdict

Production V4R1 assets and PR #224 remain parked as a held visual candidate.
CO plate and effect-mask SHA differ from the saved support-final source pack,
whereas the other eight seat/mask SHA values match; investigate only in the
later dedicated art family.
No speculative code fix was made in this audit. No merge occurred.
`W1_POLICY_MECHANISMS = MACHINE_PASS`
`W1_ROUTE_FULL_SUITE = FAIL_5_CONTRACT_ASSERTIONS / TRIAGE_RECORDED`
`W1_PRODUCT_BUG = NOT_YET_PROVEN`
`W1_REPORT = CLOSED_WITH_NEXT_FALSIFIER`
`HUMAN_PROOF = FALSE`
`P02 = NOT_ADMITTED`
