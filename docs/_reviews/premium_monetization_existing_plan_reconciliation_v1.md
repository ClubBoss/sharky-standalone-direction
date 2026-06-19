# Premium / Monetization Existing Plan Reconciliation v1

Status: docs/code audit and reconciliation only
Date: 2026-06-18

## 1. Wave Admission

Admitted as reconciliation-only. This wave reads existing Sharky premium,
monetization, entitlement, paywall, purchase, restore, trial, value-preview, and
Runout reference seams and reconciles them against the accepted first-week
product state.

No product code, UI, copy, tests, routes, telemetry, commerce, entitlement,
paywall, screenshot tooling, Playwright tooling, table geometry, or localization
changes were made.

## 2. Evidence Inventory

| Evidence | Status | Reconciliation read |
| --- | --- | --- |
| `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md` | active | Act0 shell is current learner-facing truth. Legacy/dormant surfaces should not drive the next monetization move. |
| `docs/plan/MASTER_PLAN_v3.0.md` | active | Premium/trial messaging appears only after value and habit credibility; public model direction is free foundation, paid depth. |
| `docs/plan/APP_WIDE_MONETIZATION_AND_RETENTION_GUIDELINE_v1.md` | active | Premium should sell depth and sharpening, not permission to begin. |
| `docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md` | active | First useful loop and believable return reason must stay free. |
| `docs/plan/MONETIZATION_TIMING_GUARD_v1.md` | active | Value and habit precede stronger monetization friction. |
| `docs/plan/MONETIZATION_SSOT_v1.md` | partially valid / stale | Still useful for known product IDs and risk categories, but stale where it says no ledger exists; current working tree has `EntitlementLedgerV1`. |
| `docs/_reviews/final_first_week_commercial_proof_packet_v1.md` | active | First-week compact English loop accepted at 9.0/10; surface-polish mode should stay closed. |
| `docs/_reviews/compact_english_premium_pack_recapture_v1.md` | active | Home, Practice completion, Review open repair, and Profile pass compact English commercial proof; no surface blocker. |
| `docs/_reviews/trust_monetization_readiness_audit_v1.md` | mostly valid | Correctly protects first value and bans unsafe claims; some earlier concern about preview copy has since been tightened. |
| `docs/_reviews/commerce_entitlement_truth_audit_v1.md` | mostly valid | Correctly marks public commerce unsafe; stale in detail because ledger MVP now exists locally. |
| `docs/_reviews/entitlement_ledger_consolidation_design_v1.md` | partially implemented / still valid | Ledger model direction is now partly implemented; production receipt/restore/public-commerce safety remains missing. |
| `docs/_reviews/product_surface_premium_pack_planning_v1.md` | superseded for next action | Surface premium pack was implemented/proven by later packets; do not reopen surface polish now. |
| `docs/_reviews/value_monetization_packaging_planning_v1.md` | active recent plan | Recommends soft premium preview after first daily/session completion; reconciles with current evidence. |
| `docs/competitive/runout/RUNOUT_REFERENCE_SUMMARY.md` | active reference | Runout is strong in commercial packaging breadth; Sharky should compete through proof-first premium framing. |
| `docs/competitive/runout/RUNOUT_ONBOARDING_PAYWALL_NOTES.md` | active reference | Borrow premium-authoring principles, not early paywall/trial pressure. |
| `docs/competitive/runout/RUNOUT_FEATURE_MATRIX.md` | active reference | Paywall packaging is a Runout strength and a trust risk if copied before value. |
| `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart` | active code seam | Preview-only sheet exists with `Stay on free route`; no purchase or trial action. |
| `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` | active code seam | Locked-world preview and placement result premium copy are now bounded around optional table-clue practice. |
| `lib/ui_v2/ui_v2_premium_hub.dart` | unsafe if public | Route exists; upgrade still reaches `PremiumService.buyPremium()` mock gateway. Must remain hidden/deferred publicly. |
| `lib/services/entitlement_ledger_v1.dart` | local deterministic MVP / not public-commerce safe | Ledger exists and centralizes local state, but access projections keep `shouldExposePublicPaywall=false` and `shouldHidePremiumHub=true`; `isPublicCommerceSafe` stays false for local sources. |
| `lib/services/entitlement_ssot_v1.dart` | active facade | Reads from ledger access projection; better than older split-read truth. |
| `lib/services/premium_service.dart` | prototype write seam | Still owns `premium_is_active`; `buyPremium()` uses mock receipt validation. Not public-safe. |
| `lib/payments/payment_service.dart` | partial store seam | Product IDs, restore, purchase stream, pending ledger writes exist; verification still trusts purchase/restored status and uses local convergence. |
| `lib/services/release_premium_access_action_v1.dart` | partial wrapper | Restore/upgrade wrapper records ledger states, but upgrade can still call mock purchase via Premium Hub. |
| `lib/services/premium_value_package_v1.dart` | active bounded copy | Current package copy is narrow: free first useful hand, optional later table-clue practice, conditional restore. |
| `lib/services/trial_service_v1.dart` | local trial seam | Trial is local SharedPreferences/time based with rollback guard and ledger writes; not production account/store truth. |
| `lib/services/payment_gateway_service.dart` | unsafe for public commerce | Explicit mock gateway, deterministic mock receipt, no real Apple/Google/Stripe verification. |

