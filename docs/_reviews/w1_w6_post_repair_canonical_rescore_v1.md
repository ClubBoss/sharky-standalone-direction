---
status: "w1_w6_ready_for_bounded_wave4_then_human_qa"
status_source: "derived"
baseline: "cdf89b9e5e97"
generated_by: "docs_frontmatter_v1"
---

# W1-W6 Post-Repair Canonical Re-Score v1

Verdict: `w1_w6_ready_for_bounded_wave4_then_human_qa`

Branch: `claude/w1-w6-post-repair-canonical-rescore-v1`

Base / integrated Wave 3 HEAD: `cdf89b9e5e97d9c24693cb34095313ecc00c64bd`

Scope: docs-only. No product, content, test, or tooling source was modified by
this re-score. Provisional scores are source-only and are explicitly **not**
final 9/10 closure; final closure requires fixed-build novice Human QA.

## Local W1-W6 Route vs Global Alpha Route

This review finalizes the **local W1-W6 source-closure route** only. It may
state that W1-W5 are source-ready for fixed-build novice Human QA and that W6
needs one bounded Wave 4 repair before that local Human QA gate. That does not
make Human QA the automatic next global project step, does not close Alpha, and
does not override the active Alpha backlog or `MASTER_PLAN_v3.0.md`.

After W1-W6 source closure, execution returns to the active Alpha backlog and
Master Plan unless the current execution context explicitly admits W1-W6 Human
QA. Fixed-build novice Human QA remains a future W1-W6 closure gate.

## Integration Note (Phase 0 disposition)

Wave 3 was validated and integrated on the Mac-side repository before this
re-score finalization:

- `main == origin/main == b188f29d777e72e79333dafb0d60f08fcbe4c2f9`;
- Wave 3 source HEAD `== cdf89b9e5e97d9c24693cb34095313ecc00c64bd`;
- `main..cdf89b9e` contains exactly one implementation commit;
- changed files are exactly the four required files;
- verdict string `w1_w6_wave3_canonical_repair_recheck_coverage_implemented`
  is present;
- fast-forward is clean (`b188f29` is an ancestor of `cdf89b9`);
- Wave 3 focused test passed 9/9;
- focused repair/recheck regression suite passed 102/102;
- `flutter analyze` passed;
- `git diff --check`, `git diff --cached --check`, and
  `graphify hook-check` passed;
- `main` was fast-forwarded to `cdf89b9e5e97d9c24693cb34095313ecc00c64bd`;
- `origin/main` was pushed to the same HEAD with ahead/behind 0/0.

Integration sub-verdict: `w1_w6_wave3_integrated_cleanly`.

## Canonical Evidence Basis

Scored strictly against active Act0 definitions in
`lib/ui_v2/act0_shell/act0_shell_state_v1.dart` (world/lesson/task, feedback,
assessed prompts, progression) and the same-world repair mapper
`act0FirstValueSameSignalRepMappingV1` in
`lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`. JSON Session Drills,
campaign packs, archived runners, generic module completion, session-drill
receipts, and optional/debug flows were excluded. W7-owned content
(`_visibleCardRangeContinuationLessons`) was not counted as W6 evidence.

## Wave 1 Verification — PASS

- **Incongruent correct-answer feedback titles repaired.** All six repaired
  correct-option titles are present exactly once and are semantically congruent
  with their proof: `BTN seat found.`, `UTG seat found.`, `Late seat found.`,
  `Pair found.`, `Purpose and price connected.`, `Gap board identified.`
