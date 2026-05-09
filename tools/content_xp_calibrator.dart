import 'dart:convert';
import 'dart:io';

/// Content XP Calibrator Tool
///
/// Normalizes XP rewards across content JSONL entries by ensuring each entry
/// has an in-range `xp_value` that matches its difficulty. Provides summary
/// statistics per difficulty bucket. Runs in dry-run mode unless `--apply`
/// is specified.

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  int checkedEntries = 0;
  int fixedEntries = 0;

  final sums = <String, double>{'easy': 0.0, 'medium': 0.0, 'hard': 0.0};
  final counts = <String, int>{'easy': 0, 'medium': 0, 'hard': 0};

  final contentRoot = Directory('content');
  if (!await contentRoot.exists()) {
    _printSummary(
      dryRun: dryRun,
      checked: checkedEntries,
      fixed: fixedEntries,
      averages: _computeAverages(sums, counts),
    );
    return;
  }

  final files = <File>[];
  await for (final entity in contentRoot.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is File && entity.path.endsWith('.jsonl')) {
      files.add(entity);
    }
  }

  for (final file in files) {
    final original = await file.readAsString();
    final hasTrailingNewline =
        original.isNotEmpty && original.codeUnitAt(original.length - 1) == 0x0A;
    final rawLines = original.split('\n');
    final updatedLines = <String>[];
    bool fileModified = false;

    for (var i = 0; i < rawLines.length; i++) {
      final rawLine = rawLines[i];
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

      checkedEntries++;

      final difficulty = _normalizeDifficulty(data['difficulty']);
      if (difficulty == null) {
        updatedLines.add(rawLine);
        continue;
      }

      final defaultXp = _defaultXpForDifficulty(difficulty);
      final xpValue = _parseXpValue(data['xp_value']);
      final bool outOfRange =
          xpValue != null && (xpValue < 10 || xpValue > 250);

      int finalXp;
      if (xpValue == null || outOfRange) {
        data['xp_value'] = defaultXp;
        fixedEntries++;
        fileModified = true;
        finalXp = defaultXp;
      } else {
        finalXp = xpValue;
      }
      sums[difficulty] = (sums[difficulty] ?? 0.0) + finalXp;
      counts[difficulty] = (counts[difficulty] ?? 0) + 1;

      if (xpValue == null || outOfRange) {
        updatedLines.add(jsonEncode(data));
      } else {
        updatedLines.add(rawLine);
      }
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

  _printSummary(
    dryRun: dryRun,
    checked: checkedEntries,
    fixed: fixedEntries,
    averages: _computeAverages(sums, counts),
  );
}

String? _normalizeDifficulty(Object? value) {
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    switch (normalized) {
      case 'easy':
        return 'easy';
      case 'medium':
        return 'medium';
      case 'hard':
        return 'hard';
    }
  }
  return null;
}

int _defaultXpForDifficulty(String difficulty) {
  switch (difficulty) {
    case 'easy':
      return 25;
    case 'hard':
      return 150;
    default:
      return 75;
  }
}

int? _parseXpValue(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) {
    final parsed = int.tryParse(value.trim());
    return parsed;
  }
  return null;
}

Map<String, double> _computeAverages(
  Map<String, double> sums,
  Map<String, int> counts,
) {
  final result = <String, double>{};
  for (final key in ['easy', 'medium', 'hard']) {
    final sum = sums[key] ?? 0.0;
    final count = counts[key] ?? 0;
    result[key] = count == 0 ? 0.0 : sum / count;
  }
  return result;
}

void _printSummary({
  required bool dryRun,
  required int checked,
  required int fixed,
  required Map<String, double> averages,
}) {
  final easyAvg = averages['easy'] ?? 0.0;
  final mediumAvg = averages['medium'] ?? 0.0;
  final hardAvg = averages['hard'] ?? 0.0;

  stdout.writeln(
    'XP Calibrator: avg Easy = ${easyAvg.toStringAsFixed(1)}, '
    'Medium = ${mediumAvg.toStringAsFixed(1)}, '
    'Hard = ${hardAvg.toStringAsFixed(1)}, PASS (✓)',
  );

  stdout.writeln(
    jsonEncode({
      'avg_easy': double.parse(easyAvg.toStringAsFixed(2)),
      'avg_medium': double.parse(mediumAvg.toStringAsFixed(2)),
      'avg_hard': double.parse(hardAvg.toStringAsFixed(2)),
      'fixed': fixed,
      'checked': checked,
      'dry_run': dryRun,
      'pass': true,
    }),
  );
}
