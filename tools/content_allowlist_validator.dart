import 'dart:io';

void main() {
  final allowlistFile = File('tools/content_allowlist.txt');
  if (!allowlistFile.existsSync()) {
    stderr.writeln('allowlist missing');
    exit(1);
  }

  final allowlist = allowlistFile
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toSet();

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

  var violations = 0;
  final tokenPattern = RegExp(r'\b[A-Z][A-Z0-9_/]*\b');
  final boardCodePattern = RegExp(r'^[2-9TJQKA]{1,3}$');
  final macroPattern = RegExp(r'^[A-Z_]+$');
  final numericPattern = RegExp(r'^[0-9]+$');

  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final match in tokenPattern.allMatches(line)) {
        final token = match.group(0)!;
        if (isAllowedToken(
          token,
          allowlist,
          boardCodePattern,
          macroPattern,
          numericPattern,
        )) {
          continue;
        }
        stdout.writeln('WARN: ${file.path}:${i + 1}: $token');
        violations++;
      }
    }
  }

  if (violations > 0) {
    stderr.writeln('Found $violations disallowed token(s)');
    exit(1);
  }
}

bool isAllowedToken(
  String token,
  Set<String> allowlist,
  RegExp boardCodePattern,
  RegExp macroPattern,
  RegExp numericPattern,
) {
  if (token.contains('/')) {
    final parts = token.split('/').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return false;
    return parts.every(
      (part) => isAllowedSimpleToken(
        part,
        allowlist,
        boardCodePattern,
        macroPattern,
        numericPattern,
      ),
    );
  }
  return isAllowedSimpleToken(
    token,
    allowlist,
    boardCodePattern,
    macroPattern,
    numericPattern,
  );
}

bool isAllowedSimpleToken(
  String token,
  Set<String> allowlist,
  RegExp boardCodePattern,
  RegExp macroPattern,
  RegExp numericPattern,
) {
  if (allowlist.contains(token) ||
      boardCodePattern.hasMatch(token) ||
      macroPattern.hasMatch(token) ||
      numericPattern.hasMatch(token)) {
    return true;
  }

  final suffixMatch = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(token);
  if (suffixMatch != null) {
    final prefix = suffixMatch.group(1)!;
    return isAllowedSimpleToken(
      prefix,
      allowlist,
      boardCodePattern,
      macroPattern,
      numericPattern,
    );
  }
  return false;
}
