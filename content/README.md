# content/

High-level content layout summary.

Active content areas
- `content/<moduleId>/v1/` — module bundles (`manifest.json`, drills/quiz/theory files)
- `content/worlds/world*/v1/` — world/session runtime drill trees
- `content/schedules/` — schedule content (for example daily routing)
- `content/gauntlets/` — gauntlet markdown playlists

Active authored subfamilies
- Module bundles: standalone authored modules under `content/<moduleId>/v1/`.
- Transitional module lineage: some thin authored bundles, commonly `trainingType: "etalon"`, are still authored content and not archive by default, but they are an older/secondary lineage rather than the current primary richer module-bundle shape.
- World/session trees: authored world structures under `content/worlds/world*/v1/` with `world.md`, `atoms.md`, and session/crucible trees.
- Authored support shelves: `content/gauntlets/` and `content/schedules/` are active authored routing/support content, not module bundles.
- Underscore shelves: `content/_*` folders are support/reference/generated/legacy buckets, not active authored module or world trees.

Support data
- `content/_meta/` — manifests and content metadata (`world_*_manifest_v1.json`)
- `content/_schemas/` — JSON schemas used by content tooling/validation
- `content/_templates/` — canonical authoring templates (see `content/_templates/README.md`)
- `content/_reference/` — reference-only content-side notes/materials
- `content/_generated/` — generated/local artifacts (non-canonical)

Legacy
- `content/_legacy_archive/` — historical content bundles (not runtime-loaded by default)

Policy
- `docs/governance/ARCHIVE_POLICY_v1.md`
