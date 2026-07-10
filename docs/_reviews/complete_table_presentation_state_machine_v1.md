# Complete Table Presentation State Machine and Theory Geometry Reassessment v1

## 1. Terminal verdict

Select **target system C**:

- one locked spatial-theory geometry (`T2`);
- one locked full task-loop geometry for decision through recheck;
- one table-free information flow (`T3`) for concepts that do not require live
  table reading.

`T2` is the default for table-based theory, subject to the isolated comparison
prototype specified below. `T3` is a necessary separate family, not a
competitor that replaces spatial theory. `T1` is not a third shipped geometry;
it remains the comparison baseline and a fallback only if T2 fails its
readability/continuity metrics.

No production UI, prototype, route change, or public claim is admitted here.

## 2. Current source truth

The active production renderer is still one `_Act0TableV1`, wrapped by
`Act0TableSceneV1`. The scene can render both theory and decision bounds
without duplicating the renderer: `Act0TablePresentationConfigV1` already
accepts `maxTableHeight` and presentation booleans, and the scene receives one
canonical `Act0TableStateV1`.

Today, geometry is not a named presentation family. The runner recalculates
framing profile, viewport family, lower-slot envelope, compact clearance, and
`maxTableHeight` during build. `Act0TeachingStepV1` can supply an alternate
table and focus IDs, while `_teachingTable` preserves/derives source context.
It has no geometry or table-context-boundary field. The runner's present
state is `theory`, `drill`, or `review`; its teaching steps advance by index.

Critically, current `onContinueTheory` advances a teaching step and, after the
last one, completes/advances the task. It does **not** express a same-task
theory→practice geometry event. A future prototype must add that event as
explicit fixture/presentation metadata, never infer it from rebuild, content,
or text size.

The play shell removes bottom navigation while the runner is active and gives
the runner the active safe-bottom responsibility. Existing compact evidence
shows a large readable production table with a lower prompt panel; it does not
establish a table-theory winner. The named `Table Continuity Review.pdf` and
the user-supplied table-theory screenshot were not present as readable local
files in this workspace/chat, so no finding below is attributed to either.

## 3. Why theory needs separate analysis

The task loop needs zero geometry motion because it is one attempt: decision,
feedback, repair, View table, repair result, and recheck all preserve spatial
memory. Theory has a different job: introduce one named clue with compact
copy, then hand the learner into an active decision. It can therefore use one
deliberate geometry transition at a pedagogical boundary without making
feedback/correctness/content length into geometry inputs.

The current stable-table audit correctly rejected lower-slot-driven resize in
the task loop; it did not yet compare whether a theory-only spatial preset
creates a better text/table balance than a full task-loop table.

## 4. T1/T2/T3 comparison

| Strategy | Strength | Main limitation | Result |
| --- | --- | --- | --- |
| T1: full spatial table + minimal theory panel | Maximum immediate continuity with later decision geometry | At 375×812 it leaves the least room for a 3–4 line, no-scroll theory beat without overlay or a cramped panel | Baseline only |
| T2: raised compact theory table + panel below | Gives deliberate, stable theory copy space while retaining full production table semantics | Adds one explicit geometry and one transition that must be source-declared and measured | **Default spatial theory** |
| T3: information/diagram theory | Best for abstract/non-spatial concepts, long explanatory framing, terminal-style information | Cannot teach a learner to locate live cards/seats/pot/position | Required table-free family only |

T2 means one fixed preset across a whole spatial-theory sequence, not a
content-aware smaller table. The prototype investigates 90–92% of full
task-loop scale, raised by a fixed 12–20 logical pixels. It must reject any
value below 88% or any value at which labels/cards/seat identity become
unreadable. The range is a test budget, not accepted production token truth.

## 5. Weighted score table

Scores are 1–10 and are a source-and-contract assessment pending visual
prototype evidence. Weights total 100. T3 is scored for applicable
information concepts, not as a spatial-theory replacement.

