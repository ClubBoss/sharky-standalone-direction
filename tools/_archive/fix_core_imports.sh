#!/usr/bin/env bash
# DEPRECATED (Archived legacy tool)
# Historical helper script kept for traceability; not part of active tooling.

set -euo pipefail; shopt -s nullglob
mapfile -t FILES < <(rg -l -g '!**/*.g.dart' -g '!lib/plugins/**' -n "import ['\"]dart:core['\"] as core;")
changed=0
for f in "${FILES[@]}"; do
  rg -q "^import ['\"]dart:core['\"];" "$f" && continue
  perl -0777 -i -pe "s/(import\\s+['\"]dart:core['\"]\\s+as\\s+core;\\s*)/\\1import 'dart:core';\\n/s" "$f" && changed=$((changed+1))
done
echo "fix_core_imports: inserted plain dart:core in $changed files"