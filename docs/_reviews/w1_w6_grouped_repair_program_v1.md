# W1-W6 Grouped Repair Program v1

Status: `grouped_repair_program_ready`

Verdict input: `w1_w6_final_gate_repair_program_ready`

## Program shape

Smallest substantial repair program: five grouped waves. Do not split into
row-by-row micro-waves. Do not open W7+, Modern Table, monetization, public
readiness, visual redesign, or Human QA execution inside these waves.

## Wave 1 - Beginner vocabulary/order + first-table assessment validity

Objective: make the absolute-beginner path safe from placement through the
first W1 rows.

Included findings:

- W1W6-LT-001
- W1W6-LT-002
- W1W6-LT-003
- W1W6-LT-014

Expected product/learning EV:

- highest first-session trust gain;
- prevents Human QA from finding obvious undefined-term failures;
- reduces false success by elimination.

Exact owner seams:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `content/worlds/world1/v1/sessions/w1.s01/`
- `content/_meta/term_introduction_contract_v1.json`
- term scanner/tests that protect first-use order
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

Allowed scope:

- beginner term-order contract for Hero/Villain/BTN/CO/SB/BB/blinds/preflop/postflop/board/pot/sizing/range;
- first-table-guide options/prompt/feedback repair;
- W1.s01 first-row prompt/feedback adjustments only where needed.

Forbidden scope:

- W2-W6 content expansion beyond term-order assertions;
- UI redesign;
- route changes;
- Human QA execution;
- telemetry implementation.

Tests:

- focused Act0 first-table-guide widget test;
- term-order scanner/guard;
- W1 first-session source parser test;
- `flutter analyze`;
- `git diff --check`;
- `graphify hook-check`.

Validation:

- prove every strict beginner term has first appearance, first explanation,
  first visual/context, first assessment, and later reuse;
- prove first-table-guide distractors are plausible and non-leaking.

DoD:

- no beginner-row term is tested before explanation;
- first-table setup row cannot be solved by one absurd option;
- no learner-facing mastery/launch claims added.

Implementation order:

1. extend term-order source/guard;
2. repair first-table-guide assessment;
3. repair W1.s01 first-row copy/feedback only if guard exposes a failure;
4. run focused tests/analyze.

## Wave 2 - Feedback-source completeness across active W1-W6 rows

Objective: every active decision row has source-owned feedback/why that matches
the evaluator and visible table facts.

Included findings:

- W1W6-LT-004
- W1W6-LT-014

Expected product/learning EV:

- mistakes become useful instead of generic;
- Review/repair receipts have better learner-facing provenance;
- low-risk source-only improvement.

Exact owner seams:

- active JSON rows from `content/_meta/world_drills_manifest_v1.json`;
- `lib/services/drill_contract_v1.dart` parser expectations;
- runner feedback presentation tests.

Allowed scope:

- add/repair `feedback_correct_v1`, `feedback_acceptable_v1`,
  `feedback_incorrect_v1`, and `why_v1` for active W1-W6 rows;
- add a source scan/guard to prevent missing feedback returning.

Forbidden scope:

- changing expected answers;
- changing route manifests;
- adding new content rows;
- changing UI layout.

Tests:

- feedback completeness source scan;
- representative W1 and W4 widget/parser tests;
- existing session-drill feedback tests;
- `flutter analyze`;
- `git diff --check`;
- `graphify hook-check`.

Validation:

- all 453 active decision rows are scanned;
- acceptable-action rows explain why playable but weaker;
- no generic `Correct.` / `Incorrect.` fallback is newly introduced.

DoD:

- zero active rows missing correct/incorrect feedback;
- repaired rows have matching `why_v1`;
- no expected-action drift.

Implementation order:

1. add feedback-completeness guard;
2. repair W1/W4 missing rows first;
3. run guard and representative widget tests;
4. broaden to any additional rows exposed by the guard.

## Wave 3 - Active authority and route/test drift cleanup

Objective: remove stale active-source ambiguity before final repair evidence.

Included findings:

- W1W6-LT-005
- W1W6-LT-007

Expected product/learning EV:

- prevents future agents from auditing ghost content;
- aligns tests with current active route truth.

Exact owner seams:

- `content/worlds/world5/v1/index.md`
- `content/worlds/world5/v1/sessions/index.md`
- `content/_meta/world_sessions_manifest_v1.json`
- `content/_meta/world_drills_manifest_v1.json`
- `test/guards/world3_early_arc_runtime_truth_contract_test.dart`
- W3 active source rows for `w3.s10`

Allowed scope:

