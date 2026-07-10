# Stable Table Lesson Architecture and Interaction Audit v1

## 1. Terminal verdict

Choose **Direction B: stable production table geometry plus a collapsible
teaching sheet** for the table-based lesson loop. It directly removes the
current lower-slot/table-size coupling, retains one poker-truth renderer, and
does not require a second feedback visual system.

This is an architecture and prototype specification only. It does not admit a
production migration, a canonical-route change, Human QA, or a public quality
claim.

## 2. Current source compatibility

The live runner has one active poker-table leaf: `_Act0TableV1`, reached by
`_RunnerTableStageV1` and now wrapped by the behavior-preserving public
`Act0TableSceneV1`. The runner derives table state, interaction mode, framing
profile, viewport family, and a task-cycle envelope on every build. In fixed
envelope states it subtracts the lower slot before forwarding `maxTableHeight`
to the scene. The table then uses that cap, viewport-dependent aspect rules,
and compact-bottom-clearance rules to choose its rendered bounds.

Consequently, current state transitions rebuild the runner subtree and can
resize/reframe the table; there is no alternate production table renderer.
`Act0TableSceneV1` is sufficient to render a stable full scene in an isolated
prototype without another extraction. It is not, by itself, a geometry-lock
owner: the prototype must give it one resolved config and one stable parent
constraint for the whole sequence.

The current runner composition is a `Column`, not a runner-level `Stack`.
`_Act0TableV1` has an internal `Stack` for felt-local seats, cards, pots, and
callouts; that is not an appropriate teaching-sheet owner. A bounded
runner-local wrapper can introduce a `Stack` around the stable table stage and
teaching sheet without moving either concern to the app shell.

## 3. Direction A/B/C/D decision

| Direction | Result | Reason |
| --- | --- | --- |
| A. Continue `feedbackEvidence` projections | Reject as next move | Adds a second compact visual contract before the primary continuity defect is solved. |
| B. Stable table plus collapsible sheet | **Select** | Reuses exact production scene, locks spatial evidence, and makes content pressure sheet-owned. |
| C. State-specific combination | Do not select | A narrowly declared `evidenceReceipt` may be evaluated later, but is not needed in the first stable-loop prototype. |
| D. Neither | Reject | The fixed lower-slot root cause and V2 failure provide enough evidence to test B safely. |

`informationFlow` remains separate for Welcome intro/handoff, non-table theory,
terminal, milestone, and Session Summary. An `evidenceReceipt` is optional
only outside `stableTableLesson` when a named table fact must travel without a
table; it is not a feedback replacement in this proposal.

## 4. Why V2 failed and what it means

V2 stopped because an exact-production-atom `feedbackEvidence` projection
overflowed its constrained evidence region. That is not proof that every
future evidence projection is impossible, and it did not invalidate the
behavior-preserving scene extraction. It does show a deeper product risk: a
separate evidence view creates its own fit, occlusion, hierarchy, and visual
parity contract while the current product's primary defect is already caused
by independently allocated lower space.

The failure therefore strengthens B as the next bounded experiment. It does
not authorize declaring A permanently wrong, nor does it supply candidate
screenshots or a production-pilot winner.

## 5. Task-sequence boundary

A stable-table sequence is one learner attempt identified by the source-owned
tuple:

`lessonId + beatIndex + selectedTaskId (when supplied) + canonical table-context key`.

It begins when that tuple first presents table theory or a decision and ends
only when Continue advances to a different task/beat, a route exit occurs, or
a new canonical table context is selected. Theory, decision, correct/wrong
feedback, repair, and recheck stay inside the boundary when they concern the
same attempt. A new teaching step can remain inside only if its declared table
context key is identical; otherwise it starts another sequence.

This is deliberately narrower than a whole lesson and more durable than the
current phase alone (`theory`, `drill`, `review`). Selected answer, feedback
quality, repair receipt, and sheet state must not create a new geometry key.

## 6. Table geometry-lock contract

At sequence start, resolve once:

- exact `Act0TableStateV1` base context;
- visual variant, density, outer width/height, aspect, scale, and anchor;
- seat, card, board, pot, dealer, and position coordinates;
- declared critical elements and their protected overlay line.

