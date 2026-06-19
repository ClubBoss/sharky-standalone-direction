# First-Week Progress Proof Packet v1

Date: 2026-06-18
Mode: Targeted visual/product proof packet
Scope: First Week Progression Loop across Home, Review, Learn, and Profile.

## 1. Purpose

Verify whether the newly implemented First Week Progression Loop is commercially readable and coherent on the key compact surfaces without reopening product implementation, screenshot tooling, Playwright tooling, table geometry, route behavior, commerce, or dashboard work.

Verdict:

Partial proof only. Current code and focused widget tests prove the Week 1 story is present across Home, Review, Learn, and Profile, and the copy stays beginner-safe and non-commercial. Current compact screenshot proof is not available. Existing Home/Review/Learn/Profile screenshots are stale, and the existing controlled-demo script still captures a broad all-surface/all-viewport sweep rather than the required targeted compact subset. A manual compact browser capture was attempted, but the local Flutter web server did not become available within the quota window and was stopped before this became tooling triage.

Product interpretation:

The first-week loop is directionally coherent, but this wave cannot certify visual/commercial readiness from fresh screenshots. The next best move is not product implementation yet; it is a tiny targeted compact proof seam or an approved manual screenshot pass that can capture only Home, Review, Learn, and Profile compact states.

## 2. Capture / Proof Scope

Intended proof scope:

- Compact portrait first.
- Home with first-week daily framing.
- Review with open repair.
- Learn first-week path surface.
- Profile return rhythm surface.
- Repaired Review proof if already available without extra setup.

Actual proof used:

- Current code evidence:
  - `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
  - `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- Focused widget-test evidence:
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Existing screenshot inventory:
  - stale prior compact captures under `output/playwright/first_session_manual_screenshot_qa_v1/`
  - stale prior compact captures under `output/playwright/controlled_demo_reliability_triage_v1/`

No screenshots were generated in this wave.

## 3. Screenshot / Artifact Inventory

| Artifact path | Surface/state | Current enough for First Week Progression Loop? | Reason |
| --- | --- | --- | --- |
| `output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.home.png` | Home | No | Predates the Week 1 Home copy and cannot prove `Week 1: build table-reading habits`. |
| `output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.review.png` | Review open repair | No | Predates `Week 1 repair` and the updated repair-return framing. |
| `output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.learn.png` | Learn | No | Predates the first-week path support line. |
| `output/playwright/first_session_manual_screenshot_qa_v1/compact_phone.profile.png` | Profile | No | Predates the first-week return rhythm line. |
| `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.home.png` | Home | No | Previously marked stale for Home hierarchy; not first-week current. |
| `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.review.png` | Review | No | Previously marked stale for Review hierarchy; not first-week current. |
| `output/playwright/controlled_demo_reliability_triage_v1/compact_phone.runner_first_correct_feedback.png` | First correct feedback | Yes for first-correct feedback only | Useful as existing proof of the first aha screen, but not proof of the new week loop surfaces. |

Capture tooling findings:

- `tools/act0_controlled_demo_capture_v1.sh` supports the needed `?act0_capture=home`, `review`, `learn`, and `profile` states, but it always runs the full surface set across compact phone, large phone, and tablet.
- The script has no documented subset flag for only compact Home/Review/Learn/Profile.
- Direct debug harness states exist for Home, Review, Learn, Profile, and first-correct feedback.
- Home/Profile debug states may not represent the first-value activated state exactly unless the capture state seeds the right progress/carry state.
- Live manual browser capture was attempted by starting `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357`; the server did not open the port within the quota window and was stopped.

## 4. Surface-by-Surface Visual Review

| Surface/state | Proof source or screenshot path | User job | First-week message clarity score 1-10 | Visual premium/readability score 1-10 | Text density risk | Commercial blocker? | Issue class | Recommended action |
| --- | --- | --- | ---: | ---: | --- | --- | --- | --- |
| Home daily / first-week framing | Code + focused test; no current screenshot | See the Week 1 trainer journey and next useful hand. | 8.5 | 7.2 confidence-limited | Medium | No, but not launch-proof | capture unavailable | Capture compact Home before any product repair. |
| Home after first-value carry | Focused first-value carry tests; no current screenshot | See exact first-value next action and Week 1 context. | 8.4 | 7.0 confidence-limited | Medium | No | capture unavailable | Needs a seeded compact capture state or targeted manual proof. |
| Review open repair | Code + direct Review widget test; no current screenshot | Treat repair as one normal Week 1 trainer step. | 8.4 | 7.3 confidence-limited | Medium | No | capture unavailable | Capture compact Review open repair; watch comparison row density. |
| Review repaired proof | Existing focused repaired proof tests; no current screenshot | See repair worked and replay if desired. | 8.1 | 7.1 confidence-limited | Medium | No | stale proof | Defer until subset proof can include repaired state. |
| Learn first-week path | Code + focused Learn test; no current screenshot | Understand first week is about seeing the table before acting. | 8.0 | 7.0 confidence-limited | Medium-high | No | capture unavailable | Capture compact Learn; if dense, run Learn/Profile alignment pass. |
| Profile return rhythm | Code + focused Profile test; no current screenshot | Understand returns keep table clues warm. | 7.9 | 6.9 confidence-limited | Medium-high | No | capture unavailable | Capture compact Profile before deciding on visual repair. |
| First correct feedback | Existing current-ish compact screenshot + tests | Understand the first table-clue aha. | 9.0 | 8.8 | Low | No | none | Keep as benchmark for first-week surfaces. |

## 5. First-Week Journey Coherence Review

What is proven:

