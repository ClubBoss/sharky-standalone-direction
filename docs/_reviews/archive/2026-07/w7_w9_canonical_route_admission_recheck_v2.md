---
status: "undeclared"
status_source: "absent"
doc_date: "2026-07-08"
baseline: "7425a17a2862"
generated_by: "docs_frontmatter_v1"
---

# W7-W9 Canonical Route Admission Recheck v2

Date: 2026-07-08

Integrated main HEAD: `7425a17a2862e72fc63ea403d20732c028cbfb64`

Overall verdict: `w7_w9_requires_separate_payoff_and_repair_waves`

## 1. Executive Verdict

The W8/W9 canonical identity conflict from v1 is closed on integrated `main`.
W8 now resolves to `Stack Depth And Risk`; W9 now resolves to `Tournament
Pressure`. Retired W8 draw ownership and retired W9 price / pot-odds ownership
no longer participate in active campaign route ownership or hidden evidence
ownership for canonical W8/W9.

W7-W9 are not yet admitted for deep content-quality audit. The remaining
blockers are bounded and separate:

- completion payoff: W7-W9 do not have world-specific completion payoff owner
  coverage;
- same-signal repair/recheck: W7-W9 have generic Act0 repair/recheck mechanics
  and hidden evidence owners, but no proven world-specific same-signal Practice
  launch / recheck closure contract.

No payoff or repair/recheck implementation was performed in this recheck.

## 2. Integrated Repository Proof

Preflight expected state matched exactly:

- original `main`: `2ed4c2755e7280f8fc0c167423ad6cdb828ff313`
- original `origin/main`: `2ed4c2755e7280f8fc0c167423ad6cdb828ff313`
- source branch: `codex/w8-w9-canonical-identity-reconciliation-v1`
- source branch HEAD: `7425a17a2862e72fc63ea403d20732c028cbfb64`
- source remote HEAD:
  `origin/codex/w8-w9-canonical-identity-reconciliation-v1` at
  `7425a17a2862e72fc63ea403d20732c028cbfb64`
- source ahead/behind remote: `0/0`
- initial worktree: clean
- source range: one commit,
  `7425a17a fix: reconcile W8 W9 canonical identity ownership`
- source branch was a clean descendant of the expected base.

Integrated commit:

- `7425a17a2862e72fc63ea403d20732c028cbfb64`

Exact source-branch changed files:

- `docs/_reviews/w8_w9_canonical_identity_ownership_reconciliation_v1.md`
- `lib/campaign/campaign_pack_registry_v1.dart`
- `lib/personalization/skill_tags_v1.dart`
- `lib/ui_v2/act0_shell/act0_w8_draws_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_w8_stack_depth_hidden_evidence_harness_v1.dart`
- `lib/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_w9_price_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_evidence_harness_v1.dart`
- `lib/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart`
- `test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart`
- `test/guards/targeted_same_signal_transfer_repairs_contract_test.dart`
- `test/guards/w1_w12_poker_correctness_review_contract_test.dart`
- `test/guards/w7_w12_first_use_jargon_contract_test.dart`
- `test/guards/w7_w12_table_context_readiness_audit_contract_test.dart`
- `test/guards/w8_route_admission_depth_gate_contract_test.dart`
- `test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart`
- `test/guards/w9_route_admission_depth_gate_contract_test.dart`
- `test/personalization/skill_tags_v1_test.dart`
- `test/ui_v2/act0_w8_hidden_evidence_consumption_internal_harness_v1_test.dart`
- `test/ui_v2/act0_w8_internal_world_source_template_v1_test.dart`
- `test/ui_v2/act0_w9_w10_hidden_evidence_consumption_internal_harness_v1_test.dart`
- `test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart`
- `tools/act0_real_text_surface_capture_v1.dart`

Integration used `git merge --ff-only` and then a normal `git push origin main`.
After push, local `main` and `origin/main` both resolved to
`7425a17a2862e72fc63ea403d20732c028cbfb64` with ahead/behind `0/0`.
The source branch was not deleted and still resolved locally and remotely to
`7425a17a2862e72fc63ea403d20732c028cbfb64`.

## 3. Reconciliation With The v1 Audit

v1 verdict:
`w7_w9_canonical_route_blocked_missing_or_conflicting_ownership`.

