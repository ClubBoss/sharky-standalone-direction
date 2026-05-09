# content/_legacy_archive Index

Bucket type: `REFERENCE` / `SNAPSHOT` (legacy content archive)

Purpose:
- Preserve historical content bundles, experiments, and superseded module formats for traceability.
- This folder is not loaded by runtime by default and is not the active content source of truth.

Rules:
- Never import from `content/_legacy_archive/` in runtime paths.
- “Gems” may be extracted into active docs/templates with source traceability.
- See `docs/governance/ARCHIVE_POLICY_v1.md`.

## Structure (batch 1 normalization)
- `content/_legacy_archive/feature_increments/` — cNN-era feature slices and iteration branches.
- `content/_legacy_archive/meta_systems_and_outputs/` — checkpoints, quizzes, recaps, persona recommendation outputs.
- Existing top-level legacy module snapshots (`core_*`, `cash_*`, `mtt_*`, etc.) remain valid and intentionally untouched in this batch.

## How to find X
- Feature-increment MTT branch: `content/_legacy_archive/feature_increments/mtt/c16_mtt_expansion/`
- Feature-increment checkpoints/quizzes/recaps: `content/_legacy_archive/feature_increments/{checkpoints,quizzes,recaps}/`
- Meta checkpoints and mixed checkpoint outputs: `content/_legacy_archive/meta_systems_and_outputs/checkpoints/`
- Meta recaps (including global recap families): `content/_legacy_archive/meta_systems_and_outputs/recaps/` and `content/_legacy_archive/recaps_global/`
- Persona recommendations: `content/_legacy_archive/meta_systems_and_outputs/persona/` and `content/_legacy_archive/recommendations/`
- Legacy domain module bundles: top-level families such as `content/_legacy_archive/core_*`, `content/_legacy_archive/cash_*`, `content/_legacy_archive/mtt_*`

## Batch 1 moved items (legacy-internal)
- `content/_legacy_archive/c16_mtt_expansion` -> `content/_legacy_archive/feature_increments/mtt/c16_mtt_expansion`
- `content/_legacy_archive/c17_mixed_checkpoints` -> `content/_legacy_archive/feature_increments/checkpoints/c17_mixed_checkpoints`
- `content/_legacy_archive/c18_recaps` -> `content/_legacy_archive/feature_increments/recaps/c18_recaps`
- `content/_legacy_archive/c19_micro_quizzes` -> `content/_legacy_archive/feature_increments/quizzes/c19_micro_quizzes`
- `content/_legacy_archive/c20_spaced_repetition` -> `content/_legacy_archive/feature_increments/spaced_repetition/c20_spaced_repetition`
- `content/_legacy_archive/c21_persona_recommendations` -> `content/_legacy_archive/feature_increments/recommendations/c21_persona_recommendations`
- `content/_legacy_archive/persona_reco` -> `content/_legacy_archive/meta_systems_and_outputs/persona/persona_reco`
- `content/_legacy_archive/micro_quizzes` -> `content/_legacy_archive/meta_systems_and_outputs/quizzes/micro_quizzes`
- `content/_legacy_archive/mixed_checkpoints` -> `content/_legacy_archive/meta_systems_and_outputs/checkpoints/mixed_checkpoints`
- `content/_legacy_archive/recaps` -> `content/_legacy_archive/meta_systems_and_outputs/recaps/recaps`

Where to look (representative paths)

## Core (legacy module bundles)
- `content/_legacy_archive/core_bet_sizing_fe/v1/`
- `content/_legacy_archive/core_board_textures/v1/`
- `content/_legacy_archive/core_positions_and_initiative/v1/`
- `content/_legacy_archive/core_starting_hands/v1/`

## Cash / L3 / Expansion
- `content/_legacy_archive/cash_l3/`
- `content/_legacy_archive/cash_l3_expansion/v1/`
- `content/_legacy_archive/cash_threebet_pots/v1/`
- `content/_legacy_archive/cash_blind_defense/v1/`

## ICM / Tournament / Advanced
- `content/_legacy_archive/icm_l4_polish/v1/`
- `content/_legacy_archive/mtt_expansion/v1/`

## Meta / QA / Cohesion
- `content/_legacy_archive/content_cohesion_v3/v1/`
- `content/_legacy_archive/core_final/v1/_meta/`
- `content/_legacy_archive/checkpoints/`
