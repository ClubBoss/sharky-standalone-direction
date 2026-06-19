# Entitlement Ledger Consolidation Design v1

Status: design/spec-only
Date: 2026-06-18

## 1. Purpose

Define the production-oriented entitlement ledger that should replace Sharky's
split premium, trial, restore, and purchase truth before any public paywall or
public Premium Hub exposure.

This document does not implement code, tests, routes, telemetry, UI, copy,
purchase logic, restore logic, screenshots, Playwright, content, table
geometry, dashboard, or visual changes.

Design verdict:

- The current commerce system is not production-safe for public purchase.
- A local-only ledger MVP can make app routing deterministic and safer, but it
  still must not be treated as production commerce until receipt verification is
  implemented.
- Premium Hub must remain hidden/deferred publicly while its upgrade path can
  reach `PremiumService.buyPremium()` and the mock `PaymentGatewayService`.

## 2. Current-State Map

| Seam | Owner/file | Current read/write role | Storage or source | Production read |
| --- | --- | --- | --- | --- |
| Premium flag | `lib/services/premium_service.dart` | Reads/writes premium access through `isPremiumActive()`, `enablePremium()`, `disablePremium()` | `premium_is_active` SharedPreferences bool | Prototype/local flag, not production ledger |
| Mock upgrade | `lib/services/premium_service.dart`, `lib/services/payment_gateway_service.dart` | `buyPremium()` creates a mock receipt and enables premium when local mock validation passes | `MOCK-RECEIPT...`, `premium_is_active` | Unsafe for public purchase |
| Entitlement facade | `lib/services/entitlement_ssot_v1.dart` | Reads premium and trial into `EntitlementStateV1`; migration is currently no-op | `premium_is_active`, `trial_entitlement_v1` | Useful facade, not a ledger |
| Subscription facade | `lib/services/subscription_status_v1.dart` | Converts entitlement facade into free/trial/premium status | `EntitlementSSOTV1` | Deterministic local read layer |
| Trial state | `lib/services/trial_service_v1.dart` | Writes trial after placement; reads active/expired/eligible/clock rollback | `trial_entitlement_v1`, `trial_placement_completed_v1`, `trial_last_seen_epoch_ms_v1`, `trial_clock_rollback_detected_v1` | Local trial policy, not account truth |
| Store purchase catalog | `lib/payments/payment_service.dart` | Queries products and stores available product details | Store product IDs | Platform-dependent availability only |
| Store purchase stream | `lib/payments/payment_service.dart` | Handles pending/error/purchased/restored/canceled purchase statuses | `in_app_purchase` stream | Partial; no production receipt verification |
| Purchased product cache | `lib/payments/payment_service.dart` | Persists product IDs after purchase delivery | `purchased_products` string list | Product cache, not entitlement proof |
| Premium product sync | `lib/payments/payment_service.dart` | Maps premium product IDs to `PremiumService.enablePremium()` | `premium_pack`, `pro_subscription_monthly`, `pro_subscription_annual` | Local convergence only |
| Restore wrapper | `lib/services/premium_restore_flow_v1.dart`, `lib/services/release_premium_access_action_v1.dart` | Calls restore and checks whether entitlement is true afterward | Store restore plus local facade | Message-safe, not ledger-safe |
| Premium Hub | `lib/ui_v2/ui_v2_premium_hub.dart` | Shows status and actions; upgrade uses mock `PremiumService.buyPremium()` | Local status, store availability, mock upgrade | Unsafe publicly |
| Universal Intake premium preview | `lib/ui_v2/screens/universal_intake_plan_screen.dart` | Shows trial/premium preview and restore CTA | Subscription/trial facades and restore wrapper | Partial; older/non-Act0 surface |
| Commerce availability | `lib/services/release_commerce_availability_v1.dart`, `lib/services/release_premium_offer_scope_v1.dart` | Enables/disables restore/upgrade by store availability and product ID set | Platform catalog | CTA safety only, not entitlement truth |
| Purchase cloud sync | `lib/services/purchase_sync_service.dart` | Syncs purchased product IDs to/from Firestore; can call restore | Firestore product IDs | Not receipt proof |

### Current entitlement read seams

- `PremiumService().isPremiumActive()`
- `TrialServiceV1.getTrialStatusV1(...)`
- `EntitlementSSOTV1.readPremiumStateV1(...)`
- `EntitlementSSOTV1.isEntitledToPremiumV1(...)`
- `SubscriptionServiceV1.getStatusV1(...)`
- UI consumers such as Premium Hub, Universal Intake, energy service, campaign
  gates, and tests.

