# MONETIZATION_SSOT_v1

Status: ACTIVE for monetization truth.

## 0) Launch monetization / route truth lock (2026-06-18)

This section is the current launch-facing monetization and route-truth overlay.
It supersedes any older local implementation notes below when planning public
premium preview, paywall, trial, or route-gate work.

### Active launch route truth

The active Act0 launch route is:

| World | Launch-facing title |
| --- | --- |
| W1 | Poker from Zero |
| W2 | Hand Discipline |
| W3 | Position Thinking |
| W4 | Preflop Framework |
| W5 | Bet Purpose + Price |
| W6 | Board and Draws |

Older authored/content documents may still describe W4 as `Bet Purpose + Price`
and W5 as `Board Awareness`. Those meanings are stale or secondary for
monetization work until a dedicated route/content normalization wave changes the
active route truth. Premium, paywall, trial, and preview copy must follow the
active launch route above.

### Accepted preview status

The current accepted public monetization surface is a soft premium value preview
after completed daily/session learning value.

Accepted state:

- appears after the completed Practice/session result state;
- keeps `Practice extra reps` as the dominant free/learning action;
- shows `See what premium adds` as a secondary entry;
- opens a boundary-neutral preview sheet;
- does not expose commerce, price, purchase, trial, restore, Premium Hub,
  entitlement change, or route gating;
- does not mention W4, W5, world unlocks, AI/adaptive/GTO/solver, guaranteed
  improvement, or win-rate claims.

Accepted proof:

- `docs/_reviews/compact_english_premium_preview_proof_v1.md`
- `output/playwright/premium_preview_proof_v1/practice_complete_compact_en.png`
- `output/playwright/premium_preview_proof_v1/premium_preview_sheet_compact_en.png`

### Launch monetization default

Launch default:

- `W1-W4` are the free public foundation.
- `W5+` is the future paid-depth boundary.
- soft premium preview may appear only after completed learning value.
- no hard paywall ships until production commerce safety is closed.

W4 status:

- W4 is a primary future challenger / A-B candidate, not the current launch
  default hard gate.
- W4 can graduate only after route truth normalization, W1-W3/W4 telemetry,
  time-to-decision/confidence evidence, and commerce readiness.
- W3 is not a launch-default paid gate.

### Trial timing lock

Launch trial default:

- no trial before placement;
- no trial on placement result;
- no trial before first hand, first feedback, first completion, or the soft
  premium preview;
- no trial inside the soft premium preview;
- contextual 7-day trial may be offered only at a future W5 locked-depth/paywall
  attempt, or later high-intent proof, after commerce safety is production-ready.

D2 return, high-intent, preview-clicker, dynamic behavior, repair-depth, and
analytics/leak-profile trial/upsell timing are deferred experiments, not launch
default.

### Current forbidden preview/paywall copy

Current preview copy may say:

- more reps;
- deeper repair/review;
- longer route depth;
- after the free foundation;
- when you are ready.

Current preview/paywall planning must not say:

- `Unlock W4`;
- `Unlock W5`;
- `W5 is premium`;
- `Bet Purpose is premium`;
- `start trial`;
- `restore`;
- `price`;
- `purchase`;
- `upgrade now`;
- `unlock all`;
- AI/adaptive/GTO/solver/optimal/frequency;
- guaranteed improvement or win-rate claims.

### Deferred commerce work

Still deferred / blocked until scoped separately:

- public hard paywall;
- Premium Hub public exposure;
- pricing;
- public trial start;
- restore;
- receipt verification;
- W4/W5 A-B test;
- one-time starter pack;
- dynamic behavior gate;
- repair-depth premium;
- analytics/leak-profile upsell;
- direct `practice_complete` capture URL productivity improvement.

This document is the current single source of truth for monetization behavior implemented in code.
It is descriptive only for current state (R4 Batch v2a), not a redesign.

## 1) Product model (as currently implemented)

### Free baseline
- Free users can run core Today Plan flows and campaign flows.
- Trial can be offered after placement completion.
- Today plan entries are governed by `TodayEntitlementsV1.free()` with `todayEntriesPerDay = 1`.
  Source: `lib/services/progress_service.dart:803`, `lib/services/progress_service.dart:3318`.

### Premium state
- Premium is represented as a local boolean flag `premium_is_active`.
  Source: `lib/services/premium_service.dart:20`.
