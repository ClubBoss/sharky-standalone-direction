---
status: "undeclared"
status_source: "absent"
doc_date: "2026-07-08"
baseline: "27a862ed2055"
generated_by: "docs_frontmatter_v1"
---

# W7-W9 Deep Content Audit Evidence Packet v1

Date: 2026-07-08

Branch: `codex/w7-w9-deep-content-evidence-packet-v1`

Base HEAD: `27a862ed2055bd62f5bda3ca5aae8ef6faf04b64`

Terminal verdict: `w7_w9_deep_content_evidence_packet_ready`

## 1. Repository And Canonical-Route Proof

Preflight matched the mission contract:

- branch before work: `main`
- expected local HEAD: `27a862ed2055bd62f5bda3ca5aae8ef6faf04b64`
- expected `origin/main`: `27a862ed2055bd62f5bda3ca5aae8ef6faf04b64`
- ahead/behind: `0/0`
- pre-worktree: clean

Accepted route closure source:

- `docs/_reviews/w7_w9_canonical_route_admission_closure_v3.md`
- W7: `canonical_route_admitted_for_deep_content_audit`
- W8: `canonical_route_admitted_with_nonblocking_debt`
- W9: `canonical_route_admitted_for_deep_content_audit`

Canonical identities:

- W7: `Visible Cards Change Ranges`
- W8: `Stack Depth And Risk`
- W9: `Tournament Pressure`

Active source owner:

- W7/W8/W9 lesson and task route: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- W7 generated visible-card specs: `lib/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart`
- W8 hidden repair source specs: `lib/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart`
- W9 hidden repair source specs: `lib/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart`
- repair mapping: `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- completion payoff: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

This packet does not re-audit route ownership. It exposes active learner-facing
content and source-adjacent repair evidence for Claude Sonnet High.

## 2. Scope And Explicit Non-Claims

In scope:

- W7-W9 active learner-facing sequence;
- prompts, option labels, correct answers, feedback cues, context, and source symbols;
- terminology ordering;
- repair/checkpoint/payoff evidence;
- bounded pattern-guessing scan.

Explicit non-claims:

- no content-quality score;
- no Human QA result;
- no route ownership change;
- no poker-answer change;
- no payoff or telemetry change;
- no W10-W12 closure;
- no W13+ activation;
- no visual or Modern Table work.

## 3. W7 Learner Sequence

World promise: `Visible Cards Change Ranges`; learner-facing subtitle: `Use visible cards to narrow what hands can still be there.`

Lesson order:

1. `range_combo_counts` / `Count the combos`
2. `range_thinking_checkpoint` / `Range thinking checkpoint`
3. `range_thinking_lite_combo_density` / `Visible Cards Change Ranges`

Sequence exposed to learner:

- theory/teaching: combo counts explain range density; checkpoint reuses range buckets; visible-card generated lesson states visible cards reduce rank-containing combinations;
- guided example/practice: A-K, pocket pairs, suited/offsuit, board-fit and table combo-weight drills;
- independent/transfer: live-table combo weight, best-five showdown transfer, visible-card cross-rank transfer;
- feedback: mostly explains count/range cue and warns that visible cards change counts but do not prove exact hands;
- repair opportunity: visible-card misses map to different same-signal W7 tasks;
- payoff: W7 payoff says `You learned how visible cards remove combinations and narrow ranges.`;
- next-world transition: W7 previews W8 `Stack Depth And Risk`.

## 4. W8 Learner Sequence

World promise: `Stack Depth And Risk`; learner-facing subtitle: `Effective stack, SPR, and format change how much risk is left.`

Lesson order:

1. `effective_stack_basics` / `Effective stack`
2. `same_hand_different_depth` / `Same hand, different depth`
3. `spr_and_commitment` / `Room or commitment`
4. `format_pressure` / `6-max vs full ring`

Sequence exposed to learner:

- theory/teaching: smaller stack sets maximum risk; depth changes future risk; low/high SPR controls room vs commitment; format changes player-behind pressure;
- guided practice: effective stack 30/100/even stacks, 20/40/100 BB depth changes, SPR 2/4/8, 6-max/full-ring;
- independent/transfer: table effective-stack read, A-J suited at 25/100 BB, top pair at SPR 2/8, format table notice, final stack-depth checkpoint;
- feedback: usually names the relevant cue and contrasts too-shallow, too-deep, or format-irrelevant distractors;
- repair opportunity: hidden W8 stack-depth misses map to launchable W8 route tasks;
- payoff: W8 payoff says `You learned how effective stack depth changes commitment and risk.`;
- next-world transition: W8 previews W9 `Tournament Pressure`.

Nonblocking debt: route task IDs still use historical `w7_` prefixes inside canonical `world_8`.

## 5. W9 Learner Sequence

World promise: `Tournament Pressure`; learner-facing subtitle: `Survival pressure, zones, bubble pressure, then player adjustment.`

Lesson order:

1. `survival_pressure_basics` / `Chips are not life`
2. `m_ratio_zones_lite` / `M-ratio zones`
3. `bubble_risk_premium` / `Bubble risk premium`
4. `tournament_pressure_checkpoint` / `Tournament pressure checkpoint`

Sequence exposed to learner:

- theory/teaching: tournament chips carry survival value; M-ratio is a quick urgency signal; bubble pressure raises risk premium;
- guided practice: cash vs tournament, short stack survival, red/green/yellow zones, medium/big/short-stack bubble adjustments;
- independent/transfer: tournament-vs-cash transfer, yellow-zone table read, bubble table risk transfer, checkpoint table pressure read;
- feedback: explains survival, urgency, risk premium, leverage, and selective pressure rather than total shutdown;
- repair opportunity: hidden W9 tournament-pressure misses map to launchable W9 route tasks;
- payoff: W9 payoff says `You learned how survival pressure, ladder pressure, and risk premium change decisions.`;
- next-world transition: W9 previews W10 `Player Adjustment`.

## 6. W7 Task Matrix

Source: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`; generated visible-card specs from `act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart`.

