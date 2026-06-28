# W2-W6 Route/Content Normalization v1

## 1. Verdict

`w2_w6_normalization_docs_only_ready`

W2-W6 route/content truth is normalized for control-plane and future
schema/factory work without changing runtime routes, learner-facing titles, or
content.

Decision:

- Keep current route-facing titles and world IDs stable.
- Treat current W2-W6 source content as `bridge_or_legacy` until schema/factory
  migration records the route title, source owner, and content job explicitly.
- Use the active route world as `route_world_id`.
- Use the active route title as `display_world_title`.
- Use the current source folder's world as `content_owner_world_id`.
- Use `route_gate_status: learner_playable` only for the active campaign path,
  not as Act0-card selectability.

No PR2 is required for W2-W6 mapping. Implementation/factory work is still
required before launch-grade claims.

## 2. Source Truth

Focused files inspected and why:

- `AGENTS.md`: active repo boundary, Act0 route truth, no archive/donor roots,
  and validation policy.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and
  Act0 shell as canonical learner-facing app truth.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Volume I launch target and
  W13-W36 deferral.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active repair queue,
  W2-W6 normalization handoff, and score context.
- `docs/_reviews/l2_volume_i_w1_w12_world_coverage_report_v1.md`: accepted L2
  baseline and W2-W6 `route_content_drift` classification.
- `docs/_reviews/wave5_3_w1_w6_content_depth_same_signal_coverage_audit_v1.md`:
  W2-W6 route-facing titles, source jobs, inferred coverage, and missing
  schema fields.
- `docs/plan/CONTENT_SCHEMA_FOUNDATION_v1.md`: required `route_world_id`,
  `display_world_title`, `content_owner_world_id`, `source_truth_status`, and
  `route_gate_status` semantics.
- `docs/plan/CONTENT_SCHEMA_VALIDATION_RULES_v1.md`: validation ladder and
  route/content alignment rules.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`: current W2-W6 Act0 titles,
  world IDs, locked card state, and non-selectability.
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`: Learn copy that says
  W1-W6 are available and exposes W2-W4 foundation labels.
- `lib/services/progress_service.dart`: W2-W6 campaign progression path and W6
  terminal gate before W7-W10.
- `lib/campaign/campaign_pack_registry_v1.dart`: W2-W6 campaign/follow-up pack
  registry IDs.
- `content/worlds/world2/v1/world.md` through
  `content/worlds/world6/v1/world.md`: current source content jobs.
- `test/guards/world2_campaign_routing_contract_test.dart` through
  `test/guards/world6_campaign_routing_contract_test.dart`: existing route
  guard ownership that may need updates only if future runtime titles change.

## 3. Problem Statement

The L2 report found that W2-W6 are active campaign-owned but their
route-facing titles and current source-world content jobs drift:

- W2 route title is Hand Discipline; source job is broad table-reading bridge.
- W3 route title is Position Thinking; source job is Preflop Framework.
- W4 route title is Preflop Framework; source job is Bet Purpose and Price.
- W5 route title is Bet Purpose And Price; source job is Board Awareness.
- W6 route title is Board And Draws; source job is Range Thinking.

This blocks honest Volume I launch claims and makes factory migration unsafe
unless route title and source job are stored separately.

## 4. Normalization Decision

This wave resolves W2-W6 mapping via `bridge_or_legacy` source truth.

It does not change any learner-facing title.

It does not change route order, active campaign IDs, Act0 card state,
ProgressService behavior, campaign registry rows, tests, content files,
monetization, telemetry, or UI.

Why no runtime title alignment now:

- The current route-facing labels are already embedded in Act0 cards,
  Learn copy, monetization/top-1 docs, and route guard expectations.
- Renaming route titles would cascade through W7-W10 title sequencing and would
  become a broader curriculum-route decision.
- The safe narrow fix is to teach future schema/factory work to preserve both
  the route title and the source content job.

PR2 is not required for W2-W6 mapping. Future implementation remains required.

## 5. W2-W6 Normalization Matrix