- **`apply_hj_decision` truly delivers an HJ medium-hand decision.** The
  `hand_discipline_apply` task `apply_hj_decision` binds
  `_w1DisciplineApplyHjMediumRunner`: hero holds K♦Q♣ (KQo, a medium hand),
  seat reassigned to HJ (`activeSeatId: 'hj'`, `heroSeatId: 'hj'`,
  `centerLabel: 'HJ, medium hand'`), unopened pot, correct action open-raise
  with congruent feedback (`HJ open is clean.` / "KQo is a medium hand… open
  it when the pot is unopened"). The old UTG 8s/4d trash-fold scenario is gone.
- **W4/W5/W6 in-lesson subtitles match their own worlds.** Canonical drill
  runners inherit world-correct subtitles: W4 purpose/protection runners →
  `Bet Purpose / Price`; W5 texture runner → `Board Awareness`; W6 range runner
  → `Range Thinking`. No cross-world stale subtitle leaks onto a canonical
  drill runner. (`Board Awareness`, `Range Thinking`, and
  `Visible Cards Change Ranges` still occur, but only as the correct subtitle of
  their own worlds.)
- **No new semantic mismatch introduced.** Spot-checked runners are internally
  congruent (caption ↔ hand ↔ correct option ↔ feedback title/reason).

## Wave 2 Verification — PASS

- **Assessed leakage removed without weakening teaching.** The flush-ranking
  drill `_flushRankRunner` no longer discloses the answer pre-choice: caption
  "Hero and CO both show completed five-card hands", hint "Compare the suit
  pattern and the rank sequence before choosing" (process guidance, not the
  answer), question "Which hand ranks higher?". The string
  `Flush beats straight` now survives only as a navigational task *title*, not
  as an assessed caption/hint/center label. W2 bucket drills no longer pre-label
  hands as premium/strong/medium/trash in assessed captions. Theory tasks still
  explain concepts explicitly.
- **W3 `position_six_seats` covers UTG/HJ/CO/BTN/SB/BB via real table
  evidence.** Dedicated seat-ID runners exist for all six seats
  (`_w3SeatIdUtgRunner`, `_w3SeatIdHjRunner`, `_w3SeatIdCoRunner`,
  `_w3SeatIdBtnRunner`, `_w3SeatIdSbRunner`, `_w3SeatIdBbRunner`), plus an
  HJ-vs-CO contrast task and BTN/UTG seat repairs, ending in a six-seat recap.
  The lesson no longer reuses the old W1 position task list.
- **W2 strong vs borderline/medium examples are distinct and coherent.** Strong
  = JJ (`J♥ J♠`); borderline = QJo (`Q♥ J♠`) with a "connected high cards need
  position and frame" frame. Distinct runners, hands, and hints.
- **Canonical IDs and progression remain stable.** Task/lesson/world IDs are
  preserved.

Minor documentation nuance (not a defect): any prior label that described the
borderline hand as suited is stale. Live source uses `Q♥ J♠` (offsuit QJo). The
hand is still distinct from JJ and pedagogically coherent; only the older doc
label was imprecise.

## Wave 3 Verification — PASS

- **Same-world repair target is appropriate to the learner signal.** Every
  target task referenced by the new W2/W4/W5/W6 branches of
  `act0FirstValueSameSignalRepMappingV1` exists exactly once in canonical state
  and is a launchable drill (buckets, purpose, protection, price, texture,
  connectedness, range bucket/board-fit/pressure). W2 bucket misses map to W2
  bucket peers, not backward to W1 first-hand repair; W4/W5/W6 misses stay in
  their own world.
- **Active repair-intent target wins deterministically.** The new same-world
  branches are inserted ahead of the older generic W1/W3 fallback rules, so a
  canonical W2/W4/W5/W6 source task resolves to its same-world target before any
  generic rule can fire.
- **Exact replay remains a safe fallback.** Where no same-world switch case
  matches (unknown/legacy source tasks), control falls through to the generic
  rules and, ultimately, exact replay of the source task; mapped targets can
  never equal the source task.
- **Repair completion and aged recheck remain coherent; no false canonical
  progression completion.** The mapper resolves only launch targets; it does not
  mark any lesson/world/module complete. Completion stays owned by the normal
  answer path and the repair-intent contract.
- **Source attribution remains understandable in learner terms.** The repair
  intent preserves source world/lesson/task, missed signal, skill atom, target
  world/lesson/task, mapping type, and reason code.

## World-by-World Re-Audit

### W1 — Poker from zero
1. **Learner promise:** learn to read the table and take a first correct action.
2. **Surface:** `_pokerFromZeroLessons`, 9 lessons, 70 tasks (teach → guided →
   assessed → repair per lesson).
3. **Strongest dimensions:** teaching-before-assessment integrity (DLR-001
   corrected), repaired congruent feedback titles, dense repair coverage.
4. **Weaknesses:** high task count (70) creates grind/pacing risk; binary A-vs-B
   assessment density; residual template phrasing (DLR-005).
5. **Assessment validity:** valid — teaching tasks gate drills; no confirmed
   canonical hidden-prerequisite defect.
6. **Feedback quality:** high post-Wave-1.
7. **Transfer depth:** adequate for a foundation world (table-read transfer
   tasks present).
8. **Repair/recheck:** mature generic W1 same-signal mapping retained under the
   Wave 3 change.
