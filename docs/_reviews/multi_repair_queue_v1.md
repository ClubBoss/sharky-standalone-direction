# Multi-Repair Queue v1

## 1. Verdict

multi_repair_queue_landed_with_single_visible_consumer

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- HEAD: `80b5adb86267b4f3dcb23dcb6dcef5d3531b92ff`
- Tracked/staged changes before work: none.
- Existing untracked `output/**` left unmodified and uncommitted.

## 3. Capsule/authority check

The context capsules were read as summaries only. Their next-task metadata was stale versus the prompt and live source, but not route-critical for the active Phase 3 sequence because the prompt, current review artifacts, live source, and tests all admitted Multi-Repair Queue as the active repair-depth wave.

## 4. Existing single-item assumptions

The Practice projection already accepted `List<Act0RepairIntentV1>`, and the Practice consumer already accepted projected rows with a max-visible cap. The limiting layer was runtime/persistence ownership: open repair intents were indexed by `sourceTaskId`, legacy persisted parsing collapsed by `sourceTaskId`, and new misses could overwrite same-source distinct repair identities.

## 5. Queue collection contract

Added `Act0MultiRepairQueueV1` as the bounded queue owner. Entries are schema-versioned and carry queue item id, exact source repair identity, concept family id, source task id, optional source session id, created/updated orders, attempt count, resolution state, and the linked repair intent payload required for stable launch target refs.

## 6. Capacity and admission policy

Capacity is three active unresolved repair items. Duplicate exact identities update the existing entry. Resolved/non-actionable entries are pruned by the queue resolution contract. If the queue is full with three active entries, a fourth distinct item is rejected fail-closed and existing active items are preserved.

## 7. Queue item identity

Identity remains the existing exact composite from `repairQueueIdentityKeyForAct0RepairIntentV1`: source task, missed signal, skill atom, and error type. Queue item ids remain `queueItemIdForAct0RepairIntentV1`, so Practice outcome and Review receipt matching keep their existing exact contract.

## 8. Deduplication rules

Same exact composite identity updates attempt count and last-updated order. Same family with a different exact identity stays separate. Malformed or targetless intents are not admitted. Persisted duplicate identities collapse deterministically on parse.

## 9. Ordering rules

Ordering is deterministic: attempted-not-resolved entries first, then unresolved entries, then oldest created order, latest update order, and queue item lexical fallback. No score, mastery, weakest-skill ranking, or hidden priority model was added.

## 10. Storage/migration

The existing shell progress owner was extended to schema version 15 with `multiRepairQueue` and `multiRepairQueueOrder`. Legacy `openRepairIntents` remains serialized for backward compatibility, and old snapshots migrate into a one-item-or-more bounded queue through exact identity parsing. Malformed optional queue entries fail safely.

Follow-up fix: after the multi-queue owner has admitted an item, an empty
post-prune queue no longer falls back to the legacy source-task debug index.
That prevents a successfully resolved active queue item from reappearing as
launchable Practice work.

## 11. Projection/consumer behavior

Practice projection, Review resolution, achievement projection, personalized return reason, and review receipts now read active repair intents through the queue-owned accessor. The existing consumer remains unchanged and still exposes a single pinned active repair row while preserving other queue entries in storage.

## 12. Review agreement

Review resolution still uses exact identity and receipts. A successful repair prunes the matching queue entry only; unrelated Review mistakes and unrelated queue entries remain active. Review does not own queue ordering.

Follow-up lifecycle proof confirms resolved exact identities no longer expose
the old Review repair CTA and no longer expose a launchable Practice queue CTA.
Failed repair remains active and launchable through the Practice queue.

## 13. Spaced-repetition boundary

No spaced-repetition consumer was admitted. The future seam remains: a scheduled family must provide a full source-owned candidate tuple before it can enter below active unresolved/failed repairs. The queue does not fabricate target fields from `nextDueFamily`.

## 14. Telemetry boundary

No telemetry events or telemetry payload owners were changed. Existing repair attempt, fix landed, and Practice launch behavior remains the only telemetry surface touched by this flow.

## 15. Screenshot evidence if applicable

No screenshots were generated. The visible Practice consumer was not redesigned and remains single visible/pinned active repair consumer behavior.

## 16. Backward compatibility

Existing launch request and queue item identity are unchanged. Legacy `openRepairIntents` snapshots migrate safely, and current snapshots keep the legacy field for older readers while using the new queue field as authoritative storage.

## 17. Tests/validation

Passed:
- `flutter test test/ui_v2/act0_multi_repair_queue_v1_test.dart`
- `flutter test test/ui_v2/act0_multi_repair_queue_v1_test.dart test/ui_v2/act0_queue_resolution_contract_v1_test.dart test/ui_v2/act0_review_resolution_contract_v1_test.dart test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_repair_outcome_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart`
- `flutter test test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_queue_resolution_contract_v1_test.dart test/ui_v2/act0_review_resolution_contract_v1_test.dart test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_review_mistake_history_consumer_v1_test.dart`
- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`

Original blocking failures and classification:
- `act0_repair_intent_lifecycle_v1_test.dart` expected `You missed the no-bet-yet clue.`. Classification: stale pre-contract copy expectation. Updated to assert the accepted compact repair-focus copy and absence of the old copy.
- `act0_repair_intent_lifecycle_v1_test.dart` tapped `act0_shell_review_fix_next_cta` for mapped repair launch. Classification: stale Review CTA expectation. Updated to assert resolved/unresolved Review CTA absence under the unresolved-only Review contract and launch active repair through the Practice queue.
- `act0_repair_intent_lifecycle_v1_test.dart` expected the legacy debug open-intent map to become null after successful Practice queue repair. Classification: mixed stale debug assertion plus real behavior regression. Updated to assert no launchable Practice queue CTA remains after success; product code was fixed so pruned multi-queue state cannot resurrect active work from the legacy source-task index.

Product behavior was not changed to satisfy stale copy or Review CTA tests.
The only product code change in the follow-up fixed the real queue resurrection
regression described above.

## 18. Scope safety

No Practice redesign, new screen, new CTA, Review redesign, pattern coaching, spaced-repetition consumer, new route family, content pack, W13+ work, server analytics, AI claim, ranking, generic task manager, drag/reorder UI, notification system, broad refactor, new dependency, or Modern Table visual change was added.

## 19. Known limitations

The first visible consumer remains single pinned active repair. Additional active queue entries are preserved and deterministically ordered in storage, but a future visible consumer follow-up is required if the product wants multiple active rows shown at once.

## 20. Next recommendation

Multi-Repair Visible Consumer Follow-up
