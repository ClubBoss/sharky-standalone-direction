#!/bin/bash

OUTPUT=~/Desktop/flutter_verification_log.txt
echo "== Dart Format ==" > "$OUTPUT"
dart format --set-exit-if-changed . >> "$OUTPUT" 2>&1

echo -e "\n== Dart Analyze ==" >> "$OUTPUT"
dart analyze >> "$OUTPUT" 2>&1

echo -e "\n== Dart Test (per file, timeout 30s) ==" >> "$OUTPUT"
find test -name "*.dart" | while read -r file; do
  echo "Testing $file" >> "$OUTPUT"
  timeout 30s dart test "$file" >> "$OUTPUT" 2>&1 || echo "❌ $file failed or timed out" >> "$OUTPUT"
done

echo -e "\n== Flutter Test (timeout 180s) ==" >> "$OUTPUT"
timeout 180s flutter test >> "$OUTPUT" 2>&1 || echo "❌ flutter test failed or timed out" >> "$OUTPUT"

echo -e "\n== Content Validation ==" >> "$OUTPUT"
dart run tools/validate_training_content.dart --ci >> "$OUTPUT" 2>&1

echo -e "\n✅ Done. Output saved to $OUTPUT"
