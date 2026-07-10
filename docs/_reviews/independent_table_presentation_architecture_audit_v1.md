# Independent Table Presentation Architecture Audit v1

Status: independent source-and-evidence audit only. No production UI, route,
content, telemetry, motion, tablet, dependency, Human QA, or screenshot change
is implemented here.

## 1. Terminal verdict

**Decision J — precisely defined hybrid.** The active Act0 path has one table
leaf (`_Act0TableV1`) and one canonical visual variant (`refinedDev2`). The
apparent large/small tables are not different widgets or fixture renderers.
They are the same semantic table inside different runner envelopes. On 375×812,
protected answer-list and repair/feedback docks reserve lower height first; the
remaining upper budget caps the table through `AspectRatio`. Other states get a
natural-width spatial table.

The compact underfill is real and is primarily **shell vertical allocation plus
top-aligned lower-dock content**, not table scaling. A fixed lower reserve keeps
options and CTAs reachable, but is selected from state/option heuristics rather
than rendered content height. Short content therefore leaves unused space.
W9's overlay collision is an independent in-table `Stack` priority issue.

Recommend a prototype-only, deterministic three-mode contract: shared poker
state/atomic table components; `decisionSpatial`, `feedbackEvidence`, and
`informationTerminal`. No production migration is admitted.

## 2. Problem statement

Compact evidence shows materially different table scale/composition and blank
lower regions. This audit reconstructs the live selection architecture before
ranking possible remedies.

## 3. Current branch and local stack

| Check | Truth |
| --- | --- |
| Branch | `main` |
| `origin/main` | `55024b4a60be5932df3dfaa2ecefc7caa6419ab5` |
| Audit start / local HEAD | `18918fca`, five commits ahead |
| Preserved local stack | `1387f3c9`, `10c3c720`, `a341868b`, `1a599a4e`, `18918fca` |
| Existing untracked files | `output/**`; left untracked and unstaged |

The supplied stack matches live ancestry. Older context capsules conflict with
this local stack, so the prompt and live source control this audit.

## 4. Evidence inspected

- `graphify query` for the runner/table/dock/tutorial graph and `graphify hook-check`.
- Active owners: `act0_lesson_runner_shell_v1.dart`, `act0_shell_state_v1.dart`,
  `act0_shell_preview_screen_v1.dart`, `act0_welcome_shell_v1.dart`, and
  `act0_shell_tokens_v1.dart`.
- Canonical route wiring: `app_root.dart`, `ui_v2_beta_shell.dart`, and
  `act0_canonical_path_root_v1.dart`.
- Literal-text 375×812 packet under
  `output/evidence/current_main_visual_evidence_fixture_trace_v1/`; source
  documents it as 2× captures (750×1624 PNGs) of logical 375×812.
- `test/ui_v2/compact_decision_lower_slot_rebalance_v1_test.dart`.

No archive runner, Modern Table, W13+, stitched image, or contact sheet was
used for active source truth. The supplied 3/6 comparison is non-canonical
context only.

## 5. Active source graph

```text
Act0 canonical entry -> Act0ShellPreviewScreenV1
  -> Act0WelcomeShellV1.demoSpot OR Act0LessonRunnerShellV1
     -> phase/task/table -> framing profile -> viewport family -> envelope
     -> _RunnerTableStageV1 -> _Act0TableV1
     -> _RunnerActionDockV1 -> learning rail | options | feedback

Welcome intro/handoff -> _WelcomeTextBeatV1 (no table)
Completion/terminal -> Act0BlockCompletionShellV1 (no runner table)
```

`_Act0TableV1` owns one felt `Stack`: seats, bets, center card, callout,
completion toast, and markers. `_RunnerTableStageV1` only forwards shared state
and constraints. There is no second active Act0 table leaf.

## 6. Exact current rendering architecture

| Layer | Current truth | Selection |
| --- | --- | --- |
| Active table renderer | **1**: `_Act0TableV1` | Every runner table state via `_RunnerTableStageV1` |
| Active visual variant | **1**: `refinedDev2` | Default in preview shell, runner, Welcome demo, and capture tool |
| Declared density values | `compactLesson`, `handView` | State default is `compactLesson`; no admitted active assignment to `handView` found |
| Effective vertical contracts | natural scroll, protected answer-list, repair/feedback | selected by runner state/viewport envelope |

Closest actual model: **G, precisely: one renderer with discrete state-specific
envelopes, one active visual variant, and an inactive code-capable density
alternative.** It is neither a continuously responsive table nor parallel
legacy/current table renderers.

## 7. Exact current table-selection decision tree

