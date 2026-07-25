---
status: "queue_resolution_contract_landed_with_bounded_coverage"
status_source: "derived"
baseline: "e8d60c616d27"
generated_by: "docs_frontmatter_v1"
---

# Queue Resolution Contract v1

## 1. Verdict

`queue_resolution_contract_landed_with_bounded_coverage`

This PR adds a deterministic Practice repair queue resolution contract and wires
it into the existing Practice queue projection as an admission filter. It does
not add a new screen, card, CTA, Review behavior, multi-repair queue,
spaced-repetition consumer, telemetry owner, or persistence store.

## 2. Preflight

- Worktree:
  `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `e8d60c616d277120ad50bba9938ef11db8f0abfb`
- Tracked/staged changes at preflight: none.
- Untracked at preflight: existing `output/**` folders only.
- `graphify hook-check`: passed.

## 3. Capsule/authority check

The route and learning capsules are fresh to `f9a1909f`, older than this
worktree HEAD. The active prompt explicitly moves the local sequence to
`Phase 3 - Repair Depth` and names Queue Resolution Contract as active. That
prompt plus live source outrank stale capsule next-task text, so this was a
non-blocking context note, not `stale_capsule_scope`.

## 4. Current queue ownership audit

- Repair intent contract: `Act0RepairIntentV1`.
- Repair outcome contract: `Act0RepairOutcomeProjectionV1` and
  `Act0RepairOutcomeV1`.
- Practice queue projection: `Act0PracticeRepairQueueProjectionV1`.
- Practice queue consumer: `Act0PracticeRepairQueueConsumerV1`.
- Queue launch request: `Act0PracticeRepairQueueLaunchRequestV1`.
- Queue item identity owner: active repair queue projection identity key.
- Successful repair write seam: `_appendPracticeQueueRepairOutcomeV1`.
- Unsuccessful repair write seam: same outcome append path with
  `isCorrect == false`.
- Persistence owner: existing `_Act0PersistedProgressV1` stores open repair
  intents and Review history; queue projection is derived.
- Review unresolved-history owner: `Act0ReviewMistakeHistoryV1`.
- Repair telemetry: existing local events such as `repair_attempted`,
  `repair_completed`, and `fix_landed`.

## 5. Queue item identity

Resolution uses the existing active queue item id:

`practice_repair_queue_v1|active|<len:sourceTaskId>|<len:repairFocusId>|<len:skillAtomId>|<len:errorType>`

The bounded composite identity applies to the exact active repair intent, not an
entire concept family. It is stable across rebuilds, compatible with the current
single active queue row, and future-safe for multi-repair because different
source/focus/skill/error tuples remain distinguishable.

## 6. Resolution contract

Added `Act0QueueResolutionStateV1` and `Act0QueueItemResolutionV1`.

Fields:

- `schemaVersion`
- `queueItemId`
- `repairIntentId`
- `conceptFamilyId`
- optional `sourceTaskId`
- optional `sourceSessionId`
- `resolutionState`
- `resolutionReason`
- optional `outcomeId`
- optional `resolvedAtOrder`

States:

- `unresolved`
- `attempted_not_resolved`
- `resolved`
- `not_actionable`
- `insufficient_evidence`

Reasons:

- `repair_succeeded`
- `repair_failed`
- `target_missing`
- `route_unavailable`
- `malformed_intent`
- `superseded`
- `no_outcome_yet`

Only the reasons supported by current live behavior are emitted today:
`repair_succeeded`, `repair_failed`, `target_missing`, and `no_outcome_yet`.

## 7. State transition rules

- Valid repair intent with no matching outcome: `unresolved`.
- Repair launch without completed outcome: remains `unresolved`.
- Completed unsuccessful matching repair: `attempted_not_resolved`.
- Completed successful matching repair: `resolved`.
- Missing target fields: `not_actionable`.
- Malformed parsed intent: fails closed before resolution.
- Unrelated repair outcome: does not resolve the item.
- Repeated successful outcomes: one resolved record, earliest success order.
- Repeated failed outcomes: one actionable record, latest failed attempt order.
- Rendering/repeated derivation: no mutation.

## 8. Queue inclusion policy

- `unresolved`: included.
- `attempted_not_resolved`: included.
- `resolved`: excluded.
- `not_actionable`: excluded.
- `insufficient_evidence`: excluded.

Generic Practice fallback remains unchanged when no actionable queue row remains.

## 9. Persistence/derivation boundary

Resolution is derived from active repair intents plus repair outcomes. No new
queue store was added. Current persisted progress already avoids resolved row
resurrection when successful repair clears the open repair intent. Repair outcome
history itself is not persisted in this PR; adding such a receipt store remains
deferred until a source-owned need appears.

## 10. Practice integration

Integration is limited to `Act0PracticeRepairQueueProjectionV1.fromSources`.
The projection now derives or accepts a queue resolution state and filters active
repair rows to actionable states only.

The launch request contract remains unchanged.

## 11. Review boundary

Review currently has separate unresolved-only logic in
`Act0ReviewMistakeHistoryV1`. This PR does not switch Review consumers or
resolve Review history. Review Resolution Contract v1 will likely need:

- `queueItemId` or a compatible bounded repair identity;
- `sourceTaskId`;
- `conceptFamilyId`;
- outcome id/order;
- resolution state/reason;
- policy for whether a Review record can become recovered, archived, or remain
  unresolved after failed repair.

Owner conflict to solve next: Review records are source-decision based, while
active queue resolution is active-intent based.

## 12. Telemetry boundary

No new telemetry event or payload field was added. Existing repair telemetry
remains observational and non-authoritative; product state is derived from local
source contracts.

## 13. Backward compatibility

The new resolution parser skips unknown schema versions and malformed entries.
Existing Practice launch request payloads remain stable. Existing Review history
and repair outcome contracts remain parse-compatible.

## 14. Tests/validation

Focused tests cover:

- unresolved intent;
- successful matching outcome;
- failed matching outcome;
- unrelated outcome;
- idempotent repeated success;
- repeated failed attempts;
- malformed intent parser fail-closed behavior;
- targetless intent fail-closed behavior;
- old/malformed optional resolution state;
- render/rebuild derivation stability;
- launch request stability;
- resolved row exclusion;
- failed row inclusion.

## 15. Scope safety

No UI surface, Practice card, CTA, Home behavior, Review behavior, route, content
pack, multi-repair queue, spaced-repetition consumer, telemetry owner, server
analytics, AI/adaptive claim, mastery/rating/XP/level/radar/percentage claim,
dependency, broad refactor, or Modern Table visual change was added.

## 16. Known limitations

- Repair outcome history is not persisted as a standalone queue-resolution
  receipt.
- Review unresolved history is not switched to this contract yet.
- Multi-repair ordering and multi-item display remain out of scope.
- `route_unavailable` and `superseded` are reserved but not emitted by current
  live behavior.

## 17. Next recommendation

`Review Resolution Contract v1`