- Premium can affect feature behavior via `SubscriptionServiceV1` composed status.
  Source: `lib/services/subscription_status_v1.dart:35`.

### Trial state
- Trial is modeled separately as `TrialEntitlementV1` persisted JSON (`trial_entitlement_v1`) with 7-day duration.
  Source: `lib/services/trial_service_v1.dart:8`, `lib/services/trial_service_v1.dart:80`.
- Trial eligibility and status are computed from premium flag, placement completion, entitlement history, and rollback checks.
  Source: `lib/services/trial_service_v1.dart:96`.

### Payment catalog (IAP layer)
- Product IDs declared in `PaymentService`:
  - `premium_pack`
  - `pro_subscription_monthly`
  - `pro_subscription_annual`
  - `xp_booster`
  - `coins_pack_small`
  - `coins_pack_medium`
  - `coins_pack_large`
  Source: `lib/payments/payment_service.dart:37`, `lib/payments/payment_service.dart:44`.

## 2) Entitlement source-of-truth (current reality)

Current implementation has multiple entitlement-related stores. There is no single unified entitlement store yet.

### A) Premium flag store
- Key: `premium_is_active` (bool in SharedPreferences).
- API:
  - `isPremiumActive()`
  - `enablePremium()`
  - `disablePremium()`
  Source: `lib/services/premium_service.dart:20`, `lib/services/premium_service.dart:32`, `lib/services/premium_service.dart:41`, `lib/services/premium_service.dart:49`.

### B) Trial entitlement store
- Keys:
  - `trial_entitlement_v1`
  - `trial_placement_completed_v1`
  - telemetry/control keys (`trial_offer_shown_logged_v1`, `trial_status_day_key_v1`, `trial_last_seen_epoch_ms_v1`, `trial_clock_rollback_detected_v1`)
- Trial activation API:
  - `startTrialIfEligibleV1()` writes trial entitlement.
- Trial status API:
  - `getTrialStatusV1(nowEpochMs: ...)`.
  Source: `lib/services/trial_service_v1.dart:80`, `lib/services/trial_service_v1.dart:181`, `lib/services/trial_service_v1.dart:96`.

### C) IAP purchased products store
- Key: `purchased_products` (string list).
- Managed inside `PaymentService`.
- Tracks purchased product IDs, but does not itself set `premium_is_active` directly.
  Source: `lib/payments/payment_service.dart:53`, `lib/payments/payment_service.dart:305`, `lib/payments/payment_service.dart:324`.

## 3) Purchase flows (as coded)

### Flow A: Mock premium purchase (non-store)
- UI path: `UiV2PremiumHub` -> `PremiumService.buyPremium()`.
- Backend path:
  - `PaymentGatewayService.purchasePremium()` returns mock receipt.
  - `PaymentGatewayService.validateReceipt()` returns deterministic pass score (0.95).
  - On validated result, `premium_is_active` is enabled.
- Sources:
  - `lib/ui_v2/ui_v2_premium_hub.dart:32`
  - `lib/services/premium_service.dart:77`
  - `lib/services/payment_gateway_service.dart:27`, `lib/services/payment_gateway_service.dart:39`.

### Flow B: Store IAP purchase flow
- `PaymentService.initialize()` checks store availability and subscribes to purchase stream.
- `buyProduct()` triggers `buyNonConsumable(...)` currently for both subscription and non-consumable branches.
- Purchase status handling:
  - `pending` -> logs pending
  - `error` -> sets `_lastError`
  - `purchased/restored` -> `_verifyPurchase()` then `_deliverProduct()` and persist product ID
  - `canceled` -> logs canceled
- Sources:
  - `lib/payments/payment_service.dart:56`, `lib/payments/payment_service.dart:69`
  - `lib/payments/payment_service.dart:141`
  - `lib/payments/payment_service.dart:221`
  - `lib/payments/payment_service.dart:277`.

### Flow C: Restore
- `PaymentService.restorePurchases()` calls `InAppPurchase.restorePurchases()`.
- Also used by `PurchaseSyncService.sync()` when cloud purchases indicate local update is needed.
- Sources:
  - `lib/payments/payment_service.dart:185`
  - `lib/services/purchase_sync_service.dart:125`.

## 4) Offline policy (current behavior)

