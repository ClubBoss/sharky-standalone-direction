# Durable Repair Practice Queue Admission Decision v1

## 1. Verdict

durable_repair_practice_queue_admission_blocked_by_mapping_owner

## 2. Context Router Usage

- Router read: `docs/context/CONTEXT_ROUTER_v1.md`.
- Lane used: `durable_repair`.
- Token budget protocol read and followed.
- Capsule reads: current state and durable repair capsules.
- Latest durable artifacts read only:
  `durable_repair_concept_family_memory_v1.md`,
  `durable_repair_candidate_surface_admission_v1.md`, and
  `durable_repair_candidate_resolution_contract_v1.md`.
- Exact seam search was used before runtime file inspection.
- No W1-W6 ledgers/artifacts, W7-W12, screenshots, fixtures, output folders, or
  broad product docs were opened.

## 3. Files Inspected

- `lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart`
- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- Targeted snippets of `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- Focused tests for repair queue projection/consumer and repair intent contract.

## 4. Practice Ownership Matrix

| Candidate owner | Existing capability | Decision |
| --- | --- | --- |
| Practice repair queue projection | Accepts Review history and active repair intents. | Existing owner exists. |
| Practice repair queue consumer | Renders safe rows and exposes launchability from projection. | Display owner only. |
| Active repair intent | Owns target lesson/task mapping and launchable repair request. | Safe only for intents. |
| Session Summary | Owns safe recommendation copy from repair candidate. | Not a Practice route owner. |
| Review entry point | Has Practice CTAs for active repair/review flows. | Deferred; different owner. |

## 5. Candidate-To-Practice Mapping Decision

- The durable repair candidate contains concept family id, repair focus id,
  skill atom id, error type, counts, order, and reason code.
- It does not carry an owned target world, lesson, task, source task, next rep,
  or launch request.
- The existing launchable Practice queue path requires
  `Act0RepairIntentV1 -> Act0PracticeRepairQueueLaunchRequestV1`.
- Mapping a concept-family candidate into that path would require a new mapping
  owner or broad reuse/extraction of current runner-specific repair mapping.
- Decision: do not invent mapping in this wave.

## 6. Selected Owner Or Deferral

- Selected owner: none for implementation.
- Deferral reason: `mapping_owner_required`.
- The existing Practice repair queue remains the likely future owner, but only
  after a bounded mapper can convert an active repair candidate into a safe
  launch target without route drift.

## 7. Implementation Summary If Any

- No runtime implementation landed.
- No model, route, UI, persistence, telemetry, content, or fixture file changed.
- This wave creates only the decision artifact.

## 8. Copy Safety

- Existing safe copy remains: `Recommended repair: <safe label>.`
- Existing Practice copy remains owned by current queue/intent flows.
- No new `Practice this next`, `Perfect next step`, AI, GTO, solver, leak,
  guaranteed improvement, mastery, or personalization claim was added.

## 9. Route Safety

- No new route, navigation, screen, queue architecture, or Practice redesign was
  added.
- Existing Practice launch remains gated by `Act0PracticeRepairQueueLaunchRequestV1`
  from active repair intent ownership.

## 10. Tests

- No focused runtime tests were added because no runtime files were changed.
- Existing inspected tests show the Practice queue already tests launchable
  active repair rows, passive Review-history rows, copy safety, and no UI
  dependency in projection.

## 11. Validation

- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- ASCII, trailing whitespace, CRLF, and final-newline checks on this artifact

Flutter analyze and Flutter tests were not run because the wave is decision-only
and authored no Dart/source changes.

## 12. Score Impact

- No score movement.
- W1-W12 remains `8.3/10`.
- Overall top-1 remains unchanged by this decision-only blocker.

## 13. Deferred v2 Items

- Define a bounded candidate-to-practice mapping owner.
- Decide whether mapping should use active repair intent, learning evidence
  source task fields, or a separate repair target registry.
- Admit Practice queue integration only after a launch target can be produced
  without broad route changes.
- Keep Review/Profile/persistence expansion as separate decisions.

## 14. Token Budget Result

- Target: under 35k tokens.
- Result: stayed within target; no scope split required.

## 15. Next Recommendation

Run a mapper-owner decision wave for converting active concept-family repair
candidates into explicit `Act0PracticeRepairQueueLaunchRequestV1` targets, or
keep Session Summary as the only durable candidate surface until that owner is
defined.
