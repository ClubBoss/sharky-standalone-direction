#!/usr/bin/env bash
set -euo pipefail

workspace_root="$(cd "$(dirname "$0")/.." && pwd)"

export STORE_PACKAGE_GUARD=1
export RELEASE_CONTENT_GUARD=1

echo "Step 1/5: run STORE_PACKAGE_GUARD assets contract"
(
  cd "$workspace_root"
  dart test test/contracts/store_package_assets_contract_test.dart -r expanded --concurrency=1 --timeout 2m
)

echo "Step 2/5: run docs sync contract"
(
  cd "$workspace_root"
  dart test test/contracts/store_package_docs_sync_contract_test.dart -r expanded --concurrency=1 --timeout 2m
)

echo "Step 3/5: run execution rules sync contract"
(
  cd "$workspace_root"
  dart test test/contracts/store_package_execution_rules_sync_contract_test.dart -r expanded --concurrency=1 --timeout 2m
)

echo "Step 4/5: run telemetry guard contract"
(
  cd "$workspace_root"
  dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m
)

echo "Step 5/5: run content guard contract"
(
  cd "$workspace_root"
  dart test test/contracts/release_content_meaningful_contract_test.dart -r expanded --concurrency=1 --timeout 2m
)

echo "Release dry run gate steps completed"