## 3. Executive Verdict

Existing premium plans are coherent at the principle level:

- first value remains free;
- premium should appear after visible value and habit credibility;
- premium should mean more table-clue practice, repair depth, and route depth;
- public commerce waits for receipt, restore, and entitlement truth.

Existing plans are not fully coherent as implementation truth because older docs
pre-date the local ledger MVP. The reconciliation is:

- ledger consolidation is no longer entirely missing;
- ledger/public-commerce safety is still not complete;
- the public paywall remains deferred;
- soft premium preview is now the highest-EV next move.

The app is ready for a soft premium preview after first daily/session completion.

The app is not ready for real paywall, public purchase, public Premium Hub, or
subscription offer implementation.

Single max-EV next step: **Premium Value Preview Surface v1**.

## 4. Existing Premium Plan Summary

Prior plans said:

- use value-before-paywall as the core monetization timing rule;
- keep first useful loop, basic trust, and route comprehension free;
- package premium as depth/sharpening rather than rescue gating;
- do not expose Premium Hub while mock purchase remains reachable;
- consolidate entitlement truth before public paywall;
- tighten premium claims to active-route truth;
- compete with Runout through proof-first packaging, not hard-paywall mimicry.

Still valid:

- first session, first feedback, first daily completion proof must stay free;
- Premium Hub remains public-unsafe;
- payment receipt verification remains insufficient for public commerce;
- restore is message-safe but not yet production-commerce-safe;
- AI/adaptive/GTO/solver/guaranteed-result claims remain forbidden;
- premium should first appear as optional value packaging, not price pressure.

Updated by current state:

- `EntitlementLedgerV1` now exists locally and reads/writes several entitlement
  outcomes.
- Older "no ledger exists" language should be read as "no production-safe
  public-commerce ledger exists yet."
- Act0 premium copy has already been tightened away from broad World 5+,
  seven-day-plan, review-queue, and progress-insight claims.
- First-week product proof is now accepted strongly enough to permit a soft
  preview after completion.

Conflicts with current accepted first-week state:

- Any plan that keeps surface-polish mode active is outdated.
- Any plan that recommends a paywall before first-week value proof is unsafe.
- Any plan that treats Universal Intake or legacy Progress Map premium gating
  as canonical Act0 monetization truth is out of bounds for the next wave.

## 5. Current Implementation Reality

### Premium UI

- `Act0PremiumPreviewSheetV1` exists as a preview-only bottom sheet.
- It has no purchase, price, restore, trial-start, or paywall action.
- Its trust CTA is `Stay on free route`.
- `_previewLockedWorldPremium(...)` opens it for locked-world exploration with
  bounded copy about optional later table-clue practice.

### Paywall / Premium Hub

- `UiV2PremiumHub` exists and includes restore and upgrade actions.
- The file itself describes the surface as allowing upgrade through a mock
  gateway.
- `_upgrade()` calls `ReleasePremiumAccessActionV1.upgradeV1(...)` with
  `performUpgrade: PremiumService().buyPremium`.
- `PremiumService.buyPremium()` calls `PaymentGatewayService`, which returns and
  validates a mock receipt.

Verdict: Premium Hub must remain hidden/deferred from public Act0 commerce.

### Entitlement / ledger

- `EntitlementLedgerV1` exists and stores local ledger state.
- `EntitlementSSOTV1.readPremiumStateV1()` now reads ledger access instead of
  directly composing old stores.
- Ledger records trial start/expiry/rollback, restore pending/no-purchase/fail,
  local restore success, purchase pending, local product convergence, and debug
  premium flag.
- Ledger projection keeps `shouldExposePublicPaywall=false`,
  `shouldHidePublicPaywall=true`, and `shouldHidePremiumHub=true`.
