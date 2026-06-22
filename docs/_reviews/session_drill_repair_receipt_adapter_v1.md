# Session-Drill Repair Receipt Adapter v1

## Scope

Local-only, range-bucket-only receipt provenance for the authored W6 `w6.s01`
session-drill family. This does not create an Act0 repair intent, launch a
repair, or change Review.

## Evidence used

- `docs/_reviews/range_bucket_receipt_mapping_v1.md`
- `content/worlds/world6/v1/sessions/w6.s01/drills/`
- `content/_meta/world_drills_manifest_v1.json`
- `lib/services/drill_contract_v1.dart`
- `lib/services/drill_runtime_adapter_v1.dart`
- Act0 repair-intent and resolver contracts

## Root limitation

The W6 session-drill runtime had deterministic drill ids and evaluator
outcomes, but no repair receipt that preserved a range-bucket miss and an
authored recheck target. Act0 repair receipts could not safely infer that
provenance from their separate runner task catalog.

## Adapter contract

`buildSessionDrillRepairReceiptCandidateV1` accepts a manifest-loaded W6
session drill, evaluator result, and chosen action. It returns a candidate
only when all of these are true:

- source session is `w6.s01`;
- source drill id equals its parsed spec id;
- drill kind is `range_bucket_classifier_v1`;
- evaluator outcome is a real failure, not correct or soft-pass;
- the authored source drill has an explicit target in the six-card family.

The candidate records:

- schema version;
- source world, session, and drill ids;
- `range_bucket_classifier_v1` family id;
- bucket-derived signal id and label;
- chosen and expected actions;
- deterministic target session and drill ids;
- target kind and evaluator error class.

## Implementation

The narrow mapping stays inside the W6 family. Strong and missed drills map to
their authored same-bucket companion; medium and weak drills use exact replay
because no distinct authored companion exists. No target is fabricated.

## Files changed

- `lib/services/session_drill_repair_receipt_adapter_v1.dart`
- `test/services/session_drill_repair_receipt_adapter_v1_test.dart`
- this review note

## Tests and checks

- focused receipt-adapter tests;
- W6 same-signal inventory/runtime test;
- range-bucket evaluator test;
- Act0 repair-intent resolver suite;
- active term scanner;
- formatter, analyzer, diff check, and status.

## Product EV

This establishes honest, deterministic provenance for a future repair loop:
the product can name the actual W6 source drill, bucket signal, and authored
repeat target instead of guessing from an unrelated Act0 task.

## Intentionally not changed

- No Review/recheck mapper wiring.
- No Act0 repair-intent schema, persistence, or telemetry change.
- No UI, route, or session-player behavior.
- No content, manifest, or glossary change.
- No Modern Table or generated-output change.

## Remaining limitation and next step

Candidates are pure adapter output only. The next safe wave can decide whether
to persist these candidates at the session-drill result boundary and expose
them to an existing repair queue without changing Review semantics.
