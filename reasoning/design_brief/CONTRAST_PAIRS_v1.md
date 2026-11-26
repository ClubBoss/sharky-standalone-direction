# B112 · D5 — skin token contrast contract (WCAG AA)

Baseline: `origin/main` at `a85177b9c2e79ede5d879e74f6db17e4c449c0a7`.
Source: `lib/ui_v2/act0_shell/skin/act0_skin_tokens_v1.dart` (B32),
`act0_skin_components_v1.dart` and the kit's editorial/result, You, Settings
and Archive consumers. There is no B101 Variant-C token set on this baseline.

## Pair inventory

Each row with multiple foregrounds or surfaces denotes the indicated
foreground × surface combinations. Pair IDs are `foreground/background`;
`@base` denotes a translucent fill composited over that base. The test uses
the live Dart tokens, not the numbers or colours copied into this document.

| Foreground token(s) | Surface/fill token(s) | Kit role | AA minimum | Pairs |
|---|---|---|---:|---:|
| `onSurface`, `muted`, `caption` | `background`, `surface`, `raised` | Body, secondary, captions, section labels, headings; screen/card/sheet/list/answer, secondary and disabled primary button labels | 4.5 | 9 |
| `accent`, `ok`, `bad` | `background`, `surface`, `raised` | Links, feedback grades, compact answer verdicts, destructive row labels | 4.5 | 9 |
| `onAccent` | `accent` | Primary button | 4.5 | 1 |
| `accent` | `accentSoft` @ `background`, `surface`, `raised` | Brass chip label | 4.5 | 3 |
| `ok`, `onSurface` | `okSoft` @ `background`, `surface`, `raised` | Correct chip/answer verdict and answer text | 4.5 | 6 |
| `bad`, `onSurface` | `badSoft` @ `background`, `surface`, `raised` | Destructive button, wrong verdict and answer text | 4.5 | 6 |
| `editorialInk`, `editorialInkMuted`, `editorialFocus`, `editorialNeedsReviewFg` | `editorialPageSurface`, `editorialCardSurface` | Editorial reading/result text and emphasis | 4.5 | 8 |
| `editorialOnPrimaryAction` | `editorialPrimaryAction` | Editorial action role | 4.5 | 1 |
| `editorialNeedsReviewFg` | `editorialNeedsReviewBg` | Editorial review status role | 4.5 | 1 |
| `editorialCorrectFg` | `editorialCorrectBg` | Editorial correct status role | 4.5 | 1 |
| `academyOnSurface` | `background`, `surface`, `raised`, `academyBackground`, `academyRaised` | Large empty-state heading | 3.0 | 5 |
| `academyMuted` | Same five surfaces | Empty-state support text | 4.5 | 5 |
| `navyOnSurface`, `navyMuted` | `navyRaised`, `navySurface`, `surface` | Profile metric text (including inherited card backing) | 4.5 | 6 |
| `academyOnSurface` | `academyTeal` | Active switch thumb against track | 3.0 | 1 |
| `muted` | `track` | Inactive switch thumb against track | 3.0 | 1 |
| `courseProgressFill` | `courseProgressTrack` | Progress indicator | 3.0 | 1 |
| `academyAccent` | `background` | Settings loading indicator | 3.0 | 1 |
| **Total** | | | | **65** |

Text roles shared by normal text and large text/icons use the stricter 4.5
threshold. The disabled primary label (`caption/raised`) is also checked
as a kit contract even though inactive controls are exempt under WCAG.

## Current failures / ratchet

**None.** Independent sRGB calculation on the baseline found all 65
combinations above their applicable threshold. Lowest normal-text ratio:
`caption/raised` = **5.1360:1** (minimum 4.5). Lowest overall:
`academyOnSurface/academyTeal` = **4.7324:1** (minimum 3.0).

The explicit test allowlist is empty. No new failing pair may be added
to it. The exception schema records a pack/pair ID, reason and measured minimum
ratio; the guard rejects a worse ratio, a repaired exception that was not
removed, and orphaned exceptions. Never change token values
to make this test pass as part of B112.

## Maintaining the guard

`test/ui_v2/skin_contrast_guard_v1_test.dart` calculates relative
luminance from sRGB channels (linearization breakpoint 0.04045), then
`(lighter + 0.05) / (darker + 0.05)`. Alpha fills are composited before
measurement; an opaque backing is required. Ratios are compared without
rounding. The test is registered in the existing Tier A test lane.

A palette that replaces existing tokens is checked automatically. When a
new separate pack (including B101 Variant-C) or new semantic pairing lands,
register its live token pairs under a separate pack ID in this test and
extend this inventory in the same change. No source reflection or
automatic discovery of newly authored pairs is claimed.

This is a deterministic token-level guard, not a native screen audit:
image/gradient backdrops, caller-supplied colours, per-screen local
opacity, dynamic theme/state overlays, decorative rules and the Modern
Table are outside its scope. It does not certify complete WCAG AA or
close the broader V6/ACC-01 native readability requirements.
