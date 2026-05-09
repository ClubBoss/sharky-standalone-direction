#!/usr/bin/env bash
set -euo pipefail

zip_path="out/modern_table_screenshots_v1.zip"

if [[ ! -f "${zip_path}" ]]; then
  echo "Generating screenshots and zip..."
  dart run tools/modern_table_screenshot_v1.dart
  SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh
else
  echo "Using existing audit zip."
fi

dart run tools/modern_table_audit_hub_v1.dart
