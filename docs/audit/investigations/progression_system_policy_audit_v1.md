# Progression System Policy Audit v1

Purpose:

- separate the remaining progression-system residue into explicit policy classes
- identify whether one bounded next sub-block is honestly separable
- avoid forcing a broad progression-system redesign

## Policy Class Summary

| Policy class | Current source locations | Current role in product | Why it is still part of the remaining residue | Suitability | Why |
| --- | --- | --- | --- | --- | --- |
| campaign-complete semantics | `lib/services/progress_service.dart`, `lib/ui_v2/app_root.dart`, `lib/ui_v2/screens/universal_intake_plan_screen.dart`, `test/guards/world1_campaign_completion_unlock_contract_test.dart`, `test/guards/world_campaign_routing_matrix_contract_test.dart` | decides when campaign completion is true and therefore when boot/default entry moves from intake-plan flow to map flow | still encoded as a narrower World 1 completion contract while surrounding world-completion truth has become more explicit and generalized | now | bounded, high product EV, low rewrite risk compared with the other residue, and cleanly isolated enough to audit/fix without inventing a new progression system |
| cross-world completion contract | `lib/services/progress_service.dart`, `lib/canonical/canonical_truth_map_v1.dart`, map/home contract tests | defines what it means for a world to count as complete inside broader campaign progression | now partially split between world-level completion helpers and separate campaign-complete policy | later | real gap, but cleaner after campaign-complete semantics are either affirmed or updated |
| band/routing semantics | `lib/services/progress_service.dart`, routing matrix tests, runner routing helpers | chooses followup packs and next routes from calibration bands or focus | many `_b2` references here are intentional branch-selection policy rather than stale residue | later | not a cleanup bug by default; any change would risk mixing policy and routing behavior |
| boot/default entry semantics | `lib/ui_v2/app_root.dart`, `lib/ui_v2/screens/universal_intake_plan_screen.dart`, boot/map tests | decides whether cold boot lands in plan or map and how the user re-enters the campaign surface | currently depends on the answer to campaign-complete semantics | later | derivative layer; should not be changed before the campaign-complete contract itself is settled |
| test-shape residue | guard harness seeds and campaign routing tests | encodes expected state shapes for current progression policy | still contains many `_b2`-shaped assumptions because tests reflect older or intentionally narrow policy shapes | too broad | should follow source-policy changes rather than drive them as a standalone next block |

## Selection Result

- selected next bounded sub-block:
  - campaign-complete semantics

## Why This Sub-block Wins

It dominates on the requested criteria:

- boundedness
  - the core contract is concentrated in one source helper plus a small number of direct consumers
- direct product EV
  - it directly controls whether the product treats the campaign as complete and changes boot/default entry behavior
- low rewrite risk
  - it can be handled as a policy-contract clarification/fix instead of a broad routing or progression rewrite
- clear separation
  - the other remaining policy classes either depend on this contract or are broader downstream effects

## Operational Boundary

This next sub-block should stay bounded to:

- what `campaign complete` means
- which pack/world conditions satisfy it
- how that contract is consumed by existing entry surfaces

It should not broaden into:

- redesigning rank semantics
- redesigning calibration-band routing
- redesigning all boot/default entry behavior
- rewriting the wider progression system

## Post-R325 Re-audit

- bounded fix landed:
  - `campaign complete` now delegates its completion truth to the canonical world-completion helper for World 1 instead of maintaining a parallel required-pack contract
- remaining policy classes now classify as:
  - `cross-world completion contract`: now
  - `band/routing semantics`: later
  - `boot/default entry semantics`: later
  - `test-shape residue`: too broad

## Updated Selection Result

- selected next bounded sub-block:
  - cross-world completion contract

## Why This Next

- boundedness
  - the remaining gap is concentrated in generic completion helpers such as `campaignWorldCompletionPackIdV1` and `isCampaignWorldDoneByCompletedSetV1`
- direct product EV
  - it governs how worlds count as complete across the surfaced campaign path
- low rewrite risk
  - it can be handled as completion-policy alignment without redesigning routing, rank policy, or entry surfaces
- clear separation
  - band-based followup choice and boot/default entry behavior are now downstream of this contract rather than the next seam to change directly

## Post-R327 Re-audit

- bounded fix landed:
  - cross-world completion truth is now centralized through `campaignWorldCompletionPackIdsV1(world)` and consumed by `isCampaignWorldDoneByCompletedSetV1`
- remaining policy classes now classify as:
  - `campaign-complete semantics`: aligned enough
  - `cross-world completion contract`: aligned enough
  - `band/routing semantics`: downstream routing/boot policy
  - `boot/default entry semantics`: downstream routing/boot policy
  - `test-shape residue`: too broad

## Current Status

- no further honest bounded progression-policy sub-block remains after R327
- the remaining residue is no longer another core progression contract gap
- the next work, if any, belongs to downstream routing/boot policy rather than progression-policy cleanup
