# Wave 5.2 - W7-W12 Route Truth Reconciliation v1

## 1. Verdict

`wave5_2_conflicting_truth_requires_follow_up`

W7-W12 route truth is now classified, but not fully resolved.

Current main has three different truth layers:

- active Act0 world cards list W7-W12 but keep every W7-W12 card locked and non-selectable;
- the compatibility campaign route can select W7-W10 deterministic campaign packs after W1-W6 completion state;
- W11-W12 have source-owned packets, fixtures, projection/proof guards, and planned-visible Learn copy, but no active learner entry or progression handoff.

The safe product truth is therefore:

- W7-W10: `conflicting_truth`, with real authored content and compatibility-route exposure risk.
- W11-W12: `authored_but_not_routed`, with source/proof content but no active route consumption.

No W7-W12 world should be promoted as generally playable from this wave.

## 2. Source truth

Files inspected and why:

- `AGENTS.md`: repo boundary, Act0 runtime canonical entry, docs/audit-first constraints, and graphify policy.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`: active SSOT hierarchy and active app boundary.
- `docs/plan/MASTER_PLAN_v3.0.md`: W7-W12 release expectations, Gate B rules, and older completed-packet/seam language.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: current Full Top-1 route and Wave 5.2 control-plane pointer.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: active long-horizon ledger naming W7-W12 route truth as unresolved and Wave 5.2 as next.
- `docs/_reviews/wave5_1_canonical_telemetry_instrumentation_v1.md`: accepted prior wave context and no W5-W12 opening boundary.
- `docs/_reviews/36_world_curriculum_ssot_contract_v1.md`: current route-status vocabulary and W7-W10/W11-W12 reconciliation precedent.
- `docs/_reviews/36_world_curriculum_coverage_sequence_audit_v1.md`: prior conflict note that W7-W12 route truth needed this scoped audit.
- `docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md`: historical calibration claiming W7-W12 release-strong quality.
- `lib/ui_v2/app_root.dart`, `lib/ui_v2/ui_v2_beta_shell.dart`, `lib/ui_v2/act0_shell/act0_canonical_path_root_v1.dart`: canonical app entry remains Act0.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`: W7-W12 world cards, lesson arrays, locked/selectable flags.
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`: learner-visible Volume I copy says W7-W10 current campaign and W11-W12 planned.
- `lib/campaign/campaign_pack_registry_v1.dart`: W7-W10 compatibility campaign packs are registered; W11-W12 are not.
- `lib/services/progress_service.dart`: next-pack routing can return W7-W10 packs, then W10 track entry, with no W11/W12 branch.
- `content/worlds/world7` through `content/worlds/world12`: active-root content/source presence.
- `test/guards/world7_campaign_routing_contract_test.dart`, `test/guards/world8_campaign_routing_contract_test.dart`, `test/guards/world9_campaign_routing_contract_test.dart`, `test/guards/world10_campaign_routing_contract_test.dart`: W7-W10 route and regression evidence.
- `test/guards/w11_route_backed_proof_contract_test.dart`, `test/guards/w12_route_backed_proof_contract_test.dart`, `test/guards/w11_route_admission_runtime_contract_test.dart`: W11-W12 non-visible proof and non-registration evidence.
- `docs/_reviews/w11_route_proof_goal_pack_v2.md`, `docs/_reviews/w12_route_proof_goal_pack_v1.md`, `docs/_reviews/w11_volume_i_admission_goal_pack_v1.md`, `docs/_reviews/w12_volume_i_admission_goal_pack_v1.md`: W11-W12 source/proof admission state.

## 3. Scope and non-scope

In scope:

- audit/docs-first route truth reconciliation;
- current-main W7-W12 classification;
- active route, content, seam/density, and guard evidence review.

Out of scope:

- content authoring;
- route opening;
- UI implementation;
- Modern Table visual work;
- monetization;
- server analytics;
- W13-W36 work;
- screenshot capture or generated evidence packets.

## 4. Conflict summary

Material conflicts found:

| Source layer | Claim / evidence | Conflict |
| --- | --- | --- |
| TOP1 long-horizon ledger | W7-W12 route truth is unresolved; Wave 5.2 must classify it before authoring/opening. | Conflicts with older Master Plan and calibration language that reads as W7-W12 release-ready. |
| TOP1 SSOT | Full Top-1 route is active; quick public/store route paused; Wave 5.2 is current control-plane work. | Supersedes older next-wave pointers and any quick-beta pressure. |
| MASTER_PLAN | W7-W12 may be playable once density, seam audit, and regression gates are green; also names specific seam audit files. | Named seam files for W8->W9 and W9->W10 were not found in active docs; W10->W11 and W11->W12 only appeared under archive. |
| Volume I calibration | W7-W12 are `release-strong`. | Calibration quality does not prove current route access; W11-W12 lack active route registration. |
| Active Act0 state | W7-W12 cards exist but are locked and non-selectable. | Conflicts with W7-W10 campaign route tests and Learn copy saying W7-W10 current campaign. |
| ProgressService / campaign registry | W7-W10 packs can be returned by `getNextSpinePackToRunV1()`. | Stronger than shell-only, but not enough to call the Act0 card route generally playable while cards remain locked. |
| W11-W12 source/proof docs/tests | Source packets and non-visible proof objects exist. | Stronger than planned-only, but explicit tests prove no active campaign pack, learner entry, or handoff. |

## 5. W7-W12 status matrix

| World | Primary status | Active route exposure | Content evidence | Seam/density evidence | Regression lock evidence | Blocker / risk | Safe next action |
| --- | --- | --- | --- | --- | --- | --- | --- |
| W7 | `conflicting_truth` | Act0 card locked; compatibility route can select `world7_spine_campaign_v1`. | 10 content sessions, 96 drill files; Act0 locked lesson array exists. | Historical calibration says release-strong; active seam proof not fully located. | `world7_campaign_routing_contract_test.dart`. | Active-route exposure and Act0 lock disagree. | Decide whether W7 is current campaign or locked preview, then align surface/route wording and guards. |
| W8 | `conflicting_truth` | Act0 card locked; compatibility route can select `world8_spine_campaign_v1`. | 10 content sessions, 96 drill files; Act0 locked lesson array exists. | Historical calibration says release-strong; active seam proof not fully located. | `world8_campaign_routing_contract_test.dart`. | Active-route exposure and Act0 lock disagree. | Same as W7; also verify W7->W8 handoff and seam evidence. |
| W9 | `conflicting_truth` | Act0 card locked; compatibility route can select `world9_spine_campaign_v1`. | 10 content sessions, 96 drill files; Act0 locked lesson array exists. | Historical calibration says release-strong; active seam proof not fully located. | `world9_campaign_routing_contract_test.dart`. | Active-route exposure and Act0 lock disagree; tournament correctness needs future review. | Align campaign route truth and run correctness/seam review before broader claim. |
| W10 | `conflicting_truth` | Act0 card locked; compatibility route can select `world10_spine_campaign_v1`; after W10 calibration, route returns selected W10 track entry. | 10 core sessions plus track content; 365 drill files. | Historical calibration says release-strong; active W10->W11 seam path is archived, not active. | `world10_campaign_routing_contract_test.dart`; track continuation tests. | W10 terminal/track behavior conflicts with W11/W12 completion implications. | Keep W10 terminal/track-owned until W10-to-W11 handoff is separately admitted. |
| W11 | `authored_but_not_routed` | Act0 card locked; no active campaign pack; W10 handoff disabled. | 1 source session, campaign fixture, deterministic source packet; Act0 locked lesson array exists. | Route-proof docs and source contract exist; no learner-visible route. | `w11_route_backed_proof_contract_test.dart`, `w11_route_admission_runtime_contract_test.dart`, source/fixture/projection guards. | No runtime consumer, no campaign registration, no W10 handoff. | W11 route-consumption / handoff decision wave only after W7-W10 truth is aligned. |
| W12 | `authored_but_not_routed` | Act0 card locked; no active campaign pack; no prior-world handoff. | 1 source session, campaign fixture, deterministic source packet; Act0 locked lesson array exists. | Route-proof docs exist; planned-visible continuation only. | `w12_route_backed_proof_contract_test.dart`, source/fixture/projection/admission guards. | No runtime consumer; W13 gateway risk if opened prematurely. | Keep planned-visible; do not route before W11 and W12 boundary contract are green. |

## 6. Per-world findings

### W7

Status: `conflicting_truth`

Evidence:

- `content/worlds/world7/v1/` contains 10 sessions and 96 drill files.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` defines W7 as locked/non-selectable.
- `lib/campaign/campaign_pack_registry_v1.dart` registers `world7_spine_campaign_v1`.
- `lib/services/progress_service.dart` can return `world7_spine_campaign_v1` after W1-W6 completion state.
- `test/guards/world7_campaign_routing_contract_test.dart` expects that next pack.

