#!/usr/bin/env bash
# DEPRECATED (Archived legacy tool)
# Historical helper script kept for traceability; not part of active tooling.

set -euo pipefail
rg -n -g '!**/*.g.dart' -g '!lib/plugins/**' "Colors\\.grey\\([0-9]{3}\\)" lib/ \
| cut -d: -f1 | sort -u | while read -r f; do perl -i -pe "s/Colors\\.grey\\(([0-9]{3})\\)/Colors.grey[\\$1]/g" "$f"; done
rg -n -g '!**/*.g.dart' -g '!lib/plugins/**' "context\\]" lib/ \
| cut -d: -f1 | sort -u | while read -r f; do perl -i -pe "s/context\\]/context)/g" "$f"; done
echo "fix_ui_safe_patterns: done"