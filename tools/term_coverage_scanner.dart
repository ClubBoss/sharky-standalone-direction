import 'dart:convert';
import 'dart:io';

void main() {
  final registryFile = File('content/_meta/term_registry.jsonl');
  if (!registryFile.existsSync()) {
    stderr.writeln('Registry missing');
    exit(1);
  }

  final registry = <String>{};
  for (final line in registryFile.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    try {
      final obj = jsonDecode(trimmed) as Map<String, dynamic>;
      registry.add(obj['term'] as String);
    } catch (_) {
      // ignore
    }
  }

  final pattern = RegExp(r'\[\[term:([A-Z0-9_]+)\]\]');
  final wordPattern = RegExp(
    r'\b(PFR|VPIP|MDF|RFI|WTSD|WWSF|AFq|SPR|BLOCKERS|EXPLOIT|EQUITY|EV|PROBE|MERGE|SPR|BLOCKERS)\b',
    caseSensitive: false,
  );

  final uncoveredDetails = <Map<String, String>>[];
  final uncoveredSet = <String>{};
  final unknown = <String>{};

  for (final entry
      in Directory('content')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('/v1/theory.md'))) {
    final lines = entry.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final match in wordPattern.allMatches(line)) {
        final term = match.group(0)!.toUpperCase();
        if (pattern.hasMatch(match.group(0)!)) continue;
        if (registry.contains(term)) {
          uncoveredSet.add(term);
          uncoveredDetails.add({
            'file': entry.path,
            'line': '${i + 1}',
            'term': term,
            'text': line.trim(),
          });
        } else {
          unknown.add(term);
        }
      }
    }
  }

  stdout.writeln('uncovered_terms: ${uncoveredSet.toList()}');
  stdout.writeln('unknown_terms: ${unknown.toList()}');
  for (final detail in uncoveredDetails) {
    stdout.writeln('--- UNCOVERED TERM ---');
    stdout.writeln('file: ${detail['file']}');
    stdout.writeln('line: ${detail['line']}');
    stdout.writeln('term: ${detail['term']}');
    stdout.writeln('text: "${detail['text']}"');
  }
}