| # | Lesson | Task ID | Family | Phase/type | Prompt | Correct / acceptable | Other options/actions | Feedback cue | Context | Transfer/repair |
|---:|---|---|---|---|---|---|---|---|---|---|
| 1 | `range_combo_counts` | `w6_combo_counts_intro` | counting | teaching | `Why do combo counts matter?` | More combos means more range weight. | inherited count options in source | combo counts measure range density | hand families before blockers | prerequisite teaching |
| 2 | `range_combo_counts` | `w6_ak_combos` | counting | guided practice | `How many combos does A-K have before blockers?` | `16 combos` | `12 combos`; `6 combos` | 4 suited plus 12 offsuit | A-K can be suited or offsuit | teaches combination count |
| 3 | `range_combo_counts` | `w6_pair_combos` | counting | guided practice | `How many combos does 8-8 have?` | `6 combos` | `12 combos`; `16 combos` | pocket pairs have six combinations | pocket eights | teaches pair count |
| 4 | `range_combo_counts` | `w6_combo_weight_compare` | counting | guided practice | `Which family appears more often in a range?` | `A-K appears more often` | equal; pocket eights | 16 beats 6 | A-K vs pocket eights | guided comparison |
| 5 | `range_combo_counts` | `w6_combo_counts_recap` | review | review | `What do combo counts help you measure?` | range density | no explicit options extracted | some families appear more often | recap | review |
| 6 | `range_thinking_checkpoint` | `range_checkpoint_intro` | range | teaching | `What are range buckets?` | value / bluff candidate / missed buckets | bucket labels | bucket before action | range is group of hands fitting situation | prerequisite recap |
| 7 | `range_thinking_checkpoint` | `range_checkpoint_value` | range | guided practice | `Which range bucket is K-Q on this board?` | `Value` | bluff candidate; missed | top pair/top kicker is value | K-7-2 rainbow, K-Q | guided bucket |
| 8 | `range_thinking_checkpoint` | `range_checkpoint_board_fit` | range | guided practice | `Which range bucket is K-Q on 8-7-6?` | `Missed` | bluff candidate; value | K-Q has no pair/draw | 8-7-6 two-tone | board-fit shift |
| 9 | `range_thinking_checkpoint` | `range_checkpoint_combos` | counting | guided practice | `How many combos does A-K have before blockers?` | `16 combos` | `12 combos`; `6 combos` | 4 suited + 12 offsuit | A-K before blockers | repeated count |
| 10 | `range_thinking_checkpoint` | `w6_suited_offsuit_weight_compare` | counting | guided practice | `Which family appears more often in a range?` | `A-K offsuit` | A-K suited; equal | 12 offsuit beats 4 suited | A-K suited vs offsuit | varied example |
| 11 | `range_thinking_checkpoint` | `w6_pair_vs_suited_weight_compare` | counting | guided practice | `Which family appears more often in a range?` | `Pocket nines` | K-Q suited; equal | 6 pair combos beats 4 suited | pocket nines vs K-Q suited | varied example |
| 12 | `range_thinking_checkpoint` | `w6_checkpoint_table_combo_weight` | transfer | independent/prove | `Which family should you expect more often in a simple opening range before blockers?` | `A-K offsuit` | pocket nines; equal | 12 combos vs 6 in opening range | CO opens 2.5 BB, BTN reads range | live-table transfer |
| 13 | `range_thinking_checkpoint` | `range_checkpoint_pressure` | range | guided practice | `Which range bucket is A-Q here?` | `Bluff candidate` | missed; value | overcards/ace blocker can pressure | K-7-2 rainbow, A-Q | action-line bridge |
| 14 | `range_thinking_checkpoint` | `w6_kicker_showdown_compare` | assessment | guided practice | `Which hand is stronger at showdown?` | `Hero A-K` | Villain K-Q; tie | kicker decides when both have kings | K-7-2-9-4, A-K vs K-Q | best-five context |
| 15 | `range_thinking_checkpoint` | `w6_board_pair_strength_compare` | assessment | guided practice | `Which hand is stronger at showdown?` | `Villain K-8` | Hero A-J; tie | trips beat two pair | J-8-8-2-2, A-J vs K-8 | paired-board context |
| 16 | `range_thinking_checkpoint` | `w6_checkpoint_table_best_five` | transfer | independent/prove | `What is the clean read before the pot is pushed?` | `Split the pot` | hero wins; villain wins | board straight is best five for both | A-K-Q-J-T, A-5 vs K-4 | live-table transfer |
| 17 | `range_thinking_checkpoint` | `range_checkpoint_review` | review | checkpoint/prove | `What carries this read into World 8?` | `Range plus stack depth` | range only; guess line | range plus depth becomes next layer | range recap | next-world bridge |
| 18 | `range_thinking_lite_combo_density` | `visible_ace_combo_reduction_intro` | `w7_combo_density_visible_card_removal` | teaching | `An ace is already visible on A72 rainbow...` | `There are fewer ace-containing combinations left.` | unchanged; must have ace; never has ace | visible ace reduces combos, not exact hand | A72 rainbow | source spec |
| 19 | `range_thinking_lite_combo_density` | `visible_king_combo_reduction_intro` | same | guided practice/repair source | `A king is already visible on K84 rainbow...` | `There are fewer king-containing combinations left.` | unchanged; must have king; never has king | visible king cannot also be private card | K84 rainbow | maps to `paired_board_texture_lite_intro` |
| 20 | `range_thinking_lite_combo_density` | `paired_board_texture_lite_intro` | same | guided practice/repair source | `On 772 rainbow, two sevens are already visible...` | fewer seven hands, trips can still exist | all removed; no count change; always trips | reduces seven hands but does not prove exact hand | 772 rainbow | maps to transfer check |
| 21 | `range_thinking_lite_combo_density` | `visible_card_combo_density_transfer_check` | same | independent transfer/repair source | `Across A72 rainbow and K84 rainbow...` | visible rank reduces matching-rank combos | increases combos; only low cards; exact hand | visible card unavailable to private hands | A72 vs K84 | maps to king intro |
| 22 | `range_thinking_lite_combo_density` | `visible_card_combo_reduction_recap` | review | review | repeats last spec through review phase | visible rank reduces matching-rank combos | inherited from transfer spec | same as transfer feedback | recap | review |

