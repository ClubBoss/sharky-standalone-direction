# Visual System Inventory v1

## PIEC Findings
- **Release visual SSOT**: `lib/sharky/design_tokens_v1.dart` defines colors, radii, elevations, opacities, and typography presets for non-table UI surfaces. This is the closest thing to a canonical token set outside the poker table.  
- **Additional theme files**: `lib/theme/app_colors.dart` and `lib/theme/app_typography.dart` add semantic colors & typography that the v2 UI uses (AppColors/ AppTypography). No single consolidated handbook exists yet—tokens are split between `SharkyTokensV1`, `AppColors`, `AppTypography`, and assorted inline styles.
- **Gaps**: Ad-hoc `TextStyle`/`Color` overrides proliferate in `design/components/*.dart`, `lib/ui_v2/*`, and `lib/widgets/*`. Icons/spacings often come from inline constants rather than tokens, so there is no single SSOT for spaces/elevation outside `SharkyTokensV1`.

## Colors
- `SharkyTokensV1`: surfaces (`surfaceApp`, `surfaceCard`, `surfaceElevated`, `surfaceFelt`), brand (`brandPrimary`, `brandGlow`), semantic (`semanticWin`, etc.), accents (`slate500`, `amber500`, `emerald500`), opacity helpers. Used via imports in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, `lib/ui_v2/home/home_screen.dart`, and many `lib/ui_v2/components/*`.
- `AppColors`: semantic background/text pairs (`darkBackground`, `button`, `success`, `error`, etc.) targeting the v2 experience; referenced in `lib/ui_v2/onboarding/*`, `lib/ui_v2/screens/*`, `design/components/*.dart`.  
- `AppColors.surfaceVariant`, `outlineSoft`, `progressBackground`, `overlay`, `shadow`, `neutral` appear repeatedly in `lib/ui_v2/map`, `lib/ui/modules`, `design/components`. Document that tokens need synchronization between files (partial SSOT).

## Typography
- `SharkyTokensV1` presets: `displayLg` 32/700, `headingMd` 20/600, `headingSm` 16/600, `bodyMd` 14/400, `bodySm` 12/400, `labelXs` 10/500. Used in `lib/ui_v2/home/home_screen.dart` and `design/components/...`.
- `AppTypography` (see `lib/theme/app_typography.dart`) mirrors headline/body/caption/label styles used extensively across onboarding screens, HUD overlays, and review/report components (`lib/ui_v2/onboarding/*`, `lib/ui_v2/session/*`, `lib/ui_v2/components/*`).  
- Inline text styles noted in `release/_reports/visual_token_violations.txt` show where custom `.copyWith(color: Colors.grey)` etc. drift from tokens; these should be consolidated under AppTypography to complete the SSOT.

## Spacing Scale
- `SharkyTokensV1` defines radii and elevations but not explicit spacing. `AppSpacing` (see `lib/theme/app_spacing.dart`) provides spacing keys (tight, md, etc.) used in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` and other v2 screens—document these derived scales and mention `SharkyTokensV1` implicitly infers spacing via the repeated use of `AppSpacing.sm/lg`.
- Additional spacing values found inline (e.g., `const EdgeInsets.all(AppSpacing.lg)`, `SizedBox(width: 4)`) suggest gaps between tokenized spacing and custom paddings.

## Corners & Elevation
- `SharkyTokensV1` defines radii (6/14/24/999) and elevations (0–3 plus glow). Referenced by `lib/ui_v2/home/home_screen.dart`, `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart` (see connectors, card containers), and `lib/ui/modules/modules_screen.dart`.  
- `BoxShadow` tokens from `SharkyTokensV1` should be reused wherever drop shadows exist; the inventory notes `release/_reports/visual_token_violations.txt` entries where inline `BoxShadow` definitions still appear in `design/components` files.

## Icons & Assets
- Icons originate from Flutter’s built-in set (e.g., `Icons.local_fire_department`, `Icons.check_circle`, `Icons.play_circle_fill` in `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`).  
- ASCII/iconography refers to `lib/ui_v2/session/ui_v2_session_result_screen.dart` and `lib/ui_v2/onboarding/value_proposition_widget.dart`, where text-based icons and custom glyphs are used; no reusable icon token set yet.  
- Suggest documenting a future icon SSOT; currently icons are reused inline and in the `design/components` library.

## Gaps
- **Partial SSOT**: `SharkyTokensV1` provides colors/radii/elevations/typography but only for the “Sharky” design tokens; the v2 UI uses `AppColors`/`AppTypography` with overlapping semantics.  
- **Spacing & Icon tokens missing**: No single file lists spacing increments beyond `AppSpacing`, and icon sizes/sources are ad-hoc (Symbols from `Icons.*` sprinkled across files).  
- **Inline overrides**: The `release/_reports/visual_token_violations.txt` log shows numerous `.copyWith` calls and direct `Colors.grey`/`Colors.white` uses—these are opportunities to extend the SSOT rather than creating new tokens.  
