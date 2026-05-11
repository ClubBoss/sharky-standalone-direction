# Priority Gap Report v1

Status: SSOT-lite planning canon  
Scope: ranked implementation-facing gap report based on current planning canon and current product reality  
Use: choose the next bounded rollout targets without guessing

## Purpose

The project now has planning/control layers for:

- staged implementation
- mode families
- skill coverage
- world/node placement
- progression / prerequisites
- anti-gap guards

This report turns those layers into one practical ranked implementation view:

- what is still missing
- what is only partial
- where the strongest next world/node home is
- which mode family should carry the first rollout

It is not a giant roadmap rewrite.
It is a bounded “what should we build next, and why?” reference.

## Input Canon

This report is grounded in:

- [CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md](docs/plan/CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md)
- [MODE_FAMILY_STRATEGY_v1.md](docs/plan/MODE_FAMILY_STRATEGY_v1.md)
- [SKILL_COVERAGE_MATRIX_v1.md](docs/plan/SKILL_COVERAGE_MATRIX_v1.md)
- [WORLD_NODE_MODE_MATRIX_v1.md](docs/plan/WORLD_NODE_MODE_MATRIX_v1.md)
- [PROGRESSION_PREREQUISITE_MATRIX_v1.md](docs/plan/PROGRESSION_PREREQUISITE_MATRIX_v1.md)
- current truth-map / dev-hub status reality

## Status Buckets Used Here

- `core`: high-EV gap that blocks or weakens the next learning staircase
- `bridge`: not the first missing rung, but needed soon to connect current strength to later families
- `later`: explicitly valuable, but not the next bounded rollout target

## Ranked Gap Table

| Rank | Skill family / gap | Current state | Gap tier | Best next world/node home | Preferred first rollout mode family | Why this is high-EV now |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Format-context boundary consumption beyond docs-only SSOT | partial | core | Cross-world planning / validation layer | Review / Recap, Explain the Why, bounded validation guards | The shared-core vs specialization contract is now explicit, but only lightly enforced. This is the strongest next drift-prevention seam after the recent closure wave. |
| 2 | Bet sizing purpose promoted from pilot to mainline home | partial | bridge | World 4 core node family, with pilot continuity from `w1.s01` | Bet Sizing Choice, Review / Recap | The pilot already exists and is teachable. The main gap is promotion from side surface to planned world placement. |
| 3 | Preflop framework / hand categories | missing | bridge | World 3 core node family | Action Choice, Classifier, Review / Recap | Important, but progression canon still says it should follow a stable comparison/action base rather than jump ahead. |
| 4 | Initiative / aggressor logic | missing | bridge | World 2 late / World 3 early node family | Action Choice, Explain the Why | Still valuable, but no longer stronger than closing planning/validation drift first. |
| 5 | Board texture / spot classification | missing | bridge | World 5 core node family | Classifier, Explain the Why, Review / Recap | Strong long-term value, but progression canon still says this should not jump ahead of earlier decision layers. |
| 6 | Draws / outs / improvement counting | missing | bridge | World 5 core node family | Outs / Improvement Counting, Review / Recap | Important bridge into equity intuition, but it should follow board/state foundations rather than precede them. |
| 7 | Equity / pot-odds intuition | missing | later | World 4 late / World 5+ / World 7+ depending slice | Equity / Pot-Odds Intuition, Action Choice | Valuable, but explicitly blocked by outs/improvement and by stronger purpose/action foundations. |
| 8 | Fold discipline / dominated-hand awareness at full World 1 scale | partial | bridge | World 1 campaign spine / followup family | Action Choice, Review / Recap | Still useful, but no longer the strongest drift-prevention or staircase need. |
| 9 | Transfer to real play | deferred/later | later | Cross-world transfer layer | Transfer / Real Table Application, Review / Recap | Important to preserve, but not the next bounded product-facing implementation target. |

## Current Highest-EV Missing / Partial Families

### Core

- Format-context boundary consumption beyond docs-only SSOT