9. **Mastery/payoff:** checkpoint/recap coverage present.
10. **Readiness for next world:** ready.
11. **Human QA dependencies:** confirm first-time pacing/comprehension across 70
    tasks; confirm A-vs-B density does not enable pattern-guessing.
12. **Provisional score (source-only):** 8.5/10.
13. **Status:** `SOURCE_READY_FOR_FIXED_BUILD_HUMAN_QA`.

### W2 — Hand discipline
1. **Promise:** sort hands into buckets and protect the stack.
2. **Surface:** `_handDisciplineLessons`, 6 lessons, 31 tasks, dedicated
   `discipline_checkpoint`.
3. **Strongest dimensions:** distinct strong/borderline examples, real HJ
   medium-hand apply task, same-world Wave 3 bucket repair.
4. **Weaknesses:** weak-ace depth is thin (`weak_ace_warning`, 2 extra drills).
5. **Assessment validity:** valid; buckets no longer pre-labeled.
6. **Feedback quality:** high.
7. **Transfer depth:** table-notice/transfer task present in checkpoint.
8. **Repair/recheck:** strong after Wave 3 (bucket → bucket peers).
9. **Mastery/payoff:** checkpoint present.
10. **Readiness for next world:** ready.
11. **Human QA dependencies:** confirm weak-ace depth is sufficient for novices.
12. **Provisional score:** 8.5/10.
13. **Status:** `SOURCE_READY_FOR_FIXED_BUILD_HUMAN_QA`.

### W3 — Position thinking
1. **Promise:** recognize the six seats and use position.
2. **Surface:** `_positionThinkingLessons`, 6 lessons, 35 tasks,
   `position_checkpoint`, full six-seat `position_six_seats`.
3. **Strongest dimensions:** complete UTG/HJ/CO/BTN/SB/BB recognition with
   table evidence and seat repairs; HJ-vs-CO nearby-seat discrimination.
4. **Weaknesses:** 6-max only (no MP/UTG+1); some upstream example reuse in
   later position lessons.
5. **Assessment validity:** valid — seat answers derive from table markers.
6. **Feedback quality:** high (repaired seat titles).
7. **Transfer depth:** same-hand-different-seat contrast present
   (`button_vs_cutoff`, HJ/CO contrast).
8. **Repair/recheck:** seat-ID repairs + generic W3 mapping.
9. **Mastery/payoff:** checkpoint + recap.
10. **Readiness for next world:** ready.
11. **Human QA dependencies:** confirm whether novices question the 6-seat scope
    (see framing decision).
12. **Provisional score:** 8.5/10.
13. **Status:** `SOURCE_READY_FOR_FIXED_BUILD_HUMAN_QA`.

### W4 — Bet purpose / price
1. **Promise:** understand why bets happen and what price asks you to risk.
2. **Surface:** `_betPurposePriceLessons`, 7 lessons, 33 tasks, `small_half_pot`
   sizing lesson, `price_checkpoint`.
3. **Strongest dimensions:** purpose (value/bluff), protection/denial, and price
   are all taught; Wave 3 same-world repair for purpose/protection/price.
4. **Weaknesses:** sizing is taught as **arithmetic recognition**
   (`w4_half_pot_bet`: "Which size is half-pot?" of a 6 BB pot), not as a
   purpose-to-size decision. `price_checkpoint` partially bridges purpose ↔ size
   ↔ price but the core sizing drills stay arithmetic.
5. **Assessment validity:** valid; purpose/free-card answers no longer leaked.
6. **Feedback quality:** high.
7. **Transfer depth:** moderate — purpose→size link exists only at checkpoint.
8. **Repair/recheck:** strong after Wave 3.
9. **Mastery/payoff:** price checkpoint present.
10. **Readiness for next world:** ready.
11. **Human QA dependencies:** confirm whether arithmetic-only sizing leaves a
    real purpose-to-size gap for novices.
12. **Provisional score:** 8.0/10.
13. **Status:** `SOURCE_READY_FOR_FIXED_BUILD_HUMAN_QA`.

### W5 — Board awareness
1. **Promise:** read board texture, draws, and how streets change the plan.
2. **Surface:** `_boardDrawsLessons`, 6 lessons, 34 tasks (dry/wet, connected,
   flush/straight draws), with real-table transfer tasks
   (`w5_made_hand_vs_flush_draw_transfer`, `w5_river_draw_story_transfer`).
