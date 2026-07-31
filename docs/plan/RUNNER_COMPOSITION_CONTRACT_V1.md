# Runner Composition Contract v1

Status: **published from merged product proof**

Product proof: PR #114, merge commit
`5530f10342cb1637480b1c4030de67c9cc88a598`.

This contract closes the T5 two-family runner architecture. It governs the
active Act0 lesson runner and does not reopen Modern Table internals, T4, T3,
F3, Human Novice evidence, or later campaign stages.

## 1. Exactly two composition families

The only production composition families are:

- `Act0RunnerCompositionFamilyV1.f1TableNative`: a source-owned table
  interaction in which the learner submits through the table.
- `Act0RunnerCompositionFamilyV1.f2AnswerList`: an answer-list interaction
  rendered below table evidence.

The merged source contains 38 F1 tasks and 329 F2 tasks. There is no F3 or F4
geometry family.

`act0RunnerCompositionFamilyForTaskIdV1` is the semantic resolver. F1
membership is explicit in `act0F1TableNativeTaskIdsV1`; all other live tasks
resolve to F2. Classification must not depend on incidental option fields,
string length, line count, or measured layout pressure.

## 2. Geometry inputs and profile allocation

`resolveAct0RunnerCompositionAllocationV1` owns every allocation number. Its
only inputs are viewport, safe area, live text scale, and the resolved
composition family. Text scale is clamped to the admitted 1.0–1.4 range.

Table/lower allocations, in logical pixels:

| Profile | Scale | F1 table/lower | F2 table/lower | F2 demand ceiling |
|---|---:|---:|---:|---:|
| compact 375 × 812 | 1.0 | 463 / 210 | 373 / 300 | 288 |
| compact 375 × 812 | 1.4 | 409 / 264 | 293 / 380 | 368 |
| canonical 402 × 874 | 1.0 | 500 / 223 | 403 / 320 | 308 |
| canonical 402 × 874 | 1.4 | 469 / 254 | 343 / 380 | 368 |
| large 430 × 932 | 1.0 | 540 / 241 | 445 / 336 | 324 |
| large 430 × 932 | 1.4 | 517 / 264 | 401 / 380 | 368 |

The demand ceiling is the corresponding F2 lower allocation less the required
12 logical-pixel headroom. It is a rendered-content ceiling, not a
character-count estimate and not another geometry constant.

The stage owns a 10 logical-pixel seam. Neither short copy nor verbose copy may
resize the accepted table.

## 3. Cycle freeze

Family and geometry resolve on task entry and remain frozen through theory,
decision, feedback, repair, recheck, and completion. A caller cannot
reclassify an active task mid-cycle. The table rectangle must be identical
between decision and feedback for the same task and profile.

## 4. Table evidence floors

F2 board evidence must retain a board-card height of at least 34 logical
pixels. The accepted native matrix rendered 43 logical-pixel board cards in
all six profile/scale rows.

F1 table hit targets must be at least 44 × 44 logical pixels. The compact 1.4
proof rendered a minimum F1 hit rectangle of 72 × 44. A hit rectangle may be
larger than its visual seat node, but it must not collide with another seat or
the board.

Visual seat nodes are a separate class from hit targets and must remain at
least 32 logical pixels. Board evidence is also a separate class; it is not
governed by tap-target sizing.

The table stage never inherits the answer-control text multiplier. A state
that cannot retain these floors is not admissible.

## 5. Copy envelope and option policy

Rendered F2 content demand must stay at or below the ceiling in the allocation
table. The composition must not absorb a copy defect by shrinking the table,
reducing type, scrolling mandatory answers, or changing family.

Prose answer tasks admit no more than three simultaneous options. Their
retained option IDs, order, meaning, misconception targets, and telemetry
identity are source contracts.

A four-option state is closed by default. A future compact four-action set may
be admitted only when all four labels are parallel actions, carry no amount
labels, remain within the source guard, and pass exact native compact 1.4
proof with:

- all four actions simultaneous;
- the applicable table evidence floor intact;
- zero answer scrolling or pagination;
- readable labels and accessible text-answer controls;
- unchanged option IDs, order, semantics, and telemetry identity.

Admission must be explicit in
`act0CompactFourActionAdmissionTaskIdsV1`. It does not create another
composition family. No live compact four-action task is currently admitted.

## 6. Accessibility classes

Accessibility has four independent owners:

| Class | Requirement |
|---|---|
| text answer controls | at least 44 logical pixels, with content allowed to grow with live type |
| table hit targets | at least 44 × 44 logical pixels; do not multiply the target by text scale |
| visual seat nodes | at least 32 logical pixels; the larger hit rectangle may remain invisible |
| board evidence | board-card height at least 34 logical pixels |

Every class also requires unclipped content, a reachable bottom interaction,
and preservation of safe areas. These requirements are conjunctive; passing
one class does not waive another.

## 7. Scrolling and pagination

Decision answers never scroll and never paginate. All options must be
simultaneously visible, with at least 12 logical pixels of lower-stage
headroom.

Theory pagination is semantic: one authored page is one teaching beat. It is
not a mechanical response to overflow and must not create an empty answer
region.

Feedback always keeps the following above the safe fold:

- outcome;
- selected or preferred answer;
- mandatory table clue;
- primary correction;
- primary CTA.

Only secondary explanation may scroll, inside a bounded region. The primary
CTA retains at least a 44 logical-pixel target and may not reserve the bottom
safe area twice.

## 8. Whitespace ownership

Whitespace must perform focus, separation, framing, pacing, or interaction
anchoring. “Reserved by the layout,” “available for longer copy,” and “stable
because it is fixed” are not acceptance arguments. Short states retain the
same geometry but must use intentional optical placement inside it.

## 9. Personalized feedback

Personalized feedback remains deterministic and rule based. It may select an
outcome, one error type, one correction, one table clue, one retry action, and
one CTA. It must not become free-form chat, invent evidence, alter table
geometry, or change the source task/option/telemetry identity.

Compact summaries may shorten a preferred-answer display only when they
preserve the source meaning and the full source option remains unchanged.

## 10. Telemetry and progression

Composition is presentation, not identity. Family selection, compact
presentation, feedback summarization, and geometry must preserve:

- world, lesson, task, and option IDs;
- expected and selected action IDs;
- attempt, repair, recheck, and progression order;
- error type, missed signal, and route source owner;
- existing event names and required fields.

The merged telemetry and progression guards are mandatory for every reopening
candidate.

## 11. Native fixtures and regression guards

The closure proof used production Flutter rendering on iOS simulators at the
exact product candidate SHA. Its evidence classification is
`NATIVE_PRODUCTION_RENDERER_INJECTED_STATE`; it is native layout proof, not
Human Novice evidence and not natural-route traversal proof.

Required native fixtures are:

- compact 1.4 F1 decision, feedback, and complete seat-tap cycle;
- compact 1.4 K84, 772, QJ5, and side-pot decisions;
- compact 1.4 longest incorrect and table-coupled feedback;
- canonical 1.4 longest ordinary F2;
- large 1.4 F1;
- one complete F2 cycle;
- representative F1 and F2 decision/feedback rows across all six
  profile/scale combinations.

Each fixture records viewport, safe area, text scale, table rectangle, lower
rectangle, applicable seat hit rectangle, board-card size, rendered content
demand, headroom, answer scroll extent, and CTA reachability.

The deterministic guard suite must assert:

- exactly two enum values and complete live-task coverage;
- 38 F1 and 329 F2 task counts;
- every allocation row in section 2 from the canonical resolver;
- F2 demand at or below the table ceiling and headroom at least 12;
- all answers simultaneous and answer scroll extent exactly zero;
- the accessibility floors in section 6;
- identical decision/feedback table rectangles;
- explicit-only compact four-action admission;
- W7 retained IDs, order, meaning, and the QJ5 plural distractor;
- exact side-pot arithmetic and production label;
- telemetry and progression preservation;
- diff, analyzer, fast-loop, release, and exact-head CI gates.

Widget/Ahem captures may guard structure but cannot replace native typography,
safe-area, wrapping, iconography, or final visual-quality proof.

## 12. Reopening conditions

This architecture may reopen only when at least one of the following is proven:

- a genuinely third interaction semantic becomes live in source;
- a shipping phone profile is narrower or shorter than the admitted compact
  profile;
- the supported live text scale exceeds 1.4;
- exact native production rendering contradicts a published evidence floor;
- an explicitly proposed four-action task passes every admission rule in
  section 5 but cannot be represented safely by either family.

A verbose string, local whitespace preference, isolated screenshot, synthetic
capture, or desire to revive T4/T3/F3 is not a reopening condition.

Any reopening requires a new bounded product proof, deterministic guards,
exact-SHA native evidence, telemetry/progression verification, exact-head CI,
and a versioned contract update. Until then, this contract is frozen.
