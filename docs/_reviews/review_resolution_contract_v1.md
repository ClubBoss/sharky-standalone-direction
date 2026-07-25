---
status: "review_resolution_contract_landed_with_bounded_coverage"
status_source: "derived"
baseline: "3696adbb1f8c"
generated_by: "docs_frontmatter_v1"
---

# Review Resolution Contract v1

## 1. Verdict

`review_resolution_contract_landed_with_bounded_coverage`

This PR adds a deterministic Review resolution contract, filters resolved
Review history through the existing Review history consumer, and persists a
minimal exact resolution receipt so a successfully repaired Review row does not
reappear as active unresolved history after reload.

It does not redesign Review, add a card or CTA, introduce multi-repair queue
behavior, add pattern coaching, change telemetry ownership, create server
analytics, or change Practice visuals.

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Expected HEAD at start: `3696adbb1f8cc8f055c0ec61c843bb5ef8f6cf1d`
- Tracked/staged state at start: clean.
- Untracked state at start: existing `output/**` only.
- `graphify hook-check`: clean.

## 3. Capsule/authority check

The route capsules were older than the task HEAD and still named an earlier
visual next task. The active prompt explicitly advanced Phase 3 Repair Depth to
Review Resolution Contract v1 after Queue Resolution Contract closure. The stale
capsule facts were not route-blocking for this bounded source/test contract, so
live source, tests, and the prompt contract were used as authority.

## 4. Current Review ownership audit

- Review screen owner: `Act0ReviewShellV1`.
- Review mistake-history owner: `Act0ReviewMistakeHistoryV1`.
- Review read model owner: `Act0ReviewMistakeHistoryConsumerV1`.
- Current unresolved-history state: `unresolved_only_v1`.
- Current Review item source: completed incorrect decisions appended through
  `_appendLearningEvidenceV1`.
- Current Review item identity: `review_mistake_v1|sourceTask|repairFocus|skillAtom|errorType`.
- Current relationship to active repair intents: Review consumer filtered rows
  by active repair source task only.
- Current relationship to repair outcomes before this PR: none.
- Current Practice launch callback from Review: existing Review repair CTA and
  Practice queue launch paths are unchanged.
- Current persistence owner: `_Act0PersistedProgressV1` stores
  `reviewMistakeHistory` and `openRepairIntents`.
- Current telemetry events: existing local repair events such as
  `repair_attempted`, `repair_completed`, and `fix_landed`; telemetry remains
  observational.
- Existing passive/history distinction: Review shell can show history notes, but
  it does not have a safe separate recovered-history mode for exact resolved
  rows.

## 5. Review item identity

Review resolution applies to an exact evidence-backed Review record:

`review_mistake_v1|sourceTaskId|repairFocusId|skillAtomId|errorType`

This is source-backed, stable across reload, compatible with existing Review
history rows, and linkable to Practice queue identity when the active repair
intent uses the same bounded composite:

`sourceTaskId|missedSignalId|skillAtomId|errorType`

A later success in the same family does not resolve a different exact Review
row unless the exact composite identity matches.

## 6. Resolution contract

New owner:

- `Act0ReviewResolutionStateV1`
- `Act0ReviewItemResolutionV1`
- `Act0ReviewResolutionReceiptHistoryV1`
- `Act0ReviewResolutionReceiptV1`

Fields include:

- `schemaVersion`
- `reviewItemId`
- optional `learningEvidenceId`
- optional `repairIntentId`
- `conceptFamilyId`
- optional `sourceTaskId`
- optional `sourceSessionId`
- `reviewState`
- `resolutionReason`
- optional `repairOutcomeId`
- optional `resolvedAtOrder`

States:

- `unresolved`
- `repair_attempted_not_resolved`
- `resolved`
- `historical`
- `not_actionable`
- `insufficient_evidence`

Reasons:

- `no_repair_outcome`
- `repair_failed`
- `repair_succeeded`
- `no_matching_repair`
- `target_missing`
- `malformed_evidence`
- `historical_only`

## 7. Transition rules

- Valid Review mistake with no matching successful repair:
  `unresolved`.
- Matching failed repair:
  `repair_attempted_not_resolved`.