### Current entitlement write seams

- `PremiumService().enablePremium()`
- `PremiumService().disablePremium()`
- `PremiumService().clear()`
- `PremiumService().buyPremium()` through mock gateway
- `TrialServiceV1.markPlacementCompletedV1()`
- `TrialServiceV1.startTrialIfEligibleV1(...)`
- `PaymentService.syncCanonicalEntitlementForProductV1(...)`
- `PaymentService._deliverProduct(...)`
- direct test/shared-preferences writes to `premium_is_active` and
  `trial_entitlement_v1`

### Current product IDs

- `premium_pack`
- `pro_subscription_monthly`
- `pro_subscription_annual`
- `xp_booster`
- `coins_pack_small`
- `coins_pack_medium`
- `coins_pack_large`

Only `premium_pack`, `pro_subscription_monthly`, and
`pro_subscription_annual` currently map to premium entitlement.

## 3. Problems With Current Split Entitlement Truth

1. Reads are facade-centralized, but writes are not.
   - `SubscriptionServiceV1` reads through `EntitlementSSOTV1`.
   - Actual writes still happen in `PremiumService`, `TrialServiceV1`, and
     `PaymentService`.

2. The premium flag is too powerful.
   - `premium_is_active=true` grants premium without proof of purchase,
     restore, receipt, trial, or source.

3. Trial and paid premium are modeled differently.
   - Trial is JSON with start and duration.
   - Premium is a bool.
   - Store purchase is a product-ID cache.

4. Restore is observational instead of authoritative.
   - Restore calls the platform, then checks whether local entitlement became
     true.
   - There is no restore ledger entry with verified transaction data.

5. Purchase verification is not production-grade.
   - `PaymentService._verifyPurchase()` trusts purchased/restored status.
   - The code comment explicitly points to future backend receipt checks.

6. Premium Hub upgrade is mock-backed.
   - `UiV2PremiumHub._upgrade()` calls `PremiumService.buyPremium()`.
   - `PaymentGatewayService` is explicitly mock and local.

7. Cloud sync stores product IDs, not verified entitlement.
   - Firestore product IDs cannot be treated as receipt validation or durable
     subscription state.

8. Tests prove local determinism, not payment safety.
   - Existing tests are useful, but they do not cover App Store / Play Store
     receipt validation, cancellation, expiry, refund, revocation, account
     switching, or server verification.

## 4. Proposed Ledger Model

Create a single ledger record as the canonical entitlement state.

Proposed storage key for local MVP:

- `entitlement_ledger_v1`

Proposed model name:

- `EntitlementLedgerV1`

### Core fields

| Field | Type | Purpose |
| --- | --- | --- |
| `schemaVersion` | int | Ledger schema version. Start at `1`. |
| `entitlementStatus` | enum/string | Main access state: `free`, `trialEligible`, `trialActive`, `trialExpired`, `premiumActive`, `premiumRestored`, `subscriptionActive`, `subscriptionExpired`, `gracePeriod`, `revoked`, `refunded`, `storeUnavailable`, `verificationPending`, `verificationFailed`. |
| `source` | enum/string | Last authority source: `none`, `migrationPremiumFlag`, `migrationTrial`, `localTrial`, `verifiedPurchase`, `verifiedRestore`, `storeRenewal`, `storeExpiry`, `storeRevocation`, `adminDebug`, `testOnly`. |
| `trialState` | object | Trial start/end/eligibility/rollback data. |
| `subscriptionState` | object | Store product/subscription status, expiry, verification, revocation, and grace data. |
| `storeProductId` | string? | Product ID such as `pro_subscription_monthly`; null for free/trial-only state. |
| `purchaseTokenHash` | string? | Hash/reference to token or receipt. Do not store raw receipt in the ledger. |
| `receiptReference` | string? | Backend/store reference ID if available. |
| `originalTransactionIdHash` | string? | Stable hashed transaction family reference for restore/renewal matching. |
| `expiresAtEpochMs` | int? | Trial/subscription expiry timestamp. |
| `lastVerifiedAtEpochMs` | int? | Last successful verification timestamp. |
| `restoreState` | enum/string | `none`, `pending`, `restored`, `noPurchaseFound`, `failed`. |
| `revocationState` | enum/string | `none`, `revoked`, `refunded`, `chargeback`, `unknown`. |
| `gracePeriodState` | enum/string | `none`, `active`, `expired`. |
| `environment` | enum/string | `debug`, `test`, `sandbox`, `production`. |
| `updatedAtEpochMs` | int | Last ledger update. |
| `migrationSourceKeys` | list<string> | Legacy keys used during migration: `premium_is_active`, `trial_entitlement_v1`, `purchased_products`. |
| `isPublicCommerceSafe` | bool | Derived or stored guard: true only when ledger state came from production-safe verification. |
| `lastErrorCode` | string? | Stable machine-readable failure reason. |
| `lastErrorMessage` | string? | User-safe diagnostic if needed. |

