# Deferred Backlog SSOT

This file is the single source of truth (SSOT) for deferred items.

Rules:
- Deferred means no implementation work starts until the listed gate is met.
- Do not track deferred feature plans only in chat.
- Add new deferred items here instead of creating new backlog lists when possible.
- Keep entries deterministic and implementation-agnostic (no timestamps, no speculative code details).
- Keep detailed design discussion in the source doc/file; keep only summary + gate + risk here.

## Deferred Items

Entries are ordered alphabetically by title.

### Bet Sizing Input + Drill Integration v1 (Deferred)
- status: deferred
- owner: assistant
- area: Runtime / Content / Tooling
- gate:
  - Implement only after Worlds 1-3 content reach 10/10 and current P0 UI issues closed.
  - Start with presets, slider later.
- why deferred:
  - Bet sizing drills are required later and should be designed to avoid late runtime/tooling refactors.
- contract principles:
  - Deterministic ID or bucket evaluation only.
  - No pixels or coordinates.
  - No raw float comparison.
  - No RNG.
  - Evaluate only on commit (not continuous drag movement).
- modes:
  - Preset buttons:
    - expected.presetId (strict enum-like IDs only)
  - Slider (deferred phase after presets):
    - expected.pctPotBucket OR expected.bbStep (quantized buckets or steps)
- tooling guardrails (future):
  - Validators reject unknown presetId values.
  - Validators reject unknown buckets or steps.
  - Validators reject unit mismatch (pct-pot vs bb-step).
  - Lint and ingest must enforce schema strictly and deterministically.
- runtime evaluation (future):
  - Runtime emits presetId or bucketId only.
  - Evaluator compares expected vs got by identifier only.
  - Failure line remains factual (expected vs got), no coaching text.
- risk if delayed too long:
  - Float-based or pixel-based checks causing endless rework.
  - Mixing slider freeform values with deterministic drill evaluation.
- estimated complexity: M
- source refs:
  - `docs/backlog_table_visual_borrow_list_v1.md`

### Completion Filters Future Enhancements (Deferred)
- status: deferred
- owner: assistant
- area: UX/Visual
- gate:
  - Activate only after current module completion filter behavior remains stable in production use.
  - Prioritize only if completion filtering becomes a frequent user workflow bottleneck.
- why deferred:
  - Current filter feature is already production-ready; enhancements are polish and convenience work.
- risk if delayed too long:
  - Growing module catalogs may become slower to browse without progress percentage or faster filter affordances.
- estimated complexity: M
- source refs:
  - `docs/COMPLETION_FILTERS.md`

### Coach Layer v1 and Table Visual Borrow List (Deferred)
- status: deferred
- owner: assistant
- area: UX/Visual
- gate:
  - Activate after current runner/table stability and deterministic proofs remain green.
  - Follow phased activation from the source backlog (runner first, then broader scenes).
- why deferred:
  - Visual/coach-layer upgrades are high leverage for virality but risky while core runner systems are still settling.
- risk if delayed too long:
  - Table scenes may feel less differentiated/viral, and instruction overlays may fragment across screens.
- estimated complexity: L
- source refs:
  - `docs/backlog_table_visual_borrow_list_v1.md`

### Import Preview and File Picker (Deferred)
- status: deferred
- owner: assistant
- area: Runtime
- gate:
  - Activate only when import flow scope is explicitly opened and parser/validation UX is defined.
  - Keep current placeholder buttons as non-functional until that scope is approved.
- why deferred:
  - Existing UI exposes placeholder import affordances only; real file picker/preview would expand scope into validation and UX flows.
- risk if delayed too long:
  - Users may see placeholder actions without usable import flow if this screen becomes widely used.
- estimated complexity: M
- source refs:
  - `lib/ui_v2/screens/import_spots_screen.dart`

### Intro Game Flow Cross-Module Progression (Deferred Post-Launch)
- status: deferred
- owner: assistant
- area: Architecture / Content
- gate:
  - Post-launch only, after the "1 level == 1 module" rule is no longer a hard constraint.
  - Requires explicit progression model decision to avoid cross-module ambiguity.
- why deferred:
  - Current curriculum/progression lock intentionally avoids cross-module progression complexity.
- risk if delayed too long:
  - Onboarding progression may remain less smooth if intro flow needs a dedicated cross-module bridge later.
- estimated complexity: M
- source refs:
  - `docs/canonical/phase_3/WORLD_1_CLOSEOUT.md`
  - `docs/canonical/PHASE_3_CLOSEOUT_AND_HANDOFF.md`

