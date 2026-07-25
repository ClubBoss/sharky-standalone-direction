---
status: "welcome_variant_b_composition_landed"
status_source: "derived"
baseline: "3d586d537035"
generated_by: "docs_frontmatter_v1"
---

# Welcome Variant B Composition PR v1

## Verdict

`welcome_variant_b_composition_landed`

The valuable dirty Welcome work was resumed and completed into the requested Welcome Variant B composition. The handoff screen now follows the section 2 structure from `Sharky Implementation Layout Specs v1`: header, 45/55 centered handoff group, visible Sharky presenter tile, centered headline/subline, single proof card, bridge copy, and full-width CTA.

## Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- HEAD: `3d586d5370359385dc9b23f52729447396db2ed2`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Dirty files resumed:
  - `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
  - `test/guards/act0_visual_ux_known_p1_copy_contract_test.dart`
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- Generated drift identified and excluded from scope:
  - `macos/Flutter/GeneratedPluginRegistrant.swift`

## Dirty Work Resumed

The existing dirty Welcome changes were valuable resume work, not stale drift. They already moved the handoff toward Variant B by removing the old duplicate lesson-ready copy, introducing a presenter-tile/proof-card direction, and aligning tests around the new handoff surface.

## Implementation Summary

- Rebuilt the final Welcome beat as a dedicated centered handoff composition.
- Preserved the prior framed guide-card treatment for earlier Welcome beats.
- Added responsive content width capped at `min(width - 48, 400)`.
- Added 45/55 spacer weighting around the handoff group.
- Added the existing Sharky mascot SVG presenter tile with responsive 64/80dp sizing.
- Added the exact subline: `Placement done. Sharky mapped your start.`
- Added the exact bridge copy: `One hand · about 2 minutes.`
- Updated the proof-card copy to:
  - `FIRST HAND READY`
  - `Your first useful hand is ready.`
  - `Learn keeps the next one visible after that.`
- Kept the CTA label as `Open first lesson`.

## Layout Spec Compliance

- `SafeArea` retained.
- Header remains first.
- Handoff group is centered in the remaining vertical lane.
- Proof card sits below the headline/subline inside the centered group.
- CTA stays full-width at the bottom.
- The bridge line sits directly above the CTA.
- Compact first-week screenshot confirms no visible clipping or overlap.

## Copy Changes

- Added: `Placement done. Sharky mapped your start.`
- Added: `One hand · about 2 minutes.`
- Removed from active handoff copy: `Your first lesson is ready.`
- Replaced: `Learn will keep the next one visible after that.`
- With: `Learn keeps the next one visible after that.`

## Sharky Asset Usage

The presenter tile uses existing registered Sharky mascot SVG assets under `assets/mascot/`. No new asset was added, and no generic placeholder or non-Sharky image was introduced.

## Screenshot Evidence

- Command: `./tools/screen_review_fast_v1.sh first_week compact`
- Evidence file: `output/screen_review/current/first_week_fast/compact.welcome_handoff.png`
- Result: compact Welcome handoff shows the Sharky presenter tile, centered headline/subline, proof card, bridge copy, and full-width CTA.
- Gap: the available fast review tool exposes `compact`; it does not expose a separate `360x640` lane.

## Tests And Validation

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Welcome completes one local micro win before Home handoff"`
- `flutter test test/guards/act0_visual_ux_known_p1_copy_contract_test.dart`
- `./tools/screen_review_fast_v1.sh first_week compact`

Final pre-commit validation is expected to rerun these plus analyzer and diff checks after generated drift restoration.

## Scope Safety

This PR stays inside Welcome scope:

- Welcome shell composition and copy.
- Welcome-focused preview test.
- Existing known P1 copy guard.
- Review artifact.

It does not touch Review/Table/Summary/Learn behavior, CTA tokens, Practice/Profile/routes, mapper seams, W13+, monetization, curriculum routing, or non-Welcome product behavior.

## Remaining Evidence Gaps

- No separate 360x640 screenshot was generated because the available tool only supports `first_week compact`.
- Full-suite testing was not part of this bounded PR; focused Welcome validation and analyzer are the intended proof set.

## Next Recommendation

Proceed with `Review Variant B Repair Bench PR` after this Welcome-only PR lands.
