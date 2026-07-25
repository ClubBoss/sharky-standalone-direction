---
status: "deep_teal_green_felt_landed"
status_source: "derived"
baseline: "2329f35abc0a"
generated_by: "docs_frontmatter_v1"
---

# Deep Teal-Green Felt Token PR v1

## 1. Verdict

deep_teal_green_felt_landed

## 2. Preflight

- Worktree: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/apply-owner-patch-sequence-a-b-c-d-v1`
- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`
- Starting HEAD: `2329f35abc0af00cdda4830e1c96aa1e4890d02c`
- Tracked dirty scope before artifact: only the expected felt implementation and focused test files.
- `output/**` remains local-only and uncommitted.

## 3. Final art-direction decision

Selected direction: `B_deep_teal_green`.

Visual verdict: `deep_teal_green_felt_visual_target_accepted`.

## 4. Token ownership

The active table material tokens live in `Act0TableFeltCanonV1` inside:

- `lib/ui_v2/act0_shell/act0_shell_tokens_v1.dart`

The active table renderer and on-felt consumers use those tokens through:

- `Act0ShellTokensV1.feltDecoration()`
- `Act0ShellTokensV1.tableRimDecoration()`
- `Act0ShellTokensV1.onFeltPanelDecoration()`

## 5. Implemented token values

- Felt center: `#146B56`
- Felt mid: `#0F5A47`
- Felt edge: `#0B4A3B`
- Radial center: `Alignment(0, -0.16)`
- Stops: `[0.0, 0.55, 1.0]`
- Rail fill: `#14273A`
- Inner hairline: `rgba(122,220,200,0.30)`
- Rail shadow: `rgba(20,60,80,0.35)`, blur `18`
- On-felt panel fill: `rgba(10,20,32,0.55)`
- On-felt panel border: `rgba(122,220,200,0.22)`
- Objective flag tint: `#7ADCC8`

## 6. Objective-banner treatment

The on-felt repair callout now uses the centralized on-felt glass panel treatment and the existing neutral `Icons.flag_rounded` glyph. The prior red alert icon treatment is removed from this active table callout.

## 7. Screenshot evidence

Local-only evidence:

- `output/deep_teal_green_felt_pr_v1/comparison_final_6_state.png`
- `output/deep_teal_green_felt_pr_v1/comparison_home_vs_table.png`
- `output/deep_teal_green_felt_pr_v1/screens/decision.png`
- `output/deep_teal_green_felt_pr_v1/screens/correct_feedback.png`
- `output/deep_teal_green_felt_pr_v1/screens/wrong_feedback.png`
- `output/deep_teal_green_felt_pr_v1/screens/repair_focus.png`
- `output/deep_teal_green_felt_pr_v1/screens/late_route_w11.png`
- `output/deep_teal_green_felt_pr_v1/screens/w12_payoff.png`

## 8. Card/suit/seat/action readability

The six-state evidence preserves white-card pop, red-suit readability, black-suit readability, seat clarity, hero anchor clarity, and action target clarity.

## 9. Felt/rail/shell three-zone separation

The final B direction keeps the felt, rail, and app shell/background as three distinct visual zones. The felt remains poker-readable and does not collapse into the shell.

## 10. Home-to-Table cohesion

The Home-vs-Table sheet shows improved cohesion with the shell while keeping the table as a distinct gameplay surface.

## 11. Focused validation

Passed:

```bash
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Act0 table felt canon uses final deep teal-green material tokens|Act0 felt decoration keeps the center clean and edge-weighted|Act0 table rim decoration uses refined rail material|Act0 on-felt repair callout uses neutral table identity material'
flutter analyze
graphify hook-check
git diff --check
git diff --cached --check
```

Required screenshot capture passed:

```bash
./tools/screen_review_fast_v1.sh first_week compact
./tools/screen_review_fast_v1.sh active_route_w7_w12 compact
```

Additional Home comparison capture passed:

```bash
./tools/screen_review_fast_v1.sh core compact
```

## 12. CTA contrast baseline verification

Classification: `cta_contrast_failure_preexisting_confirmed`.

Baseline proof used a detached temporary worktree at:

`2329f35abc0af00cdda4830e1c96aa1e4890d02c`

Baseline command:

```bash
flutter test test/ui_v2/act0_shell_tokens_v1_test.dart
```

Baseline failure:

```text
Deep Ocean Gold v1.1 keeps filled primary actions readable
Expected: a value greater than or equal to <4.5>
Actual: <3.014131782536772>
```

Current worktree command shows the same single failure with the same actual contrast value.

## 13. Known pre-existing issue

The primary CTA contrast assertion in `test/ui_v2/act0_shell_tokens_v1_test.dart` is pre-existing and unrelated to the felt-token PR. It should be handled first in the next `CTA Learn Cleanup PR`.

## 14. Scope safety

The committed scope is limited to:

- Table felt/rail/panel tokens.
- Active table renderer token consumption.
- On-felt repair callout material and neutral glyph.
- Focused token/material tests.

No geometry, card face colors, suit ink, chip colors, seat layout, route logic, copy, motion, Welcome, Review, Summary, Home structure, Practice, Profile, mapper, W13+, monetization, achievements, or Sharky progression changes were made.

## 15. Output/local-only status

`output/deep_teal_green_felt_pr_v1/` and `output/screen_review/` are local-only evidence and are not part of the commit.

## 16. Next recommendation

CTA Learn Cleanup PR
