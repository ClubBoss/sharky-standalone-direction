# R20 Entitlement/Paywall Interaction Matrix v1

## Scope
Slice A verification of entitlement/paywall determinism across launch-critical surfaces:
- map/start
- result
- checkpoint
- re-entry behavior
- restore/premium/trial precedence

## Interaction Matrix
| State/Path | Classification | Evidence |
|---|---|---|
| Non-entitled user -> today plan start on premium-target placement | PROVEN by existing code/tests | `test/guards/world_campaign_map_home_contract_test.dart` (`today plan gates world5 placement behind premium preview and restore unblocks next attempt`) shows paywall preview appears and runner does not open before entitlement. |
| Trial-active user -> today plan start on premium-target placement | PROVEN by existing code/tests | `test/guards/world_campaign_map_home_contract_test.dart` (`today plan allows trial-active entitlement to open premium-target placement deterministically`) shows runner opens directly and premium preview is absent. |
| Premium-entitled user -> today plan start on premium-target placement | PROVEN by existing code/tests | `test/guards/world_campaign_map_home_contract_test.dart` same premium gate/restore test verifies entitlement sync allows deterministic open to `world5_spine_campaign_v1`. |
| Restore path after prior entitlement | PROVEN by existing code/tests | `test/payments/payment_service_restore_verification_policy_v1_test.dart` verifies restored purchase converges entitlement true, none/error paths preserve deterministic state. Runtime: `lib/payments/payment_service.dart` (`isVerifiedEntitlementV1`, `syncCanonicalEntitlementForProductV1`). |
| Premium/trial precedence facade | PROVEN by existing code/tests | `test/services/subscription_status_v1_test.dart` verifies precedence and deterministic source tagging. Runtime: `lib/services/entitlement_ssot_v1.dart`, `lib/services/subscription_status_v1.dart`. |
| Map checkpoint pending entry visibility + CTA open checkpoint | PROVEN by existing code/tests | `test/guards/world_campaign_map_home_contract_test.dart` tests strip visible only when pending and CTA opens checkpoint runner. Runtime: `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` (`map_checkpoint_pending_strip`, `checkpoint_entry_cta_v1`). |
| Result/checkpoint/map re-entry loop (no dead end) | PROVEN by existing code/tests | `test/ui_v2/session_result_screen_contract_test.dart` tests checkpoint pending routes to `season1_checkpoint_global_v1`, clears pending on success, and deterministic return path after result. Runtime: `lib/ui_v2/screens/session_result_screen.dart`, `lib/services/progress_service.dart`. |
| Split-store convergence edge (premium flag, trial JSON, purchased products) | PARTIALLY PROVEN / missing contract | `docs/plan/MONETIZATION_SSOT_v1.md` still documents multi-store state and unresolved v2b/v2c hardening; current tests prove deterministic behavior for current flows but do not prove one unified ledger design. |

## Unresolved Items
1. No single entitlement ledger is implemented yet (documented in `docs/plan/MONETIZATION_SSOT_v1.md`).
2. This is a design hardening gap, not a detected deterministic routing bug in current launch-critical surfaces.

## Verdict
**Launch-safe for current launch-critical routing surfaces; blocked by missing-proof/design-hardening only if launch requires unified entitlement-ledger guarantees.**

For first launch readiness under current scope:
- No deterministic runtime mismatch was found in map/start/result/checkpoint entitlement routing.
- Remaining risk is documented technical debt (entitlement convergence architecture), not an active route-integrity failure.
