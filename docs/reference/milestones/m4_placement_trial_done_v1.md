# M4 Placement Trial Done v1

- Status: M4 v1 DONE (placement + routing + trial skeleton).

- Entry points (paths + signatures):
  - `lib/services/placement_service_v1.dart`
    - `static Future<void> startPlacementV1({required int totalItems})`
    - `static Future<void> recordAnswerV1({required bool correct, required int decisionMs})`
    - `static Future<PlacementResultV1> finishPlacementV1({required String skillBand})`
  - `lib/services/placement_service_v1.dart`
    - `class PlacementRouteV1`
    - `static Future<PlacementRouteV1> computePlacementRouteV1(PlacementResultV1 result)`
  - `lib/services/trial_service_v1.dart`
    - `class TrialEntitlementV1`
    - `static Future<void> markPlacementCompletedV1()`
    - `static Future<TrialStatusV1> getTrialStatusV1({required int nowEpochMs})`
    - `static Future<TrialStatusV1> startTrialIfEligibleV1({required int nowEpochMs})`
  - `lib/services/subscription_status_v1.dart`
    - `class SubscriptionStatusV1` fields include `isTrialActive` and `trialRemainingDays`
  - `lib/ui_v2/screens/universal_intake_plan_screen.dart`
    - placement keys: `today_plan_placement_result_v1`, `today_plan_placement_route_v1`
    - trial keys: `today_plan_trial_start_cta_v1`, `today_plan_trial_status_v1`

- Deterministic rules:
  - Placement bucket mapping and confidence gating are deterministic in `PlacementServiceV1`.
  - Confidence gate threshold for advanced downgrade is fixed in the route mapper.
  - Max-1 repair policy: `PlacementRouteV1.repairSessionId` is nullable and holds at most one session id.
  - Trial eligibility reasons are fixed tokens: `premium_active`, `trial_active`, `trial_already_used`, `placement_incomplete`, `eligible`.
  - Trial start-once behavior: once entitlement is persisted, later starts do not overwrite.
  - `trial_status_v1` telemetry is throttled once per UTC day via persisted day key.

- Telemetry contracts (event -> payload fields):
  - `placement_start_v1` -> `schemaVersion`, `skillBand`, `totalItems`
  - `placement_end_v1` -> `schemaVersion`, `bucket`, `confidence`, `weakAreasCount`, `durationMs`, `correctCount`, `totalCount`
  - `placement_route_selected_v1` -> `schemaVersion`, `bucket`, `confidence`, `startTargetSessionId`, `repairSessionId`, `reasonCodesCount`
  - `trial_offer_shown_v1` -> `schemaVersion`, `eligible`, `reason`
  - `trial_started_v1` -> `schemaVersion`, `startEpochMs`
  - `trial_status_v1` -> `schemaVersion`, `active`, `remainingDays`, `eligible`, `reason`

- Proof tests and gates:
  - `test/services/placement_service_v1_test.dart`
  - `test/services/trial_service_v1_test.dart`
  - `./tools/fast_loop_world1_v1.sh`

- Deferred explicitly:
  - Real purchases or paywall SDK integration.
  - Multi-repair queues and deep personalization trees.
  - A/B framework beyond current telemetry-only instrumentation.
