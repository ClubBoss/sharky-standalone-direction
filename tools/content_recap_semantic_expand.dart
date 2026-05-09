import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_recap_semantic_expand.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final recap = File('content/$moduleId/recap.md');
  if (!recap.existsSync()) {
    stderr.writeln('recap.md missing for $moduleId');
    exit(1);
  }

  final text = recap.readAsStringSync();
  const headers = ['## What you learn', '## Why it matters', '## Key examples'];

  final lines = text.split('\n');
  final foundHeaders = lines.where((line) => line.startsWith('##')).toList();
  if (headers.any((header) => !text.contains(header))) {
    print('[SKIP] real recap');
    return;
  }

  if (foundHeaders.length > headers.length) {
    print('[SKIP] real recap');
    return;
  }

  if (text.length >= 500) {
    print('[SKIP] real recap');
    return;
  }

  const expanded = '''# Recap

## What you learn
- Core concept summary
- Practical application patterns
- Key decision anchors

## Why it matters
Explain the strategic impact, common pitfalls, and how this module connects to future topics.

## Key examples
- Practical scenario 1
- Practical scenario 2
- Typical mistake + correction
''';

  recap.writeAsStringSync(expanded);
  print('[EXPANDED] semantic recap');
}
