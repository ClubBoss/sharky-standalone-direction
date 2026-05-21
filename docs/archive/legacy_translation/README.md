# Legacy Translation Archive

Status: HISTORICAL ONLY

This folder contains old translation editorial handoff packets that are no
longer part of the current Act0 translation SSOT.

These files are kept for historical reference only.

They must not be used as:

- current runtime translation truth
- current Act0 translation workflow authority
- current source of truth for future RU localization waves

Current translation SSOT lives in:

- `docs/l10n/TRANSLATION_SSOT_v1.md`

Current active runtime translation owners live in:

- `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
- `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- `lib/ui_v2/act0_shell/act0_runtime_phrase_registry_v1.dart`
- `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart`

Current active helper/reference docs remain in `docs/l10n/` and
`docs/plan/` unless they are explicitly archived here.

Archive rule:

- if a translation file is a one-off editorial handoff, stale pass packet, or
  historical calibration note that is no longer part of the live Act0
  translation flow, keep it here and do not route new localization work
  through it
