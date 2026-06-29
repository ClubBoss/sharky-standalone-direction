# Durable Repair Concept Candidate Practice Mapper Owner v1

## 1. Verdict

durable_repair_concept_candidate_mapper_landed_partial_allowlist

## 2. Context Router Usage

- Router read: `docs/context/CONTEXT_ROUTER_v1.md`.
- Lane used: `durable_repair`.
- Token budget protocol read and followed.
- Capsules read: current state and durable repair.
- Latest durable artifacts read only: concept-family memory, candidate surface
  admission, candidate resolution contract, and Practice queue admission
  decision.
- Exact seams searched before code reads.
- No W1-W6 ledgers/artifacts, W7-W12, fixtures, screenshots, output folders, or
  broad product docs were opened.

## 3. Files Inspected

- `lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart`
- `lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- Targeted `act0_shell_preview_screen_v1.dart` same-signal mapper lines only
- Focused repair queue, repair intent, and mapper tests

## 4. Practice Launch Contract Found

- Existing launch type: `Act0PracticeRepairQueueLaunchRequestV1`.
- Launchable requests require active repair target type, active repair source
  type, target world/lesson/task, source task, repair task, focus key, and queue
  item id.
- Existing Practice shell launch remains outside this wave.

## 5. Mapping Owner Decision

- Added pure mapper owner:
  `act0_concept_candidate_practice_mapper_v1.dart`.
- It converts an active concept-family repair candidate to an existing Practice
  launch request only when an allowlist entry is exact and safe.
- It does not mutate queue state or create UI.

## 6. Mapping Policy

- Exact ids only: concept family, repair focus, skill atom, and error type.
- No label inference.
- No new tasks, fixtures, routes, screens, telemetry, or persistence.
- Ties resolve deterministically by allowlist mapping id.

## 7. Allowlist Or No-Target Behavior

- Landed partial allowlist:
  `no_bet_yet/action_read/missed_action_read`.
- Target: `world_1/fold_check_call_raise/actions_check_drill`.
- Source owner: existing `actions_legal_context` same-signal repair mapping.
- Unknown concepts return `no_target_unknown_concept_id_v1`.
- Unsafe missing launch owner returns
  `no_target_unsafe_missing_launch_owner_v1`.

## 8. Route-Lock / Bridge-Limited Handling

- Targets outside W1-W6 return `no_target_route_locked_v1`.
- Bridge-limited allowlist specs return `no_target_bridge_limited_v1`.
- W7-W12 targets are not admitted.

## 9. Implementation Summary If Any

- Added mapper source file.
- Added focused mapper tests.
- Updated current and durable capsules with compact status lines.
- No Practice UI CTA, Session Summary CTA, Review/Profile admission, route, or
  queue redesign landed.

## 10. Tests

- Mapped allowlisted candidate to launch request.
- Unknown concept no-target.
- Route-locked target no-target.
- Bridge-limited target no-target.
- Unsafe missing launch owner no-target.
- Deterministic duplicate-spec tie behavior.
- Source dependency guard: no UI, route, telemetry, or content dependency.

## 11. Validation

- Focused mapper test.
- Repair queue projection/consumer and repair intent focused tests.
- `dart format`.
- `flutter analyze`.
- `git diff --check`.
- `git diff --cached --check`.
- `graphify hook-check`.
- ASCII, trailing whitespace, CRLF, and final-newline checks.

## 12. Score Impact

- W1-W12 remains `8.3/10`.
- No Human QA, launch, 9.0, monetization, or learning-effect claim becomes safe.
- Overall top-1 may move +0.1 max as architecture readiness only.

## 13. Deferred v2 Items

- Practice UI/CTA admission.
- Queue admission/wiring from candidate mapper output.
- Additional allowlist entries after source ownership is explicit.
- Review/Profile and durable persistence decisions.

## 14. Token Budget Result

- Target: under 35k tokens.
- Result: stayed within target; no scope split required.

## 15. Next Recommendation

Run a bounded Practice queue admission implementation wave that consumes this
mapper output without adding routes, screens, telemetry, or persistence.
