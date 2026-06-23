# Baseline Failure Ledger v1

Date: 2026-06-23

Origin main: `edaac82f71e217bde8592ef95ef3073cc2424280`

Status: advisory failure ledger, not a skip list.

## Rules

1. A baseline entry needs direct reproduction on clean `origin/main` or a
   source-verified prior clean-main record.
2. A new failure is current-wave suspicious by default, including failures in
   a previously listed test file.
3. Baseline classification expires when the affected area becomes an active
   release gate or a task touches its code, assertions, dependencies, or
   runtime contract.
4. This ledger records investigation state. It never authorizes ignoring a
   regression, weakening a gate, or claiming a failing suite is green.

## Confirmed baseline failures

### Act0 repair-intent lifecycle visible-copy assertion

| Field | Evidence |
| --- | --- |
| Test | `wrong answer stores one deterministic open repair intent` |
| File | `test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart:45` |
| Reproduction command | `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart --reporter compact` |
| Observed behavior | The test finds the open repair intent and its stored fields, then fails because `You missed the no-bet-yet clue.` is not rendered. |
| Clean-main evidence | Reproduced on 2026-06-23 with `HEAD` equal to `origin/main` at `edaac82f71e217bde8592ef95ef3073cc2424280`. |
| Why baseline | The failure occurs with no current-wave source/test changes and on the checked remote main revision. |
| Current impact | Does not block Project Intelligence Layer documentation-only work. It does block any claim that this lifecycle file is fully green. |
| Revisit | Before any Act0 repair lifecycle, feedback/repair copy, visible-reason, or release-gate work; or whenever this suite becomes a required gate. |

Cause and repair are deliberately unclassified. The failure may reflect a
stale copy expectation or a real visible-repair regression; this ledger does
not decide that question.

## Non-baseline by default

Never classify these as baseline without fresh clean-main proof:

- failures in files changed by the current wave;
- route, canonical-entry, or telemetry regressions;
- content validator or term-scanner failures after content changes;
- deterministic screenshot failures after UI or capture-tooling changes;
- Modern Table guard failures after table work;
- failures whose command, test name, or actual/expected output differs from a
  ledger entry.

## Validation guidance

| Change type | Minimum evidence |
| --- | --- |
| Docs/process | `graphify hook-check`, `flutter analyze`, `git diff --check`, status. |
| Product/service | Focused affected tests, analyzer, Graphify hook check, diff/status; use the policy-gated loop when changed-file policy requires it. |
| Content | Relevant content validators and term scanner. |
| UI/capture | Focused tests plus the appropriate deterministic review packet only when UI/capture scope is touched. |

Codex summaries must name the exact failing test, command, observed output,
clean-main evidence, and whether it blocks the current wave. Do not write
"known baseline" without that evidence.

## Open items

- The root cause and intended contract for the lifecycle visible-copy failure
  need a dedicated test/contract repair wave.
- No other baseline failures are admitted by this ledger yet.
- Future reproductions should record the exact remote commit and full command
  before asking for a baseline classification.
