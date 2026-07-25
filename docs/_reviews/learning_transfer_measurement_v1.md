---
status: "learning_transfer_measurement_landed_engine_only"
status_source: "derived"
generated_by: "docs_frontmatter_v1"
---

# Learning Transfer Measurement v1

## 1. Verdict

`learning_transfer_measurement_landed_engine_only`

## 2. Evidence sources used

- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
- `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/TOP1_LONG_HORIZON_100_PERCENT_ROUTE_v1.md`
- `docs/_reviews/concept_family_state_foundation_v1.md`
- `docs/_reviews/deterministic_session_identity_v1.md`
- `docs/_reviews/durable_repair_learning_transfer_measurement_v1.md`

## 3. Transfer contract

Added `Act0LearningTransferMeasurementV1`, a pure local projection from
`Act0LearningEvidenceHistoryV1`.

It produces per-concept `Act0LearningTransferSignalV1` records with:

- `conceptFamilyId`
- `relationship`
- `verdict`
- baseline and comparison orders
- baseline and comparison task ids
- baseline and comparison session ids
- baseline and comparison decision-time buckets

No UI, route, telemetry, persistence, or learner-facing copy was added.

## 4. Eligibility rules

Positive transfer eligibility requires:

- same normalized concept family;
- ordered local evidence;
- a later comparison record;
- different non-empty task ids;
- different non-empty session ids.

Exact task repeat is classified as `same_task_repeat_v1` and is not promoted to
transfer. Same-session evidence, missing session linkage, missing task linkage,
negative ordering, and tied ordering stay `insufficient_evidence_v1`.

## 5. Baseline and comparison strategy

The baseline is the earliest valid local evidence record for the concept family.
The comparison is the latest later eligible local evidence record for the same
concept family. This keeps the derivation deterministic and avoids maintaining a
parallel transfer store.

## 6. Verdict logic

- miss then later correct on a different same-family task:
  `improved_v1`
- correct then later correct on a different same-family task:
  `held_v1`
- later same-family transfer remains incorrect:
  `not_yet_improved_v1`
- any ineligible relationship:
  `insufficient_evidence_v1`

Decision-time buckets are carried as evidence fields only. Speed changes alone
do not create improvement.

## 7. Persistence and derivation owner

Persistence remains owned by `Act0LearningEvidenceHistoryV1`. Transfer
measurement is derived on read from the existing local evidence history. No
schema migration or storage key was introduced.

## 8. Telemetry impact

No telemetry event was added or modified. The projection does not emit, enrich,
or depend on telemetry.

## 9. Scope proof

Touched scope is limited to:

- engine-only projection source;
- focused projection contract tests;
- this review artifact.

No UI, copy, route, server analytics, vendor SDK, AI/adaptive claim, hidden
rating, XP/levels/radar/mastery, cross-family inference, W13+, or broad refactor
was introduced.

## 10. Known limitations

This is local evidence measurement only. It does not prove causal practice
transfer, create personalized return reasons, schedule spaced repetition, build
a multi-repair queue, or support public learning-effect claims.

## 11. Next recommendation

Run a bounded consumer/admission decision only after the product owner decides
where, if anywhere, this internal signal should be displayed without overstating
learning effect.
