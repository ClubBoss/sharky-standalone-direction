# Blind Monetization Strategy Challenge v1

Status: independent strategy audit only
Date: 2026-06-18

## 1. Executive verdict

The strongest launch-default monetization strategy is:

**Value-first free foundation, soft premium preview after a completed useful
session, then a real `W5+` paid-depth boundary only after commerce safety is
production-ready.**

This confirms the broad current direction, but with three stricter guardrails:

1. The soft preview is not a paywall, not a trial start, not a price page, and
   not a route to Premium Hub while mock purchase remains reachable.
2. `W5+` is the best first hard boundary, but only as a future production gate
   after receipt, restore, entitlement, and subscription copy truth are closed.
3. High-intent behavior-based gating should become an experiment later, not the
   launch-default model.

Why this wins:

- Sharky's current advantage is trust: free table-first value, deterministic
  signal feedback, concrete repair, and honest first-week proof.
- A hard early gate increases short-term conversion pressure but weakens the
  exact trust advantage that differentiates Sharky from paywall-first trainers.
- A long free route builds goodwill but under-monetizes the main curriculum.
- Usage caps and repair gates create frustration in the learning loop.
- A soft preview after value is the only immediate move that improves future
  conversion without requiring public commerce readiness.

Immediate next wave:

**Premium Value Preview Surface v1**

Scope constraint for that wave: preview-only, post-completion, English-first,
no price, no trial, no restore, no purchase, no Premium Hub route, no unsupported
AI/GTO/solver/guaranteed-result claims.

## 2. First-principles candidate models generated before reading latest recommendations

The independent candidate set was generated from Sharky's product type and
current accepted state: a beginner-safe poker learning app with a strong free
first-week proof loop but unsafe public commerce.

| Model | Core idea | First-principles read before reconciliation |
| --- | --- | --- |
| Hard pre-value paywall | Paywall before first real learning proof. | Revenue-aggressive but strategically wrong for a trust-first learning product. |
| W3 hard boundary | Give W1-W2 free, gate position/table-read depth at W3. | Too early; risks charging before the learner trusts the route. |
| W4 hard boundary | Give W1-W3 free, gate W4. | Better than W3, still slightly early for beginner confidence and repair proof breadth. |
| W5 hard boundary | Give W1-W4 free, gate W5+. | Best structural hard boundary because it gives real foundation while preserving paid depth. |
| No early premium preview | Stay fully free-looking until the gate. | Trust-safe, but makes the future gate cold and surprising. |
| Soft premium preview | Show optional premium value after completed learning value. | Highest immediate EV if kept non-blocking and commerce-safe. |
| Usage / daily cap | Limit free reps per day or session count. | Familiar freemium mechanic, but bad fit for deliberate learning and repair trust. |
| Dynamic behavior gate | Gate faster or differently based on high-intent behavior. | Attractive later; too complex and too easy to feel arbitrary at launch. |
| Repair-based gate | Charge for deeper repairs or repeated weak-spot fixes. | Monetizes real pain, but emotionally risky for beginners if introduced early. |
| Trial after first completion | Offer trial immediately after first daily/session result. | Stronger than pre-value trial, but still too early while commerce is unsafe. |
| Trial after W3/W4/W5 | Trigger trial near a meaningful locked depth point. | Best trial timing class; W5 is safest launch boundary. |
| One-time starter pack | Sell fixed beginner pack instead of subscription. | Reduces commitment friction but weakens long-horizon subscription identity. |
| Subscription-only | Paid subscription owns all premium depth. | Best durable business shape, but must not be first-touch pressure. |
| Freemium with paid depth | Real free foundation plus paid later route/mastery depth. | Best strategic base. |
| Long free foundation with premium mastery | Keep much more route free, charge only for advanced mastery. | Trust-rich but under-monetizes the main beginner/improver market. |
| Analytics/leak-profile upsell later | Sell deeper insight after enough behavior data exists. | High-LTV expansion later; not credible as launch monetization. |
| Hybrid | Free W1-W4, soft preview after value, W5+ subscription, later analytics upsell. | Best long-run shape, but launch should ship only the first two pieces safely. |

