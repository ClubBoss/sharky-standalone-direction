# World1 Demo Flow v1

- Scope: demo-first, deterministic, no content editing during demo.
- Entry command: `./tools/demo_world1.sh`.

## Screen Order

- Cold start -> Universal Intake Plan.
- START -> Module Summary.
- START THEORY -> Theory screen.
- START PRACTICE -> Practice runner.
- Complete short run -> Session Result.
- BACK TO MAP -> World1 map current node visible.
- Optional: open branch launcher and verify Cash/MTT requirement labels.

## Success Criteria

- Release gate passes at script start.
- START path reaches Session Result without exceptions.
- BACK TO MAP returns to map with current marker visible.
- Share actions are available:
  - Copy Skill Card
  - Copy Duel Code
  - Apply Duel Code in Today Plan

## Feedback Collection

- At Session Result:
  - tap Copy Skill Card
  - tap Copy Duel Code
- Open terminal and run `./tools/demo_world1.sh`.
- Copy the printed FEEDBACK PACKET block.
- Fill FEEDBACK PACKET fields:
  - app_version
  - app_commit
  - date_utc
  - device_model
  - device_os
  - tester_skill_band
  - result_focus_label
  - result_correct_total
  - result_review_due
- Paste:
  - Skill Card into `skill_card`
  - Duel Code into `duel_code`
- Fill one-line answers for:
  - q1_confusion_point
  - q2_fun_moment
  - q3_pressure_feel
  - q4_stakes_clarity
  - q5_next_action_clarity
- Send packet as plain text in one message.

## Telemetry Expectations

- Script prints `TELEMETRY DIGEST (copy/paste)` after feedback packet.
- Digest includes:
  - commit hash
  - UTC timestamp
  - expected campaign events:
    - `campaign_pack_start`
    - `campaign_hand_result`
    - `campaign_pack_end`
    - `campaign_calibration_resolved` (if applicable)
    - `campaign_complete` (once only)
- Deterministic telemetry contract command:
  - `flutter test test/guards/world1_campaign_telemetry_contract_test.dart`

## Failure Triage Hints

- Gate fail before demo start:
  - Run `./tools/release_gate_world1.sh` directly and inspect first failing step.
- Practice path mismatch:
  - Verify keys `table_first_practice_shell` and `table_practice_runner`.
- Map return mismatch:
  - Verify key `world1_state_current` after BACK TO MAP.
- Branch state mismatch:
  - Verify `world1_branch_cash_requirements` and `world1_branch_mtt_requirements`.
