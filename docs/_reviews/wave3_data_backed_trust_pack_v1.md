# Wave 3 Data-Backed Trust Pack v1

## 1. Verdict

wave3_trust_pack_ready_profile_projection_next

## 2. Current Wave 3 state

Wave 1 and Wave 2 are closed. Wave 3 has started with the Review
mistake-history family:

- `Act0ReviewMistakeHistoryV1` is admitted as an unresolved-only projection for
  non-correct completed decisions.
- The Act0 completed-decision write path persists `reviewMistakeHistory`
  beside the existing learning evidence history.
- `Act0ReviewMistakeHistoryConsumerV1` turns persisted unresolved records into
  read-only Review notes.
- `Act0ReviewShellV1` can render `Past spots to review` notes.
- The Review empty state remains `No past spots to review yet`.
- `Act0RepairIntentV1` remains the owner of active repair intent and active
  repair routing.
- No clear, fix, resolved, fixed, or cleared state exists for Review
  mistake-history records.

## 3. Part A — Review history UI acceptance

Accepted.

The current Review read-only history UI is acceptable as the first
data-backed Review tab/surface. The implementation keeps history rows
read-only, sources rows from `Act0ReviewMistakeHistoryV1`, and suppresses a
history item when its `sourceTaskId` is already represented by the active
repair source set.

Focused Review tests prove the rendered row contract:

- persisted history rows render under `Past spots to review`;
- history rows use read-only notes rather than repair controls;
- the empty state remains honest when no history exists;
- active repair remains separate from persisted unresolved history.

## 4. Part A — screenshot evidence inspected

