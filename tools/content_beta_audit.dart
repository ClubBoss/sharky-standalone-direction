import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    _printSummary(
      files: 0,
      entries: 0,
      invalid: 0,
      emptyGoals: 0,
      emptyReactions: 0,
      parseErrors: 0,
    );
    return;
  }

  final files = await _collectJsonl(contentDir);
  int filesScanned = 0;
  int entriesScanned = 0;
  int invalidSchema = 0;
  int emptyGoals = 0;
  int emptyReactions = 0;
  int parseErrors = 0;

  for (final file in files) {
    filesScanned++;
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(line) as Map<String, dynamic>?;
      } catch (_) {
        parseErrors++;
        continue;
      }
      if (data == null) {
        parseErrors++;
        continue;
      }

      entriesScanned++;
      final idOk =
          data['id'] is String && (data['id'] as String).trim().isNotEmpty;
      final goal = data['goal'];
      final reaction = data['reaction_text'];
      final goalOk = goal is String && goal.trim().isNotEmpty;
      final reactionOk = reaction is String && reaction.trim().isNotEmpty;

      if (!idOk) invalidSchema++;
      if (!goalOk) emptyGoals++;
      if (!reactionOk) emptyReactions++;
    }
  }

  _printSummary(
    files: filesScanned,
    entries: entriesScanned,
    invalid: invalidSchema,
    emptyGoals: emptyGoals,
    emptyReactions: emptyReactions,
    parseErrors: parseErrors,
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

void _printSummary({
  required int files,
  required int entries,
  required int invalid,
  required int emptyGoals,
  required int emptyReactions,
  required int parseErrors,
}) {
  final pass =
      invalid == 0 &&
      emptyGoals == 0 &&
      emptyReactions == 0 &&
      parseErrors == 0;
  stdout.writeln(
    'Content Beta Audit\n'
    'Files scanned: $files\n'
    'Entries scanned: $entries\n'
    'Invalid schema: $invalid\n'
    'Empty goals: $emptyGoals\n'
    'Empty reactions: $emptyReactions\n'
    'Parse errors: $parseErrors\n'
    'Status: ${pass ? 'PASS' : 'FAIL'}',
  );
  stdout.writeln(
    jsonEncode({
      'files': files,
      'entries': entries,
      'invalid_schema': invalid,
      'empty_goals': emptyGoals,
      'empty_reactions': emptyReactions,
      'parse_errors': parseErrors,
      'pass': pass,
    }),
  );
}
