# First-Session Manual Screenshot QA v1

## 1. Purpose

Verify whether the current Act0 first-session feedback surface visually supports the intended beginner aha:

- the table stays the main learning object;
- the feedback identifies a visible table clue;
- the learner understands what to do next;
- the surface feels like a compact poker coach rather than a metadata receipt.

This was an audit-only screenshot QA pass. No app UI, copy, route, telemetry, resolver, table, dashboard, or geometry changes were made.

## 2. Screenshot Generation / Inspection Method

Existing route-browser screenshot tooling was used:

```bash
tools/act0_controlled_demo_capture_v1.sh /Users/elmarsalimzade/Sharky_1.0/output/playwright/first_session_manual_screenshot_qa_v1
```

The first run used a relative output path and failed before producing a manifest because Playwright resolved the generated config path relative to the output directory. The command was rerun with an absolute output path.

The rerun generated the needed runner-feedback screenshots, but the script exited non-zero because its completeness assertion marked `compact_phone/placement` as blank:

```text
missing: compact_phone/placement
```

That failure does not invalidate the generated feedback screenshots, but it means the command cannot be counted as a fully green capture lane in this wave.

Important limitation: the existing `act0_capture=runner_feedback` direct-state harness renders a wrong/repair table-position feedback state from the default task. It does not expose the exact correct No-bet first-value feedback state that now says:

- `Table read improved`
- `You noticed No bet yet before choosing an action.`
- `Next: practice the same table clue once more.`

The exact No-bet copy is covered by focused widget tests, but not by an existing screenshot capture mode.

## 3. Screenshot Paths Inspected

- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.runner_feedback_or_review.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/first_session_manual_screenshot_qa_v1/large_phone.runner_feedback_or_review.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/first_session_manual_screenshot_qa_v1/tablet.runner_feedback_or_review.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/first_session_manual_screenshot_qa_v1/manifest.json`

## 4. Compact Portrait Assessment

Viewport: `393 x 852`.

The compact feedback screenshot is readable and table-dominant. The table occupies most of the screen, seat highlights remain visible, and the feedback surface sits at the bottom without visually taking over the learning object.

However, compact portrait only shows the upper part of the repair hierarchy:

- visible: table, highlighted position signal, `Hero on the Button`, `Better option: Hero on the Button`, short reason, `Continue`;
- not visible in compact without more vertical room: the lower context chips that are visible on large phone/tablet.

The CTA is obvious. The table clue is connected to the highlighted seat and the feedback row. The density is acceptable, but compact portrait is close to the lower-surface limit.

Exact No-bet correct-feedback copy was not screenshot-available through current tooling.

## 5. Landscape Assessment

Not available. The existing controlled demo capture supports compact phone, large phone, and tablet portrait. No landscape viewport is wired without changing tooling, so this wave did not add one.

## 6. Aha-Screen Rubric Scores

Scores are for the available route-browser runner-feedback screenshot state. Exact No-bet correct-feedback screenshot coverage is unavailable.

| Dimension | Score | Notes |
| --- | ---: | --- |
| Table dominance | 5/5 | Table remains the visual hero across compact, large phone, and tablet. |
| First-feedback copy visibility | 3/5 | Available repair copy is readable. Exact new No-bet correct copy is not screenshot-proven. |
| Table-clue clarity | 4/5 | `Hero on the Button` is visually tied to a highlighted seat. Compact loses some lower context chips. |
| Feedback hierarchy | 4/5 | Outcome, better option, selected answer, clue, reason, and CTA are clear on large phone/tablet; compact is more compressed. |
| CTA / next-action clarity | 5/5 | `Continue` is large, obvious, and reachable. |
| Beginner readability | 4/5 | Copy is short and concrete. `Better option` is clear, but compact repair state still feels slightly evaluative. |
| Compact portrait fit | 4/5 | Fits safely; bottom surface is dense but not broken. |
| Premium trainer perception | 4/5 | Poker-native table presentation is strong; lower feedback is functional and calm rather than flashy. |
| No visual/table regression | 5/5 | No overlap, blank table, or obvious table/dock geometry issue in feedback screenshots. |

## 7. Blockers

No visual blocker was found in the available runner-feedback screenshots.

Exact first-correct No-bet screenshot QA is unavailable with the current capture harness. This is a tooling coverage gap, not evidence of a product regression.

## 8. Non-Blocking Issues

- The screenshot harness direct `runner_feedback` state is not aligned with the currently most important first-value aha state.
- Compact portrait repair feedback is readable but tight; large phone/tablet show the hierarchy more completely.
- The capture command currently fails full completeness because `compact_phone/placement` was blank in this run. That should be triaged separately if the controlled-demo lane is used as a gate.

## 9. Recommended Next 1-3 Arcs

1. **Act0 First Correct Feedback Capture Harness v1**: add a bounded existing-harness state for the correct No-bet first-value feedback screen, without changing runtime UX.
2. **Compact Feedback Density Review v1**: audit whether compact portrait should prioritize the table clue + why + CTA over secondary context chips.
3. **Controlled Demo Capture Reliability Triage v1**: classify why `compact_phone/placement` intermittently captures blank while other surfaces render.

## 10. Direction Score

Current direction: **8.3 / 10**.

The proven visual direction is strong where the screenshot exists: the table remains dominant, the feedback is calm, and the visible signal is tied to a table highlight. The unproven part is the exact updated No-bet correct-feedback aha screen, because the existing screenshot harness cannot target it.

Compared with Runout / benchmark stack from proven current behavior only:

- Sharky is stronger on deterministic table-signal proof when the feedback signal is visible.
- Runout remains the benchmark for polished trainer packaging.
- Sharky should not copy Runout's advanced/GTO feel; the stronger path is still beginner-safe table-first proof.

## 11. Follow-Up Capture Harness Addendum

`Act0 First Correct Feedback Capture Harness v1` added a deterministic harness state for the exact correct No-bet first-value feedback screen.

New surface:

```text
?act0_capture=runner_first_correct_feedback
```

Generated screenshot evidence:

- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/first_correct_feedback_capture_harness_v1/compact_phone.runner_first_correct_feedback.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/first_correct_feedback_capture_harness_v1/large_phone.runner_first_correct_feedback.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/first_correct_feedback_capture_harness_v1/tablet.runner_first_correct_feedback.png`

Compact portrait now proves the exact target copy is visible:

- `Table read improved`
- `You noticed No bet yet before choosing an action.`
- `Next: practice the same table clue once more.`

The table remains visible and dominant, the `No bet yet` signal chip is visible, `Best play: Check` is visible, and the `Continue` CTA is visible.
