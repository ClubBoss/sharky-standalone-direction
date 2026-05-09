# R73 Action-Bar Legality Closeout Audit v1

## Milestone purpose/scope recap
- Purpose: harden the authoritative World1 action-phase action bar so facing-bet states do not show misleading affordances.
- Scope: one bounded legality family on one authoritative seam only.
- Out of scope: action-bar redesign, finish/progression work, highlight-system work, schema/content rewrites.

## Authoritative seam recap (from R72)
- Surface: `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Seam: `_buildCampaignActionChips(_CampaignActionUiState contextState)`
- State family: campaign spine action phase while acting seat is facing a live bet/raise.

## Exact legality contract summary
- If user is facing a live bet/raise:
  - `CHECK` must not be rendered.
  - generic `BET` must not be rendered.
  - raise-family affordance remains available when legal.
- Non-facing states keep prior behavior.
- Deterministic under identical step/state input.

## What changed
- Runtime guard:
  - kept bounded logic in `_buildCampaignActionChips(...)`.
  - when `facingBetByActionStateV1` is true and a bet-type option is used, chip label now resolves to `RAISE TO` instead of `BET`.
  - `CHECK` suppression in facing-bet state remains enforced.
- Contract proof:
  - strengthened `world1 preflop action-state truth invariants hold for pot/currentBet/toCall` to also assert `BET` is absent in facing-bet state.
  - updated expected-action tap helper to recognize aggressive affordance labels deterministically (`BET` or `RAISE*`) for bet-kind expected steps.

## Proof recap (gates + targeted tests)
- `flutter analyze` PASS
- `./tools/fast_loop_world1_v1.sh` PASS
- `flutter test test/guards/world1_foundations_microtask_contract_test.dart` PASS

## Open risks
- Some legacy content steps still encode `expectedActionKind=bet` while runtime facing state may expose raise-family labeling. Behavior is now legal and user-facing truthful, but underlying naming debt remains.

## Explicit defer list
- Broader action-token normalization across all worlds/packs.
- Any action-bar layout/order redesign.
- Any finish/result or progression continuity changes.

## Anti-drift note
- This milestone changed one runtime seam and one contract surface only.
- No adjacent phase ownership or multi-family action-layer edits were introduced.

## Ambiguous P0 statement
- No ambiguous P0 remains inside the selected R73 seam.

## Transition note for next focus only
- Next bounded focus should be R74 definition/lock before any new implementation work.
