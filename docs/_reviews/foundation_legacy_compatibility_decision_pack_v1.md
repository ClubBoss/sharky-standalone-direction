# Foundation Legacy Compatibility Decision Pack v1

## 1. Verdict

`keep_legacy_now_adapter_later`

W1-W10 should stay on the current legacy-compatible campaign/session route for
now. The existing route is live, tested, and product-critical. W11's
source-owned Foundation Rep Contract chain should remain the forward format for
new route proof, but W1-W10 should not be migrated until a concrete blocker
requires it.

## 2. Inventory summary

| World | Active route status | Owner / runtime shape | Interaction type | Current guard coverage | Classification |
| --- | --- | --- | --- | --- | --- |
| W1 | Active foundation entry and spine | `campaign_pack_registry_v1.dart`, Act0 packs, World1 runner/adapters, `ProgressService` | seat literacy, action choice, street flow, campaign microtasks | large World1 guard family, campaign registry invariants, route/entry/result tests | `legacy_compatible` |
| W2 | Active campaign continuation | content shelf plus `world2_spine_*` packs, canonical/session-backed campaign launch | table texture / initiative / outs bridge | world2 route/map guards, registry invariants; known contrast-beat baseline residue | `legacy_compatible` |
| W3 | Active campaign continuation | content shelf plus `world3_spine_*` packs, canonical/session-backed campaign launch | preflop / position framework | world3 route guards, runtime truth guards, registry invariants | `legacy_compatible` |
| W4 | Active campaign continuation | content shelf plus `world4_spine_*` packs, canonical/session-backed campaign launch | bet purpose / price | world4 route guards, registry invariants, term scanner coverage for key active terms | `legacy_compatible` |
| W5 | Active campaign continuation | content shelf plus `world5_spine_*` packs, canonical/session-backed campaign launch | board texture / draws / price context | world5 route/runtime guards, registry invariants, content-depth audit notes density gap | `legacy_compatible` |
| W6 | Active campaign continuation | content shelf plus `world6_spine_*` packs, canonical/session-backed campaign launch | range bucket / range-vs-board work | world6 route/runtime guards, range-bucket tests, same-signal drill test, registry invariants | `legacy_compatible` |
| W7 | Active campaign continuation | content shelf plus `world7_spine_*` packs, canonical/session-backed campaign launch | stack depth / SPR | world7 campaign-routing guard, route-truth audit, registry invariants | `legacy_compatible` |
| W8 | Active campaign continuation | content shelf plus `world8_spine_*` packs, canonical/session-backed campaign launch | tournament pressure / ICM / EV | world8 campaign-routing guard, term scanner after glossary safety fix, registry invariants | `legacy_compatible` |
| W9 | Active campaign continuation | content shelf plus `world9_spine_*` packs, canonical/session-backed campaign launch | player tendency / exploit guardrails | world9 campaign-routing guard, term scanner, registry invariants | `legacy_compatible` |
| W10 | Active campaign plus track continuation | content shelf, core pack, Cash/Tournament/Mixed track session roots, `world10_spine_*` packs | player adjustment and track transfer | world10 campaign-routing guard, track/session continuation tests, registry invariants | `legacy_compatible` |

Evidence sources inspected include `lib/campaign/campaign_pack_registry_v1.dart`,
`lib/services/progress_service.dart`, `lib/services/campaign_spine_runner_v1.dart`,
`lib/canonical/canonical_truth_map_v1.dart`, W1-W10 content shelves,
campaign-routing guards, registry invariant guards, the Foundation Campaign Rep
Contract, and recent W7-W12/content-depth audit notes.

## 3. Compatibility analysis

Foundation Rep Contract fields already covered in current legacy-compatible
runtime shape:

- stable pack/session-like owner through pack IDs and content shelf paths;
- visible table/action facts in `MicroTaskStep` fields where the active runner
  needs them: prompt, hint, expected seats, hero seat, street, board, hero
  cards, pot, price, legal actions, and expected action;
- learner prompt and bounded interaction choices through campaign runner data;
- feedback/repair-like learner explanation through consequence, tradeoff,
  context, and insight text;
- route/progression identity through `ProgressService`, canonical truth map,
  campaign pack IDs, and route guards.

Fields absent or not uniformly native:

- explicit `source_ref` per rep;
- explicit `world_id` / `session_id` / `rep_id` tuple per runner beat;
- explicit `target_skill_id`;
- explicit `error_type`;
- explicit `repair_cue`;
- explicit `telemetry_inputs` list matching the W11 source packet convention.

Gaps that matter now:

- None create a current learner-route blocker. W1-W10 are already active,
  guarded, and routed. Replacing that path would be higher risk than value.

Gaps that matter later:

- personalization and repair systems may need stable `target_skill_id`,
  `error_type`, and `repair_cue`;
- telemetry/reporting may need uniform `user_choice`, `correct_or_incorrect`,
  `error_type`, and `time_to_decision` identities;
- W11/W12 coexistence may need adapters to compare legacy beats and
  source-owned beats without migrating all old content.

