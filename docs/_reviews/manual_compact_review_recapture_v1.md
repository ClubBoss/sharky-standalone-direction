# Manual Compact Review Recapture v1

## Purpose

Visual QA gate for the Review First-Week Repair Card Readability v1 change.

The goal was to verify whether the compact Review open-repair state now feels calmer, less operational, and easier to parse after removing duplicate repair elements.

## Capture Method

Used the existing Review debug URL at compact portrait `393 x 852`:

```text
?act0_capture=first_week_review
```

Captured with the in-app browser against a fresh local Flutter web server at:

```text
http://127.0.0.1:7357/?act0_capture=first_week_review
```

No broad screenshot sweep was run. No product code, tests, routes, telemetry, table geometry, Playwright tooling, screenshot tooling, or copy was changed.

Locale note: the screenshot rendered RU-dominant mixed locale. It is valid for layout, density, hierarchy, CTA visibility, and localized proof of the simplified Review structure. Final English commercial screenshot proof remains deferred.

## Screenshot Inventory

| Surface | Path | Status |
| --- | --- | --- |
| Review compact open repair | `output/playwright/manual_compact_review_recapture_v1/first_week_review_open_repair_compact.png` | captured |
| Manifest | `output/playwright/manual_compact_review_recapture_v1/capture_manifest.json` | captured |

## Review Visual Review

| criterion | score | notes |
| --- | ---: | --- |
| Repair hierarchy clarity | 8.4 | The eye now lands on one repair story: header, coach line, answer comparison, why, CTA. |
| Trainer voice clarity | 8.2 | `Ремонт с Sharky` and the reread sentence make the state feel guided rather than reported. |
| Visual readability | 8.4 | The first viewport is much calmer; no duplicate board below the mistake card. |
| Commercial/premium feel | 8.1 | The simplified card preserves the polished dark shell and removes prototype-like clutter. |
| Text density | 8.2 | Still text-heavy because the task content is mixed language, but density is now acceptable. |
| CTA clarity | 8.7 | Single primary CTA is visible above the fold and clearly tied to the clue repair. |
| Answer comparison clarity | 8.5 | The selected answer and better clue are easy to compare. |
| Blocker severity | 9.0 | No blocker found. |
| Runout-level packaging gap | 7.7 | Still less minimal than Runout-style calm packaging, but no longer a Review-specific blocker. |

Issue class: **acceptable polish / locale proof limitation**.

No visible overflow, truncation, duplicate repair board, or competing repair CTA was found.

## Before/After Verdict Based on Previous Manual Proof

Before the readability pass, Review was the weakest first-week surface because the user had to parse:

- a status badge;
- answer comparison;
- concept title and explanation;
- context chips;
- repair-plan row;
- primary repair CTA;
- a second lower repair board with another CTA.

After the readability pass, the compact Review state is materially clearer:

- duplicate lower Review board is gone;
- prominent status badge is gone;
- repair-plan row is gone;
- one primary CTA remains;
- answer comparison and task reason stay visible;
- the surface now reads as one repair moment instead of two stacked repair modules.

Verdict: **Review now clears the 8+ bar for compact first-week readability.**

## Runout Comparison From Visible Evidence Only

Runout's likely visible advantage remains broader calm packaging and fewer training-surface elements.

Sharky's visible advantage remains stronger deterministic repair proof: the screen shows exactly what was chosen, what the better clue was, why it matters, and the repair CTA.

From this screenshot, the gap is no longer a Review-blocking hierarchy issue. Further gains should come from a broader product layer rather than another Review micro-polish pass.

## Blockers vs Acceptable Polish

Blockers:

- None for Review readability.
- None for compact layout.
- None for CTA clarity.
- None for commercial trust.

Acceptable polish:

- Mixed-language task content.
- English commercial screenshot proof still deferred.
- Review still has more visual structure than Runout-style minimal training screens, but the structure now serves the repair proof.

## Recommended Next Implementation Wave

**Session Result / Progress Anchor v1**

Reason: Review now scores above 8 with no blocker. The highest EV next step is to make the end of a session leave a clear progress anchor: what improved, what was repaired, and why returning tomorrow matters.

Do not run another Review micro-polish wave unless new screenshot evidence shows a specific regression.

## Deferred List

- English-locale compact Review recapture.
- Automated targeted capture reliability.
- Product Surface Premium Implementation Pack.
- Broad controlled-demo sweep.
- Localization cleanup.
- Profile trainer identity pass.

## Direction Score

**8.5 / 10**

The Review repair card is now good enough to move forward. The first-week loop has a credible calm trainer moment in Review while preserving Sharky's deterministic repair proof.
