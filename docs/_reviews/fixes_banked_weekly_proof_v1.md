---
status: "fixes_banked_weekly_proof_landed_with_recent_session_window"
status_source: "derived"
baseline: "4d358bf97e50"
generated_by: "docs_frontmatter_v1"
---

# Fixes Banked / Weekly Proof v1

## 1. Verdict

fixes_banked_weekly_proof_landed_with_recent_session_window

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `4d358bf97e508479072b7dc9abc78285fec7a031`
- Preflight found no tracked or staged changes; only `output/**` was untracked.
- `graphify hook-check` passed.

## 3. Capsule/authority check

The route capsules were stale versus the active prompt and live HEAD, but not route-critical for this bounded Phase 4 wave. The prompt, live source, current tests, and latest review artifacts were used as higher authority.

## 4. Current proof ownership audit

- Current Session Summary proof receipt: `Act0RepairOutcomeConsumerV1.sessionReceipt`, rendered by `Act0BlockCompletionShellV1`.
- Current Profile proof projection: `Act0ProfileEvidenceProjectionV1` and `Act0ProfileEvidenceConsumerV1`.
- Current Home proof/support line: Home daily goal support and personalized return reason.
- Current Review resolution receipts: `Act0ReviewResolutionReceiptHistoryV1`.
- Current repair success/failure records: `Act0RepairOutcomeProjectionV1`.
- Current concept-family state: `Act0ConceptFamilyStateHistoryV1`.
- Current transfer evidence: `Act0LearningTransferMeasurementV1`.
- Current session identity and ordering: `Act0SessionIdentityStateV1`.
- Current persistence owner: `_Act0PersistedProgressV1`.
- Existing learner-facing proof slot admitted: Session Summary repair outcome receipt.

## 5. Proof terminology

- `repair completed`: an exact matching successful repair outcome accepted through Review resolution receipt evidence.
- `later evidence observed`: a later same-family transfer signal with an accepted positive verdict.
- `fix banked`: a completed repair proof item accepted into the derived projection.
- `reinforced`: a banked fix with later valid supporting transfer evidence.
- `mastered`: forbidden.

## 6. Fix proof contract

Added `Act0FixProofProjectionV1` and `Act0FixProofItemV1`.

Fields include schema version, stable proof id, queue item id, concept family id, optional repair focus/source task, repair session id, repair outcome ref, proof state, later evidence refs, transfer verdict, banked order, and message key.

## 7. Admission rules

A fix is banked only when:

- Review resolution receipt exists;
- receipt has a valid `repair_outcome_v1|sequence|queueItemId` ref;
- matching repair outcome exists;
- matching outcome is correct;
- concept family is non-empty;
- repeated exact identity reads collapse into one proof.

## 8. Reinforcement rules

A completed fix is reinforced only when transfer measurement supplies:

- same concept family;
- `same_family_transfer_v1`;
- `improved_v1`;
- later comparison order;
- later distinct session;
- non-empty comparison task.

Same-task repeat, same-session evidence, different-family evidence, and failed later attempts do not reinforce.

## 9. Recent/weekly window decision

Calendar-week grouping was not admitted. Existing state has local date fields, but the reliable proof sources are session/order based. The implementation uses a bounded recent-session window and phrases aggregate copy as `across your recent sessions`, not `this week`.

## 10. Aggregation rules

Aggregate outputs:

- completed fix count;
- reinforced fix count;
- distinct concept-family count;
- bounded recent proof items capped at three visible items;
- `recent_session_window_v1` descriptor.

Ordering is deterministic: reinforced first, then newest banked order, then proof id.

## 11. Persistence/derivation boundary

Path A, derived proof. No new proof receipt or persistence field was added. Proof reconstructs from persisted Review resolution receipts, repair outcomes, and learning transfer signals.

## 12. Consumer admission

Path B, bounded existing consumer. The existing Session Summary repair receipt now uses structured fix-proof aggregate lines when a fix proof projection is supplied. The old repair-outcome fallback remains when no banked fix proof exists.

## 13. Claim-safe copy

Admitted copy:

- `1 repair completed`
- `2 fixes banked across your recent sessions`
- `1 completed repair now has later supporting evidence`
- `2 completed repairs now have later supporting evidence`

Forbidden mastery, score, percentage, weakest-skill, level, rating, AI, and fixed-forever claims are not introduced by the proof projection.

## 14. Relationship to repair/review/pattern layers

- Queue resolution remains the active repair truth owner.
- Review resolution remains unresolved-only and supplies durable resolved receipts.
- Completed fixes do not resurrect Review rows.
- Multi-repair ordering is unchanged.
- Pattern coaching remains a reader, not a proof owner.
- Transfer measurement supplies later evidence only.
- Personalized return reasons and spaced-repetition timing remain independent.

## 15. Telemetry boundary

No telemetry event, sink, payload, vendor SDK, or analytics owner was added.

## 16. Screenshot evidence if applicable

Visible Session Summary proof changed, so screenshot evidence was generated:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Local evidence was copied to `output/fixes_banked_weekly_proof_v1/`.

## 17. Backward compatibility

No storage schema bump was required. Old state loads safely because the projection is derived and `Act0FixProofProjectionV1.tryParse` is tolerant of malformed or partial proof payloads.

## 18. Tests/validation

- `flutter test test/ui_v2/act0_fix_proof_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_fix_proof_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_fix_proof_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_fix_proof_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/ui_v2/act0_queue_resolution_contract_v1_test.dart test/ui_v2/act0_review_resolution_contract_v1_test.dart test/ui_v2/act0_multi_repair_queue_v1_test.dart test/ui_v2/act0_review_pattern_coaching_v1_test.dart test/ui_v2/act0_learning_evidence_contract_v1_test.dart test/ui_v2/act0_session_identity_v1_test.dart test/ui_v2/act0_learning_transfer_measurement_v1_test.dart test/ui_v2/act0_repair_outcome_contract_v1_test.dart test/ui_v2/act0_repair_outcome_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Block completion consumes grouped latest-run evidence"`
- screenshot lanes listed above
- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`

## 19. Scope safety

No new route, destination, generic analytics surface, Profile redesign, Home redesign, achievement icon system, motion, W13+ work, server analytics, dependency, or Modern Table visual change was added.

## 20. Known limitations

- The window is recent-session based, not calendar-week based.
- The visible consumer is Session Summary only.
- Profile-level durable proof remains a follow-up.
- Exact proof depends on Review resolution receipts for durable admission.

## 21. Next recommendation

Cross-Session Proof Profile v1
