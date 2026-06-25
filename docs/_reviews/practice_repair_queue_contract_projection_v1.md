# Practice Repair Queue Contract + Projection v1

## 1. Verdict

practice_repair_queue_contract_projection_ready

## 2. Why Practice queue is next

Review now owns persisted unresolved mistake history, and active repair remains
owned by `Act0RepairIntentV1`. The missing learning-loop layer is a Practice
queue projection that can translate unresolved source-backed mistakes into a
small deterministic set of future repair reps.

This PR adds only the data contract and projection. It does not create Practice
UI, a queue renderer, a CTA, a route mutation, or repair completion semantics.

## 3. Queue owner contract

Practice repair queue projection owns only the queue view:

- `Act0PracticeRepairQueueProjectionV1`
- `Act0PracticeRepairQueueItemV1`

Existing owners remain unchanged:

- `Act0ReviewMistakeHistoryV1` owns persisted unresolved mistake records.
- `Act0RepairIntentV1` owns active/current repair intent.
- Home remains the next-action owner.
- Review remains the history owner.
- Practice is not admitted as a rendered reps owner in this PR.

The queue projection does not mutate Review history or active repair intent.

## 4. Source map

| Source | Projection source type | V1 decision |
| --- | --- | --- |
| `Act0ReviewMistakeHistoryV1.records` | `review_history_unresolved_v1` | Included. This is the primary source. |
| `Act0RepairIntentV1` | `active_repair_v1` | Included as an optional pinned item when dedup is explicit. |

Active repair is not treated as a new owner. It is read as a current source row
and deduped against Review history by source task, repair focus, skill tag, and
error detail.

## 5. Projection schema

`Act0PracticeRepairQueueItemV1` fields:

- `itemId`
- `sourceRecordId`
- `sourceKey`
- `sourceTaskId`
- `skillTag`
- `safeLabel`
- `errorDetail`
- `selectedId`
- `betterId`
- `context`
- `priority`
- `sourceType`
- `state`

Allowed source types:

- `review_history_unresolved_v1`
- `active_repair_v1`

Allowed state:

- `queued_unresolved_v1`

## 6. Retention/order rules

Projection retains at most 10 candidates.

Ordering is deterministic:

- active repair items are pinned before Review history items;
- Review history items sort newest-first by `updatedOrder`;
- ties fall back to stable source keys;
- final `priority` is assigned after sorting and cap.

Future Practice consumers should show at most 3 items unless a later admission
explicitly changes the visible cap.

## 7. Dedup rules with Review/Home/active repair

Dedup key:

- `sourceTaskId`
- `repairFocusId` / active repair `missedSignalId`
- `skillTag`
- `errorDetail`

If active repair and Review history share that key, the active repair item is
kept as the pinned queue row and the Review-history duplicate is skipped.

The projection does not dedup against Home state, route state, or Profile state,
because those are not queue owners.

## 8. Resolution-state boundary

No resolved/fixed/cleared state exists in V1.

Queue items remain `queued_unresolved_v1`. The projection does not mark a
mistake fixed, clear a Review item, complete a repair, or mutate any source
owner.

## 9. Consumer admission status

No Practice consumer was added.

Future consumer decision:

- Practice read-only repair queue section;
- show a small number of source-backed items;
- still no clear/fixed/done state until a separate resolution owner exists.

## 10. Forbidden-claim proof

The projection does not introduce:

- AI-found claims;
- leak-fixed claims;
- mastery/mastered claims;
- GTO or solver claims;
- premium/paywall claims;
- Practice UI copy;
- Review UI copy;
- Home/Profile/Session Summary copy.

Focused tests scan the projection payload and source for forbidden claim and
commerce vocabulary.

## 11. Tests / validation

Focused test added:

- `test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart`

Coverage:

- empty history creates an empty queue;
- unresolved Review history creates queued items;
- empty sources do not create queue items;
- retention cap is 10 candidates;
- deterministic ordering;
- active repair is pinned and deduped against matching Review history;
- active repair payload remains unchanged;
- no fixed/cleared/done states;
- no AI/leak-fixed/mastery/GTO/solver/premium copy;
- no UI imports/dependencies.

Validation run:

- `flutter test test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_review_mistake_history_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart`
- `graphify hook-check`;
- `flutter analyze`;
- `dart format --set-exit-if-changed` on touched Dart/test files only;
- `git diff --check`;
- `git status --short`.

`git status --short` shows only intended source/test/review changes plus
generated output directories under `output/`, which remain untracked.

## 12. Next recommended PR

Practice Repair Queue Consumer Admission v1 — Local Only.

Recommended scope:

- add a read-only Practice queue consumer;
- render at most 3 source-backed repair candidates if admitted;
- keep no resolved/fixed/cleared semantics;
- keep route/progression, telemetry, Profile, Review, Home, achievements,
  Modern Table, premium/paywall, and generated output out of scope.
