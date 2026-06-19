# Compact English Premium Preview Proof v1

## 1. Wave Admission

Wave: Compact English Premium Preview Proof v1 — Canonical Capture Rerun
Mode: Proof/audit only. No product code, UI, copy, tests, routes, telemetry,
commerce, entitlement, paywall, screenshot tooling, Playwright tooling, table
geometry, content, or localization files changed.

## 2. Capture Method

- **Target URL (entry):** `http://127.0.0.1:7357/?act0_capture=practice&locale=en`
- **Interaction flow:** navigate to practice capture surface → enable
  accessibility gate → click "Start daily set" → click through runner spots
  (answer questions) until session completes → capture completion state →
  click "See what premium adds" → capture preview sheet
- **Viewport:** compact portrait `393 × 852` (verified: `page.viewportSize()
  = {w: 393, h: 852}`)
- **Locale lane:** `locale=en` in URL; `flutter.app_language_code` also
  confirmed "en" in running app state
- **Tooling:** existing Playwright CLI at
  `$HOME/.codex/skills/playwright/scripts/playwright_cli.sh`; session `ppv2`
  via `npx --yes --package @playwright/cli playwright-cli`. No tooling edits.
- **Server:** `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357`
  (PID `dart 95676`); confirmed live before capture.

**Capture log:**

| step | action | result |
| --- | --- | --- |
| preflight | `lsof -i :7357` + `curl http://127.0.0.1:7357/` | Server live, HTML served. |
| 1 | Open practice surface at `?act0_capture=practice&locale=en`, set 393×852 viewport, enable accessibility gate | Practice hub rendered: "Start daily set" visible. |
| 2 | Click "Start daily set" → enter runner | Runner loaded at step 2/6 "Tap the correct seat". |
| 3 | Click through runner spots (seat taps + spot-check answer choices) | Session completed; returned to practice hub. |
| 4 | Capture `practice_complete_compact_en.png` | ✅ Accepted. |
| 5 | Click "See what premium adds" | Premium preview sheet opened. |
| 6 | Capture `premium_preview_sheet_compact_en.png` | ✅ Accepted. |

**Architectural note:** The `?act0_capture=practice` surface always initialises
the pre-session practice hub (`done_for_today_supported: false` in all prior
manifests). The session-completed state with "See what premium adds" is
in-memory runtime state only reachable by completing the runner. The Playwright
CLI session interacted with the live runner to trigger the completion callback.

## 3. Screenshot Paths

| Surface | Screenshot | Status |
| --- | --- | --- |
| Practice — session completed result state | `output/playwright/premium_preview_proof_v1/practice_complete_compact_en.png` | ✅ captured |
| Premium preview sheet | `output/playwright/premium_preview_proof_v1/premium_preview_sheet_compact_en.png` | ✅ captured |

## 4. Completed Result State Review

**Screenshot:** `practice_complete_compact_en.png`

Visible elements confirmed in screenshot:

| element | value | pass? |
| --- | --- | --- |
| Header | "Done ✓  120 XP  4d" | ✅ |
| Hero card eyebrow | "Today's training" | ✅ |
| Hero card title | "Daily table trainer complete" | ✅ |
| Hero card meta | "Done for today · ~3 min" | ✅ |
| Hero card primary CTA | "Practice extra reps" (large filled blue button) | ✅ dominant |
| Completion card pill | "✓ Done for today" | ✅ |
| Completion card title | "Session complete" | ✅ |
| Completion card body | "Nice work — one table clue is warmer. Sharky has tomorrow's useful hand ready." | ✅ |
| Secondary CTA | "See what premium adds" (outlined, small, below completion card) | ✅ secondary |
| Below completion | "Nothing to repair right now." + "Skill packs" section | ✅ |

**Visual hierarchy verdict:** The primary free action ("Practice extra reps") is
visually dominant — large filled blue button inside the hero card. "See what
premium adds" is a secondary outlined button tucked beneath the "Session
complete" card. The hierarchy is correct: completion → free action → optional
premium preview entry. Preview feels earned, not intrusive.

## 5. Preview Sheet Review

**Screenshot:** `premium_preview_sheet_compact_en.png`

Visible elements confirmed in screenshot:

