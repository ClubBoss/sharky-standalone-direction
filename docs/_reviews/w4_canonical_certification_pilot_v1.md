# W4 Canonical Certification Pilot v1

Branch: `codex/w4-canonical-certification-pilot-v1`.
Baseline: `f731226c` (`w3_bounded_8_0_certification_closure_passed`).

## 1. Verdict

`w4_canonical_certification_blocked_by_route_title_gap`

W4 cannot safely enter the W1/W2/W3 canonical certification path in this pilot.
The existing W4 source truth is coherent for bet-purpose and price-intuition
work, but the active route title remains `Preflop Framework`. A canonical W4
fixture under that display title would overclaim the current source job by
metadata.

No W4 canonical fixture was created.

## 2. Source truth

Focused W4 source files checked:

- `content/worlds/world4/v1/world.md`
- `content/worlds/world4/v1/sessions/index.md`
- `content/worlds/world4/v1/sessions/w4.s01/session.md`
- `content/worlds/world4/v1/sessions/w4.s02/session.md`
- `content/worlds/world4/v1/sessions/w4.s03/session.md`
- `content/worlds/world4/v1/sessions/w4.s04/session.md`
- `content/worlds/world4/v1/sessions/w4.s05/session.md`
- `content/worlds/world4/v1/sessions/w4.s06/session.md`
- `content/worlds/world4/v1/sessions/w4.s07/session.md`
- `content/worlds/world4/v1/sessions/w4.s08/session.md`
- `content/worlds/world4/v1/sessions/w4.s09/session.md`
- `content/worlds/world4/v1/sessions/w4.s10/session.md`
- `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`

The source files describe World 4 as the mainline home for bet purpose, basic
price awareness, value, protection, bluff, denial, and controlled reopen work.
That is internally coherent source truth, but it is not an honest canonical
`Preflop Framework` proof while the learner-facing route title remains
unchanged.

## 3. Current W4 state

- Route world: `world_4`.
- Current display title: `Preflop Framework`.
- Current source job: Bet Purpose and Price.
- Existing fixture:
  `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`.
- Existing fixture status: three task bridge pilot with
  `source_truth_status: bridge_or_legacy`,
  `safe_claim_status: limited_bridge`, and
  `launch_coverage_claimed: false`.
- L2/L3 route admission for existing fixture:
  `bridge_or_legacy_limited`.

## 4. Canonicalization decision

Stop. Do not create a canonical W4 fixture in this wave.

Reason:

- The current source can support bet-purpose/price migration later.
- The current route title still says `Preflop Framework`.
- The W2-W6 canonical/bridge decision explicitly warned that W4 must not
  canonicalize current bet-purpose source as Preflop Framework by metadata only.
- The pilot requirement says a W4 canonical fixture must honestly align with
  the W4 learner-facing title/source job and preserve current display title
  unless mismatch is documented and deferred.

The mismatch is now documented and deferred to a W4 source/title ownership
remap wave.

## 5. Migration output summary, if fixture created

No fixture was created.

The minimum safe target was not attempted because the route-title/source-job
blocker appears before task-count or transfer-surface selection:

- no new canonical task IDs;
- no new canonical source-truth status;
- no new `canonical_pilot` claim status;
- no launch coverage claim;
- no exporter or test changes.

## 6. L2/L3 validation results

Existing W4 bridge fixture:

```text
content_schema_l2_l3_validator_v1: fixtures=1 worlds=1 tasks=3 coverage_countable=3
content_schema_l2_l3_validator_v1: world_4 tasks=3 coverage_countable=3 coverage_ready=false transfer_ready=true repair_ready=true route_admission=bridge_or_legacy_limited
content_schema_l2_l3_validator_v1: OK
```

Interpretation:

- The bridge fixture is schema-valid.
- The bridge fixture is not canonical route-ready evidence.
- There is no W4 canonical fixture to validate.

## 7. Test coverage

Executed evidence checks:

```text
dart run tools/content_schema_foundation_validator_v1.dart test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json
content_schema_foundation_validator_v1: test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json tasks=3 coverage_countable=3 migration_sources=3
content_schema_foundation_validator_v1: OK
```

```text
dart run tools/content_schema_l2_l3_validator_v1.dart test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json
content_schema_l2_l3_validator_v1: fixtures=1 worlds=1 tasks=3 coverage_countable=3
content_schema_l2_l3_validator_v1: world_4 tasks=3 coverage_countable=3 coverage_ready=false transfer_ready=true repair_ready=true route_admission=bridge_or_legacy_limited
content_schema_l2_l3_validator_v1: OK
```

No focused Flutter test or Dart format run was required because this wave made
no Dart, test, exporter, or fixture changes.

## 8. W4 certification impact

W4 remains bridge-limited.

Certification impact:

- no W4 canonical pilot;
- no W4 coverage-ready canonical family;
- no W4 technical 8.0 movement;
- no launch claim movement;
- no Human QA, 9.0, solver/GTO, or correctness certification claim.

## 9. Ledger impact

Proposed W4 score movement: `+0.0`.

The pilot produced useful negative evidence, not executable canonical coverage.
The ledger should preserve W4 at `5.3` and update the next required action to
`W4 Source/Title Ownership Remap`.

## 10. Route impact

No route, title, Act0 card, runtime entry, or display-title change was made.

The active route title/source-job conflict is now the next blocker:

- route title: `Preflop Framework`;
- source job: Bet Purpose and Price;
- safe next wave: `W4 Source/Title Ownership Remap`.

## 11. Active repair queue update

Replace the active next wave:

- completed pilot: `W4 Canonical Certification Pilot`;
- next wave: `W4 Source/Title Ownership Remap`.

The next wave should decide whether W4 owns a preflop-framework canonical slice,
whether the bet-purpose/price source belongs under W5, or whether a route-title
realignment is required before any canonical W4 fixture can be honest.

## 12. Evidence DoD status

Fixture/tooling DoD:

- Dart format on touched Dart/test files: not applicable.
- Focused Flutter test: not applicable.
- `dart run tools/content_factory_import_export_mvp_v1.dart`: not applicable.
- W4 L2/L3 validator on canonical fixture: not applicable, no canonical fixture.
- W4 bridge+canonical negative control: not applicable, no canonical fixture.
- W4 foundation validator: pass on existing bridge fixture.
- `flutter analyze`: not applicable.

Always-run DoD:

- `graphify hook-check`: pass.
- `git diff --check`: pass.
- `git diff --cached --check`: pass.
- direct ASCII / diff-only ASCII: pass.
- trailing whitespace / CRLF / final-newline checks: pass.

## 13. Anti-theater check

Pass.

This wave did not turn coherent bet-purpose source into a fake
`Preflop Framework` certification. It preserved bridge/canonical separation,
kept launch coverage disabled, avoided route/title mutation, avoided W5-W12,
and selected a source/title ownership-remap wave instead of fabricating a
canonical fixture.
