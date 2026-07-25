---
status: "review_multi_session_pattern_coaching_landed_with_bounded_consumer"
status_source: "derived"
generated_by: "docs_frontmatter_v1"
---

# Review Multi-Session Pattern Coaching v1

## 1. Verdict

review_multi_session_pattern_coaching_landed_with_bounded_consumer

## 2. Scope

Added a deterministic Review coaching projection for repeated, source-backed patterns across learner sessions. The only visible consumer is one optional line inside an existing read-only Review mistake-history row.

## 3. Source Inputs

- `Act0LearningEvidenceHistoryV1`
- `Act0ReviewMistakeHistoryV1`
- `Act0ReviewResolutionStateV1`
- active `Act0RepairIntentV1` values
- `Act0RepairOutcomeProjectionV1`
- `Act0LearningTransferMeasurementV1`

## 4. Pattern Contract

`Act0ReviewPatternCoachingProjectionV1` emits sorted `Act0ReviewPatternCoachingPatternV1` records with stable ids, concept family, pattern type, session count, evidence count, source tasks, state, evidence strength, latest order, and copy message key.

## 5. Eligibility

Repeated miss patterns require at least two miss records in the same concept family across at least two non-empty session ids. Failed repair patterns require at least two failed repair outcomes for an active repair queue identity across at least two non-empty session ids. Improvement patterns require an existing same-family transfer signal with `improved_v1`.

## 6. Evidence Strength

Two-session evidence maps to `two_session_signal`. Three or more distinct sessions map to `repeated_multi_session_signal`. Improvement evidence maps to `improvement_observed`.

## 7. Pattern Types

- `repeated_miss_across_sessions`
- `repeated_unsuccessful_repair`
- `miss_then_later_improvement`
- `insufficient_evidence`

## 8. Pattern States

- `active`
- `improving`
- `historical`
- `insufficient_evidence`

## 9. Selection

Selection is deterministic: failed repair outranks repeated miss, repeated miss outranks improvement, then active state, session count, latest evidence order, and concept family id.

## 10. Review Consumer

`Act0ReviewMistakeHistoryConsumerV1` accepts an optional pattern projection and attaches `patternLine` to at most one matching read-only history item. It does not create a new Review section, CTA, route, or queue item.

## 11. Claim-Safe Copy

Current copy is limited to conservative local statements:

- `This table-reading mistake showed up in more than one session.`
- `This repair has not landed yet across your recent attempts.`
- `You missed this earlier, then handled it correctly on a later hand.`

## 12. Review Resolution Relationship

Resolved Review items are not resurrected into active Review. If matching Review history exists but all matching items are non-visible under Review resolution, the pattern is marked historical.

## 13. Multi-Repair Relationship

The projection reads active repair intents and repair outcomes but does not mutate, reorder, create, prune, or launch multi-repair queue items.

## 14. Persistence Boundary

No new persistence owner was added. The projection is rebuildable from existing local evidence histories and outcomes.

## 15. Telemetry Boundary

No telemetry sink, analytics owner, external service, SDK, or event stream was added.

## 16. UI Boundary

The only UI change is a single optional text line rendered inside `_MistakeHistoryRowV1`. No dashboard, graph, score, percentage, mastery surface, Practice redesign, or new route was added.

## 17. Screenshot Evidence

Ran `./tools/screen_review_fast_v1.sh core compact`. The script produced its built-in packet at `output/screen_review/current/core_fast/`; the packet was copied to `output/review_multi_session_pattern_coaching_v1/` for this wave.

## 18. Validation

- `flutter test test/ui_v2/act0_review_pattern_coaching_v1_test.dart`
- `flutter test test/ui_v2/act0_review_pattern_coaching_v1_test.dart test/ui_v2/act0_review_mistake_history_consumer_v1_test.dart test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_review_pattern_coaching_v1_test.dart test/ui_v2/act0_review_mistake_history_consumer_v1_test.dart test/ui_v2/act0_review_shell_v1_test.dart test/ui_v2/act0_review_resolution_contract_v1_test.dart test/ui_v2/act0_queue_resolution_contract_v1_test.dart test/ui_v2/act0_multi_repair_queue_v1_test.dart test/ui_v2/act0_learning_evidence_contract_v1_test.dart test/ui_v2/act0_session_identity_v1_test.dart test/ui_v2/act0_learning_transfer_measurement_v1_test.dart test/ui_v2/act0_repair_outcome_contract_v1_test.dart test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Review consumes persisted mistake history as read-only notes"`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Persisted review resolution receipt hides resolved note"`
- `flutter analyze`
- `./tools/screen_review_fast_v1.sh core compact`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`

Attempted broader preview validation with `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart`; it is not a green gate in this worktree and ended at `571` tests run with `117` failures across unrelated debug capture, Learn, runner, Review snapshot, and retention cases.

## 19. Generated Drift

`macos/Flutter/GeneratedPluginRegistrant.swift` contained unrelated generated plugin drift and was restored before closeout.

## 20. Deferred Work

Deferred items remain deferred: Multi-Repair Visible Consumer Follow-up, Concept Family to Practice Target Mapping Follow-up, Spaced Repetition Practice consumer, passive recovered-history UI, and broad repair outcome-history dashboard.

## 21. Phase Recommendation

Review Multi-Session Pattern Coaching closes the current repair-depth sequence after Queue Resolution, Review Resolution, and Multi-Repair Queue. Recommended next prompt: `Fixes Banked and Weekly Proof v1`.
