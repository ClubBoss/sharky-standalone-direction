# Curriculum Operating System SSOT v1

Status: ACTIVE
Last updated: 2026-05-06

## Purpose

Define one smart system for curriculum control so concept coverage, world
placement, and cross-world learning systems can evolve together without
requiring constant edits across many planning files.

This document answers:

1. where concept truth comes from
2. where world-home truth lives
3. where cross-world system truth lives
4. which minimal docs must change when a concept moves

## Core Principle

Do not treat every planning file as equal.

The operating system should work like this:

1. one source import for concept inventory
2. one ladder SSOT for route and world order
3. one concept-to-world matrix for coverage truth
4. one owner doc per cross-world system
5. optional supporting docs underneath those owners

The goal is not fewer documents at any cost.
The goal is fewer documents that need to change for one curriculum decision.

## Authority Stack

### Layer 1. Source inventory

- `docs/learning/CONCEPTS_SOURCE_FULL_IMPORT_v1.md`

Job:

- preserve the imported concept universe from `Concepts.md`
- act as the broad audit checklist
- not decide routing by itself

### Layer 2. Route and world ladder

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md`

Job:

- define the canonical world order
- define practical product route and current ladder
- freeze high-EV route-policy decisions for disputed concept families
- define when a concept belongs early vs later

### Layer 3. Coverage placement

- `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
- `docs/plan/COVERAGE_LOCK_PROTOCOL_v1.md`

Job:

- assign each important concept family a world home
- show reinforcement worlds
- flag `solid / partial / gap / deferred`
- lock future waves against silent concept loss

### Layer 4. Cross-world system owners

- `docs/plan/LEAK_MAP_AND_RECOMMENDATION_SYSTEM_SSOT_v1.md`
- `docs/plan/ADAPTIVE_SPACED_REPETITION_SSOT_v1.md`
- `docs/plan/HAND_HISTORY_REVIEW_LAYER_SSOT_v1.md`
- `docs/plan/SKILL_GRAPH_PROGRESS_MAP_SSOT_v1.md`

Job:

- own system layers that do not belong to one world only
- prevent important product-learning systems from becoming scattered notes

### Layer 5. Production detail

- `docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md`
- per-world audits
- seam audits
- content grammar and density docs

Job:

- define what gets authored inside each world
- not redefine the concept universe

## Minimal-Change Protocol

When a concept changes, update the smallest correct set only.

### Case A. New concept family added

Update:

1. `CONCEPTS_SOURCE_FULL_IMPORT_v1.md` only if the source import itself changed
2. `CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
3. `MASTER_PLAN_v3.0.md` only if route placement or world order changes
4. `CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md` if the concept was disputed and the
   route policy itself changed
5. one cross-world system owner doc only if the concept belongs to a system

Do not update:

- old historical matrices
- unrelated per-world audits
- runtime-adjacent docs that do not own the concept

### Case B. Concept moves to a different world

Update:

1. `CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
2. `MASTER_PLAN_v3.0.md`
3. `CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md` if the move resolves or changes a
   disputed route decision
4. `CONTENT_PLAN_PER_WORLD_v2.1.md` if the authoring home changes materially

### Case C. Concept stays in same world but gains stronger repetition/support

Update:

1. owning cross-world system doc
2. `CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md` if status changes

### Case D. Product adds a new learning system

Update:

1. create one dedicated owner doc in `docs/plan/`
2. add it to this OS doc
3. add it to `MASTER_PLAN_v3.0.md` references if it becomes active

## Coverage Rules

Every important concept family should have:

1. one primary world home
2. optional reinforcement world(s)
3. optional cross-world system owner
4. one explicit status

Every important system should have:

1. one owner doc
2. one interaction rule with worlds
3. one interaction rule with review/progression/profile

## Four-Layer Learning Rule

For any concept family that matters, the curriculum should eventually support:

1. understand
2. recognize
3. decide
4. recover after a mistake

This rule should be checked in coverage audits.

## Anti-Drift Rules

1. Do not let a per-world content file become the only place a major concept is named.
2. Do not let one product-system doc invent new world order by itself.
3. Do not let imported concept source override the practical ladder silently.
4. Do not let Home/Profile/Review system ideas exist without one owner doc.
5. Do not use historical matrices as active routing truth.

## Coverage Lock State

The previously partial high-value system areas now have dedicated owner docs:

1. leak map and recommendation logic
2. adaptive spaced repetition
3. hand-history review layer
4. skill-first progress map

Future work should extend those owners there instead of reopening ownership
ambiguity elsewhere.

## Operational Recommendation

For future curriculum work:

1. start from `MASTER_PLAN_v3.0.md`
2. check `CURRICULUM_ROUTE_POLICY_DECISIONS_v1.md` for disputed concept timing
3. check `CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
4. if the concept is system-shaped, edit the relevant owner doc
5. only then drop into per-world content planning

This keeps the curriculum connected without making every change fan out across
the whole documentation graph.
