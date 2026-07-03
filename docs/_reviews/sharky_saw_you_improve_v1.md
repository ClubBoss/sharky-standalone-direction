# Sharky Saw You Improve v1

## 1. Verdict

`sharky_saw_you_improve_landed_with_bounded_consumer`

Sharky now has a source-backed later-improvement observation derived from reinforced Fix Proof and admitted into one existing consumer: Session Summary's fix receipt.

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `a3059775 feat: add Foundation and Developing Sharky phrases`
- Tracked worktree was clean before implementation.
- Pre-existing untracked `output/**` artifacts were ignored and remain local-only.
- `graphify hook-check` passed during preflight.

## 3. Capsule / Authority Check

Read and followed:

- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
- `docs/context/VISUAL_PROOF_CAPSULE_v1.md`
- `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`
- `docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md`
- `docs/_reviews/sharky_phrase_tier_contract_v1.md`
- `docs/_reviews/foundation_developing_phrase_sets_v1.md`
- prior proof artifacts for Fix Proof, Cross-Session Proof Profile, and Review pattern coaching

The active lane was Phase 5 - Sharky Companion. The implementation stayed inside Act0 proof, phrase, and Session Summary seams.

## 4. Existing Improvement-Evidence Audit

The source evidence already existed in local proof projections:

- `Act0LearningTransferMeasurementV1` identifies same-family later improvement only when a prior baseline miss is followed by a later correct comparison on a different task and different session.
- `Act0FixProofProjectionV1` upgrades completed repair proof to reinforced proof only after matching same-family improved transfer evidence.
- Review pattern coaching already has its own conservative improvement pattern consumer, but this task intentionally did not reuse Review as the selected product consumer.

## 5. Observation Contract

Added `Act0SharkyImprovementObservationProjectionV1` as a pure read-only projection over `Act0FixProofProjectionV1`.

The observation stores:

- stable observation id
- concept family id
- source repair id and session id
- later evidence task/session/order
- observation state
- phrase context
- raw source references

No persistence owner, queue state, telemetry, score, rank, animation, route, or asset was introduced.

## 6. Eligibility Rules

An observation is eligible only when all of these are true:

- Fix Proof state is `reinforced_by_later_evidence_v1`.
- Transfer verdict is `improved_v1`.
- Source repair id/reference, concept family, source session, later session, later task, and later order are present.
- Later order is strictly after the banked repair order.
- Later session differs from repair session.
- Later task differs from source task.
- Optional completed-session filter matches the later evidence session.

Malformed, same-task, same-session, unrelated-family, failed-repair, stale-order, and missing-reference cases fail closed.

## 7. Relationship To Reinforced Proof

The observation does not independently prove learning. It presents a Sharky companion line only after reinforced Fix Proof already established the source-backed evidence chain:

`Review resolved repair + successful repair outcome + same-family later improved transfer -> reinforced Fix Proof -> Sharky observation`

`Act0FixProofItemV1` now carries `laterEvidenceOrder` so the observation can verify later-than-repair ordering without reopening raw history.

## 8. Repetition / Acknowledgement Policy

One source repair can produce at most one observation because projection output is deduped by `sourceRepairId`.

Repeated Session Summary reconstruction from the same proof can show the same line again because this wave intentionally did not add a durable read receipt or acknowledgement store. A second distinct source repair may produce a second observation.

## 9. Phrase Resolution

The observation uses the existing Sharky phrase resolver with:

- surface: Session Summary
- moment: later improvement observed
- evidence kind: transfer evidence
- transfer state: later correct
- tier: Foundation by default in the current runtime projection

Foundation line:

`You missed this clue before. On a later hand, you caught it.`

Developing line:

`You connected this signal correctly on a later hand.`

Both lines remain structural and claim-safe.

## 10. Consumer Admission

Admitted consumer: existing Session Summary fix receipt.

`Act0RepairOutcomeConsumerV1.fromProjection` accepts an optional improvement observation projection and appends exactly one Sharky observation line to the existing banked-fix receipt when eligible. It does not create a new card, route, visual state, CTA, or Review/Profile consumer.

`Act0ShellPreviewScreenV1` wires the projection into the existing block-completion Session Summary consumer and filters observations to the current/latest completed session id.

## 11. State Isolation

The projection is deterministic and source-derived. It does not mutate:

- repair outcomes
- Review receipts
- learning evidence history
- Practice queue state
- Profile proof state
- Session identity state

## 12. Telemetry Boundary

No telemetry event, analytics payload, dashboard, server state, or phrase-text logging was added. Phrase choice remains local and deterministic.

## 13. Screenshot / Evidence Result

Visible consumer changed, so both required screenshot lanes were run:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Both lanes passed. Local-only copied evidence:

- `output/sharky_saw_you_improve_v1/first_week_fast/`
- `output/sharky_saw_you_improve_v1/full_scroll_fast/`

These artifacts are intentionally not committed.

## 14. Tests / Validation

Focused tests passed:

- `flutter test test/ui_v2/act0_sharky_improvement_observation_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_learning_transfer_measurement_v1_test.dart test/ui_v2/act0_fix_proof_projection_v1_test.dart test/ui_v2/act0_cross_session_profile_proof_v1_test.dart test/ui_v2/act0_review_pattern_coaching_v1_test.dart`
- `flutter test test/ui_v2/act0_fix_proof_projection_v1_test.dart test/ui_v2/act0_sharky_improvement_observation_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart`

Final validation also passed:

- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- route capsule check for `Sharky Saw You Improve`, `Sharky Companion States`, and `sharky_saw_you_improve`

## 15. Rolling Capsule Advance

After this artifact lands:

- Sharky Saw You Improve is CLOSED.
- Sharky Companion States is ACTIVE.
- Phase 5 - Sharky Companion remains ACTIVE.

## 16. Scope Safety

Not added:

- new screen or route
- new Sharky asset
- new visual state, pose, motion, animation, or growth system
- generic praise
- random copy
- mastery, score, rank, percent, XP, or level claims
- telemetry
- durable acknowledgement persistence
- Review/Profile expansion
- W13+ phrase tier
- Modern Table or broad visual redesign

## 17. Known Limitations

The current runtime wiring defaults to the Foundation-safe tier for this observation. Developing copy is covered in phrase/projection tests but not yet routed from a dedicated world-band companion state.

The observation is not a universal learner memory. Without a persisted acknowledgement receipt, revisiting the same eligible Session Summary can show the same source-backed line again.

## 18. Next Recommendation

Proceed to `Sharky Companion States v1`.

That wave should define explicit companion states and tier/state routing without reopening this wave's evidence gate or adding unsupported personality, memory, mastery, or animation claims.
