# R16 Hand Chain Audit v1

## What shipped
- `hand_chain_v1` contract shipped with deterministic chain length `2..4` steps.
- Per-step expected field exclusivity is enforced: exactly one of `expected_action`, `expected_preset_id`, or `range_bucket_v1`.
- Optional acceptable lists are supported for soft-pass behavior with deterministic ordering.
- Chain traversal is deterministic and uses normal session completion flow after the final step.

## Evidence commits
- Contract + tooling + runtime + tests: `227956fab`
- Gold 2-step content slice: `3d4f451a1`
- Gold 3-step content slice + deterministic guard: `949669981`

## Gates and status
- `flutter analyze`: PASS
- `./tools/fast_loop_world1_v1.sh`: PASS
- `dart run tools/validate_world_content_v1.dart`: PASS
- `dart run tools/run_content_qa_r2_v1.dart`: PASS

## No dead ends
- Hand chains complete deterministically and return to the standard session-complete surface.
- No separate chain-only route is introduced; completion stays inside existing drill/session flow.