| World | Current route-facing title | Current source content job | Recommended display_world_title | Recommended content_owner_world_id | Recommended source_truth_status | Route gate status | Launch claim safety | Factory migration target | Required follow-up | Change now | Reason |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W2 | Hand Discipline | Broad table-reading bridge: showdown, position, initiative, texture, outs, price | Hand Discipline | world_2 | bridge_or_legacy | learner_playable via campaign path; Act0 card remains locked/non-selectable | Safe to claim only that W2 supports foundation hand-discipline reads; not safe to claim full Hand Discipline mastery | Migrate current world2 source under route_world_id `world_2`, display title `Hand Discipline`, source job `table_reading_bridge`, source_truth_status `bridge_or_legacy` | Tiny factory/import-export proof, then L2/L3 validation | No runtime change | Keeps learner route stable while separating route title from bridge source |
| W3 | Position Thinking | Preflop Framework | Position Thinking | world_3 | bridge_or_legacy | learner_playable via campaign path; Act0 card remains locked/non-selectable | Safe to claim routed bridge practice; not safe to claim complete Position Thinking mastery from current source | Migrate current world3 source under route_world_id `world_3`, display title `Position Thinking`, source job `preflop_framework_bridge`, source_truth_status `bridge_or_legacy` | Tiny factory/import-export proof, then L2/L3 validation | No runtime change | Avoids broad title cascade while preserving source job |
| W4 | Preflop Framework | Bet Purpose and Price | Preflop Framework | world_4 | bridge_or_legacy | learner_playable via campaign path; Act0 card remains locked/non-selectable | Safe to claim routed bridge practice; not safe to claim complete Preflop Framework mastery from current source | Migrate current world4 source under route_world_id `world_4`, display title `Preflop Framework`, source job `bet_purpose_price_bridge`, source_truth_status `bridge_or_legacy` | Tiny factory/import-export proof, then L2/L3 validation | No runtime change | Preserves route order while flagging source offset |
| W5 | Bet Purpose And Price | Board Awareness | Bet Purpose And Price | world_5 | bridge_or_legacy | learner_playable via campaign path; Act0 card remains locked/non-selectable | Safe to claim routed bridge practice; not safe to claim complete Bet Purpose and Price mastery from current source | Migrate current world5 source under route_world_id `world_5`, display title `Bet Purpose And Price`, source job `board_awareness_bridge`, source_truth_status `bridge_or_legacy` | Tiny factory/import-export proof, then L2/L3 validation | No runtime change | Keeps W5 premium boundary stable while preventing false claim |
| W6 | Board And Draws | Range Thinking | Board And Draws | world_6 | bridge_or_legacy | learner_playable via campaign path; terminal before W7-W10 lock | Safe to claim routed bridge practice and W6 terminal; not safe to claim complete Board and Draws mastery from current source | Migrate current world6 source under route_world_id `world_6`, display title `Board And Draws`, source job `range_thinking_bridge`, source_truth_status `bridge_or_legacy` | Tiny factory/import-export proof, then L2/L3 validation | No runtime change | Preserves W6 terminal gate and separates range source from board/draw route claim |

## 6. Volume I World Readiness Ledger Update

Ledger path:

- `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md`

Current W1-W12 score table:

| World | Previous score | Current score | Delta | Main release blocker |
| --- | ---: | ---: | ---: | --- |
| W1 | 6.5 | 6.5 | +0.0 | Active content lacks schema-owned coverage fields and human QA. |
| W2 | 4.3 | 4.4 | +0.1 | Source job is broader than route title. |
| W3 | 4.8 | 4.9 | +0.1 | Source job differs from route title. |
| W4 | 5.0 | 5.1 | +0.1 | Route title and content job are offset. |
| W5 | 5.0 | 5.1 | +0.1 | Route title and content job are offset. |
| W6 | 4.8 | 4.9 | +0.1 | Route title and content job are offset. |
| W7 | 2.8 | 2.8 | +0.0 | Locked route gate. |
| W8 | 2.7 | 2.7 | +0.0 | Locked route gate. |
| W9 | 2.7 | 2.7 | +0.0 | Locked route gate. |
| W10 | 3.0 | 3.0 | +0.0 | Locked route gate and track handoff. |
| W11 | 2.2 | 2.2 | +0.0 | No active route or handoff. |
| W12 | 2.0 | 2.0 | +0.0 | No active route or W11 handoff. |

