#!/usr/bin/env bash
set -euo pipefail

timestamp=$(date -u +"%Y%m%dT%H%M%SZ")
log_dir="/private/tmp"
log_path="${log_dir}/poker_analyzer_phase_logs_${timestamp}.txt"

cat <<'EOF'
macOS debug runner helper
- Press q inside flutter run to quit.
- Set RUN_SOFTWARE_RENDERING=1 to run with software rendering (avoids GPU hangs).
EOF

echo "Log capture: ${log_path}"

args=("--debug")
if [[ "${RUN_SOFTWARE_RENDERING:-0}" == "1" ]]; then
  args+=("--enable-software-rendering")
fi

if [[ "${CAPTURE_LOG:-0}" == "1" ]]; then
  mkdir -p "$log_dir"
  flutter run -d macos "${args[@]}" 2>&1 | tee "${log_path}"
  echo "Log saved to ${log_path}"
  echo "RUN_PHASE4_REGRESSION_LOGS=1 PHASE4_LOG_INPUT=\"${log_path}\" bash tool/dev/precommit_sanity.sh"
else
  flutter run -d macos "${args[@]}"
fi
