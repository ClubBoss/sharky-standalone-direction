# W1-W6 Schema Migration Pilot v1

## 1. Verdict

`w1_w6_schema_migration_pilot_ready`

The W1 canonical coverage pilot remains valid, and a new W2 bridge_or_legacy
schema migration pilot exports three real W2 source tasks through the content
factory. The combined W1/W2 pilot passes foundation validation and L2/L3
validation while keeping W2 bridge content out of canonical launch coverage.

## 2. Source truth

Focused docs, tools, and tests inspected:

- `AGENTS.md` for active repo, route, graphify, and testing constraints.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` for SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` for Volume I launch scope.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md` for active next-wave state.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md` for world score rules.
- `docs/_reviews/w1_world_coverage_expansion_pilot_v1.md` for accepted W1 coverage proof.
- `docs/_reviews/l2_l3_content_validator_expansion_v1.md` for L2/L3 report and route-admission contracts.
- `docs/_reviews/tiny_content_factory_import_export_mvp_v1.md` for the accepted W2 tiny bridge sample.
- `docs/_reviews/w2_w6_route_content_normalization_v1.md` for bridge_or_legacy route/content truth.
- `docs/_reviews/l2_volume_i_w1_w12_world_coverage_report_v1.md` for W1-W12 coverage classification.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md` and `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md` for required fields and claim-safety rules.
- `tools/content_factory_import_export_mvp_v1.dart`, `tools/content_schema_l2_l3_validator_v1.dart`, and `tools/content_schema_foundation_validator_v1.dart` for executable behavior.
- `test/tools/content_factory_import_export_mvp_v1_test.dart` and `test/tools/content_schema_l2_l3_validator_v1_test.dart` for focused proof.

Focused W2 source tasks inspected and used:

- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_fold_early.json`
- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_call_vs_open.json`
- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_raise_btn.json`

Focused W2 source tasks inspected but not used:

- `content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_fold_vs_open.json`

## 3. Problem statement

W1 coverage proof is not enough for W1-W6 content production because W2-W6
have accepted route/content drift. Their route-facing titles remain stable,
but current source jobs are bridge material rather than final canonical launch
coverage. The migration pipeline must prove it can export W2-W6 source with
explicit route title, content owner, bridge_or_legacy source truth, migration
metadata, and launch-claim limits before broader migration or authoring.

## 4. Pilot decision

- Selected W2-W6 world: W2.
- Selected concept family: `position_btn_vs_early`.
- Selected source tasks: `choose_fold_early`, `choose_call_vs_open`, and `choose_raise_btn`.
- Safety rationale: all three are existing W2 action-choice tasks with the same `intent_v1`, clear `expected.actionId`, and ASCII `why_v1`.
- Bridge_or_legacy handling is executable: the W2 fixture validates, reports metrics, and stays `bridge_or_legacy_limited`.
- Intentionally not built: W3-W6 migration, full W1 migration, broad W1-W6 migration, content authoring, route changes, W7-W12 admission, W13-W36 work, UI, telemetry, monetization, Modern Table, L4 poker correctness, and human QA.

## 5. Migration output summary

### W1 fixture

- Output fixture: `test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json`
- Source files: six real W1 source tasks from `w1.s02` and `w1.s03`.
- `world_id`: `world_1`
- `route_world_id`: `world_1`
- `display_world_title`: `Poker from Zero`
- `content_owner_world_id`: `world_1`
- `source_truth_status`: `migrated`
- `route_gate_status`: `learner_playable`
- `concept_family_id`: `position_action_order`
- `same_signal_group_id`: `w1.position_action_order.first_in_or_facing_pressure`
- `transfer_surface_id`: `first_in_action_order_v1`, `facing_open_pressure_v1`, `multiway_pressure_v1`
- `repair_focus_id`: `position_before_action`
- Validation result: foundation OK; L2/L3 route-ready.
- Claim safety: canonical W1 pilot slice only, not full W1 certification.

### W2 fixture

- Output fixture: `test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json`
- Source files: three real W2 source tasks from `w2.s01`.
- `world_id`: `world_2`
- `route_world_id`: `world_2`
- `display_world_title`: `Hand Discipline`
- `content_owner_world_id`: `world_2`
- `source_truth_status`: `bridge_or_legacy`
- `route_gate_status`: `learner_playable`
- `concept_family_id`: `position_btn_vs_early`
- `same_signal_group_id`: `w2.position_btn_vs_early.bridge_action_default`
- `transfer_surface_id`: `early_position_release_v1`, `facing_open_price_v1`, `late_position_open_v1`
- `repair_focus_id`: `position_price_action_default`
- Validation result: foundation OK; L2/L3 bridge-limited.
- Claim safety: `safe_claim_status: limited_bridge`; `launch_coverage_claimed: false`.

## 6. L2/L3 validation results

Combined W1/W2 validator run:

- Total tasks: 9.
- Coverage_countable tasks: 9.
- `source_truth_status` distribution: W1 `migrated: 6`; W2 `bridge_or_legacy: 3`.
- W1 same-signal count: `w1.position_action_order.first_in_or_facing_pressure: 6`.
- W2 same-signal count: `w2.position_btn_vs_early.bridge_action_default: 3`.
- W1 transfer counts: `first_in_action_order_v1: 2`, `facing_open_pressure_v1: 3`, `multiway_pressure_v1: 1`.
- W2 transfer counts: `early_position_release_v1: 1`, `facing_open_price_v1: 1`, `late_position_open_v1: 1`.
- W1 repair count: `position_before_action: 6`.
- W2 repair count: `position_price_action_default: 3`.
- W1 route admission result: `learner_playable_route_ready`.
- W2 route admission result: `bridge_or_legacy_limited`.
- Bridge canonical coverage prevention: W2 `coverage_ready=false`, and tests block `launch_coverage_claimed: true`.