- Local product convergence and local restore success use `verified=false` and
  `isPublicCommerceSafe=false`.

Verdict: local deterministic ledger progress is real; public commerce safety is
not proven.

### Payment / restore / trial

- `PaymentService` declares product IDs for premium pack, monthly/annual
  subscription, XP booster, and coins.
- `buyProduct(...)` still uses `buyNonConsumable(...)` for subscription and
  non-consumable branches.
- `_verifyPurchase(...)` trusts purchased/restored status locally and comments
  that backend receipt checks are future hardening.
- Restore calls platform restore and then wrappers observe local entitlement
  convergence.
- Trial remains local time/SharedPreferences based with rollback detection and
  ledger writes.

Verdict: adequate for prototype/local state and tests; inadequate for public
purchase exposure.

## 6. Free vs Premium Boundary

### Stay free now

- placement and beginner-safe route calibration;
- first useful hand;
- first correct/wrong feedback and table-signal proof;
- same-signal next rep;
- first daily/session completion;
- basic Home return reason;
- basic Review repair and open repair proof;
- Learn current mission clarity;
- Profile progress rhythm;
- enough early route depth to prove Sharky is useful.

### Premium can honestly own later

- more reps on already-seen table clues;
- deeper same-signal practice;
- richer repair resurfacing;
- longer route depth beyond the free foundation;
- replay/mastery depth;
- later-volume and specialization depth when those systems are ready;
- clearer upgrade path once receipt/restore/ledger truth is production-ready.

### Do not sell yet

- AI coaching or AI personalization;
- solver/GTO/optimal-frequency training;
- guaranteed improvement or win-rate gain;
- automatic leak fixing;
- all features/worlds unlocked;
- seven-day guided plan as a paid promise;
- progress insights / review queues as paid benefits unless exact entitlement
  mapping proves them;
- restore/cancel/refund/account guarantees;
- privacy/offline/local-only claims.

## 7. Premium Touchpoint Recommendation

First premium appearance should be:

**after the first completed daily/session result, as an optional preview entry
from Home or Practice completion.**

Why there:

- first value has already happened;
- table-signal proof has already happened;
- the daily loop has already proven a return reason;
- the result ceremony is an earned moment;
- the preview can be quiet and optional without harming activation.

Must not appear:

- before placement;
- during placement;
- on placement result before the first useful hand;
- immediately after first feedback;
- as a blocker in Review repair;
- as an auto-open modal that competes with completion proof;
- as a paywall, price card, trial-start, restore, or purchase CTA.

## 8. Claims Audit

### Allowed claims

- "More practice on the table clues you are already learning."
- "Extra reps after the free foundation."
- "Deeper review of missed reads."
- "Longer route depth when you want more than the opening path."
- "Premium stays optional; the first useful loop stays free."
- "Stay on the free route until you want more practice."

### Banned claims

- AI coach / AI-personalized / adaptive AI.
- Solver, GTO, optimal frequencies.
- Guaranteed improvement, guaranteed win rate, guaranteed results.
- Fix leaks automatically.
- Unlock all worlds/features.
- Restore always works.
- Cancel anytime, refund, account access, or cross-device guarantee before
  store policy and receipt truth are production-ready.
- Offline/private/local-only training claims before privacy/data audit.

### Existing unsafe copy found

No active Act0 first-week unsafe claim was found in the inspected current seams.
Current Act0 premium preview copy is bounded and optional.

Unsafe if exposed publicly:

- `UiV2PremiumHub` upgrade path because it can still reach mock purchase.
- `PaymentGatewayService` because it is explicitly a mock gateway.
- `PaymentService` purchase verification because it trusts purchase stream
  status rather than production receipt verification.

## 9. Technical Readiness Audit

Already done:

- local entitlement ledger model exists;
- subscription status reads through entitlement SSOT / ledger access projection;
- trial start/expiry/rollback can write ledger;
- restore wrapper records pending/no-purchase/failure/local success outcomes;
- payment product convergence writes local ledger state;
- premium value package copy is bounded;
- public paywall and Premium Hub are explicitly hidden by ledger projection.

Still missing before public commerce:

- production receipt verification;
- verified subscription expiry/renewal/refund/revocation/grace states;
- upgrade path that does not call `PremiumService.buyPremium()`;
- public purchase fulfillment through verified store product mapping;
- restore convergence with verified transaction/account truth;
- cancellation/refund/subscription-management copy;
- explicit active Act0 entitlement gating map;
- tests proving verified paid/restore/trial/free transitions through Act0 gates;
- App Store / Play Store commerce metadata and support policy.

