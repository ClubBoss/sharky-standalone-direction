# Volume I Pre-Human QA Actionable Gap Repair + P2 Adjudication Pack v1

Date: 2026-07-01
Starting HEAD: 05bd3fa4da7360d45e6cbf6f72e5804c3a840e40
Challenger source: `/Users/elmarsalimzade/Desktop/Audit 3.md`
Scope: W1-W12 route-visible copy, guards, and review artifacts only.

## 1. Verdict

pre_human_repairs_and_p2_adjudication_landed

All five P1 repairs were completed. P2-01, P2-06, and P2-08 were classified
`repair_now` and repaired in the same batch. P2-02 was deferred until the
mapper/Practice gate. P2-03 was blocked by scope. P2-04, P2-05, and P2-07
remain Human QA watch items.

## 2. Stage 0 Summary

| Check | Result |
| --- | --- |
| HEAD | `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40` |
| Branch | `main` |
| origin/main sync | `HEAD` and `origin/main` were mutual ancestors; no divergence. |
| Dirty/untracked state at start | Only two accepted untracked review artifacts and untracked `output/` folders were present. |
| Prior artifact state | `docs/_reviews/volume_i_e2e_curriculum_product_quality_gate_planning_v1.md` and `docs/_reviews/full_w1_w12_e2e_curriculum_product_quality_gate_v1.md` were untracked and preserved. |
| Output/generated assets | `output/` contents, screenshots, and generated assets were not inspected or staged. |

## 3. P1 Repairs Completed

| P1 | Status | Files touched | Learner-facing outcome | Guards | Remaining Human QA watchlist |
| --- | --- | --- | --- | --- | --- |
| REPAIR-01 W12 terminal fallback explanation | fixed | `lib/services/progress_service.dart`, `lib/campaign/campaign_pack_registry_v1.dart`, `lib/canonical/canonical_truth_map_v1.dart`, W12 guard | W12 completion now routes to `volume_i_terminal_review_v1`, not W6 seat-label copy. Terminal copy says Volume I review is complete, W13 is not open, and the visible next activity is review/keep-sharp. | W12 completion and terminal-copy guard updated. | Observe whether terminal review feels satisfying, not repetitive. |
| REPAIR-02 W4/W10 naming collision | fixed | W10 route pack, W10 guard | W10 first route-visible context now says W4 showed bets and prices exist, W9 asked about call price, and W10 asks what the bet is trying to accomplish now. | W10 guard requires W4/W9/W10 distinction. | Watch whether W10 still feels redundant to beginners. |
| REPAIR-03 W5 -> W8 draw vocabulary bridge | fixed | W8 route pack, W8 guard, jargon guard | W8 first route-visible context reconnects W5 outs/draws before introducing W8 draw improvement types. | W8 guard requires W5, outs, draw, and improve in first W8 copy. | Watch whether the W5 recall is strong enough after W6/W7. |
| REPAIR-04 W12 payoff arc | fixed | W12 route packs, W12 guard | W12 payoff now names concrete Volume I clue families: visible cards/ranges, draws, call price, bet purpose, texture, and missed-cue explanation. | W12 guard requires Volume I and concrete cue families while blocking claim-risk terms. | Watch payoff feel versus quiz feel. |
| REPAIR-05 W7-W12 first-use jargon audit | fixed | New jargon audit, new jargon guard, W8/W9/W10/W12 guards | First-use terms were audited and bounded gaps fixed in route-visible copy. | New `w7_w12_first_use_jargon_contract_test.dart`. | Human QA should still observe subjective jargon load. |

## 4. P2 Adjudication Table

| ID | Issue | Codex classification | Reason | Owner seam if repairable | Repair included | Files touched if repaired | Validation / deferred note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P2-01 | W9/W10 cross-world repair handling | repair_now | A copy-only bridge can clarify W9 caller price versus W10 bettor target without building a cross-world repair system. | W10 first route-visible context and W10 guard. | yes | W10 route pack, W10 guard | Focused W10 guard passed. |
| P2-02 | W7-W12 Practice CTA absent | defer_until_mapper_practice_gate | Safe repetition needs mapper/Practice ownership. Terminal keep-sharp copy can explain review state but must not implement CTA or allowlist. | Not safely repairable now. | no | n/a | Deferred until mapper/Practice gate. |
| P2-03 | W3 scenario richness / two canonical families | blocked_by_scope | Adding richness requires source/family expansion or source-remap work, not a safe copy-only repair. | No bounded safe owner seam. | no | n/a | Blocked by scope; observe in Human QA. |
| P2-04 | W2 bridge-limited remainder | watch_in_human_qa | Targeted read found no concrete machine-actionable copy issue that can be safely fixed without broad W2 history/rewrite. | No repair seam selected. | no | n/a | Watch bridge-limited remainder in Human QA. |
| P2-05 | W6 -> W7 cognitive pivot / W6 thinness | watch_in_human_qa | W6 completion and W7 intro already seed visible-cards/range continuity; richness risk needs learner observation or content expansion. | No repair seam selected. | no | n/a | Highest-priority Human QA transition observation. |
| P2-06 | W8 -> W9 ask-before-teach risk | repair_now | W9 first route-visible copy could safely bridge draw spotting to call price. | W9 first route-visible context and W9 guard. | yes | W9 route pack, W9 guard | Focused W9 guard passed. |
| P2-07 | W1 broad copy sweep incomplete | watch_in_human_qa | Targeted W1 intro/action/street read found no concrete bounded claim/jargon/confusing copy fix; broad polish is forbidden. | No repair seam selected. | no | n/a | Watch W1 intro/action/street clarity in Human QA. |
| P2-08 | W1-W12 soft-claim sweep incomplete | repair_now | Targeted route-visible sweep found risky soft wording in touched W7-W12 pack copy. | W8-W12 route pack copy and guards. | yes | W8/W9/W10/W11/W12 route copy, W8/W9/W10/W12 guards | Focused guards passed; residual benign hits are test assertions, scoring text, or non-route W1-W6 legacy copy outside this repair scope. |