Ran and inspected:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Generated packets are local-only:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/full_scroll_fast/`

Inspection result:

- First-week packet shows standard onboarding, decision, feedback, repair,
  session summary, Review handoff, and Profile return states. Review does not
  show clear/fix/resolved/fixed/cleared controls or forbidden claims.
- Day 2 return packet shows the Review continuation as an active repair note,
  not duplicate equal-primary jobs.
- Full-scroll packet shows the Review frame remains compact and honest, with no
  hidden repair-resolution controls or forbidden claim language.

Capture limitation:

The current screen-review capture state set covers standard Review empty,
handoff, active-repair, day-2 continuation, and full-scroll frames. It does not
currently include a screenshot state that visibly displays a persisted
`Past spots to review` history row. That row state is covered by focused
rendered tests and source inspection in this pack. This is not a blocker for
this task because the screenshot packets show no Review regression and the
row-specific behavior is already under focused tests.

## 5. Part A — blocker/fix decision

No blocker was found. No product code change is admitted in this task.

Checked blocker list:

- Duplicate active repair/history as two equal primary jobs: not visible in the
  inspected packets; consumer also suppresses active repair source ids.
- Forbidden resolved/fixed/clear state visible: not visible.
- Fabricated history rows: not found; rows are sourced from
  `Act0ReviewMistakeHistoryV1`.
- Dishonest Review empty state: not found; empty Review remains honest.

Decision: do not implement a Review fix in this PR.

## 6. Part B — Profile evidence source audit

Profile capability claims must not be sourced from activity counters alone.
Current counters such as XP, level, streak, tasks completed, badges, and generic
progress can remain activity/progress indicators, but they are not capability
proof.

Allowed durable source family for future Profile capability:

- `Act0LearningEvidenceHistoryV1`, because it stores completed-decision
  evidence and can be projected into bounded skill/concept summaries.

Supporting but insufficient sources:

- `Act0ReviewMistakeHistoryV1` can support `needs review` style unresolved
  mistake counts only. It must not become Profile capability proof by itself.
- `Act0RepairIntentV1` can support active repair routing and current repair
  context only. It must not become Profile capability proof by itself.
- `Act0ReviewStateV1` and existing Profile presentation state are not durable
  capability evidence owners.

Required owner for Profile capability:

A future data-only projection should own Profile capability truth before any
Profile UI consumption. Recommended owner name:
`Act0ProfileCapabilityEvidenceV1` or `Act0ProfileCapabilityProjectionV1`.

That projection should derive from durable completed-decision evidence, not
from raw Review history rows or activity counters.

## 7. Part B — Profile capability contract

A future Profile capability projection must expose fact-only fields before
Profile can say anything skill-like:

- `schemaVersion`
- `capabilityId`
- `conceptId` or `skillAtomId`
- display label separated from the source id
- `correctCount`
- `attemptCount`
- `sampleThreshold`
- `windowKind`, either `recent` or `all_time`
- explicit window bounds, such as record order range or run/window id
- `confidenceEligible`
- `worldId` and/or route context
- `lessonIds` or source lesson context
- `lastUpdatedOrder` or equivalent sequence
- `sourceRecordCount`
- `evidenceVersion`

Profile may consume this only after the projection and its tests are admitted.
Until then, Profile must remain activity/progress-led and must not add
capability copy.

## 8. Part B — thresholds and allowed claims

Minimum thresholds:

- No capability claim with fewer than 5 completed attempts for the named
  concept/skill.
- No `strongest skill`, `weakest skill`, or ranking language until a separate
  ranking projection is admitted.
- No `based on your last N decisions/hands` unless the projection explicitly
  owns that N and its window boundaries.
- No trend language unless the projection owns a recent window and an older
  comparison window, each with enough samples.
- No durable capability claim from Review mistake history alone.

Allowed future copy families after thresholds are met:

- `You are getting better at reading no-bet-yet spots.`
- `Recent proof: X/Y correct in this concept.`
- `Keep practicing this spot type.`
- `First capability signal unlocked.`

These are copy families only. The exact text still requires a future UI/copy
admission after the data projection exists.

## 9. Part B — forbidden claims

Forbidden Profile and Review claim families:

- `AI detected your leak`
- `You mastered this`
- `Your biggest leak is...`
- `GTO approved`
- `Solver-backed`
- `Based on your last N hands` unless N is explicitly owned by the projection
- premium, paywall, trial, or subscription claims
- any claim that Review mistake history alone proves skill mastery or durable
  capability
- any claim that the current app has activated W11/W12, W13+, Volume I
  completion, 36-world runtime coverage, or a Practice recommendation engine

## 10. Part C — Practice repair queue dependency map

Practice queue must not start until Review history acceptance is complete and
queue ownership/dedup rules are named. Review acceptance is complete in this
pack; queue ownership is defined here but not implemented.

Answers:

1. Practice queue can reference `Act0ReviewMistakeHistoryV1` as a candidate
   source, but it must not reuse Review history itself as the queue owner.
2. `Act0RepairIntentV1` must continue to own the current active repair intent,
   active repair routing, source/target identity, and repair reason.
3. The single future queue owner should be a new bounded data projection, for
   example `Act0PracticeRepairQueueV1` or
   `Act0PracticeRepairQueueProjectionV1`.
4. Home, Practice, and Review avoid duplicate jobs through one source identity
   and one primary action rule per repair source.
5. Queue entry requires a completed non-correct source plus a launchable repair
   target. Raw unresolved history is not enough.
6. Queue exit requires an admitted completion/consumption policy. Review
   history must not gain a resolved state as an accidental side effect.
7. The smallest safe later PR is `Practice Repair Queue Contract v1` as
   data/contract only.

## 11. Part C — Home/Practice/Review dedup rules

Dedup key:

- primary: `sourceTaskId`
- secondary: `repairFocusId`, `skillAtomId`, `errorType`, and source decision
  identity when available

Surface rules:

- Home owns the single daily primary CTA.
- Practice may show a repair queue item only when a queue owner has admitted it
  and it does not duplicate the current active repair as a separate job.
- Review can show active repair context and read-only unresolved notes, but it
  must not turn unresolved history into clear/fix/resolved actions.
- If active repair and unresolved history share the same source identity, active
  repair wins as the actionable item and the history row is suppressed or
  demoted.
- A queue item must point to the same repair source identity across Home,
  Practice, and Review so the product does not present one mistake as three
  unrelated jobs.

## 12. Part D — next PR decision

Profile Evidence Projection v1 — Data Only

Reason:

Review read-only history is accepted without a blocker, and Practice queue
should not start until the queue owner/dedup contract becomes its own bounded
work. Profile now needs a data-backed capability projection before it can safely
graduate from activity counters to evidence-backed capability language.

The next PR should be data-only: projection contract, source tests, thresholds,
and no Profile UI consumption.

## 13. Explicit non-goals

This pack does not implement:

- Profile capability UI
- Profile capability copy
- Practice queue UI
- Review clear/fix/resolved/fixed/cleared state
- route or progression changes
- telemetry changes
- Modern Table changes
- premium/paywall/trial copy
- AI, leak, mastery, GTO, or solver claims
- achievements, dopamine systems, badges, rewards, or streak redesigns
- generated screenshot commits

## 14. Validation

Passed:

- `flutter test test/ui_v2/act0_review_mistake_history_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_review_mistake_history_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Incorrect completed decisions persist unresolved mistake history'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Correct completed decisions do not persist mistake history'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Persisted review mistake history round-trips'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Review consumes persisted mistake history as read-only notes'`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short` showed only this review doc plus generated local output
  directories before staging.

No formatter is required because this is a docs-only change.

## 15. Recommended next prompt

Task title:
Profile Evidence Projection v1 — Data Only

Workflow mode:
Data contract and projection implementation only. No Profile UI, no Profile
copy, no route/progression changes, no telemetry changes.

Goal:
Implement a bounded Profile capability evidence projection over durable
completed-decision evidence, with explicit sample thresholds and claim
eligibility fields. Do not consume the projection in Profile yet.

Required constraints:

- Source from `Act0LearningEvidenceHistoryV1` or an admitted completed-decision
  evidence seam.
- Do not use `Act0ReviewMistakeHistoryV1` as capability proof by itself.
- Preserve `Act0RepairIntentV1` as active repair owner.
- Expose fact-only projection fields: concept/skill id, counts, threshold,
  window, eligibility, route context, last updated order, and source record
  count.
- Add focused tests for threshold gating and forbidden claim prevention.
- Do not add mastery, leak, AI, GTO, solver, premium, or ranking claims.
