# Downstream Routing Boot Policy Audit v1

Purpose:

- separate the remaining downstream routing / boot residue into explicit policy classes
- identify whether one bounded next sub-block is honestly separable
- avoid forcing a broader routing / boot redesign

## Policy Class Summary

| Policy class | Current source locations | Current role in product | Why it is still part of the remaining residue | Suitability | Why |
| --- | --- | --- | --- | --- | --- |
| boot/default-entry semantics | `lib/ui_v2/app_root.dart`, `lib/services/progress_service.dart`, `test/guards/world1_campaign_completion_unlock_contract_test.dart` | decides whether cold boot enters the intake-plan surface or skips directly into the post-campaign map shell | now that campaign-complete and cross-world completion contracts are aligned, the remaining question is whether this boot decision still matches the intended product policy | now | concentrated in one root boot gate, directly user-visible, and separable from downstream map/home behavior |
| campaign/home landing semantics | `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, `lib/ui_v2/screens/universal_intake_plan_screen.dart`, `test/guards/world_campaign_map_home_contract_test.dart` | decides what the learner sees and which CTA/path is emphasized after landing inside campaign/map surfaces | still blends campaign section presentation, next-action emphasis, and map/home behavior after boot already chose the shell | later | real product EV, but broader than boot because it mixes shell-internal emphasis and landing behavior |
| band/routing semantics | `lib/services/progress_service.dart`, routing matrix tests, followup-pack helpers | chooses which followup pack or next route to use from band/focus state | remaining residue here is branch-selection policy, not a stale cleanup bug by default | later | not another local cleanup by default; any change risks mixing routing policy with progression semantics |
| downstream test-shape residue | guard seeds and routing/home tests | encodes expected boot and routing state shapes | still contains older or intentionally narrow expectations that mirror current downstream policy | too broad | should follow source-policy changes rather than act as a standalone next block |

## Selection Result

- selected next bounded sub-block:
  - boot/default-entry semantics

## Why This Sub-block Wins

It dominates on the requested criteria:

- boundedness
  - the core decision is concentrated in `AppRoot._bootstrapEntrySurface()`
- direct product EV
  - it controls the very first learner-visible shell after app boot
- low rewrite risk
  - it can be audited and adjusted without redesigning the full campaign/map experience
- clear separation
  - campaign/home landing and band/routing behavior sit downstream of this boot gate rather than being prerequisites to audit it

## Operational Boundary

This next sub-block should stay bounded to:

- how boot chooses between intake-plan and post-campaign map flow
- which settled completion truths are allowed to influence that choice
- whether the boot gate still matches current surfaced campaign truth

It should not broaden into:

- redesigning campaign map/home emphasis
- redesigning band-based followup routing
- redesigning broader boot/deep-link systems
- rewriting the full routing stack

## Post-R330 Re-audit

- bounded fix landed:
  - `AppRoot` now actually honors the intake-plan vs beta-shell boot branch
- remaining policy classes now classify as:
  - `boot/default-entry semantics`: aligned enough
  - `campaign/home landing semantics`: campaign/home landing semantics
  - `band/routing semantics`: broader routing/band behavior
  - `downstream test-shape residue`: too broad

## Current Status

- no further honest bounded downstream routing / boot policy sub-block remains after R330
- the remaining residue is no longer another boot/default-entry contract gap
- the next work, if any, belongs to campaign/home landing semantics or broader routing/band behavior rather than this downstream boot layer