3. **Strongest dimensions:** clear texture/draw classification with concrete
   board evidence; Wave 3 same-world texture/connectedness repair.
4. **Weaknesses:** classification-to-action transfer is partial — the learner
   classifies texture/draws more than they act on them.
5. **Assessment validity:** valid; wet-board classification no longer leaked in
   hints.
6. **Feedback quality:** high.
7. **Transfer depth:** moderate — some action-linked transfer tasks exist.
8. **Repair/recheck:** strong after Wave 3.
9. **Mastery/payoff:** recap/transfer tasks present.
10. **Readiness for next world:** ready.
11. **Human QA dependencies:** confirm classification-to-action transfer is
    sufficient.
12. **Provisional score:** 8.0/10.
13. **Status:** `SOURCE_READY_FOR_FIXED_BUILD_HUMAN_QA`.

### W6 — Range thinking (foundation)
1. **Promise (world card):** "Group hands into ranges and see who has the
   advantage."
2. **Surface:** `_rangeThinkingFoundationLessons` = exactly 3 lessons
   (`range_bucket_basics`, `range_board_fit`, `range_pressure_lines`),
   ~18 tasks, **no dedicated checkpoint lesson**.
3. **Strongest dimensions:** coherent own-hand bucketing (value / bluff
   candidate / missed) with board-fit shifts; Wave 3 same-world repair including
   a dedicated `w6_wet_board_repair`.
4. **Weaknesses:** **scope/payoff mismatch** — lessons teach sorting the hero's
   own hand into buckets and an action direction, but the world card promises
   range-vs-range "who has the advantage"; the world is also thin (3 lessons vs
   6-9 elsewhere) and has no checkpoint. W7 continues the same
   `_rangeThinkingLite` family, so the forward bridge is structural but not
   surfaced inside W6.
5. **Assessment validity:** valid for what it teaches (own-hand buckets).
6. **Feedback quality:** adequate.
7. **Transfer depth:** limited — pressure-line transfer tasks exist but the
   range-advantage promise is not delivered.
8. **Repair/recheck:** strong after Wave 3 for the buckets it does teach.
9. **Mastery/payoff:** weakest of W1-W6 — no checkpoint; payoff does not match
   the world-card promise.
10. **Readiness for next world:** conditional — the W6→W7 bridge is implicit.
11. **Human QA dependencies:** would follow the bounded Wave 4 repair.
12. **Provisional score:** 7.5/10.
13. **Status:** `BOUNDED_WAVE4_REPAIR_REQUIRED`.

## Remaining Caps by World

- **W1:** 70-task load/grind and binary A-vs-B density are real but
  QA-observable, not source blockers; residual template phrasing (DLR-005) is
  deferred. No feedback/leakage cap remains after Waves 1-2.
- **W2:** weak-ace depth is thin but coherent (low EV); world identity is clear;
  repair coverage is good after Wave 3.
- **W3:** six-seat repair fulfills the six-seat lesson promise; same-hand
  different-seat transfer is present; the only open item is 6-max/full-ring
  framing (below).
- **W4:** arithmetic-only sizing vs purpose-to-size is a genuine transfer-depth
  cap, partially mitigated by `price_checkpoint`; price heuristic is present;
  repair coverage is good.
- **W5:** classification-to-action transfer is the open cap; texture/draw
  mastery and repair coverage are good.
- **W6:** own-hand-buckets-vs-advantage promise, no checkpoint, and an implicit
  W6→W7 bridge together cap the world below Human-QA readiness; repair coverage
  itself is good after Wave 3.

## 6-max / Full-ring Framing Decision

Decision: **`DEFERRED_BOUNDED_LEARNER_TRUST_CANDIDATE`**.