## 3. Evidence reviewed

Primary strategy and policy evidence:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/MONETIZATION_RETENTION_MODEL_RECOMMENDATION_v1.md`
- `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md`
- `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md`
- `docs/plan/MONETIZATION_TIMING_GUARD_v1.md`

Recent review evidence:

- `docs/_reviews/final_first_week_commercial_proof_packet_v1.md`
- `docs/_reviews/value_monetization_packaging_planning_v1.md`
- `docs/_reviews/premium_monetization_existing_plan_reconciliation_v1.md`
- `docs/_reviews/monetization_ev_scenario_analysis_v1.md`
- `docs/_reviews/commerce_entitlement_truth_audit_v1.md`
- `docs/_reviews/entitlement_ledger_consolidation_design_v1.md`

Code evidence:

- `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart`
- `lib/ui_v2/ui_v2_premium_hub.dart`
- `lib/services/entitlement_ledger_v1.dart`
- `lib/services/premium_service.dart`
- `lib/services/payment_gateway_service.dart`
- `lib/payments/payment_service.dart`

Competitive reference:

- `docs/competitive/runout/RUNOUT_REFERENCE_SUMMARY.md`
- `docs/competitive/runout/RUNOUT_ONBOARDING_PAYWALL_NOTES.md`
- `docs/competitive/runout/RUNOUT_FEATURE_MATRIX.md`

Evidence summary:

- Current first-week proof is accepted at `9.0/10`.
- Act0 premium preview exists as a preview-only sheet with `Stay on free route`.
- Premium Hub is public-unsafe because upgrade still reaches a mock purchase
  path.
- `PaymentService` still treats purchased/restored stream status as verified
  pending future receipt hardening.
- `EntitlementLedgerV1` exists, but projections keep public paywall hidden and
  Premium Hub hidden; local states are not production commerce truth.
- Runout appears stronger in commercial packaging and paywall infrastructure,
  but Sharky's differentiator is value-before-paywall proof.

## 4. User segment analysis

| Segment | Activation | Trust | Chance to reach paid gate | Conversion direction | Refund/churn risk | LTV direction | Best premium timing |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Complete beginner | Needs zero-pressure proof and beginner-safe copy. | Highest sensitivity to early paywall. | Moderate if W1-W4 are free and useful. | Low before value, medium after foundation. | High if gated at W3 or after a mistake. | Medium if nurtured. | Soft preview after completion; hard gate no earlier than W5. |
| Motivated beginner | Wants quick confidence. | Good if table proof feels real. | High if daily loop stays clear. | Medium-high after first visible improvement. | Medium if trial promise is too broad. | High with route depth. | Preview after result, trial at W5/locked depth. |
| Recreational poker player | Wants useful practical reads, not schoolwork. | Good if feedback is table-native. | High if early content avoids jargon. | Medium-high after several real spots. | Medium if cap blocks momentum. | High if depth keeps practical. | W5 boundary with optional trial. |
| High-intent learner | May tolerate earlier paid framing. | Less fragile, but still needs proof. | Very high. | High after clear route depth is visible. | Lower if premium promise is precise. | Highest. | Future behavior-based offer after preview click, fast W4 completion, or locked W5 attempt. |
| Low-intent/free user | Will leave if pressured. | Fragile. | Low-medium. | Low. | Medium if pushed; low if left alone. | Low. | Keep free route dominant; no hard early pressure. |
| Price-sensitive but engaged user | Needs proof and low regret. | High if free foundation is generous. | Medium-high. | Medium with monthly/trial option later. | High if offer feels like a trap. | Medium-high if trust is preserved. | Trial at W5; annual as value anchor, monthly as low-friction option. |
| Returning user after D1/D2 | Has felt value and return reason. | Stronger than first session. | Medium-high. | Medium-high for soft preview. | Low-medium if no pressure. | High if daily progress continues. | Passive preview on Home/Practice completion. |
| User who clicks premium preview | Self-selects intent. | Depends on preview honesty. | High. | Higher later if preview remembers proof. | Medium if sent to mock/unsafe commerce. | High if routed to future real offer. | Future commerce-safe offer after W5 or second proof. |
| User who completes free foundation quickly | Strong signal of intent. | Likely high. | Very high. | Highest for contextual trial. | Low if paid depth is real. | Highest. | W5 locked-depth trial/paywall once commerce is safe. |

Segment verdict:

- One launch-default strategy should serve all users because the first public
  model must be simple and trustworthy.
- High-intent users should eventually receive a different offer timing, but
  only as a future experiment after the base model, commerce truth, and event
  semantics are stable.

## 5. Monetization model score table

Score convention: `10` is best. For risk/complexity columns, higher means safer
or simpler. These are directional strategy scores, not measured cohort data.

| Model | Activation | D1 | D7 | D30/LTV | Conv. | Rev quality | Refund safe | App review | Beginner conf. | Brand/trust | Impl. simple | Commerce safe | Truth fit | Runout comp. | Top-1 | Avg |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Hard pre-value paywall | 4.8 | 4.2 | 4.0 | 5.6 | 7.3 | 5.5 | 4.0 | 4.5 | 3.8 | 3.9 | 5.5 | 2.5 | 3.8 | 6.8 | 4.2 | 4.7 |
| W3 hard boundary | 6.6 | 6.1 | 5.9 | 6.8 | 7.0 | 6.7 | 5.8 | 6.2 | 5.8 | 6.1 | 6.2 | 3.8 | 6.2 | 7.2 | 6.3 | 6.3 |
| W4 hard boundary | 7.5 | 7.2 | 7.0 | 7.6 | 7.4 | 7.4 | 6.7 | 6.8 | 7.0 | 7.2 | 6.2 | 3.8 | 7.4 | 7.8 | 7.4 | 7.1 |
| W5 hard boundary, no preview | 8.5 | 8.1 | 7.9 | 8.1 | 7.0 | 7.8 | 8.1 | 8.0 | 8.7 | 8.5 | 6.5 | 4.0 | 8.4 | 7.4 | 8.0 | 7.7 |
| Soft preview + W5 boundary | 8.7 | 8.5 | 8.4 | 8.8 | 8.1 | 8.5 | 8.3 | 8.4 | 8.8 | 8.9 | 8.0 | 8.3 | 9.1 | 8.6 | 9.0 | 8.6 |
| Usage / daily cap | 7.2 | 6.7 | 6.3 | 7.0 | 7.2 | 6.8 | 5.9 | 6.5 | 6.2 | 6.0 | 5.8 | 4.5 | 5.8 | 7.1 | 6.2 | 6.5 |
| Dynamic behavior gate | 8.0 | 7.7 | 7.8 | 8.6 | 8.4 | 8.4 | 7.0 | 6.8 | 7.4 | 7.5 | 4.2 | 3.5 | 6.8 | 8.5 | 8.5 | 7.4 |
| Repair-based gate | 7.0 | 6.6 | 6.5 | 7.5 | 7.5 | 7.2 | 5.8 | 6.4 | 5.9 | 6.0 | 5.6 | 4.0 | 6.4 | 7.6 | 6.8 | 6.6 |
| Trial after first completion | 8.2 | 8.0 | 7.8 | 8.2 | 8.0 | 7.6 | 6.8 | 6.5 | 8.0 | 7.9 | 5.4 | 3.0 | 7.8 | 8.2 | 8.1 | 7.4 |
| Trial at W5 locked depth | 8.5 | 8.3 | 8.2 | 8.8 | 8.2 | 8.5 | 8.0 | 8.0 | 8.7 | 8.8 | 5.8 | 3.5 | 8.8 | 8.5 | 8.8 | 8.0 |
| One-time starter pack | 8.0 | 7.8 | 7.2 | 6.8 | 7.6 | 6.8 | 7.8 | 7.8 | 8.2 | 8.0 | 5.8 | 3.8 | 7.2 | 7.1 | 6.5 | 7.2 |
| Subscription-only depth | 8.1 | 7.8 | 7.8 | 8.6 | 7.7 | 8.4 | 7.3 | 7.4 | 7.8 | 8.0 | 5.5 | 3.5 | 8.2 | 8.1 | 8.3 | 7.6 |
| Long free foundation / paid mastery | 9.0 | 8.8 | 8.4 | 7.6 | 5.3 | 6.0 | 8.9 | 8.9 | 9.1 | 9.0 | 7.0 | 7.5 | 7.6 | 6.7 | 7.0 | 7.7 |
| Later analytics upsell | 8.2 | 8.0 | 8.1 | 9.0 | 7.8 | 8.8 | 7.4 | 7.0 | 7.8 | 8.0 | 3.8 | 3.2 | 6.5 | 8.7 | 8.8 | 7.5 |
| Full hybrid long-run | 8.6 | 8.4 | 8.5 | 9.3 | 8.4 | 9.0 | 7.8 | 7.6 | 8.5 | 8.8 | 3.5 | 3.0 | 7.8 | 9.0 | 9.3 | 8.1 |

The score table has two important readings:

- The best immediate strategy is not the highest theoretical long-run model.
  Full hybrid can beat the simple launch model later, but it is too complex and
  commerce-unsafe now.
- Soft preview plus W5 boundary wins launch EV because it is the highest score
  that does not require public purchase safety today.

## 6. W3 vs W4 vs W5 analysis

| Boundary | Strength | Failure mode | Verdict |
| --- | --- | --- | --- |
| W3 | Earlier revenue intent capture; preserves more paid content. | Charges before enough beginner trust, repair confidence, and route depth are visible. | Too early for launch default. |
| W4 | Better trust than W3; monetizes before too much route is free. | Still risks gating while the learner is forming table literacy and confidence. | Plausible future test, not best default. |
| W5 | Gives W1-W4 as a real foundation, then paid depth starts when the learner understands the product. | Later conversion moment; needs preview/priming so it does not feel sudden. | Best hard boundary. |

W5 wins because it balances:

- enough real free value;
- enough route depth left to sell;
- lower beginner refund risk;
- better App Store review safety;
- better alignment with Sharky's proof-first brand.

## 7. Usage cap vs world gate vs dynamic gate analysis

| Gate type | EV read | Why it loses or wins |
| --- | --- | --- |
| Hard world gate | Best structural model. Easy to understand and easy to support. | Wins if placed at W5 and only shipped after commerce safety. |
| Usage / daily cap | Familiar and measurable. | Loses because it interrupts learning rhythm and can make repair feel artificially withheld. |
| Dynamic behavior gate | Potentially strongest for high-intent users. | Loses as launch default because it can feel arbitrary, requires more telemetry confidence, and invites accidental fake-personalization claims. |
| Repair-based gate | Monetizes concrete pain. | Loses early because it risks charging at the user's vulnerable mistake moment. Better as later repair-depth packaging after trust. |

Launch-default gate should be a clear world/depth boundary, not usage friction
or opaque behavior gating.

Future high-intent experiment can use behavior signals such as:

- clicked premium preview;
- completed W1-W4 quickly;
- repeated optional extra reps;
- attempted locked W5 content;
- completed multiple repairs and returned.

## 8. Trial timing analysis

| Trial timing | Verdict |
| --- | --- |
| Before placement / app-open | Reject. Highest trust and review risk. |
| After placement result | Too early. User has been routed, not helped. |
| After first correct/wrong feedback | Too close to the first emotional learning moment. Preserve the aha. |
| After first daily/session completion | Good for future, but not while commerce is unsafe. Use preview-only now. |
| On D2 return | Strong future candidate because habit credibility is higher. |
| At W5 locked-depth attempt | Best trial offer moment once commerce is safe. Intent is explicit and value proof exists. |
| After fast W1-W4 completion | Best high-intent experiment later. |

Recommended launch posture:

- now: soft preview after completion, no trial start;
- later: contextual 7-day trial at W5 locked depth or second-session proof;
- future experiment: earlier trial for high-intent preview clickers only after
  commerce safety and refund monitoring exist.

## 9. Subscription vs one-time vs hybrid analysis

| Packaging | Strength | Weakness | Verdict |
| --- | --- | --- | --- |
| Subscription-first | Best match for long-horizon learning, route depth, repair, mastery, and later specialization. | Requires trust and production commerce. | Launch business model, but not first-touch pressure. |
| One-time starter pack | Lower commitment, less subscription anxiety. | Caps LTV, fragments entitlement, and can train users to avoid subscription. | Future experiment only if subscription conversion quality is weak. |
| Hybrid subscription + one-time | Captures price-sensitive users. | Adds entitlement/copy/support complexity before core commerce is safe. | Defer. |
| Subscription + later analytics upsell | Best long-run ARPU for serious learners. | Requires real leak/profile data and more trust. | Long-horizon expansion, not launch default. |

Default: subscription depth model with annual as the value anchor and monthly as
the lower-friction option once public commerce is safe.

## 10. Revenue quality / LTV analysis

Revenue quality should be judged by paid retention, refund safety, and continued
learning fit, not raw trial starts.

Best LTV path:

1. Free W1-W4 foundation proves Sharky teaches visible poker decisions.
2. Soft preview makes premium feel expected without pressure.
3. W5+ paid boundary monetizes meaningful depth.
4. Contextual trial attaches to a real locked-depth intent moment.
5. Later analytics/leak-profile expansion increases ARPU only after enough
   behavioral truth exists.

Worst revenue path:

1. Early hard paywall gets trial starts before trust.
2. Learner does not understand the value.
3. Trial churn/refund/negative review risk rises.
4. Sharky loses its strongest competitive contrast with Runout.

## 11. Trust / retention / refund risk analysis

Trust risks by strategy:

- Hard pre-value paywall: highest trust harm; rejects Sharky's differentiator.
- W3 boundary: still too early for true beginners.
- Usage cap: makes practice feel rationed rather than coached.
- Repair gate: can feel like charging for mistakes.
- Dynamic gate: can feel opaque unless the reason is explicit.
- Soft preview: low risk if optional, earned, and non-commercial.
- W5 boundary: low-medium risk if W1-W4 are strong and the boundary was previewed.

Refund/churn risk is lowest when paid entry happens after the learner can say:

- "I used a table clue."
- "The app showed me why."
- "A mistake became a repair."
- "I came back and knew what to do."
- "Premium is more of this, not the first usable part."

## 12. Commerce safety constraints

Must not ship before production commerce readiness:

- public paywall;
- public Premium Hub route;
- price cards;
- trial start;
- purchase CTA;
- restore CTA as a primary commercial promise;
- annual/monthly plan selector;
- cancellation/refund/support promises;
- `all worlds`, AI, adaptive AI, solver, GTO, guaranteed improvement, or
  guaranteed win-rate claims.

Current code reasons:

- Premium Hub upgrade still calls `PremiumService().buyPremium`.
- `PremiumService.buyPremium()` uses `PaymentGatewayService` mock receipt flow.
- `PaymentService._verifyPurchase()` trusts purchase/restored stream status
  pending backend receipt hardening.
- `EntitlementLedgerV1` projections keep public paywall hidden and Premium Hub
  hidden.

Allowed now:

- preview-only value packaging after completed learning value;
- free-route-dominant close action;
- benefit claims tied to existing deterministic proof: more reps on table
  clues, deeper repair, longer route depth later.

## 13. Recommended launch-default monetization strategy

Launch default:

**Freemium foundation + premium depth subscription.**

Operational shape:

1. W1-W4 stay free and useful.
2. Premium preview appears only after completed learning value.
3. Preview explains later depth without price, trial, restore, or purchase.
4. Public paywall stays off until commerce safety is closed.
5. Once safe, W5+ becomes the first hard paid-depth boundary.
6. Contextual 7-day trial appears at W5 locked-depth attempt or D2/W5 proof
   moment, not before first value.
7. Annual/monthly subscription becomes the primary paid package.
8. Analytics/leak-profile and high-intent behavior offers remain future
   experiments.

This should serve all launch users by default. Do not split beginners and
high-intent users at launch beyond letting high-intent users voluntarily open
the same preview.

## 14. Future experiment candidates

Safe future experiments after commerce readiness:

- W4 vs W5 hard boundary for high-intent cohorts.
- Trial at D2 return vs W5 locked-depth attempt.
- Preview clicker follow-up offer after another proof moment.
- One-time starter pack for price-sensitive users.
- Repair-depth premium after repeated successful repairs, not immediately after
  a wrong answer.
- Analytics/leak-profile premium once the product has real profile data.
- Annual-default vs monthly-default paywall ordering.

Do not run these before:

- receipt verification;
- restore convergence;
- entitlement ledger public-commerce safety;
- support/cancel/refund copy;
- event semantics for preview click, locked-depth attempt, trial start, trial
  conversion, churn, and refund.

## 15. Recommended immediate next wave

**Premium Value Preview Surface v1**

Purpose:

Create or finalize a post-completion preview-only premium value moment that
packages the already-proven Sharky loop without exposing commerce.

Non-negotiable constraints:

- no product purchase path;
- no Premium Hub link;
- no trial start;
- no plan selector;
- no price;
- no restore;
- no route blocking;
- no fake AI/adaptive/GTO/solver/guaranteed claims;
- primary action remains free-route continuation.

The wave should not implement the W5 paywall. It should make the future W5
boundary feel expected, earned, and honest.

## 16. Reasons rejected alternatives lost

- Hard pre-value paywall lost because it damages activation, beginner
  confidence, App Store review safety, and Sharky's trust-first brand.
- W3 boundary lost because it monetizes before enough foundation is proven.
- W4 boundary lost because it is viable but less trust-safe than W5.
- No preview lost because the eventual W5 gate becomes colder and lower-convert.
- Usage cap lost because it interrupts the learning habit and can feel like
  artificial rationing.
- Dynamic gate lost as launch default because it is complex, hard to explain,
  and too close to fake personalization if not carefully proven.
- Repair gate lost because monetizing immediately around mistakes risks shame
  and churn.
- Trial after first completion lost for now because commerce safety is not
  ready.
- One-time starter pack lost as default because it weakens long-horizon route
  subscription logic.
- Analytics/leak-profile upsell lost as immediate strategy because the product
  should not sell profiles before enough behavioral data and product truth
  exist.

## 17. Deferred decisions

- Exact subscription price.
- Annual/monthly ordering.
- Trial length finalization.
- Whether W4 should be tested against W5 for high-intent users.
- Whether a one-time starter pack is needed.
- Whether analytics/leak-profile becomes a second paid layer.
- Public paywall UI.
- Premium Hub public route.
- App Store / Play Store receipt verification architecture.
- Cross-device/account restore policy.
- Refund/cancel/support copy.

## 18. Direction score

Current monetization direction: **9.0 / 10**.

The direction is strategically strong because it protects Sharky's differentiator:
real table-first value before paywall pressure. It is not `10/10` because the
commerce stack is still not production-safe, the hard boundary remains
unshipped, and conversion assumptions are still model-based rather than cohort
measured.

Compared with Runout from proven current evidence:

- Runout appears stronger in commercial packaging, paywall maturity, and broad
  subscription infrastructure.
- Sharky is stronger in beginner-safe value proof before monetization.
- Sharky's max-EV response is not to copy hard-paywall pressure; it is to make
  premium feel like more of the already-proven table-clue loop.

Final verdict:

**Proceed with Premium Value Preview Surface v1. Do not implement public
paywall, trial, pricing, restore, purchase, or Premium Hub exposure yet.**
