# Act0 Localization File Model SSOT v1

Status: ACTIVE  
Last updated: 2026-05-11

## Purpose

This file defines the storage model for Act0 learner-facing localization so
future RU cleanup and future languages do not turn the codebase into a maze of
screen-local strings.

This is the file-model SSOT for Act0 localization work.

## Core rule

Do not store learner-facing localized copy by scattering raw strings across
multiple runtime surfaces.

Act0 localization must use:

1. one core API/reader layer
2. one language data file per language
3. generated world-pack docs for authoring and editorial rewrite
4. stable ids as the translation truth

## Current file model

### Core API layer

- `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`

This file should stay small and structural.

It owns:

- copy model types
- language bundle lookup
- stable-id read helpers
- fallback behavior

It should not grow into a multilingual text dump.

### Language data files

- `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`

Policy:

- one file per language for the whole Act0 family
- do not create one file per screen
- do not create one file per world unless a future scale break proves it is
  necessary
- keep orientation cheap: a human or another agent should know exactly where to
  edit Russian without repo archaeology

Future languages should follow the same shape:

- `act0_copy_es_v1.dart`
- `act0_copy_de_v1.dart`
- `act0_copy_tr_v1.dart`

### Authoring / review layer

- `docs/l10n/ACT0_RU_TRANSLATION_WORKBOOK_v1.md`
- `docs/l10n/act0_world_packs/ACT0_RU_TRANSLATION_MASTER_v1.md`
- `docs/l10n/act0_world_packs/W##_world_X_RU_PACK_v1.md`

These pack docs are not archive artifacts.

They are working translation/editing documents that may be improved by a human
or a translation-focused agent, then brought back into the language file via
the ingest flow.

## Stable-id truth

Localization truth is keyed by ids, not by visible English:

- `worldId`
- `lessonId`
- `taskId`
- named surface atoms

Visible English may remain the authored fallback source, but localized display
copy should be resolved from ids.

## Editing rule

If Russian needs improvement:

1. edit the relevant generated world pack or the RU language file
2. validate with pack audit / coverage / gap tools
3. ingest back into the language file when using packs
4. do not patch UI-local strings as a shortcut

If a new language is added:

1. create one new Act0 language file
2. generate packs with `--lang`
3. fill the new language through the same stable-id pipeline
4. do not re-architect the core reader layer

## Tooling rule

Tools should resolve language-specific copy through one path helper:

- `tools/_lib/act0_copy_language_paths.dart`

Tooling must target language files, not the core API file.

## Anti-sprawl rule

Avoid these failure modes:

- one localization file per screen
- one localization file per tiny widget
- copy logic duplicated in both UI and tools
- different agents inventing different storage formats
- editing generated packs without updating the language file

Preferred structure:

- one Act0 API file
- one Act0 language file per language
- one generated master workbook per language
- one generated world-pack set per language

That is enough structure to scale, but still small enough to stay navigable.

## Progress snapshot

As of this SSOT update:

- Act0 runtime copy reads through the language-aware seam
- RU data lives in `act0_copy_ru_v1.dart`
- RU authoring packs, audit, ingest, and coverage flows are active
- master workbook now points editors back to the RU language file

## Future extension rule

If Act0 grows far beyond the current scale and one language file becomes too
large, split only by stable, obvious product families, not by random screens.

Acceptable future split example:

- `act0_copy_ru_route_v1.dart`
- `act0_copy_ru_runner_v1.dart`
- `act0_copy_ru_surface_atoms_v1.dart`

Do not split before there is a real readability/ownership problem.

For now, the correct model is still:

- one RU file for Act0
- one core API file for Act0
