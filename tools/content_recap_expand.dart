import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/content_recap_expand.dart <moduleId>',
    );
    exit(1);
  }

  final moduleId = args.first;
  final recap = File('content/$moduleId/recap.md');
  if (!recap.existsSync()) {
    stderr.writeln('recap.md missing for $moduleId');
    exit(1);
  }

  final current = recap.readAsStringSync();
  const placeholder = '# Recap\n\nThis module covers key fundamentals.\n';
  if (current != placeholder) {
    print('[SKIP] real content');
    return;
  }

  recap.writeAsStringSync('''# Recap

## What you learn
- Core ideas of the module
- Practical patterns
- Common pitfalls

## Why it matters
Provide a short explanation here.

## Key examples
- Example 1
- Example 2
''');
  print('[EXPANDED] recap');
}
