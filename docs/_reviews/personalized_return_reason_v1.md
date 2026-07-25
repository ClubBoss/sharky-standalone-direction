---
status: "personalized_return_reason_landed_with_bounded_consumer"
status_source: "derived"
baseline: "1f46377b55a7"
generated_by: "docs_frontmatter_v1"
---

# Personalized Return Reason v1

## 1. Verdict

`personalized_return_reason_landed_with_bounded_consumer`

## 2. Preflight

- Worktree:
  `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`.
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`.
- Starting HEAD: `1f46377b55a7010782fe478505da48393af10b1e`.
- Tracked and staged changes at preflight: none.
- Untracked at preflight: `output/**` only.
- `graphify hook-check`: exit 0.

## 3. Capsule/authority check

The active capsules were fresh to `f9a1909f`, while the task HEAD was
`1f46377b`. The prompt explicitly set `Phase 2 - Learning Truth Foundation`,
closed concept-family state, session identity, and learning transfer, and opened
Personalized Return Reason. Live source and committed artifacts confirm those
closed seams, so capsule freshness was treated as a non-blocking context note.

## 4. Return/re-entry ownership audit

- Day-2 return event owner: Act0 shell local `day2_return` telemetry helper.
- Home re-entry owner: `Act0HomeShellV1`, with existing
  `personalizedReturnReasonLine` and generic fallback copy.
- Session Summary "what next" source:
  `Act0SessionSummaryEvidenceViewModelV1` plus Practice repair queue consumer.
- Review/Practice repair focus source:
  `Act0ReviewMistakeHistoryV1`, `Act0RepairIntentV1`, and
  `Act0PracticeRepairQueueProjectionV1`.
- Existing last-session receipt:
  `Act0LastSessionLearnerStateV1` with `last_session_repair_focus_id`,
  `last_session_proof_result`, `last_session_date`, and
  `last_session_world_id`.
- Concept-family state reader: `Act0ConceptFamilyStateHistoryV1`.
- Transfer measurement reader: `Act0LearningTransferMeasurementV1`.
- Safe learner-facing slot found: existing Home daily-plan support line.

## 5. Return-reason contract

Added `Act0PersonalizedReturnReasonV1` with:

- `schemaVersion`
- `reasonType`
- `conceptFamilyId`
- optional `sourceTaskId`
- optional `sourceSessionId`
- `evidenceKind`
- `messageKey`
- `priorityClass`
- optional `rawEvidenceRef`

Copy is derived from `messageKey`; persisted state never owns display text.

## 6. Selection priority

1. active unresolved repair;
2. repair attempted but not yet succeeded;
3. recent transfer evidence with `improved_v1` or `held_v1`;
4. most recent valid concept-family focus;
5. no personal reason available.

Tie-breaks are deterministic by source order and concept-family id.

## 7. Claim-safety rules

The copy avoids mastery, AI/adaptive claims, percentages, weakness ranking,
guaranteed retention, score, level, XP, radar, and cross-family claims. Transfer
copy says the learner handled the clue better on a later hand, not that a skill
permanently improved.

## 8. Consumer admission decision

Path B was admitted for exactly one existing surface: the Home daily-plan
support line. The integration passes only a single string into the already
existing `personalizedReturnReasonLine` slot. No new screen, card, CTA, route,
or layout redesign was added.

## 9. Persistence boundary

No new recommendation state is persisted. The current reason is derived on read
from existing active repair intents, concept-family state, and learning transfer
measurement.

## 10. Telemetry boundary

No telemetry event or payload was added. Existing `day2_return` remains
unchanged and telemetry remains non-authoritative.

## 11. Fallback behavior

If no source-backed reason exists, `copyLine` is null and the existing Home
generic return copy remains visible.

## 12. Screenshot evidence if applicable

No screenshot evidence was required. The consumer change is a bounded existing
Home text slot with focused widget coverage and no visual redesign.

## 13. Tests/validation

- Red run failed on missing `Act0PersonalizedReturnReasonV1` API.
- Focused selector tests cover priority, transfer safety, fallback, determinism,
  no copy persistence, no UI parsing, and no ranking/telemetry owner.
- Focused Home consumer test covers the existing Home slot and route-neutral
  rendering.
- Additional focused owner tests were run for concept-family state, session
  identity, learning transfer, and repair behavior.

## 14. Scope safety

No new screen, route family, Review redesign, Home redesign, Session Summary
redesign, spaced repetition, notification system, server analytics, vendor SDK,
AI/adaptive language, mastery/rating/level/score/radar/XP, cross-family ranking,
W13+ work, dependency, or broad refactor was introduced.

## 15. Known limitations

The reason is local and deterministic. It does not schedule spaced repetition,
prove causal learning transfer, rank weakest skills, create a multi-repair
queue, or provide analytics cohorts.

## 16. Next recommendation

`Spaced Repetition Engine v1`