| element | value | pass? |
| --- | --- | --- |
| Sheet eyebrow | "Premium preview" (gold icon) | ✅ |
| Title | "Want more reps like this?" | ✅ |
| Summary | "Premium adds more practice after the free foundation, without changing today's free route." | ✅ |
| Trust section label | "Free right now" | ✅ |
| Trust line | "The free route stays open. Premium is optional extra practice for later." | ✅ |
| Value section label | "Premium adds later" | ✅ |
| Value point 1 | "more table-clue practice after the free foundation." | ✅ |
| Value point 2 | "Extra reps when one useful read feels worth sharpening." | ✅ |
| Value point 3 | "deeper review of missed reads after you have proof it helps." | ✅ |
| Value point 4 | "Longer route depth when you are ready." | ✅ |
| Footer | "No pressure. Keep using Sharky free until you want more depth." | ✅ |
| Primary CTA | "Stay on free route" (filled blue) | ✅ |
| Secondary CTA | "Maybe later" (outlined) | ✅ |

**Scroll fit:** Sheet fits compact portrait without requiring scroll to reach
"Stay on free route". All value points and the primary CTA are visible in a
single viewport frame.

## 6. Boundary-Neutral Copy Audit

Checked all rendered text against boundary-neutral constraints:

| check | result |
| --- | --- |
| "World 4" or "World 5" | ✅ not present |
| Any world-number unlock promise | ✅ not present |
| "unlock all" | ✅ not present |
| W4/W5 boundary framing | ✅ not present |
| Value points reference world numbers | ✅ none |

All four value points use practice-depth framing ("after the free foundation",
"when one useful read feels worth sharpening", "after you have proof it helps",
"when you are ready") — earned and conditional, not boundary-unlock promises.

## 7. Commerce / Paywall Safety Audit

| check | result |
| --- | --- |
| Price shown | ✅ none |
| Purchase / subscribe button | ✅ none |
| Trial mention | ✅ none |
| Restore button | ✅ none |
| Premium Hub route | ✅ none |
| Plan selector | ✅ none |
| Countdown or discount | ✅ none |
| "unlock all" | ✅ none |
| AI / adaptive / GTO / solver claim | ✅ none |
| Guaranteed improvement | ✅ none |
| Win-rate claim | ✅ none |

The sheet contains two CTAs only: "Stay on free route" (primary) and "Maybe
later" (secondary). Both dismiss the sheet without triggering any IAP or paywall
flow.

## 8. Verdict

**Accepted.**

The compact English proof confirms:

1. Premium preview appears only after session completion (earned context).
2. The free primary action ("Practice extra reps") remains visually dominant.
3. "See what premium adds" is secondary in both position and visual weight.
4. The preview sheet is commerce-safe: no price, no purchase, no trial, no
   paywall hub.
5. All copy is boundary-neutral: no world-number unlock promises.
6. "Stay on free route" is the primary CTA; the sheet is trust-safe.

## 9. Files Changed

- `docs/_reviews/compact_english_premium_preview_proof_v1.md`
- `output/playwright/premium_preview_proof_v1/practice_complete_compact_en.png` (new)
- `output/playwright/premium_preview_proof_v1/premium_preview_sheet_compact_en.png` (new)

## 10. Verification

- No product code, UI, copy, tests, routes, telemetry, commerce, entitlement,
  paywall, screenshot tooling, Playwright tooling, table geometry, content, or
  localization files changed.
- `git diff --check` passed (exit 0).
- No tests required; proof/audit only wave with no product code change.
- Two screenshots captured and visually reviewed.
- Playwright session `ppv2` closed after capture.

## 11. Direction Score

**9.2 / 10**

The premium preview strategy is implemented correctly. Post-value placement,
free-route dominance, trust-safe sheet copy, commerce-safe CTAs, and
boundary-neutral value framing all pass. The only minor open item is that the
capture path requires interactive session completion (no direct-state capture
URL exists for the completed practice state), which means this proof wave
requires a live runner interaction rather than a URL-param shortcut. This is a
workflow inconvenience, not a product quality issue.

## 12. Recommended Next Wave

The premium preview proof is accepted. The recommended next arc is:

1. If premium conversion evidence is needed: run a Russian-locale equivalent
   proof pass to confirm localized copy is equally boundary-neutral.
2. If readiness tracking: update `PROJECT_READINESS_EPICS_SSOT_v1.md` to close
   the premium preview visual proof seam.
3. Do not open paywall, entitlement activation, or pricing work until a
   deliberate commercial conversion wave is scoped.
4. Optional: add a `?act0_capture=practice_complete` direct-state surface to
   eliminate the need for interactive session completion in future proof passes.