For every state in the sequence, render the same `Act0TableSceneV1` bounds and
the same parent alignment. Semantic emphasis may change (highlight, selected
seat feedback, correct/wrong tone, replay cue) but must not move cards, seats,
board, pot, or the table frame. The bottom sheet overlays the table rather
than reducing `maxTableHeight`.

Exact zero layout movement is feasible for a 375×812 prototype when the
sequence uses one `Act0TableStateV1`, one resolved presentation config, and
one stable `SizedBox`/alignment. Raster rounding may vary by at most 1 logical
pixel; it is not permission for a state-specific reflow.

## 7. Sheet ownership

The owner should be a new runner-local `stableTableLesson` presentation wrapper
inside `Act0LessonRunnerShellV1`'s content subtree. It owns sheet state,
sheet-safe overlay bounds, CTA placement, and the explicit View table / Show
explanation controls. The existing runner remains owner of phase, answer,
feedback quality, repair truth, W9 signal policy, telemetry, and progression.

Do not put the sheet inside `_Act0TableV1`; that would make instructional
layout a felt-renderer responsibility. Do not put it above the entire app
shell; the app shell owns navigation and hides its bottom navigation while the
play runner is active. The runner already owns the active bottom inset, so the
prototype sheet must consume that same `MediaQuery.viewPadding.bottom` source.

## 8. Sheet-state model

Select **Model 3**, constrained as a four-value deterministic presentation
state:

- `compact`: short conclusion plus one primary action;
- `standard`: title, key reason, context/evidence, deterministic CTA;
- `expanded`: user-requested detailed explanation with a body-only scroll;
- `hiddenForTable`: temporary user-requested full-table view with a persistent
  48dp handle.

Model 1 cannot distinguish ordinary feedback from a readable long repair.
Model 2 lacks the intentional full-table inspection state. Model 3 adds one
bounded view value, not a freeform drag position. A smaller model is not
sufficient because the explicit View table requirement would otherwise hide
the explanation without a recoverable control.

The state is reset to the state-owned default on each task-sequence boundary;
it is not persisted as learner preference or cross-session product state.

## 9. System-controlled versus user-controlled transitions

| Runner state | System default | User may choose | Transition rule |
| --- | --- | --- | --- |
| Table theory | `standard` | expanded, hidden | Advance changes only teaching content, not table geometry. |
| Decision / recheck | `standard` | hidden only after an answer is recorded; expanded only for an admitted hint | Options remain deterministic and CTA is the selected answer flow. |
| Correct feedback | `compact` | standard, expanded, hidden | Continue is visible in compact/standard; explanation is optional. |
| Wrong feedback | `standard` | compact, expanded, hidden | Do not auto-collapse a learner's error explanation. |
| Repair focus/result | `standard` | expanded, hidden | Long reason scrolls inside the sheet; repair result preserves the same table. |

`hiddenForTable` never means zero affordance: it leaves the persistent
`Show explanation` handle. It does not show Continue, so progression cannot
skip an intentionally hidden explanation by accident. Selecting Show
explanation restores the prior non-hidden state; a new runner state restores
its system default. V1 uses explicit buttons only—no swipe-to-dismiss or
vertical drag gesture.

## 10. View table / Show explanation contract

`View table` is visible in standard/expanded states when the full table has a
declared critical element below the sheet safe line or when a learner asks to
inspect the spatial setup. It sets `hiddenForTable`, preserves scroll position
in memory for that visit, and leaves a fixed `Show explanation` handle.

`Show explanation` restores the last non-hidden state. It never advances a
task, changes answer selection, clears replay state, or recomputes geometry.
Correct feedback may expose Continue in compact/standard; hidden view requires
Show explanation before Continue. This makes the choice reversible and
deterministic rather than an accidental overlay dismissal.

## 11. Pointer/input behavior

- The sheet intercepts pointer events only within its painted bounds; no
  full-screen dismiss backdrop is used in V1.