### `trialState` object

| Field | Type | Purpose |
| --- | --- | --- |
| `state` | enum/string | `unknown`, `notEligible`, `eligible`, `active`, `expired`, `blockedByPremium`, `blockedByRollback`, `alreadyUsed`. |
| `startEpochMs` | int? | Trial start time. |
| `endEpochMs` | int? | Trial end time. |
| `durationDays` | int? | Current trial duration. |
| `remainingDays` | int | Derived remaining days at read time. |
| `eligibilityReason` | string | Existing reason tokens: `premium_active`, `trial_active`, `trial_already_used`, `placement_incomplete`, `clock_rollback`, `eligible`. |
| `placementCompleted` | bool | Compatibility flag from current trial policy. |
| `clockRollbackDetected` | bool | Preserve current rollback safety. |
| `lastSeenEpochMs` | int? | Preserve current rollback state. |

### `subscriptionState` object

| Field | Type | Purpose |
| --- | --- | --- |
| `state` | enum/string | `none`, `pending`, `active`, `restored`, `expired`, `gracePeriod`, `revoked`, `refunded`, `verificationFailed`. |
| `store` | enum/string | `unknown`, `appStore`, `playStore`, `stripe`, `debug`. |
| `productId` | string? | Store product ID. |
| `transactionIdHash` | string? | Hashed transaction ID or token. |
| `originalTransactionIdHash` | string? | Stable subscription family reference. |
| `verified` | bool | True only after verification boundary succeeds. |
| `verificationProvider` | string? | `appStoreServer`, `playDeveloperApi`, `server`, `localTest`. |
| `purchasedAtEpochMs` | int? | Purchase timestamp. |
| `expiresAtEpochMs` | int? | Subscription expiry. |
| `renewedAtEpochMs` | int? | Last renewal timestamp. |
| `revokedAtEpochMs` | int? | Revocation/refund timestamp. |

### Derived booleans

The ledger read API should compute these, not ask screens to recompute:

- `canAccessPremium`
- `isTrialActive`
- `isTrialEligible`
- `isPremiumActive`
- `isSubscriptionVerified`
- `isRestorePending`
- `isRestoreFailed`
- `isRestoreRecovered`
- `isStoreUnavailable`
- `shouldExposePremiumPreview`
- `shouldExposePublicPaywall`
- `shouldHidePublicPaywall`
- `shouldHidePremiumHub`

## 5. Ledger State Machine

### States

| State | Meaning | Premium access | Public commerce safe |
| --- | --- | --- | --- |
| `free` | No entitlement, no active trial, no verified purchase. | No | Yes |
| `trialEligible` | User can start trial after value/placement policy. | No until started | Partial |
| `trialActive` | Trial is active and not blocked by rollback. | Yes | Partial unless server-backed |
| `trialExpired` | Trial existed and is expired. | No | Yes |
| `premiumActive` | Legacy/debug/local premium flag grants access. | Yes | No for public commerce |
| `premiumRestored` | A restore wrote verified premium entitlement. | Yes | Yes only with production verification |
| `subscriptionActive` | Verified paid subscription is active. | Yes | Yes |
| `subscriptionExpired` | Verified subscription exists but expired. | No | Yes |
| `gracePeriod` | Store says user is in billing grace period. | Yes if store policy says access remains | Yes if verified |
| `revoked` | Store/backend revoked access. | No | Yes |
| `refunded` | Purchase was refunded or charged back. | No | Yes |
| `storeUnavailable` | Store/catalog unavailable for current check. | Preserve last verified entitlement; no new purchase | Partial |
| `verificationPending` | Purchase/restore callback received, verification not finished. | No public premium unless existing verified entitlement remains | Partial |
| `verificationFailed` | Purchase/restore could not be verified. | No new access | Yes |

### Transition table

