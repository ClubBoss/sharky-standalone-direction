# W8/W9 Canonical Identity Ownership Reconciliation v1

Date: 2026-07-08

Branch: `codex/w8-w9-canonical-identity-reconciliation-v1`

Base: `2ed4c2755e7280f8fc0c167423ad6cdb828ff313`

## Verdict

`w8_w9_canonical_identity_reconciled`

W8 and W9 keep their canonical identities:

- W8: `Stack Depth And Risk`
- W9: `Tournament Pressure`

Retired active meanings are no longer active owners for W8/W9:

- W8 retired meaning: draws / draw improvement
- W9 retired meaning: call price / pot odds / price-to-call

## Owner Decision Matrix

| Owner surface | Current role | Decision | Repair |
|---|---:|---|---|
| `ProgressService.getNextSpinePackToRunV1` | Active learner route progression | Keep stable route IDs | `world8_spine_campaign_v1` and `world9_spine_campaign_v1` remain progression IDs, but now resolve to canonical W8/W9 semantics. |
| `campaign_pack_registry_v1.dart` W8 packs | Active campaign content source for W8 route IDs | Replace | Replaced W8 campaign/followup content with stack-depth, all-in pressure, and commitment-risk copy. Removed retired W8 draw helper block from the active registry. |
| `campaign_pack_registry_v1.dart` W9 packs | Active campaign content source for W9 route IDs | Replace | Replaced W9 campaign/followup content with tournament pressure, survival, bubble, ladder, and risk-premium copy. Removed retired W9 price helper block from the active registry. |
| W8 hidden runtime owner | Production library source, test/tool consumed hidden evidence | Replace/rename | Replaced `Act0W8DrawsHidden*` with `Act0W8StackDepthHidden*`; evidence now emits `w8_stack_depth_risk_control`. |
| W9 hidden runtime owner | Production library source, test/tool consumed hidden evidence | Replace/rename | Replaced `Act0W9PriceHidden*` with `Act0W9TournamentPressureHidden*`; evidence now emits `w9_tournament_pressure_risk_premium`. |
| Active screen-review capture tooling | Direct consumer of hidden owner specs | Update | Updated imports, owner dispatch, and human labels to canonical W8/W9 owners. |
| Progress skill tags | Progress metadata consumed from route IDs | Update | W8 now reports stack-depth tags; W9 now reports tournament-pressure tags. |

## Policy Lock

- Canonical Act0 W8 is `Stack Depth And Risk`.
- Canonical Act0 W9 is `Tournament Pressure`.
- No active campaign map resolves canonical W8/W9 route IDs to retired draw/price semantics.
- No active hidden owner emits retired draw/price concept families for canonical W8/W9.
- Stable persistence route IDs were retained; semantic ownership was replaced behind those IDs.
- Hidden evidence run-kind strings remain stable (`w8_hidden_runtime_session_owner_v1`, `w9_hidden_runtime_session_owner_v1`) so historical evidence remains readable while started-by owners are canonical.

## Validation Evidence

Passed:

- `flutter test test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart test/guards/w8_route_admission_depth_gate_contract_test.dart test/guards/w9_route_admission_depth_gate_contract_test.dart test/guards/w7_w12_first_use_jargon_contract_test.dart test/guards/active_route_w7_w12_screen_review_tooling_contract_test.dart test/ui_v2/act0_w8_internal_world_source_template_v1_test.dart test/ui_v2/act0_w8_hidden_evidence_consumption_internal_harness_v1_test.dart test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart test/ui_v2/act0_w9_w10_hidden_evidence_consumption_internal_harness_v1_test.dart test/guards/w1_w12_poker_correctness_review_contract_test.dart test/guards/targeted_same_signal_transfer_repairs_contract_test.dart test/guards/w7_w12_table_context_readiness_audit_contract_test.dart test/personalization/skill_tags_v1_test.dart`
- `flutter test test/guards/world7_campaign_routing_contract_test.dart test/guards/world8_campaign_routing_contract_test.dart test/guards/world9_campaign_routing_contract_test.dart test/guards/world10_campaign_routing_contract_test.dart test/guards/world11_campaign_routing_contract_test.dart test/guards/world12_campaign_routing_contract_test.dart test/guards/world_campaign_routing_matrix_contract_test.dart test/guards/w7_w10_route_status_alignment_contract_test.dart test/guards/route_w7_w12_screen_review_tooling_contract_test.dart test/guards/w10_route_admission_depth_gate_contract_test.dart test/guards/w11_route_admission_transfer_depth_gate_contract_test.dart test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart`

Not repaired in this lane:

- `test/guards/campaign_spine_structure_contract_test.dart` currently reports `Missing contrast beat: world2_spine_campaign_v1`, which is outside W8/W9 ownership.
- `test/guards/world10_followup_map_campaign_runtime_sync_contract_test.dart` imports archived `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, which is absent and not the active Act0 surface.
- `test/guards/world3_to_world9_map_campaign_runtime_sync_contract.dart` was requested with the wrong filename during exploratory broadening; the valid repository file is not part of this W8/W9 repair validation.

Full Flutter suite was not run because the direct campaign/progression/hidden-owner cone was explicit and the attempted broader guard command exposed unrelated stale-test failures outside this mission.
