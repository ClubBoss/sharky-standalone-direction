---
status: "docs-only canonical deep-learning audit. No product, content, test,"
status_source: "derived"
doc_date: "2026-07-08"
baseline: "0ca324f842ab"
generated_by: "docs_frontmatter_v1"
---

# W1-W3 Canonical Deep Learning Audit v1

Date: 2026-07-08

Branch: `claude/w1-w3-canonical-deep-learning-audit-v1`

Base HEAD (integrated main): `0ca324f842abab969fb23546a1a694e12eda2bd3`

Status: docs-only canonical deep-learning audit. No product, content, test,
tooling, Modern Table, legacy-flow, or repair changes were made.

Final verdict:

`w1_w3_canonical_learning_ready_for_bounded_repairs`

## 0. Method and Evidence Scope

Orientation used the canonical ownership map
(`docs/_reviews/w1_w6_canonical_ownership_map_v1.md`) and graphify
(`graphify query "W1 W2 W3 Act0 canonical lessons tasks ..."`) before reading
live Act0 source.

Scoring uses ONLY canonical Act0 evidence:

- `_act0PreviewWorlds` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:6026`)
- `_pokerFromZeroLessons` (W1, `act0_shell_state_v1.dart:1427`)
- `_handDisciplineLessons` (W2, `act0_shell_state_v1.dart:2899`)
- `_positionThinkingLessons` (W3, `act0_shell_state_v1.dart:3217`)
- Act0 task order, progression/completion, feedback, repair/recheck, payoff, as
  owned by `act0_shell_preview_screen_v1.dart` and
  `act0_lesson_runner_shell_v1.dart`.

Explicitly excluded from scoring (listed in section 11): JSON Session Drills
(Flow B / legacy), campaign packs (Flow A / debug spine), archived runners
(`lib/archive/...`), generic module completion, Audit Hub content counts,
optional/debug flows.

Prior Flow-B showdown finding `W1W6-DLR-001` is CLOSED / MISSCOPED and was NOT
reopened. The canonical W1 route teaches hand rankings (lesson 8,
`hand_rankings_table`) and showdown (lesson 9, `showdown_winning`); this was
verified in live source (`act0_shell_state_v1.dart:1971`, `:2100`,
`_showdownBestHandRunner:9166`, `_showdownKickerRunner:9250`).

Runner model (evidence basis for feedback/ambiguity/leakage dimensions):
`Act0RunnerStateV1` (`act0_shell_state_v1.dart:464`) with per-option
`Act0RunnerOptionV1` (`:709`) carrying `isCorrect`, `quality`
(correct/suboptimal/wrong), `feedbackTitle`, `feedbackReason`, and
`repairFocus{SeatIds,CardIds,Labels}`. Reused lessons are built by
`_lessonFromTasksV1` (`:2203`) which merges `sourceTasks` + `extraDrills` and
re-titles via `_retitledTasksV1` (`:2176`).

Canonical task surfaces inspected: W1 = 70 tasks (9 lessons), W2 = 35 tasks
(6 lessons), W3 = 44 tasks (6 lessons).

---

## 1. W1 - Poker from Zero (lesson-by-lesson)

Source: `_pokerFromZeroLessons` (`act0_shell_state_v1.dart:1427-2174`).

| # | lessonId | tasks | learn->practice->prove present | notes |
| --- | --- | --- | --- | --- |
| 1 | `what_poker_is` | 6 | yes (theory + transfer recheck + proveIt) | clean onboarding; table-read transfer + recheck pair |
| 2 | `what_poker_is_content` | 7 | yes | pot/stack, folds vs showdown, all-in, matched-chips transfer |
| 3 | `cards_ranks_suits` | 7 | yes | deck, rank, suit, private/board, board count, best-five idea |
| 4 | `your_first_hand` | 8 | yes | full street walk preflop->river->showdown + recap |
| 5 | `fold_check_call_raise` | 7 | yes | 4 core verbs; `actions_fold_drill` is `fixMistakes` |
| 6 | `blinds_action_order` | 7 | yes | blinds post, first/last preflop actor, button moves |
| 7 | `positions` | 7 | yes | teaches all six seat names; tap BTN/UTG/CO, early/late |
| 8 | `hand_rankings_table` | 14 | yes | pair->royal ladder + 3 compare tasks + best-five |
| 9 | `showdown_winning` | 7 | yes | two-ways-to-win, best hand, kicker, board plays, tie |

Dimension findings (1-20):

- Teach-before-ask (3), sequencing (5): sound. Every lesson opens with a
  `learn`/`theory` beat before drills; streets are ordered; rankings precede
  showdown comparison.
- Terminology (4): mostly introduced before use. Hand-code shorthand (`s`/`o`)
  is introduced later (W2 bucket intro), acceptable since W1 uses full ranks.
- Cognitive load (6) / repetition: `hand_rankings_table` packs 14 tasks in one
  lesson; combined with the 70-task W1 total this is the strongest overload
  risk for absolute beginners. Many drills are binary A-vs-B (e.g.
  `_handRankingsRunner:8484` pair vs high card; `_flushRankRunner:8560` flush
  vs straight), which lowers assessment validity (dim 10) and inflates rep
  count without adding decision variety.
- Feedback specificity (13) — MATERIAL DEFECT: several W1 runners carry
  recycled "session/mindset" strings as the CORRECT-answer `feedbackTitle`,
  incongruent with the task:
  - `_buttonSeatRunner` correct BTN tap -> `feedbackTitle: 'Win can hide a
    leak.'` (`act0_shell_state_v1.dart:8327`).
  - `_utgSeatRunner` correct UTG tap -> `'Reset before next hand.'` (`:8370`).
  - `_latePositionRunner` correct -> `'Log it, then reset.'` (`:8449`).
  - `_handRankingsRunner` correct "find the pair" -> `'Process ignores table
    talk.'` (`:8491`).
  These read as nonsense praise and are a trust/quality failure across the
  seat-id and hand-ranking families (P1).
