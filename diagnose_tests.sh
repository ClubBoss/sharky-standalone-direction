#!/bin/bash

echo "🔍 Running isolated tests with timeout (30s each)..."
echo "=============================================="

PROBLEM_FILES=()

for file in $(find test -name "*_test.dart"); do
  echo "▶️ Testing $file"
  timeout 30s flutter test "$file"
  EXIT_CODE=$?

  if [ $EXIT_CODE -eq 124 ]; then
    echo "⏱️ Timeout: $file"
    PROBLEM_FILES+=("$file")
  elif [ $EXIT_CODE -ne 0 ]; then
    echo "❌ Failed: $file (exit code $EXIT_CODE)"
    PROBLEM_FILES+=("$file")
  else
    echo "✅ Passed: $file"
  fi

  echo "----------------------------------------------"
done

echo ""
echo "🧹 Summary of problematic tests:"
printf '%s\n' "${PROBLEM_FILES[@]}"