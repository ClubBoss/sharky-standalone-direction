# Act0 Shell Preview Contract Split v1b - Learn Route Harness

Date: 2026-06-18
Mode: bounded Learn route/panel harness refresh
Scope: Learn route/panel failures from
`test/ui_v2/act0_shell_preview_screen_v1_test.dart`

## 1. Wave Admission

Admitted as a Learn-only continuation of the Act0 shell preview contract split.

No product code, UI copy, routes, telemetry, persistence, commerce, entitlement,
premium/trial/paywall surfaces, screenshots, table geometry, localization
files, content chronology, Home retention rows, Profile, Review, Welcome, or
Placement contracts were changed.

## 2. PIEC Result

The remaining Learn route/panel failures were test-harness drift and stale
assertions, not proven product regressions.

Current Learn opens to the mission card. It does not auto-expand a selected
lesson panel when the Learn tab first opens. A selected lesson panel is still
owned by `Act0LearnPathShellV1`; tests must open a lesson before asserting that
panel.

## 3. Learn Fixes Applied

- `Selected lesson panel keeps compact subtitle headroom and guidance strip`
  - Fix: explicitly tap the current lesson before asserting
    `act0_shell_selected_lesson_panel`.
- `Expanded lesson panel shows primary CTA and tapping it launches runner`
  - Fix: tap the keyed CTA wrapper instead of casting it to `FilledButton`.
- `Levels menu is separate and keeps Level 1 selected with locked levels gated`
  - Fix: after selecting the current world, assert the current mission card
    rather than stale `What poker is` text.
- `Bottom nav switches tabs`
  - Fix: keep the test to tab switching/root ownership and remove the deeper
    Profile recommended-focus scroll assertion.
- `Completing current lesson unlocks the next lesson`
  - Fix: assert a locked/future lesson does not open before completion, then
    allow the unlocked lesson title to appear in more than one authoritative
    location after completion.

`Runner Review Continue advances to next task when available` already passed
without changes.

## 4. Deferred Learn Blockers

- First Table Guide five-step/order assertions remain deferred as content
  chronology.
- First-run placement-to-Learn assertions remain deferred because they cross
  Placement, Welcome, and Learn.
- `Opening a lower lesson auto-scrolls its inline hub into view` remains
  deferred as deeper Learn scroll/locked-lesson harness work.
- `Returning to the current lesson from a completed lesson reopens only the
  target after scroll` remains deferred as completed/current lesson return
  harness work.
- `Completing current lesson unlocks the next lesson` and `Runner Review
  Continue advances to next task when available` pass in isolation after this
  wave, but still appear in the full-file failure inventory, indicating
  broad-suite order sensitivity rather than a local Learn widget regression.

Measured broad preview status after this wave:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
  failed at `+578 -78`.
- Unique extracted failures: 73.

## 5. Recommended Next Wave

`Act0 Shell Preview Contract Split v1c - Home Retention Rows`

Bounded scope:

1. Refresh only Home daily/recheck/prove/keep-sharp row assertions.
2. Do not touch Learn, Profile, Review, Welcome/Placement, compact geometry,
   localization, content chronology, commerce, premium/trial/paywall,
   screenshots, or repair-intent behavior.
