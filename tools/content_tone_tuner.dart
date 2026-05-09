import 'dart:convert';
import 'dart:io';

/// Content Tone & Emotion Tuner
///
/// Rewrites goal and reaction_text fields into a upbeat, coach-like voice.
/// Dry-run by default; use --apply to write changes.

Future<void> main(List<String> args) async {
  final apply = args.contains('--apply');
  final dryRun = !apply || args.contains('--dry-run');

  final contentDir = Directory('content');
  if (!contentDir.existsSync()) {
    _printSummary(dryRun: dryRun, checked: 0, rephrased: 0, shifts: const {});
    return;
  }

  final files = <File>[];
  for (final entity in contentDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.jsonl')) files.add(entity);
  }

  int checked = 0;
  int rephrased = 0;
  final shiftCounts = <String, int>{};

  final positivePhrases = [
    'Crush this spot with confidence.',
    'Own the line and keep the pressure on.',
    'Stay sharp and trust your read.',
  ];
  final supportivePhrases = [
    'Great feel! Keep stacking smart reps.',
    'Nice instincts! Stay on the gas.',
    'Love the focus! Keep building the edge.',
  ];

  final negativeTokens = {
    'tilt',
    'mistake',
    'wrong',
    'bad',
    'tough',
    'lose',
    'loss',
    'frustrated',
  };
  final supportiveTokens = {
    'nice',
    'great',
    'awesome',
    'well played',
    'good job',
    'keep going',
    'you got this',
    'stay sharp',
  };

  for (final file in files) {
    final lines = file.readAsLinesSync();
    final updated = <String>[];
    var modified = false;

    for (final raw in lines) {
      if (raw.trim().isEmpty) {
        updated.add(raw);
        continue;
      }
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(raw) as Map<String, dynamic>?;
      } catch (_) {
        updated.add(raw);
        continue;
      }
      if (data == null) {
        updated.add(raw);
        continue;
      }
      checked++;
      var fieldChanges = 0;

      if (_tuneField(
        data,
        key: 'goal',
        targetTone: 'positive',
        phrases: positivePhrases,
        negativeTokens: negativeTokens,
        supportiveTokens: supportiveTokens,
        shiftCounts: shiftCounts,
        onRewrite: _rewriteGoal,
      )) {
        fieldChanges++;
      }

      if (_tuneField(
        data,
        key: 'reaction_text',
        targetTone: 'supportive',
        phrases: supportivePhrases,
        negativeTokens: negativeTokens,
        supportiveTokens: supportiveTokens,
        shiftCounts: shiftCounts,
        onRewrite: _rewriteReaction,
      )) {
        fieldChanges++;
      }

      if (fieldChanges > 0) {
        rephrased += fieldChanges;
        modified = true;
        updated.add(jsonEncode(data));
      } else {
        updated.add(raw);
      }
    }

    if (apply && modified) {
      file.writeAsStringSync('${updated.join('\n')}\n');
    }
  }

  _printSummary(
    dryRun: dryRun,
    checked: checked,
    rephrased: rephrased,
    shifts: shiftCounts,
  );
}

typedef _RewriteFn = String Function(String, List<String>);

bool _tuneField(
  Map<String, dynamic> data, {
  required String key,
  required String targetTone,
  required List<String> phrases,
  required Set<String> negativeTokens,
  required Set<String> supportiveTokens,
  required Map<String, int> shiftCounts,
  required _RewriteFn onRewrite,
}) {
  final value = data[key];
  if (value is! String || value.trim().isEmpty) return false;
  final original = value.trim();
  final tone = _classifyTone(
    original,
    negativeTokens: negativeTokens,
    supportiveTokens: supportiveTokens,
  );
  final updated = onRewrite(original, phrases);
  if (updated == original) return false;
  data[key] = updated;
  final shift = '${tone ?? 'unknown'}->$targetTone';
  shiftCounts[shift] = (shiftCounts[shift] ?? 0) + 1;
  return true;
}

String? _classifyTone(
  String text, {
  required Set<String> negativeTokens,
  required Set<String> supportiveTokens,
}) {
  final lower = text.toLowerCase();
  if (lower.isEmpty) return 'neutral';
  if (negativeTokens.any(lower.contains)) return 'negative';
  if (supportiveTokens.any(lower.contains)) return 'supportive';
  if (lower.contains('great') || lower.contains('awesome')) return 'positive';
  return 'neutral';
}

String _rewriteGoal(String original, List<String> phrases) {
  final cleaned = _clean(
    original,
  ).replaceFirst(RegExp(r'^goal:\s*', caseSensitive: false), '');
  final base = cleaned.isEmpty ? 'lock in the core pattern' : cleaned;
  final trimmed = _truncateSentence(base);
  final upbeat = phrases.first;
  return 'Goal: ${_capitalize(trimmed)}! $upbeat';
}

String _rewriteReaction(String original, List<String> phrases) {
  final cleaned = _clean(original);
  final index = cleaned.hashCode.abs() % phrases.length;
  final cheer = phrases[index];
  return 'Great work! $cheer';
}

String _clean(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

String _truncateSentence(String text) {
  if (text.length <= 80) return text;
  final cut = text.substring(0, 77);
  final idx = cut.lastIndexOf(' ');
  return idx > 40 ? cut.substring(0, idx) : cut;
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  final lower = text.toLowerCase();
  return '${lower[0].toUpperCase()}${lower.substring(1)}';
}

void _printSummary({
  required bool dryRun,
  required int checked,
  required int rephrased,
  required Map<String, int> shifts,
}) {
  final sortedShifts = shifts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topShift = sortedShifts.isEmpty
      ? 'none'
      : '${sortedShifts.first.key} (${sortedShifts.first.value})';

  stdout.writeln('Content Tone Tuner Tool');
  stdout.writeln('Mode: ${dryRun ? 'DRY-RUN' : 'APPLY'}');
  stdout.writeln('Entries checked: $checked');
  stdout.writeln('Fields rephrased: $rephrased');
  stdout.writeln('Top sentiment shift: $topShift');

  stdout.writeln(
    jsonEncode({
      'checked': checked,
      'rephrased': rephrased,
      'shifts': shifts,
      'top_shift': topShift,
      'dry_run': dryRun,
      'pass': true,
    }),
  );
}