| Criterion (weight) | T1 | T2 | T3 |
| --- | ---: | ---: | ---: |
| Learning clarity (18) | 8 | 9 | 7 |
| Spatial continuity (15) | 10 | 8 | 2 |
| Table readability (14) | 10 | 8 | 2 |
| Text capacity (12) | 5 | 9 | 10 |
| Compact composition (10) | 6 | 9 | 9 |
| Premium perception (7) | 8 | 9 | 8 |
| Deterministic stability (8) | 9 | 9 | 10 |
| Implementation complexity (5) | 9 | 6 | 9 |
| Regression risk (4) | 9 | 7 | 9 |
| Localization resilience (4) | 5 | 9 | 10 |
| Transition complexity (1) | 10 | 6 | 10 |
| Reuse of production scene (2) | 10 | 9 | 8 |
| **Weighted total** | **8.13** | **8.45** | **6.77** |

T2 wins the spatial-theory comparison because its deliberate, fixed geometry
solves the text-capacity constraint without introducing content-driven motion.
T3 is selected by concept class, not by its aggregate score.

## 6. Recommended theory strategy

Use T2 for theory that requires the learner to read a live table: table scan,
hero cards, board, pot/call price, seat/position, dealer order, active bet,
or a relationship among those elements. Use T3 for vocabulary, rule framing,
history, mental model, recap prose without a live-table reference, terminal,
milestone, and Session Summary.

One T2 preset serves all spatial theory. A different taught element changes
only the canonical table state and one principal highlight; it does not create
another theory geometry. T1 is not selected as an authored exception, avoiding
two competing spatial-theory systems.

## 7. Complete state machine

Abbreviations: `S-T` = locked spatial-theory geometry; `F-L` = locked full
task-loop geometry; `I` = table-free information flow; `std`, `cmp`, `exp`,
and `peek` are standard, compact, expanded, and hidden-for-table sheet states.
All spatial rows require declared critical elements above the overlay safe line.

| Learner state | Family / geometry | Panel or sheet | Critical elements / occlusion | CTA, scroll, return |
| --- | --- | --- | --- | --- |
| Welcome intro | I | intro content | none | Next; own scroll policy; resume same welcome beat |
| Welcome spatial tutorial | F-L | decision prompt | hero seat, position, board/pot when taught; no critical occlusion | tap/Continue; resume demo state |
| Table theory beat | S-T | content-sized no-scroll theory panel | declared one principal clue | Next; restore theory beat + S-T |
| Theory recap | S-T or I | no-scroll recap panel | multiple already-taught elements only when spatial | Next; restore recap state |
| Long non-table theory | I | paginated information panel | none or small diagram | Next; pagination only, no table |
| Theory → decision | explicit S-T→F-L boundary | theory panel exits, then decision sheet appears | same context is recognizably preserved | static step first; focus to decision heading |
| Decision, 2 answers | F-L | `std` sheet | task board/hero/price/seat | answer; no scroll; resume task + F-L |
| Decision, 4 answers | F-L | `std` sheet | same declared set | answer; no scroll; no geometry response to count |
| Long-question stress | F-L | `std` sheet, authored split if >3 lines | same declared set | answer; no scroll; fail authoring instead of resize |
| Correct feedback | F-L | `cmp`, expandable | selected/principal evidence | Continue; no scroll until explicit `exp` |
| Wrong feedback | F-L | `std`, expandable | preferred/selected clue | Continue after review; body only in `exp` |
| Repair focus | F-L | `std` | repair target, board/hero/seat as declared | repair CTA; body-only expanded scroll |
| Repair detail | F-L | `std` or user `exp` | all repair-critical evidence | Continue; one body scroll maximum |
| View table / Peek | F-L | `peek` persistent handle | all table facts visible | Show explanation; no progression control |
| Show explanation | F-L | restores prior `cmp`/`std`/`exp` | original critical set | same CTA and scroll state |
| Repair result | F-L | `std` or `cmp` when receipt fits | result/target evidence | Continue; no layout movement |
| Recheck | F-L | `std` | original/recheck critical set | answer; no scroll |
| W9 callout stress | F-L | `std` | W9 callout plus task evidence | no callout occlusion; answer/Continue |
| Position-critical | S-T or F-L by phase | theory panel or sheet | hero, position, relevant seat, dealer when order matters | phase CTA; no overlap |
| Hero-card-critical | S-T or F-L by phase | theory panel or sheet | hero cards, board if comparison requires it | phase CTA; no overlap |
| Terminal / no-W13 | I | terminal content | no table by default | terminal CTA; own scroll |
| Milestone | I | payoff card | no table by default | forward CTA; own scroll |
| Session Summary | I | summary | receipt/evidence strip only if named | navigation CTA; own scroll |
| Resume / return | restore persisted family + boundary key | restore beat/sheet state only if same sequence | revalidate source critical set | continue at source-owned beat/task |
| Route exit | leave current family | none | no retained overlay | route navigation; clear ephemeral sheet state |
| New-hand transition | explicit new F-L or S-T sequence | default panel/sheet | new declared context | no visual continuity claim across hands |

