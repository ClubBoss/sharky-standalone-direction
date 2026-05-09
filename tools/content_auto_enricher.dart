import 'dart:convert';
import 'dart:io';

/// Content Auto Enricher Tool
///
/// Ensures that each JSONL content entry contains `lesson_goal` and
/// `reaction_text`. Missing values are synthesized from existing `goal`
/// metadata or derived heuristics. Runs in dry-run mode unless `--apply`
/// is provided.

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
        // Preserve unparseable lines verbatim.
        updatedLines.add(rawLine);
        continue;
      }

      if (data == null) {
        updatedLines.add(rawLine);
        continue;
      }

      checkedEntries++;
      bool updated = false;

      if (!_hasNonEmptyString(data, 'goal')) {
        final goal = _buildPrimaryGoal(data);
        if (goal != null && goal.isNotEmpty) {
          data['goal'] = goal;
          updated = true;
        }
      }

      if (!_hasNonEmptyString(data, 'lesson_goal')) {
        final lessonGoal = _buildLessonGoal(data);
        if (lessonGoal != null && lessonGoal.isNotEmpty) {
          data['lesson_goal'] = lessonGoal;
          updated = true;
        }
      }

      if (!_hasNonEmptyString(data, 'reaction_text')) {
        final reactionText = _buildReactionText(data);
        if (reactionText.isNotEmpty) {
          data['reaction_text'] = reactionText;
          updated = true;
        }
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

String? _buildPrimaryGoal(Map<String, dynamic> data) {
  final lessonGoal = data['lesson_goal'];
  if (lessonGoal is String && lessonGoal.trim().isNotEmpty) {
    return _cleanGoalLabel(_sanitizeAscii(lessonGoal));
  }

  final goal = data['goal'];
  if (goal is String && goal.trim().isNotEmpty) {
    return _ensureSentence(_sanitizeAscii(goal));
  }

  final question = data['question'];
  if (question is String && question.trim().isNotEmpty) {
    return _ensureSentence(_sanitizeAscii(question));
  }

  final steps = data['steps'];
  if (steps is List && steps.isNotEmpty && steps.first is String) {
    return _ensureSentence(_sanitizeAscii((steps.first as String)));
  }

  return _ensureSentence(
    _sanitizeAscii(
      _phraseFromId(
        data['id'] is String ? data['id'] as String : 'session_goal',
      ),
    ),
  );
}

String? _buildLessonGoal(Map<String, dynamic> data) {
  final rawGoal = data['goal'];
  final idValue = data['id'] is String ? data['id'] as String : '';

  String? source;
  if (rawGoal is String && rawGoal.trim().isNotEmpty) {
    source = rawGoal.trim();
  } else if (idValue.isNotEmpty) {
    source = _phraseFromId(idValue);
  }

  if (source == null || source.isEmpty) {
    return null;
  }

  final sanitized = _sanitizeAscii(source);
  final sentence = _ensureSentence(sanitized);
  return 'Goal: $sentence';
}

String _buildReactionText(Map<String, dynamic> data) {
  final idValue = data['id'] is String ? data['id'] as String : 'content_entry';
  final target = data['target'] is String ? data['target'] as String : null;
  final spotKind = data['spot_kind'] is String
      ? data['spot_kind'] as String
      : null;
  final difficultyScore = (data['difficulty_score'] is num)
      ? (data['difficulty_score'] as num).toDouble()
      : 1.0;
  final xpReward = (data['xp_reward'] is num)
      ? (data['xp_reward'] as num).toInt()
      : 0;

  final focus = _formatFocus(target ?? spotKind ?? 'this spot');
  final tone = difficultyScore >= 1.1 || xpReward >= 110 ? 'energetic' : 'calm';
  final options = tone == 'energetic'
      ? _energeticReactions
      : _supportiveReactions;
  final hash = idValue.toLowerCase().codeUnits.fold<int>(
    0,
    (acc, unit) => (acc * 31 + unit) & 0x7fffffff,
  );
  final stem = options[hash % options.length];

  return '$stem Keep pressing on $focus.';
}

String _phraseFromId(String idValue) {
  final sanitized = idValue.replaceAll(RegExp(r'[^A-Za-z0-9_]+'), '_');
  final tokens = sanitized
      .split('_')
      .where((token) => token.trim().isNotEmpty)
      .map(_titleCase)
      .toList();
  if (tokens.isEmpty) return 'Learn Core Concepts';
  return tokens.take(10).join(' ');
}

String _sanitizeAscii(String input) {
  final buffer = StringBuffer();
  for (final codeUnit in input.codeUnits) {
    if (codeUnit >= 32 && codeUnit <= 126) {
      buffer.writeCharCode(codeUnit);
    } else if (codeUnit == 9 || codeUnit == 10 || codeUnit == 13) {
      buffer.write(' ');
    } else {
      buffer.write(' ');
    }
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _ensureSentence(String text) {
  if (text.isEmpty) return 'Review key concepts.';
  final trimmed = text.endsWith('.') || text.endsWith('!') || text.endsWith('?')
      ? text
      : '$text.';
  final capitalized = '${trimmed[0].toUpperCase()}${trimmed.substring(1)}'
      .trim();
  return capitalized;
}

String _titleCase(String token) {
  if (token.isEmpty) return '';
  final lower = token.toLowerCase();
  if (lower.length == 1) return lower.toUpperCase();
  return '${lower[0].toUpperCase()}${lower.substring(1)}';
}

String _cleanGoalLabel(String value) {
  return value.replaceFirst(
    RegExp(r'^goal\s*[:\-]\s*', caseSensitive: false),
    '',
  );
}

String _formatFocus(String raw) {
  final sanitized = raw.replaceAll(RegExp(r'[_\-]+'), ' ');
  final cleaned = _sanitizeAscii(sanitized);
  return cleaned.isEmpty ? 'this spot' : cleaned.toLowerCase();
}

const _energeticReactions = [
  'High-voltage line!',
  'Strong punch there!',
  'Love the aggression!',
  'You pushed the edge!',
];

const _supportiveReactions = [
  'Smooth control.',
  'Smart tempo.',
  'Nice composure.',
  'Steady read.',
  'Great flow.',
];

void _printSummary({
  required bool dryRun,
  required int checked,
  required int fixed,
}) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  stdout.writeln('Content Auto Enricher Tool');
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
