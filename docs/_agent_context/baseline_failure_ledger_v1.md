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

## Personalization Breadth Wave 1 differential — 2026-07-14

| Field | Evidence |
| --- | --- |
| Clean base | `origin/main` at `49d6e71331f694ef8c0595dc0cf74c8e77190a83` in detached worktree `/tmp/sharky-wave1-base-49d6e713`. |
| Candidate | `fd563be70a087acd1c4c34c4f9219184b8cbf593` (`ec657f2f` + `fd563be7`). |
| Identical command | `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart -r expanded` with no retries. |
| Runtime | Flutter `3.35.7`, Dart `3.9.2` in both worktrees. |
| Result | All nine candidate failures also fail on clean base. Base has 15 failures total; six additional baseline layout failures do not reproduce on candidate. |
| Scope decision | The nine candidate failures are unrelated pre-existing telemetry-fixture debt for Personalization Breadth Wave 1. They do not authorize treating the full suite as green. |

| Candidate failure | Base primary signature | Candidate primary signature | Classification |
| --- | --- | --- | --- |
| `Act0 runner emits safe task telemetry without changing answer route` | missing `act0_shell_option_raise` | same | `pre_existing` |
| `Act0 runner emits canonical decision_made payload aliases` | missing `act0_shell_option_raise` | same | `pre_existing` |
| `Act0 runner emits safe incorrect result telemetry` | missing `act0_shell_option_fold` | same | `pre_existing` |
| `W5 structured board context is attributed to decision telemetry` | missing `act0_shell_option_wet` | same | `pre_existing` |
| `representative W1 W3 W4 W5 W6 paths emit attributed decision telemetry` | `Bad state: No element` in `chooseOptionByQualityV1` | same | `pre_existing` |
| `Act0 runner emits one safe feedback_viewed event from the real feedback path` | missing `act0_shell_continue_cta` | same | `pre_existing` |
| `Act0 repair flow emits safe repair_started and repair_completed telemetry` | offscreen feedback CTA, then missing review screen | same primary failure; CTA remains offscreen | `pre_existing` |
| `Act0 feedback telemetry stays non-blocking when sink throws` | missing `act0_shell_continue_cta` | same | `pre_existing` |
| `Action sequence surfaces a traceable deterministic recommendation` | missing `not stable yet` text | same | `pre_existing` |

The changed runner owner is shared by these fixtures, but the current-wave
hunks are limited to exact W3 position classification/seat telemetry and
`isReview` compact-layout handling. The option-control failures occur before
selection in W1/W5 drill setup, and the base reproduces each primary failure.
No current-wave hunk is a causal owner for these failures.
