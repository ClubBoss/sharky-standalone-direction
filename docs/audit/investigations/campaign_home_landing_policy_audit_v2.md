# Campaign Home Landing Policy Audit v2

Purpose:

- separate the remaining landing-layer residue after the shell-internal focus fixes
- identify whether one bounded next sub-block is honestly separable
- avoid forcing a broader routing / landing redesign

## Policy Class Summary

| Policy class | Current source locations | Current role in product | Why it is still part of the remaining residue | Suitability | Why |
| --- | --- | --- | --- | --- | --- |
| shell-to-home transition emphasis semantics | `lib/ui_v2/screens/universal_intake_plan_screen.dart`, `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, `test/guards/world_campaign_map_home_contract_test.dart` | decides how the learner is transitioned from intake-plan framing into map/home framing once both shells are already valid | the remaining residue is no longer local CTA wording inside a single shell; it is the seam where plan intent and map intent still overlap in emphasis and “what to do first” framing | now | bounded to shell-to-shell emphasis and default-action continuity without redesigning landing identity or routing |
| campaign/home landing semantics | `lib/ui_v2/screens/universal_intake_plan_screen.dart`, `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, `test/guards/world_campaign_map_home_contract_test.dart` | decides what the learner should perceive as the canonical campaign home surface and what each surface means in the product | still mixes shell meaning, campaign identity, and cross-surface framing | later | real EV, but broader than one emphasis-transition contract |
| broader routing/band behavior | `lib/services/progress_service.dart`, `test/guards/world_campaign_routing_matrix_contract_test.dart`, routing helpers | chooses which route or pack path follows from calibration band, world progression, and route policy | residue here is still route-selection policy rather than landing-semantics cleanup | later | not cleanly separable from wider routing policy |
| downstream test-shape residue | landing and routing guard seeds | reflects current landing/routing expectations in tests | some tests still encode narrow current shapes that should follow source-policy decisions | too broad | should trail source decisions, not define the next sub-block |

## Selection Result

- selected next bounded sub-block:
  - shell-to-home transition emphasis semantics

## Why This Sub-block Wins

It dominates on the requested criteria:

- boundedness
  - sits between already-saturated shell-internal focus semantics and broader campaign/home identity
- direct product EV
  - affects how the learner experiences the handoff from plan shell to map shell
- low rewrite risk
  - can be handled as emphasis/default-action continuity rather than shell/routing redesign
- clear separation
  - campaign/home identity and routing/band behavior remain outside this sub-block

## Operational Boundary

This next sub-block should stay bounded to:

- how intake-plan emphasis and map-shell emphasis align once both surfaces are already valid
- whether the default suggested action and framing remain coherent across the handoff
- whether shell-to-shell transition semantics still match canonical surfaced progression truth

It should not broaden into:

- redefining which surface is the true campaign home
- redesigning shell selection or boot behavior
- redesigning routing-band policy
- rewriting the wider landing system
