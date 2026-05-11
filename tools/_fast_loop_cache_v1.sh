#!/usr/bin/env bash

FAST_LOOP_CACHE_FILE_V1=".dart_tool/fast_loop_world1_v1.cache"

fast_loop_latest_mtime_v1() {
  local dir="$1"
  local latest
  if [[ ! -d "$dir" ]]; then
    echo 0
    return 0
  fi

  latest="$( (find "$dir" -type f -exec stat -f "%m" {} + 2>/dev/null || true) | sort -nr | head -n1 )"
  if [[ -z "$latest" ]]; then
    latest=0
  fi
  echo "$latest"
}

fast_loop_compute_cache_key_v1() {
  local root="$1"
  local head dirty lib_mtime test_mtime tools_mtime

  head="$(git -C "$root" rev-parse HEAD 2>/dev/null || echo no_git_repo)"
  dirty="$(git -C "$root" diff --name-only | LC_ALL=C sort)"
  lib_mtime="$(fast_loop_latest_mtime_v1 "$root/lib")"
  test_mtime="$(fast_loop_latest_mtime_v1 "$root/test")"
  tools_mtime="$(fast_loop_latest_mtime_v1 "$root/tools")"

  printf '%s\n%s\n%s\n%s\n%s\n' "$head" "$dirty" "$lib_mtime" "$test_mtime" "$tools_mtime"
}

fast_loop_cache_matches_v1() {
  local key="$1"
  [[ -f "$FAST_LOOP_CACHE_FILE_V1" ]] && [[ "$(cat "$FAST_LOOP_CACHE_FILE_V1")" == "$key" ]]
}

fast_loop_write_cache_v1() {
  local key="$1"
  mkdir -p .dart_tool
  printf '%s' "$key" > "$FAST_LOOP_CACHE_FILE_V1"
}
