---
status: "street_replay_how_we_got_here_landed_with_bounded_consumer"
status_source: "derived"
generated_by: "docs_frontmatter_v1"
---

# Street Replay / How We Got Here v1

## 1. Verdict

`street_replay_how_we_got_here_landed_with_bounded_consumer`

Street Replay is landed as a source-gated, inline Act0 decision-context aid.
It reconstructs ordered prior actions from existing table/action-trail state
and renders one compact `How we got here` block inside the current decision
panel when source truth is complete or partial-safe.

## 2. Scope

Admitted surface:

- `lib/ui_v2/act0_shell/act0_street_replay_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- focused Street Replay projection/widget tests

No new route, screen, persistence, dependency, solver layer, hand-history DB,
timeline scrubber, animation, Modern Table redesign, W13+ scope, or telemetry
was introduced.

## 3. Source Ownership Audit

| Fact | Source | Result |
| --- | --- | --- |
| current street | `Act0TableStateV1.streetLabel` | source-backed |
| board cards | `Act0TableStateV1.boardCards` | source-backed, street-capped |
| hero position | `Act0TableStateV1.heroSeat.seatLabel` | source-backed |
| opponent position | first non-hero `Act0SeatStateV1.seatLabel` | optional source-backed |
| effective stack | existing seat `stackLabel` | optional source-backed |
| pot/current price | `potLabel` and `toCallLabel` | optional source-backed |
| prior actions | `Act0TableStateV1.actionTrail` | source-backed |
| current actor | `activeSeatId` resolved into seat display/label | required for consumer |
| pending action | not read from option selection | excluded |
| HH metadata | none | not introduced |

## 4. Replay Contract

`Act0StreetReplayV1` now carries:

- `currentStreet`
- `heroPosition`
- optional `opponentPosition`
- optional `effectiveStackBb`
- ordered `steps`
- `currentDecisionActor`
- optional current decision summary/context
- `sourceRefs`
- `completeness`: `complete`, `partialSafe`, or `insufficient`

`Act0StreetReplayStepV1` carries street, actor, action type, optional amount,
source order, board cards visible by that street, optional current pot label,
and the current-street marker.

## 5. Fail-Closed Behavior

The projection returns `null` when there is no source-owned street/action-trail
context. It returns `insufficient` with no steps when required actor/action
truth cannot be parsed. The learner-facing consumer only renders when
`isConsumerSafe` is true.

Missing optional stack, opponent, pot, price, or clue fields do not fabricate
copy. They leave the optional fields empty or downgrade to `partialSafe`.

## 6. Street Coverage

The current contract safely supports preflop, flop, turn, and river when the
existing table state and action trail carry those streets. Board cards are
street-capped: preflop shows none, flop shows three, turn four, river five.

## 7. Action Truth

Action steps are parsed from ordered action-trail labels. Actor labels must be
recognized seat labels such as `SB`, `BB`, `BTN`, `CO`, `HJ`, `LJ`, `MP`, or
`UTG+`. Action verbs must be known poker action words such as blind/post,
check, bet, raise, call, fold, shove, or jam.

No copy inference is used to invent a missing actor or amount.

## 8. Current Decision Integrity

The replay stops at existing prior action-trail state. It does not consume the
currently pending options, selected option, correct answer, future street, or
solver advice. If no action exists on the current street, the inline consumer
marks the current decision separately with `You are here` rather than creating
a fake action step.

## 9. Presentation

The admitted consumer is one compact inline block inside the existing
`_ActionPromptPanelV1` decision surface. It renders:

- title: `How we got here`
- compact ordered action rows for the current street when available, otherwise
  the safe prior action trail
- current-decision marker
- optional source-backed decision context

No modal, collapsible history, large section, playback, scrubber, or animation
is used.

## 10. Foundation / Developing Readability

The text remains beginner-readable: concrete street, action, board, pot, and
`You are here` language. The implementation does not fork separate Foundation
and Developing architectures.

## 11. Consumer Admission

Only one learner-facing consumer is admitted: the existing Act0 lesson decision
panel. The existing action buttons, callbacks, route behavior, table rendering,
and answer options are preserved.

## 12. Table Relationship

The replay complements the table and does not redesign table geometry. Board
cards are shown only as compact text in the replay rows and are capped by
street to avoid future-card leakage.

## 13. Telemetry / Persistence

No telemetry field, analytics event, local persistence field, schema migration,
or hand-history storage was added.

## 14. Tests

Focused tests prove:

- deterministic ordered street replay from action trail and table state;
- new projection fields and completeness;
- fail-closed behavior when actor truth is missing;
- inline consumer renders without hiding the action panel;
- old entry/sheet/playback/motion keys are absent from the admitted consumer;
- consumer stays hidden when source-owned street/action-trail context is absent.

## 15. Screenshot Evidence

No screenshot packet was generated for this pass. The visible consumer changed,
but the focused widget test exercises the compact learner-facing state directly
and the final validation still includes analyzer and hygiene checks.

## 16. Validation

Performed during implementation:

- TDD red: focused Street Replay tests failed on missing projection fields and
  missing inline consumer.
- TDD green: focused Street Replay projection/widget suite passed.

Final validation commands are recorded in the implementation response.

## 17. Risk / Limits

Known bounded limits:

- actor parsing is intentionally conservative;
- optional effective-stack/pot/price fields are not guessed;
- older action-trail copy outside the new replay consumer can still use legacy
  labels such as `Hand history`;
- the consumer does not attempt a full hand replay or playback state.

## 18. Capsule Advance

Advance route state:

- `Street Replay / How We Got Here v1` -> CLOSED
- `W7-W12 Table-Context Readiness Audit v1` -> ACTIVE
- verified active route artifact ->
  `docs/_reviews/street_replay_how_we_got_here_v1.md`

## 19. Next Recommendation

`W7-W12 Table-Context Readiness Audit v1`
