# Minimal Live End-to-End Alpha Scenario v1

Status: `PUBLISHED FOR ADMISSION`

## Baseline and route profiles

- Baseline: `0081d80851be81c324662b034dc6aa08e2a4c128` (`origin/main`).
- Profile A, fresh install: canonical placement/Welcome reaches Learn at `0/9`;
  `what_poker_is` / First Table Guide is current and Action remains locked.
  The first lesson advances truthfully without sharing the Profile B fixture.
- Profile B, unlocked Action recovery: persisted production-equivalent
  completion of `what_poker_is`, `what_poker_is_content`,
  `cards_ranks_suits`, and `your_first_hand`; no debug menu, release bypass,
  or intermediate Action state.

## Selected scenario and owner matrix

| Concern | Production owner / proof |
| --- | --- |
| Boot, Home/Learn, progression and persistence | `app_root.dart`, `Act0ShellPreviewScreenV1`, `alpha_journey_progression_truth_v1_test.dart` |
| Theory, decision, causal feedback, repair and recheck | `Act0LessonRunnerShellV1`, `act0_causal_feedback_contract_v1.dart`, same-signal `w1_action_words_check_v1` |
| Exact scenario | `fold_check_call_raise`: `actions_theory` -> wrong `fold` on `actions_check_drill`; `missed_action_read`; repair/recheck target `actions_check_drill` |
| Receipt and payoff | `act0_learning_receipt_v1.dart`, `act0_learning_run_payoff_v1.dart`, `Act0ActionSessionPayoffPolicyV1` |
| Personalized next step / exit | `act0_personalized_return_reason_v1.dart`, `Act0ShellPreviewScreenV1`; explicit Learn-to-Home closes once |
| Telemetry | `Act0TelemetrySinkV1`, `act0_telemetry_sink_v1_test.dart` |
| Existing Alpha QA | `tools/run_alpha_journey_qa_v1.sh`, `tools/validate_alpha_journey_contract_v1.py` |

The original wrong choice creates exactly one repair debt. The repair CTA opens
the bound same-signal target; successful repair and a later valid recheck give
the `recoveredSuccess` payoff. The receipt ladder remains claim-safe and the
next-step owner recomputes from the same evidence rather than persisting copy.
Back returns to Learn without closing the run; explicit Home exits it once.
Restart discards the local run lifecycle and cannot emit a stale payoff.

## Deterministic evidence

- Fresh-profile contract and five fresh-route/progression tests: PASS.
- Visible-control Profile B replay: PASS. It records an ordered single-session
  trace of decision/correctness/error/time, feedback, repair start/completion,
  recheck start/result, recovered payoff, session exit, and next-step
  projection, with no duplicate bound lifecycle events.
- Focused owner suite: causal feedback/receipt, action personalization, session
  payoff, next-step policy, telemetry, shell route, and canonical Action raster
  capture: PASS (57 completed assertions before the local aggregate runner's
  own foreground-control timeout; the individual raster capture passed).
- `fast_loop_world1_v1.sh`: PASS, including `flutter analyze`. The longer R5
  wrapper did not complete because its foreground Flutter workers outlived this
  terminal control plane; this is tooling evidence, not a product failure.
  `graphify hook-check` and final diff checks run after this documentation-only
  reconciliation.

Compact (`375x812`), tall (`390x844`), and large (`430x932`) Action raster
owners are present and use `ensureVisible` before every visible-control tap;
the canonical raster capture has no required-CTA failure.

## Computer Use

Simulator `iPhone 17 Pro Max — iOS 26.2` booted, but Sharky was not installed
and the local Flutter control plane retained overlapping long-running test
workers after aggregate validation. No learner state was injected and no second
GUI retry was attempted. Real-GUI admission is therefore **pending**, not
claimed; deterministic capability proof remains valid.

## Change matrix and non-claims

| File | Change |
| --- | --- |
| `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` | Refresh baseline, two-profile truth, selected scenario, and GUI status. |
| `docs/_reviews/minimal_live_e2e_alpha_scenario_v1.md` | This bounded evidence and admission record. |

No product code changed: the named integration gap was already closed on the
specified baseline by PR #29 and PR #30. This does not claim Human learning
effectiveness, Human Novice Proof, all W1-W12 E2E routes, full telemetry
closure, Alpha admission, release readiness, or visual/mascot completion.