A live or full-ring learner could reasonably ask why only six seats exist and
where MP/UTG+1 sit. However, the canonical copy does **not** overclaim universal
coverage — the lesson explicitly names the six seats ("Recognize UTG, HJ, CO,
BTN, SB, BB"), and the early/middle/late/blind principle transfers to larger
tables. The trust gap is therefore likely high-EV and low-risk, but it is not
an immediate Wave 4 blocker and does not require Human QA as the only path to
admission.

If the next W3/content seam opens, or product evidence confirms the need, admit
a bounded learner-trust copy note only: state that the foundation teaches a
6-max training table, note that 8/9-max adds middle seats, preserve
early/middle/late/blind transferability, and do not change table layout or add
full-ring assessments.

## Wave 4 Admission Decisions

1. W4 purpose-to-size decision — **`HUMAN_QA_FIRST`** (purpose↔size link exists
   at `price_checkpoint`; confirm the drill-level gap with novices first).
2. W5 texture-to-action decision — **`HUMAN_QA_FIRST`** (action-transfer tasks
   already exist; confirm sufficiency with novices).
3. W6 scope/payoff reconciliation — **`ADMIT_WAVE4`** (bounded: reconcile the
   "who has the advantage" world-card promise with the delivered own-hand
   bucketing — either adjust the promise copy or add a minimal range-vs-range
   payoff task; no broad content expansion).
4. W6 bounded checkpoint or forward bridge — **`ADMIT_WAVE4`** (bounded: add one
   W6 checkpoint and/or an explicit W6→W7 bridge surface).
5. W3 6-max/full-ring framing —
   **`DEFERRED_BOUNDED_LEARNER_TRUST_CANDIDATE`** (likely high-EV and
   low-risk, but not admitted as immediate Wave 4 and not gated only on Human
   QA).
6. Residual W2 weak-ace depth — **`DEFER`** (thin but coherent; low EV).
7. Residual W1 load mitigation — **`HUMAN_QA_FIRST`** (do not cut content before
   QA confirms a pacing problem).

Only W6 requires bounded Wave 4 work before fixed-build novice Human QA. Wave 4
must remain bounded to the W6 items above.

## Pre-Existing Failing Test Disposition

Test: `test/ui_v2/act0_completed_decision_callback_contract_v1_test.dart`,
case "sizing confirmation resolves its preset option before emitting a
completed-decision contract".

Disposition: **`STALE_TEST_EXPECTATION_PENDING_BOUNDED_TEST_ONLY_FIX`**.

Root cause: the test helper calls
`_task('world_5', 'small_half_pot', 'w4_half_pot_bet')`, but the
`small_half_pot` lesson and `w4_half_pot_bet` task are canonically owned by
**`world_4`** (`_betPurposePriceLessons`; the `w4_` prefix and the world card
"Bet Purpose / Price" confirm this). `world_5` (`_boardDrawsLessons`, "Board
Awareness") does not contain that lesson, so the helper's
`firstWhere((lesson) => lesson.lessonId == 'small_half_pot')` throws
`Bad state: No element` in the sizing lookup. Git history (`git log -S`) shows
`small_half_pot`/`w4_half_pot_bet` were introduced in the initial snapshot and
were **not** touched by Waves 1, 2, or 3; the product content is internally
consistent and correct. The failure is a wrong world argument in the test, not a
canonical regression, and is unrelated to the waves.

Because the fix is a test-code change (`'world_5'` → `'world_4'`), it is out of
scope for this docs-only task. Bounded recommendation: in a separate, bounded
test-only change, correct the world argument to `'world_4'` (or add the missing
`world_4` lesson lookup); no product/content change is warranted.

## Ledger Corrections (minimum factual)

`docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md`:

1. `W1W6-DLR-004` still names the **session-drill repair-receipt owner** and the
   `session_drill_repair_receipt_adapter_v1.dart` seam as the path to broaden
   repair coverage. Wave 3 implemented canonical same-world repair/recheck
   coverage for W2/W4/W5/W6 through `act0FirstValueSameSignalRepMappingV1` in
   `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` (the canonical Act0
   owner). The DLR-004 minimum-repair wording is therefore **superseded for
   canonical scoring**: any remaining repair-breadth work should target the
   canonical mapper, not the session-drill receipt seam. The historical row is
   preserved with a superseding note (not erased).
2. `W1W6-DLR-005` confirmed prompt/hint leakage was addressed by Wave 2
   (CAP-005) for W1/W2/W4/W5; only the deferred template residue remains. Note
   the partial closure; do not treat DLR-005 as fully open.

No competing SSOT is created. History is preserved.

## Local Human QA Readiness

W1-W5 are source-ready for fixed-build novice Human QA now. W6 requires one
bounded Wave 4 pass (scope/payoff reconciliation + a checkpoint/forward bridge)
before it enters Human QA. No world is assigned a final 9/10 from source alone;
local W1-W6 closure is gated on fixed-build novice Human QA. This is not an
Alpha-closure claim and does not make Human QA the automatic next global project
step.

## Final Verdict

`w1_w6_ready_for_bounded_wave4_then_human_qa`
