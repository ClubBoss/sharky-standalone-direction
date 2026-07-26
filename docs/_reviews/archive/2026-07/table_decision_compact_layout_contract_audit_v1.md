---
status: "undeclared"
status_source: "absent"
baseline: "aa0f8d241ff4"
generated_by: "docs_frontmatter_v1"
---

# Table Decision Compact Layout Contract Audit v1

Terminal verdict: `compact_portrait_table_decision_allocation_contract_mapped_repair_wave_ready`

## Scope and audit basis

- Audit only. No product source, test, capture-tool, route, telemetry, or asset
  change was made.
- Branch / HEAD inspected: `claude/hub-surface-coherence-audit-plan-v1` /
  `aa0f8d241ff4f353da14335d03d54a008e1d84a9`.
- Canonical visual target: compact phone portrait (`375 x 812` in the active
  W7-W12 capture lane). Tablet is outside this conclusion.
- Source files inspected:
  - `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_shell_tokens_v1.dart`
  - `tools/act0_real_text_surface_capture_v1.dart`
  - `test/ui_v2/act0_w11_w12_late_route_table_signal_differentiation_v1_test.dart`
  - `test/guards/final_pre_qa_layout_and_proof_repair_contract_test.dart`
  - `test/ui_v2/act0_shell_preview_screen_v1_legacy_backlog.dart` (existing
    compact-layout contract coverage; not newly changed)
- Evidence/review files inspected:
  - `docs/_reviews/w11_w12_late_route_table_signal_differentiation_v1.md`
  - `docs/_reviews/act0_shell_preview_contract_split_compact_runner_geometry_navigation_v1h.md`
  - `docs/_reviews/final_pre_qa_layout_and_proof_repair_v1.md`

## Layout ownership map

| Region | Source owner | Contract |
| --- | --- | --- |
| Top progress/navigation | `_RunnerProgressV1` in `Act0LessonRunnerShellV1` | Intrinsic row inside the upper runner stage; its 34 px budget is included in `_runnerUpperStageChromeHeightV1`. |
| Optional phase/instruction chrome | `buildRunnerStage` / `_RunnerInstructionSlotV1` / `_CoachCardV1` | Sits above the table; its fixed/known height is subtracted before the table max-height is calculated. |
| Table allocation | `runnerScreen` fixed-envelope branch, then `_RunnerTableStageV1` and `_Act0TableV1` | The root owns the height split; `_Act0TableV1` converts its permitted height into a width-constrained `AspectRatio` table. |
| Felt, board/cards, seats, chips | `_Act0TableV1`, `_CenterPotV1`, `_SeatPlacementV1`, `_BetChipPlacementV1` | All are descendants of the single aspect-ratio table canvas. The felt is `Positioned.fill`; board/pot/status are centred; seats/chips use the table `LayoutBuilder` width/height slots. |
| Pot/status/street | `_CenterPotV1` | Centre status lane. It owns the normal focus badge, board, pot, price, and street composition. |
| W11/W12 signal | `act0LateRouteTableSignalForWorldNumberV1` -> `_LateRouteCenterSignalV1` -> `_CenterPotV1` | The accepted repair places one compact gold signal in the existing centre status lane, rather than a separate overlay. W11 is `Transfer`; W12 is `Reset`. |
| Question/options panel | `_RunnerActionDockV1` -> `_ActionPromptPanelV1` -> `_ActionPanelV1` | The dock owns compact prompt/card/answer-row density. It is not a free-floating overlay on the table. |
| Bottom remainder and chin protection | `_RunnerTaskCycleViewportEnvelopeV1` plus `_RunnerActionDockV1` | The envelope reserves a lower slot; the dock has an intrinsic 68 px minimum and `SafeArea(top: false)`, while protected review paths add bottom inset clearance. |

## Constraint chain

For a compact portrait answer-list decision with a protected table profile:

```text
Scaffold SafeArea (active capture wrapper)
  -> Act0LessonRunnerShellV1 / runnerScreen Column
     -> Expanded LayoutBuilder (fixed lower-slot envelope)
        -> upper SizedBox
           -> buildRunnerStage(maxTableHeight)
              -> progress + optional chrome + centred _RunnerTableStageV1
                 -> _Act0TableV1 ConstrainedBox + AspectRatio
        -> lower SizedBox
           -> _RunnerActionDockV1 SafeArea + compact decision surface
              -> question + options
```

The fixed-envelope branch is selected only for answer-list decision profiles on
portrait phones whose safe-area-adjusted usable height is at most 900 px. It
does not apply to W11/W12 because of their semantic label; both worlds inherit
the same decision layout when their task profile qualifies.