- docs/index truth cleanup;
- guard expectation update to current active W3 row set;
- add parity assertion that W5.s11 is preserved-only, not active.

Forbidden scope:

- deleting W5.s11 source;
- changing active W3/W5 route;
- changing learner copy except stale index wording.

Tests:

- W3 early-arc runtime truth guard;
- W5 early runtime truth guard;
- manifest/index parity guard;
- `flutter analyze`;
- `git diff --check`;
- `graphify hook-check`.

Validation:

- W3.s10 active row list is explicitly intentional;
- W5.s11 cannot be interpreted as active route content.

DoD:

- W3 guard passes against live source;
- W5 index/manifests agree on active sessions;
- no source row deletion.

Implementation order:

1. decide W3.s10 active row set from manifest/source;
2. update stale guard or source authority, whichever is wrong;
3. clean W5 index wording;
4. run focused W3/W5 guards.

## Wave 4 - Prompt/table structured-context and mobile actionability

Objective: make table facts visible where they teach, and make compact mobile
primary action unambiguous.

Included findings:

- W1W6-LT-006
- W1W6-LT-008
- W1W6-LT-011
- W1W6-LT-012, only if actionability/hidden feedback is reproduced

Expected product/learning EV:

- reduces prompt-only learning;
- fixes compact entry/action ambiguity;
- keeps visual work limited to comprehension/action proof.

Exact owner seams:

- W5 `board_texture_classifier_v1` rows requiring representative structured context;
- session-drill scenario-state/projection seams;
- Act0 Learn/Home hierarchy surfaces;
- W4 compact campaign entry guard.

Allowed scope:

- add structured board/table context to high-EV W5 rows;
- adjust hierarchy/copy/order of current action blocks only enough to make one primary action clear;
- fix W4 compact CTA/actionability if reproduced.

Forbidden scope:

- broad table redesign;
- Modern Table migration;
- aesthetic polish without comprehension/action proof;
- new screenshot tooling.

Tests:

- W5 board texture parser/rendered contract;
- W4 compact actionability guard;
- Learn/Home hierarchy widget test;
- deterministic screenshot lane only if a visual/action claim cannot be proven by widget tests;
- `flutter analyze`;
- `git diff --check`;
- `graphify hook-check`.

Validation:

- table shows facts; prompt asks the decision; feedback explains why;
- compact primary CTA is visible/enabled;
- no hidden critical feedback.

DoD:

- W4 compact guard passes;
- representative W5 rows render structured board facts;
- Learn/Home current-action hierarchy has one primary job.

Implementation order:

1. reproduce W4 compact failure in isolation;
2. repair actionability/hierarchy if root cause is active UI;
3. add W5 structured context for selected high-EV rows;
4. run focused widget/rendered tests.

## Wave 5 - Telemetry and repair proof field completion

Objective: make repair proof measurable enough for Human QA and final claim
safety without inventing analytics.

Included findings:

- W1W6-LT-009
- W1W6-LT-010
- W1W6-LT-013

Expected product/learning EV:

- supports real Human QA protocol;
- makes repeated-error and returning-learner evidence inspectable;
- prevents fake learning-effect claims.

Exact owner seams:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart`
- session-drill repair receipt/persistence/consumer/queue files;
- Human QA protocol artifact when a later task admits it.

Allowed scope:

- local event schema/field propagation for user choice, correctness, error
  type, source ID, signal, target ID, recheck result, completion, and time to
  decision;
- no server analytics or dashboards.

Forbidden scope:

- public analytics;
- AI personalization;
- monetization;
- claiming Human QA passed;
- expanding repair families without source-owned targets.

Tests:

- telemetry sink field test;
- repair lifecycle tests;
- recheck retained-result tests;
- claim-safety copy scan;
- `flutter analyze`;
- `git diff --check`;
- `graphify hook-check`.

Validation:

- every emitted field is locally explainable from source/runtime contracts;
- missing telemetry is not hidden behind copy claims;
- Human QA protocol can consume exact fields.

DoD:

- session-drill path has time-to-decision or an explicit tested limitation;
- repair/recheck event has exact source/target/signal/outcome;
- no mastery/launch/learning-effect copy appears.

Implementation order:

1. define local field contract;
2. wire session-drill decision timing if feasible;
3. extend tests around eligible repair families;
4. update Human QA protocol only in a later admitted Human QA planning wave.

## Highest-EV first wave

Wave 1 is first. It protects the strict absolute-beginner promise and removes
the clearest false-success row before any later content, UI, telemetry, or
Human QA work.
