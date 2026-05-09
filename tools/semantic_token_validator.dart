import 'dart:io';

void main() {
  final mapFile = File('tools/semantic_token_map.txt');
  if (!mapFile.existsSync()) {
    stderr.writeln('semantic map missing');
    exit(1);
  }

  final tokenLines = mapFile.readAsLinesSync();
  final tokenMap = <String, String>{};
  var issues = 0;

  for (var line in tokenLines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final colonIndex = trimmed.indexOf(':');
    if (colonIndex == -1) {
      stdout.writeln('WARN: invalid map entry: $trimmed');
      issues++;
      continue;
    }

    final token = trimmed.substring(0, colonIndex).trim();
    final category = trimmed.substring(colonIndex + 1).trim();
    tokenMap[token] = category;
    if (category.isEmpty) {
      stdout.writeln('WARN: missing category for token $token');
      issues++;
    }
  }

  final files = Directory('content')
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.md') ||
            f.path.endsWith('.txt') ||
            f.path.endsWith('.jsonl'),
      )
      .toList();

  final tokenPattern = RegExp(r'\b[a-zA-Z0-9_/]+\b');
  final boardPattern = RegExp(r'^[2-9TJQKA]{2,3}$');
  final macroPattern = RegExp(r'^[A-Z_]+$');
  final numericPattern = RegExp(r'^[0-9]+$');

  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final match in tokenPattern.allMatches(line)) {
        final token = match.group(0)!;
        if (tokenMap.containsKey(token)) {
          final category = tokenMap[token]!;
          if (category.isEmpty) {
            stdout.writeln(
              'WARN: ${file.path}:${i + 1}: $token has no category',
            );
            issues++;
          }
          continue;
        }

        if (boardPattern.hasMatch(token) ||
            macroPattern.hasMatch(token) ||
            numericPattern.hasMatch(token)) {
          continue;
        }
      }
    }
  }

  if (issues > 0) {
    stderr.writeln('Found $issues semantic issue(s)');
    exit(1);
  }
}