Closed by integration:

- `W7W9-CRA-002`: W8 identity/source ownership conflict is closed.
- `W7W9-CRA-003`: W9 identity/source ownership conflict is closed.

Still open after integration:

- `W7W9-CRA-001`: W7-W9 completion payoff remains absent.
- `W7W9-CRA-004`: W7-W9 normal-route same-signal repair/recheck remains
  unproven.

Updated admission status:

- route reachability: present;
- semantic identity: closed for W7, W8, W9;
- completion payoff: blocked;
- same-signal repair/recheck: blocked.

## 4. Identity-Ownership Closure Proof

Canonical truth:

- `lib/canonical/canonical_truth_map_v1.dart` maps `world_7` to
  `Visible Cards Change Ranges` and marks `Range Thinking Lite` retired.
- `lib/canonical/canonical_truth_map_v1.dart` maps `world_8` to
  `Stack Depth And Risk` and marks `Draws as W8 primary route` retired.
- `lib/canonical/canonical_truth_map_v1.dart` maps `world_9` to
  `Tournament Pressure` and marks `Price and Pot Odds as W9 primary route`
  retired.

Act0 state:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` maps `world_7` to
  `Visible Cards Change Ranges`.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` maps `world_8` to
  `Stack Depth And Risk`.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` maps `world_9` to
  `Tournament Pressure`.

Campaign and progression:

- `lib/campaign/campaign_pack_registry_v1.dart` maps
  `world7_spine_campaign_v1` to visible-card range packs.
- `lib/campaign/campaign_pack_registry_v1.dart` maps
  `world8_spine_campaign_v1` and W8 followups to stack-depth risk packs.
- `lib/campaign/campaign_pack_registry_v1.dart` maps
  `world9_spine_campaign_v1` and W9 followups to tournament-pressure packs.
- `lib/services/progress_service.dart` still uses stable route IDs and routes
  W6 -> W7 -> W8 -> W9 -> W10 by completion / calibration state.

Hidden owners:

- W7 hidden owner:
  `Act0W7VisibleAceHiddenRuntimeSessionOwnerV1`.
- W8 hidden owner:
  `Act0W8StackDepthHiddenRuntimeSessionOwnerV1`, with repair focus ids under
  `w8_stack_depth_*`.
- W9 hidden owner:
  `Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1`, with repair focus ids
  under `w9_tournament_pressure_*`.

Deterministic guard:

- `test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart`
  locks W8/W9 canonical truth, active campaign route copy, hidden owner concept
  families, and ProgressService entry into canonical W8 then canonical W9.

Conclusion: no retired W8 draw meaning or retired W9 price / pot-odds meaning
contributes to active W8/W9 admission, progression, campaign completion,
screen-review tooling, hidden telemetry evidence, or closure evidence.

## 5. W7 Remaining Contracts

Identity:

- active identity: `Visible Cards Change Ranges`;
- active Act0 owner: `act0_shell_state_v1.dart`;
- active campaign owner: `_w7VisibleRangeCampaignPackV1`;
- hidden owner: `Act0W7VisibleAceHiddenRuntimeSessionOwnerV1`;
- retired meaning `Range Thinking Lite` is not the active W7 label.

Completion payoff:

- exact completion owner:
  `Act0ShellPreviewScreenV1._maybeShowBlockCompletionSummary`;
- exact payoff owner:
  `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff`;
- world-specific payoff exists: no;
- next-step copy owner: `Act0BlockCompletionSummaryV1` generic next-world copy;
- next-world routing owner:
  `Act0ShellPreviewScreenV1._advanceAfterTask` plus ProgressService W7 -> W8;
- deterministic test status:
  `test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart` asserts
  `World 7 is not yet covered by any completion payoff`.

Same-signal repair/recheck:

- wrong/suboptimal source task owner: Act0 runner option result path;
- error/missed-signal attribution owner:
  `Act0RepairIntentV1` / `Act0ShellPreviewScreenV1`;
- repair target owner: generic Act0 repair target mapping;
- classification: same-signal when mapped, exact replay fallback when no mapped
  launchable target exists;
- Practice launchability: generic Practice queue exists, but the W7 hidden owner
  exposes `practiceLaunchRequest => null`;
- recheck completion: generic `recheck_completed` telemetry exists;
- progression non-interference: generic repair lifecycle tests cover intent
  clearing / retention without changing route progression;
- deterministic test status: generic repair lifecycle passes, but no W7-specific
  same-signal recheck closure test exists.

Disposition: `canonical_route_admitted_with_bounded_defects`.

## 6. W8 Remaining Contracts

Identity:

- active identity: `Stack Depth And Risk`;
- active Act0 owner: `act0_shell_state_v1.dart`;
- active campaign owner: `_w8StackDepthRiskCampaignPackV1`;
- hidden owner: `Act0W8StackDepthHiddenRuntimeSessionOwnerV1`;
- retired draw ownership is excluded by source and guard coverage.

Completion payoff:

- exact completion owner:
  `Act0ShellPreviewScreenV1._maybeShowBlockCompletionSummary`;
- exact payoff owner:
  `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff`;
- world-specific payoff exists: no;
- next-step copy owner: `Act0BlockCompletionSummaryV1` generic next-world copy;
- next-world routing owner:
  `Act0ShellPreviewScreenV1._advanceAfterTask` plus ProgressService W8 -> W9;
- deterministic test status: W2-W6 payoff tests intentionally do not cover W8.

Same-signal repair/recheck:

- wrong/suboptimal source task owner: Act0 runner option result path and W8
  hidden task specs;
- error/missed-signal attribution owner:
  W8 hidden specs emit `w8_stack_depth_*` repair focus ids and generic Act0
  repair intent records missed signals;
- repair target owner: generic Act0 repair target mapping;
- classification: same-signal when mapped, exact replay fallback when no mapped
  launchable target exists;
- Practice launchability: generic Practice queue exists, but W8 hidden owner and
  harness expose `practiceLaunchRequest => null`;
- recheck completion: generic `recheck_completed` telemetry exists;
- progression non-interference: generic repair lifecycle tests cover intent
  clearing / retention without changing route progression;
- deterministic test status: W8 hidden evidence tests pass, but no W8-specific
  same-signal Practice/recheck closure test exists.

Disposition: `canonical_route_admitted_with_bounded_defects`.

## 7. W9 Remaining Contracts

Identity:

- active identity: `Tournament Pressure`;
- active Act0 owner: `act0_shell_state_v1.dart`;
- active campaign owner: `_w9TournamentPressureCampaignPackV1`;
- hidden owner: `Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1`;
- retired price / pot-odds ownership is excluded by source and guard coverage.

Completion payoff:

- exact completion owner:
  `Act0ShellPreviewScreenV1._maybeShowBlockCompletionSummary`;
- exact payoff owner:
  `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff`;
- world-specific payoff exists: no;
- next-step copy owner: `Act0BlockCompletionSummaryV1` generic next-world copy;
- next-world routing owner:
  `Act0ShellPreviewScreenV1._advanceAfterTask` plus ProgressService W9 -> W10;
- deterministic test status: W2-W6 payoff tests intentionally do not cover W9.

Same-signal repair/recheck:

- wrong/suboptimal source task owner: Act0 runner option result path and W9
  hidden task specs;
- error/missed-signal attribution owner:
  W9 hidden specs emit `w9_tournament_pressure_*` repair focus ids and generic
  Act0 repair intent records missed signals;
- repair target owner: generic Act0 repair target mapping;
- classification: same-signal when mapped, exact replay fallback when no mapped
  launchable target exists;
- Practice launchability: generic Practice queue exists, but W9 hidden owner and
  harness expose `practiceLaunchRequest => null`;
- recheck completion: generic `recheck_completed` telemetry exists;
- progression non-interference: generic repair lifecycle tests cover intent
  clearing / retention without changing route progression;
- deterministic test status: W9 hidden evidence tests pass, but no W9-specific
  same-signal Practice/recheck closure test exists.

Disposition: `canonical_route_admitted_with_bounded_defects`.

## 8. Completion-Payoff Matrix

| World | Completion owner | Payoff owner | World-specific payoff? | Next-step copy owner | Next-world routing owner | Deterministic status |
|---|---|---|---:|---|---|---|
| W7 | `Act0ShellPreviewScreenV1._maybeShowBlockCompletionSummary` | `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff` | no | generic `Act0BlockCompletionSummaryV1` copy | Act0 next selectable world; ProgressService `world8_spine_campaign_v1` | explicit negative test |
| W8 | `Act0ShellPreviewScreenV1._maybeShowBlockCompletionSummary` | `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff` | no | generic `Act0BlockCompletionSummaryV1` copy | Act0 next selectable world; ProgressService `world9_spine_campaign_v1` | missing positive test |
| W9 | `Act0ShellPreviewScreenV1._maybeShowBlockCompletionSummary` | `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff` | no | generic `Act0BlockCompletionSummaryV1` copy | Act0 next selectable world; ProgressService `world10_spine_campaign_v1` | missing positive test |

Blocking fact: `hasWorldCompletionPayoff` is true only for ordinary worlds 2-6
with sequential next-world truth. The code comment explicitly says World 7+
payoff remains deferred.

## 9. Same-Signal Repair/Recheck Matrix

| World | Source task owner | Error attribution | Repair target owner | Classification | Practice launchability | Recheck completion | Telemetry | Progression non-interference | Deterministic status |
|---|---|---|---|---|---|---|---|---|---|
| W7 | Act0 runner options; W7 hidden specs | generic `Act0RepairIntentV1`; W7 `repairFocusId` specs | generic Act0 repair target mapping | generic same-signal or exact replay | hidden owner `null`; generic Practice queue only | generic recheck exists | generic repair/recheck telemetry exists | generic lifecycle tests | W7-specific closure missing |
| W8 | Act0 runner options; W8 stack-depth hidden specs | generic `Act0RepairIntentV1`; `w8_stack_depth_*` specs | generic Act0 repair target mapping | generic same-signal or exact replay | hidden owner `null`; generic Practice queue only | generic recheck exists | generic repair/recheck telemetry exists | generic lifecycle tests | W8-specific closure missing |
| W9 | Act0 runner options; W9 tournament-pressure hidden specs | generic `Act0RepairIntentV1`; `w9_tournament_pressure_*` specs | generic Act0 repair target mapping | generic same-signal or exact replay | hidden owner `null`; generic Practice queue only | generic recheck exists | generic repair/recheck telemetry exists | generic lifecycle tests | W9-specific closure missing |

Generic Act0 tests prove repair lifecycle, exact replay fallback, successful
Practice queue clearing, failed repair retention, and `recheck_completed`
telemetry. They do not prove W7-W9 world-specific same-signal closure.

## 10. Transition Matrix

| Transition | Reachability | Semantic identity | Completion payoff | Repair closure |
|---|---|---|---|---|
| W6 -> W7 | ProgressService routes to `world7_spine_campaign_v1`; Act0 can make next world selectable | W7 is visible-card range narrowing | W7 payoff absent after completion | W7-specific same-signal recheck absent |
| W7 -> W8 | ProgressService routes to `world8_spine_campaign_v1`; Act0 can make next world selectable | W8 is Stack Depth And Risk | W8 payoff absent after completion | W8-specific same-signal recheck absent |
| W8 -> W9 | ProgressService routes to `world9_spine_campaign_v1`; Act0 can make next world selectable | W9 is Tournament Pressure | W9 payoff absent after completion | W9-specific same-signal recheck absent |
| W9 -> W10 | ProgressService routes to `world10_spine_campaign_v1`; Act0 can make next world selectable | W10 route remains separate and reachable | W9 payoff absent before transition | W9-specific same-signal recheck absent |

Generic reachability is not treated as complete admission.

## 11. Remaining Defect Ledger

ID: `W7W9-CRA-001`

- seam: W7-W9 completion payoff.
- severity: P1.
- status: open.
- class: missing world-specific completion payoff.
- exact owner:
  `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff`.
- evidence:
  `hasWorldCompletionPayoff` only covers ordinary World 2-6 completion;
  `test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart` explicitly asserts
  World 7 has no completion payoff.
- learner impact:
  a learner can complete W7-W9 without world-specific payoff and next-step
  copy.
- minimum bounded repair:
  add W7-W9 payoff metadata, render states, and tests for canonical identities
  and next-world copy.
- required validation:
  focused W7-W9 payoff tests, Act0 telemetry tests, route transition tests,
  `flutter analyze`, `git diff --check`, `graphify hook-check`.

ID: `W7W9-CRA-004`

- seam: W7-W9 same-signal repair/recheck.
- severity: P1.
- status: open.
- class: generic repair receipt without W7-W9 same-signal Practice/recheck
  closure.
- exact owner:
  `Act0RepairIntentV1`, `Act0ShellPreviewScreenV1`, and W7-W9 hidden owner
  task specs.
- evidence:
  hidden W7-W9 owners expose `practiceLaunchRequest => null`; generic repair
  lifecycle and recheck telemetry tests pass, but no W7-W9-specific same-signal
  recheck closure test exists.
- learner impact:
  audit cannot prove W7-W9 mistakes produce launchable same-signal repair and a
  completed recheck without falling back to generic route mechanics.
- minimum bounded repair:
  bind W7-W9 canonical source tasks to same-signal repair/recheck target specs
  and prove Practice launch / completion / telemetry / progression
  non-interference.
- required validation:
  W7-W9 same-signal repair/recheck tests, Act0 repair lifecycle tests, telemetry
  tests, route transition tests, `flutter analyze`, `git diff --check`,
  `graphify hook-check`.

Resolved:

- `W7W9-CRA-002`: W8 identity/source ownership conflict.
- `W7W9-CRA-003`: W9 identity/source ownership conflict.

## 12. Per-World Terminal Dispositions

- W7: `canonical_route_admitted_with_bounded_defects`.
- W8: `canonical_route_admitted_with_bounded_defects`.
- W9: `canonical_route_admitted_with_bounded_defects`.

These dispositions mean identity and reachability are reconciled, not that deep
content audit is admitted. The blocking bounded defects remain payoff and
same-signal repair/recheck.

## 13. Next Highest-EV Bounded Implementation Wave

Next admitted action:

`implement_w7_w9_completion_payoff_v1`

Scope:

- add W7/W8/W9 world-specific completion payoff metadata under
  `Act0BlockCompletionSummaryV1`;
- preserve canonical identity labels:
  W7 `Visible Cards Change Ranges`, W8 `Stack Depth And Risk`, W9
  `Tournament Pressure`;
- prove next-world copy for W7 -> W8, W8 -> W9, and W9 -> W10;
- add focused tests for no template tokens, no unsupported claims, and
  deterministic route copy;
- do not implement same-signal repair/recheck in that wave.

Reason:

Completion payoff is the cleaner first closure because it has one known owner,
one current negative test, and one direct learner-facing gap. It also creates
the stable completion surface that the later repair/recheck wave can reference.

## 14. Whether Payoff And Repair May Safely Share One Wave

No. Payoff and repair/recheck should remain separate waves.

Reason:

- payoff is render/copy/next-route closure owned by
  `Act0BlockCompletionSummaryV1`;
- same-signal repair/recheck is source-task mapping, Practice launch,
  telemetry, intent lifecycle, and progression non-interference;
- combining them would mix two P1 contract families and make failures harder to
  classify.

Remaining waves:

1. `implement_w7_w9_completion_payoff_v1`
2. `implement_w7_w9_same_signal_repair_recheck_v1`

## 15. Explicit Non-Claims

- No payoff implementation was performed.
- No repair/recheck implementation was performed.
- No poker answers were changed.
- No W7-W9 content expansion was performed.
- No W6, W10-W12, W13+, Modern Table, monetization, visual, or strategic
  direction work was performed.
- No deep content-quality score is claimed.
- No Human QA, Alpha closure, launch readiness, or release readiness is claimed.
- No broad full-suite cleanup is claimed.
- Known unrelated stale observations remain deferred, including the World 2
  campaign structure contrast-beat observation and archived map sync imports.

## 16. Validation

Source-branch validation before integration:

- `dart format --output=none --set-exit-if-changed <20 changed Dart files>`:
  passed, `Formatted 20 files (0 changed)`.
- `flutter test test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart test/guards/w8_route_admission_depth_gate_contract_test.dart test/guards/w9_route_admission_depth_gate_contract_test.dart test/guards/w7_w12_first_use_jargon_contract_test.dart test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart test/ui_v2/act0_w8_internal_world_source_template_v1_test.dart test/ui_v2/act0_w8_hidden_evidence_consumption_internal_harness_v1_test.dart test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart test/ui_v2/act0_w9_w10_hidden_evidence_consumption_internal_harness_v1_test.dart test/guards/w1_w12_poker_correctness_review_contract_test.dart test/guards/targeted_same_signal_transfer_repairs_contract_test.dart test/guards/w7_w12_table_context_readiness_audit_contract_test.dart test/personalization/skill_tags_v1_test.dart`:
  68 passed.
- `flutter test test/guards/world7_campaign_routing_contract_test.dart test/guards/world8_campaign_routing_contract_test.dart test/guards/world9_campaign_routing_contract_test.dart test/guards/world10_campaign_routing_contract_test.dart test/guards/world11_campaign_routing_contract_test.dart test/guards/world12_campaign_routing_contract_test.dart test/guards/world_campaign_routing_matrix_contract_test.dart test/guards/w7_w10_route_status_alignment_contract_test.dart test/guards/route_w7_w12_screen_review_tooling_contract_test.dart test/guards/w10_route_admission_depth_gate_contract_test.dart test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`:
  39 passed.
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart`:
  90 passed.