- Table regions outside the sheet remain tappable only for an already-admitted
  interaction: seat selection in a seat-tap decision and board taps in
  eligible showdown lessons. Static seats/cards do not gain new taps.
- The sheet never passes a tap through its own bounds to board or seat targets.
- Feedback, repair, and recheck suppress new decision taps; View table is the
  explicit way to inspect the table without a sheet.
- W9's existing table signal/callout remains table-owned. It has no separate
  sheet tap behavior and must be declared critical when it teaches the task.
- Existing replay focus remains runner-owned. Sheet state must not reset it;
  replay controls stay usable only when their visible location is outside the
  sheet or after View table.
- Accessibility order is: runner heading/progress, available interactive table
  target(s), sheet handle, sheet title/content, then primary CTA. Hidden sheet
  content is excluded from semantics; the persistent handle is not. Explicit
  semantic sort keys are required rather than relying on `Stack` paint order.

## 12. Safe-area behavior

The preview shell applies `SafeArea(bottom: !isPlayRunner)` and removes its
bottom navigation bar during the play runner. The stable-sheet layer must
therefore apply bottom protection from the runner's current
`MediaQuery.viewPadding.bottom`, including it in the sheet's CTA/footer and
never assuming the shell navigation bar is present.

The sheet is bottom-anchored within the runner's usable bounds, has no top
safe-area responsibility, and must not overlap the progress row. Keyboard or
other transient inset behavior is out of the first prototype unless the
fixture deliberately activates it; it must not silently alter table geometry.

## 13. Critical-element/occlusion contract

Every stable-table task declares a finite `criticalTableElements` set from:

`board`, `heroCards`, `pot`, `callPrice`, `activeBet`, `relevantOpponent`,
`relevantSeat`, `position`, `dealerButton`, and `tableClue`.

Always visible when present: board, hero cards, relevant seat/position, and
any task-defining price/pot. State-specific elements are active bet, relevant
opponent, dealer button, and callout. The source must also declare a normalized
safe overlay line below the lowest critical element. The standard sheet may not
cross it; compact has a stricter line. Expanded may cover only non-critical
lower felt and is always user initiated. If authored critical elements cannot
fit above the line, the task fails an authoring guard; it must split into a new
beat, use a smaller approved table context, or declare a justified receipt.

Table framing cannot shift during a sequence. A shift is visual jumping even
when scale remains constant. Duplicate `evidenceReceipt` content is justified
only outside the stable loop or after authoring rejects a required fact as
unviewable; it is not a blanket solution for long feedback.

## 14. Content authoring limits

These limits are canonical-375×812 visual-line budgets, verified from authored
metadata and localization fixtures—not post-frame text measurement:

| Content | Limit | Guard action |
| --- | --- | --- |
| Table-theory title/body | 2 title + 4 body lines | Split into another teaching beat after 4 body lines. |
| Decision question | 3 lines | Rewrite or split the decision context. |
| Answer options | 2–4 options, maximum 2 lines each | More than 4 or over-two-line choices require a two-step task. |
| Correct feedback | 2 title + 3 reason lines | Move optional detail to expanded explanation. |
| Wrong feedback | 2 title + 5 reason lines | Put deeper instruction in repair beat. |
| Repair explanation | 2 title + 8 body lines | Body-only scroll after the budget; split if it needs multiple concepts. |
| Table clue/callout | 2 lines | Split/rephrase; do not grow the table overlay. |
| CTA | one visual line, one primary action | Reject ambiguous/multi-action CTA copy. |

An authored `contentClass` and declared line-budget class must accompany each
prototype fixture. Body-only scrolling is allowed only in `expanded` repair or
explicit theory detail; headers, critical evidence summary, and CTA remain
fixed. The layout must not create an unbounded sheet to compensate for source
copy.

## 15. Scroll and pagination rules

There is one scroll region maximum: the expanded sheet body. The full runner,
table, header, sheet handle, and CTA do not scroll in the stable-table mode.
Theory and repair content exceeding the visual budget are paginated into
source-owned beats before using body scroll. Scrolling is not combined with a
collapse gesture in V1, eliminating gesture arbitration and screenshot drift.