| From | Event | To | Notes |
| --- | --- | --- | --- |
| `free` | placement completed and trial policy eligible | `trialEligible` | Read-only eligibility may be derived; ledger may persist eligibility reason. |
| `trialEligible` | trial start accepted | `trialActive` | Write start/end in ledger; do not write separate entitlement as active truth. |
| `trialActive` | time >= trial end | `trialExpired` | Preserve trial history. |
| `trialActive` | clock rollback detected | `verificationFailed` or `trialExpired` with rollback reason | MVP can use `trialExpired` plus `trialState.blockedByRollback`; production can use server time. |
| `free` | store purchase initiated | `verificationPending` | No paid access until verification succeeds. |
| `verificationPending` | receipt verified for one-time premium pack | `premiumActive` | Public-safe only if verification provider is production. |
| `verificationPending` | receipt verified for subscription | `subscriptionActive` | Set product, token hash, expiry, verified timestamp. |
| `verificationPending` | verification fails | `verificationFailed` | No new access. |
| `free` | verified restore succeeds | `premiumRestored` or `subscriptionActive` | Restore state becomes `restored`. |
| `free` | restore returns no purchase | `free` | Restore state becomes `noPurchaseFound`. |
| `subscriptionActive` | store expiry event | `subscriptionExpired` | Remove premium access unless grace period applies. |
| `subscriptionActive` | billing retry/grace event | `gracePeriod` | Access depends on store policy and verified signal. |
| `gracePeriod` | renewal verified | `subscriptionActive` | Refresh expiry. |
| `gracePeriod` | grace expires | `subscriptionExpired` | Access false. |
| any paid state | refund/revocation verified | `revoked` or `refunded` | Access false, keep transaction reference. |
| any state | store unavailable | `storeUnavailable` overlay, not destructive transition | Do not erase last verified entitlement just because store is unavailable. |
| legacy local premium flag | migration | `premiumActive` with `source=migrationPremiumFlag` | Access may remain for compatibility but `isPublicCommerceSafe=false`. |
| legacy trial JSON | migration | `trialActive` or `trialExpired` with `source=migrationTrial` | Preserve start/end and rollback fields. |

## 6. Read API Contract

Future implementation target:

- `EntitlementLedgerServiceV1.readLedgerV1({int? nowEpochMs})`
- `EntitlementLedgerServiceV1.readAccessV1({int? nowEpochMs})`
- `EntitlementLedgerServiceV1.isEntitledToPremiumV1({int? nowEpochMs})`
- `EntitlementLedgerServiceV1.readSubscriptionStatusV1({int? nowEpochMs})`
- `EntitlementLedgerServiceV1.readTrialStatusV1({int? nowEpochMs})`
- `EntitlementLedgerServiceV1.readCommerceExposurePolicyV1({int? nowEpochMs})`

### `EntitlementAccessV1`

The read API should return a compact access projection for UI and gates:

| Field | Purpose |
| --- | --- |
| `schemaVersion` | Projection schema. |
| `canAccessPremium` | True for active trial, verified paid entitlement, valid grace period, or compatibility premium state. |
| `why` | Stable reason: `free`, `trial_active`, `trial_eligible`, `legacy_premium_flag`, `verified_purchase`, `verified_restore`, `subscription_active`, `grace_period`, `expired`, `revoked`, `refunded`, `verification_failed`, `store_unavailable`. |
| `entitlementStatus` | Ledger status. |
| `isTrialActive` | Trial active now. |
| `trialRemainingDays` | Derived trial remaining days. |
| `isSubscriptionVerified` | True only for receipt-verified purchase/restore/subscription. |
| `isRestorePending` | Restore in progress or pending verification. |
| `restoreState` | Restore state. |
| `publicCommerceSafe` | True only when access is backed by production-safe verification or free state. |
| `shouldExposePremiumPreview` | Low-pressure preview allowed after first value. |
| `shouldExposePublicPaywall` | False until ledger plus receipt verification are production-ready. |
| `shouldHidePublicPaywall` | True for current MVP. |
| `shouldHidePremiumHub` | True while mock upgrade path remains reachable. |

### Compatibility with existing services

Implementation should initially keep current public APIs stable:

- `EntitlementSSOTV1.isEntitledToPremiumV1(...)` should delegate to ledger
  access instead of reading split keys directly.
- `SubscriptionServiceV1.getStatusV1(...)` should derive its current
  `SubscriptionStatusV1` shape from the ledger projection.