## 7. W8 Task Matrix

Source: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.

| # | Lesson | Task ID | Family | Phase/type | Prompt | Correct / acceptable | Other options/actions | Feedback cue | Context | Transfer/repair |
|---:|---|---|---|---|---|---|---|---|---|---|
| 1 | `effective_stack_basics` | `w7_effective_stack_intro` | stack depth | teaching | `What is the effective stack?` | `30 BB` | `200 BB`; `115 BB` | smaller stack caps risk | smaller stack sets maximum risk | first teaches effective stack |
| 2 | same | `w7_effective_stack_30bb` | stack depth | practice | `What is the effective stack?` | `30 BB` | larger/average stack | smaller stack | Hero 200 BB, Villain 30 BB | guided |
| 3 | same | `w7_effective_stack_100bb` | stack depth | practice | `What is the effective stack?` | `100 BB` | `50 BB`; `200 BB` | equal stacks keep full depth | 100 vs 100 | guided variant |
| 4 | same | `w7_table_effective_notice` | transfer | practice | `What should you notice first before planning?` | `18 BB effective stack` | own 120 BB; total chips | real live-table risk is smaller stack | 120 BB covers 18 BB | table transfer |
| 5 | same | `w7_effective_stack_recap` | review | review | `Why does effective stack matter?` | real risk / room | no full option set extracted | deep leaves room, short simplifies | recap | review |
| 6 | `same_hand_different_depth` | `w7_depth_shift_intro` | stack depth | teaching | `Why does stack depth change the plan?` | short stacks simplify | deep/same distractors | less money behind shortens tree | same hand at 20 vs 100 BB | teaches depth shift |
| 7 | same | `w7_20bb_wider` | stack depth | practice/repair target | `Which depth usually plays this hand more simply and more often?` | `20 BB` | `100 BB`; same | less postflop burden | A-J suited, 20 BB | W8 repair target |
| 8 | same | `w7_100bb_tighter` | stack depth | practice | `What changes when the hand is 100 BB deep?` | more room and more risk | less risk; jam now | deep stacks create future risk | same hand, 100 BB | contrast |
| 9 | same | `w7_40bb_middle` | transfer | practice | `What is the cleaner 40 BB read?` | some room, not carefree deep | shove/fold; like 100 BB | middle depth | same hand, 40 BB | transfer |
| 10 | same | `w7_ajs_btn_25bb_transfer` | transfer | practice | `What is the cleaner stack-depth read here?` | use short-stack read | irrelevant; too fragile | 25 BB simplifies future risk | CO opens, BTN A-J suited, 25 BB | table transfer |
| 11 | same | `w7_ajs_btn_100bb_transfer` | transfer | practice | `What changes when this spot becomes 100 BB deep?` | treat it as deeper | like 25 BB; shove logic | more room and more second-best risk | same spot, 100 BB | table transfer |
| 12 | same | `w7_depth_shift_recap` | review | review | `What changes when stack depth changes?` | hand can widen short/tighten deep | no full option set extracted | risk and commitment change | recap | review |
| 13 | `spr_and_commitment` | `w7_spr_intro` | SPR | teaching | `What does low SPR usually mean?` | one bet can commit | wait/freedom; same as high SPR | little room left | SPR explanation | first teaches SPR |
| 14 | same | `w7_low_spr_commit` | SPR | practice/repair target | `What does low SPR usually tell you?` | one bet can commit | room to float; same as SPR 8 | SPR 2 close to committed | top pair, SPR 2 | W8 repair target |
| 15 | same | `w7_high_spr_room` | SPR | practice/repair target | `What does high SPR usually give you?` | more room to maneuver | immediate commitment | stack remains behind | SPR 8 | W8 repair target |
| 16 | same | `w7_spr4_middle` | SPR | transfer/repair target | `What does SPR 4 usually feel like?` | middle ground | auto commitment; same as SPR 8 | commitment pressure starts | one pair, SPR 4 | W8 repair target |
| 17 | same | `what_poker_is_side_pot_intro` | pot mechanics | practice | `Which statement is true here?` | Hero can win main pot, not side pot | every chip; penalty | main pot and side pot separate | Hero all-in 20 BB, others add 30 BB | inserted support concept |
| 18 | same | `w7_top_pair_spr2_transfer` | transfer | independent/prove | `What does low SPR add to this top-pair spot?` | less room, more commitment pressure | like SPR 8; ignore depth | low-SPR transfer | K-7-2, K-Q, SPR 2 | independent transfer |
| 19 | same | `w7_top_pair_spr8_transfer` | transfer | practice | `What does stack depth add to this top-pair spot?` | more room, more risk | like SPR 2; ignore depth | deeper room creates future risk | K-7-2, K-Q, SPR 8 | transfer |
| 20 | same | `w7_spr_recap` | review | review | `What does SPR help you feel?` | room-heavy vs commitment-heavy | no full option set extracted | low SPR commits, high SPR leaves room | recap | review |
| 21 | `format_pressure` | `w7_format_intro` | format | teaching | `Why does 6-max usually widen ranges?` | fewer players behind | full ring; same | fewer players wake up with premiums | 6-max vs full ring | first teaches format |
| 22 | same | `w7_6max_wider` | format | practice | `Where does this hand usually open wider?` | `6-max` | full ring; same | 6-max widens many opens | A-J offsuit early position | guided |
| 23 | same | `w7_fullring_tighter` | format | practice | `What usually changes in full ring?` | range tightens | widens; only stack depth | more players behind | same hand full ring | guided contrast |
| 24 | same | `w7_format_table_notice` | transfer | practice | `What is the first useful adjustment?` | count players behind and tighten early opens | open as wide; ignore player count | more players behind tightens early pressure | 9-handed live table | transfer |
| 25 | same | `w7_format_recap` | review | review | `Why does format change opening pressure?` | players behind alter pressure | no full option set extracted | fewer widen, more tighten | recap | review |
| 26 | same | `w7_stack_checkpoint` | checkpoint | independent/prove | `What does stack-depth thinking add to range thinking?` | `Range plus stack risk` | range only; chip count only | range tells hands, depth tells risk | W8 final checkpoint | checkpoint and W9 bridge |

