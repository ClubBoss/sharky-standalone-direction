# B101 · Skin swap gaps

Scope: V6.pre rehearsal only, from the current Act0 learner surfaces; not visual acceptance of V6/V7. Variant C is a test palette (navy and soft teal, [PR #634](https://github.com/ClubBoss/sharky-standalone-direction/pull/634)); it does not ship. No edits to geometry, typography metrics, assets, copy, routes or Modern Table owners.

## Gap count and disposition

**One source-established whole-surface dependency gap (Placement), ten literal sites migrated. Render-confirmed gap count: not yet measured.** The English Placement intro flows through `act0_placement_shell_v1.dart:582–609` into `Act0AcademyOnboardingLeafV1`, whose palette at `academy_leaves/act0_academy_onboarding_leaf_v1.dart:44–51` and action bar at `:367–394` did not reference the B32 skin. Home and Review also consume this palette, even when their shared buttons already consume skin tokens. Replacing the ten duplicate declarations with exact-value aliases is the entire production change. Their old lines/values are below (paths relative to `lib/ui_v2/act0_shell/`).

| Original file:line | Literal before change | Canonical token |
|---|---|---|
| `academy_leaves/act0_academy_leaf_style_v1.dart:16` | `0xFF020E13` | `academyBackground` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:17` | `0xFF071C24` | `academyRaised` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:18` | `0xFF0B3530` | `academyTealDeep` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:19` | `0xFF177D70` | `academyTeal` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:20` | `0xFF23E6D2` | `academyAccent` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:21` | `0xFFB9F5E9` | `academyAccentSoft` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:22` | `0xFFF1FBF8` | `academyOnSurface` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:23` | `0xFFB6C8D5` | `academyMuted` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:24` | `0xFF23443F` | `academyLine` |
| `academy_leaves/act0_academy_leaf_style_v1.dart:25` | `0xFFF2C46B` | `academyWarn` |

The original declarations match the current default canonical tokens exactly. B66's per-file ceiling was reduced 12 → 2, not extended. The migration remains conditional on CI's default-pixel parity check.

## Remaining source-visible candidates (not measured whole-surface failures)

These are explicit unchanged paint sites in the affected path. They are not added to the count of failed surface renders: a surface can change while some of its children do not. Do not change or add designer roles speculatively before the actual pack arrives.

| File:line (current source) | Unchanged value | Why left |
|---|---|---|
| `academy_leaves/act0_academy_onboarding_leaf_v1.dart:81` | `0xB3020E13` twice | Placement's photo gradient: no exact existing alpha role. |
| `academy_leaves/act0_academy_leaf_style_v1.dart:162` | `0xFF19796F` | Shared active border: no exact existing role. |
| `academy_leaves/act0_academy_leaf_style_v1.dart:168` | `0x38000000` | Shared shadow: no exact existing role. |
| `act0_club_night_tokens_v1.dart:20–44` | e.g. `wall=0xFF0E1311`, `text=0xFFF4EFE4`, `brass=0xFFD8B46A` | Separate shared palette still used by some Home/Review/runner components. Not a proven wholly unchanged surface; no additional migration without rendered evidence. |
| `act0_academy_design_tokens_v1.dart:12–26` | e.g. `pageSurface=0xFFF7F5ED`, `ink=0xFF182E32`, `focus=0xFF126761` | Separate editorial palette remains in mixed legacy surfaces. Not a proven wholly unchanged surface. |
| `act0_shell_tokens_v1.dart:6–19, 87–113` | e.g. `deepNavy=0xFF081220`, `bluePrimary=0xFF0A64D8`, `textPrimary=0xFFFFFFFF` | Shared table/shell roles; no alteration to Modern Table allowed. |

B66 retains the rest of the per-file static inventory. This rehearsal checks response of the named surface, not complete per-widget token adoption or all spacing/typography roles.

## Reproduce / gate

Run `python3 tools/test_authority/skin_swap_rehearsal_v1.py` (Tier A invokes this). Production skin members are static constants, so changing only `ThemeData` would be a false rehearsal. The driver makes one isolated scratch project under `.dart_tool`, uses cached dependencies offline, and compiles the same production widget fixture in three passes:

1. Default skin with the original Academy literals restored in the scratch copy. Capture full viewport, actual surface region, and isolated Modern Table scene in both runner states (registered-six drill; theory retains its actual renderer) as raw RGBA plus dimensions.
2. Default skin with the migrated aliases. Require byte-identical default captures, including full chrome.
3. Variant C replaces the complete canonical token file **only in the scratch copy**. Require a changed rendered pixel within every surface region (Welcome, Placement, Home, runner theory and drill, Result, Review, You) and byte-identical Modern Table paint in both runner states (actual scene subtree, not a screenshot of overlays). Failure prints the surface name. No baseline auto-update, tolerances, or missing-baseline bypass in the driver.

All passes hold EN, 393×852 at DPR 1, safe-area insets, learner state, clock and reduced motion fixed. The scratch copy is disposed on exit; standalone `flutter test` of the new fixture is only a smoke run, not swap evidence. Report new failures here with source locations/values before calling the rehearsal complete.

**Local evidence:** variant static API check passed; reconstructed original palette equals pre-edit HEAD (excluding the new import); targeted Dart analysis clean; B66 passed 3/3. Flutter rendering/default goldens and CI are not run locally per `_rules_tech.md` (localhost socket blocked); no rendered result or final leak count claimed.