- `TrialServiceV1.getTrialStatusV1(...)` may remain as a facade, but trial
  active/expired state should come from the ledger after MVP migration.
- `PremiumService.isPremiumActive()` may remain as compatibility read, but
  production code should move to the ledger projection.

## 7. Write API Contract

Future implementation target:

- `EntitlementLedgerServiceV1.migrateLegacyKeysIfNeededV1(...)`
- `EntitlementLedgerServiceV1.recordTrialStartedV1(...)`
- `EntitlementLedgerServiceV1.recordTrialExpiredV1(...)`
- `EntitlementLedgerServiceV1.recordTrialClockRollbackV1(...)`
- `EntitlementLedgerServiceV1.recordPurchasePendingV1(...)`
- `EntitlementLedgerServiceV1.recordVerifiedPurchaseV1(...)`
- `EntitlementLedgerServiceV1.recordVerifiedRestoreV1(...)`
- `EntitlementLedgerServiceV1.recordNoPurchaseFoundRestoreV1(...)`
- `EntitlementLedgerServiceV1.recordVerificationFailedV1(...)`
- `EntitlementLedgerServiceV1.recordSubscriptionExpiredV1(...)`
- `EntitlementLedgerServiceV1.recordGracePeriodStartedV1(...)`
- `EntitlementLedgerServiceV1.recordRevokedV1(...)`
- `EntitlementLedgerServiceV1.recordRefundedV1(...)`
- `EntitlementLedgerServiceV1.recordStoreUnavailableV1(...)`
- `EntitlementLedgerServiceV1.debugSetEntitlementForTestsOnlyV1(...)`

### Allowed production writers

| Writer | Allowed write | Constraints |
| --- | --- | --- |
| Trial policy | `recordTrialStartedV1`, `recordTrialExpiredV1`, `recordTrialClockRollbackV1` | Must preserve first-value timing and rollback rules. |
| Purchase verification boundary | `recordPurchasePendingV1`, `recordVerifiedPurchaseV1`, `recordVerificationFailedV1` | Verified write only after receipt/token verification succeeds. |
| Restore verification boundary | `recordVerifiedRestoreV1`, `recordNoPurchaseFoundRestoreV1`, `recordVerificationFailedV1` | Restore success must write ledger before UI reports restored. |
| Store/subscription sync | `recordSubscriptionExpiredV1`, `recordGracePeriodStartedV1`, `recordRevokedV1`, `recordRefundedV1` | Must use verified store/backend signals. |
| Migration | `migrateLegacyKeysIfNeededV1` | One-way compatibility import; should record source keys and mark public commerce unsafe for legacy premium. |

### Test/debug writers

Debug writes are allowed only behind explicit test/debug APIs:

- `debugSetEntitlementForTestsOnlyV1(...)`
- `debugClearLedgerForTestsOnlyV1(...)`

Rules:

- Debug writes must set `environment=test` or `environment=debug`.
- Debug writes must set `isPublicCommerceSafe=false`.
- Public paywall code must not depend on debug entitlement.

### Disallowed production writers

- Direct production writes to `premium_is_active`.
- Public purchase success through `PaymentGatewayService`.
- UI code directly setting premium/trial keys.
- Firestore product ID sync directly granting access without verification.
- Restore success without a ledger write.

## 8. Migration / Compatibility Plan

### Storage keys to migrate or preserve

| Key | Current owner | Migration handling |
| --- | --- | --- |
| `premium_is_active` | `PremiumService` | Read once during migration. If true, create ledger state `premiumActive`, `source=migrationPremiumFlag`, `publicCommerceSafe=false`. Keep key readable for rollback/debug but stop treating it as active truth after ledger read path lands. |
| `trial_entitlement_v1` | `TrialServiceV1` | Parse using existing `TrialEntitlementV1.tryParse`. Create `trialActive` or `trialExpired` depending on `nowEpochMs`. |
| `trial_placement_completed_v1` | `TrialServiceV1` | Preserve into `trialState.placementCompleted`. |
| `trial_last_seen_epoch_ms_v1` | `TrialServiceV1` | Preserve into `trialState.lastSeenEpochMs`. |
| `trial_clock_rollback_detected_v1` | `TrialServiceV1` | Preserve into `trialState.clockRollbackDetected`. |
| `purchased_products` | `PaymentService` | Import as non-authoritative product cache. Do not grant public-safe access from product ID alone. |
| `entitlement_ssot_migrated_v1` | `EntitlementSSOTV1` | Replace with ledger migration marker such as `entitlement_ledger_migrated_v1`. |

