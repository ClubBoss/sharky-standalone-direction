# W5 Board Texture Same-Signal Coverage v1

- Date: 2026-06-23
- Branch: `main`
- Base after Part A push: `cd78be4500b8ba294301ee74405b645fcd15a594`
- Status: `implemented_w5_board_texture_same_signal_coverage`

## Scope

Small content-depth implementation only. This wave addresses the first-week
content audit finding that W5 s01 board texture had only three authored
same-signal classifier reps.

No product UI, Review redesign, routes, telemetry, Modern Table, glossary,
monetization, queue clear/resolution, third repair family, broad action-choice
mapping, screenshots, or generated outputs changed.

## PIEC result

W5 s01 already had a safe authored seam:

- session: `w5.s01`
- family: `board_texture_classifier_v1`
- existing textures: dry, wet, paired
- existing action frames: raise, call, fold
- existing manifest -> `DrillRuntimeAdapterV1` session-practice path
- existing W5 board-texture receipt mapping for the original exact replay
  targets

The smallest useful fix was to add three more authored board-texture classifier
drills to the same session and manifest. No route, UI, or telemetry change was
needed.

## Coverage added

W5 s01 now has six board-texture classifier reps:

| Drill | Texture | Expected action | Role |
| --- | --- | --- | --- |
| `classify_texture_intro_dry_raise_v1` | dry | raise | existing value frame |
| `classify_texture_intro_dry_call_control_v1` | dry | call | added control frame |
| `classify_texture_intro_wet_call_v1` | wet | call | existing control frame |
| `classify_texture_intro_wet_fold_pressure_v1` | wet | fold | added pressure frame |
| `classify_texture_intro_paired_fold_v1` | paired | fold | existing weak-improvement frame |
| `classify_texture_intro_paired_call_control_v1` | paired | call | added control frame |

This gives each supported texture at least two authored reps while preserving
the same family, session, error class, and beginner-safe copy style.

## Manifest and practice path

The new drills are registered in:

- `content/worlds/world5/v1/sessions/w5.s01/drills/index.md`
- `content/_meta/world_drills_manifest_v1.json`

Focused runtime coverage proves `DrillRuntimeAdapterV1` loads all six through
the existing `w5.s01` practice path.

## Repair/recheck behavior

This wave does not change the W5 receipt mapper or visible Review queue.

The already-supported exact replay targets remain:

- `classify_texture_intro_dry_raise_v1`
- `classify_texture_intro_wet_call_v1`
- `classify_texture_intro_paired_fold_v1`

The three new drills improve authored same-signal practice depth. They are not
new route targets or new queue-resolution behavior.

## Tests and checks

Added focused inventory/runtime coverage:

- `test/tools/w5_board_texture_same_signal_coverage_v1_test.dart`

Validation target:

- W5 s01 has six manifest-backed `board_texture_classifier_v1` drills.
- Dry, wet, and paired each appear at least twice.
- Raise, call, and fold action frames remain represented.
- Every drill has intent, why, correct feedback, and incorrect feedback.
- The runtime adapter loads all six board-texture drills for `w5.s01`.

The legacy widget-level board-texture screen test remains baseline-blocked by
missing archived imports:

- `lib/ui_v2/screens/modern_table_screen_v1.dart`
- `lib/ui_v2/screens/session_drill_player_v1_screen.dart`

That test is not used as this content-slice gate. The active coverage gate is
the new inventory/runtime test plus the service-level board-texture receipt
mapping and evaluator tests.

The full `dart run tools/validate_world_content_v1.dart` gate remains
baseline-blocked on clean `origin/main` by unrelated W6 s01 drill-count residue:

- `content/worlds/world6/v1/sessions/w6.s01/drills/index.md`
- `world6 session=w6.s01 role=Learn drill_count=14 expected_range=3..12`

This reproduced on clean `origin/main` at
`cd78be4500b8ba294301ee74405b645fcd15a594`. The W5 slice increases world5 file
count only and does not touch W6.

## Remaining limitations

- Queue clear/resolution remains deferred.
- Only the original three W5 exact replay targets are mapped into repair
  receipts.
- The legacy widget-level board-texture test still depends on missing archived
  screen imports.
- The full content validator still fails on unrelated clean-main W6 s01
  drill-count residue.
- W6 s01 index/count residue remains outside this W5 wave.
- No broad W5 pack expansion or premium packaging was attempted.

## Recommended next step

Run a small packaging/push gate for this content-depth slice. After that, the
next product decision should be whether to add receipt mapping for the added W5
board-texture reps or to address queue resolution policy first.
