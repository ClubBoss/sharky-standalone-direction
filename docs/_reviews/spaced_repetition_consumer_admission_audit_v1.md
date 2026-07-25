---
status: "spaced_repetition_consumer_deferred_engine_ready"
status_source: "derived"
baseline: "115e1bc7830d"
generated_by: "docs_frontmatter_v1"
---

# Spaced Repetition Consumer Admission Audit v1

## 1. Verdict

`spaced_repetition_consumer_deferred_engine_ready`

The spaced-repetition engine is deterministic and source-backed, but its current
`nextDueFamily` output cannot safely enter Practice without a new adapter policy
that reconstructs a concrete repair target from a concept family. The existing
Practice launch path is already narrow and route-locked, but it accepts launch
requests or full concept repair candidates, not schedule records.

No product code integration was admitted.

## 2. Preflight

- Worktree:
  `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- HEAD: `115e1bc7830df854260420f9e1536f85a4ad29f5`
- Dirty scope at preflight: no tracked or staged changes.
- Untracked scope at preflight: existing `output/**` folders only.
- `graphify hook-check`: passed.

## 3. Capsule/authority check

`ACTIVE_ROUTE_CAPSULE_v1` and `LEARNING_REPAIR_CAPSULE_v1` are fresh to
`f9a1909f`, older than the current HEAD. The active prompt and live committed
artifacts explicitly advance Phase 2 through Personalized Return Reason and
Spaced Repetition Engine. The stale capsule facts are not route-critical for
this admission audit, so live source, tests, and current artifacts were used as
higher authority.

## 4. Current Practice admission ownership

- Practice entry owner:
  `Act0ShellPreviewScreenV1`, Play tab construction.
- Practice repair target contract:
  `Act0PracticeRepairQueueLaunchRequestV1`.
- Active repair intent owner:
  `Act0RepairIntentV1` plus `buildAct0RepairIntentV1`.
- Repair focus identifiers:
  active repair intent fields `missedSignalId`, `skillAtomId`, `errorType`,
  and source task id; review history fields `repairFocusId`, `skillAtomId`,
  `errorType`, and source task id.
- Route/pack mapper:
  `act0FirstValueSameSignalRepMappingV1` for same-signal repair targets.
- Practice queue projection:
  `Act0PracticeRepairQueueProjectionV1.fromSources`.
- Practice queue consumer:
  `Act0PracticeRepairQueueConsumerV1.fromProjection`.
- Existing concept candidate mapper:
  `mapAct0ConceptCandidateToPracticeLaunchRequestV1`.
- Fallback when no repair target exists:
  empty/passive queue row or no queue row; existing Practice group fallback
  remains unchanged.

The current Practice target can be selected without UI mutation only when an
existing launch request is already available. The current route admission is
source-owned by active repair intent and allowlisted candidate specs, not
learner-facing copy.

## 5. Input/output contract mismatch

Practice input:

- `Act0PracticeRepairQueueLaunchRequestV1`
- required target ids: world, lesson, task;
- required source fields: source task, repair task, repair focus key, queue item
  id;
- target type must be `active_repair_target_v1`;
- source type must be `active_repair_v1`.

Existing candidate mapper input:

- `Act0ConceptFamilyRepairCandidateV1`
- required tuple: `conceptFamilyId`, `repairFocusId`, `skillAtomId`,
  `errorType`, counts, latest miss order, selection reason.

Spaced-repetition output:

- `Act0SpacedRepetitionFamilyScheduleV1`
- current target field: `conceptFamilyId`;
- schedule fields: state, due reason, evidence session/order, due-after session,
  optional source task/evidence ref.

Mismatch:

`nextDueFamily` does not carry `repairFocusId`, `skillAtomId`, `errorType`, or a
validated concrete world/lesson/task target. Mapping from concept family alone
would be inference unless a separate source-backed candidate join is admitted.

## 6. Mapping coverage matrix

| conceptFamilyId | source evidence | existing repair focus / skill atom mapping | concrete Practice target | route/pack availability | current world coverage | admission verdict | unsupported reason |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `no_bet_yet` | active repair intent and default concept-candidate allowlist | `no_bet_yet` / `action_read` / `missed_action_read` when a full candidate exists | `world_1` / `fold_check_call_raise` / `actions_check_drill` | allowlisted and launchable | W1 | `safe_with_existing_fallback` | safe only when full candidate or active repair intent is present; schedule family alone is insufficient |
| `actions_legal_context` / source task evidence | active repair source task | no concept-family mapping by source task alone | none from schedule output | not applicable | W1 | `unsupported` | source task id is not a concept-family target contract |
| encoded repair focus key from repair outcome | repair outcome `repairFocusKey` can be encoded queue key | no allowlisted concept-family candidate | none from schedule output | not applicable | W1 | `ambiguous` | encoded queue key is not a stable concept-family id for Practice admission |
| transfer-only concept family | learning transfer signal | no guaranteed repair focus / skill atom / error tuple in schedule | none from schedule output | not applicable | W1-W6 only if separately mapped | `blocked_missing_target` | transfer schedule lacks a concrete route target |
| W7+ concept families seen in dormant owners | dormant/non-route source owners | route-locked outside active admission | none | blocked | W7+ | `blocked_route_contract` | W13+ and route expansion remain forbidden; W7+ is not admitted by this prompt |

Do not expand this matrix beyond currently evidenced active families without a
separate source-contract wave.

## 7. Priority policy

Required order:

1. active unresolved repair;
2. active failed repair;
3. spaced-repetition due family;
4. existing generic Practice fallback.

Current authoritative order:

1. active repair intent rows are projected first;
2. unresolved Review history rows follow and remain passive;
3. generic Practice groups remain outside the repair queue fallback.

Adding scheduled due families would introduce a new queue candidate class between
active repair and generic Practice. That is plausible, but it is not already an
implemented authoritative order. It should not be silently added in an audit PR.

Active repair must always outrank scheduled reinforcement.

## 8. Admission safety evaluation

| Rule | Result | Notes |
| --- | --- | --- |
| `nextDueFamily` is source-backed | pass | Schedule is derived from active repair, concept-family state, and transfer signals. |
| deterministic family-to-target mapping exists | fail | Existing mapper needs a full candidate tuple, not family id only. |
| mapping resolves to an already registered active target | partial | `no_bet_yet` resolves only when candidate tuple is available. |
| no new route or content pack required | pass for W1 `no_bet_yet`; fail for broader families | Current allowlist is intentionally narrow. |
| active unresolved repair retains higher priority | pass in current queue | Any schedule integration would need to preserve this. |
| current fallback remains unchanged | pass if audit-only | Integration would need explicit tests. |
| unsupported families fail closed | pass in existing mapper | Schedule-to-candidate adapter does not yet exist. |
| no UI rendering owns target selection | pass currently | Projection owns queue derivation; shell launches requests. |
| no telemetry owns target selection | pass | Telemetry is not the owner. |
| same input produces same target | pass in existing mapper | Only for full candidates. |
| route-lock rules remain intact | pass currently | W7+ and W13+ remain blocked. |

Safety gate result: not all conditions pass.

## 9. Chosen path

Path A - Audit only.

Reason:

- no safe schedule-family-only adapter exists;
- mapping coverage is incomplete;
- Practice queue precedence would change if a scheduled row were inserted;
- transfer-only due families lack concrete repair target ownership;
- unsupported and route-locked families must fail closed.

## 10. Adapter implementation if any

None.

No adapter, resolver, route owner, UI owner, persistence owner, telemetry owner,
or test was added.

## 11. Fallback behavior

Audit-only preserves fallback behavior:

- active repair rows remain first and launchable when target metadata exists;
- review-history rows remain passive;
- no safe repair queue means no repair queue rows;
- generic Practice groups remain the user-visible fallback.

Unsupported scheduled families continue to have no Practice consumer.

## 12. Route-lock proof

- Existing concept-candidate mapper allowlists W1-W6 targets only.
- Default allowlist currently contains one W1 mapping:
  `no_bet_yet -> actions_check_drill`.
- W7+ concept owners exist in source but are not admitted by this prompt.
- No W13+ route, content, pack, or taxonomy work was readmitted.
- No Modern Table or route hierarchy file was modified.

## 13. Tests/validation

Required validation for this audit:

- focused spaced repetition tests;
- focused repair intent / target tests;
- focused route mapper tests;
- focused Practice route tests;
- `flutter analyze`;
- `graphify hook-check`;
- `git diff --check`;
- `git diff --cached --check`;
- `git status --short --branch`.

## 14. Scope safety

This artifact makes no product-code changes. It does not add a screen, card,
CTA, Practice redesign, Review redesign, Home redesign, route family, content
pack, multi-repair queue, notification logic, server analytics, AI/adaptive
claim, mastery score, broad refactor, dependency, or Modern Table change.

## 15. Deferred coverage

Deferred work needed before consumer admission:

- define a source-owned schedule-to-candidate join contract;
- decide whether cleared/successful repair summaries may still provide a
  launchable candidate tuple;
- define how transfer-only families map to repair focus and target tasks;
- keep unsupported families null/no-target;
- preserve active repair priority;
- prove no new visible queue semantics imply fixed/cleared/resolved state.

## 16. Phase 2 closure decision

`close_learning_truth_foundation`

All five Phase 2 engines/contracts are landed, and consumer admission is
explicitly rejected with an engine-ready/deferred-consumer boundary. The hidden
dependency moves out of Learning Truth Foundation and into a follow-up mapping
contract.

## 17. Next recommendation

`Concept Family to Practice Target Mapping Follow-up`
