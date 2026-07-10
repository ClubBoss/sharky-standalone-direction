# Current-Main Visual Evidence / Fixture Trace v1

Status: evidence and source tracing only. No product source, UI, route, progression, telemetry, Sharky, motion, tablet, or readiness artifact changed.

## Terminal verdict

`feedback_clue_pill_integrity_only__admitted_after_review`.

At canonical 375×812 compact-phone real-text evidence, the longest feedback clue visibly clips in welcome and W1 correct feedback. The same one-line/fade contract is used by the repair outcome family. This is one bounded feedback-owner family. W9 table-overlay collision also reproduces, but independent positioned owners make it a later separate wave.

## Branch / evidence

| Check | Result |
| --- | --- |
| Pushed adjudication / capture HEAD | `6906fdfeca18f46d1a3fc442a67cf92e96480f13` |
| Branch / remote after Step 0 | `main`; local equals `origin/main` |
| Push | succeeded before Step 1 |
| Local evidence | `output/evidence/current_main_visual_evidence_fixture_trace_v1/` (110 files; untracked) |
| Literal text | all four manifests report `is_real_text: true`; no masks, blur, Ahem, or reconstructed screenshots |

The local package copies four successful real-text widget-test packets: `first_week_fast`, `day2_return_fast`, `active_route_w7_w12_fast`, and `full_scroll_fast`. Individual PNGs are primary; contact sheets are navigation only.

### Device coverage

| Requested | Result |
| --- | --- |
| 375pt | captured at 375×812 compact portrait |
| ~320pt / ~430pt | unavailable: approved literal-text tool has only compact 375×812 or non-canonical tablet; no tool/source modification made |
| short/tall compact | unavailable in approved literal-text lane |
| native/notched | unavailable; no cheap native lane exists |
| tablet | intentionally not captured |

## Reproduction matrix

| Concern | Current 375pt result | Source owner / classification |
| --- | --- | --- |
| Welcome feedback clue | **REPRODUCES**: `Nobody had bet yet - that was the clue` fades at right edge. | `_humanizedFeedbackProofLineV1` + runner feedback evidence bridge; `maxLines: 1`, `TextOverflow.fade`, `softWrap: false`. |
| W1 correct feedback clue | **REPRODUCES**. | Same formatter and presentation contract. |
| Repair result / open repair source | Same runner/repair family is captured; shared one-line contract means this is one owner family. | Do not treat as Home/table/terminal owner. |
| W8 table | available; no conclusive collision at 375. | Keep as regression control. |
| W9 table | **REPRODUCES**: flag callout overlaps center context/street and occupied seat/bet area. | `_Act0TableV1` has independent `Positioned` seat/bet, `_CenterPotV1`, and `_TableRepairCalloutV1` children. |
| W10/W11/W12 | captured; no generic collision rule proven. | Individual fixture controls only. |
| Home Review subtitle | **INCONCLUSIVE**: top full-scroll view puts Review below the visible fold/nav but does not prove own-row text clipping. | Separate `_HomeChecklistRowTileV1` owner. |
| Return Home subtitle | **NOT REPRODUCED** at 375. | Same Home family; not runner/table scope. |

## Table overlay owner trace

The W9 result is a source-backed blocker investigation, not a Modern Table redesign. `_Act0TableV1` owns the table stack; `_BetChipPlacementV1` and `_SeatPlacementV1` use independent slot anchors; `_CenterPotV1` owns context/signal/street; `_TableRepairCalloutV1` owns the flag callout. The collision is not a proven z-order-only defect. A later table-only wave needs one agreed priority/avoidance invariant and W8/W9/W12-payoff 375pt regression controls. It excludes feedback, Home, terminal copy, progression semantics, and Modern Table redesign.

## `1/4` fixture/data trace

`1/4` is **correct micro-set scope**, not W7–W12 progression. `_learningRailProgressLabel` returns `current/total` from `runner.teachingStepIndex` and `runner.teachingSteps.length`. Active W7–W12 fixtures start at task index 0 with four teaching steps, therefore display `1/4`. The No-W13 detail fixture at index 3 shows **4/4**. Canonical classification: correct value, **missing scope label**; no semantic change admitted.