```text
phase + task family + table facts + viewport
 -> review ? feedback : drill + seat targets ? tableTap : answerList
 -> seatFocus | explicit profile | heroAction | boardHeroPot | boardOnly
 -> tableTapSeatFocus | answerListHeroAction | answerListBoardHeroPot | neutral
 -> portrait phone, <=600pt short side, usable height <=900, protected profile?
    -> tableDockPressure : none
 -> repair context? compact repair feedback? short-safe four option list?
 -> fixed lower slot OR natural-scroll stage
 -> upper budget = available - lower slot - runner chrome (if fixed)
 -> `_Act0TableV1`: refinedDev2 / compactLesson / aspect and width caps
 -> rail | prompt/options | feedback dock -> final composition
```

Exact facts behind the branches:

1. Review maps to `feedback`; drill with seat target maps to `tableTapDecision`;
   all other states map to `answerListDecision`.
2. Seat target forces `seatFocus`; explicit framing otherwise wins; task family
   decision/sizing/repair selects `heroAction`; table facts can select
   `boardHeroPot` or `boardOnly`.
3. `_compactAnswerListPressureReasonV1` never measures prompt, callout,
   feedback, or receipt height. It tests portrait, phone width, usable height,
   and a protected answer-list profile.
4. `_resolveRunnerTaskCycleViewportEnvelopeV1` then tests repair context,
   compact wrong/repair feedback, and the only content proxy: exactly four
   options, empty amount labels, and localized labels <=36 characters.
5. Fixed mode subtracts lower slot before passing `maxTableHeight`; the table
   caps width by `maxTableHeight * aspectRatio`, then lays out with `AspectRatio`.
6. Non-fixed mode makes the runner stage scrollable and puts the dock after it.

Actual content height is not measured, estimated, or used to select table size.

## 8. Active state-to-renderer matrix

| State | Owner / lower owner | Renderer / selection | Scroll and intent |
| --- | --- | --- | --- |
| Welcome intro | `_WelcomeTextBeatV1` | no poker table | full-height centered text, scroll safety |
| Welcome tutorial demo | Welcome -> runner | `_Act0TableV1`, refined, seat-focus | natural spatial table; seat recognition |
| Welcome handoff | `_WelcomeTextBeatV1` | no poker table | full-height spacers, CTA |
| W1 decision | runner prompt | same table; seat-tap or answer-list | natural or protected answer dock |
| W1 correct feedback | runner feedback | same table, feedback envelope | table may be height-capped |
| W1 wrong feedback | runner feedback | same table, compact repair feedback dock | fixed lower slot; table opacity `.68` |
| Repair focus | runner feedback + repair flags | same table, `repairFill` | fixed repair share, dock body scrolls |
| Repair result | runner feedback + receipt | same table, repair envelope | receipt/CTA lower owner |
| Open repair source | preview shell -> runner | same table, repair context | no alternate renderer |
| W7 decision | runner prompt | same table | answer-list may protect dock |
| W9 long callout | runner prompt | same table plus positioned callout | overlay collision risk is in-table |
| W12 decision | runner prompt | same table; W12 signal replaces repair callout | answer-list if pressure matches |
| W12 payoff | completion shell | no runner table | independent scrollable payoff |
| No-W13 terminal | terminal payoff/review fixture | no terminal-specific table leaf | terminal card is independent scroll UI |
| Session Summary | summary owner | no `_Act0TableV1` consumer | independent scrolling summary |
| Visually largest active table | Welcome/W1 seat focus | natural compactLesson table | full spatial seating |
| Visually smallest active table | pressured answer/feedback | same table with height cap | lower slot wins first |

## 9. Active state-to-size matrix

| Condition | Table rule | Lower rule |
| --- | --- | --- |
| Natural refined compact lesson | `326 + 48 = 374` max width, `.576` aspect | dock after expanded scroll stage |
| Protected answer list | pressure composition `.66` aspect, then height cap | normal target 405/min 365/max 54%; short-safe target 320/min 300/max 47% |
| Repair fill | shared table; safe-bottom scale may apply | target 420/min 320/max 46% |
| Compact wrong/repair feedback | shared table, receded opacity | target 320/min 280/max 44% |
| `handView` | 336 max width, `.75` aspect | declared only; no active selection found |

`compactBottomDockClearance` is safe-area scaling only (`.917` answer-list,
`.832` otherwise for qualifying compact refined states), not content-aware sizing.

## 10. Current vertical-allocation contract

