#!/bin/zsh
# Usage: tools/post_rebase_check_v1.sh <worktree>
# Run this after rebasing, with the worktree's Dart dependencies resolved.
emulate -L zsh
unsetopt bg_nice

if (( $# != 1 )); then
  print -u2 'Usage: tools/post_rebase_check_v1.sh <worktree>'
  exit 2
fi
cd -- "$1" || exit 2
if [[ ! -d test/guards ]]; then
  print -u2 'Expected test/guards in the target worktree'
  exit 2
fi

dart_bin=${commands[dart]:-dart}
# Bypass the Flutter SDK launcher when Dart comes from a Flutter install.
sdk_dart=${dart_bin:A:h}/cache/dart-sdk/bin/dart
[[ -x $sdk_dart ]] && dart_bin=$sdk_dart

run_check() {
  local file=$1
  shift
  local child deadline=$(( SECONDS + 300 ))
  # Give the command its own process group so the timeout also stops workers.
  python3 -I -c 'import os, sys; os.setsid(); os.execvp(sys.argv[1], sys.argv[1:])' "$@" &
  child=$!
  while kill -0 "$child" 2>/dev/null; do
    if (( SECONDS >= deadline )); then
      kill -KILL -- -"$child" 2>/dev/null || kill -KILL "$child" 2>/dev/null
      wait "$child" 2>/dev/null
      print "FAIL $file (300-second timeout)"
      return 1
    fi
    sleep 0.2
  done
  if wait "$child"; then
    print "PASS $file"
  else
    print "FAIL $file"
    return 1
  fi
}

integer failed=0
for file in test/guards/**/*.dart(N.); do
  if grep -Eq "^[[:space:]]*import[[:space:]]+['\"]package:test/test\.dart['\"]" "$file" &&
     ! grep -Eq "^[[:space:]]*import[[:space:]]+['\"]package:flutter_test/flutter_test\.dart['\"]" "$file"; then
    run_check "$file" "$dart_bin" test "$file" || failed=1
  fi
done
if [[ -f tools/test_lint_v1.py ]]; then
  run_check tools/test_lint_v1.py python3 -I tools/test_lint_v1.py --base origin/main || failed=1
fi
exit "$failed"
