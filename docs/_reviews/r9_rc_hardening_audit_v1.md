# R9 RC Hardening Audit v1

## Scope Summary
R9 P0.1-P0.5 are completed with deterministic contract coverage.
The hardening pass stayed deterministic-only, introduced no new dependencies, and required no schema changes.
Tier0 gates were used as required.

## P0 Coverage
- P0.1 E2E world10 -> chooser -> track s01..s03 -> return
  - Test pointer: `test/ui_v2/session_result_screen_contract_test.dart`
  - Contract: `r9 p0.1 e2e no-dead-end: world10 result -> track route -> s01..s03 chain -> result return path`
- P0.2 Runner truth invariants (pot/currentBet/toCall, board strip presence, badge non-conflation)
  - Test pointer: `test/guards/world1_foundations_microtask_contract_test.dart`
  - Contracts: `world1 preflop action-state truth invariants hold for pot/currentBet/toCall`,
    `world1 spine multi-street progression advances exactly one step per commit`,
    `world1 preflop blinds stay in-hand (sb/bb not OUT)`
- P0.3 Messaging polish (no optimal/solver; why visible; focus hidden)
  - Test pointer: `test/guards/world1_foundations_microtask_contract_test.dart`
  - Contracts: `world1 spine why fallback uses recommended-play wording without solver/optimal`,
    `world1 spine incorrect outcome uses factual copy with visible why`,
    `world1 followup incorrect outcome keeps Expected and Why without Focus`
- P0.4 Performance ordering/budget guard (Details metrics)
  - Test pointer: `test/guards/world1_foundations_microtask_contract_test.dart`
  - Contract: `world1 outcome perf metrics keep deterministic ordering and bounded budget`
- P0.5 Return path after track s03 result
  - Test pointer: `test/ui_v2/session_result_screen_contract_test.dart`
  - Contract: `r9 p0.5: after cash s03 result, back-to-map return path is deterministic`

## Required Gates
- `flutter analyze`
- `./tools/fast_loop_world1_v1.sh`

## Compliance Statement
- Deterministic-only: yes.
- New dependencies: none.
- Schema changes: none.
- Tier0 status: green.
