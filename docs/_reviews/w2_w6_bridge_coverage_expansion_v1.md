# W2-W6 Bridge Coverage Expansion v1

## 1. Verdict

`w2_w6_bridge_coverage_expansion_ready`

W3, W4, W5, and W6 now each have one small validator-backed
`bridge_or_legacy` schema migration pilot. The pilots use existing source
tasks only, report L2/L3 metrics, and remain blocked from canonical launch
coverage claims.

## 2. Source truth

Focused docs, tools, and tests inspected:

- `AGENTS.md` for active repo, route, graphify, and testing constraints.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` for SSOT hierarchy.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` for Volume I launch scope.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md` for active route state.
- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md` for score rules.
- `docs/_reviews/w1_w6_schema_migration_pilot_v1.md` for the accepted W1/W2 baseline.
- `docs/_reviews/w2_w6_route_content_normalization_v1.md` for W2-W6 bridge route/content truth.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md` and `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md` for required fields and claim-safety rules.
- `tools/content_factory_import_export_mvp_v1.dart`, `tools/content_schema_l2_l3_validator_v1.dart`, and `tools/content_schema_foundation_validator_v1.dart` for executable behavior.
- `test/tools/content_factory_import_export_mvp_v1_test.dart` and `test/tools/content_schema_l2_l3_validator_v1_test.dart` for focused proof.

## 3. Problem statement

The accepted W1-W6 Schema Migration Pilot proved W1 canonical coverage and W2
bridge migration, but W3-W6 still had no committed schema-shaped bridge sample.
That left the route/content normalization plan unproven beyond W2 and made the
next authoring step too risky.

## 4. Scope decision

Included:

- Four new small bridge fixtures: W3, W4, W5, and W6.
- Three existing source tasks per world.
- Factory exports for those fixtures.
- Foundation and L2/L3 validator-backed tests.
- Launch-claim blocking tests for the new bridge fixtures.
- Conservative ledger score movement.

Not included:

- New content authoring.
- Full W1-W6 migration.
- Canonical coverage-ready claims for W2-W6.
- Route changes or W7-W12 opening.
- UI, telemetry, monetization, store, public beta, Modern Table, or screenshots.

## 5. Migration output summary

### W3 fixture

- Output fixture: `test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json`
- Source files:
  - `content/worlds/world3/v1/sessions/w3.s06/drills/d.choose_raise_mixed_context_checkpoint_v1.json`
  - `content/worlds/world3/v1/sessions/w3.s03/drills/d.choose_call_preflop_checkpoint_v1.json`
  - `content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_fold_final_preflop_checkpoint_v1.json`
- `display_world_title`: `Position Thinking`
- `concept_family_id`: `preflop_framework_bridge`
- `same_signal_group_id`: `w3.preflop_framework.bridge_action_default`
- `transfer_surface_id`: `late_position_open_v1`, `facing_open_continue_v1`, `earlier_position_release_v1`
- `repair_focus_id`: `preflop_frame_action_default`
- L2/L3 route admission: `bridge_or_legacy_limited`

### W4 fixture

- Output fixture: `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`
- Source files:
  - `content/worlds/world4/v1/sessions/w4.s10/drills/d.choose_raise_focus.json`
  - `content/worlds/world4/v1/sessions/w4.s10/drills/d.choose_call_focus.json`
  - `content/worlds/world4/v1/sessions/w4.s10/drills/d.choose_fold_focus.json`
- `display_world_title`: `Preflop Framework`
- `concept_family_id`: `bet_purpose_price_bridge`
- `same_signal_group_id`: `w4.bet_purpose_price.bridge_action_default`
- `transfer_surface_id`: `denial_raise_v1`, `control_call_v1`, `release_when_denial_gone_v1`
- `repair_focus_id`: `purpose_price_action_default`
- L2/L3 route admission: `bridge_or_legacy_limited`

### W5 fixture

- Output fixture: `test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json`
- Source files:
  - `content/worlds/world5/v1/sessions/w5.s10/drills/d.classify_texture_synthesis_dry_raise_v1.json`
  - `content/worlds/world5/v1/sessions/w5.s10/drills/d.classify_texture_synthesis_connected_call_v1.json`
  - `content/worlds/world5/v1/sessions/w5.s10/drills/d.classify_texture_synthesis_wet_fold_v1.json`
- `display_world_title`: `Bet Purpose And Price`
- `concept_family_id`: `board_awareness_bridge`
- `same_signal_group_id`: `w5.board_awareness.bridge_texture_action_default`
- `transfer_surface_id`: `dry_texture_pressure_v1`, `connected_texture_control_v1`, `wet_texture_release_v1`
- `repair_focus_id`: `texture_before_action`
- L2/L3 route admission: `bridge_or_legacy_limited`

### W6 fixture

- Output fixture: `test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`
- Source files:
  - `content/worlds/world6/v1/sessions/w6.s10/drills/d.choose_raise_synthesis.json`
  - `content/worlds/world6/v1/sessions/w6.s10/drills/d.choose_call_synthesis.json`
  - `content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_fold_trap.json`
- `display_world_title`: `Board And Draws`
- `concept_family_id`: `range_thinking_bridge`
- `same_signal_group_id`: `w6.range_thinking.bridge_range_action_default`
- `transfer_surface_id`: `range_strength_raise_v1`, `equity_realization_call_v1`, `range_weak_release_v1`
- `repair_focus_id`: `range_before_action`
- L2/L3 route admission: `bridge_or_legacy_limited`

## 6. Factory change

The content factory now exports W3-W6 bridge schema migration pilot fixtures in
addition to the existing W1/W2 samples and pilots.

One import compatibility extension was added: source tasks may provide either
`expected.actionId` or the existing source-owned `expected_action` field. This
is required for W5 board-texture classifier tasks and does not synthesize new
content.

## 7. L2/L3 validation results

The W3-W6 bridge expansion fixtures validate with:

- Total tasks per world: `3`.
- Coverage-countable tasks per world: `3`.
- `source_truth_status`: `bridge_or_legacy`.
- `safe_claim_status`: `limited_bridge`.
- `launch_coverage_claimed`: `false`.
- `coverageReady`: `false`.
- `transferReady`: `true`.
- `repairReady`: `true`.
- Route admission status: `bridge_or_legacy_limited`.

The L2/L3 tests also prove that setting `launch_coverage_claimed: true` on
these bridge fixtures produces route-admission errors for W3, W4, W5, and W6.

## 8. Test coverage

- `exports W3-W6 bridge schema migration pilots from real source tasks`: proves deterministic fixture generation, normalized route/content fields, source truth, transfer surfaces, repair focus, source paths, and correct actions.
- `reports W3-W6 bridge expansion fixtures as bridge-limited`: proves each world reports metrics but remains non-coverage-ready.
- `blocks W3-W6 bridge expansion launch coverage claims`: proves bridge fixtures cannot claim launch coverage.
- Existing W1/W2 tests continue to protect the canonical W1 baseline and W2 bridge pilot.

## 9. Ledger impact

World score movement:

- W3: `4.9 -> 5.1` (`+0.2`)
- W4: `5.1 -> 5.3` (`+0.2`)
- W5: `5.1 -> 5.3` (`+0.2`)
- W6: `4.9 -> 5.1` (`+0.2`)

Aggregate proposed movement:

- W1-W12 Volume I Premium Product Readiness: `5.8 -> 5.9`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: `5.6 -> 5.7`.
- Architecture scalability: `8.0 -> 8.1`.
- Content depth: `4.7 -> 4.8`.
- Learning effect: unchanged at `6.0`.
- Monetization readiness: unchanged at `2.0`.

Reason: this wave reduces W3-W6 migration/tooling and claim-safety risk. It
does not make bridge worlds canonical launch coverage and does not change
route admission.

## 10. Route impact

- No active route truth changed.
- No learner-facing title changed.
- No world became playable, locked, or routed differently.
- W2-W6 remain bridge_or_legacy for these pilots.
- W7-W10 remain locked_not_learner_playable.
- W11-W12 remain authored_but_not_routed.
- W13-W36 remain post-launch / live expansion / advanced roadmap.

## 11. Active repair queue update

Closed:

- W2-W6 Bridge Coverage Expansion v1.
- W3-W6 bridge_or_legacy schema migration proof.
- W3-W6 launch-claim blocking tests.

Active:

- W1-W6 Migration Coverage Consolidation.

Must-not-skip:

- Keep W1-W6 migration validator-led.
- Keep bridge_or_legacy content claim-limited until canonical evidence exists.
- Preserve route titles separately from source jobs.
- Run Human QA Protocol before external beta or learning-effect claims.

Deferred:

- New W1-W6 content authoring.
- Full W1-W6 migration.
- W5-W12 expansion.
- W7-W12 opening.
- Monetization.
- Store/public beta.

## 12. Next-step recommendation

Recommended actual next step: `W1-W6 Migration Coverage Consolidation`.

Why: W1 now has one real validator-backed canonical coverage group, and W2-W6
now each have bridge-limited validator-backed migration pilots. The next
bottleneck is consolidating this into one W1-W6 migration coverage picture and
choosing the smallest next proof without authoring new content or claiming
bridge content as coverage-ready.

## 13. Wave DoD status

- One validator-backed migrated/bridge sample for W3: done.
- One validator-backed migrated/bridge sample for W4: done.
- One validator-backed migrated/bridge sample for W5: done.
- One validator-backed migrated/bridge sample for W6: done.
- L2/L3 bridge-limited checks: done.
- Launch-claim blocking checks: done.
- Existing source tasks only: done.
- No content authoring: done.
- No route changes: done.
- No broad migration: done.
- Conservative score movement: done.

## 14. Evidence DoD status

Command evidence:

- `flutter test test/tools/content_factory_import_export_mvp_v1_test.dart test/tools/content_schema_l2_l3_validator_v1_test.dart`: OK; 20 tests passed after red failures for missing W3-W6 exports and fixtures.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: OK; wrote eight fixtures including W3-W6 bridge schema pilots with `tasks=3` and `coverage_countable=3` each.
- `dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w2_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`: OK; 5 fixtures, 15 tasks, W2-W6 all `coverage_ready=false`, `transfer_ready=true`, `repair_ready=true`, and `route_admission=bridge_or_legacy_limited`.
- `dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w3_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w5_bridge_or_legacy_schema_migration_pilot_v1.json test/fixtures/content_factory_mvp/w6_bridge_or_legacy_schema_migration_pilot_v1.json`: OK; W3-W6 each report `tasks=3`, `coverage_countable=3`, and `migration_sources=3`.
