# Store Assets README

## Purpose
This folder documents the optional import layout for Store Package v1 imagery that may later be handed off to App Store Connect and Google Play metadata flows.

The enforced repo proof path is the tracked archive:

- `out/modern_table_screenshots_v1.zip`

with supporting notes in:

- `docs/release/store_assets_v1.md`
- `docs/release/submission_metadata_truth_v1.md`

## Naming Scheme
- Format: `<platform>-<set>-<index>.png`  
  - `<platform>`: `ios` or `android`.  
  - `<set>`: one of `hero`, `table`, `streak`, `offline`, `stats`, `insights`.  
  - `<index>`: two-digit sequence starting at `01`.

## Required Files
- `assets/store/ios/hero/ios-hero-01.png` (portrait hero table highlight)  
- `assets/store/ios/table/ios-table-01.png`, `ios-table-02.png`, `ios-table-03.png`  
- `assets/store/ios/streak/ios-streak-01.png`, `ios-streak-02.png`  
- `assets/store/ios/offline/ios-offline-01.png`  
- `assets/store/ios/stats/ios-stats-01.png`  
- `assets/store/android/hero/android-hero-01.png`, `android-hero-02.png`  
- `assets/store/android/table/android-table-01.png`, `android-table-02.png`  
- `assets/store/android/streak/android-streak-01.png`, `android-streak-02.png`  
- `assets/store/android/insights/android-insights-01.png`  
- `assets/store/android/offline/android-offline-01.png`

## Maintenance
1. When updating or adding a screenshot, drop the optimized PNG into the correct folder and increment the index.  
2. After adding files, mention the additions in `docs/release/store_package_v1.md` (Required Screenshot Sets section).  
3. This folder is optional import storage; the release gate does not require this layout to exist on mainline.
4. No runtime code is needed; these assets are referenced manually during release packaging.