### Migration phases

1. Add ledger model/service and tests without changing public commerce.
2. On first read, migrate legacy keys into ledger.
3. Keep old keys read-only for compatibility and test setup during the first
   implementation wave.
4. Point `EntitlementSSOTV1` and `SubscriptionServiceV1` reads at ledger
   projections.
5. Move trial starts to ledger writes while preserving existing
   `TrialServiceV1` API shape.
6. Move purchase/restore convergence to ledger writes.
7. Deprecate direct `PremiumService.enablePremium()` in production code; keep
   debug/test-only behavior explicit.

### Compatibility rule

Legacy local premium may keep access in development/current-user compatibility,
but it must not satisfy public commerce safety checks. This lets existing local
flows keep working while preventing a public paywall from treating a bool as a
verified purchase.

## 9. Restore / Purchase / Trial Convergence Rules

### Trial convergence

- Trial start writes one ledger record with `entitlementStatus=trialActive`,
  `source=localTrial`, `trialState.state=active`, `expiresAtEpochMs`, and
  `environment` from runtime.
- Trial expiry is derived on read and may be persisted on next write.
- Clock rollback writes or derives a blocked state and sets trial access false.
- Premium verified access overrides trial in read projection, but trial history
  remains stored.

### Purchase convergence

- Purchase initiated writes `verificationPending`.
- Purchase stream callback alone must not grant access.
- Receipt/token verification success writes `subscriptionActive` or
  `premiumActive` with product ID, token hash/reference, expiry if available,
  and `lastVerifiedAtEpochMs`.
- Verification failure writes `verificationFailed` and does not grant new
  premium access.
- Non-entitlement products must never grant premium.

### Restore convergence

- Restore start writes `restoreState=pending` or a pending projection.
- Restore no-purchase writes `restoreState=noPurchaseFound` and preserves free
  or existing entitlement state.
- Restore success writes `premiumRestored` or `subscriptionActive` through the
  same verified path as purchase.
- UI should report "restored" only after the ledger read returns verified
  access or an existing verified entitlement.

### Revocation/refund convergence

- Verified refund writes `refunded`, clears premium access, and preserves
  product/transaction references.
- Verified revocation writes `revoked`, clears premium access, and records
  reason.
- Subscription expiry writes `subscriptionExpired` unless grace period is
  active.

### Store unavailable convergence

- Store unavailable should not delete a last verified entitlement.
- Store unavailable should block new purchase/restore actions and set a
  recoverable store state.
- Public commerce UI should explain unavailability without implying purchase
  failure or entitlement loss.

## 10. Receipt Verification Boundary

The ledger MVP can be local-only for routing safety, but production commerce
requires a separate verification boundary.

Required boundary decisions:

1. Verification provider.
   - App Store server API, Play Developer API, backend receipt verification, or
     a clearly scoped platform validation layer.

2. Token handling.
   - Ledger stores `purchaseTokenHash` or `receiptReference`, not raw receipt.
   - Raw receipt/token should be passed only to the verification boundary.

3. Verification outcomes.
   - `verified_active`
   - `verified_restored`
   - `pending`
   - `expired`
   - `grace_period`
   - `revoked`
   - `refunded`
   - `no_purchase_found`
   - `verification_failed`
   - `store_unavailable`

4. Account/device behavior.
   - Restore should reconcile account/store state into the ledger.
   - Cross-device sync must use verified entitlement state, not only product ID.

5. Offline behavior.
   - Last verified entitlement may be honored for a bounded period if product
     policy allows it.
   - New purchases/restores cannot be granted offline.

Do not overdesign backend internals in the ledger MVP. The ledger should define
the contract and placeholder fields, while Receipt Verification Readiness v1
should decide the production verification mechanism.

## 11. Premium Hub Exposure Rules

Premium Hub must stay hidden/deferred publicly until all of these are true:

1. `_upgrade()` no longer reaches `PremiumService.buyPremium()`.
2. `PaymentGatewayService` is not reachable from public purchase UI.
3. Upgrade action writes ledger only after verified purchase.
4. Restore action writes ledger only after verified restore or records
   no-purchase/failure.
5. `SubscriptionServiceV1` reads from ledger, not split local keys.
6. Public commerce exposure policy says `shouldExposePublicPaywall=true`.
7. First useful learning loop remains free and premium-pressure-free.
8. Premium copy remains bounded to proven value and does not reintroduce
   unsupported claims.

