# Shared Table Presentation Seam Audit v1

Status: architecture/source-ownership audit only. No production source, route,
mode selection, screenshot output, or visual behavior changed.

## 1. Terminal verdict

**Decision G — precisely defined combination:** retain the full private runner
table, then extract a narrow internal reusable `Act0TableSceneV1` plus a small
publicly typed presentation config and independently reusable visual atoms.
Do not expose or rename `_Act0TableV1`; do not use a test-only production
factory; do not move a test into the production library. This is a V2 prototype
plan, not an admitted implementation.

The seam is justified only when a future V2 needs production-fidelity evidence.
It is not a production migration and must be introduced, if admitted, as a
one-commit, behavior-preserving source-ownership extraction first.

## 2. Branch/local stack

Branch is `main`; `origin/main` is `55024b4a60be5932df3dfaa2ecefc7caa6419ab5`.
Audit start HEAD is `15ecd437`. All seven supplied local commits remain intact.

## 3. Prototype V1 assessment

V1 was a valid isolated composition experiment: test-only code, one
`Act0TableStateV1` fixture, deterministic 375×812 repeat captures, no canonical
route change. It proved a direction, not production visual fidelity.

## 4. What V1 proved

- State-aware height budgeting can remove the fixed-slot underfill mechanism
  without post-frame content measurement.
- Full spatial presentation is best retained for decisions.
- Evidence/terminal projections are more compositionally appropriate for
  feedback/repair and information states.
- `You · BTN` avoids the current learner-facing `Hero`/BTN duplication.

## 5. What V1 did not prove

It did not render the exact private production table leaf or its complete felt,
seat, bet-chip, card, typography, shadow, overlay, and geometry behavior. Its
allocated-zone `0%` void result is not visible-content occupancy. It cannot
justify a production pilot until V2 reuses production-quality components.

## 6. Source dependency graph

```text
Act0TableStateV1 (public semantic poker state)
  -> Act0TablePresentationConfigV1 (candidate typed presentation contract)
  -> Act0TableSceneV1 (candidate internal reusable full scene)
     -> felt/rail + geometry/tokens
     -> seats + markers + bets + cards
     -> board/pot/price/context
  -> runner-only overlay/action adapter
     -> selection feedback, replay, completion toast, late-route signal,
        repair callout, tap handlers, runner viewport/framing truth
```

Current `_RunnerTableStageV1` forwards 20 inputs into `_Act0TableV1`. They
divide as follows:

| Dependency | Class | Boundary |
| --- | --- | --- |
| `Act0TableStateV1`, cards, seats, pot/price, action trail | semantic poker state | retain public/current |
| tokens, felt, slots, card/seat/bet/marker widgets | pure table presentation | extract behind scene/atoms |
| `visualVariant`, size/max height, compact clearance | table presentation/geometry | typed config |
| highlight IDs, selected seat, focus resolution | runner presentation | adapter input; keep policy private |
| replay active seat/bet, board tap, seat tap | runner interaction | runner-only adapter |
| repair callout, late-route signal, completion toast | feedback/repair/route presentation | overlay policy; runner remains owner |
| viewport/framing/private interaction enums | runner presentation | do not expose directly |
| screenshot fixture builders | test fixture only | remain test-side |

## 7. Why `_Act0TableV1` is private

The underscore is a Dart library-private boundary, not merely style. The widget
depends on private `_RunnerInteractionModeV1`, `_RunnerViewportFamilyV1`,
`_SeatSelectionFeedbackStateV1`, focus-resolution helpers, slot helpers,
private card/seat/marker/bet widgets, `_CenterPotV1`, `_TableRepairCalloutV1`,
and runner completion overlay types. Simply renaming it would force at least
these private types and helper policies across an external API boundary, expose
a large constructor, and make the runner's current layout decisions a public
contract. That is unstable and unsafe.

No useful existing public scene-level widget was found. `Act0TableStateV1` is
already public and is the correct shared semantic source. The only `part`
relationship found is unrelated localization copy; the runner file has no
library/part seam suitable for external test access.

## 8. Candidate extraction boundaries

The correct cut is below runner policy and above visual atoms:

- scene owns exact full oval composition, tokens, geometry, seats, cards,
  board, bet markers, center stat cluster, and marker placement;
