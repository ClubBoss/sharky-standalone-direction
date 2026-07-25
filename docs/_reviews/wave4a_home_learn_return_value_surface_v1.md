---
status: "undeclared"
status_source: "absent"
baseline: "e3b4eabdbb7c"
generated_by: "docs_frontmatter_v1"
---

# Wave 4A - Home / Learn / Return Value Surface Lift

## Objective

Improve the first-visible compact-phone value surface for Home, Learn, Learn lesson detail, and Day-2 return Home after Wave 1 / Wave 2 / Wave 2B without changing route semantics, correctness logic, feedback semantics, repair authority, telemetry, content architecture, monetization, tablet behavior, or Sharky assets.

## Terminal Verdict

wave4a_value_surface_complete_ready_for_review

## Baseline Branch / Head

- Baseline branch: `codex/wave2b-feedback-semantics-cleanup-v1`
- Baseline head: `e3b4eabdbb7c48f94d83af3dffb436321faa3860`

## Branch / Head

- Branch: `codex/wave4a-home-learn-return-value-surface-v1`
- Head at artifact creation: `e3b4eabdbb7c48f94d83af3dffb436321faa3860`
- Commit status: pending at artifact creation

## Files Changed

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/wave4a_home_learn_return_value_surface_v1.md`

## Screens Touched

- Home compact primary next-action card
- Learn compact current mission card
- Learn compact lesson detail / inline lesson panel copy
- Day-2 return Home compact repair-priority surface, preserved through the existing repair recommendation path

## Evidence Pack Abs Path

`/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1`

## Evidence Zip Abs Path

`/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1.zip`

## Compact Contact Sheet Abs Path

- Core: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact_core_contact_sheet.png`
- Day-2 return: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact_day2_return_contact_sheet.png`
- Full scroll: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact_full_scroll_contact_sheet.png`

## Key Screen Paths

- Home: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact.home.png`
- Learn: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact.learn.png`
- Learn detail: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact.learn_detail.png`
- Day-2 return Home: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact.return_home.png`
- Home full-scroll top: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact.home.scroll_01_top.png`
- Learn full-scroll top: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact.learn.scroll_01_top.png`

## Open Commands

```bash
open /Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1
open /Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact_core_contact_sheet.png
open /Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1/compact_day2_return_contact_sheet.png
open /Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1/output/design_review/wave4a_home_learn_return_value_surface_v1.zip
```

## Capture Tier

Tier 2-lite compact only:

- `./tools/screen_review_fast_v1.sh core compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Capture tooling was intentionally limited to the existing full lane contact sheets (`capture_tooling_limited_to_full_lane_contact_sheets`). Tablet capture was intentionally deferred by mission scope.

## Validation

- Red check: `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart` failed before production edits on the new Home value line.
- Green check: `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart` passed after the Home/Learn copy updates.
- Capture checks:
  - `./tools/screen_review_fast_v1.sh core compact` passed.
  - `./tools/screen_review_fast_v1.sh day2_return compact` passed.
  - `./tools/screen_review_fast_v1.sh full_scroll compact` passed.

## Known Limitations

- Tablet was not optimized or captured by scope.
- Profile was not product-touched. It appeared in existing capture lanes, but was intentionally deferred because its source surface is a larger proof/profile subsystem and not required for the bounded Home/Learn/return lift.
- Sharky placeholder art was preserved exactly; no asset replacement, animation work, or generated image work was done.
- The Day-2 return Home improvement is preservation-oriented: the existing repair-priority surface remains visible and claim-safe; no new repair semantics or fake progress were introduced.
- `output/screen_review/` and `output/design_review/` are local visual evidence only and should remain unstaged.

## Recommendation

Review compact contact sheets first, especially `compact_core_contact_sheet.png` and `compact_day2_return_contact_sheet.png`. If accepted, land the code/test/doc commit and keep local screenshot evidence out of git.

## Push Status

Pending at artifact creation.

## Worktree Status

Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/wave4a-home-learn-return-value-surface-v1`

Expected before commit:

- Tracked changes limited to Wave 4A code/test/doc files.
- Local-only evidence under `output/screen_review/` and `output/design_review/` remains untracked.
