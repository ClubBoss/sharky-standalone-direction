# Nonruntime Module Families Audit v1

Status: ACTIVE
Workspace root: `/Users/elmarsalimzade/Sharky_1.0`

## Purpose

Record the post-cutover truth for top-level module content after the standalone
product root was narrowed to the current `Act0 + worlds` route.

## Current top-level module truth

Active top-level module families still present in `content/`:

1. `world1_act0_table_literacy`
2. `world1_act0_action_literacy`
3. `world1_act0_street_flow`

These are the only active top-level module bundles left inside the product
root.

## Active authored route that stays in root

The broader active curriculum now lives primarily under:

1. `content/worlds/world*/v1/`
2. `content/gauntlets/`
3. `content/schedules/`
4. active support shelves under `content/_*`

On-disk authored world roots currently present:

1. `world0`
2. `world1`
3. `world2`
4. `world3`
5. `world4`
6. `world5`
7. `world6`
8. `world7`
9. `world8`
10. `world9`
11. `world10`

The `W1-W12` route remains the active product authority in docs and planning,
but this root no longer keeps older top-level module bundles as live authored
content.

## Archived top-level module families

All other top-level module families were moved out of the active root to:

`/Users/elmarsalimzade/Sharky_1.0_archive/content/top_level_module_archive/`

This includes the old:

1. `intro_*`
2. `core_*`
3. `cash_*`
4. `mtt_*`
5. `online_*`
6. `live_*`
7. `math_*`
8. legacy `table-first` deeper theory chains

## Archived legacy root files

Old content-root files that are no longer part of the active product were moved
to:

`/Users/elmarsalimzade/Sharky_1.0_archive/content/legacy_root_files/`

These include:

1. `preflop_drills.json`
2. `puzzles.json`
3. `glossary.json`

## Important caution

Some legacy code and tests may still reference archived module ids.

That does **not** make those module bundles active product content again.

It means the next cleanup wave, if wanted, should target code ownership:

1. legacy `table-first` route owners
2. old intro/core release-content plan owners
3. stale tests that still assert on archived module families

## Safe conclusion now

The active product root is now content-scoped the way the current product is
actually intended to work:

1. active `Act0`
2. active authored `worlds`
3. active support shelves
4. old top-level module bundles preserved only as archive/reference