Why not stronger: the active Act0 card remains locked and the older seam/density proof is not cleanly present in active docs.

Opening safe now: no. W7 may be reachable through compatibility campaign state, but the product should first decide whether this is intended current campaign exposure or a route-truth leak.

Next prerequisite: W7 route/status alignment across Act0 card state, Learn copy, ProgressService, campaign registry, and guards.

### W8

Status: `conflicting_truth`

Evidence:

- `content/worlds/world8/v1/` contains 10 sessions and 96 drill files.
- Act0 defines W8 as locked/non-selectable.
- Registry and ProgressService can expose `world8_spine_campaign_v1` after W7 completion/calibration state.
- `test/guards/world8_campaign_routing_contract_test.dart` expects W8 as the deterministic next pack.

Why not stronger: active card lock and campaign routing disagree; current seam proof was not found in active docs.

Opening safe now: no broader claim. Treat as current-campaign-compatible only until route status is normalized.

Next prerequisite: W7->W8 handoff/seam proof and surface wording alignment.

### W9

Status: `conflicting_truth`

Evidence:

- `content/worlds/world9/v1/` contains 10 sessions and 96 drill files.
- Act0 defines W9 as locked/non-selectable.
- Registry and ProgressService can expose `world9_spine_campaign_v1` after W8 completion/calibration state.
- `test/guards/world9_campaign_routing_contract_test.dart` expects W9 as the deterministic next pack.

