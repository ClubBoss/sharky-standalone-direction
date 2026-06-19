# Trust / Monetization Readiness Audit v1

Status: audit-only
Date: 2026-06-18

## 1. Purpose

Evaluate whether Sharky is ready to introduce trust, value, and monetization framing after the Act0 first-value, daily-loop, return-carry, and Home/Review hierarchy improvements.

This audit does not implement paywall, purchase logic, subscription logic, UI, copy, routes, telemetry, screenshots, Playwright, dashboard, content, table geometry, or visual changes.

## 2. Existing Monetization / Trust Surface Inventory

| Surface / seam | Owner | Current state | Readiness read |
| --- | --- | --- | --- |
| Act0 first-session placement / result / handoff | `lib/ui_v2/act0_shell/act0_placement_shell_v1.dart`, `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | First value is explicitly protected from premium/trial preview. Tests assert no `Premium trial`, no `Preview 7-day trial`, no premium preview sheet during placement result handoff. | Safe. Keep monetization out of this path. |
| Act0 first-correct feedback | `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`, focused Act0 tests | Proves table-first value: `Table read improved`, `You noticed No bet yet before choosing an action.`, same-signal next rep. | Strong value proof; safe as foundation for later value framing. |
| Act0 premium preview sheet | `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart`, `act0_shell_preview_screen_v1.dart` | Preview-only bottom sheet with `Stay on free route` primary CTA. Used for locked world premium preview seams, but tests also protect early placement from it. | Generally trust-safe, but value claims need truth tightening before broader exposure. |
| Act0 Learn locked worlds | `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`, focused Act0 tests | Locked route panels use progression copy, not premium/paywall copy. Tests assert no `Premium preview` / `See what premium adds` for locked Volume II and later worlds. | Safe for activation. Not a monetization surface yet. |
| Home / Play premium-action styling | `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`, `act0_play_shell_v1.dart` | Uses `premiumActionSurfaceDecoration` as visual styling, not commerce copy. | Naming is internal only; not a user-facing monetization risk. |
| Universal Intake Plan premium/trial surface | `lib/ui_v2/screens/universal_intake_plan_screen.dart`, `test/ui_v2/today_plan_entitlement_truth_v1_test.dart` | Shows `See premium access`, trial status, premium preview, restore states, store unavailable state. Not the current Act0 canonical first-session route. | Has useful truth contracts, but should not be treated as current Act0 monetization readiness. |
| Premium Hub | `lib/ui_v2/ui_v2_premium_hub.dart` | Upgrade and restore UI exists. Upgrade uses `PremiumService.buyPremium()` mock gateway. | High risk if exposed as production purchase. Needs entitlement/payment hardening before use. |
| Premium value package copy | `lib/services/premium_value_package_v1.dart`, `test/services/premium_value_package_v1_contract_test.dart` | Bounded package truth: free opening path + one Today route per UTC day; trial/premium unlock premium-target Today routes and World 5+ progression; restore is conditional. | Good direction, but product truth should be reconciled with active Act0 route before public copy. |
| Entitlement SSOT | `lib/services/entitlement_ssot_v1.dart`, `subscription_status_v1.dart` | Reads premium flag and trial status into one status object. Migration is no-op; legacy keys remain. | Useful aggregation, not a complete commerce ledger. |
| Premium / trial state | `lib/services/premium_service.dart`, `trial_service_v1.dart` | Premium is a local SharedPreferences bool; trial is persisted JSON with 7-day duration and eligibility checks. | Good for prototypes/tests. Not enough for public subscription truth. |
| Store purchase path | `lib/payments/payment_service.dart`, `docs/plan/MONETIZATION_SSOT_v1.md` | Product IDs exist. Purchase stream handles purchased/restored, but receipt verification is stubbed and product delivery does not unify entitlement writes. | Not ready for public monetization. |
| Restore flow | `lib/services/release_premium_access_action_v1.dart`, `premium_restore_flow_v1.dart`, tests | Restore action distinguishes restored, already active, no purchase found, failed, unavailable store. | Truth-safe at UI-message level, but depends on entitlement/purchase convergence that remains incomplete. |

## 3. Claim Truth Table

| Claim / phrase / surface | Source location | Current support level | Evidence | Risk | Recommended action |
| --- | --- | --- | --- | --- | --- |
| `Table read improved` | `act0_lesson_runner_shell_v1.dart`, Act0 focused tests | proven | First-correct feedback tests and compact screenshot evidence from prior proof packet. | Low | Allowed. Strong value claim. |
| `You noticed No bet yet before choosing an action.` | `act0_lesson_runner_shell_v1.dart`, Act0 focused tests | proven | Feedback signal/table signal layer ties the copy to visible table state. | Low | Allowed. |
| Same-signal next rep / Home carry | `act0_shell_preview_screen_v1.dart`, Act0 focused tests | proven | Return carry and daily rep launch tests exist from recent accepted waves. | Low | Allowed when phrased as deterministic carry, not AI personalization. |
| `Recovered lately` / `Repaired` / `Replay for perfect` | `act0_review_shell_v1.dart`, Act0 focused tests | proven | Repair completion and repaired proof tests pass; deterministic repair queue exists. | Low | Allowed. |
| `Free includes the opening path and one Today route per UTC day.` | `premium_value_package_v1.dart` | partial | Contract test protects copy, but active Act0 first-session route does not currently surface this as a public entitlement boundary. | Medium | Keep as internal package truth; audit against active route before public use. |
| `Trial or premium unlock premium-target Today routes and World 5+ progression on current main.` | `premium_value_package_v1.dart`, Universal Intake tests | partial / risky | Tests prove the copy appears in Universal Intake premium preview; `MONETIZATION_SSOT_v1` says entitlement stores are split and gating is partly heuristic. | High | Do not use broadly until entitlement and active-route gating are reconciled. |
| Restore checks this store account and activates only if past purchase is found. | `premium_value_package_v1.dart`, `release_premium_access_action_v1.dart`, restore tests | partial | Restore message handling is truth-safe; store purchase/entitlement convergence remains incomplete. | Medium | Allowed only in restore UI with clear conditional language; do not overstate guarantee. |
| `Premium can turn your diagnostic into daily weak-spot drills, review queues, and progress insights.` | placement result data in `act0_shell_preview_screen_v1.dart` | risky | Daily weak-spot and repair queues exist, but not clearly as premium-gated value; `progress insights` is broad. | High | Constrain or defer before public premium preview. |
| `Premium can keep your review focused on the spots you miss instead of repeating everything.` | placement result data in `act0_shell_preview_screen_v1.dart` | partial | Review repair queue exists; premium gating for it is not proven as a paid feature. | Medium | Rephrase later as future/deeper sharpening only after package truth cleanup. |
| `Premium can add personal repair drills and a seven-day guided plan after this foundation.` | placement result data in `act0_shell_preview_screen_v1.dart` | partial / risky | Repair drills exist; seven-day guided plan as premium entitlement is not proven in active Act0. | High | Do not expose until premium package truth is tightened. |
| `Premium adds extra reps and follow-up around this world once the free route unlocks it naturally.` | `_previewLockedWorldPremium` in `act0_shell_preview_screen_v1.dart` | partial | Extra reps exist in content/review systems, but paid entitlement to this package is not production-proven. | Medium | Keep preview low-pressure; audit copy before broader release. |
| `AI`, adaptive personalization, solver/GTO improvement claims | forbidden by prompt; searched active Act0/tests | unsupported / forbidden | Active tests assert no GTO/solver in first-session feedback; legacy AI services are outside active Act0 route. | High | Forbid public claims unless deterministic proof and privacy are explicit. |
| Offline / privacy / local-only claims | `MONETIZATION_SSOT_v1`, privacy/legal tests outside Act0 | partial | Premium/trial local state is readable offline, but cloud sync, telemetry, Firebase, and legal/privacy surfaces exist elsewhere. | High | Do not claim offline-first or privacy guarantees until a privacy/data posture audit closes. |
| Refund / cancel clarity | searched code/docs | unsupported | No current Act0-facing refund/cancel copy found. | High | Must be defined before any public subscription/paywall implementation. |

## 4. Activation / Paywall Risk Table

| Surface | When user sees it | Before / after first value | Risk to activation | Monetization readiness | Recommendation |
| --- | --- | --- | --- | --- | --- |
| Placement intro/questions | First open when placement starts | Before first value | Low | Not a monetization surface | Keep premium absent. |
| Placement result / first-hand handoff | After placement / quick check | Before first hand value | Low today because tests exclude premium preview | Not ready for monetization pressure | Keep `Start with the useful hand` dominant. Do not add paywall here. |
| First correct feedback | After first useful answer | First value moment | Low | Strongest value proof, not a paywall | Use later as trust basis. Do not interrupt with purchase prompt here. |
| Home first-value carry / daily checklist | After first value or return | After first value | Low-medium | Good value framing, not commerce-ready | Eligible for passive value framing later, not payment flow. |
| Review open repair / repaired proof | After mistake or repair completion | After value and repair proof | Low-medium | Strong trust proof | Candidate for "premium deepens repair" preview later, after package truth cleanup. |
| Act0 locked world premium preview | User explores locked/premium preview world | After route exploration | Medium | Preview-only, but copy has partial claims | Audit/tighten preview truth before expanding. |
| Universal Intake Plan premium preview | Older/non-Act0 Today entry | Potentially early depending route | Medium-high if made canonical | Has state contracts, but not active-route ready | Do not route Act0 through it for monetization without cleanup. |
| Premium Hub | Direct route or older premium CTA | Varies | High | Not production-ready because upgrade uses mock gateway and entitlement split remains | Do not expose as public purchase surface. |

## 5. Missing Trust Requirements

1. Unified entitlement ledger.
   - `MONETIZATION_SSOT_v1` still records split stores: premium bool, trial JSON, purchased products.

2. Real receipt verification and entitlement convergence.
   - Store purchase verification is not production-hard; mock premium purchase path still exists.

3. Public restore / cancel / refund language.
   - Restore has bounded truth; cancel/refund are not product-ready.

4. Premium package truth against the active Act0 route.
   - `World 5+`, premium-target Today routes, weak-spot drills, and seven-day plan claims need exact active-route support.

5. Privacy and data posture.
   - Do not claim local/offline/private training broadly while telemetry/cloud/Firebase-era services remain present and unaudited for release copy.

6. Premium preview freshness.
   - Low-pressure preview principle is right, but current Act0 premium copy includes `can` claims that may outrun implemented paid entitlement truth.

7. App-store/legal/commercial readiness.
   - Store metadata, support, privacy, terms, subscription management language, and review-safe product claims remain separate release work.

## 6. Recommended Next 1-3 Arcs

### 1. Premium Preview Truth Cleanup v1

EV: High
Risk: Low-medium

Audit and tighten only monetization-adjacent preview/package language so every premium claim maps to implemented active-route truth. Keep first-session paywall-free. Do not implement purchases.

Scope should include:

- `Act0PremiumPreviewSheetV1`
- `_previewLockedWorldPremium`
- placement result `premiumPitch` / `trialValuePoints`
- `kPremiumValuePackageV1`
- tests that forbid broad claims like all worlds, all features, AI/adaptive, solver/GTO, guaranteed restore

### 2. Entitlement / Restore / Trial Production Readiness Audit v1

EV: High
Risk: Medium

Audit whether the existing entitlement SSOT, Premium Hub, mock gateway, store purchase path, restore flow, and trial state can become production-safe. This should be audit-first and may end with a no-op if real backend/store decisions are missing.

### 3. Product Packaging / App Store Narrative Audit v1

EV: Medium-high
Risk: Low

Build the external value narrative from proven Sharky behavior: table clue, first correction proof, same-signal rep, return carry, repair proof. Do not mention AI, solver, GTO, guaranteed improvement, or unsupported personalization.

## 7. Forbidden Claims List

- "AI coach", "AI-personalized", "adaptive AI", or any machine-learning personalization claim.
- "Solver/GTO optimal trainer" or solver-grade strategy claims.
- "Guaranteed improvement", "guaranteed results", or "fix your leaks automatically".
- "All worlds/features unlocked" unless entitlement mapping proves it exactly.
- "Offline/private/local-only" unless privacy/data audit and release policy prove it.
- "Restore always works" or any restore guarantee.
- "Cancel anytime" / refund language until subscription management policy and store copy are finalized.
- "Premium unlocks review queues / progress insights / seven-day plans" unless the exact paid entitlement is implemented and tested.
- Any paywall/trial pressure before the first useful learning loop.

## 8. Deferred List

- Paywall implementation.
- Public subscription pricing.
- Real receipt verification backend.
- Store-product configuration and App Store / Play Store package truth.
- Subscription cancel/refund/support flow.
- Privacy/legal release packet.
- Broad dashboard, Skill Map, or Leak Profile.
- Screenshot capture or paywall visual design.

## 9. Stop Rules

- Do not implement paywall/purchase/subscription UI before premium package truth cleanup.
- Do not expose Premium Hub publicly while mock gateway and entitlement split remain unresolved.
- Do not place monetization before placement result -> first useful hand -> first feedback proof.
- Do not use AI/adaptive/GTO/solver claims.
- Do not monetize basic trust, first value, or the first return reason.
- Stop any monetization implementation if entitlement, restore, or store state cannot be made deterministic and truthful.

## 10. Direction Score

Current direction: 7.6 / 10.

Sharky is now ready for monetization-adjacent trust/value packaging work. It is not ready for public paywall or subscription implementation.

The product proof spine is strong enough to begin packaging: first hand, first feedback, same-signal rep, Home carry, daily loop, and repaired proof. The commercial system is still too split and stubbed to safely ask for money.

## 11. Runout / Benchmark-Stack Comparison

Based only on current proven behavior and accepted Runout reference docs:

- Runout remains ahead in commercial packaging maturity: paywall/subscription assets, premium motion, and app-store-grade offer framing.
- Sharky is ahead in honest learning proof before paywall: deterministic table clue -> action -> why -> same-signal next action -> repair proof.
- Sharky should borrow the principle of premium value packaging, not Runout's early monetization pressure or visual composition.
- Sharky's best competitive path is value-first premium framing after trust, not paywall-first conversion.

