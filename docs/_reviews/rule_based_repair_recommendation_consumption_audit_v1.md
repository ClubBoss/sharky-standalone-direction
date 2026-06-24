# Rule-Based Repair Recommendation Consumption Audit v1

## 1. Verdict

`existing_consumption_sufficient_no_change`

The active-route consumers already cover the deterministic repair decision at
the correct moments and with distinct roles. Adding another consumer would
repeat current-focus copy, compete with Home, or imply unsupported history.

## 2. Existing consumer map

| Consumer | Existing input | Current role | Ownership result |
| --- | --- | --- | --- |
| Home current action | Reason receipt and copy bridge | Selects the next useful hand and remains the only primary repair launch owner. | Sufficient. |
| Practice | Same receipt through its repair recommendation | Frames one same-clue rep or exact replay as reinforcement. | Sufficient. |
| Review | Repair-intent surface copy and open-mistake priority | Explains active repair without becoming a competing launch source. | Sufficient. |
| Wrong feedback | Repair reason, result receipt, and session-repair lines | Explains the current miss and keeps one immediate CTA. | Sufficient. |
| Repair result / session repair | Existing guarded receipt helpers | Shows outcome of the active repair, not a new recommendation. | Sufficient. |

`Act0RuleBasedRepairDecisionV1` is produced inside the next-useful-hand reason
receipt. Its source, target, mapping type, reason code, and rule-based
priority remain available without a second model.

## 3. Candidate consumer analysis

### Home current focus

Already consumes the repair selection through `_learningRecommendation` and
the reason receipt. A direct second decision card would duplicate the hero
action that PR1/PR1b intentionally consolidated.

### Practice recommended drill

Already consumes the same receipt to describe a same-clue rep or exact replay.
It is the correct secondary reinforcement owner and needs no additional CTA.

### Review repair context

Already consumes repair context. PR1b intentionally removed its generic CTA
because Home owns the active repair action. Reintroducing a direct
recommendation here would reverse that ownership decision.

### Feedback repair CTA

Already consumes the current repair through its reason/result/session lines.
The wrong-feedback CTA is intentionally immediate and singular. Adding a
second recommendation label would duplicate the existing reason.

### Session repair handoff

Already consumes repair outcome after the attempt. It is proof of the active
repair, not a safe place to create a new next-action owner or durable history.

## 4. Chosen consumer

None. Existing consumption is intentionally complete for the active W1-W10
route.

## 5. Why no fake history / personalization is introduced

The decision is based on an open repair intent from the current route. It uses
source task, learner choice, result, missed signal, skill atom, and a mapped
or exact target. It does not create evidence counts, strength scores,
weakness history, leak labels, mastery, or Profile claims.

## 6. Boundary proof

- No new UI surface, consumer card, CTA, Profile evidence, Review backlog,
  session summary, repair variant, ML, LLM, chat, or user-facing AI claim.
- No Modern Table, W11/W12 activation, W13+, content, glossary, premium, or
  generated-output work.

## 7. Route / progression truth proof

Home remains the active repair launch owner. Practice remains reinforcement.
Review remains repair context. The decision resolves only a launchable current
route target and uses exact replay when a same-signal target is unavailable.
No route or progression contract changed.

## 8. Telemetry compatibility

No telemetry schema change is required. Consumers rely on the persisted repair
intent and local reason receipt; existing `user_choice`, `task_result`, and
`feedback_viewed` telemetry remains intact. Active Act0 still owns only a
decision-time bucket, which is sufficient for this current-focus layer.

## 9. Tests / validation

- Repair intent contract, rule-based decision, and resolver tests.
- Feedback rhythm tests.
- Existing Home/Practice/Review resolver assertions that preserve distinct
  surface ownership.
- `graphify hook-check`, `flutter analyze`, `git diff --check`, and status
  review.

## 10. Next recommended wave

No new repair-consumption implementation is admitted. Reassess only when new
evidence identifies a concrete owner gap; otherwise return to the active
product bottleneck rather than adding presentation layers.
