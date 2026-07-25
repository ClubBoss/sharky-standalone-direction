---
status: "undeclared"
status_source: "absent"
baseline: "7c498dcbafc3"
generated_by: "docs_frontmatter_v1"
---

# Canonical Act0 W1 Showdown Learning-Truth Audit v1

Agent: Claude (Opus effort tier). Status: docs-only source-evidence audit. No
product code, content, test, or Modern Table change was made.

Base HEAD: `7c498dcbafc3b1bdef1e71541f28af7af7e28d44`
(base commit `7c498dcb "Add W1 showdown route admission gate review"`).

Branch: `claude/canonical-act0-w1-showdown-learning-truth-v1`.

## 0. Why this audit exists

A prior thread admitted a P1 finding `W1W6-DLR-001` claiming that W1 assesses
showdown / hand-ranking / best-5-of-7 / kicker **before teaching them**, and a
follow-up wave then authored a `w1.s11` session against the JSON "Session
Drills" pipeline (Flow B) to "close" it. That finding was **misscoped**: it
was derived from the non-canonical Flow B / legacy inventory, not from the
canonical learner route. This audit reads the actual canonical Act0 source,
proves the real teaching-before-assessment order, corrects the record, and
decides whether any replacement canonical finding is warranted.

The optional `w1.s11` session is **not** counted as closure evidence here, and
its source branch is **not** integrated or referenced as a fix.

## 1. Canonical route (authoritative for this audit)

Canonical learner route:

`AppRoot -> Act0ShellPreviewScreenV1 -> Home/Learn -> Act0 lessons/tasks -> Act0 completion/progress`

Route evidence from source:

