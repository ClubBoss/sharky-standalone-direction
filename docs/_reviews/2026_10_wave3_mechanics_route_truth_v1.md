# Wave 3 - Mechanics Route Truth on PR #226

Date: 2026-10-08
State: W3_MACHINERY_REVIEWED / NO_NEW_IMPLEMENT_NOW / HUMAN_ACTIONABILITY_OPEN
Exact product candidate: `e87862309817f2f27f9db8bb51afbfd118f8310f` (PR #226; not merged).
Base main: `bdf560f0d90d9659335f6492149c373842f655b1`.
Local worktree: `/Users/elmarsalimzade/Sharky_W3_Mechanics_Audit_2026-10-08` (detached; isolated from protected dirty checkout).
Modern Table and V4 art: FROZEN/DEFERRED. Do not reopen aesthetic work from this report.

## Independent W3 post-fix route run

Real Mac Flutter 3.35.7, `flutter pub get` PASS.
Six route suites: `act0_due_review_route_v1_test`,
`act0_review_recovery_route_v1_test`,
`act0_shell_preview_screen_v1_test`,
`e2e_product_integrity_checkpoint_v1_test`,
`act0_same_session_learning_delta_v1_test`,
`act0_learning_run_payoff_v1_test`.

Exact-head result: **39 passed / 5 failed, exit 1**, same failure census as baseline W1. This is **NOT** a green full integrated route result. The failure classifications are:

1. `act0_review_recovery_route_v1_test.dart:65` expects
   `act0_shell_feedback_reason`; current source intentionally uses a separate
   repair teaching block. An ephemeral W1 diagnostic verified actual
   `CORRECT READ`, private cards/board/pot explanation, and
   `Continue to Review`; completing the rest of that path passed after
   bypassing the obsolete key expectation. `OLD_WIDGET_IDENTITY`, not yet a
   demonstrated interaction defect.
2. `e2e_product_integrity_checkpoint_v1_test.dart:82` expects a
   `The 6 positions` lesson item in an old lower lesson-list location.
   A W1 diagnostic found this lesson visible as the W3 `Current table read`
   mission with `Start`, and other completed lessons available for replay.
   `OLD_LIST_POSITION_ASSUMPTION`; do not rewrite navigation for this test.
3. `act0_same_session_learning_delta_v1_test.dart:177`: feedback-table
   distance 94.12 logical px vs asserted <=48. Real geometry, not hypothetical.
   The tested feedback is within viewport and the CTA is reachable, but the
   empty field's novice scan cost remains unproven. `HUMAN_ACTIONABILITY_RISK`.
4. `act0_same_session_learning_delta_v1_test.dart:381`: action-dock/table
   gap 143.12 logical px vs <=32. Real geometry, not hypothetical. Existing
   full W2 flow on the same viewport can execute its original recheck and
   CTA. `HUMAN_ACTIONABILITY_RISK`.
5. `act0_same_session_learning_delta_v1_test.dart:488` expects
   `Original read needs one more rep`. W1 diagnostic recorded an actual
   `MISSED CLUE` + KQo-in-HJ explanation + `Continue to Review`, and
   `user_choice`, `decision_made`, `task_result`,
   `repair_started`, `repair_completed`, `recheck_started` events.
   `OLD_COPY_EXPECTATION`, not an observed dead end.

## Existing PR #226 payoff fix is independently supported

The previous actual product defect was the mismatch between
`learning_effect_delta_viewed` and missing visible proof in
`sceneOwnsFeedbackExplanation`. PR #226 fixes that branch. Existing W2
targeted full transition passed when the known obsolete geometry/label
assertions were bypassed, with one `learning_effect_delta_viewed`.
The earned proof is in viewport:
- compact 375x812 proof y=711..737, CTA y=744..792;
- 402x874 proof y=773..799, CTA y=806..854.
No scene, cast, telemetry semantics or poker engine change.

The exact PR #226 GitHub-owned CI is GREEN:
Theory Integrity, Health, R5 release gate, Sharky Web QA Mirror, Test
Authority Lanes all success (L2 conditional skipped). Third-party
`TestSprite Pre-Check` separately fails `No tests detected`; do not
mislabel it as an owned machine test pass. No merge or owner acceptance
is implied.

## Disposition

`W3_PRODUCT_ENGINE_BLOCKER_FOUND = NO_NEW_PROVEN_BLOCKER`
`W3_LEGACY_ROUTE_CONE = FAIL_5_DOCUMENTED_EXPECTATIONS`
`W3_GEOMETRY_ACTIONABILITY = HUMAN_HYPOTHESIS_PENDING`
`W3_TEST_FOR_TEST_FIX = FORBIDDEN_WITHOUT_PRODUCT_REGRESSION`
`W3_NEXT = BOUNDED_EARLY_NOVICE_PILOT_PREP`
`P02 = NOT_ADMITTED`
`HUMAN_LEARNING_PROOF = FALSE`

Keep the older expectation failures visible; neither silence them nor add
duplicative widgets to turn red assertions green. If a novice encounters an
actual dead zone, first capture viewport, tap attempt, effect and user words;
only then open one high-EV fix. Otherwise, preserve code and redirect effort
to real learner understanding and transfer.
