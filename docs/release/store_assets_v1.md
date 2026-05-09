# Store Assets Pipeline v1

This document defines a minimal deterministic store-asset generation flow for audit and packaging.

## Generate assets

```bash
bash tools/store_assets_v1.sh
```

## What the script does

1. Runs the canonical deterministic screenshot harness.

```bash
dart run tools/modern_table_screenshot_v1.dart
SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh
```

2. Collects generated outputs into:

```text
out/store_assets/v1/
```

3. Creates the consolidated archive:

```text
out/store_assets_v1.zip
```

## Expected generated files

```text
out/store_assets/v1/modern_table_default.png
out/store_assets/v1/modern_table_json.png
out/store_assets/v1/modern_table_asset.png
out/store_assets/v1/modern_table_default_portrait.png
out/store_assets/v1/modern_table_json_portrait.png
out/store_assets/v1/modern_table_asset_portrait.png
out/store_assets/v1/modern_table_screenshots_v1.zip
out/store_assets_v1.zip
```

## App Store copy placeholders

- SSOT copy source: `docs/release/store_package_v1.md` (section: `App Store Copy SSOT v1`)
- Screenshot caption source: `docs/release/store_package_v1.md` (section: `Screenshot Selection Checklist v1`)
- Use this file only for generation commands and output locations.