## 8. Geometry transition rules

Geometry changes are allowed only at these named events:

1. entering a spatial-theory sequence: select S-T once;
2. leaving its final theory/recap beat for the first active decision of the
   same declared table context: one S-T→F-L transition;
3. loading a genuinely different `tableContextKey`: select geometry for the
   new sequence;
4. leaving spatial work for I terminal/information flow or route exit.

They are forbidden for text length, answer count, localization, sheet height,
feedback quality, correctness, repair, recheck, replay focus, and View table.
The state machine owner must reject an unrecognized transition rather than
quietly recomputing dimensions.

## 9. Theory → practice boundary

The future source event is `presentationBoundary: theoryToPractice`, emitted
only when the last declared S-T beat hands the same `tableContextKey` to the
first F-L decision. It is not the generic current `_advanceTeachingStep` call,
which merely increments an index and can complete a theory-only task.

Static behavior is mandatory: theory panel leaves, F-L resolves, then decision
sheet appears. The table may change center/scale once at this boundary, but its
card/seat identities must remain recognizably the same where the context is
shared. For a later motion-only wave, use a stepped transform lasting at most
220ms, respect reduced motion by rendering the static destination, and move
accessibility focus only after the destination decision heading is available.
No motion is implemented or required here.

## 10. Task-loop geometry lock

F-L is selected when active practice starts and stays byte/metric stable
through decision, all feedback, repair, peek, result, and recheck. Its table
outer bounds, scale, anchor, seat slots, board, hero cards, pot, and relevant
seat have a zero-logical-pixel target, with ±1px raster rounding tolerance.
The sheet overlays rather than sets `maxTableHeight` or changes aspect ratio.

## 11. Sheet/panel mapping

S-T uses a short, content-sized theory panel immediately below the raised table:
eyebrow, title/instruction, body, and control row. It is not a reserved lower
slot, never scrolls, and its height is bounded by authored line class.

F-L uses the runner-local teaching sheet from the stable-table audit:
`std` for decisions/wrong/repair, `cmp` for short correct feedback, `exp` only
by explicit user choice, and `peek` for View table. I uses its owning
information shell, not the task-loop sheet.

## 12. Critical-element mapping

| Concept class | Required table elements |
| --- | --- |
| Table scan / orientation | hero seat, relevant seats, position, dealer only if order matters |
| Hole cards / hand strength | hero cards; board when comparison needs it |
| Board / street | board, street, hero cards when relation is taught |
| Pot / price / action | pot, call price, active bet, relevant opponent/seat |
| Position / blinds | hero, relevant seat, position, dealer button, blinds/active bet as needed |
| W9 pressure | W9 callout plus the named decision facts; no fabricated price lesson |
| Abstract terms / recap prose | I by default; diagram/evidence strip only when useful |

Every spatial beat declares its set and normalized safe overlay line. A sheet
or theory panel may cover no declared critical element. Multiple highlights are
allowed only in recap; an ordinary theory beat has one principal highlight.

## 13. Content limits

Table theory has: eyebrow 1 line, title/instruction maximum 2, body maximum
3–4, one principal idea, one primary highlight, and a visible CTA/control row.
It has no scroll. A spatial recap may show multiple already-taught elements but
uses the same copy budget. Overflow creates another authored beat; it never
changes S-T scale or panel/table allocation.

F-L limits remain: decision question maximum 3 lines; 2–4 options at maximum
2 lines each; correct feedback 2 title + 3 reason lines; wrong feedback 2 + 5;
repair 2 + 8 before expanded body scroll; clue maximum 2; CTA one visual line.

## 14. Scroll/pagination rules