### Bridge

- Bet sizing purpose as a mainline world competency rather than pilot-only
- Preflop framework / hand categories
- Initiative / aggressor logic
- Fold discipline / dominated-hand awareness at fuller World 1 scale
- Board texture / spot classification
- Draws / outs / improvement counting

### Later

- Equity / pot-odds intuition
- Transfer to real play

## Recent Closure State

The previously highest-EV World 2/runtime/trust cleanup wave is now closed for prioritization purposes in this report.

Closed / no longer ranked as the strongest next move:

- World 2 real-user route/runtime synchronization
- modern table runtime truth and scene-readability fixes on the touched path
- onboarding staged-core-first trust primer and adjacent copy alignment
- first shared-core format-boundary validator consumer

Evidence now exists in:

- `test/guards/world2_campaign_routing_contract_test.dart`
- `test/guards/world2_map_campaign_runtime_sync_contract_test.dart`
- `test/ui_v2/session_drill_player_world2_source_projection_contract_test.dart`
- `test/ui_v2/onboarding_how_it_works_trust_primer_test.dart`
- `test/tools/shared_core_format_boundary_validator_v1_test.dart`

## Best Next World / Node Homes

### Cross-world planning / validation layer

Best next bounded drift-prevention home.

Why:

- the shared-core vs specialization contract is now explicit
- the first validator consumer exists, but the policy boundary is still lightly consumed
- this is the narrowest high-EV way to keep future copy/content/routing aligned before specialization spreads

### World 3

Best next structured content bridge after planning/validation drift is better controlled.

Why:

- current canon explicitly places preflop framework here
- classifier/action-choice mix still makes sense only after simpler comparison/action foundations stabilize

### World 4

Best home for promoting bet sizing from pilot to mainline.

Why:

- the pilot already proves the family is teachable
- the world/node matrix already places bet purpose here
- progression canon says purpose should come before deeper optimization

## Preferred First-Rollout Mode Paths

### For format-context boundary consumption

Start with:

- bounded validation / guard consumption
- Explain the Why
- Review / Recap

Do not start with:

- broad specialization content rollout
- broad runtime or onboarding rewrites

### For bet sizing promotion

Start with:

- Bet Sizing Choice
- Review / Recap

Do not start with:

- a broad new subsystem or many size variants at once

## Ranked Recommendation: Next 5 Implementation Targets

1. Expand the new Format-Context Boundary Contract into a few bounded validation / wording consumers.
   Reason: highest-EV anti-drift move now that the recent cleanup wave is closed.

2. Promote bet sizing purpose from `w1.s01` pilot to a bounded World 4-aligned rollout slice.
   Reason: pilot already exists, so this is the strongest bounded content-facing move after drift-prevention.

3. Begin World 3 preflop framework only after boundary-consumption and current prerequisite integrity remain clear.
   Reason: progression canon still says structured preflop framework should not jump ahead loosely.

4. Add initiative / aggressor logic only when it lands through a bounded bridge, not as broad World 2 fill.
   Reason: still useful, but weaker than the current drift-prevention need.

5. Keep World 5 board/outs layers visible as planned bridge work without pulling them ahead of earlier prerequisites.
   Reason: still important, but not the next bounded rollout target.

## Practical Decision Rule

When choosing the next implementation slice:

1. prefer `core` over `bridge`
2. prefer `bridge` over `later`
3. prefer a missing concept with a clear world home over a broad expansion of an already-strong live slice
4. prefer first rollouts that match the curated mode families already assigned in the canon

## Near-Term Conclusion

The strongest next bounded move is no longer another World 2/runtime/trust cleanup pass.
That closure work is now guarded and should not be re-selected here as the top target.

The strongest next move is:

- consuming the new shared-core vs specialization boundary through a few narrow validation / wording guardrails

After that, the cleanest content-facing frontier remains:

- bounded World 4 bet-sizing promotion
- then World 3 preflop framework work under preserved prerequisite discipline