### Premium/trial local state
- Premium and trial status are local SharedPreferences-driven and readable offline.
- Trial status requires caller-provided or current epoch time; clock rollback is detected and disables eligibility.
- Sources:
  - `lib/services/premium_service.dart:32`
  - `lib/services/trial_service_v1.dart:96`, `lib/services/trial_service_v1.dart:103`.

### Store IAP path
- If store is unavailable, `PaymentService` sets an error and does not proceed with catalog/purchase.
- Source: `lib/payments/payment_service.dart:58`.

### Cloud sync path
- Purchase cloud sync is best-effort; errors are caught and logged, not fatal.
- Source: `lib/services/purchase_sync_service.dart:58`, `lib/services/purchase_sync_service.dart:94`.

## 5) Receipt verification policy (current)

### Store IAP verification
- `_verifyPurchase()` is a stub that always returns `true`.
- Explicit comment says server-side verification is TODO for production.
- Source: `lib/payments/payment_service.dart:277`.

### Mock gateway verification
- `validateReceipt()` is deterministic local validation with fixed score 0.95.
- Source: `lib/services/payment_gateway_service.dart:39`.

## 6) Routing and gating points (current)

### Gate point 1: UI v2 Progress Map premium pack lock
- Premium packs are inferred heuristically (`meta['premium']`, tags containing `premium`, or advanced stack/spot thresholds).
- If pack is premium and user is not premium, open is blocked and a Snackbar prompts upgrade to `UiV2PremiumHub`.
- Sources:
  - `lib/ui_v2/ui_v2_progress_map_screen.dart:68`
  - `lib/ui_v2/ui_v2_progress_map_screen.dart:189`.

### Gate point 2: Universal Intake Plan monetization surface
- Intake computes trial/subscription status and displays monetization row:
  - premium active line
  - trial status and preview CTA
  - start trial CTA when eligible
- This surface is informational/entry UX; not a hard route block by itself.
- Sources:
  - `lib/ui_v2/screens/universal_intake_plan_screen.dart:279`
  - `lib/ui_v2/screens/universal_intake_plan_screen.dart:1591`
  - `lib/ui_v2/screens/universal_intake_plan_screen.dart:1673`.

### Gate point 3: Energy premium bypass
- Premium users bypass energy depletion (`getCurrentEnergy()` returns max, `useEnergy()` always true).
- Source: `lib/services/energy_service.dart:32`, `lib/services/energy_service.dart:56`.

### ProgressService routing note
- `ProgressService` currently exposes only free today entitlements (`todayEntriesPerDay = 1`) and does not own premium gating logic.
- Source: `lib/services/progress_service.dart:803`.

## 7) Determinism constraints

### Must remain deterministic
- SharedPreferences keys and state transitions for premium/trial flags.
- Trial eligibility and reason mapping from fixed rules.
- Premium pack heuristic in UI v2 progress map (same data -> same result).
- Sources:
  - `lib/services/premium_service.dart`
  - `lib/services/trial_service_v1.dart`
  - `lib/ui_v2/ui_v2_progress_map_screen.dart:68`.

### Allowed platform-dependent behavior
- Store availability and purchase stream status from `in_app_purchase`.
- Restore and purchase callbacks timing from platform IAP layer.
- Source: `lib/payments/payment_service.dart`.

## 8) Known limitations

- Entitlement state is split across multiple stores (`premium_is_active`, trial JSON entitlement, `purchased_products`) with no single authoritative ledger.
- Store IAP verification is stubbed (always true).
- Product delivery in `PaymentService` persists purchased IDs but does not unify entitlement writes to premium/trial status.
- Coexistence of mock premium purchase path and store IAP path can diverge entitlement outcomes.
- Some premium gating is heuristic-based (`_isPremiumPack`) rather than explicit content entitlement mapping.

## 9) Next hardening steps (R4 v2b/v2c, doc-only plan)

- R4 v2b: define one entitlement SSOT service with explicit product-to-entitlement mapping and migration from current keys.
- R4 v2b: make routing gates read only that SSOT service; remove duplicate heuristic gate decisions where possible.
- R4 v2c: implement real receipt verification policy (server-side), and make `restore` converge to entitlement SSOT.
- R4 v2c: add deterministic contract tests for entitlement transitions (buy, restore, premium/trial precedence, offline startup).