The runner is a `Column`. Fixed mode gives an `Expanded/LayoutBuilder` the
available height, calculates a lower slot, gives the rest to the stage, and
places a fixed lower `SizedBox` below. Non-fixed mode gives the stage an
`Expanded` scroll view and follows it with the dock. `_RunnerActionDockV1` owns
bottom safe-area handling. There is no second scaffold or fixed global canvas.

The dock container can fill a reserved slot while its visual child is a
top-aligned `mainAxisSize.min` column. Short child plus retained reserve is the
visible void. Its `SingleChildScrollView` avoids overflow; it does not balance
the screen.

## 11. Measurement table

All figures are logical 375×812 points. PNG visual bounds are read from the
unmodified 2× individual captures (±2pt because rails/shadows anti-alias), and
source budgets are exact. The capture lane has no native notch inset; usable
height is 812pt.

| Representative state | Table top / height / bottom | Lower top / visual height | CTA bottom | Lower unused region | Why |
| --- | --- | --- | --- | --- | --- |
| Welcome demo / largest | ~46 / ~612 / ~658 | ~659 / ~139 | n/a | ~14pt (1.7%) | natural seat-focus stage |
| W9 four-option / smallest | ~46 / ~362 / ~408 | ~409 / ~235 | fixture has no CTA | ~168pt (20.7%) | short-safe protected dock is larger than body |
| W1 short correct feedback | ~46 / ~359 / ~405 | ~407 / ~298 | ~692 | ~120pt (14.8%) | compact feedback reserve caps table first |
| Long repair result | ~46 / ~446 / ~492 | ~493 / ~280 | ~762 | ~50pt (6.2%) | repair content consumes more reserve |
| No-W13 comparison table | ~46 / ~362 / ~408 | fixture-dependent | n/a | not attributable | terminal card itself is separate scroll UI |

At usable 812pt, exact reserve calculations are: normal
`min(405,max(365,.50×812)) = 405`; repair `min(420,max(320,.40×812)) = 324.8`;
compact feedback target 320; short-safe target 320. The table is sized after
those reserves, which is more authoritative than raster-edge measurement.

## 12. Root cause of lower underfill

**Root cause:** a state/heuristic-selected fixed lower allocation whose visual
child does not expand to consume it. The architecture optimizes overflow
avoidance/reachable actions rather than balanced use of spare screen height.
Table size is a downstream dependent cap, not the primary owner of the blank.

Welcome handoff is separate: `_WelcomeTextBeatV1` uses a full-height `SizedBox`
and asymmetric phone `Spacer` flexes (handoff 65 above / 20 below). It may look
underfilled, but the runner table contract does not own that space.

## 13. Whether content length affects table selection

No real content height is measured. Question, callout, feedback, and repair
receipt length are ignored. Only the narrow short-safe four-option classification
can alter a lower reservation indirectly. It is a preclassification of option
shape, not content-aware layout.

## 14. Whether overlap prevention causes underfill

Indirectly yes: protected lower slots intentionally avoid dock/table collisions
and preserve actions, then expose a void if the panel is short. W9 overlay
collision is distinct: independent `Positioned` seat/bet children,
`_CenterPotV1`, and `_TableRepairCalloutV1` compete inside `_Act0TableV1`.
Commit `10c3c720` separates the callout/center lanes but is not a general
vertical-allocation model.

## 15. Semantic table inventory

| Element | Class | Mode rule |
| --- | --- | --- |
| felt/silhouette | E | retain spatially; simplify evidence mode |
| occupied seats | A for seat/position; D otherwise | full decision, quiet feedback |
| card backs/inactive seats | D | collapse outside relevant decision |
| hero/board cards, pot, price | A when present | retain when decision/evidence depends on them |
| street, active action, bets | B | retain only when action/price truth needs them |
| blinds, stacks, identity | C | show when lesson signal needs them |
| position/dealer | A for position/order | show truthfully, avoid duplication |
| clue/callout/highlight | B/C | one priority cue lane |
| progress/receipt overlay | F on table | panel/receipt, not felt overlay |

## 16. You/position/dealer-button decision

`You` is player identity. `BTN` in `BTN Hero` is the hero's table position. The
separate `BTN` marker comes from `seat.isDealerButton` and is the dealer button.
They are distinct concepts but often duplicate the same seat in current
fixtures. Target representation: **`You · BTN`** when position matters; show a
separate dealer disc only when dealer order itself is the taught clue. Do not
render internal `Hero` to learners. Outside a position lesson, omit the
redundant dealer disc unless it changes the action.

## 17. Strategy 1–10 evaluation

Scores use requested weights: learning 20%, compact composition 20%, poker
truth 15%, clarity 10%, content adaptability 10%, maintainability 10%,
implementation/regression 10%, premium/deterministic stability 5%.

