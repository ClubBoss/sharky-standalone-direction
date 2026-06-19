# Monetization EV Scenario Analysis v1

Status: docs/code audit and monetization strategy analysis only
Date: 2026-06-18

## 1. Executive verdict

Max-EV path:

**Soft premium preview after first daily/session completion now, preserve the
H1 structural boundary later: `W1-W4` free, `W5+` premium, contextual 7-day
trial only after value proof or a locked deeper-route attempt.**

This is scenario B in this analysis.

It is compatible with the earlier H1 default. The soft preview is not a paywall,
not a trial start, and not a purchase CTA. It is a priming/value-packaging layer
that makes the future `W5+` boundary feel expected and earned instead of
surprising.

Do not move directly to hard W5+ paywall implementation now. Public commerce is
still not production-ready: Premium Hub can reach a mock purchase path,
`PaymentService` still trusts local purchase/restored status, restore is not
receipt-verified, and the local ledger keeps public paywall hidden.

Single immediate next wave:

**Premium Value Preview Surface v1**

## 2. Evidence used

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` - Act0 shell is active app
  truth.
- `docs/plan/MASTER_PLAN_v3.0.md` - Product 100 includes value-before-premium
  and stable public model: `W1-W4` free, `W5-W36` premium.
- `docs/plan/MONETIZATION_RETENTION_MODEL_RECOMMENDATION_v1.md` - prior public
  model and H1-H5 EV simulation.
- `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md` - premium as
  depth/sharpening, not rescue gating.
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md` - real free
  trust-building route and premium depth boundary.
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md` - value and habit before stronger
  monetization friction.
- `docs/_reviews/final_first_week_commercial_proof_packet_v1.md` - compact
  English first-week loop accepted at 9.0/10.
- `docs/_reviews/value_monetization_packaging_planning_v1.md` - recommends
  soft premium value preview after first daily/session completion.
- `docs/_reviews/premium_monetization_existing_plan_reconciliation_v1.md` -
  reconciles active docs/code and recommends Premium Value Preview Surface v1.
- `docs/_reviews/commerce_entitlement_truth_audit_v1.md` - public commerce and
  Premium Hub remain unsafe until receipt/restore/entitlement truth is hardened.
- `docs/_reviews/entitlement_ledger_consolidation_design_v1.md` - ledger target
  and public-commerce requirements.
- `lib/services/entitlement_ledger_v1.dart` - local ledger exists, but public
  paywall and Premium Hub are hidden in access projection.
- `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart` - preview-only sheet with
  `Stay on free route`.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` - bounded Act0
  premium preview copy around optional table-clue practice.
- `lib/ui_v2/ui_v2_premium_hub.dart` - public-unsafe Premium Hub upgrade path
  still reaches mock premium purchase.
- `lib/services/premium_service.dart` and `lib/services/payment_gateway_service.dart`
  - mock purchase path remains.
- `lib/payments/payment_service.dart` - store purchase status is locally trusted,
  not production receipt verified.
- `docs/competitive/runout/RUNOUT_ONBOARDING_PAYWALL_NOTES.md` and
  `docs/competitive/runout/RUNOUT_FEATURE_MATRIX.md` - Runout benchmark has
  stronger paywall packaging but higher early-trust risk.

## 3. Prior H1-H5 decision summary

Prior hybrid scenarios:

1. `H1`: `W1-W4` free, `W5+` premium, contextual 7-day trial after first useful
   loop or locked deeper route.
2. `H2`: `W1-W4` free, `W5+` premium, 7-day trial shown immediately after
   placement.
3. `H3`: `W1-W4` free, `W5+` premium, no trial, paid start only at premium
   boundary.
4. `H4`: broad free route, premium only for advanced analytics / deep review /
   specialist tools.
5. `H5`: `W1-W4` free, `W5+` premium, contextual trial plus secondary paid
   analytics layer later.

Prior conclusion:

- `H1` is the best launch-default model.
- `H5` is the best long-horizon expansion path but too complex as launch
  default.
- `After W4` is the best structural boundary because it gives enough trust
  before paid depth without giving away too much of the main curriculum.
- The boundary and the offer moment are not the same thing.

This wave preserves that conclusion and adds one clarification:

**A soft preview after first completion is compatible with H1 if it does not
start trial, expose price, route to Premium Hub, or block learning.**

## 4. Current product/commercial state

Current strengths:

- First-week loop accepted at roughly 9.0/10.
- First value is table-first and free.
- Correct/wrong feedback proves visible table signals.
- Review repair is concrete and emotionally safe.
- Home/Practice/Profile/Learn have accepted compact English commercial proof.
- Current Act0 premium preview copy is bounded and optional.