## 16. State-by-state matrix

| State | Table | Sheet | Critical rule | CTA/input |
| --- | --- | --- | --- | --- |
| Table theory | locked | standard | declared board/seat/position stays above line | explicit Advance; optional detail expand |
| Decision | locked | standard | board, hero, price/pot, target seat visible | answer controls; only admitted table target taps |
| Correct feedback | locked | compact | selected evidence visible | Continue visible; explanation optional |
| Wrong feedback | locked, semantic wrong emphasis only | standard | preferred/selected evidence and clue visible | Continue after review; View table available |
| Repair focus | locked, declared highlight only | standard | repair target visible | body may expand/scroll |
| Repair result | locked | standard or compact if receipt fits | result evidence visible | deterministic Continue |
| Recheck | locked | standard | same task critical set remains visible | answer controls; no geometry reset |
| Hidden full-table view | locked | persistent handle | every table fact visible | Show explanation only |

## 17. Stability metrics and thresholds

Metrics are captured from original 375×812 full-screen PNGs and structural
widget bounds for every state in a sequence:

| Metric | Threshold |
| --- | --- |
| Table scale/outer width/height delta | 0 logical px; ±1 only raster rounding |
| Table top and center displacement | 0 logical px; ±1 only raster rounding |
| Board, hero-card, relevant-seat displacement | 0 logical px; ±1 only raster rounding |
| Visible critical-element ratio | 100% for compact/standard; 100% for expanded too |
| Sheet occlusion of table bounds | compact <=26%; standard <=42%; expanded <=58% and user initiated |
| Largest unexplained blank band | <=32px and <=4% of usable height |
| Sheet visible-content occupancy | >=55% excluding intentional padding/safe area |
| CTA reachability | visible without page scroll in every non-hidden state |
| Scroll regions | 0 except one expanded-body scroll region |
| Repeated-render stability | identical metrics and no overflow across 3 pumps per state |

If exact zero is not achieved, a prototype fails unless the deviation is a
documented pixel-rounding artifact within the stated tolerance. There is no
content-driven movement allowance.

## 18. Existing lower-slot retirement plan

Do not delete current lower-slot code in the prototype. The later production
migration candidate is limited to the stable-table family:

1. retire that family's use of `_RunnerTaskCycleViewportEnvelopeV1` fixed
   lower-slot reservations and `maxTableHeight` subtraction;
2. retire `coupleTableToDock` and compact lower-dock pressure as geometry
   inputs for that family;
3. retain current action/feedback/learning content owners behind a new sheet
   adapter until parity is proven;
4. leave non-stable routes, Welcome, terminal, completion, W9 signal behavior,
   safe-area helpers, and existing action dock behavior untouched.

The action dock should evolve into the teaching-sheet content adapter, not run
beside a second action surface. Its existing dock container is not reused as a
fixed slot in the prototype.

## 19. Current commit compatibility

Commit `7b5d581b` is compatible: `Act0TableSceneV1` supplies the exact table
scene needed by the prototype while preserving private runner policies.
Commit `471157f4` remains accurate: V2 had no valid candidate evidence and
does not decide this direction. Commit `2a343445` remains a local review
bundle record only. Existing feedback-clue, W9 overlay, and progress-scope
fixes remain valid and must be treated as regression constraints.

## 20. Prototype scope

One isolated, local, unpushed production-fidelity prototype only:

- exact `Act0TableSceneV1` and exact current production table visuals;
- one shared `Act0TableStateV1`, one locked presentation config, 375×812 only;
- current behavior compared with stable table plus sheet;
- sequence: decision, correct feedback, wrong feedback, repair,
  hidden/full-table view, and recheck or closest deterministic state;
- stress: short correct feedback, long repair explanation, four two-line
  options, W9 long callout, position-critical, and hero-card-critical cases.

## 21. Prototype non-scope

No canonical route change, production mode migration, table renderer rewrite,
feedbackEvidence projection, `evidenceReceipt` implementation, new gestures,
tablet/landscape support, animation, data persistence, telemetry change,
content rewrite, Human QA, public-readiness claim, or push.

