# Commerce / Entitlement Truth Audit v1

Status: audit-only
Date: 2026-06-18

## 1. Purpose

Map Sharky's current commerce, restore, premium entitlement, trial state, and
public monetization surfaces before any paywall or public subscription work.

This audit does not implement paywall, purchase logic, restore logic,
entitlement changes, routes, telemetry, UI, copy, screenshots, Playwright,
content, table geometry, dashboard, or visual design.

Verdict: current value and premium preview copy is directionally safe, but the
commerce system is not production-safe for public purchase exposure. Premium Hub
must remain hidden/deferred as a public purchase surface until entitlement and
receipt truth are consolidated.

## 2. Commerce Surface Inventory

| Surface/seam | Owner/file | Current behavior | User-facing | Production safety | Evidence | Recommended action |
| --- | --- | --- | --- | --- | --- | --- |
| Act0 first-value route | `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | First useful hand and first feedback remain free; premium preview is guarded out of placement/result/handoff. | Yes | Safe | Focused Act0 tests assert premium preview absence before first value. | Keep monetization absent before first value. |
| Act0 premium preview sheet | `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart`, `act0_shell_preview_screen_v1.dart` | Preview-only, low-pressure sheet with "Stay on free route"; copy now frames premium as optional later table-clue practice. | Yes, limited | Partial | Premium Preview Truth Cleanup removed unsupported World 5+/seven-day/review-queue/progress claims. | Keep as informational preview only; do not wire to purchase until commerce truth is clean. |
| Universal Intake premium preview | `lib/ui_v2/screens/universal_intake_plan_screen.dart` | Shows trial status, "See premium access", restore CTA, store-unavailable state, and trial start after value conditions. | Yes, older/non-Act0 route | Partial/risky | Uses `ReleasePremiumAccessActionV1.restoreV1`, `ReleaseCommerceAvailabilityServiceV1`, and `kPremiumValuePackageV1`. | Do not promote as primary Act0 commerce surface before ledger/receipt hardening. |
| Premium Hub | `lib/ui_v2/ui_v2_premium_hub.dart` | Shows premium status, restore CTA, upgrade CTA, benefits, and store availability note. Upgrade calls `PremiumService().buyPremium()`. | Yes if routed from dev/menu/direct route | Unsafe for public purchase | File comment says "lets the user upgrade via mock gateway"; `_upgrade()` uses mock `PremiumService.buyPremium()`. | Keep hidden/deferred publicly. Replace upgrade path only after production purchase and entitlement ledger are ready. |
| Premium value package | `lib/services/premium_value_package_v1.dart` | Bounded public copy: free first useful hand; premium optional later; restore conditional. | Yes where surfaced | Safe as copy only | Contract test protects no broad claims. | Keep claim set; do not expand until entitlement truth supports it. |
| Subscription status facade | `lib/services/subscription_status_v1.dart` | Reads `EntitlementSSOTV1`, labels state as free/trial/premium, emits status telemetry once. | Indirect | Partial | Tests prove deterministic precedence for local premium flag vs trial JSON. | Keep as facade; do not treat as production ledger. |
| Entitlement SSOT facade | `lib/services/entitlement_ssot_v1.dart` | Aggregates local premium bool and trial service; migration is no-op. | Indirect | Partial | `readPremiumStateV1()` reads `PremiumService().isPremiumActive()` and `TrialServiceV1.getTrialStatusV1()`. | Promote to real ledger in next arc. |
| Premium local flag | `lib/services/premium_service.dart` | Stores `premium_is_active` bool in SharedPreferences; `buyPremium()` uses mock gateway and enables flag on local validation. | Indirect | Prototype/risky | Comments state production activation should only follow payment verification; mock gateway is used today. | Replace as write target with ledger-backed entitlement record. |
| Trial state | `lib/services/trial_service_v1.dart` | Stores `trial_entitlement_v1` JSON, placement completion, telemetry keys, last-seen clock, rollback flag. | Yes via status/CTA | Partial | Tests prove one-time start, expiration, rollback blocking. | Keep policy, but move entitlement consequence into ledger. |
| Store IAP service | `lib/payments/payment_service.dart` | Queries product IDs, listens to purchase stream, calls restore, persists `purchased_products`, maps premium product IDs to `PremiumService.enablePremium()`. | Indirect | Partial/risky | `_verifyPurchase()` trusts purchase/restored status; comment says backend receipt checks are future hardening. | Do not expose public paywall until receipt verification and product mapping are production-grade. |
| Mock payment gateway | `lib/services/payment_gateway_service.dart` | Returns `MOCK-RECEIPT...`, deterministic validation score 0.95. | Indirect through Premium Hub upgrade | Unsafe for public purchase | Header says "Stage 25: Payments Integration (Mock)" and "No real Stripe/Apple/Google keys or network calls." | Remove from public upgrade path. Keep only as test/dev fixture if needed. |
| Restore flow wrapper | `lib/services/premium_restore_flow_v1.dart`, `release_premium_access_action_v1.dart` | Runs restore, then checks whether entitlement became true; distinguishes restored/already active/no purchase/failure. | Yes | Partial | Message tests and UI tests prove outcomes, but success depends on underlying purchase stream and local entitlement convergence. | Keep copy conditional; require ledger-backed restore before public exposure. |
| Commerce availability | `lib/services/release_commerce_availability_v1.dart`, `release_premium_offer_scope_v1.dart` | Uses `PaymentService.initialize()`, queried product IDs, and offer-scope classifier to enable/disable restore/upgrade. | Yes via hub/intake notes | Partial | Tests use debug overrides; production depends on platform catalog. | Keep as availability layer, not proof of entitlement safety. |
| Purchase cloud sync | `lib/services/purchase_sync_service.dart` | Syncs local purchased product IDs to Firestore and loads them back; if cloud has missing local purchases, calls `restorePurchases()`. | Indirect | Risky/partial | No receipt verification or entitlement-write ledger in cloud sync; errors are swallowed/logged. | Defer from paywall readiness or redesign as ledger sync after receipt verification. |
| Legacy/adaptive premium triggers | `lib/services/adaptive_premium_triggers.dart` | Legacy 24h trial path is disabled by `_legacyTrialPathEnabledV1 = false`; bonus rewards may still run. | No active premium path | Safe if disabled | Code returns `legacy_triggers_disabled_v1` before trial activation. | Keep disabled; do not use adaptive/AI monetization claims. |

## 3. Entitlement Flow Map

| Event/action | Service touched | Storage key/model | Source of truth | Entitlement written | Restore aware | Trial aware | Production risk | Proof source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Read current access | `SubscriptionServiceV1.getStatusV1()` -> `EntitlementSSOTV1.readPremiumStateV1()` | `premium_is_active`, `trial_entitlement_v1` | Aggregated facade, not ledger | No | Indirect | Yes | Split storage can drift | `subscription_status_v1.dart`, `entitlement_ssot_v1.dart`, `subscription_status_v1_test.dart` |
| Enable premium manually/mock | `PremiumService.enablePremium()` | `premium_is_active` bool | Local preference flag | Yes | No | Premium overrides trial in facade | Local toggle can grant paid access without receipt | `premium_service.dart` |
| Premium Hub upgrade | `UiV2PremiumHub._upgrade()` -> `ReleasePremiumAccessActionV1.upgradeV1()` -> `PremiumService.buyPremium()` | Mock receipt, `premium_is_active` | Mock local validation | Yes if mock validates | No | Trial state read after | Public-unsafe because mock purchase grants premium | `ui_v2_premium_hub.dart`, `payment_gateway_service.dart`, `premium_service.dart` |
| Store IAP purchase update | `PaymentService._handlePurchase()` | `purchased_products`, `premium_is_active` via sync | Purchase stream trusted locally | Yes for premium product IDs | Same handler handles restored | No direct trial write | No server receipt verification; product delivery comment says fulfillment is incomplete | `payment_service.dart`, payment restore verification tests |
| Restore from Premium Hub | `ReleasePremiumAccessActionV1.restoreV1()` -> `PaymentService.restorePurchases()` -> purchase stream callback | Platform restore plus local keys | Platform stream plus local facade | Partial/asynchronous | Yes | Reads entitlement after restore | Wrapper may report no purchase until purchase stream converges; success still lacks server receipt proof | `release_premium_access_action_v1.dart`, `premium_restore_flow_v1.dart`, Premium Hub tests |
| Restore from Today preview | `UniversalIntakePlanScreen._openPremiumPreviewV1()` restore CTA | Same as above | Same as above | Partial/asynchronous | Yes | Uses fixed `nowEpochMs` for entitlement read | Same restore risk plus older/non-Act0 surface risk | `universal_intake_plan_screen.dart`, Today entitlement tests |
| Start trial | `TrialServiceV1.startTrialIfEligibleV1()` | `trial_entitlement_v1` JSON | Local trial service | Yes, trial entitlement only | No | Yes | Local clock based; rollback guard exists but no server authority | `trial_service_v1.dart`, `trial_service_v1_test.dart` |
| Trial expires | `TrialServiceV1.getTrialStatusV1()` | `trial_entitlement_v1`, clock keys | Local clock with rollback detection | No | No | Yes | Device clock/user data reset can affect local truth | `trial_service_v1.dart` |
| Cloud purchase sync | `PurchaseSyncService.sync()` | Firestore `users/{uid}/purchases`, local `purchased_products` | Best-effort cloud product list | No direct premium ledger write; can trigger restore | Partial | No | Cloud product ID is not receipt proof; errors are swallowed | `purchase_sync_service.dart` |
| Product availability check | `ReleaseCommerceAvailabilityServiceV1.readV1()` | Store queried product IDs | Platform catalog availability | No | Checks canRestore boolean | No | Availability is not purchase/receipt truth | `release_commerce_availability_v1.dart`, tests with overrides |

## 4. Purchase / Restore / Trial Truth Table

| Capability | Current implementation | Verification level | Entitlement convergence | Test coverage | Risk | Recommendation |
| --- | --- | --- | --- | --- | --- | --- |
| Premium upgrade from Premium Hub | Mock gateway receipt through `PremiumService.buyPremium()` | Mock deterministic local validation | Writes `premium_is_active` | UI tests cover success/failure messaging through overrides and local status refresh | Unsafe for public purchase | Do not expose. Replace with store purchase action plus receipt-backed entitlement ledger. |
| Store product purchase | `PaymentService.buyProduct()` calls `buyNonConsumable` for subscription and non-consumable branches | Purchase stream status only | Premium product IDs eventually call `PremiumService.enablePremium()` | Unit tests cover static verification policy and entitlement sync helper | Partial/risky | Implement production receipt verification and correct subscription purchase semantics before paywall. |
| Restore | `PaymentService.restorePurchases()` plus wrapper that checks entitlement after restore | Purchase stream status only; wrapper observes local entitlement | Partial/asynchronous; local premium flag after stream delivery | Restore tests cover outcomes and message truth; payment test covers restored product -> entitlement helper | Partial | Keep restore copy conditional. Require ledger-backed restore proof before public commerce. |
| Trial start | `TrialServiceV1.startTrialIfEligibleV1()` after placement completion | Local SharedPreferences and local time with rollback detection | Trial contributes to `isEntitledToPremium` via facade | Trial tests cover start-once, expiration, rollback, telemetry | Partial | Accept for prototype/trust preview. For paid launch, make trial ledger-backed or server-backed. |
| Trial/premium precedence | Subscription facade chooses premium over trial | Deterministic local rules | Facade converges for reads only | `subscription_status_v1_test.dart` | Medium | Preserve precedence but move writes into ledger. |
| Commerce availability | Store availability and product IDs via `in_app_purchase` | Platform catalog only | No entitlement write | Tests use debug overrides and product-id classifier | Medium | Use as gate for CTA availability only, not proof of payment safety. |
| Cloud purchase sync | Firestore best-effort sync of product IDs | Product ID presence only | Does not directly write entitlement; may call restore | No production receipt proof found | High | Defer or redesign after receipt verification and ledger design. |
| Premium copy claims | Bounded package and preview copy | Static/test evidence | N/A | Contract and UI tests guard forbidden claims | Low | Keep bounded. Do not expand claims until commerce readiness improves. |

## 5. Production-Readiness Gaps

1. No unified production entitlement ledger.
   - `EntitlementSSOTV1` is a read facade over `premium_is_active` and
     `trial_entitlement_v1`; migration is no-op.
   - `PaymentService` also persists `purchased_products`.

2. Premium Hub public upgrade path is mock-backed.
   - `UiV2PremiumHub._upgrade()` calls `PremiumService().buyPremium()`.
   - `PremiumService.buyPremium()` uses `PaymentGatewayService`, which is
     explicitly mock and returns local `MOCK-RECEIPT...`.

3. Store receipt verification is not production-grade.
   - `PaymentService._verifyPurchase()` trusts purchased/restored status.
   - Code comments state backend receipt checks are future hardening.

4. Store purchase semantics are incomplete.
   - `buyProduct()` uses `buyNonConsumable` even for the monthly subscription
     branch.
   - Product delivery comment says actual fulfillment should be handled by a UI
     layer or separate fulfillment service.

5. Restore is message-safe but not fully commerce-safe.
   - Restore wrapper reads local entitlement after calling restore.
   - Success depends on purchase stream timing and local premium flag write.

6. Trial is local and clock-based.
   - Rollback detection exists, which is good, but paid-launch trial truth is
     still local SharedPreferences state rather than a server/account ledger.

7. Cloud purchase sync is not entitlement proof.
   - Firestore stores product IDs, not verified receipts or durable entitlement
     grants.
   - Sync errors are swallowed and do not block or repair entitlement truth.

8. Tests prove deterministic local behavior, not production payment safety.
   - Current tests are useful guards for copy, local state, UI status, and
     wrapper outcomes.
   - They do not prove App Store / Play Store receipt validation, refunds,
     subscription expiry, cancellation, account restore, or cross-device truth.

## 6. High-Risk Surfaces

1. Premium Hub
   - Public exposure would let a mock gateway path grant premium.
   - Must remain hidden/deferred until the upgrade path is production-backed.

2. Any future paywall CTA wired to `PremiumService.buyPremium()`
   - This is mock purchase infrastructure, not public commerce.

3. Restore success claims beyond conditional wording
   - Current copy is bounded, but implementation is still local/stream-driven.
   - Do not imply guaranteed restore, cancel-anytime, refund, or cross-device
     certainty.

4. World/progression premium access claims
   - Copy was tightened away from World 5+ and premium-target claims. Do not
     reintroduce them until entitlement mapping is explicit and tested.

5. Cloud purchase sync
   - Product ID sync can be useful later, but should not be treated as receipt
     verification or authoritative entitlement today.

## 7. Minimum Production Requirements Before Paywall

1. Entitlement Ledger Consolidation
   - Define one `EntitlementLedgerV1` model with explicit records for purchase,
     restore, trial, expiry, source, product ID, transaction ID, verification
     status, and last sync time.
   - Make premium/trial/status reads consume this ledger.
   - Migrate existing `premium_is_active`, `trial_entitlement_v1`, and
     `purchased_products` into explicit legacy/debug inputs, not active truth.

2. Receipt Verification Readiness
   - Replace local purchase-stream trust with App Store / Play Store receipt or
     server verification policy.
   - Define behavior for pending, canceled, failed, refunded, expired,
     restored, and account-switched states.

3. Public Purchase Action Replacement
   - Remove mock `PaymentGatewayService` from public Premium Hub/paywall flows.
   - Wire upgrade to product selection and verified store purchase delivery.

4. Restore Convergence Contract
   - Restore must write or refresh the same ledger used by subscription status.
   - Tests should prove restored purchase -> ledger entitlement -> status ->
     UI, and no purchase -> no entitlement.

5. Trial Ledger Contract
   - Trial should use the same entitlement/status pipeline as paid premium.
   - Preserve value-after-first-loop timing and rollback/fraud safety.

6. Public Commerce Copy/Policy Packet
   - Define store-safe restore, cancellation, refund, subscription management,
     privacy/data, and support language before public paywall surfaces.

## 8. Recommended Next 1-3 Arcs

### Arc 1. Entitlement Ledger Consolidation Design v1

EV: Blocker
Risk: Medium

Create the target ledger contract, migration plan, read/write API, and test
matrix. Do not implement paywall. This should answer exactly how premium, trial,
purchase, restore, expiry, refund, and legacy local flags converge.

### Arc 2. Entitlement Ledger MVP v1

EV: High
Risk: Medium-high

Implement the ledger behind existing local behavior without exposing new public
commerce. Keep `PremiumService`, `TrialServiceV1`, and `SubscriptionServiceV1`
compatible, but make active status read from one ledger-backed source.

### Arc 3. Receipt Verification Readiness v1

EV: High
Risk: High

Define and implement the receipt verification boundary, including production
store product IDs, purchase/restore callbacks, server or platform validation
policy, and failure-state semantics. This should happen before public paywall
or public Premium Hub exposure.

## 9. Deferred List

- Public paywall implementation.
- Public Premium Hub exposure.
- Pricing and subscription offer design.
- App Store / Play Store commerce copy.
- Screenshots, Playwright, or paywall visual design.
- Dashboard, Skill Map, Leak Profile, or content expansion.
- AI/adaptive/GTO/solver positioning.
- Broad cloud sync redesign outside the entitlement ledger.
- Refund/cancel/support UI beyond the policy packet.

## 10. Stop Rules

- Do not expose Premium Hub publicly while `_upgrade()` uses
  `PremiumService.buyPremium()`.
- Do not wire any paywall to `PaymentGatewayService`.
- Do not claim production restore or cross-device entitlement until restore
  writes/refreshes the same ledger used by subscription status.
- Do not use World 5+, premium-target route, seven-day plan, weak-spot drill,
  review queue, progress insight, AI, adaptive, GTO, solver, guaranteed,
  offline/private, cancel-anytime, or restore-always claims until separately
  proven.
- Do not add stronger monetization before first value and return credibility.
- Stop any commerce implementation if receipt verification and entitlement
  convergence are unresolved.

## 11. Direction Score

Current direction: 7.2 / 10.

The learning-value direction is strong: first value is free, premium copy is
bounded, and Sharky has deterministic proof loops that can justify optional
paid depth later. Commerce readiness is the limiting factor. The purchase and
restore infrastructure is useful prototype scaffolding, but it is not yet
production-grade.

## 12. Runout / Benchmark-Stack Comparison

Based only on proven current behavior:

- Runout remains ahead in visible commercial packaging maturity because it
  appears to have an established public subscription/paywall surface.
- Sharky remains ahead in value-before-monetization proof because first useful
  hand, feedback signal proof, same-signal reps, return carry, and repaired
  proof are available before any paywall pressure.
- Sharky's best path is not to rush a paywall. The competitive advantage is
  trust-first learning proof, followed by a commerce stack that is as
  deterministic as the learning loop.