Why not stronger: current route proof exists through campaign tests, but Act0 route-state and long-horizon truth still mark W7-W12 unresolved; W9 also carries tournament-pressure correctness risk.

Opening safe now: no general playable claim.

Next prerequisite: route/surface alignment plus W9 correctness/seam audit before any stronger status.

### W10

Status: `conflicting_truth`

Evidence:

- `content/worlds/world10/v1/` contains 10 core sessions, track folders, and 365 drill files.
- Act0 defines W10 as locked/non-selectable.
- Registry and ProgressService can expose `world10_spine_campaign_v1`.
- After W10 calibration, `ProgressService.getNextSpinePackToRunV1()` returns the selected W10 track entry, not W11.
- `test/guards/world10_campaign_routing_contract_test.dart` proves W10 campaign start and telemetry.

Why not stronger: W10 has the strongest route/test evidence in W7-W10, but its terminal/track behavior conflicts with any claim that W11/W12 are active.

Opening safe now: no broader Volume I completion claim.

Next prerequisite: keep W10 terminal or explicitly admit a W10-to-W11 handoff wave after W7-W10 route truth is normalized.

### W11

Status: `authored_but_not_routed`

Evidence:

- `content/worlds/world11/v1/sessions/w11.s01/` contains a source session, fixture, and deterministic source packet.
- Act0 defines W11 locked/non-selectable lesson arrays.
- W11 proof descriptor is non-learner-visible with `w10HandoffEnabled: false`.
- Guards prove no `world11_` campaign registry row.
- Learn copy says W11-W12 are planned foundation chapters, coming later.

Why not stronger: no active runner, no ProgressService consumer, no campaign pack registration, and no W10 handoff.

Opening safe now: no.

Next prerequisite: W11 route-consumption and W10 handoff contract after current campaign truth is resolved.

### W12

Status: `authored_but_not_routed`

Evidence:

- `content/worlds/world12/v1/sessions/w12.s01/` contains a source session, fixture, and deterministic source packet.
- Act0 defines W12 locked/non-selectable lesson arrays.
- W12 proof descriptor is non-learner-visible with prior-world handoff disabled.
- Guards prove no `world12_` campaign registry row.
- Learn copy says W11-W12 are planned foundation chapters, coming later.

Why not stronger: no active route, no runtime consumer, and opening W12 would risk a false Volume I completion / W13 gateway claim.

Opening safe now: no.

Next prerequisite: W11 active route truth first, then separate W12 boundary/admission contract.

## 7. Runtime exposure risk

Yes, there is W7-W10 runtime exposure risk.

Severity: medium.

Reason:

- `ProgressService.getNextSpinePackToRunV1()` can return W7-W10 campaign packs.
- `UniversalIntakePlanScreen` consumes the next spine pack and can start the route.
- Focused W7-W10 route tests intentionally assert this behavior.
- At the same time, canonical Act0 world cards keep W7-W10 locked/non-selectable.