### Module Progress Tracking Future Enhancements (Deferred)
- status: deferred
- owner: assistant
- area: Runtime / UX/Visual
- gate:
  - Activate only after core module completion tracking usage data justifies expansion (sync, finer granularity, analytics).
  - Keep local-only completion tracking stable first.
- why deferred:
  - Current module progress tracking shipped with a minimal local-only scope and explicitly deferred secondary features.
- risk if delayed too long:
  - Cross-device continuity and granular progress visibility may lag as content volume grows.
- estimated complexity: M
- source refs:
  - `docs/product/MODULE_PROGRESS_TRACKING.md`

### Path Visual Upgrade Backlog v1 (Deferred)
- status: deferred
- owner: assistant
- area: UX/Visual
- gate:
  - After Path 2.0 scheduling and current stability milestones complete.
  - Keep progression logic unchanged during activation.
- why deferred:
  - Scope control and guard stability while map/progression systems are still changing nearby.
- risk if delayed too long:
  - Path/map UX may under-communicate NEXT action and modality as content depth increases.
- estimated complexity: L
- source refs:
  - `docs/backlog_path_visual_upgrade_v1.md`

### Phase 2 Value/Aha UI Polish (Animations and Badges) (Deferred)
- status: deferred
- owner: assistant
- area: UX/Visual
- gate:
  - Only if a Tier-2 regression or SSOT drift reopens Phase 2 work under the spec STOP rule.
  - Otherwise remain out of scope for the locked Phase 2 slice.
- why deferred:
  - Phase 2 intentionally focused on visibility/navigation, not polish loops or animation/badge work.
- risk if delayed too long:
  - Low immediate risk; polish can lag without breaking the core phase objective.
- estimated complexity: S
- source refs:
  - `docs/reference/history/phase2_value_aha_spec.md`

### Phase 4 Regression Suite Expansion Beyond Stub (Deferred)
- status: deferred
- owner: assistant
- area: Tooling
- gate:
  - Only when Phase 4 is explicitly opened beyond the stub and opt-in checks.
  - Respect the existing Phase 4 change policy and gates.
- why deferred:
  - Current Phase 4 is intentionally a minimal deterministic stub and opt-in guards, not a full regression automation suite.
- risk if delayed too long:
  - Regression coverage may lag feature growth, increasing breakage risk in later phases.
- estimated complexity: M
- source refs:
  - `docs/reference/history/phase4_regression_spec.md`

### Player Zone Real Chip Count Overlay Data (Deferred)
- status: deferred
- owner: assistant
- area: Runtime / UX/Visual
- gate:
  - Activate only when deterministic chip data is available at the player-zone overlay seam.
  - Avoid placeholder-derived values or inferred counts.
- why deferred:
  - UI placeholders exist but actual chip count data is not currently wired.
- risk if delayed too long:
  - Overlay may remain visually incomplete or misleading if users assume counts are accurate.
- estimated complexity: S
- source refs:
  - `lib/widgets/player_zone/player_zone_overlay.dart`

### RC Packaging Manifest Metadata Aggregation (Deferred)
- status: deferred
- owner: assistant
- area: Tooling
- gate:
  - After RC validator maps and visual QA manifests are finalized.
  - Aggregate persona diagnostics only once source exports are stable.
- why deferred:
  - The RC packaging manifest intentionally contains placeholders pending stabilization of upstream metadata sources.
- risk if delayed too long:
  - Release packaging metadata may remain incomplete and require manual stitching during RC cycles.
- estimated complexity: M
- source refs:
  - `lib/release/rc_packaging_manifest_v1.dart`

### Visual Icon SSOT (Deferred)
- status: deferred
- owner: assistant
- area: Architecture / UX/Visual
- gate:
  - Activate when icon reuse starts causing drift or duplication across UI surfaces and design/components library.
  - Keep current inline reuse until there is a clear consolidation target.
- why deferred:
  - Existing inventory notes the need but the icon system is not yet causing immediate blocking issues.
- risk if delayed too long:
  - Icon usage may drift across screens and make later consolidation more expensive.
- estimated complexity: S
- source refs:
  - `docs/visual_system_inventory_v1.md`

### Web Plugin Loader Download and Persistence (Deferred)
- status: deferred
- owner: assistant
- area: Tooling / Runtime
- gate:
  - Activate when Flutter web plugin downloading is an approved target and storage behavior is specified.
  - Keep current web loader behavior explicit and non-downloading until then.
- why deferred:
  - The web plugin loader currently documents missing download/persistence behavior as future work.
- risk if delayed too long:
  - Web plugin feature parity remains limited and may block plugin-based workflows on web.
- estimated complexity: M
- source refs:
  - `lib/plugins/plugin_loader_web.dart`
