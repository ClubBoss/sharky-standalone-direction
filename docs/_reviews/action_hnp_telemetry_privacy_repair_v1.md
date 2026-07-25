---
status: "LOCAL-ONLY REPAIR RECORD"
status_source: "derived"
baseline: "6d758c702616"
generated_by: "docs_frontmatter_v1"
---

# Action HNP Telemetry Privacy Repair v1

Status: LOCAL-ONLY REPAIR RECORD
Baseline: `6d758c7026163cddb6445f0618336cf75da76d27`
Product candidate: `901eb2cca17d83a6253e956d81d0261123c79fba`

## Scope and root cause

This record closes only `PH-CX-001 — CONFIRMED_ACTIONABLE_HNP_BLOCKER`.
No visual, content, pedagogy, route, dependency, remote, or broader telemetry
change is included.

The canonical Action recovery owner,
`_advanceActionSequenceReviewV1` in
`lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`, emitted the
learner-facing context identity `w1_action_words_no_bet_read_v1` as both
`tableContextKey` and `table_context_key` in Action recovery lifecycle payloads.
`Act0HnpTelemetrySinkV1` writes the recorded event fields verbatim to physical
local JSONL, so that source-owned projection reached HNP output.

## Permitted physical HNP projection

Physical HNP JSONL retains controlled event names, route/task IDs, user choice,
correctness/classification, canonical error type, bounded decision-time bucket,
repair/recheck/payoff/recommendation lifecycle, explicit exit, and local session
correlation. It excludes learner-facing copy, table/context labels and
copy-derived slugs, raw board/private-card payloads, identity/account/network
fields, and exact decision milliseconds.

The repair removes the forbidden table/context projection at the sole canonical
Action lifecycle owner while retaining the internal `tableContextKey` sequence
contract for route logic and compatibility.

## Owners and focused coverage

| Owner | Role |
| --- | --- |
| `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` | Canonical Action repair/recheck/completion lifecycle payload projection |
| `lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart` | Physical bounded local HNP JSONL collector; unchanged serialization owner |
| `test/ui_v2/act0_telemetry_sink_v1_test.dart` | Canonical Profile B Action wrong-choice → repair → recheck → recovered payoff → one-exit physical JSONL trace |
| `test/ui_v2/act0_hnp_telemetry_collector_v1_test.dart` | Local physical collector JSONL allowlist survival check |

## Pre-fix reproduction

The canonical unlocked Profile B Action replay ran from the pinned baseline:
wrong `fold` on `actions_check_drill` → causal feedback → repair `check` →
recheck `check` → recovered payoff → one explicit exit.

- Trace: local-only `/private/tmp/sharky-action-hnp-telemetry-privacy-v1-evidence/pre_fix_action_trace.json`
- Events: 49
- SHA-256: `673d1314706c4d5bc64450e09438a0b1e6eaa339b64b71d0be69203124ae3014`
- Forbidden lifecycle events: `action_sequence_repair_entry`, `recheck_started`,
  `action_sequence_recheck_entry`, `recheck_result`, and
  `action_sequence_completed`.
- The explicit pre-fix privacy assertion exited `1`, as required: the trace
  contained the forbidden field/value. The physical collector's current
  behavior was one-to-one serialization of recorded event fields.

## Post-fix physical HNP evidence

The same canonical Profile B replay used `Act0HnpTelemetrySinkV1` with its
physical JSONL file-store path:

- Trace: local-only `/private/tmp/sharky-action-hnp-telemetry-privacy-v1-evidence/post_fix_profile_b_action_hnp.jsonl`
- Events: 49; every line parses; final byte is newline (`0a`).
- SHA-256: `1e182aef4884b5edc55b731b61d81aeae8da510878c8f73fe0135a9feb8e6a04`
- Lifecycle retains wrong choice, `misread_action_legality`, repair/recheck,
  recovered payoff, and exactly one `session_exited`.
- Timing values are bounded (`under_3s`, `unknown`); no exact millisecond field
  is present.
- Forbidden scan count is zero for `tableContextKey`, `table_context_key`, and
  `w1_action_words_no_bet_read_v1`; active legacy
  `missed_action_read` count is zero.

## Validation

All observed exit codes are zero unless stated otherwise:

1. Pre-fix canonical replay: `0`; explicit privacy assertion: `1` (expected
   failing demonstration).
2. Action telemetry sink + HNP collector + canonical progression + Action
   sequence + payoff suites: `0` (38 tests).
3. `flutter analyze`: `0` (`No issues found`).
4. `./tools/fast_loop_world1_v1.sh`: `0` (`FAST LOOP PASS`).
5. `graphify hook-check`: `0`.
6. `git diff --check` and `git diff --cached --check`: `0`.

## Non-claims and deferred findings

This local repair does not claim real-GUI/Human Novice Proof, fresh-install
Action access, release readiness, external analytics, or re-adjudication of
Claude or Antigravity findings. `PH-CX-001` is the only finding reconsidered;
all other pre-Human findings remain deferred and untouched.

Targeted recheck result:

- `PH-CX-001 — CLOSED_FIXED`
- `PREHUMAN_TRIPLE_CHALLENGE — CLEAR AFTER TARGETED REPAIR`