## 8. W9 Task Matrix

Source: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.

| # | Lesson | Task ID | Family | Phase/type | Prompt | Correct / acceptable | Other options/actions | Feedback cue | Context | Transfer/repair |
|---:|---|---|---|---|---|---|---|---|---|---|
| 1 | `survival_pressure_basics` | `w9_survival_intro` | survival | teaching | `What makes tournament chips different from cash chips?` | survival pressure matters more | cash logic; avoid all risk | busting ends run | tournament chips | first teaches survival |
| 2 | same | `w9_cash_vs_tournament` | survival | practice | `Which frame should be stronger in a tournament?` | survival pressure matters more | cash logic; avoid all risk | survival changes thin spots | thin all-in edge, 20 BB | guided |
| 3 | same | `w9_short_stack_survival` | survival | practice/repair target | `What is usually the sharper plan?` | reasonable jam/reshove spot | wait premium; open-fold | controlled urgency beats waiting | 9 BB, blinds coming | W9 repair target |
| 4 | same | `w9_survival_stack_tradeoff` | transfer | practice | `Which table should pass more thin stack-off spots?` | tournament table | cash; equal | no reload makes thin stack-offs costly | cash vs tournament | transfer |
| 5 | same | `w9_survival_recap` | review | review | `What is the key survival takeaway?` | controlled urgency | wait perfect; flat-call wide | cleaner risk selection | recap | review |
| 6 | `m_ratio_zones_lite` | `w9_m_ratio_intro` | M-ratio | teaching | `What does M-ratio help you read?` | urgency signal | inherited options are survival-like in extraction | lower zones mean pressure | zone thinking | first teaches M-ratio |
| 7 | same | `w9_m_ratio_red_zone` | M-ratio | practice | `What is the sharper mindset?` | controlled urgency | wait; flat-call | red zone needs timely commitment | red zone | guided |
| 8 | same | `w9_m_ratio_green_zone` | M-ratio | practice | `What usually improves in green zone?` | patience/table selection | force all-ins; avoid pressure | room to pass thin spots | green zone | guided contrast |
| 9 | same | `w9_m_ratio_yellow_zone` | M-ratio | transfer | `What usually becomes sharper in yellow zone?` | prepare action windows | ignore urgency; force any spot | plan before red-zone panic | yellow zone | transfer |
| 10 | same | `w9_m_ratio_table_window_transfer` | transfer | independent/prove | `What is the cleaner first zone adjustment here?` | prepare/folded-to-BTN action window | wait for red; instant panic | yellow-zone table transfer | BTN A-J offsuit, 12 BB | table transfer |
| 11 | same | `w9_m_ratio_recap` | review | review | `What is the M-ratio takeaway?` | lower zone means less freedom | no full option set extracted | quick pressure map | recap | review |
| 12 | `bubble_risk_premium` | `w9_bubble_intro` | risk premium | teaching | `What is risk premium in simple terms?` | extra hand strength before risking life | chip-EV-only; fold all | payout pressure raises bar | near bubble | first teaches risk premium |
| 13 | same | `w9_medium_stack_tighten` | risk premium | practice/repair target | `What is usually the sharper adjustment?` | tighten marginal calls | chip EV calls; fold everything | medium stack protects life | two spots from money | W9 repair target |
| 14 | same | `w9_big_stack_leverage` | leverage | practice | `What usually improves for the big stack?` | selective open pressure | freeze; jam any two | covering stacks pressure others | covers blinds near bubble | guided contrast |
| 15 | same | `w9_bubble_short_stack` | ladder/survival | transfer/repair target | `What usually stays true for the short stack?` | take practical jam spots | fold to money; call off light | short stack cannot fold forever | short stack near bubble | W9 repair target |
| 16 | same | `w9_bubble_table_risk_transfer` | transfer | independent/prove | `What is the cleaner first bubble adjustment here?` | tighten thin stack-offs vs covering blind | chip EV call; over-fold | covering BB creates risk premium | BTN A-J offsuit, BB shoves 18 BB | table transfer |
| 17 | same | `w9_bubble_recap` | review | review | `What is the bubble-pressure takeaway?` | medium defend life, big stack pressures selectively | no full option set extracted | risk premium is context, not fear | recap | review |
| 18 | `tournament_pressure_checkpoint` | `w9_checkpoint_intro` | checkpoint | teaching | same as survival intro | survival pressure matters | cash/avoid all | recap survival | checkpoint intro | recap |
| 19 | same | `w9_checkpoint_survival_line` | checkpoint | practice | `What is the best pressure line?` | disciplined urgency in reasonable spots | any two; wait aces | survival plus timely action | short, one orbit left | checkpoint |
| 20 | same | `w9_checkpoint_zone_line` | checkpoint | practice | `Which player should act sooner?` | red-zone player | green-zone; same | lower M-ratio means urgency | similar hand, different zones | checkpoint |
| 21 | same | `w9_checkpoint_bubble_line` | checkpoint | practice | `What is often the cleaner medium-stack plan?` | tighten defend and avoid thin all-ins | chip EV; fold all | risk premium raises stack-off bar | medium vs big-stack open | checkpoint |
| 22 | same | `w9_checkpoint_table_notice` | transfer | practice/repair target | `What is the clean first pressure read?` | respect bubble pressure | cash; fold everything | name risk premium and leverage | medium stack vs covering big stack | W9 repair target |
| 23 | same | `w9_checkpoint_review` | checkpoint | independent/prove | `What does tournament-pressure thinking add before player adjustment?` | map pressure first, then adjust by player | player only; cards only | bridge to World 10 | final recap | payoff bridge |