## 22. Tests

The future prototype must add focused widget/prototype tests for:

- a single geometry config retained through all six states;
- exact table-anchor/critical-element bounds and sheet safe line;
- visible/blocked input paths, including View table/Show explanation;
- CTA visibility and no extra scroll region;
- W9 callout and allowed showdown/seat interactions;
- safe-area bottom padding; and
- overflow-free repeated deterministic pumps.

It must retain focused guards for existing feedback clue, W9 overlay, and
progress-scope behavior. No broad suite is required for this audit.

## 23. Evidence requirements

Required local evidence is original full-screen PNGs, one ordered contact
sheet, a safe-overlay visualization, table-anchor and critical-occlusion
tables, sheet occupancy metrics, and an interaction-state diagram. Every image
must identify its state, content class, sheet state, critical set, and viewport.
No qualitative conclusion is accepted from cropped views alone.

## 24. Risks

- A fixed table can expose source content that no longer fits the sheet; the
  authoring guard must fail rather than silently shrink the table.
- The sheet could obscure W9 or position evidence; critical metadata and the
  safe line are mandatory.
- Reusing the action dock without clear ownership could duplicate CTAs; the
  prototype needs one sheet-owned CTA.
- Freeform gestures would add focus, scroll, and screenshot nondeterminism;
  defer them.
- Public `Act0TableSceneV1` defaults do not reproduce all runner-private
  policies; the prototype must specify only admitted interactions explicitly.

## 25. Rollback

The future prototype is isolated and local. Delete its test/harness and local
output directory if it fails the metrics; do not touch production source or
the existing commits. A later production pilot, if separately admitted, rolls
back by restoring the stable-table family to the current action-dock envelope
path while retaining the scene extraction.

## 26. Exact next prototype-only prompt

```text
Sharky Poker — Stable Table Lesson Prototype v1

Continue from local HEAD 2a343445 or its direct descendant. Build only an
isolated, local/unpushed 375×812 production-fidelity prototype; do not change
the canonical Act0 route, production runner behavior, existing commits, or
remote state.

Use exact Act0TableSceneV1, one shared Act0TableStateV1, exact current table
visuals, and one resolved stable geometry config for every sequence state.
Implement a prototype-local runner wrapper with a bottom-anchored teaching
sheet owned outside the table's internal Stack. Do not implement
feedbackEvidence or evidenceReceipt.

Use deterministic sheet states compact, standard, expanded, hiddenForTable.
Use explicit View table / Show explanation controls only; no drag gestures.
Standard/compact must preserve 100% of declared critical table elements above
the safe overlay line. Expanded remains user initiated and also preserves all
critical elements. The only allowed scroll region is the expanded sheet body.

Capture current vs stable-sheet original full-screen PNGs for decision, correct
feedback, wrong feedback, repair, hidden full-table view, and recheck or the
closest deterministic state. Include short correct feedback, long repair,
four two-line options, W9 long callout, position-critical, and hero-card-
critical fixtures. Produce a contact sheet, safe-region visualization,
table-anchor metrics, occlusion/occupancy metrics, and interaction diagram in
an untracked local output directory.

Fail the prototype if table outer bounds, center, board, hero cards, or relevant
seat move by more than one raster-rounding pixel between states; if any
critical element is occluded; if CTA is unreachable; if more than one scroll
region exists; or if any overflow occurs. Do not claim a production winner.
Commit only a docs/_reviews prototype report if the evidence is valid. Run the
focused prototype tests, git diff --check, git diff --cached --check, and
graphify hook-check. Do not push.
```

## 27. Human QA/public implications

This audit and any prototype evidence are engineering/design evidence only.
They do not establish learning effectiveness, learner preference, 10/10
quality, conversion, retention, accessibility certification, or public launch
readiness. Human QA remains a separately admitted protocol after a production
candidate exists.

## 28. Non-claims

This artifact does not claim that B is implemented, that A cannot ever work,
that the V2 seam is broken, that all table lessons can share one context, or
that current production has been migrated. It selects one bounded hypothesis
for an isolated next prototype only.
