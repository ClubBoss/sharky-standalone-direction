# Wave 5.2 Follow-up - W7-W10 Current Campaign Status Alignment v1

## 1. Verdict

`wave5_2_w7_w10_current_campaign_status_alignment_ready`

W7-W10 are now aligned as `locked_not_learner_playable` in the active Act0
learner route.

The campaign registry may still contain W7-W10 authored/internal pack IDs, but
`ProgressService.getNextSpinePackToRunV1()` no longer promotes W7-W10 as the
next learner-facing pack after W6. Stale W7-W10 active-pack state is also
clamped back to the W6 terminal follow-up gate.

## 2. Source Truth

- `docs/_reviews/wave5_2_w7_w12_route_truth_reconciliation_v1.md`: accepted
  prior audit artifact and conflict source.
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`: W7-W12 route truth was
  unresolved before this follow-up.
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`: Wave 5.2 is a control-plane
  route-truth wave, not content authoring.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`: W7-W12 cards remain locked
  and non-selectable.
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`: learner-visible Learn
  copy now says W7-W10 are a locked preview.
- `lib/services/progress_service.dart`: learner progression now stops at the W6
  terminal follow-up gate instead of returning W7-W10 campaign packs.
- `test/guards/w7_w10_route_status_alignment_contract_test.dart`: direct route
  status guard for W7-W10 locked state.
- `test/guards/world7_campaign_routing_contract_test.dart` through
  `test/guards/world10_campaign_routing_contract_test.dart`: prior current
  campaign route guards were realigned to the closed learner route.
- `test/guards/w11_route_backed_proof_contract_test.dart` and
  `test/guards/w12_route_backed_proof_contract_test.dart`: W11-W12 remain
  authored/proof-backed but not routed.

## 3. Problem Statement

Wave 5.2 found a product-truth conflict:

- Act0 world cards treated W7-W12 as locked and non-selectable.
- Learn copy said W7-W10 were the current campaign.
- `ProgressService` could return W7-W10 campaign pack IDs after W1-W6
  completion state.
- W11-W12 were already correctly non-routed.

This meant W7-W10 could not be honestly described as either locked or active.

## 4. Product Decision

Default product decision adopted for this follow-up:

`W7-W10 are not learner-playable in the active Act0 route for now.`

Practical meaning:

- W1-W6 remain the active learner route.
- The W6 terminal follow-up pack is the current learner route boundary.
- W7-W10 can remain authored/internal campaign content in registry structures.
- W7-W10 must not be promoted by current learner progression.
- W11-W12 remain `authored_but_not_routed`.

## 5. Code Alignment

- `ProgressService.getNextSpinePackToRunV1()` now returns
  `world6_spine_followup_v1_b2` after W6 completion instead of W7.
- Stale active W7-W10 pack state is clamped to
  `world6_spine_followup_v1_b2`.
- W7-W10 campaign/follow-up pack IDs are tracked in an internal locked-pack
  set for this route gate.
- The campaign registry was not deleted or rewritten; registry presence is now
  treated as authored/internal content, not active learner route authority.
- Learn-path status copy now says `W1-W6 available - W7-W10 locked preview`
  for both supported locale branches to keep this follow-up ASCII-only.

## 6. Test Alignment

- Added `w7_w10_route_status_alignment_contract_test.dart` to assert:
  - W7-W12 Act0 cards are locked and non-selectable.
  - W7-W10 are not returned after W6 completion.
  - stale active W7-W10 pack IDs are not returned.
- Updated W7, W8, W9, and W10 route guards to assert the learner route gate
  instead of route opening.
- Updated the Act0 Learn status text guard to expect locked-preview copy.
- Preserved W6 route behavior: W6 still returns `world6_spine_campaign_v1`
  before W6 completion.
- Preserved W11/W12 proof guards: no W11/W12 learner route was opened.

## 7. W7-W12 Status Matrix

