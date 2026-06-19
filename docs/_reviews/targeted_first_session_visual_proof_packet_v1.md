# Targeted First-Session Visual Proof Packet v1

Status: audit/proof-only
Date: 2026-06-18

## 1. Purpose

Verify, with quota-efficient compact-phone evidence, whether the current Act0 first-session, Home, and Review hierarchy reads like calm premium trainer guidance instead of a task tracker or repair queue after the recent Home + Review Calm Trainer Hierarchy Pass.

This packet does not change app code, tests, copy, routes, telemetry, repair resolver logic, screenshot tooling, Playwright logic, table geometry, content, or visual design.

## 2. Evidence Used

- Existing compact screenshot evidence:
  - `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.runner_first_correct_feedback.png`
  - `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.home.png`
  - `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.review.png`
- Existing screenshot metadata:
  - `output/playwright/controlled_demo_reliability_triage_v1/.entry.compact_phone.runner_first_correct_feedback.json`
  - `output/playwright/controlled_demo_reliability_triage_v1/.entry.compact_phone.home.json`
  - `output/playwright/controlled_demo_reliability_triage_v1/.entry.compact_phone.review.json`
- Current code evidence:
  - `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- Focused widget-test evidence:
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`

No new screenshots were generated. The controlled demo capture script currently runs all surfaces across all configured viewports; using it would violate the targeted quota unless the tool were changed, and this wave explicitly forbids screenshot tooling changes.

## 3. Screenshot / Artifact Paths Inspected

| Path | State | Current for hierarchy pass? | Notes |
| --- | --- | --- | --- |
| `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.runner_first_correct_feedback.png` | First correct feedback | Yes for first-correct state | Shows exact No-bet first correct feedback on compact phone. |
| `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.home.png` | Home | No | Stale: still shows `Today's focus`, `Useful steps for today.`, and `0 / 4`. |
| `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.review.png` | Review open repair | No | Stale: still shows `Start here`, `What to fix next`, and `Recovery plan`. |
| `output/playwright/first_correct_feedback_capture_harness_v1/compact_phone.runner_first_correct_feedback.png` | First correct feedback | Yes for first-correct state | Duplicate current first-correct proof source. |

## 4. State-by-State Visual QA Table

| State | Proof source | Captured | User job | Visible CTA | Visible learning proof | Score | Blocker | Issue class | Recommended action | Rationale |
| --- | --- | --- | --- | --- | --- | ---: | --- | --- | --- | --- |
| First correct feedback compact state | Screenshot + test | yes | Understand: "I noticed a table clue and read better." | `Continue` | `Table read improved`; `You noticed No bet yet before choosing an action.`; `Next: practice the same table clue once more.` | 9.0 | no | none | Keep. | Compact screenshot shows table as hero, No-bet signal row, why sentence, next action, and reachable CTA without truncation. |
| Home first-value carry / daily checklist compact state | Code + focused test; stale screenshot rejected | no | Know the next useful hand without checklist pressure. | Main `Continue`; active row affordance | `Short table practice`; `Keep one table clue warm.`; `Next useful hand` | 8.2 | no | visual proof gap | Do not fix product. Run a future targeted compact capture only if tooling can capture a subset without editing. | Current code and tests prove the calm copy; existing Home screenshot is stale and should not be used for launch proof. No evidence of runtime blocker from tests. |
| Review open repair compact state | Code + focused test; stale screenshot rejected | no | Fix one missed table clue without shame. | `Start repair rep`; `Fix the next signal` | `Repair one table clue`; `One calm repair rep keeps this clue from becoming a habit.`; `This clue is still open` | 8.0 | no | visual proof gap / minor comparison-density risk | Keep current product. Defer a bounded comparison-language pass only if manual QA later finds `You chose` / `Better` punitive. | Current code and tests prove the hierarchy change. Existing screenshot is stale and still shows the old queue-like Review copy, so it is not current evidence. |
| Review repaired proof compact state | Code + focused test | no | See that the repair worked and optionally replay for perfect. | `Replay for perfect` | `Recovered lately`; `Repaired`; `This clue is cleaner now.` or `This clue is clean now.` | 8.3 | no | visual proof gap | Keep current product; capture later with a subset-capable proof lane. | Focused tests prove repaired proof and removal of stale `Clear path still open.` / `Perfect clear complete.` strings. No direct compact screenshot exists for the repaired proof state. |

## 5. Blockers

None found.

The only hard evidence gap is screenshot freshness for Home and Review after the hierarchy pass. That is not a product blocker because current code and focused tests prove the new copy and because generating fresh visuals would require either a full capture lane or screenshot tooling changes.

## 6. Non-Blocking Issues

- Existing Home and Review compact screenshots in `controlled_demo_reliability_triage_v1` are stale and should not be reused as current proof for hierarchy quality.
- Review still contains comparison language (`You chose` / `Better`) inside the card. It is useful and deterministic, but may warrant a later narrow manual review for tone.
- No compact screenshot currently proves the repaired proof row after the latest hierarchy copy.
- The capture script is not subset-friendly; it is reliable for broad proof but inefficient for this quota policy.

## 7. Recommended Next Action

Proceed to Trust / Monetization Readiness Audit v1 or the next macro-layer.

Do not run a local Home/Review corrective wave from this packet. The product-facing copy/hierarchy has enough code and focused-test proof, and the remaining issue is proof artifact freshness rather than a confirmed UI defect.

## 8. Deferred List

- A subset-capable compact proof lane that can capture only selected states without editing the screenshot script.
- Compact screenshot proof for Home after first-value carry and daily checklist.
- Compact screenshot proof for Review open repair after the hierarchy pass.
- Compact screenshot proof for Review repaired proof.
- Optional manual tone audit for `You chose` / `Better` if future visual QA flags it as punitive.

## 9. Direction Score

Current direction: 8.4 / 10.

The first-correct feedback surface is already strong and table-first. Home and Review have current code/test proof for calmer trainer language, but not current compact screenshot proof. The next product step should move up a macro-layer rather than continue local copy polishing.

## 10. Runout / Benchmark-Stack Comparison

Based only on proven current evidence:

- Sharky is stronger than a generic polished trainer on deterministic learning proof: choice -> visible table signal -> why -> same-signal next action.
- The first-correct feedback screenshot is the strongest current proof: it keeps the table dominant and ties the explanation to `No bet yet`.
- Runout remains the packaging benchmark from prior accepted audits, but this packet did not re-open Runout evidence and makes no new competitor claims.
- Sharky's current risk is not missing learning proof; it is proof artifact freshness for Home/Review after the latest hierarchy improvements.

