# Session-Drill Repair Receipt Persistence v1

## Scope

Persist eligible session-drill repair receipt candidates after the existing
session-drill evaluator resolves a learner miss.

This follows the already-landed adapter seam for W6 range-bucket misses. It
does not map those receipts into Act0 Review, recheck routing, UI, routes, or
telemetry.

## Seam changed

- `CanonicalTerminalSessionDrillSurfacedRunnerV1` now calls the persistence
  helper after a failed evaluated drill result.
- `SessionDrillRepairReceiptPersistenceV1` stores adapter-approved receipt
  payloads in local `SharedPreferences`.
- Repeated writes for the same source session and source drill replace the
  existing stored candidate instead of duplicating it.

## Persisted fields

- schema version
- source world/session/drill
- drill family
- missed signal id/label
- chosen action
- expected action
- target session/drill
- target kind
- error class

## Backward compatibility

The loader ignores malformed, legacy, incomplete, or unsupported stored
payloads and returns an empty list instead of throwing.

## What did not change

- No Review or recheck mapper was added.
- No learner-facing UI changed.
- No route changed.
- No telemetry schema changed.
- No Modern Table code changed.
- No content or glossary changed.

## Checks

- Focused persistence tests.
- Existing session-drill repair receipt adapter tests.
- Existing repair intent resolver tests.
- Same-signal inventory/runtime tests.
- Range-bucket evaluator test.
- Term scanner across active session content.
- Flutter analyze.
- Formatting and diff checks.

## Remaining limitation

Stored session-drill repair receipt candidates are durable provenance only.
They are not yet consumed by Review, recheck, or Act0 repair surfaces. That
mapping remains a separate future wave.