- `lib/ui_v2/app_root.dart:544` documents `AppRoot (_EntryGate) -> Act0ShellPreviewScreenV1`; `:619` returns `Act0ShellPreviewScreenV1(...)` as the entry surface.
- W1 world ("Poker from Zero") is the list `_pokerFromZeroLessons`
  (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:1427`), bound as the world's
  `lessons:` at `:198` and `:6039`.

Non-canonical flows (explicitly **excluded** as learning-closure evidence):

- Flow A campaign spine = DEBUG_SUPPORT (debug-only).
- Flow B JSON "Session Drills" = LEGACY_BLOCKED. The `showdown_winner_choice_v1`
  drill "kind" that `W1W6-DLR-001` relied on exists only in:
  - `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
    (archive / legacy), where it is labelled `w2.s01 showdown_winner_choice_v1`;
  - `lib/services/drill_contract_v1.dart` and
    `lib/services/world2_showdown_truth_validator_v1.dart` (the JSON drill
    contract / W2 validator layer);
  - `lib/audit_hub_v1/world_pedagogical_progression_audit_v1.dart` (audit tooling).
  It does **not** appear anywhere in `_pokerFromZeroLessons`. It is a
  **W2-owned, Flow-B** drill kind. `W1W6-DLR-001` treated this W2/legacy JSON
  kind as if it were a W1 canonical assessment, which is the miss-scope.

## 2. Canonical W1 lesson / task sequence (proved from source)

W1 = `_pokerFromZeroLessons`, 9 lessons, in this order
(`act0_shell_state_v1.dart`):

1. `what_poker_is`
2. `what_poker_is_content`
3. `cards_ranks_suits`
4. `your_first_hand`
5. `fold_check_call_raise`
6. `blinds_action_order`
7. `positions`
8. `hand_rankings_table`  (line 1971)
9. `showdown_winning`     (line 2100)

So hand-ranking teaching (lesson 8) precedes showdown teaching (lesson 9), and
both sit at the end of W1 after cards, the first hand, the action menu,
blinds, and positions are already taught.

### 2.1 `hand_rankings_table` task order (line 1982+)

| # | taskId | phase | stepKind | runner | role |
| --- | --- | --- | --- | --- | --- |
| 1 | `hand_rankings_theory` | theory | learn | `_handRankingIntroRunner` | **teaching** (ranking ladder) |
| 2 | `hand_rankings_pair_drill` | drill | practice | `_handRankingsRunner` | recognition |
| 3 | `hand_rankings_two_pair_drill` | drill | practice | `_twoPairRunner` | recognition |
| 4 | `hand_rankings_trips_drill` | drill | practice | `_tripsRankRunner` | recognition |
| 5 | `hand_rankings_straight_drill` | drill | practice | `_straightRankRunner` | recognition |
| 6 | `hand_rankings_flush_drill` | drill | practice | `_flushRankRunner` | recognition |
| 7 | `hand_rankings_full_house_drill` | drill | practice | `_fullHouseRankRunner` | recognition |
| 8 | `hand_rankings_quads_drill` | drill | practice | `_quadsRankRunner` | recognition |
| 9 | `hand_rankings_royal_flush_drill` | drill | practice | `_royalFlushRankRunner` | recognition |
| 10 | `hand_rankings_full_house_vs_flush_drill` | drill | compare | `_fullHouseVsFlushRunner` | comparison |
| 11 | `hand_rankings_quads_vs_full_house_drill` | drill | compare | `_quadsVsFullHouseRunner` | comparison |
| 12 | `hand_rankings_royal_vs_flush_drill` | drill | compare | `_royalFlushVsFlushRunner` | comparison |
| 13 | `hand_rankings_best_five_drill` | drill | practice | `_bestFiveShowdownRunner` | best-5-of-7 |
| 14 | `hand_rankings_review` | review | proveIt | `_rankingRecapRunner` | **independent assessment** |

Recognition drills (2-9) precede all comparison drills (10-12); best-five (13)
and the prove-it recap (14) come last. Teaching (task 1) is the gating first
task.

### 2.2 `showdown_winning` task order (line 2111+)

| # | taskId | phase | stepKind | runner | role |
| --- | --- | --- | --- | --- | --- |
| 1 | `showdown_theory` | theory | learn | `_showdownIntroRunner` | **teaching** (two ways to win) |
| 2 | `showdown_foldout_drill` | drill | practice | `_showdownRunner` | win-by-folds |
| 3 | `showdown_best_hand_drill` | drill | compare | `_showdownBestHandRunner` | best hand at showdown |
| 4 | `showdown_kicker_drill` | drill | compare | `_showdownKickerRunner` | kicker |
| 5 | `showdown_board_plays_drill` | drill | fixMistakes | `_boardPlaysRunner` | board plays / **repair** |
| 6 | `showdown_tie_drill` | drill | compare | `_tiePotRunner` | split pot / tie |
| 7 | `showdown_review` | review | proveIt | `_worldOneCheckpointRunner` | **independent assessment** |

Teaching (task 1) is the gating first task; best-hand, kicker, board-plays,
and tie all follow it.

## 3. Reachability / prerequisite-order proof

All gating is computed at runtime in
`act0_shell_preview_screen_v1.dart`:

- **Lesson order is enforced.** `_progressWorld` / `_progressLesson`
  (`:10118`-`:10209`): a lesson's state is `current` **only** if it is the
  first non-complete lesson in the world; every later lesson is `locked`,
  `isSelectable: false`. A world is `current` only if the previous world is
  complete. So `showdown_winning` cannot become current until
  `hand_rankings_table` is complete, and neither is reachable until the seven
  earlier W1 lessons are complete.
- **Task order is enforced within a lesson.** `_firstIncompleteTask` /
  `_taskAvailable` (`:10547`-`:10569`): a task is available **only** if it is
  already completed/skipped, or it is the first incomplete task. Because the
  theory (`learn`) task is index 0 in both lessons, the learner cannot reach
  any drill or the assessment before the teaching task is the current task.
- **Completion is persisted in canonical Act0 progress.**
  `_completeCurrentTask` (`:10211`) adds the task to `_completedTaskIds`,
  marks the lesson complete in `_completedLessonIds`, and calls
  `_persistProgress` (`:3157`), which writes to `SharedPreferences`
  (`:3157`-`:3182`; restore path `:2745`+). Progress survives across sessions.
- **No first-time teaching bypass exists.** The `skipTeaching` /
  `allowDrillBypass` flags (practice groups / topic packs, `:6739`+) require
  `lesson.isSelectable` (`:6755`), i.e. the lesson is already unlocked through
  the ordered route where the theory task was the gating predecessor. These
  are re-practice affordances for already-taught lessons, not a way to reach
  first-time assessment before teaching.

**Prerequisite-order result: PASS.** On the canonical route a learner is
taught hand ranking and showdown resolution before being asked to apply
either, and cannot skip the teaching to reach the assessment.

## 4. Concept coverage matrix (canonical Act0 evidence)

Classification per concept (taught clearly / demonstrated / guided practice
present / independently assessed / reinforced / missing / insufficient depth /
requires Human QA).

| Concept | Canonical evidence | Classification |
| --- | --- | --- |
| Complete & correct hand-rank order | `_handRankingIntroRunner` teaches the ladder pair -> two pair -> trips -> straight -> flush -> full house -> quads -> straight flush; per-rank drills 2-9; royal-flush drill present | taught clearly + guided practice present + independently assessed |
| Recognition before comparison | recognition drills (2-9) ordered before comparison drills (10-12) | taught clearly + correct progression ordering |
| Showdown meaning | `_showdownIntroRunner` / `_showdownRunner`: "win when everyone folds, or win by best hand at showdown"; reveal vs fold-out | taught clearly |
| Best-five-of-seven | `_bestFiveShowdownRunner`: "best five are A A 7 7 J ... the 4 does not play because only the strongest five cards count" | taught clearly + guided practice present |
| Both hole cards used | `_handRankingsRunner` / two-pair (`A+A`, `7+7`) use both private cards | demonstrated + guided practice present |
| One hole card decisive | `_showdownKickerRunner`: shared pair of aces, Hero K kicker beats CO Q kicker | demonstrated + guided practice present |
| Zero hole cards (board plays) | `_boardPlaysRunner`: both use the same A-K-Q-J-T board straight, private cards do not improve either | demonstrated + guided practice present |
| Board plays | `_boardPlaysRunner` (stepKind fixMistakes) | taught/demonstrated + guided practice present |
| Kicker | `_showdownKickerRunner` | taught clearly + guided practice present |
| Split pot / ties | `_tiePotRunner`: "a tied pot is split between tied players" | taught clearly + guided practice present |
| Beginner-safe language | plain terms throughout ("best five", "ladder", "reveal"); no solver jargon | taught clearly (pacing/clarity = requires Human QA) |
| Guided examples | every runner carries `teachingSteps` with focus card ids/labels and `centerLabel` narration | demonstrated |
| Independent assessment | `ranking_recap` (proveIt) and `world_one_checkpoint` (proveIt) review tasks | independently assessed (one prove-it per lesson) |
| Feedback specificity | option-level `feedbackReason` cites the real cause, e.g. "Seat order decides who acts first, not who wins at showdown"; wrong options carry `betterAnswerLabel` | taught clearly / strong |
| Ambiguity / prompt-option leakage | `preferredLabel` / `betterAnswerLabel` are feedback-normalization fields, not prompt-visible; distractors are plausible same-table options | low leakage; a few generic/templated `feedbackTitle` strings (cosmetic) = requires Human QA |
| Transfer into different card configs | drills span AK pair, 8-9 straight, QcQd broadway, A7o two pair, Qq vs Jd7h, A-K vs A-Q | demonstrated + reinforced (in-route variation; dedicated novel-context transfer is modest) |
| Progression ordering | theory-first; recognition-before-compare; ranks lesson before showdown lesson | correct |
| Repair after an error | `showdown_board_plays_drill` (fixMistakes); wrong-answer feedback with better-answer routing | guided practice present (bounded) |

No concept in the canonical W1 showdown/hand-ranking contract is classified
`missing` or `insufficient depth`.

## 5. Assessment-validity review

- Assessment tasks (`hand_rankings_review`, `showdown_review`) are `proveIt`
  review tasks that come **after** their lesson's teaching and guided drills,
  never before.
- Distractors are plausible in-context (e.g. "First actor", "Hero cards
  only", "Seat name", "BTN wins") and each maps to a specific corrective
  `feedbackReason`. The answer is not leaked by prompt phrasing;
  `preferredLabel`/`betterAnswerLabel` are internal feedback-shaping fields,
  not shown as prompt text.
- **Observation (not a defect):** some `feedbackTitle` strings are
  generic/templated and occasionally topically loose (e.g. the correct-pair
  option in `_handRankingsRunner` carries the title "Process ignores table
  talk."). This is cosmetic copy polish; it does not change correctness,
  ordering, or the taught-before-assessed contract, and it is already inside
  the territory tracked by the existing `W1W6-DLR-005` / `W1W6-LT-014`
  template-residue item. It does **not** warrant a new canonical finding.

**Assessment-validity result: PASS** (with the cosmetic copy observation
routed to the existing template-residue item, and pacing/clarity routed to
Human QA).

## 6. Feedback / transfer / repair-continuity review

- **Feedback:** every canonical option in these two lessons carries a
  correct/incorrect quality plus a specific `feedbackReason`; wrong answers
  name the better answer. **PASS.**
- **Transfer:** the same concepts are exercised across visibly different card
  and board configurations (pairs, straights, broadway board, two-pair,
  kicker aces). In-route transfer is present; a dedicated out-of-route
  novel-context transfer task beyond this variation is modest but not required
  by the contract. **PASS (reinforced).**
- **Repair-continuity:** `showdown_board_plays_drill` is authored as a
  `fixMistakes` step and wrong-answer feedback routes to the better answer;
  this is bounded but present within the lesson. Broader durable
  repair-receipt lifecycle for W1 remains tracked separately under
  `W1W6-DLR-004` (unchanged by this audit). **PASS (bounded).**

## 7. Corrected ledger disposition for `W1W6-DLR-001`

**New disposition: `MISSCOPED_NO_CANONICAL_ASSESSMENT`.**

Rationale: `W1W6-DLR-001` claimed W1 assesses showdown/hand-ranking/best-5/
kicker before teaching them, citing the `showdown_winner_choice_v1` decision
"kind." That kind is a **W2-owned, Flow-B (JSON Session Drills / legacy)**
artifact (Section 1), not a W1 canonical assessment. The canonical W1 Act0
route owns dedicated `hand_rankings_table` and `showdown_winning` lessons whose
teaching tasks are the gating first tasks and provably precede every drill and
every prove-it assessment (Sections 2-3). There is therefore **no canonical
assessed-before-taught event** for these concepts. The premise of the finding
does not exist on the reachable learner route, so the finding is misscoped
rather than "fixed" — and the optional `w1.s11` Flow-B session built against
that misscoped premise is not closure evidence for the canonical route.

Consequences:
- `W1W6-DLR-001` is removed from the active P1 count.
- Its historical text is preserved and annotated (not deleted) in the review
  and the ledger.
- No replacement canonical finding is added: the canonical evidence supports a
  **closed** contract (Sections 4-6). The only residue observed (a few generic
  feedback-title strings) is already inside the existing `W1W6-DLR-005`
  template-residue item and is not re-admitted as a new finding.

## 8. Verdict

`canonical_act0_w1_showdown_learning_contract_closed`

The canonical Act0 W1 route teaches hand ranking (ladder, recognition,
comparison, best-five-of-seven) and showdown resolution (two ways to win, best
hand, kicker, board plays, split pot/tie) with beginner-safe language and
guided examples, gates every drill and every prove-it assessment behind the
teaching task, enforces lesson-order and task-order reachability, and persists
completion in canonical Act0 progress. The assessed-before-taught defect
alleged by `W1W6-DLR-001` does not exist on the canonical route.

## 9. W1 score-impact decision

`W1_SCORE_MAY_IMPROVE_AFTER_HUMAN_QA`

The reconciliation review capped W1 at 7.5 **solely** because "a real beginner
is assessed on showdown/hand-ranking outcomes before W1 teaches them." That
cap rationale is invalidated by this audit: on the canonical route the teaching
provably precedes the assessment. The cap ceiling can therefore rise. This
audit deliberately assigns **no new source-only number** and does not assign
9/10 from source evidence alone; only Human QA (pacing, perceived clarity,
first-time comprehension) can certify a higher W1 score. The score is not
changed here; it is unblocked to improve after Human QA.

## 10. Minimum repair, if needed

None required for the canonical showdown/hand-ranking learning contract. The
optional cosmetic feedback-title polish stays folded into the existing
`W1W6-DLR-005` template-residue scan; do not open a dedicated wave for it.
`W1W6-DLR-002` (W6 repair-recheck route contract) remains the only surviving
active P1 and is untouched by this audit.
