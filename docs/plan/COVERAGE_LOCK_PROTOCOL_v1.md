# Coverage Lock Protocol v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Define the smallest permanent protocol that keeps curriculum coverage at
effectively 100 percent during future content production.

The goal is simple:

1. no important concept family disappears
2. no new content wave authors against a false route
3. no one has to reread the whole docs tree to stay safe

This is a lock protocol, not a new planning layer.

## What "100 Percent Coverage" Means Here

Coverage is considered locked only when every important concept family from the
imported source satisfies all four checks:

1. it has a canonical primary world home or a canonical cross-world system owner
2. it has a documented reinforcement path when reinforcement is needed
3. its route timing is either accepted or explicitly frozen as a policy decision
4. its absence from the current production wave cannot make it disappear from
   the route accidentally

This protocol does not claim that all worlds are already fully produced.
It claims that the route is fully accounted for so production can proceed
without silent concept loss.

## Canonical Control Set

Open these first and treat them as the active coverage lock:

1. `docs/plan/MASTER_PLAN_v3.0.md`
2. `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`
3. `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
4. `docs/learning/CONCEPTS_SOURCE_FULL_IMPORT_v1.md`
5. `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`
6. `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`

Open cross-world owner docs only when the concept is system-shaped:

1. `LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md`
2. `ADAPTIVE_SPACED_REPETITION_SSOT_v1.md`
3. `HAND_HISTORY_REVIEW_LAYER_SSOT_v1.md`
4. `SKILL_GRAPH_PROGRESS_MAP_SSOT_v1.md`

## Five Checks Before Any Content Wave

Before authoring or moving any world content, answer these in order:

1. **Coverage check**
   Is the concept family already named in `CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`?
2. **Home check**
   Does it already have one canonical primary world home or one canonical
   cross-world owner?
3. **Timing check**
   If timing is disputed, is the answer already frozen in
   `CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`?
4. **Authoring check**
   Does `CONTENT_PLAN_PER_WORLD_v2.1.md` already show where the content should
   be authored?
5. **Execution check**
   Is the current wave adding density/repetition/clarity, or is it actually
   changing route policy?

If any answer is "no", stop and update the smallest owning doc first.

## Minimal Update Rule

Use the smallest correct edit set:

1. change `CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md` when coverage truth changes
2. change `CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md` when timing policy changes
3. change `MASTER_PLAN_v3.0.md` only when route, priority, or ladder truth changes
4. change `CONTENT_PLAN_PER_WORLD_v2.1.md` when authoring home or world detail changes
5. change one cross-world owner doc only when the concept belongs to that system

Do not update historical matrices or historical execution references as part of
normal content work.

## No-Loss Rules

1. No concept family may exist only in a world authoring note.
2. No concept family may move worlds without the coverage matrix being updated.
3. No practical early seed may be added ad hoc if route timing is still disputed.
4. No late concept may be pulled forward just because one task already exists for it.
5. No world may be called complete if it teaches topics but drops the
   understand -> recognize -> decide -> recover loop.
6. No review, profile, or recommendation behavior may imply a concept family
   that has no canonical owner.

## Tension Handling Rule

If a topic is intentionally later than the imported source would prefer, it is
not a gap if all three are true:

1. the concept family exists in the coverage matrix
2. the later timing is explicitly frozen in route policy
3. early route copy or seeds do not falsely imply that the full concept is
   already taught

This is how we keep strong route discipline without pretending the concept is
missing.

## Definition Of Done For Coverage-Safe Waves

A content wave is coverage-safe when:

1. it does not create any ownerless concept family
2. it does not contradict route-policy decisions
3. it does not require scanning historical docs to understand placement
4. it leaves the active control set sufficient for the next wave

## Practical Stop Rule

Do not create a new governance or coverage doc unless one of these is true:

1. a real concept family still has no clean owner
2. a real route-policy dispute cannot fit in the existing policy doc
3. a real cross-world system has appeared without an owner

Otherwise, update the existing owner doc and continue product work.