Scores moved only for W2-W6 because route/content migration posture is now
explicit. Scores did not move for W1 or W7-W12 because no schema coverage,
route admission, correctness, QA, or learner-visible proof changed.

## 7. Claim Safety

W2 can safely claim:

- foundation bridge practice for reading visible table facts before hand
  decisions.

W2 cannot safely claim:

- complete Hand Discipline mastery;
- coverage-ready hand-discipline source truth;
- schema-owned same-signal or transfer readiness.

W3 can safely claim:

- routed bridge practice connected to preflop framework content.

W3 cannot safely claim:

- complete Position Thinking mastery from current source;
- schema-owned preflop transfer readiness.

W4 can safely claim:

- routed bridge practice around bet purpose and price concepts.

W4 cannot safely claim:

- complete Preflop Framework mastery from current source.

W5 can safely claim:

- routed bridge practice around board awareness content.

W5 cannot safely claim:

- complete Bet Purpose and Price mastery from current source.

W6 can safely claim:

- routed bridge practice around range-thinking content and the current W6
  terminal boundary.

W6 cannot safely claim:

- complete Board and Draws mastery from current source;
- any W7 unlock or W7-W12 availability.

For all W2-W6:

- no premium 10/10 claim before schema migration, L2/L3 validation, correctness
  review where applicable, and human QA.

## 8. Factory / Schema Implications

Future factory/schema migration should emit these fields for W2-W6:

- `route_world_id`: the active route world, `world_2` through `world_6`.
- `display_world_title`: the current route-facing title from Act0 route truth.
- `content_owner_world_id`: the source folder's world, `world_2` through
  `world_6`.
- `source_truth_status`: `bridge_or_legacy`.
- `route_gate_status`: `learner_playable` for the campaign path only.

The migrated records should also include an explicit source-job or migration
note so future validators do not infer that route title and content job are the
same thing.

`coverage_ready`, `same_signal_ready`, `transfer_ready`, and `repair_ready`
must remain validator outputs, not author-provided claims.

## 9. Tests / Guards Impact

No tests, code, runtime titles, or guards were changed in this wave.

Existing tests/guards that may need updates later if runtime titles change:

- `test/guards/world2_campaign_routing_contract_test.dart`
- `test/guards/world3_campaign_routing_contract_test.dart`
- `test/guards/world4_campaign_routing_contract_test.dart`
- `test/guards/world5_campaign_routing_contract_test.dart`
- `test/guards/world6_campaign_routing_contract_test.dart`
- Act0 Learn status/title tests that assert W1-W6 route labels.
- Any future L2/L3 content validator tests that compare
  `display_world_title`, `content_owner_world_id`, and source job.

Because this wave is docs-only, Dart format, Flutter analyze, and focused tests
were not required.

## 10. Route Impact

- No W7-W12 opening.
- No W13-W36 launch dependency.
- No monetization, store, public beta, paywall, or entitlement change.
- No broad route change.
- No learner-facing W2-W6 title changed.
- No world became playable, locked, or routed differently.

## 11. Active Repair Queue Update

Closed:

- W7-W10 route leak.
- W1-W6 content-depth audit classification.
- Content Schema Foundation.
- L0 Content Validation Rules.
- L1 Migrated Sample Pilot.
- L2 W1-W12 coverage report classification.
- W2-W6 route/content normalization decision.

Active:

- Tiny Content Factory Import/Export MVP.

Must-not-skip:

- Preserve route title and source job separately in factory/schema output.
- Keep W2-W6 as `bridge_or_legacy` until migrated and validated.
- Do not count filename/inferred coverage as schema-owned coverage.
- Do not author content before factory proof.
- Do not open W7-W12.
- Do not claim W13-W36 at launch.
- Do not make premium/public claims before correctness review and human QA.

Deferred:

- Broad W1-W6 migration.
- New W1-W6 content authoring.
- W7-W12 Admission/Content Lock.
- W7-W12 opening.
- W13-W36 content production.
- Monetization/store/public beta.

Blockers:

- Active content lacks schema-owned coverage fields.
- L2/L3 validators are not implemented.
- W7-W10 remain locked.
- W11-W12 remain authored but not routed.
- Human novice QA and poker correctness review absent.

