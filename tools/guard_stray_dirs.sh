#!/usr/bin/env bash
set -euo pipefail
[ -f .gitmodules ] && { echo "::error::submodules are forbidden (.gitmodules found)"; exit 1; }
if git ls-files | grep -q -E '(^|/)обновились(/|$)'; then
  echo "::error::forbidden tracked dir 'обновились'"; exit 1
fi
echo "✅ Guard passed."
