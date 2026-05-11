#!/usr/bin/env bash
set -euo pipefail

ROOT="$PWD"
if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  while [[ "$ROOT" != "/" ]]; do
    ROOT="$(dirname "$ROOT")"
    if [[ -f "$ROOT/pubspec.yaml" ]]; then
      break
    fi
  done
fi
cd "$ROOT"

repeat_runs=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repeat)
      if [[ $# -lt 2 ]]; then
        echo "Usage: ./tools/checkpoint_world1_v1_capture.sh [--repeat N]"
        exit 2
      fi
      repeat_runs="$2"
      shift 2
      ;;
    *)
      echo "Unknown flag: $1"
      echo "Usage: ./tools/checkpoint_world1_v1_capture.sh [--repeat N]"
      exit 2
      ;;
  esac
done

if ! [[ "$repeat_runs" =~ ^[0-9]+$ ]] || [[ "$repeat_runs" -lt 1 ]]; then
  echo "--repeat requires a positive integer"
  exit 2
fi

mkdir -p out

run_once() {
  local run_index="$1"
  local ts
  ts="$(date -u +%Y%m%dT%H%M%SZ)"
  local stamp="${ts}_run${run_index}"
  local log_path="out/checkpoint_full_suite_${stamp}.log"
  local summary_path="out/checkpoint_failure_summary_${stamp}.txt"
  local cmd="CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint"
  local started ended elapsed rc

  started="$(date +%s)"
  set +e
  CHECKPOINT=1 ./tools/release_gate_world1.sh --checkpoint >"$log_path" 2>&1
  rc=$?
  set -e
  ended="$(date +%s)"
  elapsed=$((ended - started))

  if [[ "$rc" -eq 0 ]]; then
    echo "[capture] PASS run ${run_index}/${repeat_runs} (${elapsed}s)"
    echo "[capture] log: ${log_path}"
    return 0
  fi

  local first_fail_line
  first_fail_line="$(grep -m1 -E '^[0-9]{2}:[0-9]{2} \+[0-9]+.*-[0-9]+: .*(test/.*\.dart)' "$log_path" || true)"
  if [[ -z "$first_fail_line" ]]; then
    first_fail_line="$(grep -m1 -E '(test/.*\.dart)' "$log_path" || true)"
  fi

  local first_fail_test
  first_fail_test="$(echo "$first_fail_line" | sed -n 's#.*\(test/[^ :]*\.dart\).*#\1#p')"
  if [[ -z "$first_fail_test" ]]; then
    first_fail_test="unknown"
  fi

  local random_seed
  random_seed="$(grep -m1 -E 'Randomized with seed|random seed|--test-randomize-ordering-seed' "$log_path" || true)"
  if [[ -z "$random_seed" ]]; then
    random_seed="none"
  fi

  local first_assertion
  first_assertion="$(grep -m1 -E 'Expected:|Actual:|Which:|TimeoutException|Test failed|Exception:' "$log_path" || true)"
  if [[ -z "$first_assertion" ]]; then
    first_assertion="(no assertion line found)"
  fi

  local stack_snippet
  stack_snippet="$(awk 'f && c<10 {print; c++} /^#0 / {f=1; c=0; print; c++}' "$log_path")"
  if [[ -z "$stack_snippet" ]]; then
    stack_snippet="(no stack snippet found)"
  fi

  local timer_hints
  timer_hints="$(grep -E 'pending timer|A Timer is still pending|open handles|pending microtask|pumpAndSettle timed out' "$log_path" || true)"
  if [[ -z "$timer_hints" ]]; then
    timer_hints="(no timer/handle hints found)"
  fi

  local frame_clock_hints
  frame_clock_hints="$(grep -E 'frame|clock|pumpAndSettle|SchedulerBinding|timeDilation|timings' "$log_path" | tail -n 20 || true)"
  if [[ -z "$frame_clock_hints" ]]; then
    frame_clock_hints="(no frame/clock hints found)"
  fi

  local run_order
  run_order="$(grep -E '^[0-9]{2}:[0-9]{2} \+[0-9]+.*loading .*/test/.*\.dart' "$log_path" | sed 's#.*loading /#/#' | head -n 50 || true)"

  local tail_snippet
  tail_snippet="$(tail -n 80 "$log_path" || true)"
  if [[ -z "$tail_snippet" ]]; then
    tail_snippet="(no tail snippet found)"
  fi

  {
    echo "Checkpoint Failure Summary"
    echo "timestamp_utc: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "elapsed_seconds: ${elapsed}"
    echo "exit_code: ${rc}"
    echo "command: ${cmd}"
    echo "log_file: ${log_path}"
    echo "first_failing_test: ${first_fail_test}"
    echo "first_failing_line: ${first_fail_line}"
    echo "first_assertion_line: ${first_assertion}"
    echo "random_seed: ${random_seed}"
    echo
    echo "stack_snippet:"
    echo "${stack_snippet}"
    echo
    echo "timer_or_handle_hints:"
    echo "${timer_hints}"
    echo
    echo "frame_clock_hints_tail:"
    echo "${frame_clock_hints}"
    echo
    echo "run_order_head:"
    echo "${run_order}"
    echo
    echo "log_tail:"
    echo "${tail_snippet}"
    echo
    echo "reproduce: ${cmd}"
  } >"$summary_path"

  echo "[capture] FAIL run ${run_index}/${repeat_runs} (${elapsed}s)"
  echo "[capture] log: ${log_path}"
  echo "[capture] summary: ${summary_path}"
  echo "[capture] reproduce: ${cmd}"
  return "$rc"
}

run=1
while [[ "$run" -le "$repeat_runs" ]]; do
  run_once "$run" || exit $?
  run=$((run + 1))
done

exit 0
