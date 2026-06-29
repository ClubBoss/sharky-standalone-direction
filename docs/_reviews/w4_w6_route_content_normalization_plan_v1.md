# W4-W6 Route/Content Normalization Plan v1

Branch: `codex/w4-w6-route-content-normalization-plan-v1`.
Baseline: `d148d3dd` (`w4_title_job_realignment_pr2_deferred_runtime_change`)
plus accepted `W1-W12 Route/Content Cascade Map v1`.

## 1. Verdict

`w4_w6_normalization_ready_with_ssot_cleanup`
`w4_w6_normalization_recommends_title_runtime_pr1`

W4-W6 normalized ownership is now a control-plane decision:

- W4 -> Bet Purpose / Price.
- W5 -> Board Awareness.
- W6 -> Range Thinking.

This wave does not mutate runtime titles, fixtures, tests, source content, or
route admission. It deprecates stale W4-W6 practical labels in active SSOT docs
and selects a focused implementation PR1 as the next wave.

## 2. Source truth

The accepted `W1-W12 Route/Content Cascade Map v1` is the source-truth input for
this plan. It confirms:

- W1-W3 baseline is accepted and must not be reopened.
- W4-W9 have a one-world-forward route/source offset.
- W10 is ambiguous.
- W11-W12 are route/source aligned but authored-but-not-routed.
- W7-W10 cascade findings are read-only while those worlds remain locked.

This plan references that cascade map instead of re-proving it.

## 3. Cascade recap

The cascade starts at W4:

- W4 route says `Preflop Framework`, but W4 source teaches Bet Purpose / Price.
- W5 route says `Bet Purpose And Price`, but W5 source teaches Board Awareness.
- W6 route says `Board And Draws`, but W6 source teaches Range Thinking.

The W5 source paradox is decisive: W5 says it comes after World 4 because
purpose and price need to exist first, while the current W5 route title itself
is Bet Purpose / Price. The source sequence becomes coherent only after W4-W6
normalization.

## 4. Normalized W4-W6 contract

| World | Current route title | Actual source job | Normalized title/job | Claim limit | Reason |
| --- | --- | --- | --- | --- | --- |
| W4 | Preflop Framework | Bet Purpose / Price | Bet Purpose / Price | Bridge-limited until title/runtime, fixture/exporter, and validator-backed canonical evidence are updated later. | W4 source explicitly teaches purpose, price, value, protection, bluff, denial, and controlled reopen work. |
| W5 | Bet Purpose And Price | Board Awareness | Board Awareness | Bridge-limited until runtime/title and fixture/exporter contracts match normalized ownership. | W5 source teaches dry/wet/paired/connected textures, draw recognition, and improvement counting. |
| W6 | Board And Draws | Range Thinking | Range Thinking | Bridge-limited; correctness review required before W6 canonical certification. | W6 source teaches range buckets, width, advantage, compression, and bounded polarization; terminal gate must be preserved. |

## 5. Stale route wording cleanup

| File | Stale wording found | Action taken | Why safe | Remaining risk |
| --- | --- | --- | --- | --- |
| `docs/plan/MASTER_PLAN_v3.0.md` | Practical W4-W6 labels presented as current route: W4 Preflop Framework, W5 Bet Purpose / Price, W6 Board and Draws. | Added accepted-cascade deprecation guard and normalized W4-W6 ownership note; preserved historical text as pre-cascade context. | Docs-only; no runtime, fixture, or route admission mutation. | Runtime still uses old labels until PR1. |
| `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` | Active launch labels listed W4/W5/W6 old titles for monetization/commercial planning. | Marked the table as deprecated for route/content ownership after the cascade map and added normalized ownership note while preserving W1-W4 free and W5+ paid-depth policy. | Prevents future agents from using old labels as product direction without changing monetization implementation. | Monetization SSOT still needs a later dedicated wording update if PR1 changes runtime labels. |
| `docs/plan/VOLUME_I_WORLD_READINESS_LEDGER_v1.md` | Active next pointer and blocker wording needed to reflect accepted cascade and normalization plan. | Preserved existing cascade update, added this plan as evidence, and moved next action to title/runtime PR1. | Score stays flat; docs-only. | W4-W6 remain bridge-limited. |
| `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md` | Handover/next-wave pointer needed to move from plan to implementation PR1. | Added this plan to history and selected W4-W6 Title/Runtime Normalization Implementation PR1. | Control-plane pointer only. | Implementation risk remains in runtime/tests. |

## 6. Dependency touch-point map

