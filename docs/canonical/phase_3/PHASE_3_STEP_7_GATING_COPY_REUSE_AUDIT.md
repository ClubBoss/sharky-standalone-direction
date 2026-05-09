# Phase 3 Step 7 - Gating Copy Reuse Audit (Progress Map V2)

## Current observed messaging on locked tiles
- `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`:
  - Locked tiles use lock icon + muted styling; no explicit text label for locked state.
  - Locked tiles are non-interactive (onTap null when `isUnlocked` is false).
  - There is no explicit “complete previous level” text in this file.

## Reuse candidates found
- `AppLocalizations.packStatusLocked` exists in localization files:
  - `lib/l10n/app_localizations.dart` (getter `packStatusLocked`).
  - `lib/l10n/app_localizations_en.dart` and other locales return "Locked".
- No existing “Complete previous” or “Complete previous level” localized string found.

## Recommendation
- Safe reuse exists: show the localized `packStatusLocked` label on locked tiles.
- Minimal patch (single file): `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`.
  - Add a small caption under the level tag or under the title when `!isUnlocked`, using `l10n.packStatusLocked`.
  - No new strings, no new localization keys, no logic changes.
