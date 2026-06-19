# Compact English Feedback Rhythm Recapture v1

## Purpose

Manual compact English proof pass for Act0 feedback rhythm after the verdict hierarchy copy landed. Scope was capture/review only: no app, copy, route, telemetry, table, or test changes.

## Capture Method

- Viewport: `393 x 852`.
- Locale lane: explicit `act0_capture` URL plus `locale=en`.
- First correct URL: `http://127.0.0.1:7357/?act0_capture=runner_first_correct_feedback&locale=en`.
- First wrong URL attempted: `http://127.0.0.1:7357/?act0_capture=runner_feedback&world=world_1&lesson=fold_check_call_raise&task=actions_check_drill&locale=en`.
- Output directory: `output/playwright/compact_english_feedback_rhythm_recapture_v1/`.

Plain `/?locale=en` was not used.

## Screenshot Inventory

| State | Screenshot | User job | Verdict clarity | Table-signal clarity | Density risk | CTA clarity | Blocker? | Issue class | Recommended action |
| --- | --- | --- | ---: | ---: | --- | ---: | --- | --- | --- |
| First correct feedback | `output/playwright/compact_english_feedback_rhythm_recapture_v1/first_correct_feedback_compact_en.png` | Prove "I noticed a table clue and read the table better." | 8.6/10 | 9.2/10 | Medium | 9.0/10 | No | Useful but verdict is subtle | Keep as acceptable proof; consider verdict hierarchy only if wrong proof shows same issue. |
| First wrong feedback | Not captured | Prove "I missed the table clue and know what to repair." | N/A | N/A | N/A | N/A | Proof blocker | Capture friction | Re-run with a targeted screenshot runner or add a harness capture seam only if needed. |
| Suboptimal feedback | Not attempted | Optional only | N/A | N/A | N/A | N/A | No | Deferred optional | Skip until correct and wrong proof are stable. |

## Correct Feedback Findings

The first correct compact English screenshot is usable commercial proof. The table remains visually dominant, the `No bet yet` table signal is visible both on-table and in the feedback surface, and the feedback explains the learning moment:

- `Good read`
- `Table read improved`
- `You noticed No bet yet before choosing an action.`
- `Next: practice the same table clue once more.`

The main weakness is hierarchy: `Good read` is present but small and low-emphasis relative to `Best play: Check`. The learner can still understand the aha moment, but the verdict does not yet feel like the strongest first read in the sheet.

## Wrong Feedback Findings

The deterministic wrong URL was identified and attempted twice, but screenshot capture timed out before a usable image was produced. After the second failure, the browser tab was still at the accessibility gate, so this is classified as capture/proof friction rather than evidence of a product regression.

No visual score is assigned for wrong feedback in this wave.

## Optional Suboptimal Findings

Suboptimal capture was skipped. The required wrong state did not produce screenshot proof within the allowed attempts, so optional capture would have expanded the wave beyond its proof-only budget.

## Runout Comparison

From the captured correct state only:

- Sharky already has stronger deterministic table-signal proof than the known Runout benchmark pattern: the user action ties to `No bet yet`, a visible table highlight, and a same-signal next rep.
- Runout-style calm feedback rhythm is partially matched: the table stays visible and the lower feedback surface is compact.
- Sharky's current risk is not proof logic; it is visible hierarchy. The verdict reads quieter than the action result.

This pass did not inspect new Runout material.

## Blockers vs Polish

Blocker:

- Missing compact English screenshot proof for first wrong feedback.

Polish:

- Correct feedback verdict is useful but slightly too subtle for a commercial proof hero moment.
- The surface is dense but still readable at 393 x 852.

## Recommended Next Implementation Wave

Because the required wrong feedback capture failed twice, the immediate next arc should be `Targeted Screenshot Pack Runner v1`, not another product-copy pass. The runner should reliably capture named compact proof states without manual browser friction.

If that runner later proves both correct and wrong states render cleanly but the verdict remains too quiet, run `Feedback Verdict Hierarchy v1` as a separate bounded visual/copy hierarchy pass.

## Direction Score

Current direction: 8.4/10.

Reason: correct feedback now communicates the intended aha, but the wave cannot clear the commercial proof gate without wrong-feedback screenshot evidence. Product direction is strong; proof reliability is the immediate weakness.

