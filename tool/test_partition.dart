import 'dart:io';

// syntax fix: replace broken script with minimal CLI classifier
final _flutterTag = RegExp(r"@Tags\(\s*\[\s*'flutter'\s*\]\s*\)");
final _flutterImport = RegExp(
  "^\\s*import\\s+['\"]package:flutter/[^'\"\\n]+['\"]",
  multiLine: true,
);

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('usage: test_partition <path>');
    exit(64);
  }
  final txt = File(args[0]).readAsStringSync();
  final isFlutter = _flutterTag.hasMatch(txt) || _flutterImport.hasMatch(txt);
  stdout.writeln(isFlutter ? 'flutter' : 'pure_dart');
}