- Answer leakage (12): some drills telegraph the answer in the hint/caption.
  Clearest: `_flushRankRunner` hint `'Flush beats straight in Holdem.'` with
  question "Which hand ranks higher?" and options Flush/Straight
  (`act0_shell_state_v1.dart:8558-8564`). (P3, DLR-005-adjacent.)
- Acceptable/suboptimal treatment (14): strong where authored — the
  fold/call/raise base (`_whatYouCanDoRunner:6664`) marks `call` as
  `suboptimal` with distinct "legal but passive" feedback, and
  `_showdownBestHandRunner:9166` marks `hero_cards_only` suboptimal. Good model
  where present.
- Showdown/kicker/best-five/board-plays (W1-specific focus): CONFIRMED taught
  canonically (`showdown_winning` lesson tasks `:2112-2170` and
  `_showdownKickerRunner:9250`, `_boardPlaysRunner`). Best-five appears in both
  `cards_ranks_suits_best_five` and `hand_rankings_best_five_drill`.
- Repair (16)/recheck (17): W1 has embedded `fixMistakes` drills plus five
  same-signal mapped repair/reinforcement targets (see section 5).
- Payoff (19)/readiness (20): `showdown_winning` ends on
  `_worldOneCheckpointRunner`; world-complete summary + W2 unlock owned by
  `_maybeShowBlockCompletionSummary` / `_advanceAfterTask`.

W1 verdict: content is comprehensive and on-route; blockers to 9/10 are the
feedback-title incongruence, scattered hint/caption leakage, and load in the
14-task rankings lesson. All bounded.

---

## 2. W2 - Hand Discipline (lesson-by-lesson)

Source: `_handDisciplineLessons` (`act0_shell_state_v1.dart:2899-3215`).

| # | lessonId | tasks | source |
| --- | --- | --- | --- |
| 1 | `hand_discipline_buckets` | 7 | native card |
| 2 | `fold_discipline` | 5 | `_lessonFromTasksV1` inline |
| 3 | `weak_ace_warning` | 6 | `_preflopBasicsLessons[5]` (=`dominated_hand_warning`) + 2 extra |
| 4 | `continue_or_let_go` | 6 | inline |
| 5 | `hand_discipline_apply` | 5 | native card |
| 6 | `discipline_checkpoint` | 6 | inline + real-table transfer |

Does W2 genuinely teach Hand Discipline (W2-specific focus)? Mostly yes: fold
discipline, weak-ace/dominated caution, and continue-vs-let-go are the right
outcomes and the title/job matches the content. But:

