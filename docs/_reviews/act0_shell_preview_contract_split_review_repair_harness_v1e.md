# Act0 Shell Preview Contract Split v1e - Review Repair Harness

## Wave Admission

Bounded Review repair harness stabilization only. No product code, content,
route, telemetry, commerce, screenshot, localization, or layout implementation
changes were made in this wave.

## PIEC Result

Existing Review source truth still exposes Review board, repair card, theory
recall, action-trail replay, and pattern-card seams. The failing broad-preview
assertions in this wave were stale harness expectations against current Review
copy, current inline theory recall flow, and viewport-gated Review replay/pattern
surfaces.

## Review Failure Inventory

- Russian clean-state Review expected stale title/key/body contract.
- Repeated wrong-answer Review expected old deep-leak taxonomy and a stale
  Profile assertion in the same test.
- Quick fix replay expected the old repaired-card quality line.
- Theory recall tests expected full idea copy immediately after opening recall;
  current flow opens the quick-hint sheet first.
- The read-only recall affordance expected visible `Need a hint?` text, while
  current compact CTA is key/icon driven.
- Review action-trail replay used a compact viewport where the fixed lower slot
  intentionally suppresses the trail.
- Dominant repair-pattern Review card used a compact viewport while the pattern
  card is tablet-gated.
- Mixed Review/Profile smoke test included stale Profile assertions and old
  Review owner keys.

## Old Assertions To Current Behavior

- `Разбор ошибок` now maps to localized `Повтор` with the current clean-state
  board headline and body.
- `act0_shell_review_empty_body` now maps to
  `act0_shell_review_board_body`.
- Clean Review support now uses `act0_shell_review_clean_sharky_line`.
- Old `Deep leak`/attempt-badge checks now map to the active mistake card,
  reason, and decision strip contract.
- `Clear path still open.` now maps to `This clue is cleaner now.` after repair.
- Opening theory recall first proves `act0_shell_theory_recall_sheet` and
  `act0_shell_hint_body`; full idea copy appears after
  `act0_shell_review_full_idea_cta` when that CTA is present.
- Review action-trail replay controls are asserted at tablet size, where the
  current runner exposes the replay trail instead of using the fixed compact
  lower slot.
- Review pattern card is asserted at tablet size, matching the current
  left-column/tablet-gated contract.

## Fixes Applied

- Refreshed stale Review clean-state, repair-card, theory-recall, action-trail,
  pattern-card, and mixed smoke assertions in
  `test/ui_v2/act0_shell_preview_screen_v1_test.dart`.
- Added a local test helper to open the full theory recall idea after the
  current quick-hint sheet appears.
- Split the mixed Review/Profile smoke assertion down to Review-only behavior
  for this wave.

## Broad Suite Status

The Review-focused tests touched in this wave pass. The full broad preview file
still fails with non-Review groups: Home, Placement, Welcome, Learn/runner
compact geometry, Profile seeding, action-trail drill, lesson progression, and
world-completion retention assertions.

## Deferred

Non-Review failures remain intentionally deferred to their own bounded split
waves. This wave did not widen into Home, Placement, Learn, Profile, Welcome,
runner geometry, content, routes, or retention behavior.

## Recommended Next Wave

Act0 Shell Preview Contract Split v1f - Placement and Welcome Harness.
