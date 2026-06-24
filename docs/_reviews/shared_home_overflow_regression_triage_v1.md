# Shared Home Overflow Regression Triage v1

## 1. Verdict

`diagnosed_with_tiny_fix`

The shared Home overflow was a localized `_HomeMetaPillV1` layout defect. The
metadata label now receives a bounded flexible slot and uses a one-line
ellipsis only when the available width is insufficient.

## 2. Failure summary

- Failing tests: the small-portrait entry assertions in W7, W8, W9, and W10
  campaign-routing contracts.
- Overflow: `RenderFlex overflowed by 6.2 pixels on the right`.
- Viewport: `360 x 640`, device pixel ratio `1.0`.
- Surface: Act0 Home mission command card metadata pills.
- Shared widget: `_HomeMetaPillV1` in
  `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`.
- Deterministic campaign-routing subtests remain passing.

## 3. Root cause analysis

The metadata pill is a `Row(mainAxisSize: MainAxisSize.min)` containing an
icon, fixed spacer, and unconstrained label. In the small-portrait Home card,
the row receives a maximum width of 274px; the long route label retains its
intrinsic width and overruns that maximum by 6.2px. Every W7-W10 test reaches
the same Home card before asserting its world entry, so all reproduce the same
failure.

This layout was present before this triage wave; it was not introduced by the
accepted metadata or curriculum documentation changes. Route logic remains
valid: the failure is presentation-level and independent of campaign pack
selection.

After the fix, the immediate `tester.takeException()` regression assertion is
clean. The older world-entry tests still fail their later expectation because
they boot canonical `AppRoot` yet wait only for archived map keys
(`world_campaign_open_N`, `world_campaign_next_pack_cta`, or map fallback).
Canonical entry now lands on the Act0 Home shell. That harness mismatch is
separate from the overflow and is not changed in this wave.

## 4. Scope classification

- Overflow: real localized regression/blocker for small-portrait rendering.
- Route-test key expectation after overflow removal: baseline test-harness
  limitation against the current canonical Act0 entry, not a curriculum or
  campaign-routing failure.
- This is not visual polish, Modern Table work, or a route-logic change.

## 5. Tiny fix eligibility

Eligible and implemented. `_HomeMetaPillV1` now wraps its label in `Flexible`
with `maxLines: 1` and `TextOverflow.ellipsis`. This preserves the full label
when space permits, preserves the icon and pill meaning, prevents a RenderFlex
overflow at constrained widths, and does not change copy sources, route logic,
curriculum status, or Home structure.

## 6. Tests / proof

Updated the W7 small-portrait route test to assert no rendering exception
immediately after Home layout. It failed before the fix with the exact 6.2px
overflow and passes that assertion after the fix.

The full W7 route file still has a later baseline failure because none of its
three expected archived-map keys are rendered by canonical AppRoot/Act0 Home.
The deterministic W7 campaign-pack subtest passes. The W8-W10 small-portrait
tests share the same obsolete key expectation and should be addressed only in a
separate, explicitly scoped test-harness/route-proof wave.

## 7. Existing behavior preserved

Campaign routing, W1-W36 status vocabulary, curriculum content, receipts,
Review, Home decision logic, first-week trust, and external packaging policy
are unchanged. Generated outputs remain uncommitted.

## 8. Next recommended wave

`Volume I Surface Contract Tiny Slice v1`

The actual small-portrait overflow is fixed. The remaining archived-map key
expectations are a separate test-harness mismatch and should not block honest
surface-contract planning; any harness change must be admitted independently.
