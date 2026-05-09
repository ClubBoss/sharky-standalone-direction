# Canonical ID / Naming / Registry Conventions v1
Status: SSOT-lite
Purpose: Record the identifier, naming, and registry conventions that future rollout should follow so IDs, files, statuses, and registry entries do not drift into inconsistent forms.
Last updated: 2026-03-09

## Use

This document sits alongside:

- `docs/plan/CANONICAL_STAGED_IMPLEMENTATION_PLAN_v1.md`
- `docs/plan/MODE_FAMILY_STRATEGY_v1.md`
- `docs/plan/SKILL_COVERAGE_MATRIX_v1.md`
- `docs/plan/WORLD_NODE_MODE_MATRIX_v1.md`
- current truth-map and guard work

It does not require a rewrite of existing IDs.
It defines the naming discipline that future implementation should follow so registries, guards, docs, and runtime surfaces stay compatible.

Core rule:

- stable internal IDs are infrastructure
- display labels are product copy
- do not treat those as the same thing

## General Naming Principles

- Use ASCII-only identifiers.
- Use lowercase snake_case for stable IDs.
- Treat stable enums and ID families as append-only where practical.
- Prefer additive evolution over rename churn.
- Keep IDs machine-oriented and keep user-facing polish in display copy.
- Avoid semantic drift where two names describe the same concept in different places.

Practical implications:

- an ID should optimize for stability and predictability
- a title should optimize for readability and product feel
- changing copy is cheaper than changing a stable ID

## Canonical Identifier Classes

### World IDs

Canonical pattern:

- `world1`
- `world2`
- `world10`

Usage:

- use numeric world IDs for stable grouping and ordering
- use `worldX_` as the prefix for world-owned packs/modules

### Node / Pack / Module IDs

Canonical pattern:

- `world1_act0_table_literacy`
- `world1_spine_campaign_v1`
- `world1_spine_followup_v1_b0`

Rules:

- use `worldX_` prefix for campaign-owned pack/module IDs
- use the same stable string for `packId` and `moduleId` unless there is a proven reason to split them
- encode structural role in the ID:
  - `act0`
  - `spine`
  - `followup`
- use suffixes like `_b0`, `_b1`, `_b2` only for structurally meaningful branch/followup distinctions

### Session IDs

Canonical pattern:

- `w1.s01`
- `w2.s01`
- `cash.s01`
- `tournament.s01`

Rules:

- use short session IDs for session-drill content
- keep the world form `wX.sYY` for numbered world sessions
- keep track-specific forms only where the content family is genuinely track-owned

### Drill IDs

Canonical pattern:

- `choose_half_pot_value`
- `choose_hero_top_pair_showdown`
- `find_bb`

Rules:

- use verb-first snake_case
- the ID should capture the task shape, not the user-facing prose
- do not encode decorative language in the drill ID

### Mode Family IDs

Canonical pattern:

- doc/canon names: `Identify / Locate`, `Bet Sizing Choice`
- runtime IDs: compact machine forms such as `bet_sizing_choice_v1`, `showdown_winner_choice_v1`

Rules:

- keep one canonical machine ID per real runtime family
- keep one canonical planning name per curated family
- if both exist, maintain a clear one-to-one mapping instead of inventing aliases

### Status / Readiness IDs

Canonical pattern:

- `productionLive`
- `productionLiveModernized`
- `productionLiveLegacy`
- `pilotLive`
- `placeholder`
- `scaffold`
- `legacy`
- `devOnly`
- `representedReady`
- `needsSkeletonShell`

Rules:

- status IDs are machine labels, not user-facing copy
- status families should be kept small and additive
- do not rename existing status IDs casually once guards or registries depend on them

### Registry Keys / File Naming

Canonical pattern:

- registry/truth files use explicit versioned names:
  - `canonical_truth_map_v1.dart`
  - `world_drills_manifest_v1.json`
- planning canon docs use explicit versioned names:
  - `MODE_FAMILY_STRATEGY_v1.md`
  - `PRIORITY_GAP_REPORT_v1.md`

Rules:

- prefer descriptive file names with explicit version suffixes where the file is intended as a canonical reference
- keep registry file names aligned to the truth layer they own
- do not create near-duplicate files that differ only by small wording changes

## Structural Naming Rules

### When To Use `worldX_...`

Use `worldX_...` when the identifier belongs to:

- a campaign pack
- a campaign module
- a world-owned canonical node

Do not use `worldX_...` for:

- short session IDs like `w2.s01`
- display titles
- ad hoc copy labels

### When To Use `_v1`

Use `_v1` when the identifier names:

- a versioned contract
- a versioned content file
- a versioned registry/truth layer
- a versioned stable product artifact that may evolve later

Do not add `_v1` to every ID by reflex.
Use it where versioning is part of the artifact’s lifecycle.

### When A Label Belongs In Copy Instead Of The ID

Put wording in copy, not in IDs, when:

- the phrase is user-facing
- the phrase may be rewritten for product quality
- the wording is explanatory rather than structural

Example:

- good stable ID: `world1_act0_action_literacy`
- good display title: `Action Order`

### Avoiding Duplicate Concepts With Different Names

If a concept already has a canonical name:

- reuse that name across docs, truth maps, guards, and runtime labels where appropriate
- do not introduce a second near-synonym unless there is a real conceptual difference

Practical example:

- keep one stable concept family for `Hand Strength / Showdown Comparison`
- do not split it casually into unrelated aliases like `winner check`, `showdown compare`, and `hand compare` across separate layers

## Registry Alignment Rules

- One canonical runtime registry/truth layer should own machine-visible status for a surface.
- Planning docs may describe intent, but should not redefine runtime IDs.
- A registry entry should use stable IDs from the same identifier family it represents.
- If a doc needs a friendlier label, keep that as prose and preserve the runtime ID separately.

Practical rule:

- registry keys should be predictable enough that guards can derive and compare them without fuzzy matching

## Migration Discipline

- Do not rename stable IDs casually.
- Prefer additive fixes:
  - new status value
  - new doc alias note
  - new display label
  instead of breaking ID churn
- Preserve backward compatibility where possible.
- If an ID is ugly but still stable and guard-backed, prefer fixing titles and mapping layers first.
- Only rename a stable ID when the ID is truly broken and the migration cost is justified.

When a rename is truly necessary:

1. document the reason
2. add compatibility or migration handling where possible
3. update registry/truth layers and guards together
4. do not leave mixed old/new names in parallel without a clear bridge

## Practical Near-Term Implication

Future implementation should:

- reuse existing world/pack/session/drill ID families
- keep runtime family IDs aligned with curated planning names
- add new statuses or readiness labels additively
- prefer one canonical registry name per truth layer
- avoid introducing duplicate concept names across docs, code, and content

Future docs, registries, and guards should rely on the same discipline so:

- guards stay reliable
- migrations stay bounded
- canonical truth stays readable
- rollout does not accumulate naming debt

## Decision Rule

Before adding a new ID or registry key, ask:

1. Which existing identifier class does this belong to?
2. Is there already a stable naming pattern for that class?
3. Is this name structural, or should it be display copy instead?
4. Am I adding a new concept, or renaming an existing one unnecessarily?
5. Will a future guard or registry comparison remain simple with this name?

If those answers are unclear, do not add a new naming variant yet.