## 9. Terminology Ledger

| Term | First appearance | First plain-language explanation | First contextual demonstration | First guided use | First independent assessment | Later reuse | Repair support |
|---|---|---|---|---|---|---|---|
| combination / combo | W7 `w6_combo_counts_intro` | `Ranges are not just hand names. They also have combo counts.` | A-K 16, pair 6 | `w6_ak_combos`, `w6_pair_combos` | `w6_checkpoint_table_combo_weight` | visible-card density | W7 generated repair specs |
| range | W7 `range_checkpoint_intro` | group of hands that fit situation | value/bluff/missed buckets | value/board-fit tasks | checkpoint review and table weight | W8 bridge copy | indirect only |
| blocker | W7 inherited feedback uses `before blockers`; W9 feedback mentions blockers | not fully taught in W7-W9 packet | A-K before blockers | combo tasks | none explicit | W9 panic/urgency feedback mentions blockers | no direct repair target |
| visible card | W7 visible-card lesson | visible cards unavailable to private hands | A72, K84, 772 | king and paired-board tasks | cross-rank transfer | W7 payoff | direct same-signal repair |
| effective stack | W8 `w7_effective_stack_intro` | smaller stack sets maximum risk | 200 vs 30; 100 vs 100 | effective-stack drills | table effective notice | W8 checkpoint | hidden W8 stack-depth repair |
| commitment | W8 `spr_and_commitment` | low SPR means less room; one bet can commit | SPR 2/4/8 | SPR tasks | top pair at SPR 2 | W8 payoff | hidden W8 stack-to-pot repair |
| SPR | W8 `w7_spr_intro` | room left after the flop | SPR 2/8/4 | SPR drills | top pair transfer and checkpoint | W8 payoff | hidden W8 mapping to SPR tasks |
| risk premium | W9 `w9_bubble_intro` | extra strength before risking tournament life | medium stack near bubble | medium-stack tighten | bubble table transfer/checkpoint | W9 payoff | hidden W9 risk-premium repair |
| bubble | W9 `w9_bubble_intro` | near payout pressure | medium/big/short stack bubble tasks | bubble drills | table risk transfer | W9 checkpoint | hidden W9 bubble repair |
| ladder pressure | W9 hidden source `short_stack_ladder_pressure_lite` | survival has extra value on ladder | hidden spec only | hidden spec | hidden transfer source | W9 payoff mentions ladder pressure | hidden source maps to `w9_bubble_short_stack` |
| survival pressure | W9 `w9_survival_intro` | busting ends tournament run | cash vs tournament | short-stack survival | survival tradeoff/checkpoint | W9 payoff | hidden W9 survival repair |

