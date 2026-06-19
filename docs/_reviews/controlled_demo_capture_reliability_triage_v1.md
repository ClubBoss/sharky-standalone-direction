# Controlled Demo Capture Reliability Triage v1

## Purpose

Triage the controlled-demo capture false failure where `compact_phone/placement` was marked blank even though the same placement capture rendered on larger viewports and first-correct feedback screenshots were generated.

## PIEC Findings

- Failing script/path: `tools/act0_controlled_demo_capture_v1.sh`, inside the surface probe and manifest entry flow.
- Failing state URL: `http://127.0.0.1:7357/?act0_capture=placement`.
- Failing viewport: `compact_phone` at `393 x 852`.
- Previous artifact state: `compact_phone.placement.png` was a blank white `2.7K` PNG, with `bodyTextLength: 0` and `failureReason: Blank surface`.
- Larger viewport comparison: `large_phone/placement` and `tablet/placement` rendered the expected placement intro text.
- First-correct feedback state safety: `runner_first_correct_feedback` stayed nonblank and captured the target No-bet feedback copy.

## Cause Classification

Harness timing issue.

The probe used fixed waits after navigation/accessibility-gate handling and then immediately read `body.innerText()` before screenshot capture. On compact placement, Flutter web sometimes had not exposed route text yet, so the script captured a pre-render blank white page and marked the entry blank.

No evidence points to production placement UI, route, content, copy, table, or geometry regression.

## Fix

The capture probe now polls for non-empty `body.innerText()` before recording the entry and screenshot. It waits up to 8 seconds in 500 ms intervals, then continues with the existing blank checks.

This is a harness-only timing fix.

## Verification Evidence

Fresh output folder:

`/Users/elmarsalimzade/Sharky_1.0/output/playwright/controlled_demo_reliability_triage_v1`

Fresh compact entries after the fix:

- `compact_phone/placement`: `blank: false`, `bodyTextLength: 391`, screenshot size `137434` bytes.
- `compact_phone/runner_first_correct_feedback`: `blank: false`, `bodyTextLength: 299`, screenshot size `174797` bytes.
- `large_phone/placement`: `blank: false`, `bodyTextLength: 391`.
- `large_phone/runner_first_correct_feedback`: `blank: false`, `bodyTextLength: 349`.

Inspected screenshot:

- `/Users/elmarsalimzade/Sharky_1.0/output/playwright/controlled_demo_reliability_triage_v1/compact_phone.placement.png`

The screenshot shows the expected `Find your start` placement surface and `Find my start` CTA.

## Remaining Risk

The full all-viewport capture run later exited non-zero with a separate Playwright Chrome launch timeout while moving into remaining viewport work. That is distinct from the compact placement blank bug:

- compact placement had already captured successfully;
- first-correct feedback had already captured successfully for compact and large phone in the fresh run;
- prior first-correct harness evidence already captured compact, large phone, and tablet successfully.

If full capture is intended as a hard gate, the next reliability target should be Playwright session startup/reuse, not placement rendering.