The lower slot is calculated from usable height (screen height less the largest
available vertical safe inset): ordinary answer-list decisions target 50%, are
clamped to 365--405 px, and may consume up to 54%. Repair-fill states use a
separate 40%/320--420 px contract. The upper slot gets what remains. Its table
max height is upper slot minus progress/instruction chrome. This is the single
allocation authority; neither the question card nor the W11/W12 signal
independently requests a share of the root height.

## Table size computation

The table is width-first, aspect-ratio bound, and height-capped in compact
answer-list composition:

1. `_Act0TableV1` starts compact-lesson width at
   `Act0ShellTokensV1.runnerTableMaxWidth` (326 px).
2. Refined compact lesson presentation changes the normal aspect from token
   `0.78` to `0.576`; protected compact answer-list composition then replaces
   it with `_compactAnswerListStageFillAspectV1` (`0.66`).
3. If the short portrait device has a system bottom inset, refined compact
   lessons additionally multiply width by `0.917` for an answer-list table
   (`0.832` outside that composition). This is the explicit chin/safe-area
   guard.
4. The fixed-envelope caller provides `maxTableHeight`. The table tightens its
   max width to `min(calculatedWidth, maxTableHeight * aspectRatio)`.
5. A `ConstrainedBox(maxWidth: ...)` wrapping `AspectRatio(aspectRatio: ...)`
   determines the final canvas. Its inner `LayoutBuilder` positions table
   content as fractions of the final width and height.

Therefore the table is neither `Expanded` nor independently height-driven. It
cannot grow into unused root height unless the root envelope and its own width/
aspect/safe-area rules jointly permit it.

## Root-cause assessment

**Primary cause: `fixed_lower_slot_overreservation_with_width_aspect_cap`.**

The compact decision path intentionally reserves a large, mostly fixed lower
slot for readable question/options and safe tap targets. On a 375 x 812
portrait fixture, that can reserve 365--405 px before the dock's actual
intrinsic compact card height is known. The upper table is then height-capped,
and the safe-area scale plus 0.66 aspect ratio can make it smaller again.
When short prompt/option content fails to consume the entire reserved lower
slot, the extra area stays below the decision card. The visual result is both a
compressed table and a large lower dead band even though the table-to-dock gap
is intentionally coupled.

Contributing factors, in order:

1. The root fixed-slot policy reserves capacity for worst-case readable answer
   lists, rather than measuring and redistributing unused lower-slot height.
2. The compact-safe-area table scale protects a home-indicator/chin layout by
   shrinking the table width on relevant devices.
3. The table's aspect ratio converts that reduced width into less height.
4. Compact question/options rows have intrinsic height and safe tap targets,
   but they are not the primary source of the empty remainder: short content
   simply exposes the pre-reserved lower slot.

Not root causes:

- W11/W12 signal differentiation. The accepted `aa0f8d24` repair moved the
  signal into `_CenterPotV1`; it changes centre-lane content only and does not
  change any height/allocation code.
- A separate late-route overlay. That was removed after it collided with
  centre status labels.
- Scroll behavior in the admitted path. Both upper and lower slots are fixed;
  the lower dock may scroll its content inside that reserved envelope, but
  scrolling does not create the reserve.
- The screenshot wrapper. It sets the same 375 x 812 viewport and captures a
  `RepaintBoundary`; it does not impose a table constraint. The active wrapper
  does wrap the runner in `Scaffold -> SafeArea`, so it contributes the real
  safe inset seen by the contract, but not an artificial bottom spacer.

## Prior guards and historical evidence

- The v1h compact runner wave deliberately tuned lower-slot/table sizing,
  retained table visibility, protected review bottom safety, and kept readable
  long-option rows. Existing geometry contracts enforce table/dock coupling,
  table-height bands, safe-bottom breathing room, and final-option proximity.
- The earlier repair-fill work addressed a different defect: a detached table
  to repair-dock gap, especially on tablet. It added the repair-specific
  fixed envelope. It does not prove compact decision density or authorize a
  broad rewrite of the ordinary answer-list envelope.
- The W11/W12 review confirms the first signal implementation collided because
  it added another in-felt overlay. The integrated centre-lane repair is the
  current collision-safe semantic contract.
- No source/review evidence was found that a table-height redistribution itself
  caused a raster regression. The documented raster issues are capture-tool
  behavior: test-font text post-processing and isolated
  `RenderRepaintBoundary.toImage()` anomalies. Treat any reported raster change
  after a future allocation patch as a validation signal, not as evidence that
  the current layout must remain frozen.