## 10. Teach-Before-Ask Matrix

| Concept | Teaching before assessment | Guided before transfer | Audit risk to check |
|---|---|---|---|
| combo count | yes: W7 combo intro before count drills | yes before live-table combo weight | repeated count format may allow pattern guessing |
| visible-card removal | partial: generated first spec teaches before later specs | yes before transfer check | Claude should judge whether one generated teaching prompt is enough |
| effective stack | yes | yes before table notice | low risk |
| depth shift | yes | yes before 25/100 BB transfer | medium: A-J repeated may overfit |
| SPR/commitment | yes | yes before top-pair transfer | medium: acronym density |
| side pot | appears inside W8 SPR lesson | one support task only | check whether side pot is adequately introduced |
| format pressure | yes | yes before table notice | medium: may assume 6-max/full ring vocabulary |
| survival pressure | yes | yes before cash/tournament transfer | low/medium |
| M-ratio | yes, but formula intentionally omitted | yes before zone transfer | check whether undefined M-ratio is acceptable |
| risk premium/bubble | yes | yes before table transfer | medium: advanced term density |
| ladder pressure | only hidden source/payoff, not normal visible route in W9 matrix | hidden repair source | high: payoff may claim ladder pressure beyond visible route evidence |

## 11. Assessment-Validity Matrix

