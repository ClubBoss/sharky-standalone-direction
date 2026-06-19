# World 3 Position Micro-Rep Backlog v1

Status: spec-only backlog
Scope: World 3 position repair micro-reps only

## 1. Purpose

This backlog defines the exact future repair micro-reps needed before Sharky expands World 3 position repair mapping.

The product goal is deterministic repair:

`position mistake -> exact missed table signal -> exact repair micro-rep -> Repaired proof`

This document must not be treated as implementation approval. Future waves still need separate admission, tests, and bounded mapping changes.

## 2. Current Accepted Repair Mapping

The accepted mapped target is:

`world_3 / position_checkpoint / position_checkpoint_position_checkpoint_table_notice`

Its teaching job is narrow:

- Hero is CO.
- BTN, SB, and BB still act after Hero.
- Cutoff is late but not last.
- The learner should count players behind before treating the seat as comfortable.

Current same-signal receipt metadata uses:

- `skillAtomId`: `table_position_read`
- `nextRepId`: `repeat_table_position_read`
- `sourceSignalId`: `hero_button`

Current repair mapping support uses `_Act0RepairTargetV1` and an allowlist in the Act0 preview shell. It should remain allowlisted, not generic.

## 3. Why The Current Target Cannot Cover All Position Mistakes

The current target is a CO players-behind transfer rep. It is exact only when the missed signal is about late position not being a free pass because seats still act behind Hero.

It is not exact for these mistakes:

- Seat label confusion, such as BTN vs CO or UTG vs HJ.
- Basic early/late classification, such as "which seat is early?"
- BTN acting last postflop as a standalone concept.
- UTG pressure from five players behind.
- Same hand changing value across different seats.

Mapping those to the current target would create a fake repair route. The learner would tap Fix for one missed signal and receive a related but different lesson.

## 4. Missing Micro-Rep Backlog Table

| family_id | learner mistake | example sourceTaskId(s), if found | missed signal | required future target job | suggested target id pattern | mapping eligibility once target exists | priority | implementation risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `seat_id_repair` | Confuses seat labels or taps the wrong named seat. | `button_advantage_find_button`, `position_six_seats_positions_button`, `position_six_seats_positions_utg`, `position_six_seats_positions_cutoff` | Exact named seat on the table: BTN, UTG, CO, HJ, SB, or BB. | Table-tap rep that asks for one named seat and highlights only the correct seat after feedback. | `position_repair_seat_id_<seat>` | Map only when wrong option is another seat label and the target asks for the same correct seat. | P1 | Low. Existing seat-tap runners and seat highlights already exist. |
| `basic_early_late_order_repair` | Cannot classify early vs late seats or seat order. | `position_six_seats_positions_late_seat`, `position_six_seats_positions_early_late`, `position_six_seats_seat_order_decision` | Early seats act sooner; late seats act later and see more first. | Table-first rep comparing two visible seats, not action choice. | `position_repair_early_late_order` | Map only when the missed signal is early-vs-late classification, not hand action. | P1 | Low-medium. Needs exact contrast copy but no new system. |
| `btn_last_postflop_repair` | Misses that BTN is the clearest late seat and often acts last postflop. | `button_advantage_button_last`, `button_advantage_find_button`, `position_six_seats_positions_late_seat` | BTN / Button acts last postflop. | Table-tap or answer-list rep where BTN is visibly last after flop. | `position_repair_btn_last_postflop` | Map only when the correct answer is BTN-last, not generic "late helps." | P1 | Low. Existing table state can show BTN and postflop framing. |
| `utg_pressure_repair` | Misses that UTG / early seats face many players behind. | `early_vs_late_early_pressure_choice`, `position_checkpoint_position_checkpoint_early_fold`, `position_apply_early_fold` | UTG acts with many players still behind. | Table-first rep that counts players behind UTG before choosing discipline. | `position_repair_utg_players_behind` | Map only when feedback says early/UTG pressure, five behind, or too exposed. | P1/P2 | Medium. Must avoid becoming a chart/open-range lesson. |
| `hand_strength_plus_position_repair` | Treats the same hand as equal across seats. | `same_hand_different_seat_same_hand_early_fold`, `same_hand_different_seat_same_hand_late_open`, `position_apply_late_open`, `position_apply_hj_fold`, `position_apply_btn_open` | Hand comfort changes when Hero seat changes. | Two-frame table rep using the same or similar hand across early vs late seat. | `position_repair_same_hand_seat_shift` | Map only when the missed signal is "same hand, different seat", not pure hand strength or pure action rhythm. | P2 | Medium-high. Needs careful copy to avoid charts, solver language, or broad strategy. |

## 5. Exact Target Specs Per Missing Family

### `seat_id_repair`

Target job:

- Show one six-max table.
- Ask the learner to identify one named seat.
- Use table tap if available.
- Feedback names the correct visible seat.
- No action decision, no hand-strength content.

Required metadata:

