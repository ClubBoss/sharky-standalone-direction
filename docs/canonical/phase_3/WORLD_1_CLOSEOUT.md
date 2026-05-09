# World 1 Closeout (SSOT)

## 1) Status
- Status: CLOSED (World 1 launch scope locked)
- Date: 2026-01-23
- Validator: PASS ([PASS] table-first bundle validation)

## 2) Level -> Module Mapping (Launch)
- L1 -> intro_welcome (content/intro_welcome/v1)
- L2 -> intro_game_types (content/intro_game_types/v1)
- L3 -> intro_actions (content/intro_actions/v1)
- L4 -> intro_hand_rankings (content/intro_hand_rankings/v1)
- L5 -> intro_how_to_win (content/intro_how_to_win/v1)
- L6 -> core_rules_and_setup (content/core_rules_and_setup/v1)
- L7 -> tier_1_checkpoint (content/tier_1_checkpoint/v1)

## 3) Final Content Totals (Launch)
- L1 intro_welcome: drills 7, quiz 2
- L2 intro_game_types: drills 5, quiz 4
- L3 intro_actions: drills 6, quiz 2
- L4 intro_hand_rankings: drills 7, quiz 2
- L5 intro_how_to_win: drills 6, quiz 2
- L6 core_rules_and_setup: drills 12, quiz 5 (above target, left as-is)
- L7 tier_1_checkpoint: drills 6, quiz 5 (above target, left as-is)

World 1 totals: drills 49, quiz 22

## 4) Validation
- validate_training_content.dart --ci: PASS ([PASS] table-first bundle validation)
- Validated module paths:
  - content/intro_welcome/v1
  - content/intro_game_types/v1
  - content/intro_actions/v1
  - content/intro_hand_rankings/v1
  - content/intro_how_to_win/v1
  - content/core_rules_and_setup/v1
  - content/tier_1_checkpoint/v1

## 5) Deferred Post-Launch (Already Declared Only)
- intro_game_flow: deferred post-launch to keep 1 level == 1 module and avoid cross-module progression ambiguity.
- No additional deferrals introduced in closeout.

## 6) Guardrails (Carry Forward)
- No level split across multiple modules at launch (unless SSOT explicitly says so).
- Future changes must keep validator PASS.