- Reuse quality: bucket and fold runners are W3-era "Preflop Basics/Position"
  runners repurposed (`_world3BucketsIntroRunner:10880` lessonSubtitle
  `'Preflop Basics'`; `_world3EarlyFoldRunner`, `_world3WeakFacingFoldRunner`,
  `_world3DominatedFoldRunner`). `_w1StrongBucketRunner:12693` and
  `_w1MediumBucketRunner:12753` correctly re-label to `'Hand Discipline'`, but
  `_world3PremiumBucketRunner`/`_world3TrashBucketRunner` keep the
  `'Preflop Basics'` subtitle -> world-identity blur (P3).
- DUPLICATE RUNNER inside one lesson (P3): `hand_discipline_buckets` uses
  `_w1StrongBucketRunner` for BOTH `hand_discipline_buckets_strong`
  (`:2932`) and `hand_discipline_buckets_borderline` (`:2956`) -> the identical
  prompt "Which bucket is JJ?" is asked twice in the same lesson. Recognition,
  not new decision.
- TASK/CONTENT MISMATCH (P1): in `hand_discipline_apply`, both
  `apply_utg_fold` (`:3127`) and `apply_hj_decision` (`:3143`) use
  `_w1DisciplineApplyEarlyFoldRunner` (`:12911`). That runner renders "UTG,
  8S 4D, fold". So the task titled "HJ, medium hand" actually presents a UTG
  trash-fold spot. The advertised independent HJ-medium decision does not
  exist -> assessment invalid for that beat.
- Weak-ace thinness (P3): `weak_ace_warning` reuses the generic
  `dominated_hand_warning` source (intro "Trouble hands"
  `_world3DominatedIntroRunner`, dominated_fold, strong_continue, recap). Only
  the 2 extra drills (`weak_ace_pressure_fold`, `weak_ace_kicker_compare`
  "A7 vs KQ", `:3027-3042`) are weak-ace-specific. Weak-ace, dominated-hand and
  fold-discipline outcomes ARE supported, but weak-ace is under-taught relative
  to its title.
- Scenario repetition across lessons (P3): the J8o-BTN-vs-CO fold spot
  (`_world3WeakFacingFoldRunner:11865`) recurs in `fold_discipline`
  (`facing_fold`), `continue_or_let_go` (`weak_let_go`), and W3 source. Same
  exact spot, multiple placements.
- Contrast / independent decision (7, 9, 15): the bucket lesson gives premium/
  strong/medium/trash contrast (good), but option counts are inconsistent
  (premium/trash = 2 options `:10913`,`:10958`; strong/medium = 3 options
  `:12700`,`:12760`), and the apply/checkpoint lessons are where genuinely
  independent bucket+seat+frame decisions live. `discipline_checkpoint` adds a
  real-table transfer task (`checkpoint_table_discipline`, taskFamily
  `transfer`, `:3197`) — the strongest W2 beat.

W2 verdict: right subject, sound structure, but a correctness defect
(apply_hj), duplicate/under-differentiated drills, and a repair-chain gap (see
section 5) hold it well below 9/10.

---

## 3. W3 - Position Thinking (lesson-by-lesson)

Source: `_positionThinkingLessons` (`act0_shell_state_v1.dart:3217-3516`).

| # | lessonId | tasks | source |
| --- | --- | --- | --- |
| 1 | `position_six_seats` | 11 | `_pokerFromZeroLessons[5]` (=`blinds_action_order`) + 4 extra |
| 2 | `button_advantage` | 7 | inline + 1 repair extra |
| 3 | `early_vs_late` | 7 | `_handValuePositionLessons[4]` (=`position_changes_value`) + 3 extra |
| 4 | `same_hand_different_seat` | 7 | `_preflopBasicsLessons[4]` (=`same_hand_different_frame`) + 3 extra |
| 5 | `position_apply` | 6 | native card |
| 6 | `position_checkpoint` | 6 | inline + real-table transfer |