| # | Strategy | LE | CC | PT | CL | CA | MT | IR | PS | Weighted | Rationale |
| --- | --- | ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:| --- |
| 1 | Repair current constraints | 7 | 6 | 8 | 7 | 5 | 7 | 9 | 7 | 6.9 | small but implicit coupling remains |
| 2 | Continuous full table | 7 | 7 | 9 | 6 | 8 | 5 | 4 | 6 | 6.8 | adaptable but unstable screenshots/CTA pressure |
| 3 | Large/compact presets | 7 | 7 | 9 | 7 | 6 | 7 | 7 | 7 | 7.2 | deterministic but no lower-owner solution |
| 4 | Content-aware sizing | 7 | 8 | 8 | 7 | 9 | 4 | 3 | 5 | 6.7 | measurement/jump risk |
| 5 | State-aware composition | 8 | 9 | 8 | 8 | 8 | 8 | 7 | 8 | 8.1 | directly addresses root allocation |
| 6 | Semantic modes | 9 | 8 | 9 | 9 | 8 | 8 | 6 | 9 | 8.4 | strong but needs exact mapping |
| 7 | Full table + evidence view | 9 | 9 | 9 | 9 | 8 | 8 | 7 | 9 | 8.7 | best feedback clarity/truth |
| 8 | Focus-window projection | 8 | 8 | 7 | 8 | 8 | 7 | 6 | 8 | 7.6 | can hide novice context |
| 9 | Diagrammatic tutorial | 7 | 8 | 6 | 9 | 7 | 7 | 7 | 8 | 7.4 | tutorial-only answer |
| 10 | Precisely defined hybrid | 9 | 9 | 9 | 9 | 9 | 8 | 7 | 9 | **8.8** | deterministic union of 5/6/7 |

## 18. Weighted comparison table

The table above is the complete weighted comparison. #5 is the allocation-only
winner; #7 is the feedback-surface winner; #10 wins because it specifies both
without a second poker truth model or post-frame measurement.

## 19. Final recommended direction

Choose **J** with exactly three presentation modes:

1. `decisionSpatial`: shared full table with protected table/choice budget.
2. `feedbackEvidence`: same semantic state, compact evidence projection and
   feedback/receipt panel; not a duplicate renderer.
3. `informationTerminal`: no spatial table unless a specific table fact is the
   content subject; terminal/tutorial use an information card or diagram.

## 20. Target state-to-mode matrix

| State | Mode | Table requirement |
| --- | --- | --- |
| Welcome intro/handoff | informationTerminal | no table; diagram only for named fact |
| Welcome demo/W1 seat tap | decisionSpatial | full six-seat table |
| W1/W7/W9/W12 decision | decisionSpatial | full table, one priority cue lane |
| Correct/wrong feedback | feedbackEvidence | hero/board/pot/price/evidence; quiet inactive realism |
| Repair focus/result/open repair | feedbackEvidence | shared state with repair highlight |
| W12 payoff/No-W13/Summary | informationTerminal | no table by default; evidence strip if needed |

## 21. Target vertical-allocation contract

- `LayoutBuilder` budgets once per named mode before child layout.
- `decisionSpatial`: table zone 46–56% usable height; lower zone 38–48%; table
  min approximately 300×455 equivalent at 375pt, max 359pt width; lower min
  280pt/max 390pt; CTA safe-bottom anchored.
- `feedbackEvidence`: evidence zone 34–43%; lower teaching/action zone 48–58%;
  table/evidence min 250pt/max 350pt; scroll panel body only, not CTA.
- `informationTerminal`: one scrollable column, no fixed empty table zone.
- Authored fixture metadata supplies `short`, `medium`, or `long` content class.
  It selects bounded lower-zone values; it never measures raw text post-frame.
- One overlay priority is allowed in a table mode. Long panels scroll inside
  bounds rather than shrinking table unpredictably.

## 22. Recommended Flutter mechanism

| Mechanism | Verdict |
| --- | --- |
| `LayoutBuilder` plus explicit mode budget | recommend: deterministic/testable/no jump |
| `Flex`/`Expanded`/`Flexible` inside mode | recommend |
| bounded state envelopes | recommend, make current heuristic named |
| presentation enum/config | recommend |
| shared atomic components/projections | recommend |
| `CustomMultiChildLayout` | defer; only if priority overlay cannot use stack |
| slivers | terminal/information only |
| preclassified content size | recommend for fixtures |
| actual measurement/post-frame | do not recommend |
| `IntrinsicHeight` in runner | do not introduce |

## 23. Deterministic selection contract