## 7. Test coverage

- `exports W2 bridge schema migration pilot from real source tasks`: proves deterministic three-task W2 export, normalized route/content fields, source metadata, bridge claim fields, transfer surfaces, repair focus, and source truth.
- `reports W2 schema migration pilot as bridge-limited`: proves W2 metrics are reported while `coverageReady` remains false and route admission stays `bridge_or_legacy_limited`.
- `blocks bridge pilot launch coverage claims`: proves bridge content cannot claim launch coverage.
- Existing W1 tests prove the canonical W1 coverage pilot still exports and validates.
- Existing L2/L3 tests continue to protect W7/W11/W13 negative gates.

## 8. Volume I ledger impact

W2 score changed from `4.5` to `4.7` (`+0.2`).

Evidence: three real W2 source tasks now pass factory export, foundation
validation, and L2/L3 reporting as bridge_or_legacy content with explicit
claim limitation. The delta is conservative because W2 remains bridge-limited
and not canonical launch coverage.

Aggregate proposed movement:

- W1-W12 Volume I Premium Product Readiness: `5.7 -> 5.8`.
- Architecture scalability: `7.9 -> 8.0`.
- Content depth: `4.6 -> 4.7`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

## 9. Route impact

- No active route truth changed.
- No learner-facing title changed.
- No world became playable, locked, or routed differently.
- W7-W10 remain locked_not_learner_playable.
- W11-W12 remain authored_but_not_routed.
- W13-W36 remain post-launch / live expansion / advanced roadmap.
- No monetization, store, public beta, UI, telemetry, or Modern Table work occurred.

## 10. Active repair queue update

Closed:

- W1-W6 Schema Migration Pilot v1.
- W1 canonical positive baseline preserved.
- W2 bridge_or_legacy schema migration proof.

Active:

- W2-W6 Bridge Coverage Expansion.

Must-not-skip:

- Keep W2-W6 migration validator-led.
- Keep bridge_or_legacy content claim-limited until canonical evidence exists.
- Preserve route titles separately from source jobs.
- Run Human QA Protocol before external beta or learning-effect claims.

Deferred:

- New W1-W6 content authoring.
- Full W1 migration.
- W3-W6 migration beyond a future bridge expansion wave.
- W7-W12 opening.
- Monetization.
- Store/public beta.

Blockers:

- W3-W6 have no committed schema migration pilot yet.
- W2 is not canonical launch coverage.
- Human QA and poker correctness review remain unrun.

## 11. Score delta proposal

- Selected W2 world readiness score: `4.5 -> 4.7` (`+0.2`).
- W1-W12 Volume I Premium Product Readiness: `5.7 -> 5.8` (`+0.1`).
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: `5.5 -> 5.6` (`+0.1`).
- Architecture scalability: `7.9 -> 8.0` (`+0.1`).
- Content depth: `4.6 -> 4.7` (`+0.1`).
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

## 12. Next-step recommendation

Recommended actual next step: `W2-W6 Bridge Coverage Expansion`.

Why: W2 proves the bridge_or_legacy path works for a small real source group.
The next bottleneck is extending the same validated bridge discipline to W3-W6
without authoring new content or claiming canonical launch coverage.

Do not recommend broad authoring yet.

## 13. Wave DoD status

- W1 canonical pilot preserved: done.
- One W2-W6 bridge_or_legacy sample selected or blocker documented: done, W2 selected.
- Schema-shaped output committed: done.
- L2/L3 validation passed or blocker documented: passed.
- Bridge launch-claim limitation tested: done.
- No content authored: done.
- No broad migration: done.
- No route changes: done.
- Next step selected: `W2-W6 Bridge Coverage Expansion`.

## 14. Evidence DoD status

Command evidence:

- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: OK; 17 tests passed after red failures for missing W2 export/fixture.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: OK; wrote four fixtures including W2 bridge schema pilot with tasks=3 coverage_countable=3.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json`: OK; W1 route-ready, W2 bridge-limited.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json`: OK; W1 tasks=6, W2 tasks=3.

Final formatting, analysis, graphify, diff, ASCII, whitespace, and CRLF checks
are recorded in the final Codex response for this wave.

## 15. Anti-theater check

Risk moved:

- W2 bridge_or_legacy migration now has a real three-task, validator-backed
  fixture instead of a one-task tiny sample.
- The validator now proves bridge content can report transfer/repair metrics
  while remaining blocked from canonical launch coverage claims.

What did not move:

- W2 did not become canonical launch coverage.
- W3-W6 were not migrated.
- Full W1 migration did not happen.
- W7-W12 route state did not open.
- Human QA, poker correctness review, monetization, and public claims did not happen.

Evidence type:

- Code-backed and test-backed, with a committed deterministic fixture and
  executable validators.

W2-W6 migration readiness:

- This enables W2-W6 Bridge Coverage Expansion. PR2 is still needed for W3-W6
  and for any broader bridge coverage claim.
