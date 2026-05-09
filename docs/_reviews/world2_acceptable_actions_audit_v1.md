# World2 acceptable_actions Audit v1

Date: 2026-03-05
Scope: World2 MS4-MS9 + Crucibles C1-C3, action_choice drills only
Policy lens: canonical practice quality (reasonable second-best, not over-permissive)

## 1) Summary counts

- drills scanned: 53
- drills with acceptable_actions: 53
- expected/acceptable shape:
  - call -> call/fold: 22
  - raise -> raise/call: 24
  - fold -> fold: 7

Estimated too-permissive risk by spot type:
- call -> fold (22 total)
  - priced pressure / facing bet-open / defend spots: 5 (generally reasonable)
  - control-checkback-showdown-thin boundary spots: 17 (often over-permissive; fold can be nonsense when no facing bet)
- raise -> call (24 total)
  - value-denial clear intent spots: 13 (moderate over-permissive risk)
  - bluff-pressure-isolation counter spots: 11 (mixed risk; some acceptable, some too passive)

Estimated too-permissive total: 29/53
- P0-like: 17 (mostly call->fold in passive/checkback spots)
- P1-like: 12 (raise->call where intent is explicitly value/pressure branch)

## 2) Top issues table (max 25)

| severity | file_path | drill_id | expected | acceptable_actions | why_v1 excerpt | issue | suggested fix |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P0 | content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_call_flop_checkback.json | choose_call_flop_checkback | call | call/fold | Thin-value boundary spots default to checkback here. | Fold is likely not a meaningful second-best in a checkback framing. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_call_flop_showdown.json | choose_call_flop_showdown | call | call/fold | Showdown-value retention uses checkback in this template. | Passive showdown branch implies checkback, not fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_call_flop_pot_control.json | choose_call_flop_pot_control | call | call/fold | Medium-strength control lines check instead of inflating pot. | Pot-control checkback node is over-permissive with fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s05/drills/d.choose_call_turn_checkback.json | choose_call_turn_checkback | call | call/fold | Marginal turn pressure defaults to checkback in this set. | Checkback control node should not soft-pass fold by default. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s05/drills/d.choose_call_turn_slowdown.json | choose_call_turn_slowdown | call | call/fold | Low-fold-equity turn nodes use checkback control. | Slowdown/checkback intent conflicts with fold as second-best. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s05/drills/d.choose_call_turn_risk_control.json | choose_call_turn_risk_control | call | call/fold | Risk-control nodes require checkback instead of forced aggression. | Explicit checkback intent; fold likely nonsense in this abstraction. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s06/drills/d.choose_call_river_checkback.json | choose_call_river_checkback | call | call/fold | Boundary thin-value nodes check in this mastery-feeder set. | Thin-value checkback node should not soft-pass fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s06/drills/d.choose_call_river_showdown.json | choose_call_river_showdown | call | call/fold | Showdown-value nodes stay in checkback branch here. | Showdown checkback branch is over-permissive with fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_call_river_sequence_showdown.json | choose_call_river_sequence_showdown | call | call/fold | Showdown finish branch checks river in this sequence. | Sequence checkback branch should not reward fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_call_turn_sequence_control.json | choose_call_turn_sequence_control | call | call/fold | Control branch checks turn instead of forcing pressure. | Control branch intent is too permissive with fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/sessions/w2.s09/drills/d.choose_call_bridge_showdown.json | choose_call_bridge_showdown | call | call/fold | Showdown-intent bridge nodes check instead of bluffing. | Showdown-intent check branch should not soft-pass fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/crucibles/c2_check_raise_intent_control/drills/d.choose_call_c2_checkback_control.json | choose_call_c2_checkback_control | call | call/fold | Control nodes keep checkback branch in this set. | Crucible control branch is over-permissive with fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/crucibles/c2_check_raise_intent_control/drills/d.choose_call_c2_showdown_control.json | choose_call_c2_showdown_control | call | call/fold | Showdown-control nodes stay passive in this crucible. | Showdown-control branch should avoid fold soft-pass. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/crucibles/c2_check_raise_intent_control/drills/d.choose_call_c2_turn_control_release.json | choose_call_c2_turn_control_release | call | call/fold | Control-release nodes remain passive when pressure is unsupported. | Passive control intent + fold likely over-permissive. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/crucibles/c3_river_value_bluff_separation/drills/d.choose_call_c3_river_showdown_control.json | choose_call_c3_river_showdown_control | call | call/fold | Showdown-control nodes keep passive branch here. | Passive showdown branch likely should not include fold. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/crucibles/c3_river_value_bluff_separation/drills/d.choose_call_c3_river_thin_boundary.json | choose_call_c3_river_thin_boundary | call | call/fold | Thin boundary nodes check back in this crucible. | Thin boundary checkback intent conflicts with fold alt. | Set acceptable_actions to ["call"]. |
| P0 | content/worlds/world2/v1/crucibles/c3_river_value_bluff_separation/drills/d.choose_call_c3_river_bluff_blocked.json | choose_call_c3_river_bluff_blocked | call | call/fold | Blocked bluff nodes use passive branch in this set. | Passive branch with blocker framing is too permissive with fold. | Set acceptable_actions to ["call"]. |
| P1 | content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_value.json | choose_raise_flop_value | raise | raise/call | Strong value and initiative map to the bet branch. | Clear value branch may be diluted by call soft-pass. | Consider ["raise"] only. |
| P1 | content/worlds/world2/v1/sessions/w2.s05/drills/d.choose_raise_turn_value.json | choose_raise_turn_value | raise | raise/call | Value turn nodes continue with the bet branch. | Explicit value continuation may be too permissive with call. | Consider ["raise"] only. |
| P1 | content/worlds/world2/v1/sessions/w2.s06/drills/d.choose_raise_river_value.json | choose_raise_river_value | raise | raise/call | Clear value nodes use the bet branch on river. | Clear value river node should likely grade call as worse+fail. | Consider ["raise"] only. |
| P1 | content/worlds/world2/v1/sessions/w2.s06/drills/d.choose_raise_river_thin_value.json | choose_raise_river_thin_value | raise | raise/call | This target supports thin value betting branch. | Thin-value target may still be overly permissive with call. | Consider ["raise"] only in thin-value approved reps. |
| P1 | content/worlds/world2/v1/sessions/w2.s05/drills/d.choose_raise_turn_denial.json | choose_raise_turn_denial | raise | raise/call | Denial nodes on turn continue via the bet branch. | Denial intent can be undermined by passive soft-pass call. | Keep alt only where explicit pot-control is intended. |
| P1 | content/worlds/world2/v1/crucibles/c1_3bet_4bet_discipline/drills/d.choose_raise_c1_4bet_value.json | choose_raise_c1_4bet_value | raise | raise/call | Value 4bet nodes use raise branch in this crucible. | 4bet value crucible likely wants tighter grading than raise/call. | Consider ["raise"] only. |
| P1 | content/worlds/world2/v1/crucibles/c2_check_raise_intent_control/drills/d.choose_raise_c2_check_raise_value.json | choose_raise_c2_check_raise_value | raise | raise/call | Value-intent check-raise nodes use raise branch. | Crucible intent-control is weakened by permissive call alt. | Consider ["raise"] only. |
| P2 | content/worlds/world2/v1/crucibles/c1_3bet_4bet_discipline/drills/d.choose_raise_c1_3bet_ip.json | choose_raise_c1_3bet_ip | raise | raise/call | This pressure node uses the aggressive 3bet branch. | why_v1 is abstract and does not explain why call is worse in one line. | Add a plain line stating why passive line loses value. |
| P2 | content/worlds/world2/v1/sessions/w2.s08/drills/d.choose_raise_flop_sequence_start.json | choose_raise_flop_sequence_start | raise | raise/call | This sequence start uses the aggressive branch. | why_v1 wording is generic; weak reinforcement for soft-pass cases. | Tighten to factual one-line consequence. |

## 3) Recommended corrective plan

### Batch 1 (P0)
- Remove fold alt from passive-control/checkback/showdown/thin-boundary call drills.
- Priority set: 17 drills listed above.
- Rule: when the node language is "checkback/control/showdown/passive", use acceptable_actions = ["call"].

### Batch 2 (P1)
- Tighten raise->call permissiveness in explicit value/denial intent drills.
- Start with value-clear/value-intent/4bet-value/check-raise-value nodes.
- Rule: if prompt+why_v1 says clear value or strict intent control, use acceptable_actions = ["raise"] unless curriculum explicitly allows passive line.

### Batch 3 (optional)
- Per-crucible exceptions:
  - C1/C2/C3 can be stricter than sessions to preserve mastery intent.
- Keep broader permissiveness in MS sessions only where branch training explicitly accepts a passive fallback.

## Notes
- No content files were edited in this audit task.
- This report is intentionally conservative: it flags likely over-permissive mappings by wording/intent cues, not runtime legality simulation.
