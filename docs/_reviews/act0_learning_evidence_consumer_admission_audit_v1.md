# Act0 Learning Evidence Consumer Admission Audit v1

## 1. Verdict

`blocked_needs_session_grouping`

The durable Act0 learning-evidence write path is ready, but no learner-facing
consumer is admitted yet. The safest first consumer is still Session Summary,
but it needs an explicit session/run grouping contract before it can truthfully
claim "this session" from persisted records.

## 2. Evidence capability map

The persisted evidence history can now truthfully derive:

| Capability | Current support | Safe claim boundary |
| --- | --- | --- |
| Total recent records | Supported through bounded history and `lastN`. | "Recent recorded decisions" only, not complete lifetime history. |
| Recent correct / incorrect count | Supported by `isCorrect` and bounded record queries. | Bounded last-N counts only when the query window is named. |
| Mistake records | Supported by `mistakes()`. | Recorded non-correct decisions only. |
| By skill atom | Supported by `bySkillAtom(skillAtomId)`. | Stable internal skill atom, not a public strength ranking. |
| By repair focus | Supported by `byRepairFocus(repairFocusId)`. | Stable repair-focus id, not proof that a repair is still open. |
| By result kind | Supported by `resultKind`. | Correct / incorrect / suboptimal result facts only. |
| Latest missed signal | Derivable as latest non-correct record with repair focus / missed signal identity. | Latest recorded miss, not a trend or leak. |
| Latest open repair focus | Not owned by evidence alone. | Must continue to come from existing repair-intent state. |
| Bounded last-N summary | Supported mechanically through `lastN`. | Safe only with explicit N and no statistical trend claim. |

Still not claimable:

- true mastery;
- leak detection;
- long-term skill ranking;
- solver, GTO, or optimal comparison;
- statistically meaningful trend;
- "best area" or "worst area" without a separate threshold policy;
- current-session summary unless records carry a session/run boundary;
- open repair status unless combined with the existing repair-intent owner.

## 3. Candidate consumer analysis

| Candidate | Classification | Reason |
| --- | --- | --- |
| Session Summary proof | `safe_only_with_contract` | Highest EV and least identity risk, but persisted records currently lack a session/run id. Without that, a summary can only say bounded recent decisions, not "this session." |
| Review mistake-history contract | `safe_only_with_contract` | Mistakes and repair focus ids exist, but Review history needs a taxonomy and open/resolved boundary so it does not duplicate or contradict active repair ownership. |
| Profile evidence contract | `defer_scope_too_large` | Profile invites identity, strength, growth, and ranking claims. The current evidence does not support broad progress identity without threshold and scope policy. |
| Practice recommended drill contract | `defer_needs_more_data` | Evidence can identify repair focus, but drill routing requires a separate recommendation/launch policy and possibly more content coverage. |
| Home current focus improvement | `reject_duplicate_consumer` | Home already owns next action and active repair routing. A durable-evidence consumer here would likely duplicate existing repair ownership. |
| No consumer yet | `safe_now` | Preserves truthful boundaries while the write path proves stable. |

## 4. Consumer admission decision

No consumer is admitted in this wave.

The first admitted consumer should be a Session Summary evidence proof only
after a session/run grouping field or equivalent current-run boundary is
defined. That contract should make the query window explicit and avoid any
long-term trend, mastery, leak, or strength claim.

## 5. If admitted: implemented tiny slice

No implementation was added. This is a documentation/contract audit only.

## 6. What Profile can / cannot claim

Profile can continue to show existing progress, recent gains, current focus,
and repair continuity from its current owners.

Profile cannot yet claim:

- "your strongest area";
- "your weakest leak";
- "you are improving over time";
- "based on your last N decisions";
- mastery, solver, GTO, or AI-personalized identity.

Any future Profile evidence contract needs thresholds, query boundaries, and a
clear separation from Review and Home repair ownership.

## 7. What Review can / cannot claim

Review can continue to show existing open repair context, dominant repeated
pattern from current Review state, and repair coaching.

Review cannot yet claim a complete durable mistake-history backlog from the new
evidence store. Durable evidence can supply candidate facts later, but Review
needs a scoped history contract defining:

- which records enter Review;
- how open versus resolved state is determined;
- how repeated families are counted;
- how old records expire or stay secondary.

## 8. What Session Summary can / cannot claim

Session Summary is the preferred first consumer once a session grouping exists.

It can eventually claim:

- decisions completed in the current session/run;
- correct and non-correct counts for that session/run;
- one latest missed signal;
- one next repair focus, if the repair-intent owner agrees.

It cannot yet claim those from durable history because current records do not
carry an explicit session/run identity.

## 9. What Practice can / cannot claim

Practice can continue to use existing daily drill and repair reinforcement
owners.

Practice cannot yet recommend drills solely from durable evidence without a
separate routing contract that maps a repair focus or skill atom to a launchable
practice target. W6 range-bucket and board-texture repair seams show the shape
of such contracts, but this audit does not expand them.

## 10. Telemetry compatibility

No telemetry event, schema, payload, or timing convention changes. The durable
evidence store remains local and non-telemetry. Any future consumer must not
reuse telemetry event keys as learner-facing evidence identity.

## 11. Route/progression boundary proof

No route, progression, W11/W12 activation, W13+ state, content, glossary,
Modern Table, premium, Profile UI, Review UI, Practice UI, Home UI, or Session
Summary UI changed.

## 12. Baseline residue, if observed

The known `act0_telemetry_sink_v1_test.dart:565` repair-flow failure remains
classified as baseline residue from clean baseline evidence. This audit does
not touch telemetry.

## 13. Tests / validation

Validation for this docs-only audit:

- durable evidence write-path tests;
- completed-decision callback and evidence-facts tests;
- repair intent / rule-based decision / resolver tests;
- feedback rhythm tests;
- `graphify hook-check`;
- `flutter analyze`;
- `git diff --check`;
- `git status --short`.

## 14. Next recommended wave

`Session Summary Evidence Grouping Contract v1`

Add only the missing session/run boundary needed for a future Session Summary
consumer. Do not add Profile, Review history, Practice recommendation, or Home
evidence consumers until the Session Summary contract proves the minimal safe
query shape.
