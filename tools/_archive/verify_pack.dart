// DEPRECATED (Archived legacy tool)
// Historical helper script kept for traceability; not part of active tooling.

import 'dart:io';
import 'dart:convert';

void main() {
  final path = 'content/core_rules_and_setup/v1';
  print('🔍 Verifying module at: $path');

  final files = [
    'manifest.json',
    'drills.jsonl',
    'quiz.jsonl',
    'demos.jsonl',
    'theory.md',
  ];

  bool hasError = false;

  for (final file in files) {
    final f = File('$path/$file');
    if (!f.existsSync()) {
      print('❌ Missing: $file');
      hasError = true;
      continue;
    }

    if (file.endsWith('.json')) {
      try {
        jsonDecode(f.readAsStringSync());
        print('✅ Valid JSON: $file');
      } catch (e) {
        print('❌ Invalid JSON in $file: $e');
        hasError = true;
      }
    } else if (file.endsWith('.jsonl')) {
      final lines = f.readAsLinesSync();
      int lineNum = 0;
      for (final line in lines) {
        lineNum++;
        if (line.trim().isEmpty) continue;
        try {
          jsonDecode(line);
        } catch (e) {
          print('❌ Invalid JSONL in $file (line $lineNum): $e');
          hasError = true;
        }
      }
      print('✅ Valid JSONL: $file (${lines.length} lines)');
    } else {
      print('✅ Found: $file');
    }
  }

  if (hasError) {
    print('🚨 VALIDATION FAILED');
    exit(1);
  } else {
    print('✨ ALL SYSTEMS GO. Content is clean.');
  }
}
