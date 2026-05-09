# Documentation Operating Map / Planning Index v1
Status: SSOT-lite
Purpose: Provide one lightweight entry point to the current planning canon so the docs operate as a usable system instead of a scattered folder.
Last updated: 2026-03-09

## Use

This is the entry-point map for `docs/plan/`.
It does not add new doctrine.
It tells you which existing canon document to use for which decision.

Core rule:

- use the canon instead of inventing local rules
- when in doubt, use the most specific canon doc for the decision type

## Current Planning Foundation Set

| Document | Governs | Use it when you need to answer |
| --- | --- | --- |
| `CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md` | execution order | what phase comes next and in what sequence work should happen |
| `MODE_FAMILY_STRATEGY_v1.md` | curated mode-family set | which mode family belongs to the job instead of inventing a new format |
| `SKILL_COVERAGE_MATRIX_v1.md` | anti-gap skill coverage | whether an essential skill is covered, partial, missing, or later |
| `WORLD_NODE_MODE_MATRIX_v1.md` | world/node placement | which world or node family should carry a skill through which mode family |
| `PROGRESSION_PREREQUISITE_MATRIX_v1.md` | sequencing and anti-jump order | what should come before what and what should not be introduced too early |
| `PRIORITY_GAP_REPORT_v1.md` | ranked next implementation targets | what the next highest-EV product-facing gap is |
| `CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md` | world depth / volume expectations | whether a world is too thin, minimally viable, or healthy/scalable |
| `CANONICAL_ID_NAMING_REGISTRY_CONVENTIONS_v1.md` | IDs, names, registry conventions | what ID/file/status naming should look like |
| `STATUS_READINESS_POLICY_v1.md` | status/readiness meaning and promotion | what `productionLive`, `pilotLive`, `representedReady`, etc. actually mean |
| `CONTENT_AUTHORING_CONTRACT_CONTENT_GRAMMAR_v1.md` | content slice authoring grammar | how a slice should use setup / why / notice / expected / acceptable / recap |
| `QA_ACCEPTANCE_LADDER_v1.md` | acceptance and verification discipline | what evidence and verification budget are enough for a given milestone type |

## Recommended Usage By Task Type

### What should we build next?

Use:

- `PRIORITY_GAP_REPORT_v1.md`
- `SKILL_COVERAGE_MATRIX_v1.md`
- `WORLD_NODE_MODE_MATRIX_v1.md`

### Where should this skill live?

Use:

- `SKILL_COVERAGE_MATRIX_v1.md`
- `WORLD_NODE_MODE_MATRIX_v1.md`
- `PROGRESSION_PREREQUISITE_MATRIX_v1.md`

### Which mode family should we use?

Use:

- `MODE_FAMILY_STRATEGY_v1.md`

### Is this world too thin?

Use:

- `CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md`
- `WORLD_NODE_MODE_MATRIX_v1.md`

### What does this status mean?

Use:

- `STATUS_READINESS_POLICY_v1.md`

### How should this slice be authored?

Use:

- `CONTENT_AUTHORING_CONTRACT_CONTENT_GRAMMAR_v1.md`

### What verification is enough?

Use:

- `QA_ACCEPTANCE_LADDER_v1.md`

### What naming / ID should we use?

Use:

- `CANONICAL_ID_NAMING_REGISTRY_CONVENTIONS_v1.md`

### What phase are we in and what kind of work is appropriate?

Use:

- `CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md`

## Suggested Reading / Decision Order

Default working order:

1. strategy  
   `CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md`
   `MODE_FAMILY_STRATEGY_v1.md`
2. coverage  
   `SKILL_COVERAGE_MATRIX_v1.md`
3. placement  
   `WORLD_NODE_MODE_MATRIX_v1.md`
4. progression  
   `PROGRESSION_PREREQUISITE_MATRIX_v1.md`
5. priority  
   `PRIORITY_GAP_REPORT_v1.md`
6. authoring  
   `CONTENT_AUTHORING_CONTRACT_CONTENT_GRAMMAR_v1.md`
7. status  
   `STATUS_READINESS_POLICY_v1.md`
8. QA  
   `QA_ACCEPTANCE_LADDER_v1.md`
9. naming / registry hygiene  
   `CANONICAL_ID_NAMING_REGISTRY_CONVENTIONS_v1.md`
10. world-volume sanity  
   `CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md`

## Practical Operating Rules

- Use the canon instead of inventing local rules in prompts or side docs.
- Prefer updating the relevant canon document over creating a parallel mini-doc.
- Avoid duplicate authority for the same decision type.
- If two docs seem relevant, start with the more specific one and use the broader one for context.
- Planning canon should guide implementation, not replace runtime truth or guard evidence.

## Near-Term Implication

After this index, the planning foundation should be considered complete enough for default use.
Future work should default back to implementation and rollout unless a genuinely new foundational risk appears.
