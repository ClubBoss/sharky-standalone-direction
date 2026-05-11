# content/

High-level content layout summary.

Canonical rule
- This `content/` tree belongs to the standalone active product root at `/Users/elmarsalimzade/Sharky_1.0`.
- Do not treat neighboring repositories or older workspaces as active content owners.

Active content areas
- `content/world1_act0_*/v1/` — the only active top-level module bundles in the current product root
- `content/worlds/world*/v1/` — world/session runtime drill trees
- `content/schedules/` — schedule content (for example daily routing)
- `content/gauntlets/` — gauntlet markdown playlists

Active authored subfamilies
- Act0 module bundles: only the `world1_act0_*` bundles remain active as top-level module content in this root.
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
- historical content bundles now live outside the active product root at:
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/_legacy_archive/`

Current audit summary
- Active runtime/authored families in this root are primarily:
  - `content/world1_act0_*/v1/`
  - `content/worlds/world*/v1/`
  - `content/gauntlets/`
  - `content/schedules/`
- Support/reference shelves that may stay in the active root:
  - `content/_meta/`
  - `content/_schemas/`
  - `content/_templates/`
  - `content/_reference/`
- Historical-only shelf:
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/_legacy_archive/`
- Archived top-level module archive:
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/top_level_module_archive/`
- Archived legacy root files:
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/legacy_root_files/`
- Safely archived nonruntime modules:
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/intro_positions/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/intro_preflop_mastery/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/intro_preflop_ranges/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/intro_session_basics/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/intro_success_signals/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/bankroll_and_variance_management/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/database_leakfinder_playbook/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/icm_bubble_blind_vs_blind/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/icm_final_table_hu/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/icm_mid_ladder_decisions/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/mental_game_and_routines/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/online_hud_and_db_review/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/online_hudless_strategy_and_note_coding/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/online_notes_and_exploit_tracker/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/online_population_exploits_playbook/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/program_catalog/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/rake_and_ante_economics/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/spr_commitment_checklists/`
  - `/Users/elmarsalimzade/Sharky_1.0_archive/content/nonruntime_modules/study_review_handlab/`

Current active root truth
- The active product no longer carries the old top-level `intro_*`, `core_*`, `cash_*`, `mtt_*`, `online_*`, `live_*`, `math_*`, or legacy table-first module families in-place.
- Those families are preserved only as archive/reference material outside the active product root.
- The authored world route currently present on disk is `world0` through `world10`; broader `W1-W12` route authority remains in the active docs and plan stack, but not every later world has a separate standalone top-level module family in this root.

Policy
- `docs/governance/ARCHIVE_POLICY_v1.md`