- `skillAtomId`: `table_position_read`
- `sourceSignalId`: seat-specific, for example `seat_btn`, `seat_utg`, `seat_co`
- `repairFocusSeatIds`: the correct seat plus the selected wrong seat when useful
- User-facing signal label: `Button seat`, `UTG seat`, `Cutoff seat`, etc.

Suggested target ids:

- `position_repair_seat_id_btn`
- `position_repair_seat_id_utg`
- `position_repair_seat_id_co`

### `basic_early_late_order_repair`

Target job:

- Compare one early seat and one late seat on the same table.
- Ask which seat acts earlier or which seat has more information.
- Teach ordering, not a hand action.

Required metadata:

- `skillAtomId`: `table_position_read`
- `sourceSignalId`: `early_late_order`
- `repairFocusSeatIds`: early seat and late seat
- Signal label: `Early vs late seats`

Suggested target id:

- `position_repair_early_late_order`

### `btn_last_postflop_repair`

Target job:

- Show a postflop or postflop-framed table.
- Make BTN visibly the last actor among active seats.
- Ask which seat acts latest after the flop.

Required metadata:

- `skillAtomId`: `table_position_read`
- `sourceSignalId`: `btn_last_postflop`
- `repairFocusSeatIds`: `btn`
- Signal label: `Button acts last postflop`

Suggested target id:

- `position_repair_btn_last_postflop`

### `utg_pressure_repair`

Target job:

- Show Hero or target seat at UTG.
- Make remaining players behind visible.
- Ask why early position needs discipline.
- Correct answer should be about players behind / less information, not chart rules.

Required metadata:

- `skillAtomId`: `table_position_read`
- `sourceSignalId`: `utg_players_behind`
- `repairFocusSeatIds`: `utg`, plus later seats if the table highlight supports it
- Signal label: `UTG has players behind`

Suggested target id:

- `position_repair_utg_players_behind`

### `hand_strength_plus_position_repair`

Target job:

- Use one close hand family across two seats, or two adjacent hands with identical seat contrast.
- Ask why the seat changes comfort.
- Keep it beginner-safe: no charts, ranges, solver, GTO, or optimal-frequency language.

Required metadata:

- `skillAtomId`: `table_position_read`
- `sourceSignalId`: `same_hand_seat_shift`
- `repairFocusSeatIds`: early and late seats used in the contrast
- `repairFocusCardIds`: Hero cards
- Signal label: `Same hand, different seat`

Suggested target id:

- `position_repair_same_hand_seat_shift`

## 6. Future Mapping Eligibility Rules

Map a World 3 source to a future target only when all conditions are true:

1. The source mistake and target teach the same missed signal.
2. The target is an existing drill task.
3. The target is not the same source task.
4. The target has compact feedback and a visible table signal.
5. The mapping is an explicit allowlist entry.
6. The mapping has a focused test for Fix launch, repaired proof, and telemetry.

Do not map when:

- The target is merely related to position.
- The source is mainly hand strength, price, board texture, or action rhythm.
- The proposed target would need new lesson family structure.
- The proposed target would become a catch-all position repair.

## 7. Recommended Implementation Order

1. `seat_id_repair`
   - Reason: first-user blocking and table literacy foundational.
   - Start with BTN and UTG before expanding to all six seats.

2. `btn_last_postflop_repair`
   - Reason: existing content depends on the Button as the clearest late seat.
   - Small target, high clarity.

3. `utg_pressure_repair`
   - Reason: important for early-seat discipline, but must avoid chart-like framing.

4. `basic_early_late_order_repair`
   - Reason: useful if source data shows repeated early/late confusion.
   - Can follow seat-ID and BTN-last once table literacy is stable.

5. `hand_strength_plus_position_repair`
   - Reason: highest product value but needs the most careful content scaffolding.
   - Defer until simpler position repair targets are proven.

## 8. Stop / Defer Rules

Stop a future implementation wave if:

- It creates a generic resolver.
- It maps more than one missed signal to a single target.
- It requires a new lesson family.
- It rewrites World 3 broadly.
- It touches Review/Home UI or table geometry.
- It introduces solver, GTO, optimal, or chart memorization framing.

Defer any source where the exact missed signal cannot be identified from existing task metadata and feedback.

## 9. Direction Score And Runout Comparison

Current direction score: 8 / 10.

What is strong:

- Sharky now has deterministic repair proof.
- Existing table-position repair has a precise mapped target.
- The repair strategy is correctly resisting a fake catch-all target.

What is still missing:

- World 3 lacks exact repair targets for several distinct position-signal families.
- Current coverage is strongest for CO players-behind transfer, not all position literacy.

Runout comparison, based only on proven current results:

- Sharky is stronger where it can show deterministic mistake-to-repair proof.
- Runout remains a packaging benchmark from prior accepted audits, but this wave does not use new Runout evidence.
- The next competitive gain comes from exact table-first repair breadth, not from copying Runout layout or wording.