Current commerce limits:

- `EntitlementLedgerV1` exists locally, but public paywall/Premium Hub remain
  hidden in access projection.
- Premium Hub can still call mock `PremiumService.buyPremium()`.
- Store purchase verification still trusts purchase/restored status.
- Restore and trial are local/prototype-safe, not production account truth.
- Public subscription copy for cancellation/refund/account restore is not ready.

Implication:

- Value packaging can move now.
- Real paywall cannot.

## 5. Scenario definitions

| Scenario | Definition | Relation to H1-H5 |
| --- | --- | --- |
| A | No premium preview until `W5+` hard boundary. | Conservative H1 without early priming. |
| B | Soft premium preview after first daily/session completion, then `W5+` hard premium boundary later. | H1 plus trust-safe priming. Recommended. |
| C | Direct hard `W5+` paywall/trial planning now, no earlier preview. | H1 boundary work before value-preview packaging. |
| D | Early hard paywall/trial after onboarding or placement result. | H2 / hard-funnel variant. |
| E | Long free route, premium only deep mastery / later advanced route. | H4 / delayed monetization. |
| F | H5-style later analytics/leak-profile upsell after H1 proves route subscription fit. | Long-horizon H5 expansion. |
| G | H3 no-trial launch: `W1-W4` free, `W5+` paid, no contextual trial. | Safe fallback if trial remains risky. |

Score convention:

- 10 is best.
- For risk columns, higher score means lower risk / safer.
- These are directional planning scores, not measured cohort data.

## 6. Scenario score table

| Scenario | Activation | First-session trust | D1 retention | D7 retention | First purchase conversion | Long-term LTV | Refund/churn safety | App Store review safety | Beginner confidence | Brand/trust | Implementation safety | Commerce safety | Product-truth fit | Runout competitiveness | Top-1 ambition | Average |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A. No preview until W5 | 8.7 | 9.2 | 8.2 | 8.0 | 7.0 | 8.1 | 8.6 | 8.8 | 9.0 | 8.8 | 8.2 | 8.4 | 8.7 | 7.3 | 8.0 | 8.3 |
| B. Soft preview + W5 boundary | 8.8 | 9.0 | 8.5 | 8.4 | 8.1 | 8.8 | 8.4 | 8.7 | 8.9 | 8.9 | 8.0 | 8.3 | 9.0 | 8.4 | 8.9 | 8.6 |
| C. Direct W5 paywall planning now | 8.5 | 8.8 | 8.1 | 8.1 | 7.8 | 8.5 | 7.8 | 7.2 | 8.6 | 8.3 | 6.4 | 5.5 | 8.3 | 8.0 | 8.3 | 7.8 |
| D. Early hard paywall/trial | 6.4 | 5.6 | 5.8 | 5.9 | 7.6 | 6.8 | 5.4 | 5.8 | 5.5 | 5.7 | 5.8 | 4.8 | 5.8 | 7.6 | 6.0 | 6.2 |
| E. Long free route / deep mastery only | 9.2 | 9.4 | 8.7 | 8.2 | 4.8 | 6.2 | 8.9 | 9.2 | 9.3 | 9.1 | 7.4 | 8.4 | 7.5 | 6.2 | 6.7 | 7.6 |
| F. H5 later analytics upsell | 8.6 | 8.7 | 8.4 | 8.5 | 8.0 | 9.2 | 7.8 | 7.5 | 8.4 | 8.5 | 5.4 | 5.8 | 7.4 | 8.8 | 9.0 | 7.9 |
| G. H3 no-trial W5 paid | 8.7 | 9.0 | 8.1 | 7.9 | 6.9 | 8.0 | 8.7 | 8.9 | 8.9 | 8.7 | 8.4 | 8.5 | 8.5 | 7.2 | 7.7 | 8.1 |

Read:

- B wins because it raises later conversion and Runout competitiveness without
  materially damaging trust.
- A and G are safe but leave monetization priming too weak.
- C is strategically valid later, but premature while commerce truth is unsafe.
- D creates too much trust damage for Sharky's differentiator.
- E under-monetizes the main curriculum.
- F is attractive later, not now.

## 7. Directional EV model

Assumptions:

- Current first-week proof is strong enough that users can understand value
  before premium messaging.
- No scenario may expose real purchase until commerce safety is production-ready.
- Conversion rates are directional, not measured.
- Early pressure can increase immediate trial starts while lowering paid quality,
  refund safety, and retention.