| Surface | Files / search targets | Expected implementation change later | Risk | Test/validation required |
| --- | --- | --- | --- | --- |
| Route title constants / world metadata | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, `act0_learn_path_shell_v1.dart` | Rename W4-W6 runtime titles and subtitles to normalized contract. | High: learner-facing route copy and unlock labels change together. | Focused Act0 shell tests and route-title contract tests. |
| Act0 world cards | `Act0WorldCardV1` records for `world_4`, `world_5`, `world_6` | Align title, subtitle, lesson owner expectations, and unlock labels. | High: W5+ boundary copy may be affected. | Focused UI/model tests; no screenshots unless later UI wave asks. |
| Campaign/progression story | W3->W4, W4->W5, W5->W6 handoff copy and completion surfaces | Reword handoffs so W4 teaches purpose/price, W5 teaches board awareness, W6 teaches range thinking. | Medium-high: old handoff copy can restore stale route semantics. | Focused progression/handoff tests. |
| Handoff/runner chrome | Runner lesson subtitles and completion cards | Align lesson subtitles and next-route labels with normalized titles. | Medium. | Existing runner chrome tests plus targeted title assertions. |
| Monetization route truth / premium boundary copy | `docs/plan/MONETIZATION_SSOT_v1.md`, `TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` | Preserve W1-W4 free and W5+ paid-depth while preventing stale topic labels from defining route ownership. | High: commercial boundary must not be reopened by title cleanup. | Docs review and monetization copy safety checks. |
| RU copy | `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart` | Update W4-W6 localized titles if runtime labels change. | Medium: localization can lag English route truth. | RU fallback/coverage tests. |
| Bridge fixture display titles | `test/fixtures/content_factory_mvp/w4_*`, `w5_*`, `w6_*` bridge fixtures | Update display titles only after active route truth changes. | High: schema requires `display_world_title` to match active route truth. | Foundation and L2/L3 validators. |
| Factory exporter defaults | `tools/content_factory_import_export_mvp_v1.dart` W4-W6 bridge exports | Align `displayWorldTitle` defaults with normalized route truth. | High: exporter can regenerate stale fixtures. | Import/export CLI and validators. |
| Focused tests | `test/ui_v2/act0_shell_preview_screen_v1_test.dart`, premium-foundation tests, runner progression tests | Update assertions that expect old W4-W6 labels. | High: broad suite churn if done casually. | Focused Flutter tests, then `flutter analyze`. |
| W6 terminal gate | W6->W7 gate and terminal-copy tests | Preserve W6 as terminal gate before W7-W10 even after title normalization. | Critical: title normalization must not open W7-W10. | Gate/route tests plus explicit negative control. |

## 7. W6 terminal gate protection

W6 remains the terminal gate before W7-W10. Normalizing W6 from Board and Draws
to Range Thinking must not open W7-W10, change W7-W10 route status, or imply
W7-W10 source readiness.

The W6 implementation PR must carry an explicit negative control: W7-W10 remain
locked/read-only after W4-W6 title normalization.

## 8. Preflop Framework disposition

Preflop Framework is displaced from W4 route ownership. It already exists as
W3 bridge-limited source. W3 does not reopen because W3 bounded 8.0 rests on two
accepted Position Thinking-safe canonical families while W3 preflop framework
material remains bridge-limited.

No W3 canonical PR4 is admitted by this plan.

## 9. 36-world policy compatibility

- W1-W12 remains Volume I.
- W13-W36 remain post-launch / long-horizon expansion.
- No W13-W36 source/content was inspected.
- No W13-W36 launch-availability claim is made.
- W7-W10 cascade findings remain read-only until route admission is planned.

## 10. Implementation split

Recommended split:

1. `W4-W6 Title/Runtime Normalization Implementation PR1`.
2. `W4-W5 Canonical Pilot Batch`.
3. `W4-W5 Certification/Payoff Gate`.
4. `W6 Range Correctness Review + Terminal Gate Safety`.
5. `W6 Canonical Pilot`.

PR1 should update title/runtime/copy/test/fixture-export contracts only. It
must not create canonical fixtures or open W7-W10.

## 11. Rejected paths

- Isolated W4 title change: rejected because W5 collision is proven.
- W5 pilot before normalization: rejected because W5 route/source offset is
  accepted.
- W4-W10 batch implementation: rejected because W7-W10 are locked/read-only.
- W7-W10 opening: rejected.
- W1-W3 reopening: rejected; baseline accepted.
- Broad Master Plan rewrite: rejected.
- Full 36-world audit: rejected.

## 12. Score / ledger impact

Score movement: `+0.0`.

This is docs/control-plane cleanup. W4 stays `5.3`, W5 stays `5.3`, W6 stays
`5.1`, W1-W12 readiness stays `7.2`, and overall top-1 readiness stays `6.4`.

## 13. Route impact

No runtime route changed. This plan changes the control-plane contract only:

- old W4-W6 practical labels are deprecated as active direction after the
  accepted cascade map;
- normalized W4-W6 ownership is selected for the next implementation PR;
- W7-W10 remain locked and W13-W36 remain post-launch.

## 14. Active repair queue update

Replace the active next wave:

- completed wave: `W4-W6 Route/Content Normalization Plan`;
- next wave: `W4-W6 Title/Runtime Normalization Implementation PR1`.

## 15. Evidence DoD status

- `graphify hook-check`: pass.
- `git diff --check`: pass.
- `git diff --cached --check`: pass.
- direct ASCII / diff-only ASCII: pass.
- trailing whitespace / CRLF / final-newline checks: pass.

No validators were required because no fixture files changed.
No screenshots were taken.

## 16. Anti-theater check

Pass.

This plan does not treat docs cleanup as runtime normalization, does not rename
fixtures by metadata, does not create canonical evidence, and does not open
W7-W10. It only locks the contract and next implementation split.

## 17. Next wave decision

`W4-W6 Title/Runtime Normalization Implementation PR1`