- adapter owns runner-derived interaction/selection/overlay policy;
- feedback evidence consumes scene-provided atoms or a scene projection, not a
  recreated table-state engine;
- terminal remains independent unless it explicitly needs evidence.

## 9. Seam A–G evaluation

| Seam | Verdict | Reason |
| --- | --- | --- |
| A public full table | reject | exposes private enums/helpers and unstable 20-input API |
| B internal `Act0TableSceneV1` | adopt as part of G | clean visual owner, exact fidelity, runner policy stays outside |
| C shared atoms only | insufficient alone | good for feedback, but cannot prove exact full decision scene |
| D adapter around private table | insufficient alone | preserves privacy but cannot give external V2 exact visual reuse |
| E test-only factory | reject | ships a special API and hides production coupling rather than clarifying it |
| F same-library test harness | reject | standalone tests cannot access another Dart library's private names; making test a part requires production-library wiring and worsens ownership |
| G scene + typed config + atom projection | **choose** | minimum reusable production-fidelity boundary with no broad public API |

## 10. Chosen seam

Create, only after a later explicit implementation prompt:

1. `Act0TablePresentationConfigV1`: public/reusable data-only config with
   geometry budget, visual variant, identity policy, and an overlay policy that
   does not mention runner-private enums.
2. `Act0TableSceneV1`: internal Act0-shell reusable widget receiving canonical
   table state plus that config and typed callbacks.
3. a small atom/projection surface for feedback evidence (`board`, `hero cards`,
   `pot/price`, relevant identity, cue/highlight), assembled from exact visual
   atoms—not a new semantic renderer.
4. a private runner adapter that maps existing private state to the config.

`Act0TableSceneV1` may be exported only from the Act0-shell package boundary if
V2 requires it; its helper children remain private. That is narrower than a
public `_Act0TableV1` replacement.

## 11. Proposed ownership diagram

```text
Act0LessonRunnerShellV1
  -> private runner adapter (existing policies retained)
     -> Act0TableSceneV1
        -> private visual atoms

V2 prototype test
  -> same Act0TableStateV1 fixture
  -> Act0TableSceneV1 decision config
  -> evidence projection composed from approved atoms/config
```

## 12. Proposed file map

Proposed only, not created:

- `lib/ui_v2/act0_shell/act0_table_presentation_config_v1.dart`
- `lib/ui_v2/act0_shell/act0_table_scene_v1.dart`
- `lib/ui_v2/act0_shell/act0_table_evidence_projection_v1.dart`
- keep runner-specific adapter/private overlays in
  `act0_lesson_runner_shell_v1.dart`
- `test/prototypes/table_presentation_contract_v2_test.dart`

## 13. `decisionSpatial` ownership

Runner keeps task, viewport, interaction, W9 overlay policy, and dock ownership.
It passes shared state plus an exact full-scene config into `Act0TableSceneV1`.
The V2 decision candidate uses that exact scene unchanged inside an isolated
height-budget wrapper. This preserves current W9 fix and avoids duplicate table
rendering.

## 14. `feedbackEvidence` ownership

Feedback/repair keeps clue wrapping, receipt semantics, and CTA policy in the
existing feedback owner. A reusable evidence projection receives the same
`Act0TableStateV1` and an explicit relevant-element config. It uses production
card/board/pot/identity/cue visual atoms but omits irrelevant perimeter realism.
No new hand/action/repair derivation is allowed.

## 15. `informationTerminal` ownership

Terminal/Welcome/Summary remain table-free by default. Their own shells own
scrolling, progression truth, and CTA. A small evidence strip is optional only
when one table fact is necessary; it must use the shared atom projection, never
the full scene by default.

## 16. Visible-occupancy metric

V2 must distinguish four layers:

1. **allocated zone**: layout rect reserved for table/evidence/lower content;
2. **visible bounds**: union of non-background visual card/content/control
   rects, keyed by test-only measurement anchors;
3. **intentional breathing room**: declared symmetric or hierarchy-driven gap;
4. **unexplained blank canvas**: remaining maximal background-connected area
   after subtracting visible bounds and declared breathing room.

Record allocated lower height, visible-content height, CTA bounds, top/bottom
internal padding, largest blank rectangle, visible occupancy ratio, unexplained
blank ratio, visual-mass vertical center, table-panel gap, and panel-CTA gap.

