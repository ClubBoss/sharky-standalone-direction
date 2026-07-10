# Multi-Wave Visual Integrity — Wave 2 W9 Table Overlay

## Verdict

`green__w9_center_overlay_collision_repaired`

## Invariant and root cause

The table has independent positioned presentation owners. A multi-line table
repair callout and the centered context/street stack both occupied the same
upper-middle region, producing W9 text interpenetration at 375 x 812.

The bounded invariant is: **a repair callout owns the upper-center teaching
lane, and the context/street stack shifts into a reserved middle lane only
while that callout is present.** The implementation derives that condition in
`_Act0TableV1`; it does not add a collision engine or alter seat, card, felt,
or table architecture.

## Validation

- `flutter test test/guards/w7_w12_table_context_readiness_audit_contract_test.dart`
  — passed (4 tests), including the lane-reservation guard.
- `flutter analyze` — passed with no issues.
- Fresh active-route capture at compact 375 x 812 — passed.

## Fresh literal evidence

Local-only images:

- `output/evidence/multi_wave_visual_integrity_v1/wave_2_w9_overlay/compact.w8_route_task_table.png`
- `output/evidence/multi_wave_visual_integrity_v1/wave_2_w9_overlay/compact.w9_first_route_task_table.png`
- `output/evidence/multi_wave_visual_integrity_v1/wave_2_w9_overlay/compact.w10_route_task_table.png`
- `output/evidence/multi_wave_visual_integrity_v1/wave_2_w9_overlay/compact.w12_payoff_completion_table.png`

W9's three-line tournament-pressure callout is now separated from the
`Decision spot` / street region; the board, pot, call price, hero seat, and
bet markers remain readable. W8, W10, and W12 are retained as regression
controls.

## Regression and non-claims

No Modern Table redesign, route/content change, W13 admission, telemetry,
Sharky, assets, or global positioning system was introduced. This proves only
the named deterministic visual lane at the supported compact capture size; it
does not claim Human QA, public readiness, or a 10/10 result.
