# TRANSLATION_SSOT_v1

Status: ACTIVE
Purpose: current translation source-of-truth map for the active Act0 route so
future agents do not confuse runtime owners, helper docs, generated pack
artifacts, and archived historical handoff files.
Last updated: 2026-05-21

## Authority

Use this file beneath:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`
- `docs/plan/ACT0_PRODUCT_100_EXECUTION_ROUTE_v1.md`

This file is the current translation SSOT for the active Act0 route.

## Current Translation SSOT

### Active runtime owner files

These files own the active Act0 EN/RU localization path:

- `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
- `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- `lib/ui_v2/act0_shell/act0_runtime_phrase_registry_v1.dart`
- `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart`

Shared app-localization support is also active:

- `lib/l10n/app_ru.arb`
- `lib/l10n/app_localizations.dart`
- `lib/l10n/app_localizations_ru.dart`
- `l10n.yaml`

### Active translation docs

These docs still guide the current Act0 translation flow:

- `docs/plan/ACT0_LOCALIZATION_FILE_MODEL_SSOT_v1.md`
- `docs/plan/ACT0_CONTENT_LOCALIZATION_SCALING_v1.md`
- `docs/plan/RUSSIAN_LOCALIZATION_ROLLOUT_v1.md`
- `docs/l10n/RU_POKER_TERMS_CANON_v1.md`

### Active helper/reference artifacts

These are not runtime SSOT, but they are still current helper/reference files
for the Act0 stable-id translation flow and must not be archived as stale:

- `docs/l10n/ACT0_RU_TRANSLATION_WORKBOOK_v1.md`
- `docs/l10n/act0_world_packs/ACT0_RU_TRANSLATION_MASTER_v1.md`
- `docs/l10n/act0_world_packs/W##_world_X_RU_PACK_v1.md`
- `docs/l10n/act0_world_packs/ACT0_RU_WORLD_STATUS_REPORT_v1.md`
- `docs/l10n/act0_world_packs/ACT0_RU_CONSOLIDATED_EDITOR_EXPORT_v1.md`
- `docs/l10n/act0_world_packs/ACT0_RU_NEXT_BATCH_v1.md`
- `tools/act0_translation_workbook_sync.dart`
- `tools/act0_translation_pack_audit.dart`
- `tools/act0_translation_pack_ingest.dart`
- `tools/act0_translation_quality_report.dart`
- `tools/act0_translation_consolidated_export.dart`
- `tools/act0_translation_batch_compose.dart`
- `tools/act0_translation_pack_completion_report.dart`

### Archived historical-only files

These files are historical only and must not be used as current translation
truth:

- `docs/archive/legacy_translation/ACT0_RU_EDITORIAL_CALIBRATION_v1.md`
- `docs/archive/legacy_translation/ACT0_RU_FINAL_EDITOR_AGENT_HANDOFF_v1.md`
- `docs/archive/legacy_translation/ACT0_RU_WAVE5_EDITORIAL_HANDOFF_v1.md`
- `docs/archive/legacy_translation/ACT0_RU_WAVE7_EDITORIAL_HANDOFF_v1.md`
- `docs/archive/legacy_translation/ACT0_RU_WAVE9_EDITORIAL_HANDOFF_v1.md`

## Deferred RU Backlog Rule

Broad RU localization remains deferred unless explicitly admitted as its own
wave.

That means:

- do not treat deferred RU debt as a reason to reopen EN route work
- do not run broad translation sweeps during unrelated product waves
- do not patch local UI strings as a shortcut around the stable-id owner seam

## New EN Copy Rule

New EN copy must stay localizable.

That means:

- keep new learner-facing copy in the real owner seam
- prefer stable-id-backed paths over screen-local ad hoc strings
- do not route new copy through archived handoff files or historical workbooks

## Files Agents Should Ignore

Future agents should ignore these as current truth:

- archived translation files under `docs/archive/legacy_translation/`
- one-off historical editorial handoff packets
- historical previous-pass calibration notes
- old external-editor instructions that are no longer part of the active flow

Future agents must not use old previous-app or historical translation
workbooks, handoff packets, or editor-export instructions as active Act0 SSOT.

## Classification Rules For Future Translation Files

Classify new or discovered translation files using this order:

1. `ACTIVE canonical source`
   - runtime owner file used directly by the app or current localization layer
2. `ACTIVE helper/reference`
   - current doc/tool/generated artifact used by the stable-id translation flow
3. `DEFERRED but useful`
   - intentionally paused work that still matches the active Act0 route shape
4. `LEGACY historical-only`
   - old handoff packet, calibration pass, or previous workflow artifact no
     longer used by the active flow
5. `DUPLICATE / stale`
   - superseded file that repeats newer truth without active references
6. `UNKNOWN manual-review`
   - file that still has active code/doc/tool references or unclear ownership

Archive only class `LEGACY historical-only` and clearly `DUPLICATE / stale`
files after confirming they are not imported by active code, tests, tools, or
current SSOT docs.
