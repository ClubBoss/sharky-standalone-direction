# World 2 Truth Family Registry v1

Purpose:

- canonical lightweight index of currently onboarded World 2 truth families
- explicit validator/tool/test entrypoints
- explicit boundary and exclusions
- next candidate family without turning this into a framework
- runtime-anchor lane uses the canonical seam in `docs/plan/world2_runtime_anchor_source_contract_v1.md`
- reusable package-type rules live in `docs/plan/family_packaging_taxonomy_v1.md`
- rollout-closeout rules for proven scenario-driven slices live in `docs/plan/scenario_driven_rollout_contract_v1.md`

## Onboarded Families

| Family | Status | Boundary | Validator | Tool | Targeted test | Exclusions |
| --- | --- | --- | --- | --- | --- | --- |
| `showdown_winner_choice_v1` | bounded / covered | full World 2 `showdown_winner_choice_v1` family | `lib/services/world2_showdown_truth_validator_v1.dart` | `tools/validate_world2_showdown_truth_v1.dart` | `test/tools/world2_showdown_truth_validator_v1_test.dart` | none in current family |
| `outs_count_choice_v1` | bounded / covered | full World 2 `outs_count_choice_v1` family | `lib/services/world2_outs_truth_validator_v1.dart` | `tools/validate_world2_outs_truth_v1.dart` | `test/tools/world2_outs_truth_validator_v1_test.dart` | none in current family |
| `board_texture_classifier_v1` | bounded / covered | full World 2 `board_texture_classifier_v1` family | `lib/services/world2_board_texture_truth_validator_v1.dart` | `tools/validate_world2_board_texture_truth_v1.dart` | `test/tools/world2_board_texture_truth_validator_v1_test.dart` | none in current family |
| `board_tap` | bounded / covered | full World 2 `board_tap` family | `lib/services/world2_board_tap_truth_validator_v1.dart` | `tools/validate_world2_board_tap_truth_v1.dart` | `test/tools/world2_board_tap_truth_validator_v1_test.dart` | none in current family |
| `seat_tap` | bounded / covered | full World 2 `seat_tap` family | `lib/services/world2_seat_tap_truth_validator_v1.dart` | `tools/validate_world2_seat_tap_truth_v1.dart` | `test/tools/world2_seat_tap_truth_validator_v1_test.dart` | none in current family |
| `position_thinking_choice_v1` | bounded / covered | full World 2 `position_thinking_choice_v1` family | `lib/services/world2_position_truth_validator_v1.dart` | `tools/validate_world2_position_truth_v1.dart` | `test/tools/world2_position_truth_validator_v1_test.dart` | none in current family |
| `initiative_aggressor_choice_v1` | bounded / covered | full World 2 `initiative_aggressor_choice_v1` family | `lib/services/world2_initiative_truth_validator_v1.dart` | `tools/validate_world2_initiative_truth_v1.dart` | `test/tools/world2_initiative_truth_validator_v1_test.dart` | none in current family |
| `action_choice` | bounded / covered | full World 2 `action_choice` trainer-policy family | `lib/services/world2_action_choice_policy_validator_v1.dart` | `tools/validate_world2_action_choice_policy_v1.dart` | `test/tools/world2_action_choice_policy_validator_v1_test.dart` | none in current family |
| `hand_chain_v1` | bounded / covered | current World 2 `hand_chain_v1` family with explicit subset boundary: factual reusable chains (`w2_s07_position_then_initiative_v1`, `w2_s08_texture_then_outs_v1`, `w2_s09_position_initiative_texture_v1`), follow-up policy-coupled chains, and capstone composition | `lib/services/world2_hand_chain_mixed_subset_validator_v1.dart` | `tools/validate_world2_hand_chain_mixed_subset_v1.dart` | `test/tools/world2_hand_chain_mixed_subset_validator_v1_test.dart` | none in current family |

## Candidate Families

| Family | Current status | Why not onboarded yet | Next safe move |
| --- | --- | --- | --- |
| `board_texture_classifier_v1` | onboarded | paired, connected, and dry rainbow calmer-board contract shapes now resolve through one bounded validator seam | extend only if a genuinely new board-texture policy shape appears |
| `board_tap` | onboarded | deterministic runtime-anchor truth from explicit symbolic `boardSlot` targets | extend only if a new bounded board anchor shape appears |
| `seat_tap` | onboarded | deterministic runtime-anchor truth from explicit symbolic `role` / `seatId` targets | extend only if a new bounded seat-anchor shape appears |
| `position_thinking_choice_v1` | onboarded | exact-answer truth from seat relationship and question shape | extend only if a new question shape appears |
| `initiative_aggressor_choice_v1` | onboarded | exact initiative questions and authored `pressure_owner` policy nodes now share the same bounded truth seam | extend only if a new initiative question shape appears |
| `action_choice` | onboarded in trainer-policy lane | bounded policy-consistency now comes from authored `expected.actionId` plus tolerated `acceptable_actions` and current `intent_v1` buckets | extend only if future policy families expose an equally canonical seam |
| runtime-anchor lane after `seat_tap` | stop | no remaining World 2 family fits the source-symbolic runtime-anchor contract cleanly | hold lane at `board_tap` + `seat_tap` |
| broader `hand_chain_v1` family | onboarded | all current World 2 hand-chain authored shapes now fit the bounded mixed-subset validator through explicit per-shape support rather than generic chain-engine behavior | only revisit if a new authored chain shape appears that cannot be expressed through the current bounded per-shape pattern |