S-T and T1 comparison panels have zero scroll regions. I may use its own
information-scroll policy. F-L has zero scroll regions except the one
user-opened expanded sheet body. Theory/repair content beyond its line contract
is paginated into authored beats, not made to resize a table or reveal a second
scroll surface.

## 15. Resume/return behavior

Persist/restore only source-owned route/task/beat identity, phase,
`tableContextKey`, selected answer/review state, and the presentation family
required by that key. Restore S-T with its locked theory beat; restore F-L with
its locked task-loop geometry. Ephemeral `exp` scroll offset and `peek` are
not durable learner progress: on process resume they reset to the state default
to avoid reopening hidden explanation or stale focus. If source context changed,
discard the presentation snapshot and resolve a new boundary.

## 16. New-hand behavior

A new hand/table context is a required boundary, identified by a different
declared `tableContextKey`, not merely changed copy. It may choose S-T before
a new theory sequence or F-L before a new active task. It resets highlights,
sheet state, replay focus, and spatial metric baseline. No continuity claim is
made across genuinely different hands.

## 17. Terminal/information behavior

Welcome intro/handoff, long non-table theory, terminal/no-W13, milestone, and
Session Summary use I and stay table-free by default. A small diagram or
evidence strip can be source-owned when it teaches one named fact, but must not
become a second compact poker renderer. The Welcome spatial tutorial is an
active F-L micro-decision, not a reason to give its intro/handoff a table.

## 18. Source owner and config proposal

Do not implement in this audit. The future narrow seam is:

```text
runner phase + task metadata + teaching step + tableContextKey
  -> pure Act0TablePresentationResolverV1
  -> Act0TablePresentationFamilyV1 { information, spatialTheory, taskLoop }
  -> typed Act0TableGeometryPresetV1 { theorySpatial, taskLoopFull }
  -> Act0TablePresentationConfigV1 + runner-local panel/sheet wrapper
  -> Act0TableSceneV1
```

The resolver is the state-machine owner. `Act0TableSceneV1` remains visual
scene owner; it should receive typed fixed geometry/config, not decide phase
or infer content. `Act0TeachingStepV1`/task metadata needs a future
`tableContextKey`, presentation family declaration, critical element set, and
explicit boundary marker. The public config needs typed geometry preset fields
instead of a collection of booleans or raw per-state heights.

## 19. Deterministic fixture contract

Every future fixture supplies: viewport `375x812`, language, table context key,
presentation family, geometry preset, named boundary event, authored line
class, critical elements, safe overlay line, phase, answer count, feedback
quality, and sheet/panel state. Fixture selection must not inspect rendered
text height, locale width, or post-frame bounds to choose a geometry.

## 20. Prototype comparison scope

The next isolated prototype compares T1 and T2 only for the same shared
`Act0TableStateV1` and short spatial-theory beat. It then proves the selected
T2 S-T→F-L boundary and locked F-L sequence. T3 is represented only by an
existing table-free information fixture; it needs no second poker renderer.
The existing stable-sheet task-loop comparison remains required.

## 21. Required screenshots

Local, unpushed originals at 375×812:

1. T1 and T2 for a 3–4 line spatial theory beat;
2. T2 first/last theory beat with identical S-T metrics;
3. static theory→decision destination pair;
4. locked F-L sequence: decision, correct, wrong, repair, peek, repair result,
   recheck;
5. four two-line options, long-question authoring rejection/split evidence,
   W9 callout, position-critical, hero-card-critical, and localized long-copy
   fixture;
6. contact sheet, safe-overlay visualization, anchor/occlusion/occupancy
   tables, and state-transition diagram.

The missing owner PDF/screenshot must be attached or otherwise made available
before any claim that the prototype reproduces its theory composition.

## 22. Metrics and thresholds

| Metric | Threshold |
| --- | --- |
| S-T scale | prototype target 90–92% of F-L; reject below 88% |
| S-T beat-to-beat movement | 0 logical px; ±1px raster only |
| F-L state-to-state movement | 0 logical px; ±1px raster only |
| T2 header/progress clearance | >=12 logical px between progress region and table rim |
| Critical element visibility | 100% in every spatial state |
| Theory panel | no overflow, no scroll, CTA fully visible |
| Largest unexplained blank band | <=32px and <=4% usable height |
| F-L sheet occlusion | compact <=26%, standard <=42%, expanded <=58% only user initiated |
| Sheet occupancy | >=55% excluding safe area/padding |
| CTA / scroll | reachable without page scroll; max one expanded-body scroll |
| Determinism | identical bounds/metrics across three pumps per fixture |