## No-W13 trace

- Data: terminal review pack step 4 in `campaign_pack_registry_v1.dart` owns `You can now slow down and read the table before choosing.` and the later-worlds-locked boundary text.
- Presentation: `Act0BlockCompletionSummaryV1`, `_TerminalCompletionPayoffV1`, and `_WorldMilestoneCardV1` in `act0_lesson_runner_shell_v1.dart`.
- Evidence: No-W13 copy-detail renders **4/4**, `Volume I complete`, and full boundary text; its table context pill clips to `You can now slo`.
- CTA: source hard-gates terminal payoff to World 12 with no W13 implication; no-forward-path CTA resolves to `Back to map`. Capture is not a tap/destination proof.
- Decision: no terminal-only wave yet. The reproduced fit failure belongs to the table-context sub-owner; terminal hierarchy/CTA remain evidence items.

## Welcome / Session Summary

The 375×812 welcome handoff has a large upper region, but one height cannot distinguish intended fixed-envelope composition from device-height behavior. **Evidence insufficient.**

Session Summary has current compact top/mid/bottom captures. Bottom content is visible above bottom navigation in the widget-test lane. This is not native/notched proof and does not establish clipping, initial-position failure, or inadequate padding. **Unresolved native-device evidence gap.**

## Source map, coverage, and stop conditions

| Concern | Data / presentation / fixture | Current tests | Stop condition |
| --- | --- | --- | --- |
| Feedback clue | runner proof line + `_humanizedFeedbackProofLineV1`; feedback bridge; first-week/Day-2 | feedback/repair source guards | stop if table/Home/terminal owner or semantic copy change is needed |
| Table overlays | W7–W12 hidden-runtime fixtures; `_Act0TableV1` stack; active-route packet | W7–W12 table-context/signal guards | stop without agreed avoidance invariant or if scope becomes Modern Table work |
| Home row | Home data/fallback; `_HomeChecklistRowTileV1`; full-scroll/Day-2 | Home shell/visual guards | stop unless own-row clipping reproduces |
| Progress | runner teaching step state; learning rail; W7–W12 packet | route screenshot-tooling guards | stop if a label changes data semantics |
| Terminal | campaign terminal pack; terminal payoff; terminal fixture | terminal/route guards | stop if W13 or non-Review/map routing is implied |
| Welcome / Summary | respective shell owners; first-week/full-scroll | visual/session guards | stop until literal short/tall or native evidence exists |

## Confirmed debt / evidence queue

Confirmed at 375pt: feedback clue truncation; W9 table overlay collision; No-W13 table-context truncation; and `1/4` as micro-set scope. Not reproduced: return-Home own-row clipping, generic W8/W10/W11/W12 collision, or terminal CTA truth failure. Unavailable: 320/430, native safe area, short/tall handoff, pressed/motion states, and Home initial-scroll semantics. PRA-01 remains stale/fixture-specific: source deliberately shows two locked previews when all topic groups are locked.

## Exactly one recommended implementation wave

**A. Feedback clue-pill integrity only.**

Included screens: welcome feedback, W1 correct feedback, repair result, open repair source where they share the runner feedback evidence bridge. Non-scope: table context/callout, terminal context, Home/return rows, progression, routes, motion, Sharky, tablet, and copy-semantic rewrites. Likely file family: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` plus focused feedback/repair guard or widget tests.

Required proof: 375pt real-text recaptures of all four, focused longest-normalized-clue coverage with no mid-word fade, and preservation of repair-receipt semantics. Stop if it crosses into another owner, changes progression/copy semantics, or needs an unapproved 320/430 capture profile.

## Non-claims / validation

No Human QA, public/investor readiness, 10/10, Worlds/path-map, Sharky, motion, tablet, durable learning-effect, or W13 claim is made. Capture-specific widget-test lanes passed for all four packets. `git diff --check`, staged diff check, and `graphify hook-check` are required before committing this review artifact. No product source test is required because no product source changed.
