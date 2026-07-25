---
status: "review_footer_density_followup_landed"
status_source: "derived"
baseline: "3b90b8957588"
generated_by: "docs_frontmatter_v1"
---

# Review Variant B Footer & Density Visual Follow-up v1

## 1. Verdict

`review_footer_density_followup_landed`

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `3b90b8957588fec649004e5b642f6b500a0893f9`
- Tracked dirty files at preflight: none
- Staged files at preflight: none
- Local-only `output/` folders were present and left uncommitted.
- `graphify hook-check` passed.

## 3. Previous State

The accepted Review Variant B direction was already in place: compact header, real repair card, How Review Works strip, honest footer, correct 0/1/>1 state gating, removed gradient banner, and preserved CTA behavior.

Screenshot review still showed the footer sitting too high, a large empty zone above the bottom nav, a disconnected footer icon/text relationship, a slightly heavy repair card, and a broad MISS slot label.

## 4. Footer Layout Changes

- Kept the 0/1 miss screen as a fixed layout for compact Review body heights that can fit the content.
- Moved the width cap inside the full-height column so the `Spacer()` can use the actual available body height.
- Kept small-phone fallback scroll behavior for tighter heights.
- Anchored the footer block near the bottom nav without adding extra nav padding or overlap.

## 5. Footer Component Treatment

- Converted the footer into a cohesive centered component.
- Kept the exact copy: `Nothing else is due. Misses land here the moment they happen.`
- Used a 19dp green check icon, 9dp gap, constrained max width, and left-aligned wrapping text inside the footer block.
- Did not add a card or new material/color system.

## 6. Repair-card Density Decision

Removed only the hardcoded low-priority sentence:

- `Keep this clue in view before your next hand.`

Preserved source-backed/load-bearing content:

- clue headline
- pattern label and working-on context
- `Next rep: spot the clue before choosing.`
- source-backed repair action line
- `Keep this read warm with one quick rep.`
- `Practice this spot` CTA and callback

This keeps one warm-up/reassurance line and avoids adjacent duplicate support sentences.

## 7. MISS Slot Label Decision

The filled MISS slot now derives the most specific honest clue label from the same repair-copy guard used by the card headline when available. For the current captured miss, it renders:

- `No-bet-yet clue`

If that specific guard text is unavailable, the slot falls back to a hyphenated form of the real mistake title rather than fabricating a narrower label.

## 8. Screenshot Evidence

- `./tools/screen_review_fast_v1.sh core compact`
  - inspected `output/screen_review/current/core_fast/compact.review.png`
- `./tools/screen_review_fast_v1.sh full_scroll compact`
  - inspected `output/screen_review/current/full_scroll_fast/compact.review.scroll_01_top.png`
  - inspected `output/screen_review/current/full_scroll_fast/compact.review.scroll_02_mid.png`
  - inspected `output/screen_review/current/full_scroll_fast/compact.review.scroll_03_bottom.png`

Result: footer is visually anchored near the bottom nav, the footer icon and copy read as one component, the repair card is lighter, and the MISS slot reads `No-bet-yet clue`.

## 9. Tests/Validation

- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`

Focused tests cover footer copy/content presence in 0/1 states, footer absence in >1 state, the `No-bet-yet clue` MISS slot label, and removal of the redundant hardcoded support line.

## 10. Scope Safety

Changed scope is limited to:

- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `test/ui_v2/act0_review_shell_v1_test.dart`
- this review artifact

No Welcome, Table, Session Summary, Learn, CTA token, Practice/Profile route, mapper, W13+, monetization, achievement, Sharky progression, or motion files were edited.

## 11. Remaining Evidence Gaps

- The screen-review harness captures the compact 1-miss Review state. The >1 state remains covered by focused widget tests rather than a generated screenshot.

## 12. Next Recommendation

`Table Felt Side-by-Side Exploration`
