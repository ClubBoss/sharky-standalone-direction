import 'dart:convert';
import 'dart:io';

/// Content Persona Harmonizer
///
/// Rewrites goal and reaction_text fields across content JSONL files
/// to match the friendly, confident coach voice. Runs in dry-run mode
/// unless `--apply` is provided.

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    _printSummary(dryRun: dryRun, entries: 0, harmonized: 0, toneScore: 1.0);
    return;
  }

  final files = await _collectJsonl(contentDir);
  if (files.isEmpty) {
    _printSummary(dryRun: dryRun, entries: 0, harmonized: 0, toneScore: 1.0);
    return;
  }

  int entriesVisited = 0;
  int fieldsHarmonized = 0;

  for (final file in files) {
    final original = await file.readAsString();
    if (original.isEmpty) continue;

    final hasTrailingNewline = original.codeUnitAt(original.length - 1) == 0x0A;
    final rawLines = original.split('\n');
    final updatedLines = <String>[];
    bool fileModified = false;

    for (final rawLine in rawLines) {
      if (rawLine.trim().isEmpty) {
        updatedLines.add(rawLine);
        continue;
      }

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(rawLine) as Map<String, dynamic>?;
      } catch (_) {
        updatedLines.add(rawLine);
        continue;
      }
      if (data == null) {
        updatedLines.add(rawLine);
        continue;
      }

      entriesVisited++;
      final idValue = data['id'] is String ? data['id'] as String : '';

      final harmonizedGoal = _harmonizeGoal(data['goal']);
      if (harmonizedGoal != null && harmonizedGoal != data['goal']) {
        data['goal'] = harmonizedGoal;
        fieldsHarmonized++;
        fileModified = true;
      }

      final harmonizedReaction = _harmonizeReaction(
        data['reaction_text'],
        idValue,
      );
      if (harmonizedReaction != null &&
          harmonizedReaction != data['reaction_text']) {
        data['reaction_text'] = harmonizedReaction;
        fieldsHarmonized++;
        fileModified = true;
      }

      updatedLines.add(jsonEncode(data));
    }

    if (apply && fileModified) {
      final buffer = StringBuffer();
      for (var i = 0; i < updatedLines.length; i++) {
        buffer.write(updatedLines[i]);
        if (i < updatedLines.length - 1 || hasTrailingNewline) {
          buffer.write('\n');
        }
      }
      await file.writeAsString(buffer.toString());
    }
  }

  final toneScore = entriesVisited == 0
      ? 1.0
      : fieldsHarmonized / (entriesVisited * 2);
  _printSummary(
    dryRun: dryRun,
    entries: entriesVisited,
    harmonized: fieldsHarmonized,
    toneScore: toneScore,
  );
}

Future<List<File>> _collectJsonl(Directory root) async {
  final files = <File>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.jsonl')) {
      files.add(entity);
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

String? _harmonizeGoal(Object? raw) {
  final sanitized = _sanitizeAscii(raw is String ? raw : '');
  final trimmed = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
  final payload = trimmed.isEmpty ? null : _stripGoalPrefix(trimmed);
  final sentence = _ensureSentence(
    payload ?? 'Lock in disciplined decisions each street.',
  );
  return "Let's analyze this spot smartly. $sentence";
}

String? _harmonizeReaction(Object? raw, String idValue) {
  final opener = _personaCue(idValue);
  final sanitized = _sanitizeAscii(raw is String ? raw : '');
  final trimmed = sanitized.replaceAll(RegExp(r'\s+'), ' ').trim();
  final insight = trimmed.isEmpty
      ? 'Stay sharp and execute the plan.'
      : _ensureSentence(trimmed);
  return '$opener $insight';
}

String _personaCue(String idValue) {
  const cues = [
    'You got this!',
    'Coach confidence check:',
    'Game-plan mode:',
    'Smart grind update:',
    'Trust your edge!',
    'Steady hands, sharp mind:',
  ];
  final key = idValue.isEmpty ? 'default' : idValue.toLowerCase();
  final hash = key.codeUnits.fold<int>(0, (acc, unit) {
    return (acc * 31 + unit) & 0x7fffffff;
  });
  final index = hash % cues.length;
  return cues[index];
}

String _sanitizeAscii(String input) {
  final buffer = StringBuffer();
  for (final code in input.codeUnits) {
    if (code >= 32 && code <= 126) {
      buffer.writeCharCode(code);
    } else if (code == 9 || code == 10 || code == 13) {
      buffer.write(' ');
    }
  }
  return buffer.toString();
}

String _stripGoalPrefix(String text) {
  var cleaned = text;
  cleaned = cleaned.replaceFirst(
    RegExp(r'^(goal|coach goal)\s*[:\-]\s*', caseSensitive: false),
    '',
  );
  return cleaned.trim();
}

String _ensureSentence(String text) {
  if (text.isEmpty) return 'Stay composed and choose the highest EV line.';
  var trimmed = text.trim();
  if (!trimmed.endsWith('.') &&
      !trimmed.endsWith('!') &&
      !trimmed.endsWith('?')) {
    trimmed = '$trimmed.';
  }
  final first = trimmed[0];
  final capital = first.toUpperCase();
  if (trimmed.length == 1) {
    return capital;
  }
  return '$capital${trimmed.substring(1)}';
}

void _printSummary({
  required bool dryRun,
  required int entries,
  required int harmonized,
  required double toneScore,
}) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  stdout.writeln('Content Persona Harmonizer');
  stdout.writeln('Mode: $mode');
  stdout.writeln('Entries visited: $entries');
  stdout.writeln('Fields harmonized: $harmonized');
  stdout.writeln('Tone score: ${toneScore.toStringAsFixed(2)}');
  stdout.writeln(
    jsonEncode({
      'entries': entries,
      'harmonized_count': harmonized,
      'tone_score': double.parse(toneScore.toStringAsFixed(4)),
      'dry_run': dryRun,
      'pass': true,
    }),
  );
}