| Scenario | Activation impact | Conversion timing | Conversion direction | Retention/LTV direction | Trust-harm probability | Net EV | Confidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | Neutral/high | Late at W5 | Medium | Medium-high | Low | High | Medium |
| B | Neutral/high | Preview after completion, hard gate later | Medium-high | High | Low-medium | Highest | Medium-high |
| C | Neutral | Planning now, gate later | Medium-high later | High later | Medium if surfaced early | Medium-high later, medium now | Medium |
| D | Negative | Very early | High short-term, low quality | Medium-low | High | Low-medium | High |
| E | High | Very late | Low | Medium | Very low | Medium | Medium |
| F | Neutral | Later secondary upsell | High long-term | Highest if executed later | Medium-high if too early | High later, not now | Medium |
| G | Neutral/high | W5 paid only | Medium-low | Medium-high | Low | High, below B | Medium |

Directional funnel read:

- A likely preserves strong free activation but creates a cold premium boundary.
- B adds light value priming after proof, increasing expected W5 conversion by
  making premium feel anticipated and optional.
- C protects H1 but spends a wave on a gate that cannot be safely implemented
  yet.
- D may spike trial starts but likely worsens D1/D7, refund risk, and brand
  trust.
- E maximizes goodwill but delays monetization beyond the strongest beginner
  route subscription moment.
- F is best once route subscription fit is proven, because analytics/leak tools
  can raise ARPU for serious users; before that, it distracts from the core.
- G is a safe fallback if trial/legal/receipt work stalls, but loses healthy
  trial-led conversion upside.

## 8. Trust and retention analysis

Soft preview after first completion is low trust risk because:

- it follows actual learning value;
- it does not interrupt first feedback;
- it does not ask for money;
- it can reinforce the value already felt;
- it can keep the free route as the dominant action.

It would become harmful if:

- it auto-opens loudly;
- it mentions price, restore, trial, or purchase;
- it appears before daily/session completion;
- it suggests core learning requires payment;
- it claims AI, solver, guaranteed improvement, or all-feature unlock.

Retention effect:

- B should improve D7 modestly versus A because it frames a longer route earlier
  without blocking the current habit loop.
- D should harm D1/D7 because it makes monetization part of the first emotional
  impression before Sharky proves the table-signal loop.
- E may improve early retention but weakens paid intent because users learn to
  treat the main route as free.

## 9. Revenue and LTV analysis

Revenue quality matters more than first trial count.

Best revenue shape:

1. prove learning;
2. show that the app has deeper paid value;
3. let the learner complete enough free route to trust the product;
4. gate `W5+` as paid depth;
5. offer contextual 7-day trial at a proof moment or locked deeper-route attempt;
6. add H5-style analytics/leak-profile upsell only after route subscription fit.

Why B should improve W5 conversion:

- It reduces surprise at the W5 boundary.
- It positions premium as more of the same useful practice.
- It lets commercial packaging start before the gate without creating pressure.
- It keeps the user's first paid decision attached to remembered table-signal
  proof.

Why hard paywall planning now is lower EV:

- The hard gate cannot ship until commerce safety is fixed.
- A planning wave for the gate does not improve current user experience.
- Soft preview can improve future conversion while commerce hardening continues
  later.

## 10. Commerce safety constraints

Soft preview before receipt verification:

- Allowed if it has no purchase, trial-start, restore, price, plan selection, or
  Premium Hub route.
- It is product/value packaging, not commerce.

Hard paywall before receipt verification:

- Not allowed.
- Public paywall requires production receipt verification, store-safe purchase
  semantics, restore convergence, cancellation/refund/support copy, and active
  entitlement-gating tests.

Current blockers:

- Premium Hub can still reach mock `PremiumService.buyPremium()`.
- `PaymentGatewayService` is explicitly mock.
- `PaymentService._verifyPurchase(...)` locally trusts purchase/restored status.
- Trial is local and clock based.
- Restore is not production receipt/account truth.
- Public cancellation/refund/account copy is absent.

## 11. Runout comparison

Runout advantage:

- stronger hard commercial funnel;
- mature paywall assets;
- discount/trial packaging;
- broader analytics/progress commercial story.

Runout risk:

- hard paywall before value can damage trust;
- personalization can feel black-box;
- advanced/GTO posture can intimidate beginners.

Sharky response:

- use Runout's premium packaging principle;
- keep table-signal proof as the trust engine;
- introduce premium after real value;
- defer hard paywall until commerce truth is production-safe;
- make W5+ premium feel like deeper table practice, not rescue gating.

## 12. Compatibility with W5+ hard boundary

Soft preview after first completion is compatible with H1 because:

- it does not change structural access;
- `W1-W4` can remain the free foundation;
- `W5+` can remain the paid-depth boundary;
- the preview does not start trial or purchase;
- it can make the later W5 boundary feel coherent.

Recommended boundary:

- `W1-W4` free.
- `W5-W36` premium.
- First paid gate: attempt to open `W5` or continue beyond W4 after completing
  the free foundation.
- First trial offer: contextual 7-day trial at the W5 boundary or after another
  meaningful value proof, not immediately after placement.

Answering the core questions:

1. Soft preview after first completion is compatible with old H1.
2. `W5+` hard boundary should remain the later target.
3. Soft preview should increase W5 conversion by reducing surprise and framing
   premium as earned depth.
4. Early preview has low trust risk if it stays passive and post-completion.
5. Preview can ship before receipt verification only because it is not commerce.
6. Hard paywall must not ship before receipt verification is production-ready.
7. Highest-EV promise: more practice on proven table clues, deeper repair, and
   longer route depth after the free foundation.
8. Best free route length remains `W1-W4`.
9. First paid gate should be `W5+`.
10. Next wave should be Premium Value Preview Surface v1.

## 13. Recommended max-EV path

Adopt scenario B:

1. Keep first session and first feedback monetization-free.
2. Add one optional soft premium preview after first daily/session completion.
3. Preserve `W1-W4` free.
4. Preserve `W5+` premium as the later structural hard boundary.
5. Contextual 7-day trial appears only after value proof and only once public
   commerce/trial policy is safe.
6. Defer H5 analytics/leak-profile upsell until H1 route subscription fit is
   proven.

Premium promise:

**Free proves Sharky can improve your table read. Premium gives you more reps
on the same table clues, deeper repair, and a longer route once you want to
sharpen faster.**

## 14. Recommended immediate next wave

Run exactly one next wave:

**Premium Value Preview Surface v1**

Scope:

- one optional preview entry after first daily/session completion;
- use current `Act0PremiumPreviewSheetV1` pattern if sufficient;
- keep the primary action on free learning continuation;
- no price, purchase, trial start, restore, Premium Hub, public paywall, or
  entitlement change;
- copy limited to table-clue reps, extra practice, deeper review, longer route
  depth;
- focused tests should guard:
  - no premium before first value;
  - no price/purchase/restore/trial/Premium Hub route;
  - no AI/GTO/solver/guaranteed/all-unlock claims;
  - preview appears only after completion.

Why this wave beats alternatives now:

- It captures Runout-style value packaging without Runout-style pressure.
- It improves future W5 conversion while public commerce remains parked.
- It does not depend on receipt verification.
- It is smaller and more product-forward than hard paywall planning.

## 15. Deferred decisions

- exact W5 paywall UI and offer ceremony;
- public pricing and discount policy;
- annual/monthly packaging;
- trial start implementation and policy copy;
- receipt verification backend/platform policy;
- verified restore/account convergence;
- cancellation/refund/support copy;
- App Store / Play Store subscription metadata;
- H5 analytics/leak-profile upsell;
- Skill Map / Leak Profile Lite as a paid packaging layer;
- advanced personalization claims;
- RU/non-English monetization QA.

## 16. Risks and stop conditions

Risks:

- Preview becomes too loud and harms the completion reward.
- Copy implies paid access is needed for basic value.
- Stakeholders mistake preview readiness for paywall readiness.
- W5 boundary copy later overclaims "unlock all" or analytics value.
- Commerce hardening lags behind value packaging.

Stop conditions:

- Stop if the next wave requires purchase, trial, restore, Premium Hub, or
  entitlement changes.
- Stop if preview must appear before first daily/session completion.
- Stop if copy needs unsupported AI/adaptive/GTO/solver/guaranteed claims.
- Stop if implementation changes route order, scoring, table, telemetry, or
  content.
- Stop if it recommends a public hard paywall before receipt/restore truth is
  production-ready.

## 17. Files changed

- `docs/_reviews/monetization_ev_scenario_analysis_v1.md`

## 18. Verification

Required docs-only verification:

- `git diff --check` - passed.

No tests or screenshots are required because this wave does not touch product
code, UI, copy, routes, telemetry, commerce, entitlement, screenshots,
Playwright tooling, or localization.

## 19. Direction score

Current monetization direction: **9.1 / 10**.

Rationale:

- The H1 boundary remains the best launch default.
- Soft preview improves the path to W5 conversion without adding hard friction.
- Public commerce remains correctly parked.
- H5 expansion is preserved for later LTV upside.
- Sharky keeps its differentiator: value-before-paywall learning proof.