## 17. Target metric thresholds

- unexplained blank ratio <=8% usable viewport;
- visible-content occupancy >=72% of a reserved lower zone;
- no one unexplained blank band >12% usable viewport;
- CTA safe-bottom margin 12–24pt;
- table/panel separation 8–20pt;
- breathing room must be symmetric or explicitly hierarchy-driven.

For deterministic widget tests, robust metrics are keyed `RenderBox` bounds,
declared gap budgets, and a background-color connected-component raster pass
with a documented tolerance. Do not use OCR or raw text height.

## 18. Production-quality prototype V2 plan

After an explicit seam-extraction approval, create a local V2 test harness that
uses exact scene rendering for decisions, exact visual atoms for evidence, and a
table-free information mode. Compare current, state-budget, and three-mode at
375×812 with one `Act0TableStateV1` per state. Measure the visible-occupancy
contract above and capture original PNGs only locally.

## 19. Exact V2 scope

W1 four-option decision; W1 short correct feedback; long repair result; W9 long
callout; No-W13; current Welcome tutorial fixture. Check felt, cards, seats,
chips, board, pot, cue, typography, borders/shadows, identity, and spacing
tokens. Test deterministic selection, no overlay collision, no clipping,
reachable CTA, and visible occupancy.

## 20. Exact V2 non-scope

No canonical route, production migration, W13, telemetry, content, Sharky,
motion, tablet, dependency, Modern Table, or broad visual redesign.

## 21. Tests

V2 focused widget/capture test; repeated-render byte check; config-selection
unit test; focused visual-atom/identity test; existing W9 and feedback clue
tests revalidated. No broad suite by default.

## 22. Evidence

Local-only root: `output/prototypes/table_presentation_contract_v2/`; original
PNGs, JSON metric rows, and contact sheets are untracked. V1 remains local
evidence only and is not overwritten as release evidence.

## 23. Stop conditions

Stop if scene extraction changes production output, requires public runner
enums, duplicates poker logic, adds a route/debug API, requires post-frame
measurement, makes captures unstable, or fails visible-occupancy thresholds.

## 24. Local commit compatibility

| Commit | Status |
| --- | --- |
| `1387f3c9` feedback clue | keep and revalidate in evidence mode |
| `10c3c720` W9 overlay | keep and revalidate in exact decision scene |
| `a341868b` progress scope | keep unchanged; runner-only |
| `15ecd437` V1 prototype | prototype-only evidence; retained as limitation record |

## 25. Risks

Prematurely exporting the full table would fossilize runner coupling. Extracting
atoms without a scene could drift decision geometry. Treating allocated space as
visible occupancy can falsely pass a visually empty panel. Test-only APIs and
part-file access can create hidden shipping contracts.

## 26. Rollback/deletion

This audit is one docs commit. A future extraction must be one reversible seam
commit, separately from V2 harness code. Delete V2 test/output if it does not
select a safe direction; do not alter the existing stack.

## 27. Exact next prototype-V2 prompt

> Audit-first, then make one reversible, behavior-preserving source-ownership
> extraction only if existing W9 and feedback-clue tests remain green: introduce
> a narrow `Act0TablePresentationConfigV1` and internal `Act0TableSceneV1` that
> preserve the exact current decision scene while keeping runner interaction,
> viewport enums, repair/late-route overlays, and completion policy private.
> Add an exact-atom feedback evidence projection with no new poker state. Build
> a local-only V2 harness outside canonical routes at 375×812 comparing current,
> state-budget, and three-mode across W1 decision/correct feedback, long repair,
> W9, No-W13, and current Welcome tutorial. Capture local originals and measure
> visible occupancy, declared breathing room, largest blank band, clipping,
> overlap, CTA reachability, and repeated-render stability. Stop before any
> production state-family migration; delete the harness/output if the seam
> changes current rendering or no candidate passes the thresholds.

## 28. Human QA/public implications

No Human QA, public-readiness, 10/10, tablet-quality, or learning-effect claim
is made. V2 would be local engineering evidence only.

## 29. Non-claims

This does not approve extraction, a public API, V2 implementation, or a product
pilot. It defines the smallest source boundary worth testing after explicit
approval.