Position progression (W3-specific focus): seat identification, action order,
early vs late, BTN advantage, and IP/OOP information edge are all present and
mostly well-authored. The W3-native extra drills are the highest-quality
authored content in the three worlds — specific, correctly reframed feedback:
`_w3SeatOrderDecisionRunner:12141`, `_w3EarlySeatPressureRunner:12206`
("Five players still act after UTG"), `_w3LateInfoEdgeRunner`,
`_w3LateSeatContrastRunner` (BTN vs CO). Same-hand-different-seat transfer is
supported by `same_hand_early_fold` / `same_hand_late_open` (`:3369-3384`).

Key findings:

- FLAGSHIP TITLE/CONTENT MISMATCH (P2): `position_six_seats` is titled
  "The 6 positions / Recognize UTG, HJ, CO, BTN, SB, and BB" (`:3220-3221`) but
  its `sourceTasks` are `_pokerFromZeroLessons[5].taskList` — index 5 is
  `blinds_action_order` (blinds post, 1BB baseline, first/last preflop actor,
  button moves), NOT the `positions` lesson (index 6). Its extra drills only
  add seat-order plus BTN and UTG seat-id repairs
  (`position_repair_seat_id_btn/utg`, `:3242-3257`). So the lesson that
  promises recognition of all six seat names actually delivers blinds/action-
  order drills and never individually drills HJ, CO, SB, or BB name
  recognition. Mitigated because W1 lesson 7 (`positions`) did teach all six
  seat names, but the on-title teach-before-ask for four seats is missing here.
- Concept reuse mismatch (P3): `same_hand_different_seat` reuses
  `same_hand_different_frame` source (frame = open/call action context, not
  seat). The extra seat drills partly correct this, but the reused core is
  about frame, not seat.
- W1->W3 duplication (P3): reusing `blinds_action_order` tasks inside W3 repeats
  W1 content rather than advancing it.
- Feedback specificity (13): strong on W3-authored runners; but reused
  seat-tap runners inherit W1's incongruent titles (e.g. `find_button` uses
  `_buttonSeatRunner` -> "Win can hide a leak.").
- Repair (16)/recheck (17): BEST of the three worlds — embedded `fixMistakes`
  drills for seat-id BTN/UTG, early/late order, BTN-last-postflop, UTG-players-
  behind, and same-hand/different-seat, plus a same-signal mapped
  table-position repair (see section 5).
- Payoff/readiness (19, 20): `position_apply` (proveIt recap) and
  `position_checkpoint` (real-table transfer `position_checkpoint_table_notice`
  taskFamily `transfer`, `:3498`) give a genuine independent-decision close and
  route to W4.

W3 verdict: strongest repair breadth and best-authored drills, but the
flagship lesson's title/content mismatch and reuse dilution cap it.

---

## 4. Cross-World Seam Findings

### W1 -> W2

- Prerequisite handoff: PASS. W1 teaches positions (lesson 7), blinds/order
  (lesson 6), actions (lesson 5), rankings/showdown (lessons 8-9). W2 buckets
  build on hand strength; W2 fold/open/call drills reuse action concepts. Unlock
  is sequential (`world_2` locked until all W1 lessons complete; progression
  owned by `_progressWorlds`).
- Terminology jump: MINOR. W2 bucket intro introduces hand-code shorthand
  (`KTs`, `J8o`, `T=Ten`, `s=suited`, `o=offsuit`) in a teaching step
  (`_world3BucketsIntroRunner:10886-10904`); taught before asked within-lesson.
- Duplication / concept consumed before mastery: acceptable; no W2 concept is
  assessed before its own teach beat.
- Difficulty progression: PASS — W2 moves from single-attribute recognition
  (bucket) toward bucket+seat+frame apply.

### W2 -> W3

- Prerequisite handoff: PASS structurally (W3 locked until W2 complete).
- Unnecessary duplication: PRESENT — W3 `position_six_seats` reuses W1
  `blinds_action_order`, and the J8o-BTN-vs-CO fold spot appears in both W2 and
  W3 source. Position concepts (early/late, BTN) were already introduced in W1
  lesson 7 and W2 apply, so W3's opener is partly redundant.
- World identity: DILUTED at the seam. W3's first lesson reads as blinds/order
  revision rather than the promised seat-name recognition, blurring where W2
  discipline ends and W3 position begins.
- No sudden terminology jump; no concept consumed before mastery.

---

## 5. Canonical P2 Revalidation

### `W1W6-DLR-004` — repair breadth for W1-W3