This is not a P0 leak because W7-W10 exposure appears intentional in older campaign-routing guards and Learn copy. It is still a route-truth conflict because the active Act0 card state and current long-horizon ledger do not allow a clean `playable` claim.

Smallest follow-up:

- choose one product truth for W7-W10: `current campaign continuation` or `locked preview`;
- align Act0 card state/copy, ProgressService route ownership, and guards to that truth;
- do not touch W11-W12 while doing that alignment.

W11-W12 have no accidental learner route found. Their proof registries and guards explicitly keep learner visibility and handoff disabled.

## 8. Product implications

Wave 5.3 W1-W6 Content Depth / Same-Signal Coverage Audit:

- still valid as the next Stage A audit if W7-W10 are treated as current campaign continuation;
- if W7-W10 are deemed route leaks, Wave 5.3 should wait for W7-W10 route alignment.

Wave 6.1 Content Schema Foundation:

- remains important because W7-W12 content is split across Dart-owned lesson arrays, compatibility campaign packs, and source-owned packets;
- Wave 6.1 should include a status field that distinguishes `campaign_routed`, `authored_but_not_routed`, and `planned_visible`.

Wave 10.1 W5-W6 Route Verification:

- should not use W7-W10 campaign tests as proof that W5-W6 are clean; W5-W6 need their own route/density verification.

Wave 10.3 W7-W12 Curriculum Lock:

- should become the decision wave that resolves this artifact's conflict: either promote W7-W10 to explicit current campaign continuation or close the exposure; keep W11-W12 authored/proof-backed but non-routed until handoff contracts are green.

Wave order does not need to change yet. The next ledger step should close this route-truth conflict before W7-W12 bulk authoring or schema/factory migration depends on it.

## 9. Wave DoD status

- [x] W7-W12 each classified
- [x] source conflicts listed
- [x] active route truth inspected
- [x] content truth inspected
- [x] tests/guards inspected
- [x] blockers listed
- [x] no content authored
- [x] no user route opened
- [x] no broad UI/product work

## 10. Evidence DoD status

- [x] review artifact created
- [x] graphify hook-check run
- [x] git diff --check run
- [x] flutter analyze run unless no Dart files changed and dependency state blocks it: skipped because no Dart/test/tool files changed
- [x] targeted tests run only if code/helper touched: not applicable, no code/helper touched
- [x] generated outputs not committed
- [x] exact commands and results recorded

Commands run:

- `git status --short`: only the new review artifact plus pre-existing untracked generated output directories were present.
- `graphify query "W7 W8 W9 W10 W11 W12 Act0 route truth content seam density regression lock"`: completed; useful scoped node was `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
- `graphify hook-check`: passed.
- `git diff --check`: passed.
- `LC_ALL=C grep -n '[^ -~]' docs/_reviews/wave5_2_w7_w12_route_truth_reconciliation_v1.md || true`: no non-ASCII found.

## 11. Score delta proposal

This is a truth-classification wave, not a product-score movement wave.

Default score movement:

- Full 36-world readiness: no direct increase.
- Content depth: no direct increase.
- Overall top-1 readiness: no direct increase.

Conservative interpretation:

- Risk clarity improved because W7-W12 now have a current-main status matrix.
- Product readiness should not move until W7-W10 route truth is normalized and W11-W12 remain honestly non-routed.

## 12. Remaining work

This PR can close Wave 5.2 as an audit artifact if the team accepts `conflicting_truth_requires_follow_up`.

Remaining blockers:

- W7-W10 Act0 lock state and compatibility campaign route exposure disagree.
- Active seam audit paths named by the Master Plan were not cleanly present in active docs.
- W11 route proof is non-visible and not consumed by runtime.
- W12 route proof is non-visible and must not imply Volume I completion or W13 access.
- W7+ poker correctness validation remains a future blocker before advanced claims.

Split recommendation:

- Do not stretch Wave 5.2 into implementation.
- Next PR should be a route-status decision/alignment slice for W7-W10 only, or Wave 10.3 should explicitly own that decision.
- If this needs a third PR, stop and re-audit rather than continuing scope creep.

Recommended next step under the long-horizon ledger:

`W7-W10 Current Campaign Status Alignment v1`

Purpose: decide and encode whether W7-W10 are intentionally current campaign continuation or should be locked preview in all active route owners. Keep W11-W12 non-routed.
