import 'dart:convert';
import 'dart:io';

/// Content Theme Binder Tool
///
/// Ensures each JSONL content entry has `theme`, `theme_emoji`, and
/// `theme_color` fields. Missing values are inferred from existing metadata.
/// Runs in dry-run mode unless `--apply` is specified.

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

      final inferredTheme = _inferTheme(data);
      if (!_hasNonEmptyString(data, 'theme')) {
        data['theme'] = inferredTheme;
        updated = true;
      }

      if (!_hasNonEmptyString(data, 'theme_emoji')) {
        data['theme_emoji'] = _emojiForTheme(inferredTheme);
        updated = true;
      }

      if (!_hasNonEmptyString(data, 'theme_color')) {
        data['theme_color'] = _colorForTheme(inferredTheme);
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

String _inferTheme(Map<String, dynamic> data) {
  final merged = StringBuffer();
  final idValue = data['id'];
  final goalValue = data['goal'];

  if (idValue is String) merged.write('${idValue.toLowerCase()} ');
  if (goalValue is String) merged.write(goalValue.toLowerCase());

  final text = merged.toString();

  if (text.contains('cash')) {
    return 'cash';
  }
  if (text.contains('icm') ||
      text.contains('bubble') ||
      text.contains('final')) {
    return 'icm';
  }
  if (text.contains('live') ||
      text.contains('etiquette') ||
      text.contains('chip')) {
    return 'live';
  }
  if (text.contains('online') ||
      text.contains('hud') ||
      text.contains('rakeback')) {
    return 'online';
  }
  return 'core';
}

String _emojiForTheme(String theme) {
  switch (theme) {
    case 'cash':
      return '💵';
    case 'icm':
      return '🏆';
    case 'live':
      return '🎥';
    case 'online':
      return '💻';
    default:
      return '🧠';
  }
}

String _colorForTheme(String theme) {
  switch (theme) {
    case 'cash':
      return 'green';
    case 'icm':
      return 'gold';
    case 'live':
      return 'red';
    case 'online':
      return 'blue';
    default:
      return 'purple';
  }
}

void _printSummary({
  required bool dryRun,
  required int checked,
  required int fixed,
}) {
  final mode = dryRun ? 'DRY-RUN' : 'APPLY';
  stdout.writeln('Content Theme Binder Tool');
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
