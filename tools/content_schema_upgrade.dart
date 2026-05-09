import 'dart:convert';
import 'dart:io';

/// Content Schema Upgrade Tool
///
/// Scans all `content/**/*.jsonl` files and ensures the presence of
/// `difficulty`, `xp_value`, and `goal` fields. Missing fields are inferred
/// heuristically. Runs in dry-run mode unless `--apply` is provided.

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  int checkedEntries = 0;
  int fixedEntries = 0;

  final contentRoot = Directory('content');
  if (!await contentRoot.exists()) {
    _printSummary(dryRun: dryRun, checked: checkedEntries, fixed: fixedEntries);
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
    final hasTrailingNewline = original.isEmpty
        ? false
        : original.endsWith('\n');
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
        // Preserve unparseable lines verbatim.
        updatedLines.add(rawLine);
        continue;
      }

      if (data == null) {
        updatedLines.add(rawLine);
        continue;
      }

      checkedEntries++;

      final idValue = data['id'] is String ? data['id'] as String : '';
      final xpRewardRaw = data['xp_reward'];
      final xpReward = xpRewardRaw is num ? xpRewardRaw.toDouble() : null;
      bool updated = false;

      if (!_hasNonEmptyString(data, 'difficulty')) {
        data['difficulty'] = _inferDifficulty(data, idValue);
        updated = true;
      } else if (data['difficulty'] is! String) {
        data['difficulty'] = _inferDifficulty(data, idValue);
        updated = true;
      }

      if (!data.containsKey('xp_value') || data['xp_value'] == null) {
        final difficulty = _difficultyLabel(data);
        final inferred = xpReward != null && xpReward > 0
            ? xpReward.round()
            : _defaultXpForDifficulty(difficulty);
        data['xp_value'] = inferred;
        updated = true;
      } else if (data['xp_value'] is num && (data['xp_value'] as num) <= 0) {
        data['xp_value'] = _defaultXpForDifficulty(_difficultyLabel(data));
        updated = true;
      }

      if (xpReward == null || xpReward <= 0) {
        data['xp_reward'] = data['xp_value'] is num
            ? (data['xp_value'] as num).round()
            : _defaultXpForDifficulty(_difficultyLabel(data));
        updated = true;
      } else if (data['xp_reward'] is! int) {
        data['xp_reward'] = xpReward.round();
        updated = true;
      }

      if (!_hasNonEmptyString(data, 'goal')) {
        data['goal'] = _deriveGoal(idValue);
        updated = true;
      }

      if (updated) {
        fixedEntries++;
        fileModified = true;
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

  _printSummary(dryRun: dryRun, checked: checkedEntries, fixed: fixedEntries);
}

bool _hasNonEmptyString(Map<String, dynamic> data, String key) {
  final value = data[key];
  return value is String && value.trim().isNotEmpty;
}

String _inferDifficulty(Map<String, dynamic> data, String idValue) {
  return _inferDifficultyWithContext(data, idValue);
}

String _inferDifficultyWithContext(Map<String, dynamic>? data, String idValue) {
  final reward = data != null && data['xp_reward'] is num
      ? (data['xp_reward'] as num).toDouble()
      : null;
  if (reward != null) {
    if (reward >= 120) return 'hard';
    if (reward <= 60) return 'easy';
  }

  final lowered = idValue.toLowerCase();
  const easyKeywords = ['intro', 'basics', 'fundamentals'];
  const hardKeywords = ['advanced', 'deep', 'icm', 'exploit'];

  if (easyKeywords.any(lowered.contains)) {
    return 'easy';
  }
  if (hardKeywords.any(lowered.contains)) {
    return 'hard';
  }
  return 'medium';
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

String _deriveGoal(String idValue) {
  final sanitized = idValue.replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_');
  final rawTokens = sanitized
      .split('_')
      .where((token) => token.trim().isNotEmpty)
      .toList();

  final tokens = rawTokens.isEmpty ? <String>['training', 'goal'] : rawTokens;
  final words = <String>[];

  for (final token in tokens) {
    if (words.length >= 10) break;
    words.add(_titleCase(token));
  }

  const fallback = [
    'Module',
    'Focus',
    'Training',
    'Objective',
    'Overview',
    'Guide',
    'Outline',
    'Primer',
  ];
  var fallbackIndex = 0;
  while (words.length < 6 && fallbackIndex < fallback.length) {
    words.add(fallback[fallbackIndex]);
    fallbackIndex++;
  }

  if (words.length > 10) {
    return words.sublist(0, 10).join(' ');
  }
  return words.join(' ');
}

String _titleCase(String token) {
  if (token.isEmpty) return '';
  final lower = token.toLowerCase();
  if (lower.length == 1) return lower.toUpperCase();
  return '${lower[0].toUpperCase()}${lower.substring(1)}';
}

String _difficultyLabel(Map<String, dynamic> data) {
  final current = data['difficulty'];
  if (current is String && current.trim().isNotEmpty) {
    return current.toLowerCase();
  }
  final idValue = data['id'] is String ? data['id'] as String : '';
  return _inferDifficultyWithContext(data, idValue);
}

void _printSummary({
  required bool dryRun,
  required int checked,
  required int fixed,
}) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  stdout.writeln('Content Schema Upgrade Tool');
  stdout.writeln('Mode: $mode');
  stdout.writeln('Entries checked: $checked');
  stdout.writeln('Entries fixed: $fixed');
  stdout.writeln(
    jsonEncode({
      'checked': checked,
      'fixed': fixed,
      'dry_run': dryRun,
      'pass': true,
    }),
  );
}