- `flutter analyze`: passed, no issues found.
- `git diff --check 2ed4c2755e7280f8fc0c167423ad6cdb828ff313..HEAD`:
  passed.
- `graphify hook-check`: passed.

Post-integration validation on `main`:

- focused W8/W9 identity group: 68 passed.
- W7-W12 routing subset: 39 passed.
- `flutter analyze`: passed, no issues found.
- `git diff --check`: passed.
- `graphify hook-check`: passed.

Failure classifications:

- source validation failures: none.
- post-integration validation failures: none.
- active regression: none observed.
- stale expectations: none in admitted validation cone.
- legacy noncanonical ownership: deferred only for known archived-map
  observation, not reproduced during this recheck.
- environment tooling failure: none.
- blocked evidence gap: W7-W9 payoff and W7-W9 same-signal repair/recheck.

## 17. Token Efficiency Report

- exact_usage: unavailable.
- estimated_total_tokens: 76000.
- estimate_confidence: medium.
- estimated input-context tokens: 56000.
- estimated reasoning/output tokens: 20000.
- estimate basis: mission attachment, memory lookup, targeted source/test/doc
  reads, Graphify output, test logs, integration proof, and artifact drafting.
- files opened:
  - attached mission text;
  - `docs/context/CONTEXT_ROUTER_v1.md`;
  - `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`;
  - `docs/_reviews/w7_w9_canonical_route_ownership_admission_audit_v1.md`;
  - `docs/_reviews/w8_w9_canonical_identity_ownership_reconciliation_v1.md`;
  - `lib/canonical/canonical_truth_map_v1.dart`;
  - `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`;
  - `lib/campaign/campaign_pack_registry_v1.dart`;
  - `lib/services/progress_service.dart`;
  - W7/W8/W9 hidden owner and harness files;
  - `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`;
  - `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`;
  - focused route, payoff, repair, telemetry, and identity test files.