- Home includes the Week 1 frame: `Week 1: build table-reading habits`.
- Home keeps the dynamic first-value/daily title instead of hiding the exact receipt.
- Home includes: `Today: keep one table clue warm`.
- Home includes: `Sharky keeps the next useful hand ready.`
- Review includes: `Week 1 repair`.
- Review frames repair as: `Repair one open clue so tomorrow starts warmer.`
- Learn includes: `Your first week is about seeing the table before choosing.`
- Profile includes: `Week 1: each short return keeps one table clue warm.`
- Focused tests prove no `GTO`, `solver`, `optimal`, `frequency`, or `paywall` copy appears in the new proof assertions.
- First-value carry persistence still has focused test proof.

What is not proven:

- Whether these lines fit comfortably on compact Home, Review, Learn, and Profile screenshots.
- Whether the combined surfaces feel premium rather than text-heavy.
- Whether Profile and Learn visual density is acceptable on compact portrait after the new line.
- Whether Review open repair comparison rows feel calm enough visually.

## 6. Commercial Readability Issues

Known from static/test proof:

- The story is now coherent across surfaces.
- Copy is beginner-safe and avoids fake AI, solver, GTO, paywall, and dashboard positioning.
- Home preserved the exact first-value/daily title, which protects learning proof.

Confidence-limited risks:

- Home may now have one more line above the daily checklist; compact screenshot proof is needed to judge whether the new line helps or creates density.
- Learn and Profile are naturally denser surfaces; the added line may be correct but still visually secondary or buried.
- Review already has comparison language and repair details; the Week 1 label may help, but visual proof is needed before deciding whether copy density is acceptable.

No blocker is proven from code/test evidence alone.

## 7. Runout / Benchmark-Stack Comparison

Based only on visible/proven current behavior:

- Sharky remains stronger on deterministic learning proof: first clue, same-signal next rep, repair proof, and return reason are explicit.
- Runout-style products remain the packaging benchmark for polished visual presentation, motion, and commercial-grade screenshot confidence.
- This wave does not prove Sharky has caught Runout visually on Home/Review/Learn/Profile because fresh compact screenshots were not produced.
- Sharky's best benchmark move remains proof-first packaging: make the week loop visibly calm and table-native before any monetization push.

## 8. Blockers vs Follow-up Polish

| Item | Classification | Severity | Evidence | Action |
| --- | --- | --- | --- | --- |
| No fresh compact screenshots for Home/Review/Learn/Profile | Proof blocker | Medium-high | Existing tooling is full sweep; manual server did not become available in quota. | Add/approve a targeted compact proof seam or manual capture pass. |
| Home Week 1 copy visual fit | Follow-up polish risk | Medium | Code/test proof only. | Evaluate from compact screenshot before changing copy. |
| Review open repair density | Follow-up polish risk | Medium | Static knowledge of comparison rows; no fresh visual proof. | Evaluate from compact screenshot. |
| Learn/Profile density | Follow-up polish risk | Medium | Dense surfaces by nature; no fresh visual proof. | Evaluate from compact screenshot. |
| Commerce/paywall | Deferred | Low for current phase | Commerce remains parked; no new paywall copy. | Keep parked. |
| Unrelated Home test drift | Safe to defer | Medium | Existing broader Home tests have stale expectations. | Do not block this proof packet; keep focused lanes. |

## 9. Recommended Next Implementation Wave

Recommended next arc: Targeted Compact First-Week Capture Seam v1.

Mode: tooling/proof-only, bounded.

Goal:

Enable capture of only compact Home, Review, Learn, and Profile first-week states without running the full all-surface/all-viewport controlled-demo sweep.

Constraints:

- No product UI/copy changes.
- No dashboard, Skill Map, commerce, entitlement, route, or table changes.
- No broad Playwright rewrite.
- Seed only the existing first-week states needed for proof.

Why not Product Surface Premium Implementation Pack yet:

The current evidence proves product logic and copy presence, but not visual failure. Starting a premium implementation pass without fresh compact screenshots would risk polishing from assumption rather than evidence.

## 10. Deferred List

- Product Surface Premium Implementation Pack.
- Sharky Coach Presence + Trainer Voice Pass.
- First-Week Surface Readability Repair.
- Learn/Profile First-Week Alignment implementation.
- Repaired Review compact screenshot proof.
- Broad screenshot sweep.
- Broad stale preview-test cleanup.
- Commerce/paywall/receipt/entitlement work.
- Dashboard, Skill Map, Leak Profile, or new content families.

## 11. Direction Score

Current direction: 8.3 / 10.

Reasoning:

- Learning/story coherence: 8.6
- First-week return logic: 8.4
- Beginner safety: 8.8
- Commercial visual proof confidence: 6.8
- Tooling/proof readiness: 6.5

Sharky is moving in the right direction, but the first-week slice is not yet visually launch-proven. The product should not reopen implementation until compact screenshots show whether the issue is real surface density or just missing evidence.

## 12. Recommended Next Arc

Run Targeted Compact First-Week Capture Seam v1.

Acceptance for that next arc:

- Captures only compact Home, Review open repair, Learn, and Profile first-week states.
- Uses existing `Act0ShellPreviewScreenV1` and debug harness semantics.
- Does not run all viewports or all surfaces.
- Produces screenshot paths and manifest entries.
- Does not change product UX, copy, routes, telemetry, commerce, entitlement, table geometry, or content.

After that proof exists:

- If Home/Review score below 8, run First-Week Surface Readability Repair v1.
- If Learn/Profile are the weak surfaces, run Learn/Profile First-Week Alignment v1.
- If all four surfaces score 8+, run Sharky Coach Presence + Trainer Voice Pass v1 or Product Surface Premium Implementation Pack v1.