Classification: **PARTIALLY_CONFIRMED** (W2 gap CONFIRMED_CANONICAL; exact W2
mis-routing REQUIRES_HUMAN_QA).

Evidence: open-repair intents (which drive Home/Review repair CTAs and the aged-
recheck chain) are created only when `buildAct0RepairIntentV1`
(`act0_repair_intent_contract_v1.dart:144`) receives a non-null skill receipt
from `act0FirstValueSkillReceiptForRunnerV1`
(`act0_lesson_runner_shell_v1.dart:4091`). That receipt derives a signal from
the selected option's `repairFocus*` fields or from table seat/card signals
(`_feedbackSignalProofForRunnerV1:3964`, `_proofFromTableSignalsV1`). Mapped
(non-exact) repair targets come from a fixed table
`act0FirstValueSameSignalRepMappingV1` (`act0_shell_preview_screen_v1.dart:57`):

- W1: 5 families mapped — action_read->`actions_check_drill`,
  board_read->`your_first_hand_turn`/`cards_ranks_suits_board_count`,
  price_read->`actions_call_drill`,
  starting_hand_read->`your_first_hand_private_cards_recheck`,
  table_read->`what_poker_is_table_read_recheck` (`:66-130`).
- W3: 1 family mapped — table_position_read/`hero_button` ->
  `position_checkpoint_...table_notice` (`:131-142`); plus rich embedded
  `fixMistakes` repair drills in every W3 lesson.
- W2: ZERO mapped repair targets in that table. W2 misses fall back to `'exact'`
  replay at best.

Confirmed canonical gap: the W2 `hand_discipline_buckets` drills
(`_world3PremiumBucketRunner:10908`, `_world3TrashBucketRunner:10953`,
`_w1StrongBucketRunner:12693`, `_w1MediumBucketRunner:12753`) set NO
`repairFocus*` on their wrong options and highlight only hero cards, so
`_proofFromTableSignalsV1` returns null -> no skill receipt -> `errorType`
becomes `'unknown'` with `repairFamilyId == null`
(`act0_lesson_runner_shell_v1.dart:1409-1416`) -> no open repair intent. The
first W2 lesson's bucket mistakes therefore do not enter the repair/recheck
chain at all. Whether any bucket miss instead gets mis-routed via stale
inherited `highlightedSeatIds` is runtime-dependent and REQUIRES_HUMAN_QA.

### `W1W6-DLR-005` — prompt/option leakage for W1-W3

Classification: **CONFIRMED_CANONICAL** (bounded to specific families).

Evidence:

- Bucket family (W2 + W3) captions pre-state the answer, then ask it:
  - `_world3PremiumBucketRunner` caption "AA is a premium preflop hand." ->
    "Which bucket is AA?" (`:10910-10912`).
  - `_w1StrongBucketRunner` "JJ is a strong preflop hand." -> "Which bucket is
    JJ?" (`:12697-12699`).
  - `_w1MediumBucketRunner` "KQo is a medium preflop hand." -> "Which bucket is
    KQo?" (`:12757-12759`).
  - `_world3TrashBucketRunner` "J8o is a weak offsuit starter..." -> "Which
    bucket fits J8o early?" (`:10955-10957`).
- W1 hand-ranking hint leak: `_flushRankRunner` hint "Flush beats straight in
  Holdem." with question "Which hand ranks higher?" (`:8558-8559`).

Not universal: fold/open/call decision drills and the W3 position extra drills
do not leak (neutral prompts, real decisions). Leakage is concentrated in the
bucket/recognition families.

---

## 6. Provisional Scores (canonical content only; no final 9/10 without Human QA)

### W1 - Poker from Zero: provisional 7.5 / 10 — status `CANONICAL_REPAIR_REQUIRED`

- Strongest dimensions: coverage/sequencing (1,5), teach-before-ask (3),
  showdown/rankings validity (10 where 3-option), suboptimal treatment (14),
  repair breadth (16).
- Weakest dimensions: feedback specificity (13, recycled titles), answer
  leakage (12, some hints), cognitive load (6, 14-task rankings + 70 total),
  assessment validity on binary drills (10).
- Hard cap: 8/10 until feedback-title incongruence and hint/caption leakage are
  repaired.
