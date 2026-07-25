---
status: "docs-only canonical deep-learning audit. No product, content, test,"
status_source: "derived"
doc_date: "2026-07-08"
baseline: "f5a64718bccf"
generated_by: "docs_frontmatter_v1"
---

# W4-W6 Canonical Deep Learning Audit v1

Date: 2026-07-08

Branch: `claude/w4-w6-canonical-deep-learning-audit-v1`

Base HEAD (integrated main): `f5a64718bccf87e67fc7e1d9bb74df6187814af3`

Status: docs-only canonical deep-learning audit. No product, content, test,
tooling, Modern Table, legacy-flow, or repair changes were made.

Final verdict:

`w4_w6_canonical_learning_ready_for_bounded_repairs`

## 0. Method and Evidence Scope

Orientation used the canonical ownership map
(`docs/_reviews/w1_w6_canonical_ownership_map_v1.md`), the integrated W1-W3 audit
(`docs/_reviews/w1_w3_canonical_deep_learning_audit_v1.md`, upstream canonical
evidence only — W1-W3 scores were NOT re-audited or revised), and graphify before
reading live Act0 source.

Scoring uses ONLY canonical Act0 evidence:

- `_act0PreviewWorlds` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:6026`)
- `_betPurposePriceLessons` (W4, `act0_shell_state_v1.dart:3605`)
- `_boardDrawsLessons` (W5, `act0_shell_state_v1.dart:3975`)
- `_rangeThinkingFoundationLessons` (W6, `act0_shell_state_v1.dart:4699` =
  `_rangeThinkingLiteLessons[0..2]`)
- Act0 task order, progression/completion, feedback, repair/recheck, payoff, as
  owned by `act0_shell_preview_screen_v1.dart` and
  `act0_lesson_runner_shell_v1.dart`.

Runner model (evidence basis for feedback/ambiguity/leakage/repair dimensions):
`Act0RunnerOptionV1` carries `isCorrect`, `quality` (correct/suboptimal/wrong),
`feedbackTitle`, `feedbackReason`, and `repairFocus{SeatIds,CardIds,Labels}`.
Repair intents are created only when `act0FirstValueSkillReceiptForRunnerV1`
(`act0_lesson_runner_shell_v1.dart:4091`) returns a non-null receipt derived by
`_feedbackSignalProofForRunnerV1` (`:3964`) from the selected option's
`repairFocus*` fields or, failing that, from generic table signals. Mapped
(cross-task) repair/reinforcement targets come from
`act0FirstValueSameSignalRepMappingV1` (`act0_shell_preview_screen_v1.dart:57`).

Canonical task surfaces inspected: W4 = 33 tasks (7 lessons), W5 = 34 tasks
(6 lessons), W6 = 18 tasks (3 foundation lessons).

Explicitly excluded from scoring (see section 11): JSON Session Drills (Flow B),
campaign packs (Flow A), archived runners (`lib/archive/...`), generic module
completion, Audit Hub counts, W4/W5 bridge fixtures and historical denial/price
"repair families", noncanonical W5 session content, and — specifically for W6 —
`range_combo_counts` and `range_thinking_checkpoint`
(`_rangeThinkingLiteLessons[3]`, `[4]`), which are NOT in `world_6.lessons`. Live
source shows those two lessons are assigned to `world_7.lessons`
(`_visibleCardRangeContinuationLessons`, `act0_shell_state_v1.dart:4705`,
`:6123`).

---

## 1. W4 - Bet Purpose / Price (lesson-by-lesson)

Source: `_betPurposePriceLessons` (`act0_shell_state_v1.dart:3605-3973`).
World card: title "Bet Purpose / Price", subtitle "Understand why bets happen and
what price asks you to risk." (`:6072-6073`) — world-card identity is CORRECT.

| # | lessonId | tasks | learn->practice->prove | notes |
| --- | --- | --- | --- | --- |
| 1 | `why_bets_happen` | 4 | yes | purpose intro + value/bluff purpose drills + recap |
| 2 | `value_bets` | 4 | yes | value = worse hands call; check-miss counter-drill |
| 3 | `bluff_pressure` | 4 | yes | bluff = fold pressure; bad-bluff (low fold equity) |
| 4 | `protection_and_denial` | 4 | yes | deny free card; protect vs check contrast |
| 5 | `call_price` | 6 | yes | pot/to-call/hand; 2 graded 3-option marginal spots |
| 6 | `small_half_pot` | 5 | yes | one-third / half / pot sizing |
| 7 | `price_checkpoint` | 6 | yes | 2 real-table transfers + proveIt |

Dimension findings:

- Teach-before-ask (3), sequencing (5): STRONG. Every lesson opens with a
  `theory`/`learn` beat (`_world4PurposeIntroRunner:13125`,
  `_world4ValueIntroRunner:13269`, etc.); purpose -> value -> bluff -> protection
  -> price -> sizing -> checkpoint is a clean conceptual ladder.
- Bet purpose vs action memorisation (W4 focus): the purpose lessons are
  genuinely purpose-framed ("name the bet purpose first", `:13152-13154`) and
  value/bluff/protection/denial distinctions are each authored with contrast
  drills. GOOD conceptual frame.
- Acceptable/suboptimal treatment (14): STRONG where authored. `call_price`
  marginal drills mark a raise as `suboptimal` with distinct feedback
  (`_world4CheapPriceMarginalCallRunner:13809`,
  `_world4PriceTableTransferRunner:14131`); `_world4BluffPressureRunner:13415`
  marks check `suboptimal` ("Legal, but betting is sharper");
  `_world4PurposePriceTableTransferRunner:14205` marks a "random size" answer
  `suboptimal`. Close alternatives are NOT uniformly marked fully wrong — this
  answers the W4 focus positively for the price/checkpoint families.
- Call price / equity terminology (W4 focus): price is taught qualitatively
  (pot vs to-call vs hand strength, `_world4PriceIntroRunner:13665-13669`); the
  word "equity" and pot-odds percentages are deliberately NOT used. Appropriate
  for the micro-stakes scope, but it caps depth: the heuristic "small price + a
  pair = call" (`_world4GoodPriceCallRunner:13677`) is taught as a near-rule that
  ignores outs/draws, which slightly lowers assessment validity (10).
- Sizing choices (W4 focus) — WEAK (dim 10/15): `small_half_pot` drills are pure
  arithmetic recognition ("Which size is one-third pot?" -> 2 BB into 6 BB,
  `_world4SmallBetRunner:13954`; `_world4HalfPotRunner:13988`;
  `_world4PotBetRunner:14031`). No drill asks the learner to CHOOSE a size for a
  stated purpose. Sizing is assessed as fraction math, not as purpose-driven
  decision.
- Feedback specificity (13) — DEFECT (P1): the W4 capstone
  `_world4CheckpointRunner` marks the CORRECT option "Purpose and price" with
  `feedbackTitle: 'Discipline: fold early trash.'`
  (`act0_shell_state_v1.dart:14254`) — a recycled W2/W3 discipline string,
  incongruent praise at the world's proof beat. Same class as W1-DLA-P1-01.
- Answer leakage (12) — DLR-005 (P2): purpose/protection captions pre-state the
  classification answer, then ask it: `_world4ValuePurposeRunner` caption "Hero
  has top pair. Worse hands can call." -> "What is the main purpose?" -> Value
  (`:13163-13165`); `_world4BluffPurposeRunner` "The bet tries to win by folds."
  -> "What is the main purpose?" -> Bluff (`:13209-13211`);
  `_world4ProtectionCheckRunner` "Villain gets a free next card." -> "What did
  checking allow?" -> Free card (`:13552-13554`).
- World identity (P3): every W4 runner sets `lessonSubtitle: 'Board Awareness'`
  (`_world4PurposeIntroRunner:13129`, `_world4PriceIntroRunner:13600`) — that is
  W5's identity, shown in the in-lesson runner header. World-card identity is
  correct; the in-lesson subtitle is off by one world.
- Repair (16)/recheck (17) — WEAKEST of the three worlds (P2, DLR-004): W4 has
  ZERO embedded `fixMistakes`/repair task (grep confirms no repair stepKind in
  `:3605-3973`); NO W4 option sets any `repairFocus*`; and
  `act0FirstValueSameSignalRepMappingV1` has NO `world_4` entry (only World 1 x5
  and World 3 x1, `act0_shell_preview_screen_v1.dart:66-142`). A W4 price miss
  produces a generic `pot_to_call`/`price_read` receipt
  (`act0_lesson_runner_shell_v1.dart:4036-4042`, `:4132-4137`) which the mapping
  routes BACKWARD to World 1 `actions_call_drill` (`:98-108`); a W4 transfer miss
  produces `hero_cards_board_pot`/`table_read` -> World 1
  `what_poker_is_table_read_recheck` (`:120-130`). See section 5. The historical
  "denial repair family" is a noncanonical bridge fixture; canonically W4 has no
  denial repair family at all, so the "is ONE denial repair family enough?"
  question resolves to: there is ZERO canonical W4 repair family.
- Payoff (19)/readiness (20): the checkpoint's two real-table transfers
  (`_world4PriceTableTransferRunner:14095`,
  `_world4PurposePriceTableTransferRunner:14170`) are the strongest independent
  assessments, and the checkpoint correct-reason explicitly bridges forward:
  "Next, board texture tells you which bet purpose fits" (`:14256`).

W4 verdict: conceptually strong, correct, well-sequenced betting content with
genuinely graded price decisions, but capped by a P1 incongruent capstone title,
caption leakage, arithmetic-only sizing, and a real repair void.

---

## 2. W5 - Board Awareness (lesson-by-lesson)

Source: `_boardDrawsLessons` (`act0_shell_state_v1.dart:3975-4319`), built via
`_lessonFromTasksV1`. World card: title "Board Awareness" (`:6086`) — CORRECT
identity.

| # | lessonId | tasks | source shape |
| --- | --- | --- | --- |
| 1 | `board_texture_basics` | 4 | dry/wet texture |
| 2 | `connected_boards` | 4 | connected/disconnected |
| 3 | `flush_draws` | 6 | 4 source + 2 transfer extras |
| 4 | `straight_draws` | 6 | 5 source + 1 gutshot-contrast transfer |
| 5 | `outs_improvement` | 7 | 4 source + 3 live-outs transfers |
| 6 | `turn_river_changes` | 8 | source incl. `w5_street_repair` + 2 transfers |

Dimension findings:

- Dry/wet/connected/paired understanding (W5 focus): CONFIRMED taught.
  `_world5DryBoardRunner:14308` (K-7-2 rainbow = dry),
  `_world5WetBoardRunner:14337` (T-9-8 two hearts = wet),
  `_world5ConnectedBoardRunner:14455` (9-8-7 connected vs paired distractor),
  `_world5DisconnectedBoardRunner:14419` (A-K-4 disconnected). Clear contrast.
- Flush/straight draws, gutshot vs open-ended, outs (W5 focus): STRONG and the
  best-authored draw content in the three worlds. `_world5FlushDrawRunner:14539`
  distinguishes flush draw from made flush AND from straight-draw (3-option,
  suboptimal middle); `_world5GutshotDrawRunner:14836` and
  `_world5GutshotContrastTransferRunner:14898` distinguish gutshot from
  open-ended (open-ended marked `suboptimal`, "too many outs claimed",
  `:14922-14926`); `_world5CleanVsRiskyOutTransferRunner:15178` teaches
  safe-out vs board-danger nuance. "Not made yet" discipline is consistent.
- Turn/river changes (W5 focus): CONFIRMED. `_world5TurnHitsRunner:15355`,
  `_world5RiverMissesRunner:15397`, plus real-table
  `_world5TurnTextureShiftTransferRunner:15499` and
  `_world5RiverDrawStoryTransferRunner:15578` ("keep the same draw story across
  streets"). Good street-continuity teaching.
- Does classification transfer into DECISIONS? (W5 focus) — PARTIAL (P3, dim 15):
  nearly every drill asks the learner to CLASSIFY (what texture / what draw / is
  it connected / which out) or to sequence a read ("name outs first, then judge
  the price", `_world5TableOutsFlushTransferRunner:15139`). There is no drill in
  which board texture directly drives an explicit bet-size or bet/check/call
  choice. Learners can name texture and explain why it matters (recaps do ask
  "why"), but the texture->action bridge is asserted, not drilled.
- Acceptable alternatives in close spots (14): STRONG — the flush/straight/outs
  transfers all carry a graded `suboptimal` middle option (e.g.
  `_world5FlushDrawRunner:14573`, `_world5GutshotContrastTransferRunner:14922`,
  `_world5BoardCheckpointRunner:15676`).
- Feedback specificity (13) — DEFECT (P1): `_world5GapBoardRunner` marks the
  CORRECT option "No" with `feedbackTitle: 'Discipline: open strong late.'`
  (`act0_shell_state_v1.dart:14975`) — a recycled W3 position string on a
  straight-texture drill. Same P1 class as W4.
- Answer leakage (12) — DLR-005 (milder than W4): texture hints pre-state the
  answer — `_world5WetBoardRunner` hint "Connected ranks and suit pressure make
  this wet." -> "What texture is this?" -> Wet (`:14340-14341`);
  `_world5DryBoardRunner` caption+hint describe "spread out / few paths" ->
  Dry (`:14311-14313`).
- World identity (P3): every W5 runner sets `lessonSubtitle: 'Range Thinking'`
  (`_world5TextureIntroRunner:14283`) — W6's identity.
- Repair breadth (16, W5 focus) — one embedded repair `w5_street_repair`
  (`_world5StreetRepairRunner:15439`, `fixMistakes`, graded 3-option) beyond the
  dry-board family; but NO W5 option sets `repairFocus*`, and there is NO
  `world_5` entry in the same-signal mapping table (see section 5). W5 board
  misses map backward to World 1 `cards_ranks_suits_board_count` /
  `your_first_hand_turn` via the generic `board_cards`/`board_read` signal
  (`act0_shell_preview_screen_v1.dart:77-97`).
- Payoff (19)/readiness (20): `_world5BoardCheckpointRunner:15652` closes with a
  graded 3-option proveIt and an explicit forward bridge: "Next, you will group
  hands into simple ranges." (`:15668`).

W5 verdict: the strongest-authored draw/texture world, but held below 9 by the
P1 recycled title, classification-not-decision transfer, and the same
repair-mapping gap.

---

## 3. W6 - Range Thinking (three canonical foundation lessons ONLY)

Source: `_rangeThinkingFoundationLessons` (`act0_shell_state_v1.dart:4699`) =
`_rangeThinkingLiteLessons[0..2]`. World card: title "Range Thinking", subtitle
"Group hands into ranges and see who has the advantage." (`:6100-6101`).

| # | lessonId | tasks | notes |
| --- | --- | --- | --- |
| 1 | `range_bucket_basics` | 5 | value/bluff-candidate/missed buckets on dry board |
| 2 | `range_board_fit` | 5 | board texture shifts the bucket |
| 3 | `range_pressure_lines` | 8 | bucket -> action direction + 2 transfers + repair |

Dimension findings:

- Bucket differentiation (W6 focus): the canonical model is THREE buckets —
  value / bluff candidate / missed (`_w6RangeIntroRunner:15827-15837`), NOT
  strong/medium/weak/missed. They are clearly differentiated with contrasting
  examples: K-Q on K-7-2 = value (`_w6ValueDryBoardRunner:15843`), J-T on K-7-2 =
  missed with bluff-candidate marked `suboptimal` (`_w6MissedDryBoardRunner:15887`),
  A-Q on K-7-2 = bluff candidate (`_w6BluffCandidateRunner:16240`).
- Board fit changes range reasoning, not just hand labeling (W6 focus):
  CONFIRMED. `range_board_fit` shows the SAME K-Q that was value on K-7-2 become
  missed on 8-7-6 (`_w6WrongBoardRunner:16021`), while 9-8 flops two-pair value
  on 8-7-6 (`_w6ValueWetBoardRunner:16066`), and a turn brick can slide a bucket
  toward missed (`_w6TurnShiftBucketRunner:16109`). This is genuine board-driven
  range reasoning, not static hand labels.
- Pressure-line tasks teach value/bluff/missed purpose (W6 focus): CONFIRMED.
  `range_pressure_lines` maps value->bet (`_w6ValueRangeActionRunner:16195`,
  check `suboptimal`, fold wrong), bluff-candidate->pressure, and missed->
  check/fold (`_w6MissedHandActionRunner:16286`), then transfers to a real table
  (`_w6TableValueLineTransferRunner:16328`, `_w6TurnPressureShiftTransferRunner:16399`).
- Feedback specificity (13): BEST of the three worlds — the sweep for recycled
  discipline/position strings found NONE in the W6 foundation runners; titles are
  congruent ("Missed: no pair, no draw.", "Legal check, lost value.",
  "Wrong bucket now.").
- Range width / combo counting / polarization / checkpoint mastery (W6 focus):
  ABSENT from the canonical route, but BY DESIGN, not a within-scope gap. Live
  source assigns `range_combo_counts` and `range_thinking_checkpoint` to
  `world_7.lessons` (`_visibleCardRangeContinuationLessons`, `:4705`, `:6123`).
  So combo counting and the cumulative checkpoint are relocated to W7, not
  missing from the curriculum. Their absence from W6 is therefore OUTSIDE
  intended W6 scope.
- Title/subtitle vs delivered content (P3): the world-card subtitle promises
  "see who has the advantage" (range-vs-range advantage), but the three
  foundation lessons only bucket the LEARNER'S OWN hand. No opponent-range,
  range-width, or advantage comparison is drilled. The world literally titled
  "Range Thinking" delivers own-hand bucket-by-board-fit, which overlaps
  heavily with W4 value/bluff and W5 texture. Bounded over-promise.
- Mastery evidence / completion payoff (18, 19) — asymmetry (P3): W4 and W5 each
  end on a dedicated checkpoint lesson; canonical W6 has none (the checkpoint is
  in W7). W6 ends on `range_pressure_lines`, whose recap
  (`_w6PressureLinesRecapRunner:16474`) + two real-table transfers + embedded
  repair act as a de-facto capstone, but there is no cumulative
  bucket+board-fit+pressure proveIt, and the recap carries no explicit forward
  bridge sentence to W7 (unlike W4/W5 checkpoints).
- Repair depth (16, W6 focus): one embedded repair `w6_wet_board_repair`
  (`_w6WetBoardRepairRunner:15759`, `fixMistakes`, graded 3-option) plus exact
  replay; NO W6 option sets `repairFocus*`; NO `world_6` mapping entry, so
  generic-signal mapped repair routes backward to World 1/World 3 (section 5).
  "Exact replay + mapped transfer" adequacy: exact replay works; the in-lesson
  transfers are genuine; but the cross-task mapped repair is backward-only.
- World identity (P3): every W6 runner sets
  `lessonSubtitle: 'Visible Cards Change Ranges'` (`_w6RangeIntroRunner:15826`,
  `_w6WetBoardRepairRunner:15763`) — W7's identity; the runners sit under a source
  comment "W7: Visible Cards Change Ranges — fresh runners" (`:15820`).

W6 verdict: the best-executed authoring of the three (congruent feedback, graded
3-option drills, real board-fit range shifts, real-table transfers, embedded
repair), but scope-capped: 18 tasks of own-hand bucketing under-deliver on the
"Range Thinking / who has the advantage" promise, with combo/width/polarization/
checkpoint intentionally deferred to W7.

---

## 4. Cross-World Seam Findings

Progression/unlock for all four seams is the standard sequential Act0 gate: each
world card is `locked` with `unlockLabel` referencing the prior world
(`_act0PreviewWorlds:6069-6124`), owned by `_progressWorlds`. No campaign pack,
JSON drill, or module completion controls advancement (confirmed via ownership
map section 10, upstream). Handoff quality below.

### W3 -> W4
- Prerequisite handoff: PASS. `world_4` locked until W3 complete
  (`unlockLabel('Position Thinking')`, `:6077`). W4 builds bet/call/fold on W1
  actions and adds value/bluff/protection/price/sizing with clean teach-before-ask.
- Difficulty progression: PASS — recognition (purpose) -> graded price decisions.
- Terminology continuity: PASS; no concept assessed before its teach beat.
- Blur: W4 in-lesson subtitle "Board Awareness" (`:13129`) reads as W5 at entry.

### W4 -> W5
- Prerequisite handoff: PASS. `world_5` locked until W4 complete (`:6091`).
- Forward bridge: STRONG — W4 checkpoint correct-reason says "Next, board texture
  tells you which bet purpose fits" (`:14256`); W5 builds texture atop W4 betting.
- No unnecessary duplication; no concept consumed before mastery.
- Blur: W5 in-lesson subtitle "Range Thinking" (`:14283`).

### W5 -> W6
- Prerequisite handoff: PASS. `world_6` locked until W5 complete (`:6105`).
- Forward bridge: STRONG — W5 board_checkpoint correct-reason says "Next, you
  will group hands into simple ranges." (`:15668`); W6 `range_board_fit` reuses
  W5 dry/wet texture as the mechanism that shifts buckets (`:16021`,`:16066`) —
  the tightest continuity in W4-W6.
- Blur: W6 in-lesson subtitle "Visible Cards Change Ranges" (`:15826`).

### W6 -> next-route boundary (W7)
- `world_7` "Visible Cards Change Ranges" exists, locked, `unlockLabel('Range
  Thinking')` (`:6111-6123`); its lessons are the two excluded W6 lessons plus a
  visible-card-density lesson (`_visibleCardRangeContinuationLessons`, `:4705`).
- Readiness: own-hand bucketing is a reasonable prerequisite for W7's combo
  counting and visible-card range narrowing, so the handoff is structurally
  sound.
- Gap: canonical W6 ends on `range_pressure_lines` with NO explicit forward
  bridge sentence to W7 (the bridging checkpoint runner
  `_world6RangeCheckpointRunner:15705`, which even references stack depth/"World
  8", belongs to the excluded `range_thinking_checkpoint` lesson now in W7). The
  deepest "range thinking" skills (combo counting/width) are deferred and
  re-branded under a different world title — a curriculum-shape note for Human QA,
  not a within-scope W6 defect.

---

## 5. Canonical P2 Revalidation

### `W1W6-DLR-004` — repair breadth for W4-W6

Classification: **PARTIALLY_CONFIRMED** (structural gap CONFIRMED_CANONICAL;
exact runtime surfacing REQUIRES_HUMAN_QA).

Confirmed canonical:
- ZERO `repairFocus*` metadata on ANY W4/W5/W6 runner option (grep of
  `act0_shell_state_v1.dart:13100-17200` returns 0).
- ZERO embedded repair task in W4; exactly one each in W5
  (`w5_street_repair`, `:4306`) and W6 (`w6_wet_board_repair`, `:4498`).
- `act0FirstValueSameSignalRepMappingV1` (`act0_shell_preview_screen_v1.dart:57-143`)
  has NO `world_4`/`world_5`/`world_6` entry — only World 1 (5 families) and
  World 3 (1 family).
- Because W4-W6 misses still carry board/pot/to-call signals, they DO generate a
  receipt, but a GENERIC one: `pot_to_call`->`price_read`,
  `board_cards`->`board_read`, `hero_cards_board_pot`->`table_read`
  (`act0_lesson_runner_shell_v1.dart:4012-4057`, `:4105-4145`). The daily rep
  target first tries the same-signal mapping (`_firstValueMappedDailyRepTargetV1`,
  `act0_shell_preview_screen_v1.dart:6464`) before exact replay
  (`_firstValueReplayDailyRepTargetV1`, `:6488`). The mapping therefore routes:
  a W4 price miss -> World 1 `actions_call_drill` (`:98-108`); a W5 texture miss
  -> World 1 `cards_ranks_suits_board_count` (`:77-97`); a W4/W5/W6 transfer miss
  -> World 1 `what_poker_is_table_read_recheck` (`:120-130`). The launchable
  guard only requires the target task to exist as a `drill`
  (`_sameSignalRepTargetIfLaunchableV1:6543`), which all completed W1 drills
  satisfy. Net: W4-W6 cross-task mapped repair points BACKWARD to World 1/World 3
  rather than to a same-world repair.

Requires Human QA: whether, in a live Review/Home flow, the learner is actually
surfaced the backward World-1/3 mapped target versus exact same-task replay (both
are computed; which wins the visible CTA is runtime).

### `W1W6-DLR-005` — prompt/option leakage for W4-W6

Classification: **CONFIRMED_CANONICAL** (bounded).

Confirmed canonical:
- W4 purpose/protection captions pre-state the classification answer:
  `_world4ValuePurposeRunner:13163`, `_world4BluffPurposeRunner:13209`,
  `_world4ProtectionCheckRunner:13552`.
- W5 texture hints pre-state the answer: `_world5WetBoardRunner:14340`,
  `_world5DryBoardRunner:14311`.
- W6 is largely CLEAN: hints teach the read (e.g. "Top pair with the best
  possible kicker", `_w6ValueDryBoardRunner:15847`) without naming the bucket
  answer; where a bucket is named it is given as context and the ACTION is the
  question (`_w6ValueRangeActionRunner:16198`) — not leakage.

Not universal: the graded price/draw decision drills and all real-table transfers
use neutral prompts and real decisions.

---

## 6. Provisional Scores (canonical content only; no final 9/10 without Human QA)

### W4 - Bet Purpose / Price: provisional 7.0 / 10 — status `CANONICAL_REPAIR_REQUIRED`
- Strongest dimensions: teach-before-ask (3), sequencing (5), purpose framing,
  graded price decisions and suboptimal treatment (14), forward payoff bridge (19).
- Weakest dimensions: repair breadth (16 — zero embedded repair, backward
  mapping), feedback specificity (13 — P1 incongruent capstone title), answer
  leakage (12), sizing assessment validity/transfer (10, 15 — arithmetic only),
  binary-drill validity (10).
- Hard cap: 7.5/10 until the incongruent capstone title, caption leakage, and the
  repair void are addressed.
- Conditions to reach 9/10: fix `_world4CheckpointRunner` title (`:14254`);
  rewrite purpose/protection captions to stop pre-stating the answer; add a
  purpose->size choice drill; add W4 embedded repair and/or `world_4` same-signal
  mapping so misses stop routing to World 1; then Human QA.
- Human QA dependencies: live repair-target surfacing (DLR-004); whether the
  qualitative price heuristic misfires; whether the P1 title erodes trust.

### W5 - Board Awareness: provisional 7.5 / 10 — status `CANONICAL_REPAIR_REQUIRED`
- Strongest dimensions: draw content quality and diversity (7), gutshot/open-ended
  and flush-draw-vs-made distinctions (10), street-change continuity (15),
  graded suboptimal treatment (14), forward payoff bridge (19).
- Weakest dimensions: feedback specificity (13 — P1 incongruent gap-board title),
  classification-to-decision transfer (15), answer leakage in texture hints (12),
  repair mapping (16), world-identity subtitle (P3).
- Hard cap: 8/10 until the P1 title and the texture->decision gap are addressed.
- Conditions to reach 9/10: fix `_world5GapBoardRunner` title (`:14975`); add at
  least one texture->action decision drill; de-leak texture hints; add `world_5`
  same-signal mapping or `repairFocus`; correct the in-lesson subtitle; then
  Human QA.
- Human QA dependencies: whether learners transfer board reads into real bet/
  check/call choices vs staying at labeling; live repair-target surfacing.

### W6 - Range Thinking: provisional 7.5 / 10 — status `CANONICAL_REPAIR_REQUIRED`
- Strongest dimensions: feedback congruence and specificity (13 — cleanest of the
  three), bucket differentiation and board-fit range shifts (10, 15), real-table
  transfers (15), embedded repair (16).
- Weakest dimensions: title/subtitle vs delivered scope (world identity), mastery/
  checkpoint asymmetry (18, 19), repair mapping (16 — backward-only),
  world-identity subtitle (P3), 18-task breadth for a "Range Thinking" world.
- Hard cap: 8/10 given execution quality, but the honest ceiling depends on
  whether own-hand bucketing counts as "Range Thinking" (Human QA).
- Conditions to reach 9/10: reconcile the world-card subtitle with delivered
  scope OR add a bounded range-advantage/checkpoint beat to canonical W6; correct
  the in-lesson subtitle; add `world_6` same-signal mapping or `repairFocus`; then
  Human QA. Do NOT import the excluded W7 combo/checkpoint lessons to inflate the
  score.
- Human QA dependencies: whether learners read 18 own-hand bucket tasks as "Range
  Thinking"; whether the missing checkpoint weakens mastery evidence.

| World | Provisional score | Status |
| --- | --- | --- |
| W4 Bet Purpose / Price | 7.0 / 10 | `CANONICAL_REPAIR_REQUIRED` |
| W5 Board Awareness | 7.5 / 10 | `CANONICAL_REPAIR_REQUIRED` |
| W6 Range Thinking | 7.5 / 10 | `CANONICAL_REPAIR_REQUIRED` |

No world reaches `SOURCE_READY_FOR_HUMAN_QA`: each has confirmed bounded canonical
repairs first (systematic subtitle mis-set + backward repair mapping for all
three; P1 incongruent titles in W4/W5). None is `MAJOR_REWORK_REQUIRED` or
`BLOCKED_BY_EVIDENCE`: structures, routing, sequencing, and payoff are sound.

---

## 7. Admitted Findings (by priority)

P0: 0.

P1 (2):
- W4-DLA-P1-01: incongruent CORRECT-answer `feedbackTitle: 'Discipline: fold
  early trash.'` on the W4 capstone `_world4CheckpointRunner`
  (`act0_shell_state_v1.dart:14254`) — trust failure at the proof beat.
- W5-DLA-P1-02: incongruent CORRECT-answer `feedbackTitle: 'Discipline: open
  strong late.'` on `_world5GapBoardRunner` (`:14975`) — recycled position
  string on a straight-texture drill.

P2 (3):
- ALL-DLA-P2-01 (`W1W6-DLR-004`): W4/W5/W6 carry zero `repairFocus*`, have no
  `world_4/5/6` same-signal mapping entries, and W4 has no embedded repair; misses
  that produce a generic price/board/table signal map BACKWARD to World 1/World 3
  drills (`act0_shell_preview_screen_v1.dart:66-142`).
- ALL-DLA-P2-02 (`W1W6-DLR-005`): caption/hint answer leakage in W4 purpose/
  protection (`:13163`,`:13209`,`:13552`) and W5 texture (`:14340`,`:14311`).
- W4-DLA-P2-03: W4 `small_half_pot` assesses sizing as arithmetic recognition
  only (`:13954`,`:13988`,`:14031`); no purpose->size choice drill exists.

P3 (5):
- ALL-DLA-P3-01: systematic in-lesson `lessonSubtitle` off-by-one — W4 shows
  "Board Awareness" (`:13129`), W5 shows "Range Thinking" (`:14283`), W6 shows
  "Visible Cards Change Ranges" (`:15826`). Each world's in-lesson header carries
  the NEXT world's identity.
- W5-DLA-P3-02: W5 stays classification-heavy; no drill converts a texture/draw
  read into an explicit bet/check/call decision.
- W6-DLA-P3-03: W6 world-card subtitle ("group hands into ranges and see who has
  the advantage", `:6101`) over-promises vs the 3 foundation lessons, which only
  bucket the learner's own hand.
- W6-DLA-P3-04: canonical W6 has no dedicated checkpoint/mastery lesson
  (asymmetric vs W4 `price_checkpoint` and W5 `board_checkpoint`);
  `range_pressure_lines` serves as de-facto capstone.
- ALL-DLA-P3-05: binary 2-option recognition drills (W4 purpose/value/bluff/
  protection; W5 dry/wet, connected/disconnected, turn-hits/misses) lower
  assessment validity relative to the graded 3-option transfers.

P4 (2):
- W6 combo counting / range width / polarization absent from canonical W6 —
  recorded as OUT OF SCOPE (assigned to `world_7.lessons`, `:6123`), NOT a
  within-scope defect; must not be imported to raise the W6 score.
- Board-scenario reuse across W6 lessons (K-7-2, 8-7-6 recur) — reinforcement vs
  repetition preference.

---

## 8. Repair Candidates (docs-only; not implemented)

1. Replace the two incongruent CORRECT `feedbackTitle` strings on
   `_world4CheckpointRunner` (`:14254`) and `_world5GapBoardRunner` (`:14975`)
   with task-matched praise. (W4-DLA-P1-01, W5-DLA-P1-02)
2. Add `world_4/5/6` entries to `act0FirstValueSameSignalRepMappingV1` and/or add
   `repairFocus*` metadata to W4-W6 wrong options so misses map to same-world
   repair targets; add at least one embedded repair drill to W4. (ALL-DLA-P2-01)
3. Rewrite W4 purpose/protection captions and W5 texture hints so they stop
   pre-stating the classification answer. (ALL-DLA-P2-02)
4. Correct the in-lesson `lessonSubtitle` on every W4/W5/W6 runner to its own
   world identity. (ALL-DLA-P3-01)
5. Add a W4 "choose the size for this purpose" decision drill; add at least one
   W5 texture->action decision drill. (W4-DLA-P2-03, W5-DLA-P3-02)
6. Reconcile the W6 world-card subtitle with delivered foundation scope, or add a
   bounded range-advantage/checkpoint capstone to canonical W6. (W6-DLA-P3-03/04)

All are bounded, high-EV, low-risk, and best solved before closure.

---

## 9. Human QA Questions

1. At runtime, does a W4 price / W5 texture / W6 bucket miss surface a backward
   World-1/World-3 rep target (e.g. a W4 price miss -> World 1 `actions_call_drill`),
   or does exact same-task replay win the visible Review/Home CTA? (DLR-004)
2. Does the incongruent capstone praise ("Discipline: fold early trash.") erode
   trust at the W4 proof beat in a live run?
3. Do learners perceive W6's 18-task own-hand bucketing as "Range Thinking", or
   do they expect the opponent-range/advantage reasoning the world card implies?
4. Does W5 board classification transfer into real bet/check/call decisions, or
   do learners stay at labeling?
5. Is W4 sizing (arithmetic recognition) sufficient, or do learners need an
   explicit purpose->size choice?
6. Does W6 without a dedicated checkpoint still produce adequate mastery evidence
   via `range_pressure_lines`?

---

## 10. Provisional Status Summary

All three worlds: `CANONICAL_REPAIR_REQUIRED`. Final verdict:
`w4_w6_canonical_learning_ready_for_bounded_repairs`.

---

## 11. Explicitly Excluded Noncanonical Evidence

- JSON Session Drills (Flow B / legacy) — `NONCANONICAL_DO_NOT_SCORE`.
- Hardcoded campaign packs (Flow A / debug spine) — support/regression only.
- Archived runners (`lib/archive/...`) — excluded.
- Generic module completion — excluded (does not own Act0 progression).
- Audit Hub content counts — excluded.
- W4/W5 bridge fixtures and historical denial/price "repair families" —
  `NONCANONICAL_DO_NOT_SCORE`; canonical W4 has no embedded repair family.
- Noncanonical W5 session content (assets/manifests) — not scored on existence.
- Session-drill receipts / recheck queue for W6 — `NONCANONICAL_DO_NOT_SCORE`.
- W6 `range_combo_counts` and `range_thinking_checkpoint`
  (`_rangeThinkingLiteLessons[3]`, `[4]`) — NOT in `world_6.lessons`; live source
  assigns them to `world_7.lessons` (`:4705`,`:6123`). Not counted for W6.
- W7 `_world6RangeCheckpointRunner` (`:15705`) and W7 visible-card lessons —
  outside the W4-W6 canonical scope.
- Prior W1-W3 audit — `ADMISSIBLE_SUPPORTING_ONLY` upstream evidence; W1-W3 scores
  were not re-audited or revised.
