Modern Table Visual Audit v1
============================

Purpose
Deterministic Modern Table visual audit loop with reproducible outputs.

One-command flow
bash tools/modern_table_audit_run_v1.sh

What it does
- Generates screenshots if missing.
- Creates the zip bundle.
- Prints audit pack hint, audit note checklist, and PR snippet.

Expected outputs
- out/modern_table_default.png
- out/modern_table_json.png
- out/modern_table_asset.png
- out/modern_table_default_portrait.png
- out/modern_table_json_portrait.png
- out/modern_table_asset_portrait.png
- out/modern_table_screenshots_v1.zip

Troubleshooting (explicit commands)
dart run tools/modern_table_screenshot_v1.dart
SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh

Optional root
You can run the audit tools against an alternate root:
dart run tools/modern_table_audit_hub_v1.dart --root /path/to/root
Single positional root is also accepted.

Do not
- Do not use manual in-app screenshots; use the harness only.