- Conditions to reach 9/10: fix all recycled/incongruent `feedbackTitle`
  strings on seat-id and rankings runners; remove hint/caption answer leakage;
  reduce binary-only reps or add decision variety in the rankings lesson; then
  Human QA on runtime load and beginner overload.
- Human QA dependencies: perceived overload across 70 tasks; whether binary
  drills feel like learning or busywork.

### W2 - Hand Discipline: provisional 6.0 / 10 — status `CANONICAL_REPAIR_REQUIRED`

- Strongest dimensions: title/job alignment (job vs content), apply+checkpoint
  transfer (15,18), fold-discipline/dominated outcomes present.
- Weakest dimensions: assessment validity (10, apply_hj mismatch), repair
  breadth (16, bucket chain gap + no mapped targets), duplication (7,
  strong==borderline; cross-lesson J8o), answer leakage (12, buckets), world
  identity (stale subtitles).
- Hard cap: 7/10 until the `apply_hj_decision` runner mismatch and the bucket
  repair-chain gap are fixed.
- Conditions to reach 9/10: give `apply_hj_decision` a real HJ-medium runner;
  differentiate `hand_discipline_buckets_borderline` from `_strong`; add
  `repairFocus`/mapped repair for the bucket family so misses enter the recheck
  chain; deepen weak-ace-specific teaching; remove bucket caption leakage;
  normalize reused subtitles to Hand Discipline; then Human QA.
- Human QA dependencies: confirm actual repair routing for bucket misses;
  confirm learners perceive W2 as new discipline rather than W1/W3 reruns.

### W3 - Position Thinking: provisional 7.0 / 10 — status `CANONICAL_REPAIR_REQUIRED`

- Strongest dimensions: repair breadth (16, best of three), authored feedback
  specificity (13 on W3-native drills), position progression + transfer
  (15,18).
- Weakest dimensions: teach-before-ask (3) and world identity for the flagship
  lesson (title/content mismatch), reuse dilution (frame vs seat; W1 blinds
  reuse), inherited incongruent seat-tap titles (13).
- Hard cap: 8/10 until `position_six_seats` is retargeted to seat-name
  recognition (or re-titled) and HJ/CO/SB/BB recognition is drilled.
- Conditions to reach 9/10: point `position_six_seats` at seat-identification
  source (or author explicit HJ/CO/SB/BB recognition drills); replace the
  frame-based `same_hand_different_seat` core with seat-based content; fix
  inherited seat-tap feedback titles; then Human QA on transfer beyond label
  memorization.
- Human QA dependencies: whether learners transfer seat reasoning to novel
  spots vs memorizing labels.

---

## 7. Admitted Findings (by priority)

P0: 0.

P1 (2):
- W1-DLA-P1-01: systemic incongruent CORRECT-answer `feedbackTitle` strings on
  W1 seat-id and hand-ranking runners (`:8327`,`:8370`,`:8449`,`:8491`) — trust
  failure, also surfaces in reused W3 seat-tap.
- W2-DLA-P1-02: `apply_hj_decision` renders a UTG trash-fold instead of the
  advertised HJ-medium decision (shared `_w1DisciplineApplyEarlyFoldRunner`,
  `act0_shell_state_v1.dart:3143` + `:12911`) — advertised assessment does not
  exist.

P2 (3):
- W2-DLA-P2-01 (`W1W6-DLR-004`): W2 bucket family excluded from the repair/
  recheck chain; W2 has no same-signal mapped repair targets.
- ALL-DLA-P2-02 (`W1W6-DLR-005`): answer leakage in bucket captions (W2/W3) and
  a W1 hand-ranking hint.
- W3-DLA-P2-03: `position_six_seats` title/content mismatch — reuses
  `blinds_action_order`; HJ/CO/SB/BB name recognition not drilled on-title.

P3 (7):
- W2 duplicate runner `strong`==`borderline` (both `_w1StrongBucketRunner`).
- W2 weak-ace teaching thin (generic dominated source reused).
- W2/W3 stale reused subtitles (`'Preflop Basics'`) blur world identity.
- W1 binary-only drills lower assessment validity in rankings.
- W1 cognitive load: 14-task rankings lesson + 70-task total.
- W3 `same_hand_different_seat` reuses frame (not seat) source.
- Cross-lesson repetition of the J8o-BTN-vs-CO fold spot (W2 x2, W3).