## Screenshot evidence assessment

Existing compact screenshots can establish the visible symptom, the order of
the table and decision dock, the lack of direct overlap, and the W11/W12
centre-lane placement. They cannot prove actual-device touch comfort, dynamic
text-scale behavior, a complete range of option lengths, or that the apparent
lower void is unacceptable to users. They also cannot distinguish a layout
policy from a capture artifact without the source chain above.

The active W7-W12 lane is eligible runtime evidence because it mounts the
active runner, but its wrapper uses test-only state and raster capture. The
wrapper affects viewport and SafeArea inputs, as production would; it does not
invent the lower slot. Any post-capture text repair must remain separate from
geometry judgment because the known W12 post-process can damage a valid raw
capture.

## Safe repair options

| Option | Change shape / expected EV | Likely files | Regression risk | Tests | Screenshot evidence |
| --- | --- | --- | --- | --- | --- |
| A. Minimal layout rebalance | Keep the fixed envelope but reduce its ordinary decision target/minimum only when the compact dock has a short, known-safe option profile; give the released height to the upper table cap. **EV: high for this symptom, low scope.** | `act0_lesson_runner_shell_v1.dart`; focused compact geometry test | Medium: safe bottom, long choices, Placement/early-world compact contracts | Existing compact decision geometry cases plus new short/long option and safe-inset bounds; W11/W12 resolver/no-W13 guards | Raw compact W1 baseline + W11 + W12 before/after, with dock/card/table bounds inspected |
| B. Shared table/question vertical contract | Replace fixed lower reservation with a measured bounded split: dock receives intrinsic height clamped to readability/safe-area min/max; table receives remaining height, subject to aspect and minimum presence. **EV: highest and systemic.** | Same runner file; compact layout test family; possibly capture-only assertion metadata, not capture behavior | Medium-high: changes a mature layout owner across W1--W12 answer-list decisions | Full focused compact geometry matrix: W1/Placement, W2--W10 representative short/long/priced options, W11/W12, review/repair invariance, safe-area variants | Same raw compact matrix, plus a simple measured layout packet recording table height, dock height, table-to-dock gap, final-option clearance |
| C. Defer | Preserve current safety/readability policy and log the issue until a broader compact decision composition wave is admitted. **EV: low immediate; avoids churn.** | Docs only | Low | No new product test | Keep current raw compact evidence and mark the symptom unresolved |

## Recommended next implementation wave

Choose **Option A — Compact decision lower-slot rebalance v1**. It targets the
identified owner (`_RunnerTaskCycleViewportEnvelopeV1`) without opening a
general table redesign. It should introduce one explicit ordinary
answer-list-only short-content condition; it must not use world number,
late-route copy, or screenshot filename as a layout input.

Definition of done:

1. On compact portrait answer-list decisions with short known-safe options,
   the table receives a bounded amount of reclaimed vertical space and the
   decision card remains close to the table.
2. Long/priced options, protected review, repair-fill, table-tap decisions,
   tablet, and non-Act0 surfaces retain their existing contracts unless a
   focused test proves a necessary shared owner adjustment.
3. W1/W2--W10 presentation remains semantically unchanged; W11/W12 preserve
   the centre-lane signal; W12 terminal payoff and W13 lock stay unchanged.
4. No route, progression, scoring, content, telemetry, or capture-postprocess
   change is made.
5. Focused geometry and route guards pass, and raw compact W1/W11/W12
   screenshots show no collision, clipping, unsafe bottom clearance, or
   table-to-dock detachment.

## Debt ledger / return queue

| ID | Debt | Owner | Return trigger |
| --- | --- | --- | --- |
| CDL-001 | Fixed lower reservation can leave short compact decision states visually under-filled. | Runner viewport envelope | Option A admission. |
| CDL-002 | The table uses both safe-area width scaling and aspect conversion; future shared-contract work should make their visual intent explicit with measured bounds. | `_Act0TableV1` + envelope tests | If A cannot improve the symptom without threshold churn. |
| CDL-003 | Existing compact geometry coverage is extensive but lives in a legacy-named backlog test file. | Test organization only | Separate test-maintenance wave; do not mix with A. |
| CDL-004 | W12 capture post-processing can alter raw-valid visual evidence. | Capture pipeline | Before a final visual gate; out of this layout wave. |

No 10/10 assessment, public readiness, Human QA readiness, mastery, or
Human QA result is claimed by this audit.