## 4. Adapter vs migration matrix

| Option | Product EV | Engineering cost | Regression risk | W12 impact | Future personalization / repair impact | Two-system debt |
| --- | --- | --- | --- | --- | --- | --- |
| A. Leave W1-W10 legacy-compatible until a real blocker | High short-term EV: protects live route and W11 momentum | Low | Low | Keeps W12 planning unblocked | Deferred; add adapter when needed | Medium but controlled |
| B. Add compatibility adapter for W7-W10 only | Medium EV if W11/W12 transition needs comparable late-foundation identities | Medium | Medium | Useful for W12 boundary work | Good late-foundation bridge | Medium |
| C. Add compatibility adapter for W1-W10 | Medium-high future EV but broad without current blocker | High | Medium-high | Could help long-term uniformity | Strong uniform read layer | Medium-low after completion |
| D. Partially migrate W7-W10 to source-owned format | Low current EV | High | High | Risky before W12 entry policy is fixed | Strong after migration, but expensive | Low after migration |
| E. Fully migrate W1-W10 to source-owned format | Low current EV, mostly architectural cleanliness | Very high | Very high | Delays W12/W11 surface work | Strong after migration, but risky | Low after migration |

## 5. Recommended strategy

Do now:

- Keep W1-W10 on the current legacy-compatible runtime path.
- Treat W11+ source-owned Foundation Rep Contract as the forward authoring
  format for new route proof.
- Add no adapter until a concrete consumer needs it.

Do not do now:

- Do not migrate W1-W10.
- Do not retrofit source packets or fixtures across W1-W10.
- Do not alter `ProgressService`, campaign registry, canonical routing,
  telemetry, content, or UI.

Why this is highest EV:

- The active product route is already routed and guarded through W10.
- Migration would touch core progression and runner seams with no current
  learner-visible gain.
- A future adapter can provide most uniformity value without rewriting the
  live route.

Expected impact on W12 and Volume I:

- W12 decision work can continue without waiting for a W1-W10 migration.
- Volume I remains honest: W1-W10 active, W11 planned/proof-backed, W12
  planned, W13+ frontier-only.
- If W12 later needs uniform prior-world identities, an adapter can be added as
  a targeted prerequisite.

## 6. Migration trigger policy

Revisit adapter or migration only when one of these concrete triggers appears:

1. Personalization cannot map W1-W10 beats to stable `target_skill_id` /
   `error_type` / `repair_cue` values.
2. Review/repair loop loses error identity or cannot compare legacy and
   source-owned failures.
3. Telemetry cannot map `user_choice`, `correct_or_incorrect`, `error_type`,
   and `time_to_decision` across W1-W12.
4. W11/W12 coexistence breaks because legacy route shape cannot interoperate
   with source-owned route proof.
5. A learner-visible W1-W10 regression is traced to legacy route shape rather
   than a local surface/test issue.
6. Monetization, mastery, or progress analytics require uniform source atoms
   and a scoped adapter cannot supply them.

Preferred trigger response order:

1. Add a read-only compatibility adapter.
2. Add focused contract tests for the consumer needing it.
3. Migrate only the smallest world range if adapter proof is insufficient.

## 7. Risk register

| Risk | Current assessment | Mitigation |
| --- | --- | --- |
| Regression risk | Migration risk is high because W1-W10 own live progression and routing. | Avoid migration now; keep current guards green. |
| Two-system debt | Medium: W1-W10 legacy-compatible, W11+ source-owned. | Accept until a consumer needs uniform reads; then add adapter. |
| Personalization / repair blocker risk | Medium future risk, low current blocker evidence. | Define trigger policy; do not preemptively rewrite. |
| Test coverage risk | Current guards prove route shape, not full Foundation Rep field parity. | Add adapter parity tests only when adapter is admitted. |
| Baseline residue risk | World2 contrast-beat failure can confuse broad campaign validation. | Keep it documented and out of this decision wave. |

## 8. Baseline residue note

Known unrelated baseline residue:

- `test/guards/campaign_spine_structure_contract_test.dart`
- failure: `Missing contrast beat: world2_spine_campaign_v1`
- previously reproduced on clean detached `origin/main`

This decision pack did not run or fix that guard. It is not used as a blocker
and should be addressed only in a separately admitted World2 baseline wave.

## 9. Tests / validation

This is a local decision artifact only. No scripts, guards, app code, content,
or tests were added for Part B.

Validation for the decision artifact should run:

```bash
graphify hook-check
flutter analyze
dart run tools/term_coverage_scanner.dart
git diff --check
git status --short
```

Focused tests were not run for Part B because no code/test behavior changed.
Part A validation separately covered the W11 admission policy guard and related
W10/W11 proof guards before push.

## 10. Next recommended wave

`W11 Route Surface Proof v1`

Reason: the selected verdict is `keep_legacy_now_adapter_later`. The highest
EV next step is not W1-W10 migration. It is proving the newly admitted W11
planned/proof-backed surface state with focused widget/surface evidence before
any W11 active entry or W10 handoff work.
