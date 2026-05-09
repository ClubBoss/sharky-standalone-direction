# Topology Entry Seam Audit v1

Purpose:

- audit current topology and entry-binding seams across world order, node order, and start-target routing
- identify at most one highest-EV seam that can be centralized without broad app-flow redesign

## Candidate Seams

| Seam | Current source locations | Shared intent | Current duplication / drift risk | Best canonical source seam | EV / priority | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| World 1 canonical node order | `lib/ui_v2/map/progress_map_world1_determinism.dart`, `lib/canonical/canonical_truth_map_v1.dart` | shared | low; already canonical enough for current scope | existing canonical order constant plus truth-map projection | medium | leave as-is |
| World 1 entry-target binding from canonical order | `UiV2ProgressMapScreenV2._resolveEarliestIncompleteWorld1PackIdV1`, `UniversalIntakePlanScreen._resolveEarliestIncompletePackIdV1` | shared | medium; the same “earliest incomplete from canonical order, else fallback” rule is duplicated in two entry surfaces | one pure World 1 topology entry helper | high | centralize now |
| non-World1 world pack ordering for entry surfaces | `UiV2ProgressMapScreenV2._sortedPackIdsForWorld`, `canonicalTruthCampaignPackOrderForWorldV1` | shared | medium; the map kept a local sort rule that could drift from the canonical truth-map order for later worlds | canonical truth world pack order helper | high | centralize now |
| world-local progression snapshot consumer | `UiV2BetaShell._loadSnapshot`, `canonicalTruthCampaignPackOrderForWorldV1` | shared | medium; profile snapshot rebuilt the current world pack set from raw prefixes instead of the canonical world order source | canonical truth world pack order helper | medium | centralize now |
| pack-to-world consumer derivation | `UiV2BetaShell._worldForPackId`, `ProgressService.worldIndexForPackIdV1` | shared | low-to-medium; beta shell still carried a local regex-based world derivation even though progression already exposes the canonical helper | `ProgressService.worldIndexForPackIdV1` | medium | centralize now |
| progress-map pack-to-world consumer derivation | `UiV2ProgressMapScreenV2._worldForPackId`, `ProgressService.worldIndexForPackIdV1` | shared | low-to-medium; the map still owned a local regex-based world derivation for display and progression consumers | `ProgressService.worldIndexForPackIdV1` with local empty/null guard | medium | centralize now |
| broad world-to-route mapping | `table_first_navigation.dart`, map launch callbacks, intake/session launch paths | partially shared | high, but route owners differ by surface and mode | none yet without broader flow redesign | medium | later |
| Start Here / Start Now CTA presentation | map CTA, module summary CTA, today-plan CTA | partially shared | labels differ, but product surfaces are not identical | none yet | low | leave as-is |

## R282 Selection

- selected seam:
  - World 1 entry-target binding from canonical order
- why:
  - it is small, shared, and source-first
  - it removes duplicate “earliest incomplete pack” logic from multiple entry surfaces
  - it does not redesign routing or app IA

## R283 Re-audit

- already canonical:
  - World 1 canonical node order
  - broader next-pack routing via `ProgressService.getNextSpinePackToRunV1`
- duplicated but compatible:
  - CTA presentation layers that consume shared targets but keep local labels and shells
- fragmented / drift-prone:
  - non-World1 world pack ordering in the map versus canonical truth ordering
- too broad for now:
  - broad route-to-surface unification

## R283 Selection

- selected seam:
  - non-World1 world pack ordering for entry surfaces
- why:
  - the map still had a local sort rule for later worlds
  - canonical truth already defined the intended pack order per world
  - centralizing this removes topology drift without redesigning route flow

## R284 Re-audit

- already canonical:
  - World 1 entry-target binding
  - non-World1 world pack ordering inside the progress map
  - broader next-pack routing via `ProgressService.getNextSpinePackToRunV1`
- duplicated but compatible:
  - CTA presentation layers that consume shared targets but keep local shells
- fragmented / drift-prone:
  - beta shell current-world progression snapshot still rebuilt world pack sets from raw prefixes
- too broad for now:
  - broad route-to-surface unification
  - general pack-to-screen route mapping

## R284 Selection

- selected seam:
  - world-local progression snapshot consumer
- why:
  - the beta shell profile snapshot is a real progression consumer
  - it can reuse the same canonical world order source without changing navigation flow
  - it removes one more prefix-based local topology derivation

## R285 Re-audit

- already canonical:
  - World 1 entry-target binding
  - non-World1 world pack ordering in the progress map
  - beta-shell world-local pack ordering
  - broader next-pack routing via `ProgressService.getNextSpinePackToRunV1`
- duplicated but compatible:
  - CTA surfaces that consume shared targets but keep local shells
- fragmented / drift-prone:
  - beta shell still carried a local pack-to-world derivation helper
- too broad for now:
  - broad route-to-surface unification
  - general pack-to-screen mapping
  - map-local nullable world/level derivation tied to level semantics

## R285 Selection

- selected seam:
  - beta-shell pack-to-world consumer derivation
- why:
  - the canonical progression helper already exists
  - this is a pure consumer cleanup with no route or UI redesign
  - it removes one more local regex rule from a progression consumer

## R286 Re-audit

- already canonical:
  - World 1 entry-target binding
  - non-World1 world pack ordering in the progress map
  - beta-shell world-local pack ordering
  - beta-shell pack-to-world derivation
  - broader next-pack routing via `ProgressService.getNextSpinePackToRunV1`
- duplicated but compatible:
  - CTA surfaces that consume shared targets but keep local shells
- fragmented / drift-prone:
  - progress map still carried its own pack-to-world derivation helper
- too broad for now:
  - broad route-to-surface unification
  - general pack-to-screen mapping
  - map-local level derivation semantics beyond plain world indexing

## R286 Selection

- selected seam:
  - progress-map pack-to-world consumer derivation
- why:
  - the canonical progression helper already exists
  - the map only needs a local empty/null guard before delegating
  - this removes one more local regex rule without changing route or level flow

## R287 Closeout

- block status:
  - closure checkpoint reached
- active blocker inside bounded scope:
  - none
- remaining deferred / too-broad seams:
  - CTA presentation surfaces
  - broad world-to-route mapping
  - general pack-to-screen mapping
  - map-local level derivation semantics
- canonical closeout artifact:
  - `docs/audit/closeouts/topology_progression_closeout_v1.md`
