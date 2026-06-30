# Volume I Pre-Route Naming Copy Capstone Contract v1

## 1. Verdict

Verdict: `volume_i_pre_route_naming_copy_capstone_contract_landed_with_tests`

Scope: pre-route product/learning contract plus localized hidden-source copy/test enforcement. This is not route admission, learner-facing launch, Human QA, monetization, or broad content expansion.

## 2. Stage 0 Result

Stage 0 passed and was pushed in `docs/_reviews/repo_integration_volume_i_pre_route_contract_v31.md`.

Starting accepted main for this wave was `b391a110b231243cd9a6bfc7cdb906cccd36e8a3`; Stage 0 landed as `b404e4d1`.

## 3. Files Inspected

- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/context/HUMAN_QA_CAPSULE_v1.md`
- `docs/plan/VOLUME_I_EV_BACKLOG_v1.md`
- `docs/_reviews/volume_i_claude_findings_triage_v1.md`
- `docs/_reviews/volume_i_internal_source_certification_v1.md`
- `docs/_reviews/w1_w12_internal_source_checkpoint_v1.md`
- `docs/plan/WORLD_FACTORY_CONTRACT_v1.md`
- W7-W12 hidden runtime owners and focused source-template tests under `lib/ui_v2/act0_shell/` and `test/ui_v2/`.

## 4. Files Changed

- `docs/_reviews/volume_i_pre_route_naming_copy_capstone_contract_v1.md`
- `docs/plan/VOLUME_I_EV_BACKLOG_v1.md`
- `lib/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart`
- `test/ui_v2/act0_w7_completion_pack_v1_test.dart`
- `test/ui_v2/act0_w8_internal_world_source_template_v1_test.dart`
- `test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart`
- `test/ui_v2/act0_w11_w12_internal_world_source_template_batch_v1_test.dart`

## 5. P1 Risks Addressed

- C01: W7 naming / positioning problem.
- C04: W9 differentiation from W4.
- C05: W10 differentiation from W4.
- C07: W12 capstone scope problem.
- C08: W12 repair concept too vague.
- C11: soft overclaim risk.
- C15: actual W7-W12 copy not verified.
- C17: route admission prerequisites remain blocked.

## 6. W7 Naming Decision

Decision: use `Visible Cards Change Ranges` as the learner-facing W7 title when W7 becomes route-visible.

Rationale: it is beginner-readable, distinct from W6 `Range Thinking`, explains the actual W7 hidden source angle, and avoids the anti-premium `Lite` suffix.

Internal IDs remain unchanged for this wave. The existing `range_thinking_lite_combo_density` lesson id and internal task ids are implementation identifiers, not learner-facing copy. Any future display-title field should alias W7 to `Visible Cards Change Ranges` without broad migration.

## 7. W9/W10 Differentiation Decision

Required positioning:

- W4: what bet sizes and bet purpose communicate.
- W9: whether the call price is attractive enough relative to the pot.
- W10: why we bet, framed as value versus trying to make stronger hands fold.

Contract: W9/W10 route copy must not read as another W4 pass. W9 must anchor call-price attractiveness; W10 must anchor bet-purpose intent in beginner language.

## 8. W12 Capstone / Review Decision

Decision: reframe W12 as `Volume I Review: Putting the Clues Together`, not a full capstone.

Rationale: the current hidden source layer has four tasks, which is acceptable for a review gate but not enough to claim a full Volume I capstone. A future source expansion may add 2-4 tasks, but route admission planning should treat that as an optional quality lift, not a silent prerequisite.

## 9. W12 Repair Specificity Decision

Decision: keep `w12_review_decision_intuition` only as an internal umbrella concept family. Learner-facing repair must use cue-specific repair focus where possible.

Required repair subtype vocabulary:

- `missed_price_cue`
- `missed_draw_cue`
- `missed_board_texture_cue`
- `missed_bet_purpose_cue`
- `missed_visible_card_cue`

Existing W12 hidden repair focus ids are more specific than the umbrella concept and may remain, but future learner-facing repair copy must answer: what cue was missed, which W7-W11 family it connects to, and what the next repair should revisit.

## 10. Copy Verification Contract

Before any W7-W12 route admission implementation, review these fields for every route-visible W7-W12 surface:

- world title;
- world intro;
- task prompt;
- choice labels;
- feedback copy;
- completion/outro copy;
- repair framing copy;
- accessibility/debug-visible labels if exposed.

Required checks:

- no raw task ids in learner copy;
- no `lite` in learner-facing copy;
- no unexplained jargon: `combo density`, `card removal`, `gutshot`, `thin value`, `fold pressure`, `suited texture pressure`;
- W7 title resolves to `Visible Cards Change Ranges`;
- W9/W10 differentiation is explicit;
- W12 is framed as review, not mastery/capstone proof.

## 11. Soft-Claim Safety Contract

Hard forbidden claim terms remain blocked: `GTO`, `solver`, `optimal`, `perfect`, `mastered`, `fixed`, `guaranteed improvement`, `proven improvement`, `win-rate`, `public/playable`, `AI leak`, and `persona`.

Soft overclaims are also forbidden unless reframed as modest review/practice copy:

- `put it all together`;
- `build winning habits`;
- `develop your reads`;
- `now you know`;
- `you mastered`;
- completion implying competence or durable proof.

Stage 2 strengthened focused copy-safety tests to scan W7-W12 displayed copy, source context, and learning purpose for these risks.

## 12. Route Admission Prerequisite Contract

Route admission remains blocked until:

1. W7 display name / positioning is applied to a route-visible metadata owner.
2. W9/W10 differentiation copy exists in the route-visible world intro.
3. W12 review framing is implemented or accepted as risk.
4. Actual W7-W12 copy passes the copy and soft-claim review.
5. Mapper allowlist plan exists.
6. Practice CTA policy exists.
7. Stale-resume design exists.
8. Human QA plan is updated for W7-W12 copy, scenario fidelity, feedback quality, repair experience, and W12 review perception.

## 13. Implementation Decision

Stage 2 was safe for a localized source/test slice:

- W10 hidden copy was changed from jargon phrases to beginner-readable descriptions.
- Existing W7-W12 hidden source-template tests were strengthened for jargon and soft-claim leakage.

No W7 display-title metadata was implemented because no localized route-safe display-title field exists yet. No W12 expansion was implemented because that would be a content expansion wave.

## 14. Remaining P1/P2 Backlog

Remaining before route admission implementation:

- Apply W7 `Visible Cards Change Ranges` to a future display-title owner.
- Add route-visible W9/W10 intro copy once a route copy owner exists.
- Apply W12 review framing to a future display-title/intro owner.
- Decide whether to add 2-4 W12 review tasks after route admission planning.
- Build mapper allowlist, Practice CTA, stale-resume, and post-W6 progression gates in a later route-admission wave.
- Prepare Human QA protocol only after the route-visible copy packet exists.

## 15. Validation

Passed:

- `dart format` on touched Dart/test files.
- `flutter test test/ui_v2/act0_w7_completion_pack_v1_test.dart test/ui_v2/act0_w8_internal_world_source_template_v1_test.dart test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart test/ui_v2/act0_w11_w12_internal_world_source_template_batch_v1_test.dart --reporter expanded`
- `flutter analyze`
- `flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart --reporter expanded`

Required final checks before push:

- `git diff --check`; `git diff --cached --check`; `graphify hook-check`
- ASCII / trailing whitespace / CRLF / final-newline checks on changed docs

## 16. Score Impact

No W1-W12 readiness movement. No top-1 readiness movement.

Planning confidence may improve by `+0.1` max because focused copy-safety enforcement landed, but no public, Human QA, launch, monetization, route, or learning-effect claim becomes safe.

## 17. Forbidden Scope Proof

No route admission, learner-facing launch, W13+, UI/screen/navigation, card unlock, stale resume, Practice CTA, mapper allowlist, queue mutation, telemetry expansion, broad content expansion, screenshots, output folder changes, generated assets, monetization, Human QA execution, ML/AI/persona, solver/GTO claim, W1-W6 rework, or Modern Table work was performed.

## 18. Next Recommendation

Run `Volume I Route Admission Planning Gate v1` next only as a planning wave. It should map the display-title/intro owner, route-lock preservation, stale-resume policy, mapper no-target to allowlist transition, Practice CTA policy, and Human QA protocol updates before any route implementation.
