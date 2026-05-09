# Campaign Home Landing Policy Audit v1

Purpose:

- separate the remaining campaign/home landing residue into explicit policy classes
- identify whether one bounded next sub-block is honestly separable
- avoid forcing a broader routing / landing redesign

## Policy Class Summary

| Policy class | Current source locations | Current role in product | Why it is still part of the remaining residue | Suitability | Why |
| --- | --- | --- | --- | --- | --- |
| shell-internal landing/default-focus semantics | `lib/ui_v2/screens/universal_intake_plan_screen.dart`, `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, `test/guards/world_campaign_map_home_contract_test.dart` | decides which CTA, section, or immediate action is visually emphasized once the user has already landed inside the plan shell or map shell | R333-R334 aligned the remaining local review/checkpoint CTA emphasis seams; no further honest local shell-emphasis gap remains without crossing into broader landing semantics | aligned enough | this sub-block is now saturated for the current roadmap scope |
| campaign/home landing semantics | `lib/ui_v2/screens/universal_intake_plan_screen.dart`, `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, `test/guards/world_campaign_map_home_contract_test.dart` | decides what the learner is meant to perceive as the “home” campaign surface after boot has already chosen the shell | still mixes shell choice aftermath, section hierarchy, and campaign-home framing across multiple surfaces | later | real value, but broader than one local emphasis/default-focus contract |
| broader routing/band behavior | `lib/services/progress_service.dart`, `test/guards/world_campaign_routing_matrix_contract_test.dart`, followup-pack helpers | chooses which pack or route follows from calibration band, focus, and world progression | residue here is still branch-selection/routing policy rather than a local landing cleanup gap | later | not a cleanup bug by default and less separable from broader routing policy |
| downstream test-shape residue | landing and routing guard seeds | reflects current landing/routing expectations in tests | still includes intentionally narrow or legacy-shaped expectations that should follow source-policy decisions | too broad | should trail source changes, not drive the next sub-block by itself |

## Selection Result

- selected next bounded sub-block:
  - shell-internal landing/default-focus semantics

## Why This Sub-block Wins

It dominates on the requested criteria:

- boundedness
  - concentrated in the already-landed shells rather than boot or routing helpers
- direct product EV
  - changes what the learner is nudged to do first after landing in plan/map surfaces
- low rewrite risk
  - can be handled as local emphasis/default-focus alignment without redesigning routing or shell ownership
- clear separation
  - campaign/home framing and routing-band policy remain downstream or broader layers

## Operational Boundary

This next sub-block should stay bounded to:

- which CTA or section gets default emphasis after landing in an already-selected shell
- how review-vs-next-pack-vs-open-map emphasis is decided inside the plan/map surfaces
- whether those emphasis rules still match current surfaced campaign truth

It should not broaden into:

- redesigning shell selection
- redesigning broader campaign/home identity across surfaces
- redesigning routing-band policy
- rewriting the wider routing / landing system

## Re-audit After R334

- shell-internal landing/default-focus semantics:
  - aligned enough
  - R333 fixed non-required review strip CTA semantics
  - R334 fixed checkpoint-pending strip CTA semantics
- remaining residue:
  - campaign/home landing semantics
  - broader routing/band behavior
  - downstream test-shape residue

No further honest bounded shell-internal landing/default-focus cleanup remains after R334.
