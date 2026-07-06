# Canonical World Identity Lock v1

Status: `canonical_world_identity_locked`

Branch: `codex/act0-preview-decomposition-world-identity-lock-v1`

Base HEAD: `5d3f77880cc8d55c8252bf2882fd9fd16242b17c`

## Decision

Dual active World models were confirmed in active search paths.

Selected canonical model:

- W1 = Poker from Zero
- W2 = Hand Discipline
- W3 = Position Thinking
- W4 = Bet Purpose / Price
- W5 = Board Awareness
- W6 = Range Thinking
- W7 = Visible Cards Change Ranges
- W8 = Stack Depth And Risk
- W9 = Tournament Pressure
- W10 = Player Adjustment
- W11 = Real Play Transfer
- W12 = Mindset Bridge

The selected model matches the current Act0 runtime route, current
`MASTER_PLAN_v3.0.md` route order, and the W4-W6 runtime title normalization
record. It also preserves teach-before-test ordering: W4 owns bet purpose and
price before W5 board texture and W6 range thinking.

Competing retired model:

- W4 = Preflop Framework
- W5 = Bet Purpose + Price
- W6 = Board Awareness
- W7 = Range Thinking

That model is now treated as retired alias/provenance only, not active routing
truth.

## SSOT Owner

`lib/canonical/canonical_truth_map_v1.dart` is the canonical metadata owner.
It now exposes `canonicalTruthWorldIdentityEntriesV1()` with:

- world ID;
- learner-facing meaning;
- skill family;
- active session range;
- runtime owner;
- registry owner;
- telemetry ID;
- retired aliases/meanings.

The W12 terminal pack `volume_i_terminal_review_v1` is explicitly owned by W12
instead of relying on `worldN_` prefix inference.

## Canonical Table

| World | Canonical learner meaning | Skills | Active sessions | Runtime owner | Registry owner | Telemetry ID | Retired meaning/alias |
| --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | Poker from Zero | table_rules_and_first_action | world1 campaign modules | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/world1_canonical_module_order_v1.dart` | `world_1` | Table Basics |
| W2 | Hand Discipline | starting_hand_discipline | `w2.s01-w2.s14` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_2` | Hand buckets bridge |
| W3 | Position Thinking | position_and_preflop_frame_bridge | `w3.s01-w3.s14` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_3` | Preflop Framework as W4-owned route |
| W4 | Bet Purpose / Price | bet_purpose_price | `w4.s01-w4.s10` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_4` | Preflop Framework |
| W5 | Board Awareness | board_texture_draws_and_street_changes | `w5.s01-w5.s10` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_5` | Bet Purpose + Price; Bet Purpose And Price |
| W6 | Range Thinking | range_buckets_and_board_fit | `w6.s01-w6.s10` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_6` | Board Awareness; Board and Draws |
| W7 | Visible Cards Change Ranges | visible_card_range_narrowing | `w7.s01-w7.s10` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_7` | Range Thinking Lite |
| W8 | Stack Depth And Risk | stack_depth_and_risk_control | `w8.s01-w8.s10` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_8` | Draws as W8 primary route |
| W9 | Tournament Pressure | tournament_pressure_and_risk_premium | `w9.s01-w9.s10` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_9` | Price and Pot Odds as W9 primary route |
| W10 | Player Adjustment | player_type_adjustment | `cash.s01-cash.s10`, `tournament.s01-tournament.s10`, `mixed.s01-mixed.s10` | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/canonical/canonical_truth_map_v1.dart` | `world_10` | Bet Purpose transfer taxonomy as W10 route |
| W11 | Real Play Transfer | real_play_transfer_and_capstone | source-owned W11 route packet | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/campaign/w11_route_admission_contract_v1.dart` | `world_11` | Board Texture as W11 primary route |
| W12 | Mindset Bridge | process_mindset_and_tilt_reset | source-owned W12 route packet plus Volume I terminal review | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` | `lib/campaign/w12_route_admission_contract_v1.dart` | `world_12` | Review Decision as W12 primary route |

## Migration

Updated active docs in the launch/readiness search path:

- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md`

Updated active guards:

- `test/guards/canonical_truth_map_v1_contract_test.dart`
- `test/guards/world_campaign_map_home_contract_test.dart`
- `test/guards/world_campaign_routing_matrix_contract_test.dart`

## Anti-Drift Guard

`test/guards/canonical_truth_map_v1_contract_test.dart` now fails if:

- learner-facing World identity is missing or duplicated;
- Act0 runtime titles diverge from canonical identity;
- active session IDs are assigned to two Worlds;
- `volume_i_terminal_review_v1` loses its W12 owner;
- retired W4-W6 aliases reappear in active launch/calibration docs.

## Wave 4 Effect

The World identity ambiguity is closed. Wave 4 remains not started in this
artifact; this lock only restores a trustworthy admission baseline.
