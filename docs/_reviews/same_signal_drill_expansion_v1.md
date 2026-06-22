# Same-Signal Drill Expansion v1

## Scope

One authored family only: `range_bucket_classifier_v1` in World 6 session
`w6.s01`. No W3 preflop or W5 board/draw expansion is included.

## Evidence and selection

`docs/_reviews/content_depth_term_drill_coverage_audit_v1.md` identified only
two explicit range-bucket classifier drills. Range bucket was selected because
it has a small, deterministic existing drill contract and a clear manifest
practice seam. W5 board/draw and W3 preflop were deferred because each already
has a broader authored family and would make this wave less surgical.

## Added same-signal spots

The W6 s01 family now has six manifest-backed range-bucket classifiers:

- existing: strong -> raise;
- existing: missed -> fold;
- added: medium -> call with a fair price;
- added: weak -> fold under pressure;
- added: strong -> call when action is already large;
- added: missed -> fold with no clean draw.

The additions repeat the same range-bucket classification signal across
raise, call, and fold frames without adding a new concept or a new session.

## Mapping and practice seam

The four new JSON drills are registered in the existing W6 s01 world-drills
manifest. The existing manifest -> drill runtime -> session-practice path can
therefore load the six-card family using the existing deterministic
`range_bucket_classifier_v1` behavior.

Review/recheck does not yet surface these content drills. The current Act0
same-signal mapper only maps first-week action, board, price, and position
signals. This wave deliberately does not add a range-bucket receipt, mapper,
route, or UI behavior.

## Tests and checks

- Focused inventory contract asserts six manifest-backed classifiers, all four
  bucket types, three action frames, and authored feedback fields. Its runtime
  check loads all six through `DrillRuntimeAdapterV1` for `w6.s01`.
- Existing widget-level range-bucket contract is baseline-blocked: it imports
  the missing `lib/ui_v2/screens/session_drill_player_v1_screen.dart` path,
  which is absent on `origin/main` and outside this wave.
- Run content validators, term-introduction scanner, formatter, analyzer when
  Dart changes, diff check, and status before commit.

## Product EV and limits

This turns a two-card range-bucket classifier family into six auditable
same-signal repetitions, making the content depth behind future repair claims
more credible. It is not a direct Act0 Review repair target yet, and it does
not make W5+ monetization-ready by itself.

## Intentionally not changed

No product UI, layout, routes, telemetry, Modern Table, glossary, screenshot
tooling, monetization, or generated outputs changed.

## Recommended next step

After this local content slice is packaged, separately assess whether a
range-bucket receipt and mapped Act0 target are justified as a product-behavior
wave.