## 5. P2 Repairs Completed

| P2 | Status | Learner-facing outcome | Validation | Remaining risk |
| --- | --- | --- | --- | --- |
| P2-01 | fixed | W10 now explicitly distinguishes W4 bets/prices, W9 call price, and W10 bettor target. | W10 guard passed. | True cross-world repair system remains post-QA backlog if learners miss both concepts. |
| P2-06 | fixed | W9 now opens with draw-to-price motivation: after spotting a draw, ask whether the call price is worth paying for pot reward. | W9 guard passed. | Human QA must still test whether this bridge lands. |
| P2-08 | fixed | Removed or softened risky route-visible wording around solved/every spot/guarantee/always/never/public-launch style claims in touched W7-W12 seams. | Focused guard subset passed. | Full subjective soft-claim perception remains a Human QA watch item. |

## 6. Jargon Audit Summary

Terms audited: visible cards; range/range narrowing; possible hands; draw;
flush draw; open-ended straight draw; one-gap/gutshot-style draw; pot; call
price; odds; risk/reward; value bet/value; worse hands call; stronger hands
fold; dry board; connected board; suited texture; danger; board texture; missed
cue.

Terms fixed: draw, flush draw context, pot/call price bridge, value/worse hands
call/stronger hands fold first-use context, suited texture/danger soft wording,
missed cue and W12 payoff context.

Terms verified safe: visible cards, range, possible hands, open-ended straight
draw, one-gap/gutshot-style draw, odds, risk/reward, dry board, connected board,
board texture.

Terms still requiring Human QA observation: W6-to-W7 range pivot, W8 draw-type
load, W9 pot/price math feel, W10 target-hand language, W11 danger/texture
language, and W12 payoff feel.

## 7. Soft-Claim Sweep Summary

Route-visible owners searched: `lib/campaign/campaign_pack_registry_v1.dart`,
focused W7-W12 route guards, and the W12 terminal route seam in
`lib/services/progress_service.dart`.

Risky copy found: W8 "solved/already complete" style negative examples, W9
"guarantee/every spot" style wording, W10 "every bet" blend wording, W11
"never/always/solves/guarantee" style wording, and W12 "course proves every
spot/solved" wording.

Fixes made: replaced those phrases with bounded beginner-safe wording such as
"made now", "predict the result", "blend the two jobs without checking
targets", "ignore suits completely", "overtrust one pair", and "does not
promise later results."

Terms guarded: W8 solved/already-complete, W9 every-spot/guarantee-outcome,
W10 W4/W9 distinction, W12 every-spot/solved/public/launch/top-1/10/10/learning
effect.

Remaining watchlist: soft implication of competence, readiness, or durable
learning effect must remain part of Human QA observation.

## 8. Opportunistic P3 Fixes

None. No standalone P3 repair was made.

## 9. Claim-Safety Section

- No readiness score movement.
- No top-1 or 10/10 claim.
- No premium, public, or launch readiness claim.
- No Human-QA-ready claim.
- No Human QA pass.
- No public learning-effect claim.
- No monetization readiness claim.
- W13+ remains blocked.
- Mapper and Practice remain blocked; terminal copy mentions review/keep-sharp
  state only and does not implement a CTA, allowlist, mapper target, or launch.

## 10. Next Chat Handover

- Current HEAD before commit: `05bd3fa4da7360d45e6cbf6f72e5804c3a840e40`.
- Artifact path: `docs/_reviews/volume_i_pre_human_qa_actionable_gap_repair_p2_adjudication_pack_v1.md`.
- Verdict: `pre_human_repairs_and_p2_adjudication_landed`.
- P1 repairs completed: W12 terminal pack, W10 differentiation, W8 draw bridge, W12 payoff arc, W7-W12 jargon audit.
- P2 repaired: P2-01, P2-06, P2-08.
- P2 deferred/watch/blocked: P2-02 deferred mapper/Practice gate; P2-03 blocked by scope; P2-04/P2-05/P2-07 Human QA watch.
- Remaining yellow/P2/P3 watchlist: W1 copy clarity, W2 bridge-limited remainder, W3/W6 richness, W6->W7 pivot, W8->W9 learner perception, W11 danger vocabulary, W12 payoff/terminal feel, premium feel P3.
- Selected next prompt title: Volume I Human QA Readiness Pack After Actionable Gap Repair v1.
- Forbidden next scope: no Human QA pass claim, no score movement, no W13+, no mapper/Practice implementation, no monetization/public launch/readiness claim.
- Token/context notes: broad repo read was avoided; highest-cost reads were the active campaign registry and focused guard files. Next wave should reuse this artifact plus the jargon audit instead of rereading W7-W12 source broadly.