## 12. Score Delta Proposal

- W1-W12 Volume I Premium Product Readiness: `5.3 -> 5.4`.
- Full W1-W36 Long-Horizon Readiness: unchanged at `3.0`.
- Overall Top-1 Readiness: `5.1 -> 5.2`.
- Architecture scalability: `7.3 -> 7.4`.
- Content depth: unchanged at `4.5`.
- Learning effect: unchanged at `6.0`.

Reason:

- W2-W6 migration-target ambiguity moved.
- No content, route admission, validator level, human QA, correctness review,
  or learner-visible proof moved.

## 13. Next-Step Recommendation

Recommended actual next wave:

`Tiny Content Factory Import/Export MVP`.

Why:

- W2-W6 now have stable route/content metadata targets for migration.
- The next bottleneck is proving the tool can import/export a tiny schema-shaped
  slice while preserving `display_world_title`, `content_owner_world_id`,
  `source_truth_status`, and `route_gate_status`.
- This should happen before broad migration or authoring.

Must not skip:

- Keep the factory proof tiny.
- Do not bulk-migrate W1-W6.
- Do not author new content.
- Do not open W7-W12.
- Do not claim coverage-ready from bridge/legacy content.

## 14. Wave DoD Status

- [x] W2-W6 each mapped.
- [x] Source truth status assigned.
- [x] Display title recommendation assigned.
- [x] Content owner assigned.
- [x] Launch claim safety stated.
- [x] Factory migration target stated.
- [x] Volume I ledger created.
- [x] W1-W12 current world scores assigned.
- [x] World score delta rules documented.
- [x] Next step selected.
- [x] No content authored.
- [x] No broad migration.
- [x] No W7-W12 opened.
- [x] No W13-W36 launch dependency introduced.

## 15. Evidence DoD Status

Commands and results:

- `git status --short --branch`
  - Pre-edit result: branch `codex/l2-volume-i-w1-w12-coverage-report-v1`,
    HEAD `698a17dc2bc064ffdc69d654efc89ffbab54ab98`, with pre-existing
    untracked `output/` folders.
- `git switch -c codex/w2-w6-route-content-normalization-v1`
  - Result: branch created.
- Focused `rg` over authority docs, W2-W6 route/content titles, schema fields,
  route owners, and route guards.
  - Result: confirmed W2-W6 route-facing titles, source jobs, campaign route
    ownership, and zero active content-world schema field hits.
- Focused reads of `content/worlds/world2/v1/world.md` through
  `content/worlds/world6/v1/world.md`.
  - Result: confirmed current source content jobs.
- Focused route reads of Act0 state, Learn copy, and ProgressService.
  - Result: confirmed route titles are stable, W1-W6 campaign path exists, and
    W6 remains terminal before W7-W10.
- `graphify hook-check`
  - Passed with no output.
- `git diff --check`
  - Passed with no output.
- Direct ASCII check on changed markdown files.
  - Passed. `LC_ALL=C grep -n '[^ -~]' ...` returned no matches.
- Direct trailing-whitespace and CRLF check on changed markdown files.
  - Passed with no output.

Dart, Flutter, and screenshots were not run because this wave changed only
markdown control-plane artifacts.

## 16. Anti-Theater Check

What risk actually moved?

- W2-W6 migration-target ambiguity moved. Future factory/schema work now has a
  canonical way to preserve active route title and current source job without
  pretending they are the same.
- W1-W12 score tracking risk moved because the new ledger gives every world a
  conservative score, blocker, delta, and next action.

What did not move?

- Content depth did not move.
- Learner-visible route did not move.
- Factory/import/export proof did not move.
- Validator coverage levels did not move.
- Human QA and poker correctness did not move.

Is this docs-only, code-backed, test-backed, or learner-visible?

- Docs-only. It is not code-backed, test-backed, or learner-visible.

Does this unblock factory/migration or require PR2?

- It unblocks a tiny Content Factory Import/Export MVP. PR2 is not required for
  W2-W6 mapping, but implementation is still required before migration claims.

Did the readiness ledger create real decision value?

- Yes. It prevents future work from treating W7-W12 locked content,
  W11-W12 proof packets, or W2-W6 bridge content as launch-ready simply because
  files exist.
