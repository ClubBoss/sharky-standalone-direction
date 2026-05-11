# Content Root Scope Audit v1

Status: ACTIVE
Workspace root: `/Users/elmarsalimzade/Sharky_1.0`

## Purpose

Define a simple, operational split between content that is part of the active
product and content that is historical/support-only.

## Active Content Owners

These are part of the active product:

1. `content/world1_act0_*/v1/`
2. `content/worlds/world*/v1/`
3. `content/gauntlets/`
4. `content/schedules/`

## Active Support Shelves

These are not learner-facing module homes, but they are valid active support
material for the product:

1. `content/_meta/`
2. `content/_schemas/`
3. `content/_templates/`
4. `content/_reference/`

## Historical-Only Shelf

This shelf is kept for recovery/reference and must not become a new runtime
owner:

1. `/Users/elmarsalimzade/Sharky_1.0_archive/content/_legacy_archive/`

## Immediate Cleanup Rule

Do not mass-delete active content families just because they look old.

Safe next cleanup targets are:

1. runtime-unreferenced modules proven unused by code and manifests
2. duplicate authored bundles when one canonical owner is proven
3. generated preview/output shelves outside `content/`
4. non-pubspec top-level module bundles after a separate tooling-impact audit

Currently proven examples of generated preview/output shelves outside
`content/`:

1. `content_adaptive_generated/`
2. `content_adaptive_preview/`
3. local build/cache roots such as `build/` and `.dart_tool/`

## Proven archive progression

Archive progress is now split into two proven buckets:

1. historical-only shelf moved out of the active root:
   - `/Users/elmarsalimzade/Sharky_1.0_archive/content/_legacy_archive/`
2. nonruntime module bundles moved after code/test ownership audit:
   - `19` families now live under
     `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/`
3. all remaining legacy top-level module families moved out after the
   product-scope cutover:
   - `/Users/elmarsalimzade/Sharky_1.0_archive/content/top_level_module_archive/`
4. old root-level content files moved out:
   - `/Users/elmarsalimzade/Sharky_1.0_archive/content/legacy_root_files/`

Important nuance:

The old `table-first` / intro / core module code paths may still exist in
`lib/` and `test/`, but their authored content no longer lives in the active
product root. They are now archive/reference-only families and should be
treated as legacy until a separate code cleanup retires or removes those route
owners.

Adaptive content sidecars are a separate class from authored product content:
they may still be referenced by tooling, but they are generated mirrors or
preview outputs rather than canonical learner-facing source material.

## Out Of Scope For This Audit

This audit does not yet prove:

1. which individual module bundles are dead
2. which worlds or sessions can be removed
3. whether every active folder is currently surfaced in runtime

That requires a second pass against runtime references, manifests, and
curriculum routing.
