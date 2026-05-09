# Audit Packet v1 Core Consensus

- Purpose: compact review packet for external consensus on current v1 repo state.
- Scope snapshot: DoR 1.0, M2, M3, and M4 baseline shipped surfaces.

## A) SSOT pointers
- Master plan: `docs/plan/MASTER_PLAN_v2.2.md` (includes M4 Placement + Trial section).
- DoR audit: `docs/audit/M1_READINESS_AUDIT_v4.md`.
- DoR ready line: `Definition of Ready 1.0: READY (all items 1..8 COMPLETE).`
- M2 closeouts:
  - `docs/worlds/m2_worlds_5_to_9_done_v1.md`
  - `docs/reference/milestones/m2_mastery_skeleton_done_v1.md`
- M3 closeout:
  - `docs/reference/milestones/m3_emotion_layer_done_v1.md`
- M4 closeout:
  - `docs/reference/milestones/m4_placement_trial_done_v1.md`

## B) What shipped (high level)
- Content platform: Worlds 0..9 v1 content present and covered by deterministic content checkpoint/audit gates.
- Placement baseline:
  - `PlacementResultV1` scoring/output.
  - deterministic routing with max-1 repair session (`repairSessionId` nullable).
  - placement telemetry: start/end/route selected.
- Trial baseline:
  - `TrialEntitlementV1` 7-day deterministic entitlement model.
  - deterministic eligibility reasons and start-once behavior.
  - trial telemetry: offer shown, started, status.
- Emotion layer:
  - curated emotion phrase layer is present and surfaced through existing flow points.
  - emotion telemetry contracts are emitted and test-locked.

## C) Determinism and contracts
- Key proof tests:
  - `test/services/endless_perception_proof_v1_test.dart`
  - `test/services/content_platform_boundary_proof_v1_test.dart`
  - `test/guards/world1_core_loop_telemetry_contract_test.dart`
  - `test/services/placement_service_v1_test.dart`
  - `test/services/trial_service_v1_test.dart`
- Key gates/commands:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `./tools/checkpoint_world1_contracts_v1.sh`
  - `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 9`
  - `dart run tools/audit_why_v1_coverage_v1.dart --world-min 1 --world-max 9`
  - `dart run tools/compile_daily_schedule_v1.dart --check`

## C.1) Post-audit fixes applied
- Trial hardening and SSOT path:
  - `lib/services/trial_service_v1.dart` now stores monotonic last-seen key `trial_last_seen_epoch_ms_v1`.
  - Clock rollback is locked with deterministic reason `clock_rollback`.
  - Legacy trial path is disabled in `lib/services/adaptive_premium_triggers.dart` with explicit SSOT note to `TrialServiceV1`.
  - `SubscriptionStatusV1` source semantics are aligned: no entitlement resolves to `SubscriptionSourceV1.none` in `lib/services/subscription_status_v1.dart`.
- Placement weak-area alignment:
  - Canonical tokens are `positions`, `hand_selection`, `table_basics`, `none` in `lib/services/placement_service_v1.dart`.
  - Accepted legacy synonyms for routing safety: `seat_order` -> `positions`, `rules_table_basics` -> `table_basics`.
- Gift drop determinism:
  - `lib/services/gift_drop_service.dart` no longer uses runtime RNG.
  - Amount is deterministic per install seed and UTC day key (`gift_drop_install_seed_v1` + day-index mix).
- Proof tests updated/added:
  - `test/services/trial_service_v1_test.dart`
  - `test/services/subscription_status_v1_test.dart`
  - `test/services/placement_service_v1_test.dart`
  - `test/services/gift_drop_service_test.dart`

## C.2) Post-cohesion and post-visual fixes applied
- M5 closeout:
  - `docs/ux/m5_cohesion_pass_done_v1.md`
  - Unified layout hierarchy and CTA rhythm plus typography/spacing normalization across map/intake/runner/result.
- Runner audit fixes:
  - Correctness and determinism hardening for incorrect-path availability, street progression boundaries, action-set invariants, seat highlight determinism, and why visibility.
  - Contract surface: `test/guards/world1_core_loop_telemetry_contract_test.dart`.
- Map cohesion and hygiene:
  - Dual sequence render issue removed; canonical inline path retained.
  - Unavailable placeholders hidden and internal slot IDs are not surfaced in user-visible map text.
  - Contract surface: `test/guards/world_campaign_map_home_contract_test.dart`.
- M6 closeout:
  - `docs/ux/m6_visual_perfection_done_v1.md`
  - Token unification outcomes and proof-command set are captured there (format/analyze/map contract/fast loop).

## D) Explicit non-goals and deferred scope
- Real payments or paywall SDK integration.
- Deep personalization trees (beyond v1 deterministic route mapping).
- Heavy visual polish or redesign-focused UX work.

## E) Questions for reviewers
- Does M4 placement plus trial preserve UX clarity and perceived value without drift?
- Are any deterministic invariants still missing or weakly locked?
- Are service facades cohesive, or do they show fragmentation risk?
- Is telemetry payload shape stable enough for downstream consumers?
- Any obvious privacy concerns in event payload contents or timing?
- Any high-risk coupling between intake, placement routing, and trial status?

## F) How to review quickly
- First open these closeouts:
  - `docs/ux/m5_cohesion_pass_done_v1.md`
  - `docs/ux/m6_visual_perfection_done_v1.md`
- Run these commands:
  - `dart format --set-exit-if-changed .`
  - `flutter analyze`
  - `flutter test test/guards/world_campaign_map_home_contract_test.dart`
  - `./tools/fast_loop_world1_v1.sh`
  - `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 9`
  - `dart run tools/audit_why_v1_coverage_v1.dart --world-min 1 --world-max 9`
- Read these 5 files first:
  - `docs/plan/MASTER_PLAN_v2.2.md`
  - `docs/audit/M1_READINESS_AUDIT_v4.md`
  - `docs/reference/milestones/m2_mastery_skeleton_done_v1.md`
  - `docs/reference/milestones/m3_emotion_layer_done_v1.md`
  - `docs/reference/milestones/m4_placement_trial_done_v1.md`