Launch blockers for real paywall:

- mock gateway reachable from Premium Hub;
- local premium flag can still grant access;
- store purchase verification is local/trusting;
- subscription purchase semantics remain incomplete;
- restore is not production-verified;
- public commerce copy is incomplete.

## 10. Runout Comparison

What to borrow:

- strong premium packaging;
- clear "there is more depth here" feeling;
- authored commercial hierarchy;
- paywall/value clarity after trust is earned.

What not to copy:

- hard paywall before learning value;
- discount urgency before trust;
- broad analytics/rating promises before proof;
- GTO/advanced intimidation for beginners;
- black-box personalization claims.

Sharky's differentiation:

- value before paywall;
- deterministic table-signal feedback;
- repair from real mistakes;
- beginner-safe route;
- premium as more reps and deeper repair, not a rescue gate.

## 11. Candidate Paths Comparison

| Candidate | EV | Risk | Dependencies | Why now / why not now |
| --- | --- | --- | --- | --- |
| Premium Value Preview Surface v1 | High | Low-medium | Accepted first-week proof, bounded preview copy, no commerce activation | Best next wave. It turns proven value into optional packaging without exposing unsafe commerce. |
| Entitlement / Receipt Verification Readiness v1 | High | High | Store/backend policy, product IDs, receipt verification decisions | Necessary before real paywall, but not the next product-facing max-EV step because preview can proceed safely without commerce. |
| Premium Copy Guardrails v1 | Medium | Low | Current bounded copy | Not first because current active Act0 premium copy is already safe enough; guardrails can be tests inside preview wave. |
| Soft Upgrade Moment Design v1 | Medium-high | Low | Preview strategy | Too overlapping with Premium Value Preview Surface; use the more concrete surface wave instead. |
| Paywall Timing / Trust Gate Design v1 | Medium | Medium | Free/premium boundary, commerce readiness | Premature before production commerce truth. Useful later after preview and receipt readiness. |
| Next Learning Layer / Rule-Based Personalization v1 | Medium-high | Medium | More content/state design | Valuable, but current bottleneck is value packaging now that first-week proof is accepted. |

## 12. Recommended Next Wave

Recommend exactly one next wave:

**Premium Value Preview Surface v1**

Why it is highest EV:

- product proof is accepted;
- current premium strategy is coherent;
- commerce is not ready for public paywall;
- existing preview copy is bounded enough to build on;
- Runout's packaging advantage can be answered without copying hard-paywall
  pressure;
- it creates the first honest monetization touchpoint while preserving trust.

Definition of Done:

- one optional premium preview entry appears only after first daily/session
  completion;
- primary learning/free-route action remains dominant;
- no price, purchase, restore, trial-start, Premium Hub route, or public paywall
  is exposed;
- copy is limited to table-clue reps, extra practice, deeper review, and longer
  route depth;
- tests guard banned claims and absence of premium before first value;
- ledger/public-commerce guards remain untouched;
- no route/order/scoring/table/content/telemetry changes.

Stop conditions:

- stop if implementation needs real purchase, trial, restore, or Premium Hub;
- stop if copy needs unsupported claims;
- stop if preview appears before first daily/session completion;
- stop if commerce/entitlement code must change;
- stop if surface polish expands beyond the preview entry.

## 13. Deferred Backlog

- public paywall implementation;
- pricing and discounts;
- public Premium Hub exposure;
- production receipt verification;
- verified restore/account convergence;
- cancellation/refund/subscription-management copy;
- App Store / Play Store subscription metadata;
- exact active Act0 entitlement-gating map;
- full free/premium route-boundary enforcement;
- advanced personalization claims;
- Skill Map / Leak Profile Lite as paid packaging;
- App Store screenshots and paywall visual story;
- RU/non-English commercial localization QA.

## 14. Files Changed

- `docs/_reviews/premium_monetization_existing_plan_reconciliation_v1.md`

## 15. Verification

Required docs-only verification:

- `git diff --check` - passed.

No tests or screenshots are required because this wave does not touch product
code, UI, copy, routes, commerce, entitlement, telemetry, tests, screenshots, or
localization.

## 16. Direction Score

Current direction: **8.9 / 10**.

Rationale:

- First-week learning proof is strong and accepted.
- Premium strategy is coherent after reconciliation.
- Act0 preview copy is bounded and trust-safe.
- Ledger progress reduces local-state chaos but does not make public commerce
  launch-ready.
- The next best move is soft premium value packaging after completion, not real
  paywall or another surface-polish wave.
