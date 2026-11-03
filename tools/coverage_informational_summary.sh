#!/usr/bin/env bash
# Called with always(): a report failure must retain diagnostics and stay red.
set -euo pipefail
mkdir -p build/reports
status=PASS
pub=FAIL
l2=FAIL
l3=FAIL
[[ ${PUB_OUTCOME:-} != success ]] || pub=PASS
if [[ ${L2_OUTCOME:-} == success && -s build/reports/l2_report.md ]]; then
  l2=PASS
elif [[ ${L2_OUTCOME:-} == skipped ]]; then
  l2=SKIP
fi
if [[ ${L3_OUTCOME:-} == success && ${L3_RESULT:-} == PASS && -s build/reports/l3_report.md ]]; then
  l3=PASS
elif [[ ${L3_OUTCOME:-} == skipped || ( ${L3_OUTCOME:-} == success && ${L3_RESULT:-} == SKIP ) ]]; then
  l3=SKIP
fi
if [[ ${COVERAGE_JOB_STATUS:-} != success || $pub != PASS || $l2 != PASS || $l3 == FAIL ]]; then
  status=FAIL
fi
{
  echo "# Informational coverage: $status"
  echo
  echo 'Content metrics only. This does not replace required Test Authority Lanes / Canonical authority (Tier A + terminal Tier B), or establish learner/release readiness.'
  echo
  echo "- Dependency resolution: $pub (step: ${PUB_OUTCOME:-not run})"
  echo "- L2: $l2 (step: ${L2_OUTCOME:-not run})"
  echo "- L3: $l3 (step: ${L3_OUTCOME:-not run})"
  if [[ $l3 == SKIP && ${L3_RESULT:-} == SKIP ]]; then
    echo '  No L3 packrun JSON inputs; no L3 report was generated.'
  elif [[ $l3 == SKIP ]]; then
    echo '  L3 did not run because an earlier step failed or was cancelled.'
  fi
  for level in l2 l3; do
    report="build/reports/${level}_report.md"
    if [[ -s $report ]]; then
      echo
      cat "$report"
    fi
  done
} > build/reports/coverage_status.md
cat build/reports/coverage_status.md >> "${GITHUB_STEP_SUMMARY:?}"
[[ $status == PASS ]]