| World | Before this follow-up | After this follow-up | Learner-facing exposure | Internal/debug/test exposure | Confirmation |
| --- | --- | --- | --- | --- | --- |
| W7 | `conflicting_truth` | `locked_not_learner_playable` | Act0 card locked; ProgressService clamps to W6 terminal gate. | Registry/content IDs may remain for authored/internal proof. | W7 route guard now expects W6 terminal gate. |
| W8 | `conflicting_truth` | `locked_not_learner_playable` | Act0 card locked; ProgressService clamps to W6 terminal gate. | Registry/content IDs may remain for authored/internal proof. | W8 route guard now expects W6 terminal gate. |
| W9 | `conflicting_truth` | `locked_not_learner_playable` | Act0 card locked; ProgressService clamps to W6 terminal gate. | Registry/content IDs may remain for authored/internal proof. | W9 route guard now expects W6 terminal gate. |
| W10 | `conflicting_truth` | `locked_not_learner_playable` | Act0 card locked; ProgressService clamps to W6 terminal gate. | Registry/content/track IDs may remain for authored/internal proof. | W10 route guard now expects W6 terminal gate. |
| W11 | `authored_but_not_routed` | `authored_but_not_routed` | Act0 card locked; no active campaign route. | Source/proof packets and guards remain. | W11 proof guard remains green. |
| W12 | `authored_but_not_routed` | `authored_but_not_routed` | Act0 card locked; no active campaign route. | Source/proof packets and guards remain. | W12 proof guard remains green. |

## 8. W7-W10 Before And After

Before:

- W7-W10 cards were locked in Act0.
- W7-W10 were described as current campaign in Learn copy.
- W7-W10 could be selected as next campaign packs by `ProgressService`.

After:

- W7-W10 cards remain locked in Act0.
- W7-W10 are described as locked preview in Learn copy.
- W7-W10 are not selected by current learner progression.
- Stale active W7-W10 state does not leak into learner progression.

## 9. W11-W12 Confirmation

W11-W12 were not modified or routed.

No W11/W12 campaign pack was added, no W10-to-W11 handoff was enabled, and no
W12 gateway/Volume I completion claim was introduced.

## 10. Scope Exclusions

This follow-up did not:

- author or edit W5-W12 content;
- open W7-W10 for learner play;
- route W11 or W12;
- change monetization, paywalls, pricing, or entitlement;
- change telemetry;
- touch Modern Table;
- capture screenshots;
- refactor campaign registry data;
- reorder enums or widen product architecture.

## 11. Evidence

Commands run for this follow-up:

- `flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart`
  - Red before the route gate: W7 was returned after W6 completion and stale
    active W7 state was returned directly.
  - Green after the route gate: all 3 tests passed.
- Focused route/proof suite:
  - `test/guards/w7_w10_route_status_alignment_contract_test.dart`
  - `test/guards/world6_campaign_routing_contract_test.dart`
  - `test/guards/world7_campaign_routing_contract_test.dart`
  - `test/guards/world8_campaign_routing_contract_test.dart`
  - `test/guards/world9_campaign_routing_contract_test.dart`
  - `test/guards/world10_campaign_routing_contract_test.dart`
  - `test/guards/w11_route_backed_proof_contract_test.dart`
  - `test/guards/w12_route_backed_proof_contract_test.dart`
  - Result: all 15 tests passed.
- Act0 Learn copy guard:
  - `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Learn status header states the truthful Volume I horizon"`
  - Result: passed.
- `dart format --set-exit-if-changed` on changed Dart files.
  - Result: 9 files checked, 0 changed on final run.
- `flutter analyze`.
  - Result: no issues found.
- `graphify hook-check`.
  - Result: passed.
- `git diff --check`.
  - Result: passed.
- Direct CRLF/trailing-whitespace check on changed files.
  - Result: no findings.
- Direct non-ASCII check on added diff lines.
  - Result: no findings.

## 12. Next Step

No PR2 is required for W7-W10 route truth after this follow-up.

The next safe step is a separate route-admission decision only if the product
explicitly wants to open W7-W10 later. That future wave must prove route,
surface, seam, regression, and first-session payoff before changing W7-W10 from
locked preview to learner-playable.