Allowed before those conditions:

- Low-pressure premium preview after value proof.
- Internal/dev Premium Hub route.
- Store-unavailable messaging in older surfaces if already reachable.

Not allowed before those conditions:

- Public paywall.
- Public Premium Hub purchase CTA.
- Trial or premium pressure before first value.
- Any claim that restore always works, cancellation is handled, all worlds are
  unlocked, AI/adaptive personalization exists, or solver/GTO training exists.

## 12. Required Test Matrix

### Ledger model and migration tests

| Test | Purpose |
| --- | --- |
| `ledger defaults to free with public paywall hidden` | Empty storage yields `free`, `canAccessPremium=false`, `shouldHidePublicPaywall=true`. |
| `migration imports premium_is_active as legacy premium only` | Legacy bool grants compatibility access but sets `source=migrationPremiumFlag` and `publicCommerceSafe=false`. |
| `migration imports active trial_entitlement_v1` | Active trial JSON becomes `trialActive` with correct expiry/remaining days. |
| `migration imports expired trial_entitlement_v1` | Expired trial becomes `trialExpired`, not premium access. |
| `migration records purchased_products as non-authoritative cache` | Product IDs are recorded in migration metadata but do not grant public-safe access. |
| `migration is idempotent` | Repeated reads do not duplicate or mutate ledger incorrectly. |

### Trial tests

| Test | Purpose |
| --- | --- |
| `trial start writes ledger and existing TrialService status remains compatible` | Existing facade still reports active trial after ledger write. |
| `trial cannot restart after expiry` | Existing start-once behavior survives ledger. |
| `trial active expires by nowEpochMs` | Access becomes false when trial end is reached. |
| `clock rollback blocks trial access` | Rollback state is preserved and access false. |
| `premium verified access suppresses active trial in subscription projection` | Premium source wins, trial history remains. |

### Purchase and restore tests

| Test | Purpose |
| --- | --- |
| `purchase pending does not grant premium` | Pending state has no new premium access. |
| `purchase success grants premium only after verification` | Purchase stream status alone is insufficient. |
| `verified subscription writes subscriptionActive with product and expiry` | Verified monthly/annual product grants access with expiry. |
| `verified legacy premium pack writes premiumActive` | One-time pack maps to premium state if still supported. |
| `non-entitlement product never grants premium` | Coins/boosters do not affect premium. |
| `restore pending does not report restored` | UI cannot show restored until ledger confirms. |
| `restore success writes restored ledger state` | Restore success converges through ledger and status facade. |
| `restore no-purchase found keeps access false` | No purchase found does not grant access. |
| `store unavailable preserves last verified entitlement` | Temporary store failure does not erase access. |
| `verification failed keeps access false` | Failure does not grant premium. |
| `expired subscription removes premium access` | Expiry transitions to no access unless grace period. |
| `grace period keeps access only when verified` | Grace period is explicit and bounded. |
| `refunded purchase revokes access` | Refund clears entitlement. |
| `revoked purchase revokes access` | Revocation clears entitlement. |

### Public exposure and safety tests

| Test | Purpose |
| --- | --- |
| `Premium Hub hidden while mock path exists` | Public exposure policy stays false until mock path is removed. |
| `public paywall cannot read from premium_is_active directly` | Paywall reads ledger exposure policy only. |
| `PaymentGatewayService is unreachable from public purchase path` | Public commerce path does not import/call mock gateway. |
| `first-value path remains free and premium-pressure-free` | Existing Act0 first-value guards stay green. |
| `premium preview copy remains bounded` | Existing forbidden-claim guard stays green. |
| `debug entitlement is never public commerce safe` | Test/debug writes grant only debug-compatible state. |

### Existing tests to preserve or adapt

