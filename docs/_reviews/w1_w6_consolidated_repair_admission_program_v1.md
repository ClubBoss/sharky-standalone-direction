---
status: "w1_w6_consolidated_repair_program_ready"
status_source: "derived"
baseline: "43a8889f643d"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Consolidated Repair Admission Program v1

Verdict: `w1_w6_consolidated_repair_program_ready`

Base: integrated `main` at
`43a8889f643dc6a38303b1bc1c462963785456ef`

Branch: `codex/w1-w6-consolidated-repair-admission-program-v1`

Scope: docs-only synthesis. No product, content, test, tooling, route, Modern
Table, legacy-flow, or session-drill repairs are implemented here.

## 1. Source Inputs

Integrated canonical audits reconciled:

- `docs/_reviews/w1_w3_canonical_deep_learning_audit_v1.md`
- `docs/_reviews/w4_w6_canonical_deep_learning_audit_v1.md`
- `docs/_reviews/w1_w6_canonical_ownership_map_v1.md`
- `docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md`

Live canonical source was verified only where cited by those audits:

- feedback-title family in `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- W2 `apply_hj_decision` binding
- W3 `position_six_seats` source-task composition
- Act0 first-value receipt and same-signal mapping owners
- prompt/hint leakage cited in W1/W2/W4/W5
- W2/W3/W4/W5/W6 identity/subtitle and W6 scope seams

## 2. Live-Source Verification Summary

### Feedback-title family

Confirmed canonical, source-owned, and systemic by copy/paste, not by a shared
helper:

- W1 `_buttonSeatRunner` correct BTN option has
  `feedbackTitle: 'Win can hide a leak.'`.
- W1 `_utgSeatRunner` correct UTG option has
  `feedbackTitle: 'Reset before next hand.'`.
- W1 `_latePositionRunner` correct late-position option has
  `feedbackTitle: 'Log it, then reset.'`.
- W1 `_handRankingsRunner` correct pair option has
  `feedbackTitle: 'Process ignores table talk.'`.
- W4 `_world4CheckpointRunner` correct purpose/price option has
  `feedbackTitle: 'Discipline: fold early trash.'`.
- W5 `_world5GapBoardRunner` correct "No" straight-pressure option has
  `feedbackTitle: 'Discipline: open strong late.'`.

Sibling scan found the same recycled-mindset strings also live in W12 mindset
runners, where they are semantically appropriate. The W1/W4/W5 instances are
the canonical W1-W6 defects because the titles do not match the task being
answered.

Required regression guard: a focused source/widget guard for correct-answer
feedback titles in W1-W6 Act0 runners that rejects recycled mindset/preflop
titles unless the runner lesson is explicitly in that family.

### W2 correctness family

Confirmed canonical P1. `hand_discipline_apply` labels
`apply_hj_decision` as "HJ, medium hand" but binds it to
`_w1DisciplineApplyEarlyFoldRunner`, the UTG 8-4 offsuit trash-fold runner.

Root cause: task binding/runner reuse in lesson composition, not a runtime
launcher bug.

Minimal fix: author or bind a distinct HJ-medium runner for
`apply_hj_decision`, preserving the advertised learner promise:
bucket + seat + frame -> action.

Required guard: a lesson-composition test that asserts `apply_hj_decision`
uses a runner with HJ seat/context and a medium hand, not the UTG trash-fold
runner.

### W3 identity family

Confirmed canonical P2. `position_six_seats` is titled as six-seat recognition
but its `sourceTasks` are `_pokerFromZeroLessons[5].taskList`
(`blinds_action_order`) plus bounded extras. The extras cover seat order, BTN
repair, and UTG repair, but do not independently drill HJ/CO/SB/BB name
recognition.

Smaller correct repair: add bounded HJ/CO/SB/BB recognition or retitle the
lesson to action-order. Adding bounded seat-name recognition is the smaller
learning repair because the world promise is position thinking and the lesson
already names all six seats.

Required guard: a W3 lesson-composition test asserting `position_six_seats`
contains canonical, launchable tasks that assess all six named seats, not just
blind/action order plus BTN/UTG.

### Repair-mapping family

Confirmed canonical P2, but not a session-drill issue. Canonical Act0 already
has task-centric exact replay fallback and telemetry, but same-signal mapping
is too shallow for W2/W4/W5/W6:

- `act0FirstValueSkillReceiptForRunnerV1` derives receipts from
  `repairFocus*` or generic table signals.
- `act0FirstValueSameSignalRepMappingV1` maps only generic W1/W3 targets:
  W1 action, board, price, starting-hand, table-read, and W3 table-position.
- W2 bucket options have no same-world bucket mapping and the early bucket
  family has no option-level `repairFocus*`.
- W4/W5/W6 options carry no `repairFocus*` in their canonical ranges.
- Generic W4/W5/W6 misses therefore map backward to W1/W3 where the signal is
  generic board/price/position, or use exact replay when mapping is absent.

A proposed mapping is not admissible unless the target drill teaches the same
signal, is canonical and launchable, preserves source world/task attribution,
emits first-value repair/recheck telemetry, and does not falsely complete
progression.

Required guard: focused mapping tests for W2/W4/W5/W6 miss -> receipt ->
Home/Review CTA -> same-world target or exact replay -> `recheck_completed`
with source attribution preserved.

### Prompt-leakage family

Confirmed and split by severity:

- Explicit answer disclosure: W1 `_flushRankRunner` hint says "Flush beats
  straight" while asking which hand ranks higher.
- Explicit answer disclosure: W5 texture hints name dry/wet through the same
  words the learner must choose.
- Classification pre-state: W4 purpose/protection captions and hints often
  name value/bluff/protection before asking the classification question.
- W2 bucket captions/hints repeatedly name the target bucket before bucket
  checks; the strongest repair target is the same W2 bucket family already
  admitted for differentiation and repair coverage.
- Harmless/legitimate teaching context: W6 bucket hints teach the read and
  then ask action direction; no W6 leakage repair is admitted from the audit.
- Human-QA-only ambiguity: W1/W2/W3 seat-caption wording that says the seat
  name before a tap prompt is borderline teaching context, not repair-now.

Required guard: a canonical prompt-leak sample that rejects hints/captions
which contain the exact correct option label or comparative answer when the
task is an assessment, while allowing theory tasks and legitimate context.

### World-identity/content family

Confirmed defects:

- W2 apply/HJ mismatch is correctness, not polish.
- W3 position opener mismatch is a bounded learning gap.
- W4/W5/W6 in-lesson subtitles are off by one owner:
  W4 shows "Board Awareness", W5 shows "Range Thinking", and W6 shows
  "Visible Cards Change Ranges".
- W4 sizing is arithmetic-only; it does not yet transfer purpose -> size.
- W5 texture work is classification-heavy and needs at least one texture ->
  action decision before 9/10 source re-score.
- W6 world-card scope over-promises "see who has the advantage" relative to
  the current W6 three-lesson foundation route; the combo/checkpoint source is
  currently W7-owned and must not be imported as W6 score evidence unless the
  route owner admits it.

Rejected or deferred:

- W6 combo-count/checkpoint content is not canonical W6 scoring evidence today.
- W4/W5 bridge fixtures and session-drill repair receipts are noncanonical for
  W1-W6 score movement.
- P4 option-count variance and seat-caption ambiguity are not implementation
  items.

## 3. Consolidated Finding Table

Consolidated admitted finding counts:

- Total consolidated rows: 11
- Severity: P1 2 / P2 6 / P3 3 / P4 0
- Disposition: `ADMIT_REPAIR_NOW` 5 /
  `ADMIT_AFTER_PREREQUISITE` 3 /
  `HUMAN_QA_BEFORE_REPAIR` 2 /
  `DEFER_P3` 1
- Explicitly rejected/deferred support items: `REJECT_NOT_CANONICAL` 3 /
  `REJECT_LOW_EV` 1 / additional `HUMAN_QA_BEFORE_REPAIR` 1

| ID | Source audit IDs | Worlds | Severity | Canonical source owner | Learner harm | Root cause | Exact repair seam | Required tests | Telemetry impact | Human QA dependency | Merge dependency | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1W6-CAP-001 feedback-title trust | W1-DLA-P1-01, W4-DLA-P1-01, W5-DLA-P1-02 | W1, W4, W5; reused W3 surface | P1 | Act0 runner option copy in `act0_shell_state_v1.dart` | Correct answers receive unrelated mindset/preflop praise, breaking trust at proof beats. | Copy/paste titles in individual options, not a helper. | Replace exact correct-option `feedbackTitle` strings on `_buttonSeatRunner`, `_utgSeatRunner`, `_latePositionRunner`, `_handRankingsRunner`, `_world4CheckpointRunner`, `_world5GapBoardRunner`. | Source/widget guard for W1-W6 correct-answer title congruence. | None except existing answer telemetry should keep same task ids. | QA checks whether titles now feel clear, not merely nonwrong. | None. | `ADMIT_REPAIR_NOW` |
| W1W6-CAP-002 W2 apply binding | W2-DLA-P1-02 | W2 | P1 | `hand_discipline_apply` task binding | Advertised HJ-medium assessment renders UTG trash-fold; the promised decision does not exist. | Runner reuse/bad task binding. | Bind `apply_hj_decision` to a distinct HJ-medium runner. | Composition test for task id -> HJ/medium runner and no UTG 8-4 runner. | Existing task id should remain; telemetry must continue to report W2/source task. | QA can judge if HJ-medium contrast lands. | None. | `ADMIT_REPAIR_NOW` |
| W1W6-CAP-003 W3 six-seat coverage | W3-DLA-P2-03 | W3 | P2 | `_positionThinkingLessons` lesson composition | Learner sees "six positions" but only gets partial seat-name assessment. | Reused W1 blinds/action-order tasks plus BTN/UTG extras. | Add bounded HJ/CO/SB/BB recognition tasks or retitle; smaller repair is add bounded seat-name drills. | Composition test proving all six seats are assessed in canonical W3. | Same task telemetry; no route change. | QA confirms seat names are learned rather than memorized. | After CAP-001 if reused seat-title repairs touch same runners. | `ADMIT_REPAIR_NOW` |
| W1W6-CAP-004 W2 bucket differentiation | W2-DLA-P3 strong==borderline, W2 score condition | W2 | P2 | `hand_discipline_buckets` lesson composition | Strong and borderline tasks ask the same JJ runner, weakening assessment validity. | Duplicate runner reuse. | Give `hand_discipline_buckets_borderline` a distinct borderline hand/context runner. | Composition test: strong and borderline task ids use distinct runners with distinct hand labels. | Existing W2 task telemetry preserved. | QA checks whether borderline differs from strong. | Can ship with CAP-002. | `ADMIT_REPAIR_NOW` |
| W1W6-CAP-005 prompt leakage | ALL-DLA-P2-02, W1 DLR-005-adjacent, W4/W5 DLR-005 | W1, W2, W4, W5 | P2 | Act0 runner captions/hints/options | Some assessment hints/captions disclose the answer instead of cueing the table read. | Assessment copy repeats correct labels. | Rewrite explicit answer-disclosing hints/captions in cited W1/W2/W4/W5 runners. | Prompt-leak source scan over W1-W6 canonical runners. | None; task ids stable. | QA only for borderline teaching context; explicit leaks do not wait for QA. | After CAP-001 if same files open. | `ADMIT_REPAIR_NOW` |
| W1W6-CAP-006 same-signal repair mapping | W1W6-DLR-004, W2-DLA-P2-01, ALL-DLA-P2-01 | W2, W4, W5, W6 | P2 | `act0_repair_intent_contract_v1.dart`, `act0_shell_preview_screen_v1.dart`, Act0 source task options | Misses either fail to create specific repair or route backward to W1/W3 generic reps instead of same-world recovery. | Narrow mapping table plus missing `repairFocus*` metadata. | Add same-world canonical targets and/or option metadata for W2 bucket, W4 price/purpose, W5 board/texture, W6 bucket/pressure families. | Miss -> receipt -> Home/Review CTA -> same-world target or exact replay -> `recheck_completed`, preserving source attribution. | Must preserve first-value shown/consumed/launched and recheck telemetry; no false progression completion. | QA validates visible repair target trust. | After Wave 1/2 exact target contracts are proven. | `ADMIT_AFTER_PREREQUISITE` |
| W1W6-CAP-007 W4/W5 decision transfer | W4-DLA-P2-03, W5-DLA-P3-02 | W4, W5 | P2 | W4/W5 Act0 content source | W4 size drills are arithmetic-only; W5 texture work may stop at labels rather than action. | Missing transfer decision tasks. | Add one W4 purpose -> size decision and one W5 texture -> action decision if post-correctness re-score still needs them. | Focused task-order and assessment tests for new transfer tasks. | New tasks emit normal Act0 task telemetry. | QA judges whether transfer actually lands. | After correctness/leakage repairs. | `ADMIT_AFTER_PREREQUISITE` |
| W1W6-CAP-008 W4-W6 in-lesson subtitles | ALL-DLA-P3-01 | W4, W5, W6 | P3 | Act0 runner copy | In-lesson headers show the next world's identity, causing low-level orientation blur. | Copy/paste from next-world runners. | Correct W4/W5/W6 `lessonSubtitle` strings to their own world identities. | Source guard for W4/W5/W6 runner subtitles matching world owner. | None. | No QA prerequisite. | May ride with Wave 1 only because same file owner and low risk. | `ADMIT_AFTER_PREREQUISITE` |
| W1W6-CAP-009 W6 scope/payoff | W6-DLA-P3-03, W6-DLA-P3-04 | W6 | P3 | W6 world card and route/content owner | World card promises range advantage, but canonical W6 delivers own-hand bucket foundation and no dedicated checkpoint. | Scope/payoff mismatch; combo/checkpoint lessons are currently W7-owned. | Either narrow W6 copy/payoff to delivered foundation or admit a bounded W6 capstone by route-owner decision. | Route-scope test if content admitted; copy snapshot if narrowed. | If content added, normal Act0 task telemetry; if copy-only, none. | Human QA should judge whether current W6 feels complete. | Owner decision before content expansion. | `HUMAN_QA_BEFORE_REPAIR` |
| W1W6-CAP-010 Learn/Home hierarchy proof | W1W6-DLR-003 | W1-W6 shell | P2 | Act0 Home/Learn shell | Primary action hierarchy may be unclear on compact portrait. | Visual emphasis not source-proven. | Produce compact portrait widget/screenshot proof before repair. | Deterministic 360x640 proof or widget assertion. | None. | Human visual QA before repair. | Independent of content waves. | `HUMAN_QA_BEFORE_REPAIR` |
| W1W6-CAP-011 schema audit fields | W1W6-DLR-006 | W1-W6 tooling | P3 | Content schema/tooling | Future audit repeatability lacks first-class concept fields. | Schema debt, not learner-facing. | Optional `concept_family_id`/`same_signal_group` backfill. | Schema validator unchanged for existing rows. | None. | None. | Opportunistic only. | `DEFER_P3` |

## 4. Rejected and Deferred Items

| Item | Decision | Reason |
| --- | --- | --- |
| W6 combo counts/checkpoint as current W6 score evidence | `REJECT_NOT_CANONICAL` | The source exists under `_rangeThinkingLiteLessons[3..4]` and W7 route ownership; current W6 uses `_rangeThinkingFoundationLessons[0..2]`. |
| Session-drill repair receipts/recheck queue | `REJECT_NOT_CANONICAL` | Optional/noncanonical for W1-W6 Act0 scoring. |
| W4/W5 bridge fixture repair families | `REJECT_NOT_CANONICAL` | Supporting history only; not canonical Act0 progression-required repair. |
| P4 option-count variance and seat-caption ambiguity | `REJECT_LOW_EV` | Not a trust/correctness blocker; keep for Human QA notes only. |
| W1 ranking lesson load and binary-drill density | `HUMAN_QA_BEFORE_REPAIR` | Source can show density, but learner overload must be observed before content expansion. |

## 5. Repair Wave Design

### Wave 1 - Canonical correctness and trust

Scope:

- CAP-001 feedback-title trust fixes in W1/W4/W5.
- CAP-002 W2 `apply_hj_decision` binding fix.
- CAP-008 W4/W5/W6 in-lesson subtitle correction if included as the same
  low-risk source-copy family.

Do not include transfer-depth or repair-mapping expansion in this wave.

Tests:

- correct-answer feedback-title congruence guard for W1-W6 canonical runners;
- W2 task-binding test for `apply_hj_decision`;
- optional subtitle ownership guard if CAP-008 rides with the wave.

### Wave 2 - Canonical assessment validity

Scope:

- CAP-005 prompt leakage cleanup in W1/W2/W4/W5.
- CAP-003 W3 six-seat recognition correction.
- CAP-004 W2 strong/borderline differentiation.
- Weak-ace depth only if it can be a bounded W2 runner/copy repair in the same
  W2 validity family; otherwise defer.

Tests:

- prompt-leak scan over canonical W1-W6 Act0 runners;
- W3 all-six-seat coverage test;
- W2 strong/borderline distinct-runner test.

### Wave 3 - Repair and recheck coverage

Scope:

- CAP-006 W2/W4/W5/W6 same-signal repair mapping and/or `repairFocus*`
  metadata.
- Embed a W4 repair target if no existing canonical W4 target satisfies the
  same-signal rule.
- Split this wave if W2 bucket repair and W4-W6 board/price/bucket repair
  cannot share one safe mapping contract.

Tests:

- invalid or unmapped targets fail closed to exact replay;
- valid same-world targets launch through Home/Review CTA;
- first-value shown/consumed/launched and recheck telemetry preserve source
  world/task attribution;
- targeted recheck does not falsely complete normal progression.

### Wave 4 - Transfer and mastery depth

Scope only if post-Waves-1-3 source re-score still caps a world below 9/10:

- CAP-007 W4 purpose -> size decision;
- CAP-007 W5 texture -> action decision;
- CAP-009 W6 scope/payoff decision.

Omission rule: do not import W6 combo-count/checkpoint content from W7 into W6
unless the route/content owner explicitly admits W6 content expansion.

## 6. Score Synthesis

No final 9/10 is assigned here.

| World | Current canonical provisional score | Confirmed hard caps | Repairs needed before source re-score | Human QA dependencies | Realistic post-repair source ceiling | Final 9/10 condition |
| --- | --- | --- | --- | --- | --- | --- |
| W1 | 7.5 | Feedback-title trust; explicit flush hint leakage; possible load | CAP-001, CAP-005; source re-score after Wave 2 | Ranking lesson load and binary drill density | 8.5-9.0 if trust/leak fixes land without adding overload | Human QA confirms beginner clarity and no overload |
| W2 | 6.0 | `apply_hj_decision` correctness; bucket repair-chain gap | CAP-002, CAP-004, CAP-005, CAP-006 | HJ-medium contrast, bucket repair visibility, weak-ace clarity | 8.5-9.0 after correctness, bucket differentiation, and repair coverage | Canonical HJ task correct, bucket family repaired, QA passes |
| W3 | 7.0 | `position_six_seats` mismatch; inherited feedback-title trust where reused | CAP-001 where reused, CAP-003 | Six-seat recognition clarity | 8.5-9.0 after all-seat coverage and trust fixes | Learner can identify all seats and use position in decisions |
| W4 | 7.0 | P1 capstone title; leakage; repair void; sizing transfer | CAP-001, CAP-005, CAP-006; CAP-007 if still capped | Live repair target trust; size-purpose transfer | 8.5 after Waves 1-3; 9.0 if Wave 4 transfer is needed and lands | Same-world repair and purpose/price/size transfer proven |
| W5 | 7.5 | P1 gap-board title; texture leakage; repair mapping; action transfer | CAP-001, CAP-005, CAP-006; CAP-007 if still capped | Texture-to-action transfer | 8.5 after Waves 1-3; 9.0 with bounded action transfer if needed | Learner converts texture/draw read into action choice |
| W6 | 7.5 | Scope/payoff mismatch; backward repair mapping; no W6 score from W7 content | CAP-006; CAP-009 only after owner/QA decision | Whether current foundation feels complete as "Range Thinking" | 8.5 with same-world repair and copy/payoff reconciliation; 9.0 only if scope is accepted or bounded capstone admitted | W6 scope/payoff matches delivered route and QA confirms mastery confidence |

## 7. Telemetry and Test Implications

- Wave 1 should preserve existing task ids and answer telemetry; only copy and
  W2 runner binding change.
- Wave 2 should preserve canonical task progression; any new W3/W2 tasks need
  normal Act0 task ids and completion behavior.
- Wave 3 is telemetry-sensitive: first-value receipt, Home/Review CTA launch,
  same-signal target launch, recheck completion, and source attribution must be
  tested together.
- No repair wave may use session-drill receipt/recheck telemetry as canonical
  W1-W6 score evidence.

## 8. Human QA Dependencies

Human QA is required after source repairs and source re-score for:

- W1 ranking/load experience;
- W2 HJ-medium and bucket differentiation clarity;
- W3 all-seat recognition transfer;
- W4 price/purpose/size confidence;
- W5 texture-to-action transfer;
- W6 "Range Thinking" scope/payoff trust;
- Home/Learn primary CTA hierarchy if CAP-010 remains visually unresolved.

## 9. Final Disposition

`w1_w6_consolidated_repair_program_ready`

The smallest safe program is Wave 1 -> Wave 2 -> Wave 3, with Wave 4 admitted
only for transfer/mastery items that still cap source score after correctness,
assessment validity, and repair coverage are repaired and re-scored.
