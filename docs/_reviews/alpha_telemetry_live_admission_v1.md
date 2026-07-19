# Alpha Telemetry Live Admission v1

Status: `PUBLISHED FOR ADMISSION`

## Baseline and scope

- Baseline: `dc52c2264135c78c5ceefdb8f959f2f507484609` (`origin/main`).
- Branch: `codex/alpha-telemetry-live-admission-v1`.
- Profile A remains fresh install -> First Table Guide at `0/9`, with Action
  locked. Profile B is only the canonical persisted production-equivalent
  fixture for completed `what_poker_is`, `what_poker_is_content`,
  `cards_ranks_suits`, and `your_first_hand`; it is not fresh-user access and
  no production progression code was changed.

## Owner and ordered trace

| Lifecycle fact | Canonical event | Owner | Required safe fields | Cardinality / proof |
| --- | --- | --- | --- | --- |
| Route/session entry | `session_start`, `lesson_started` | preview shell | IDs, source surface, session ID | once per launched owner |
| Task/decision | `task_shown`, `user_choice`, `decision_made`, `task_result` | lesson runner | IDs, controlled choice/result/error, timing bucket | once per presentation/answer/result |
| Feedback | `feedback_viewed` | lesson runner | IDs, controlled result/classification | once per feedback presentation |
| Repair | `repair_started`, item lifecycle, `repair_completed` | preview shell | source/target IDs and controlled status | one bound repair attempt |
| Recheck | `recheck_started`, `recheck_result` | preview shell | source/repair/recheck IDs and result | one valid completion |
| Receipt/payoff | receipt and `action_payoff_generated` | receipt/payoff owners | controlled receipt/payoff classification | after valid recheck only |
| Recommendation/exit | next-step selected/opened, `session_exited` | preview shell | controlled mapping and session ID | exit once; Back/rebuild/restart do not duplicate |

Selected Profile B order: `actions_theory` -> wrong `fold` on
`actions_check_drill` (`missed_action_read`) -> same-signal
`w1_action_words_check_v1` repair -> valid recheck -> recovered receipt/payoff
-> truthful next step -> explicit Home exit.

## Implemented telemetry repair

The existing lifecycle instrumentation was complete. The real gap was its
payload projection: generic runner events could include `board_card_ids`, and
feedback/repair/recommendation events could include learner-facing
`tableSignal` text. Both fields are now absent from the local telemetry path.
The focused sink test enforces their absence alongside existing copy/identity
guards. This is a privacy projection repair only; no route, persistence schema,
event vocabulary, progression gate, vendor, network, or release behavior
changed.

## Deterministic proof

- `act0_telemetry_sink_v1_test.dart` and
  `act0_hnp_telemetry_collector_v1_test.dart`: PASS, 26 assertions.
- Earlier in this worktree: the selected ordered Alpha replay, Profile A
  progression truth, and causal receipt suite passed individually.
- HNP collector tests prove opt-in/non-release activation, bounded retention,
  ordered complete JSONL lines, replacement lifecycle, and non-fatal write
  failure.
- `flutter analyze`, `graphify hook-check`, and the policy-gated fast loop:
  PASS. The R5 wrapper is not runnable on this host because it calls Bash 4
  `mapfile`, while the available shell lacks that builtin; this is recorded as
  a local validation-environment blocker, not a passing R5 claim.

## Installed proof and admission disposition

The build used `--dart-define=HNP_TELEMETRY=true` on the booted iPhone 17 Pro
Max (iOS 26.2). A stale local CocoaPods specs cache initially lacked
`Sentry/HybridSDK 8.58.3`; after one `pod repo update`, Xcode reported
concurrent Flutter builds and did not produce `Runner.app/Runner`. Per the
one-retry control-plane breaker, no second GUI attempt was made. Therefore no
app-container JSONL file, GUI walkthrough, or phone acceptance claim exists.

## CI and repository state

Draft PR #32 is open against `main` at commit
`6c3f6a4fa7fa942b837bdc20f045adbf144dcd34`; its remote branch matches local
HEAD. Repository-owned CI is green: Theory/verify, Health, R5 release gate,
and Tier A active/release all passed. Tier B/C/D and L2 are conditional skips.
The external TestSprite pre-check failed and remains non-required.

| File family | Disposition |
| --- | --- |
| `act0_lesson_runner_shell_v1.dart` | Removes raw board-card and visible table-signal projection. |
| `act0_shell_preview_screen_v1.dart` | Removes visible table-signal projection from repair/recommendation events. |
| `act0_telemetry_sink_v1_test.dart` | Guards the forbidden fields and retains controlled street attribution. |
| Telemetry map, route capsule, Alpha reviews | Reconcile current owner, privacy, CI, and GUI-blocked admission truth. |

## Non-claims

No vendor analytics, network export, identity, ML, dashboard, schema migration,
release privacy policy, curriculum change, visual work, Modern Table work, or
Alpha admission is claimed.

Exact status:

`BOUNDED_LEARNING_LOOP_TELEMETRY_V1 — CLOSED_FIXED`

`MINIMAL_E2E_ALPHA_CAPABILITY_V1 — MACHINE_VERIFIED; LIVE_GUI_PROOF_PENDING`

Exact verdict: `ALPHA_ADMISSION_BLOCKED_BY_GUI`.