`mode = phase/route family`, then `contentClass = authored fixture metadata`,
then `viewportBucket = compact phone`. The config owns table min/max/ratio,
lower min/max, scrolling, CTA anchor, and overlay priority. Tests assert the
configuration for every state. Raw measured text height never changes a mode.

## 24. Prototype plan

0. This audit documents current contract.
1. Build an isolated local comparison harness outside canonical routes.
2. Compare current layout with no more than two alternatives: state-aware budget
   only, and the three-mode hybrid.
3. Use one shared `Act0TableStateV1` fixture/state source.
4. Cover short, medium, and long lower content.
5. Capture deterministic 375×812 full-screen PNGs and measurement table.
6. Select one target contract.
7. Pilot one runner state family only.
8. Review before wider migration.

States: W1 four-option decision, W1 short correct feedback, long repair result,
W9 long callout, No-W13 terminal, tutorial/teaching. Keep all harness/tests/
outputs local and unpushed; delete them if no candidate wins.

## 25. Migration plan

None is authorized. A later proposal may pilot one runner family only, with a
single presentation config seam and 375×812 regression packet. It must not
migrate Welcome, completion, and terminal in the same wave.

## 26. Risks

- Reduced realism may hide a required positional clue.
- Duplicate table implementations can fork poker truth.
- Measured adaptive layout can jump and destabilize captures.
- Broad overlay work can reopen the bounded W9 lane.
- Welcome spacers can be misdiagnosed as runner table debt.

## 27. Rollback plan

Prototype: delete harness, temporary tests, and local output; retain this audit.
Any later pilot must be a bounded commit and can be reverted as one unit. Do not
rewrite, rebase, amend, drop, or reorder the existing five local commits.

## 28. Local commit compatibility

| Commit | Classification | Rationale |
| --- | --- | --- |
| `1387f3c9` feedback clue wrapping | keep and revalidate | feedbackEvidence must preserve full clue text |
| `10c3c720` W9 overlay | keep and revalidate | retain callout/center collision regression |
| `a341868b` progress scope | keep unchanged | `Step n/m` is orthogonal |
| `1a599a4e` Welcome trace | evidence only | Welcome is separate spacer owner |
| `18918fca` closure report | evidence only | audit does not reopen closed fixes |

## 29. Existing debt made obsolete

No product debt is closed here. Retired hypotheses: multiple active renderers,
active `handView` selection, raw feedback-length sizing, and fixture-only
variation.

## 30. Independent remaining debt

- W9 needs a general overlay-priority invariant if a new collision reproduces.
- Welcome spacer balance needs short/tall or native evidence.
- Native/notched safe area and Session Summary initial-scroll are evidence gaps.
- Table-context truncation is separate from the feedback clue owner.

## 31. Exact next prototype-only prompt

> Work locally and do not touch canonical routes or production UI. Create an
> isolated, unpushed table-presentation comparison harness fed by one shared
> `Act0TableStateV1` fixture/state source. At logical 375×812 compare current
> layout with exactly two candidates: (1) explicit state-aware height budgeting
> using the current full table, and (2) the three-mode hybrid in
> `docs/_reviews/independent_table_presentation_architecture_audit_v1.md`
> (`decisionSpatial`, `feedbackEvidence`, `informationTerminal`). Cover W1
> four-option decision, W1 short correct feedback, long repair result, W9 long
> callout, No-W13 terminal, and tutorial/teaching; include short, medium, and
> long lower-content fixtures. Generate local full-screen PNGs, readable contact
> sheet, and a measurement table with viewport, safe area, header, table,
> lower-panel, CTA, bottom reserve, and unused-height bounds. Assert deterministic
> config selection and CTA reachability. Do not add a production route, alter
> canonical UI, push, or migrate production code. Keep artifacts local and
> unpushed. Success: no overlap, reachable CTA, no unexplained short-state void
> above 8%, preserved poker truth, stable repeat screenshots. On failure or no
> clear winner, delete harness/tests/output and stop before migration.

## 32. Explicit non-scope

No implementation; no Modern Table redesign; no W13; no route, telemetry,
content, Sharky, motion, tablet, dependency, screenshot modification, history
rewrite, or push.

## 33. Human QA and public-gate implications

Human QA has not started. This audit and any local prototype are not Human-QA,
10/10, tablet-quality, public-readiness, or release evidence. A selected pilot
would need its own regression packet before any Human-QA baseline discussion.

## 34. Non-claims

This does not claim user validation, production readiness, terminal redesign
need, universal W9 resolution, or that the hybrid is ready to migrate. It states
live source truth and a bounded experiment plan.