P4 (2):
- Recognition-drill captions that name the target seat ("Button is the dealer
  seat" -> "Tap the Button") — borderline teaching vs leak.
- Inconsistent option counts (2 vs 3) across bucket drills.

---

## 8. Repair Candidates (docs-only; not implemented)

1. Replace incongruent CORRECT `feedbackTitle` strings on `_buttonSeatRunner`,
   `_utgSeatRunner`, `_latePositionRunner`, `_handRankingsRunner` with
   task-matched praise. (W1-DLA-P1-01)
2. Author a distinct HJ-medium runner for `apply_hj_decision`. (W2-DLA-P1-02)
3. Add `repairFocus*` metadata (and/or a bucket same-signal mapped repair
   target) so W2 bucket misses generate a skill receipt and enter recheck.
   (W2-DLA-P2-01)
4. Rewrite bucket captions so they no longer state the bucket before asking;
   fix the `_flushRankRunner` hint. (ALL-DLA-P2-02)
5. Retarget `position_six_seats` to seat-identification source, or re-title it
   and add explicit HJ/CO/SB/BB recognition drills. (W3-DLA-P2-03)
6. Differentiate `hand_discipline_buckets_borderline` from `_strong`; deepen
   weak-ace-specific content; normalize reused subtitles. (P3 cluster)

All are bounded, high-EV, low-risk, and best solved before closure.

---

## 9. Human QA Questions

1. Do W1's 70 tasks (esp. the 14-task rankings lesson) feel like learning or
   grind for an absolute beginner?
2. At runtime, does a W2 bucket miss create ANY repair/recheck, and if so does
   it route to a sensible target (not a W1 private-cards or W3 position drill)?
3. Does the incongruent feedback praise noticeably erode trust in a live run?
4. Do learners read W3's opening lesson as "recognize the six seats" or as
   blinds/order revision?
5. Does `same_hand_different_seat` produce seat transfer or frame recall?
6. Is the repeated J8o-BTN-vs-CO fold spot perceived as reinforcement or
   repetition?

---

## 10. Provisional Status Summary

| World | Provisional score | Status |
| --- | --- | --- |
| W1 Poker from Zero | 7.5 / 10 | `CANONICAL_REPAIR_REQUIRED` |
| W2 Hand Discipline | 6.0 / 10 | `CANONICAL_REPAIR_REQUIRED` |
| W3 Position Thinking | 7.0 / 10 | `CANONICAL_REPAIR_REQUIRED` |

No world reaches `SOURCE_READY_FOR_HUMAN_QA` yet because each has confirmed,
bounded canonical repairs to make first. None is `MAJOR_REWORK_REQUIRED` or
`BLOCKED_BY_EVIDENCE`: structures, routing, and payoff are sound.

---

## 11. Explicitly Excluded Noncanonical Evidence

- JSON Session Drills (Flow B / legacy), including any
  `showdown_winner_choice_v1` drill kind — `NONCANONICAL_DO_NOT_SCORE`.
- Hardcoded campaign packs (Flow A / debug spine) — `NONCANONICAL_DO_NOT_SCORE`
  (support/regression only).
- Archived runners (`lib/archive/...`) — excluded.
- Generic module completion — excluded (does not own Act0 progression).
- Audit Hub content counts — excluded.
- Optional/debug flows (e.g. `w1.s11` session-drill work, debug seed helpers in
  `act0_shell_preview_screen_v1.dart:2255-2440`) — `HISTORICAL_ONLY` /
  debug-only.
- Prior audit artifacts (e.g.
  `canonical_act0_w1_showdown_learning_truth_v1.md`) — `ADMISSIBLE_SUPPORTING_
  ONLY` after live-source reconciliation; live Act0 source wins conflicts.
- Prior Flow-B finding `W1W6-DLR-001` — CLOSED/MISSCOPED, not reopened.

Sibling source lists that are NOT the canonical W2/W3 route and were used only
to resolve `_lessonFromTasksV1` reuse (`_handValuePositionLessons:2245`,
`_preflopBasicsLessons:2574`, `_preflopFrameworkLessons:3518`) were inspected as
the origin of reused tasks but are not scored as separate curricula.
