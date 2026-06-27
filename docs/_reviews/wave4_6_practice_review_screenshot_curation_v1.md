# Wave 4.6 - Practice Review Active-State & Public Screenshot Curation v1

## 1. Verdict

wave4_6_practice_review_screenshot_curation_ready

## 2. Source findings

- Practice already rendered a launchable active repair queue above the daily hero when `active_repair_target_v1` was present, but visible copy still said "Current fix first" / "Your current fix", which made the active state feel less route-truth specific.
- Review already placed the active repair card before history/recovered content, but the visible card label "What to fix next" competed with the accepted repair/practice language.
- First-open placement launch chips used single-line fade behavior, which could visually truncate compact labels.
- Runner public screenshot candidates are strongest as individual images, not contact sheets; contact-sheet labels can crowd at the top and should not be treated as store/public-ready art.

## 3. Implementation summary

- Practice active queue copy now says "Active repair first", "Active repair", and "Same table clue as the miss."
- Practice CTA behavior and copy remain unchanged: `Practice this`.
- Review active card label now says "Practice this clue next."
- Placement ready-support chip was shortened from "First hand after" to "Hand after."
- Placement launch step chips now allow two-line wrapping instead of one-line fade truncation.

## 4. Practice active-state-first

- The Practice repair queue still renders before the daily hero only when at least one queue item is launchable through the existing active-repair target contract.
- History/passive queue rows remain display-only and do not receive a CTA.
- The active row still uses the existing row-level launch request and does not remove or resolve the queue item.

## 5. Review active-state-first

- The active Review state keeps the repair coach card before read-only history and recovered notes.
- The visible active label now points to the next learner action: "Practice this clue next."
- The existing `Practice this spot` CTA and callback path were preserved.

## 6. Table runner curation / hierarchy

- No Modern Table or runner layout code was changed.
- Runner packet evidence supports individual screenshots as candidates:
  - `output/screen_review/current/runner_fast/compact.decision.png`
  - `output/screen_review/current/runner_fast/compact.correct_feedback.png`
  - `output/screen_review/current/runner_fast/compact.wrong_feedback.png`
- `output/screen_review/current/runner_fast/contact_sheet.png` is useful for local review only; its sheet labels are crowded and should not be used as public artwork.

## 7. Placement truncation

- Launch path chips now wrap to two lines instead of fading mid-label.
- The compact placement capture shows `Quick check` and `First hand` as complete labels.
- The diagnostic support chip was shortened to `Hand after`.

## 8. Public screenshot candidate matrix

| Surface | Candidate path | Status | Notes |
| --- | --- | --- | --- |
| First open / placement | `output/screen_review/current/first_week_fast/compact.placement.png` | Candidate | Strong no-exam, no-paywall first-open proof; launch chips are no longer truncated. |
| Runner decision | `output/screen_review/current/runner_fast/compact.decision.png` | Candidate | Clean table-first decision frame; use the individual PNG, not the contact sheet. |
| Runner correct feedback | `output/screen_review/current/runner_fast/compact.correct_feedback.png` | Candidate | Shows earned proof and table clue payoff without solver/GTO claims. |
| Runner wrong feedback | `output/screen_review/current/runner_fast/compact.wrong_feedback.png` | Candidate | Shows honest repair prompt without fake completion claims. |
| Review active repair | `output/screen_review/current/day2_return_fast/compact.review_continuation.png` | Candidate | Clear active repair state and single `Practice this spot` CTA. |
| Practice empty state | `output/screen_review/current/core_fast/compact.practice.png` | Support only | Honest restrained empty state; not the strongest public lead image. |

## 9. Claim/copy safety

- No AI, chat, GTO, solver, premium, paywall, rating, radar, mastery, or broad personalization claims were added.
- No fixed, cleared, resolved, completed, or durable-history semantics were added to Practice or Review.
- Existing repair/proof language was reused and tightened.

## 10. Learner-visible improvement

- Practice now names the launchable repair row as an active repair rather than a generic/current fix.
- Review makes the next action clearer without adding a new Review system.
- Placement compact chips now preserve full labels in the first-open screenshot.

## 11. Anti-drift proof

- No route family was added.
- No progression, telemetry, drill engine, reward, profile, Learn, Home, monetization, AI/persona, or Modern Table behavior was changed.
- Generated screenshot outputs remain local-only under `output/screen_review/current/`.

## 12. Tests/checks

- `flutter test test/ui_v2/act0_play_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'First-run placement asks questions before the app shell|Placement diagnostic sends the recommended start through Welcome|Review keeps repeated pending evidence as one active note|Review keeps an open repair as compact truthful context'`

Final validation commands are recorded in the final report for this PR.

## 13. Screenshot evidence

- `./tools/screen_review_fast_v1.sh day2_return compact`
  - `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `./tools/screen_review_fast_v1.sh first_week compact`
  - `output/screen_review/current/first_week_fast/contact_sheet.png`
  - `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
  - `output/screen_review/current/full_scroll_fast/contact_sheet.png`
  - `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`
- `./tools/screen_review_fast_v1.sh core compact`
  - `output/screen_review/current/core_fast/contact_sheet.png`
  - `output/screen_review/current/core_fast/screen_review_core_fast.zip`
- `./tools/screen_review_fast_v1.sh runner compact`
  - `output/screen_review/current/runner_fast/contact_sheet.png`
  - `output/screen_review/current/runner_fast/screen_review_runner_fast.zip`

Generated screenshot artifacts were not staged for commit.
