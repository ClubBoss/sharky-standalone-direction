# Design Tokens - UI V2 Handoff Guide

## Overview
This document provides a centralized reference for all design tokens used in UI V2.
Designers and developers can use this guide to understand where to change colors, spacing, typography, and other visual properties without touching business logic.

## File Structure

```
lib/ui_v2/theme/
  ├── design_tokens.md          (this file - handoff guide)
  ├── ui_v2_brand_theme.dart    (brand theme tokens for UI V2)
  ├── ui_v2_colors.dart         (color palette tokens)
  └── ui_v2_typography.dart     (typography tokens)

lib/theme/
  ├── theme_v2.dart             (main theme builder)
  ├── brand_theme.dart          (BrandTheme extension)
  ├── app_colors.dart           (base color palette)
  └── app_typography.dart       (base typography)
```

## Color Palette (ui_v2_colors.dart)

### Primary Colors
- **primaryBrand**: #00B894 (teal-green) - Main brand color for buttons, highlights
- **accentSuccess**: #2ECC71 (green) - Success states, positive feedback
- **accentWarning**: #F1C40F (yellow) - Warnings, attention states

### Surface Colors
- **neutralBg**: #121212 - Main background (dark mode)
- **surface**: #1E1E1E - Card/container surfaces
- **surfaceVariant**: #232325 - AppBar and elevated surfaces
- **lightBackground**: #F2F2F4 - Main background (light mode)

### Text Colors
- **textPrimaryDark**: #FFFFFF - Primary text (dark mode)
- **textSecondaryDark**: #FFFFFFB3 (white70) - Secondary text (dark mode)
- **textPrimaryLight**: #000000 - Primary text (light mode)
- **textSecondaryLight**: #0000008A (black54) - Secondary text (light mode)

### Semantic Colors
- **success**: Colors.greenAccent - Success indicators
- **error**: Colors.red - Error states
- **warning**: Colors.yellow - Warning states
- **info**: Colors.blue - Informational states

### Borders & Outlines
- **outlineSoft**: #33FFFFFF - Subtle borders and dividers

## Typography (ui_v2_typography.dart)

### Heading Styles
- **h1**: 18sp, w600, textPrimaryDark - Main headings
- **h3**: 16sp, w600, textPrimaryDark - Section headings

### Body Styles
- **body**: 16sp, textSecondaryDark - Regular body text
- **label**: 14sp, w500, textSecondaryDark - Labels and buttons
- **caption**: 12sp, textSecondaryDark - Small text, captions

## Spacing (ui_v2_brand_theme.dart)

### Standard Spacing
- **spacingSmall**: 8px - Tight spacing (icon-to-text, compact UI)
- **spacingMedium**: 16px - Standard spacing (most common)
- **spacingLarge**: 24px - Wide spacing (section breaks)

### Border Radius
- **radius**: 12px - Standard corner radius for cards and containers

### Elevation
- **elevationLow**: 1 - Subtle elevation (cards at rest)
- **elevationMed**: 2 - Medium elevation (buttons, elevated cards)

## How to Change Design

### Rebranding Colors
1. Open `lib/ui_v2/theme/ui_v2_colors.dart`
2. Update the color constants (e.g., `primaryBrand`, `accentSuccess`)
3. Run `flutter run` to see changes live (hot reload supported)

### Adjusting Typography
1. Open `lib/ui_v2/theme/ui_v2_typography.dart`
2. Update font sizes, weights, or colors in the TextStyle definitions
3. Changes apply globally to all UI V2 components

### Modifying Spacing
1. Open `lib/ui_v2/theme/ui_v2_brand_theme.dart`
2. Update `spacingSmall`, `spacingMedium`, `spacingLarge` values
3. All UI V2 components will use the new spacing

### Theme Integration
All tokens are integrated via `buildThemeV2()` in `lib/theme/theme_v2.dart`.
The function returns a `ThemeData` with `BrandTheme` extension attached.

Access in widgets:
```dart
final brand = Theme.of(context).extension<BrandTheme>();
final spacing = brand?.spacingMedium ?? 16;
final radius = brand?.radius ?? 12;
```

## Design Checklist

Before handoff, verify:
- [ ] All colors are defined in `ui_v2_colors.dart` (no hardcoded hex in widgets)
- [ ] Typography uses `ui_v2_typography.dart` constants (no inline TextStyle)
- [ ] Spacing uses `BrandTheme` tokens (no magic numbers)
- [ ] Dark/light mode variants are defined
- [ ] ASCII-only documentation (no special unicode beyond standard emoji)

## Future Enhancements

Planned additions:
- Animation duration tokens (fast, normal, slow)
- Iconography guidelines (size tokens)
- Component-specific tokens (button sizes, input heights)
- A11y tokens (contrast ratios, touch targets)

## Contact

For design questions, refer to:
- Main theme: `lib/theme/theme_v2.dart`
- UI V2 components: `lib/ui_v2/`
- Health Dashboard check: `tools/health_dashboard.dart` -> "UI Design Tokens"