- `test/services/subscription_status_v1_test.dart`
- `test/services/trial_service_v1_test.dart`
- `test/services/release_premium_access_action_v1_test.dart`
- `test/services/premium_restore_flow_v1_test.dart`
- `test/payments/payment_service_restore_verification_policy_v1_test.dart`
- `test/ui_v2/premium_hub_access_state_v1_test.dart`
- `test/ui_v2/today_plan_entitlement_truth_v1_test.dart`
- Act0 premium absence tests in `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

These existing tests currently prove local deterministic behavior and UI-message
truth. The ledger implementation must add tests for production-safety
semantics that the current suite does not prove.

## 13. Implementation Roadmap

### Arc 1. Entitlement Ledger MVP v1

Goal: make entitlement reads deterministic through one local ledger without
exposing public commerce.

Scope:

- Add ledger model and service.
- Add migration from `premium_is_active`, `trial_entitlement_v1`, trial
  metadata keys, and `purchased_products`.
- Point `EntitlementSSOTV1` and `SubscriptionServiceV1` at ledger projections.
- Preserve existing public API shapes.
- Keep Premium Hub public exposure false.
- Keep `PaymentGatewayService` as dev/test-only and not public-safe.

Exit criteria:

- Existing local entitlement/trial/status tests pass after adaptation.
- New ledger migration tests pass.
- First-value premium absence tests remain green.
- No public paywall or Premium Hub exposure.

### Arc 2. Ledger Write Consolidation v1

Goal: move trial, restore, and purchase convergence writes behind ledger APIs.

Scope:

- `TrialServiceV1.startTrialIfEligibleV1()` writes ledger.
- Restore wrapper records pending/no-purchase/failure/restored via ledger.
- `PaymentService.syncCanonicalEntitlementForProductV1()` becomes a ledger
  write adapter.
- Debug/test writes are explicit and marked not public-commerce-safe.

Exit criteria:

- Restore success only after ledger write.
- Purchase success only through ledger write.
- Trial start/expiry/rollback remain deterministic.
- Premium Hub still hidden publicly.

### Arc 3. Receipt Verification Readiness v1

Goal: define and implement the production verification boundary.

Scope:

- Decide verification provider and token handling.
- Replace purchase-stream trust with verification result mapping.
- Add subscription expiry, grace period, refund, and revocation handling.
- Make restore converge through verified ledger write.

Exit criteria:

- Verified purchase/restore tests cover active, expired, refunded, revoked, and
  no-purchase states.
- Public commerce policy can independently evaluate whether paywall exposure
  is allowed.

### Arc 4. Public Commerce Exposure Gate v1

Goal: only after ledger and verification pass, define the route-safe exposure
gate for Premium Hub/paywall.

Scope:

- Gate Premium Hub public route by ledger exposure policy.
- Ensure mock gateway is unreachable from public commerce.
- Keep first-value route free.
- Keep premium copy bounded to proven table-clue practice.

Exit criteria:

- Public paywall is still not implemented unless explicitly admitted.
- Exposure policy can say "hidden" or "eligible" from verified ledger state.

## 14. Deferred List

- Paywall UI implementation.
- Public Premium Hub exposure.
- Pricing and subscription offer design.
- App Store / Play Store screenshots.
- Store metadata, cancellation/refund/support copy.
- Backend receipt verification internals beyond the boundary contract.
- Cloud purchase sync redesign outside ledger requirements.
- Dashboard, Skill Map, Leak Profile, or content expansion.
- AI/adaptive/GTO/solver positioning.
- Any table/ModernTable geometry work.

## 15. Stop Rules

- Do not expose Premium Hub publicly while it can call `PremiumService.buyPremium()`.
- Do not wire any paywall or public purchase CTA to `PaymentGatewayService`.
- Do not let `premium_is_active` satisfy public commerce safety.
- Do not grant premium on purchase/restored stream status before verification.
- Do not report restore success before ledger convergence.
- Do not delete legacy keys before migration and compatibility tests are green.
- Do not expand premium claims beyond optional table-clue/table-read practice
  until paid entitlement truth supports broader claims.
- Do not add monetization pressure before the first useful learning loop and
  return credibility.
- Stop any implementation that requires backend receipt design without a
  separate Receipt Verification Readiness wave.

## 16. Direction Score

Current direction: 7.4 / 10.

Sharky's product direction is strong because the learning loop is value-first:
first useful hand, feedback proof, same-signal reps, return carry, and repaired
proof exist before paywall pressure. The commerce direction is improving
because copy is bounded and the blocker is now clearly identified. The score is
limited by mock upgrade, split entitlement writes, and missing production
receipt verification.

## 17. Runout / Benchmark-Stack Comparison

Based only on proven current behavior:

- Runout remains ahead in visible commercial packaging and public
  subscription/paywall maturity.
- Sharky remains ahead in trust-first learning proof before monetization.
- Sharky should not copy a paywall-first move. The right competitive response
  is to make commerce truth deterministic enough to match the deterministic
  learning proof spine.
- The next meaningful competitive lift is not pricing or visuals. It is making
  entitlement, restore, purchase, trial, and public exposure rules impossible to
  fake or accidentally overstate.

