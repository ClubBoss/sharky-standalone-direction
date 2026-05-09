import 'dart:io';

void main() {
  final registryFile = File('content/_meta/term_registry.jsonl');
  if (!registryFile.existsSync()) {
    stderr.writeln('term_registry.jsonl not found');
    exit(1);
  }

  final registryTerms = registryFile
      .readAsLinesSync()
      .map((line) {
        if (line.trim().isEmpty) return null;
        final json = line.trim();
        final termMatch = RegExp(r'"term"\s*:\s*"([^"]+)"').firstMatch(json);
        return termMatch?.group(1);
      })
      .where((term) => term != null)
      .toSet();

  final skipStats = RegExp(r'^[A-Z]{2,}\d+$');
  final allowedAbbrs = {'PFR', 'VPIP', 'WTSD', 'WWSF', 'AFQ', 'MDF', 'RFI'};

  stdout.writeln('=== UNKNOWN UPPERCASE TOKENS ===');

  final files =
      Directory('content')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/theory.md'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final tokens = RegExp(r'\b[A-Z][A-Z0-9]+\b').allMatches(line);
      for (final match in tokens) {
        final token = match.group(0)!;
        if (line.contains('[[term:$token]]')) continue;
        if (registryTerms.contains(token)) continue;
        if (skipStats.hasMatch(token)) continue;
        if (allowedAbbrs.contains(token)) continue;
        stdout.writeln('--- UNKNOWN ---');
        stdout.writeln('file: ${file.path}');
        stdout.writeln('line: ${i + 1}');
        stdout.writeln('token: $token');
        stdout.writeln('text: $line');
      }
    }
  }
}