- files read in full:
  - attached mission text;
  - `docs/context/CONTEXT_ROUTER_v1.md`;
  - `docs/_reviews/w8_w9_canonical_identity_ownership_reconciliation_v1.md`.
- targeted searches: 9.
- broad searches: 1 overly broad repair/payoff `rg` over Act0/tests that was
  narrowed afterward.
- Graphify queries: 1 (`W8 W9 canonical identity reconciliation route ownership
  admission ProgressService campaign registry Act0 hidden owners`).
- commands run: 28 before artifact creation.
- tests run:
  - 5 `flutter test` invocations;
  - 304 focused passing test cases across source-branch and integrated-main
    validation invocations.
- generated log lines versus lines inspected:
  test and `rg` commands generated several thousand lines; only pass counts,
  owner snippets, and relevant assertions were inspected.
- largest token sinks:
  focused Flutter test output, campaign registry slices, Act0 shell state
  slices, and one over-broad `rg`.
- repeated investigation:
  low; one broad search was narrowed after truncation.
- avoidable token cost:
  the over-broad repair/payoff `rg` should have been split by owner file first.
- whether another discovery pass is required:
  yes, for the next implementation wave, limited to W7-W9 completion payoff
  owner and tests.
- contracts closed per estimated 10k tokens:
  about 0.65: integration proof, identity closure, transition recheck, payoff
  classification, repair/recheck classification, and next-wave selection.