| World | Assessment evidence | Possible leakage / pattern issue |
|---|---|---|
| W7 | live-table combo weight, best-five showdown, visible-card transfer | many answers are labels with the concept name; correct option often states exact lesson phrase |
| W8 | table effective notice, A-J depth transfer, top-pair SPR transfers, stack checkpoint | repeated short/deep contrast may let learners pick by obvious stack number without reasoning |
| W9 | table zone transfer, bubble table transfer, checkpoint review | distractors are often extremes: `fold everything`, `jam any two`, `treat like cash` |

## 12. Feedback Matrix

| World | Correct feedback quality | Incorrect/suboptimal feedback quality | Audit focus |
|---|---|---|---|
| W7 | usually explains count/range cue | usually says why exact-hand or unchanged-count answer fails | check if feedback teaches visible-card logic deeply enough |
| W8 | names smaller stack, future risk, room/commitment, format pressure | contrasts wrong stack, irrelevant depth, or over-simple shove logic | check whether SPR acronym and side pot are explained enough |
| W9 | explains survival, urgency, leverage, and risk premium | rejects cash-only, panic, and total shutdown lines | check whether feedback overuses extreme distractor correction |

## 13. Transfer And Difficulty Matrix

| World | Progression | Surface-feature changes | Transfer quality question |
|---|---|---|---|
| W7 | counts -> checkpoint -> visible-card reduction | A-K/pair/suited, live table, visible A/K/paired board | Does visible-card lesson rely too heavily on one mechanic? |
| W8 | effective stack -> depth shift -> SPR -> format -> checkpoint | stack sizes, same hand at different depth, real-table top pair, player count | Does W8 test enough independent transfer beyond label recognition? |
| W9 | survival -> M-ratio -> bubble -> checkpoint | cash/tournament, zones, payout pressure, table leverage | Does W9 make M-ratio/risk-premium beginner-safe? |

## 14. Repair And Checkpoint Matrix

| Source task | Repair target | Alignment |
|---|---|---|
| `visible_king_combo_reduction_intro` | `paired_board_texture_lite_intro` | same visible-card combo-density family |
| `paired_board_texture_lite_intro` | `visible_card_combo_density_transfer_check` | same family, transfer target |
| `visible_card_combo_density_transfer_check` | `visible_king_combo_reduction_intro` | same family, different rank |
| `short_stack_all_in_pressure_intro` | `w7_low_spr_commit` | stack-depth pressure to low-SPR commitment |
| `deep_stack_postflop_room_intro` | `w7_high_spr_room` | deeper-stack room to high-SPR room |
| `stack_to_pot_commitment_lite` | `w7_spr4_middle` | stack/pot commitment to middle SPR |
| `all_in_threshold_transfer_check` | `w7_20bb_wider` | shallow stack threshold to short-depth route task |
| `bubble_survival_pressure_intro` | `w9_short_stack_survival` | survival pressure to short-stack survival |
| `risk_premium_medium_stack_intro` | `w9_medium_stack_tighten` | risk premium to medium-stack discipline |
| `short_stack_ladder_pressure_lite` | `w9_bubble_short_stack` | ladder/survival pressure to short-stack bubble urgency |
| `pressure_transfer_check` | `w9_checkpoint_table_notice` | tournament-pressure transfer to real-table pressure read |

Checkpoint tasks:

- W7: `range_checkpoint_review`, `visible_card_combo_reduction_recap`
- W8: `w7_stack_checkpoint`
- W9: `w9_checkpoint_review`

## 15. Completion/Payoff Matrix

| World | Demonstrated evidence before payoff | Payoff claim | Proportion question |
|---|---|---|---|
| W7 | combo counts, range checkpoint, visible-card reduction tasks | `You learned how visible cards remove combinations and narrow ranges.` | Is three visible-card tasks plus inherited combo count enough? |
| W8 | effective stack, depth shift, SPR, format, checkpoint | `You learned how effective stack depth changes commitment and risk.` | Does format/side-pot content dilute stack-depth promise? |
| W9 | survival, zones, bubble, checkpoint | `You learned how survival pressure, ladder pressure, and risk premium change decisions.` | Ladder pressure appears mainly in hidden repair source/payoff; audit this. |

## 16. Bounded Pattern-Guessing Scan

Scan scope: W7-W9 active tasks only.

Quantified structural findings:

- W7 learner-facing route tasks represented: 22.
- W8 learner-facing route tasks represented: 26.
- W9 learner-facing route tasks represented: 23.
- total represented tasks: 71.
- W7 repair-source tasks: 4 plus recap.
- W8 hidden repair-source tasks: 4.
- W9 hidden repair-source tasks: 4.
- W8 historical `w7_` prefixes in canonical W8 route tasks: 25 of 26 W8 tasks; nonblocking route debt already accepted.

Pattern risks for Claude to judge:

- repeated prompt frames: `Which family appears more often`, `What changes`, `What is the cleaner first...`, `What usually...`;
- repeated distractor structures: extreme answers such as `always`, `never`, `fold everything`, `jam any two`, `ignore pressure`;
- answer-label leakage: correct answers often contain the concept label itself, e.g. `Tighten marginal calls`, `Respect bubble pressure`, `Range plus stack risk`;
- repeated correct-option position: bounded extraction suggests many first options are correct, but exact UI order should be checked from source if this becomes a P1/P2 finding;
- checkpoint duplication: W9 checkpoint intentionally reuses survival/M-ratio/bubble concepts; Claude should decide if it is valid synthesis or duplicate recognition.

## 17. Exact Questions Claude Must Answer

1. What are the confirmed P0-P4 learner/content defects?
2. Which findings are evidence-backed versus Human-QA-only?
3. Does each world honestly teach what its promise claims?
4. Is every major term taught and demonstrated before assessment?
5. Does each major concept receive enough examples and independent transfer?
6. Are assessments valid against pattern guessing and answer leakage?
7. Does feedback explain reasoning rather than only correctness?
8. Are repair targets pedagogically aligned?
9. Is difficulty progressive and coherent?
10. Is world completion payoff proportionate to demonstrated competence?
11. Which defects should enter one bounded repair wave?
12. Which findings should be deferred to later worlds or Human QA?
13. Can W7, W8, and W9 be closed after at most one grouped repair wave?

## 18. Evidence Limitations

- This packet is compact and does not dump full source files.
- Some review/recap tasks inherit base runner options or use summary-style feedback; source symbols are provided for exact lookup if a finding depends on option order.
- Pattern-scan option-order findings are bounded and should be treated as audit leads, not final defects, unless confirmed against source or rendered UI.
- No Human QA, screenshot, or visual evidence was collected.
- No W1-W6 or W10-W12 content was inspected beyond W7 active continuation tasks that are directly reused by canonical W7.

## 19. Validation

Passed validation for this artifact wave:

- targeted source/task count checks: W7 `22`, W8 `26`, W9 `23`, terminology `11`, repair mappings `11`, Claude questions `13`;
- `flutter test test/ui_v2/act0_w7_w9_same_signal_repair_recheck_v1_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart test/guards/w7_w10_route_status_alignment_contract_test.dart`: passed, `110` tests;
- `flutter analyze`: passed, no issues found;
- `git diff --check`: passed;
- `graphify hook-check`: passed;
- exact changed-file inspection: only `docs/_reviews/w7_w9_deep_content_audit_evidence_packet_v1.md`.

## 20. Token Efficiency Report

- exact_usage: unavailable.
- selected model: current Codex default.
- why it was sufficient: repository inspection, bounded extraction, docs-only artifact creation, and focused validation did not require escalation.
- escalation occurred: no.
- escalation reason: none.
- estimated_total_tokens: 30000.
- estimate_confidence: medium.
- input-context estimate: 22000.
- reasoning/output estimate: 8000.
- files opened: attachment, context router, mainline memory skill, W7-W9 active source owners, repair mapper, closure artifacts, and targeted tests.
- files read in full: attachment and small skill/context files; large source files were read by bounded slices/searches.
- targeted searches: 9.
- broad searches: 0 beyond bounded `rg` in admitted W7-W9 files.
- Graphify queries: 1.
- commands run before artifact validation: 12.
- tests run before final validation: 0.
- generated lines versus inspected lines: several thousand source lines generated by bounded slices; only W7-W9 task/runner evidence and repair mappings were retained.
- largest token sinks: active source excerpts for W8/W9 task runners and repair mapping search output.
- repeated investigation: one parser attempt was abandoned and replaced with bounded line extraction.
- avoidable token cost: the first generated runner excerpt over-captured adjacent option blocks.
- whether another discovery pass is required: no for Claude audit input; yes only if Claude wants exact rendered option order as a defect proof.
- evidence contracts closed per estimated 10k tokens: about 1.0 artifact contract per 10k tokens, including task inventory, terminology ledger, repair/payoff bridge, and pattern-scan leads.
