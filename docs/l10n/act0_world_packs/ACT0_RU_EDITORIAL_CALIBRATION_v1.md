# ACT0 RU Editorial Calibration v1

Date: 2026-05-12
Scope: `world_1` through `world_12`
Purpose: editorial quality calibration after the Wave 8 targeted editorial cleanup cycle

## Truth Model

- This file is an editorial scorecard, not a runtime coverage report.
- Structural/runtime truth still lives in `ACT0_RU_WORLD_STATUS_REPORT_v1.md`.
- Runtime RU truth still lives in `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`.
- Pack-layer editing truth still lives in `docs/l10n/act0_world_packs/W##_world_*_RU_PACK_v1.md`.

## Wave 8 Applied

This calibration assumes the following work landed:

- pack-layer closure of all empty `*_ru` fields in `world_1`, `world_2`, and `world_3`
- targeted editorial cleanup for `world_7`, `world_9`, `world_10`, `world_11`, and `world_12`
- replacement of false-friend `сброс` phrasing in mindset/reset teaching with `перезагрузка`
- softer signal-language in `world_11` and lower study-note tone in `world_9` and `world_10`
- regenerated consolidated export after the cleanup pass

## Pack Completion Snapshot

Current pack-layer truth after Wave 8:

- lesson titles: `63/63`
- lesson subtitles: `63/63`
- task titles: `329/329`
- runner prompts: `328/329`
- runner supports: `328/329`
- runner questions: `328/329`
- teaching step titles: `340/340`
- teaching step bodies: `340/340`

Notes:

- `world_1`, `world_2`, and `world_3` no longer have empty learner-facing `*_ru` fields.
- the remaining `328/329` runner-field count is a schema/source exception in `world_12`, not a new blank-translation family.
- task summaries are intentionally sparse because many tasks in the source pack do not carry summary fields.

## Overall Editorial Readiness

- Previous external audit baseline: `76/100`
- Post-cleanup baseline before the last two editorial cycles: `81/100`
- Baseline before the Wave 8 cleanup pass: `93/100`
- Current editorial readiness after the new cleanup pass: `95/100`
- Net effect of this wave: the largest remaining false-friend and study-note residues were reduced, `world_11` transfer copy is warmer, and `world_12` mindset/reset language is more product-safe for learners

## External Report Synthesis

### Report A: `ACT0_RU_WAVE8_CALIBRATION_AND_AGENT_HANDOFF_v1.md`

- Strengths:
  - strongest operational report in this cycle
  - correctly challenged stale coverage assumptions
  - useful as a process-integrity and risk-ordering document
- Weaknesses:
  - several coverage claims were already stale against current pack truth by the time of integration
  - less sensitive to line rhythm than the pure editorial note

### Report B: `Gemini 3.md`

- Strengths:
  - strong ear for line-level natural Russian
  - correctly flagged `сброс` as a harmful false friend for emotional reset copy
  - gave high-EV fixes in `world_9`, `world_10`, `world_11`, and `world_12`
- Weaknesses:
  - better as a patch list than as structural truth
  - some suggestions still needed compaction and product-tone filtering

### Verdict

- Better operational report: `ACT0_RU_WAVE8_CALIBRATION_AND_AGENT_HANDOFF_v1.md`
- Better line-level editorial report: `Gemini 3.md`
- Best combined use:
  - use `Wave 8 handoff` for sequencing and risk framing
  - use `Gemini 3` for targeted rewrites where the wording is already structurally sound but not yet premium

## World Scorecard

| World | Score | Status | Main Residue |
| --- | --- | --- | --- |
| `world_1` | `9.2/10` | strong | only final rhythm polish remains |
| `world_2` | `8.9/10` | strong | coherent and teachable; only finish work remains |
| `world_3` | `9.0/10` | strong | stable and consistent; only launch-grade polish remains |
| `world_4` | `8.2/10` | usable draft | still the softest restored world and the clearest tone-upgrade opportunity |
| `world_5` | `8.4/10` | cleanup | coherent draft, mainly tone smoothing left |
| `world_6` | `8.3/10` | cleanup | restored and warmer, but still not fully polished |
| `world_7` | `8.5/10` | cleanup | combo/range language is safer; next gain is cadence and warmth |
| `world_8` | `8.0/10` | cleanup | stable and coherent, but still slightly more mechanical than neighbors |
| `world_9` | `8.4/10` | cleanup | tournament language is more human; some compression polish still helps |
| `world_10` | `8.4/10` | cleanup | player-adjustment copy is clearer and less analyst-like |
| `world_11` | `8.8/10` | cleanup | transfer/review loop now reads much more like product coaching |
| `world_12` | `9.0/10` | cleanup | mindset/reset layer is now safer; remaining work is final cadence polish |

## Priority Order After This Wave

1. `world_4`
Reason: still the softest restored world and the clearest place to gain product tone quickly.

2. `world_6`
Reason: coherent now, but board/draw teaching still wants one warmth pass.

3. `world_7`
Reason: terminology is safe; the next gain is better pedagogy rhythm and compactness.

4. `world_8`
Reason: stable, but still slightly more mechanical than neighbouring worlds.

5. `world_9` and `world_10`
Reason: safer and more human now, but still not fully premium-editorial in rhythm.

6. light final polish on the rest
Reason: `world_1-3` and `world_11-12` are no longer rescue zones; only finish work remains.

## Before / After By Block

| Block | Before | After | Effect |
| --- | --- | --- | --- |
| Early table literacy (`world_1`) | `9.2/10` | `9.2/10` | unchanged this wave; still strong and coverage-complete |
| Hand discipline (`world_2`) | `8.9/10` | `8.9/10` | unchanged this wave; stable and coherent |
| Position thinking (`world_3`) | `9.0/10` | `9.0/10` | unchanged this wave; only final polish remains |
| Preflop framework (`world_4`) | `8.2/10` | `8.2/10` | next highest-EV editorial frontier |
| Bet purpose (`world_5`) | `8.4/10` | `8.4/10` | stable, waiting on lighter polish |
| Board and draws (`world_6`) | `8.3/10` | `8.3/10` | stable, but still wants warmth and cadence polish |
| Range thinking (`world_7`) | `8.3/10` | `8.5/10` | combo language is more natural and less like translated notes |
| Stack depth / format (`world_8`) | `8.0/10` | `8.0/10` | stable and coherent; frontier is still cadence |
| Tournament pressure (`world_9`) | `8.1/10` | `8.4/10` | survival and bubble lines are more human and less abstract |
| Player adjustment (`world_10`) | `8.1/10` | `8.4/10` | cleaner product voice with less analyst/sample wording |
| Real play transfer (`world_11`) | `8.4/10` | `8.8/10` | signal/review loop reads more like coaching and less like a worksheet |
| Mindset bridge (`world_12`) | `8.5/10` | `9.0/10` | reset language is now product-safe; remaining work is final cadence polish |

## Notes

- These scores are calibration estimates, not tool-derived numeric truth.
- This wave did not change coverage truth; it improved editorial quality inside already-complete packs.
- `world_11` and `world_12` moved out of the highest-risk wording group.
- The next best expensive step is now a true finish pass: `world_4`, `world_6`, `world_7`, then `world_8-10`, with lighter rhythm polish on the rest.