T2 fails if it makes production cards, labels, pot, or seats materially less
readable than T1 at 375×812, crowds the progress row, or requires text-driven
size changes.

## 23. Risks

- T2 can feel miniature or gratuitous if the scale reduction does not buy
  meaningful no-scroll theory capacity; the comparison must disprove that.
- A generic phase-only resolver could apply S-T to a non-spatial theory task;
  family metadata is mandatory.
- The current lifecycle lacks a same-task theory→practice event; implementers
  must not simulate one from `setState` timing.
- Localized copy can exceed authored lines; guard/copy split is required.
- Adding multiple spatial-theory presets would recreate the current
  unpredictability under a new name.

## 24. Mode-proliferation guard

The maximum system is exactly three families and two table geometries:

1. `information` / no full table;
2. `spatialTheory` / one S-T preset;
3. `taskLoop` / one F-L preset.

No per-world, content-length, answer-count, feedback-type, localization, or
device-specific spatial geometry is allowed in this model. A proposed new
family requires evidence that it cannot be expressed by these three and a
separate architecture audit.

## 25. Existing commit compatibility

`7b5d581b` remains the enabling scene extraction: it permits exact table reuse
without duplicating renderer atoms. `471157f4` remains a stopped evidence
projection report and does not conflict. `39dbfa24` remains authoritative for
the task-loop geometry lock, runner-local sheet ownership, input, occlusion,
and content contracts; this document narrows only the previously unexamined
theory boundary. Existing feedback clue, W9 overlay, and progress-scope fixes
remain unchanged regression constraints.

## 26. Exact updated prototype-only prompt

```text
Sharky Poker - Theory Geometry and Stable Task-Loop Prototype v1

Continue from local HEAD 39dbfa24 or a direct descendant. Build only an
isolated, local/unpushed 375x812 production-fidelity prototype. Do not alter
canonical Act0 routing, production runner behavior, existing commits, or
remote state.

Use exact Act0TableSceneV1, exact current visual atoms, and one shared
Act0TableStateV1 per comparison. Implement only fixture-local typed
presentation metadata: information, spatialTheory, taskLoop; theorySpatial
and taskLoopFull geometry presets; a tableContextKey; critical elements; safe
overlay line; and explicit theoryToPractice boundary. Do not infer a boundary
from text, rebuild timing, answer count, localization, or sheet height.

Compare T1 full-table theory with T2 raised spatial theory at 90%, 91%, and
92% of the full task-loop scale. Do not test below 88%. Use a 3-4 line,
no-scroll theory beat and reject any configuration that crowds progress,
clips/obscures critical evidence, or makes cards/seats/pot labels less
readable. Select no winner unless metrics prove it.

Then render the selected theory geometry across first and last theory beats,
perform one static theoryToPractice transition to taskLoopFull, and hold that
full geometry exactly through decision, correct feedback, wrong feedback,
repair, View table/Show explanation, repair result, and recheck. The task-loop
sheet is runner-local; use explicit controls only and no drag gestures. Do not
implement feedbackEvidence, evidenceReceipt, motion, persistence, or a
production migration.

Capture local original PNGs, contact sheets, safe-overlay visualization,
geometry/anchor/occlusion/occupancy metrics, readability notes, and an
interaction/state diagram. Include four two-line options, W9 callout,
position-critical, hero-card-critical, long localized copy, and authoring
split/rejection cases. Fail on any overflow, hidden critical element, table
movement beyond +-1 raster pixel inside S-T or F-L, unreachable CTA, more than
one scroll region, or content-driven geometry change.

Commit only a prototype report if valid evidence exists. Run focused prototype
tests, git diff --check, git diff --cached --check, and graphify hook-check.
Do not push.
```

## 27. Human QA/public non-claims

This source/spec assessment does not claim visual acceptance, learner
preference, reading speed, accessibility certification, learning effectiveness,
retention, 10/10 quality, or launch readiness. No Human QA was run. The T2
recommendation is conditional on local prototype evidence and the missing
owner visual authorities being available for comparison.