- Matching successful repair for the same bounded identity:
  `resolved`.
- Unrelated repair success:
  does not resolve the Review item.
- Same-family but different exact identity:
  does not resolve the Review item.
- Fallback/malformed evidence:
  `insufficient_evidence` and excluded from active Review.
- Missing active repair target:
  `not_actionable` and excluded from active Review.
- Repeated successful outcomes:
  idempotent, earliest success order wins.
- Rendering:
  does not mutate resolution.

## 8. Inclusion policy

Policy A - unresolved-only active Review.

- `unresolved`: visible.
- `repair_attempted_not_resolved`: visible.
- `resolved`: excluded.
- `not_actionable`: excluded.
- `insufficient_evidence`: excluded.
- `historical`: excluded unless a future Review history mode explicitly opens
  that UI.

Policy B was rejected for this PR because the current Review UI does not safely
distinguish exact recovered history from active unresolved truth without adding a
new visual mode.

## 9. Shared truth with Practice queue

Review resolution reuses the Practice queue identity helpers and outcome
matching semantics where the active repair intent matches the exact Review
identity. Practice queue remains authoritative for actionable repairs.

Intentional difference:

- Practice queue identity is active-intent oriented.
- Review identity is evidence-record oriented.
- The adapter links them only when the bounded composite identity matches.

## 10. Persistence/derivation decision

Derivation alone was insufficient.

Reason: successful repair clears the open repair intent, but the Review mistake
history is persisted. Without a minimal receipt, a reload could show the old
Review row as unresolved again while Practice no longer has an active queue row.

This PR adds one exact source-linked persisted receipt list in the existing
progress snapshot:

`reviewResolutionReceipts`

The receipt stores only source IDs and resolution metadata. It does not copy
display text and does not create a broad repair outcome history subsystem.

## 11. Review projection integration

`Act0ReviewMistakeHistoryConsumerV1.fromHistory` now accepts an optional
`reviewResolutionState`. Resolved, not-actionable, and insufficient-evidence
rows are filtered before building existing history item view models.

No Review layout, copy, CTA, or callback shape changed.

## 12. Practice boundary

Practice queue resolution remains in `Act0QueueResolutionStateV1` and
`Act0PracticeRepairQueueProjectionV1`.

Review does not create repair intents during rendering. Existing Review launch
callbacks remain unchanged. Successful matching repair now gives both Practice
and Review the same resolved truth for the matching identity.

No multi-item queue behavior is added.

## 13. Telemetry boundary

No new telemetry event or sink was added. Existing local repair telemetry remains
observational and does not own Review state.

## 14. Screenshot evidence if applicable

No screenshot packet was required. The learner-visible change is only filtering
existing Review history rows according to a source-backed contract, with no new
layout or copy.

## 15. Backward compatibility

- Existing Review history records remain parse-compatible.
- Existing v1-v14 persisted progress snapshots parse with an empty receipt
  history if `reviewResolutionReceipts` is absent.
- Malformed old receipt rows are skipped.
- Existing Practice queue and launch request payloads remain stable.

## 16. Tests/validation

Focused tests cover:

- valid mistake unresolved;
- failed repair remains visible/actionable;
- successful repair resolves and is excluded;
- unrelated success does not resolve;
- same-family different identity does not over-resolve;
- repeated success idempotence;
- malformed/missing target fail-closed;
- persisted receipt prevents reload resurrection;
- old receipt state loads safely;
- rendering derivation does not mutate;
- Review and Practice agreement for matching identity;
- existing Review history projection behavior;
- persisted shell receipt consumption.

## 17. Scope safety

No new screen, Review card type, CTA, route, Home redesign, Practice redesign,
multi-repair queue, spaced-repetition consumer mapping, W13+ work, content pack,
mastery/score/XP/rating/level/radar/percentage claim, AI/adaptive claim, server
analytics, dependency, broad refactor, or Modern Table visual change was added.

## 18. Known limitations

- This is not a broad repair outcome history subsystem.
- Review recovered-history presentation remains deferred.
- Multi-Repair Queue v1 remains separate.
- Review Multi-Session Pattern Coaching remains separate.

## 19. Next recommendation

`Multi-Repair Queue v1`
