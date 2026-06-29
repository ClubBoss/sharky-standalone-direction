# W4 Title/Job Realignment PR2 v1

Branch: `codex/w4-title-job-realignment-pr2-v1`.
Baseline: `5e6f22d4` (`w4_route_title_job_recommends_title_change_later`).

## 1. Verdict

`w4_title_job_realignment_pr2_deferred_runtime_change`

An isolated W4 runtime title change is not safe in this wave. Current W4 source
truth supports Bet Purpose / Price, but active route truth, monetization truth,
Act0 runtime copy, the W4 bridge exporter, the existing bridge fixture, and
focused tests still bind W4 to `Preflop Framework` while W5 owns
`Bet Purpose And Price`.

Recommended next wave: `W4-W6 Route/Content Normalization Plan`.

## 2. Source truth

Focused W4 source remains unchanged:

- `content/worlds/world4/v1/world.md` defines W4 as the first honest mainline
  home for bet purpose and basic price awareness.
- `content/worlds/world4/v1/sessions/index.md` describes bet purpose plus price
  intuition, value/protection/bluff/denial intent, and purpose-price
  checkpoints.
- `test/fixtures/content_factory_mvp/w4_bridge_or_legacy_schema_migration_pilot_v1.json`
  uses `display_world_title: Preflop Framework` because the active route title
  still says W4 is `Preflop Framework`.

The source truth is coherent for Bet Purpose / Price. It is still not honest
canonical proof for current-title W4 `Preflop Framework`.

## 3. Current W4 blocker recap

- W4 route title: `Preflop Framework`.
- W4 source job: Bet Purpose / Price.
- W4 canonical-owned bucket under current title: empty.
- W4 fixture status: bridge-limited only.
- W4 Route Title/Job Realignment Plan v1 rejected a bounded submodule claim and
  selected PR2 to audit whether a minimal title/job contract realignment could
  safely happen.

The PR2 audit finds the change is not isolated enough.

## 4. Title dependency audit

| Dependency | Current W4 truth | PR2 finding |
| --- | --- | --- |
| Route title | `docs/plan/MONETIZATION_SSOT_v1.md` and `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` list W4 as `Preflop Framework` and W5 as Bet Purpose / Price. | This is active launch route truth until a dedicated normalization wave changes it. |
| Progression story | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` defines W4 as `Preflop Framework`, W5 as `Bet Purpose And Price`, and W5's unlock label as `Preflop Framework`. | Renaming W4 alone would create duplicate or contradictory W4/W5 route jobs. |
| Ledger/world metadata | `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md` keeps W4 at `5.3`, bridge-limited, with route/content offset as the primary blocker. | Ledger can document the blocker, but score cannot move without executable route-safe evidence. |
| Fixtures | W4 bridge fixture uses `display_world_title: Preflop Framework`, `source_truth_status: bridge_or_legacy`, and `safe_claim_status: limited_bridge`. | Changing fixture title alone would violate the content schema rule that display title follows active route truth. |
| Validators | Foundation and L2/L3 validators accept the bridge fixture and report W4 as `bridge_or_legacy_limited`. | Validators protect schema posture but do not authorize title changes. |
| Exporter | `tools/content_factory_import_export_mvp_v1.dart` exports W4 bridge samples with `displayWorldTitle: Preflop Framework`. | Exporter title would need to change together with active route truth, not before it. |
| Tests | `test/ui_v2/act0_shell_preview_screen_v1_test.dart` asserts W4 title and W4 preflop-framework coverage; premium-foundation tests assert `W4 - Preflop Framework`. | Runtime rename would require focused test repairs and a product decision about W5 collision. |
| Visible copy | Act0 English and RU copy both identify W4 as preflop framework and W5 as bet purpose/price. | Visible copy change is learner-facing and not safe as a metadata-only edit. |

## 5. Safe realignment options

| Option | Safety | Decision |
| --- | --- | --- |
| Docs-only title/job ownership decision | Safe. | Use this wave. Record that isolated W4 runtime realignment is deferred. |
| Metadata-only route/job label update | Unsafe. | The fixture/exporter title must match active route truth; metadata-only would create schema theater. |
| Runtime route title update | Unsafe in isolation. | W4 rename collides with W5's active title and focused runtime tests. |
| Future title change deferred | Safe. | Requires a dedicated normalization plan that handles W4/W5/W6 title-source cascade. |
| Leave W4 bridge-limited and move to W5 pilot | Not recommended. | W5 has a known route/source offset; moving there repeats the blocker without resolving W4. |

## 6. Implementation decision

Docs-only blocker.

Do not implement a runtime title change, fixture title change, exporter title
change, or canonical fixture in this wave.

Reason:

- Active route truth still says W4 is `Preflop Framework`.
- W5 already owns `Bet Purpose And Price` in active runtime and monetization
  route truth.
- W4 source ownership cannot be made canonical by relabeling W4 alone.
- The safe next step is a route/content normalization plan for the W4-W6 title
  cascade, not an isolated W4 title mutation.

## 7. Changes made, if any

Changed docs/control-plane only:

- created this PR2 review artifact;
- updated the Volume I readiness ledger next action;
- updated the long-horizon route pointer.

No Dart, fixture, exporter, runtime route, visible copy, source content, or test
files were changed.

## 8. Tests / validation

Executed required evidence checks:

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

No focused Flutter test, Dart format, or `flutter analyze` run was required
because no Dart/test/runtime files changed.

## 9. W4 certification impact

W4 remains bridge-limited.

No W4 canonical fixture, technical 8.0 movement, launch coverage claim, Human
QA claim, 9.0 claim, solver/GTO claim, or route-ready evidence is added.

## 10. Ledger impact

Proposed score movement: `+0.0`.

W4 remains `5.3`. This wave reduces decision ambiguity but adds no executable
canonical coverage and no safe runtime title change.

## 11. Route impact

No route, runtime title, Act0 card, display title, W5-W12 state, or
monetization boundary changed.

The active route/title truth remains:

- W4: `Preflop Framework`;
- W5: `Bet Purpose And Price`;
- W4 source job: Bet Purpose / Price;
- W4 certification posture: bridge-limited.

## 12. Active repair queue update

Replace the active next wave:

- completed wave: `W4 Title/Job Realignment PR2`;
- next wave: `W4-W6 Route/Content Normalization Plan`.

That next wave should decide whether the W4-W6 title/source cascade should be
renormalized before any W4, W5, or W6 canonical fixture work continues.

## 13. Evidence DoD status

- W4 foundation validator: pass.
- W4 L2/L3 validator on existing bridge fixture: pass.
- `graphify hook-check`: pass.
- `git diff --check`: pass.
- `git diff --cached --check`: pass.
- direct ASCII / diff-only ASCII: pass.
- trailing whitespace / CRLF / final-newline checks: pass.

No screenshots were taken.

## 14. Anti-theater check

Pass.

This wave does not rename W4 by metadata, does not duplicate W4 and W5 title
jobs, does not count bridge evidence as canonical, and does not use a docs-only
decision as certification. It records the isolated-runtime-change blocker and
routes the next work to a normalization plan before fixture work resumes.
