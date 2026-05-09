import 'dart:convert';
import 'dart:io';

/// Stage H6 cache repair utility.
///
/// Scans key cache files and replaces malformed JSON with safe defaults so the
/// app can start cleanly even after offline corruption.
Future<void> main(List<String> args) async {
  final repairs = <String, String>{};
  final errors = <String>[];

  await _repairProgression(repairs, errors);
  await _repairRewardCache(repairs, errors);
  await _repairDifficultyCache(repairs, errors);

  final repairedKeys = repairs.keys.toList()..sort();
  final buffer = StringBuffer();
  buffer.writeln('Cache Repair Summary');
  buffer.writeln('--------------------');
  if (repairedKeys.isEmpty) {
    buffer.writeln('No repairs needed.');
  } else {
    for (final key in repairedKeys) {
      buffer.writeln('$key -> ${repairs[key]}');
    }
  }
  if (errors.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('Warnings:');
    for (final warning in errors) {
      buffer.writeln('- $warning');
    }
  }
  stdout.write(buffer.toString());

  final telemetry = {
    'event': 'cache_repair_executed',
    'repaired': repairedKeys,
    'warnings': errors,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  };
  stdout.writeln();
  stdout.writeln(jsonEncode(telemetry));
}

Future<void> _repairProgression(
  Map<String, String> repairs,
  List<String> errors,
) async {
  const path = 'tools/_reports/progression_state.json';
  final file = File(path);
  if (!await file.exists()) {
    return;
  }

  try {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is Map<String, dynamic> && decoded.containsKey('level')) {
      return;
    }
  } catch (_) {
    // fall through to rewrite
  }

  final safe = {
    'level': 1,
    'xp_total': 0,
    'next_level_xp': 1000,
    'chip_total': 0,
    'league_tier': 'Bronze',
    'streak': 0,
  };
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(safe));
  repairs[path] = 'reset to defaults';
}

Future<void> _repairRewardCache(
  Map<String, String> repairs,
  List<String> errors,
) async {
  const path = 'tools/_reports/adaptive_reward_cache.json';
  final file = File(path);
  if (!await file.exists()) {
    return;
  }

  Map<String, dynamic>? decoded;
  try {
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      decoded = null;
    } else {
      final value = jsonDecode(raw);
      decoded = value is Map<String, dynamic> ? value : null;
    }
  } catch (error) {
    errors.add('Failed to parse $path (${error.runtimeType}).');
  }

  decoded ??= {};
  final history = decoded['history'];
  final cleanedHistory = <Map<String, Object>>[];
  if (history is List) {
    for (final entry in history) {
      if (entry is! Map) {
        repairs[path] = 'cleaned history entries';
        continue;
      }
      final map = <String, Object>{};
      final timestamp = entry['timestamp']?.toString();
      if (timestamp == null || DateTime.tryParse(timestamp) == null) {
        repairs[path] = 'cleaned history entries';
        continue;
      }
      final baseXp = (entry['base_xp'] as num?)?.toInt() ?? 0;
      final adjustedXp = (entry['adjusted_xp'] as num?)?.toInt() ?? 0;
      final baseChips = (entry['base_chips'] as num?)?.toInt() ?? 0;
      final adjustedChips = (entry['adjusted_chips'] as num?)?.toInt() ?? 0;
      final multiplier = (entry['multiplier'] as num?)?.toDouble() ?? 1.0;

      map['timestamp'] = timestamp;
      map['base_xp'] = baseXp;
      map['adjusted_xp'] = adjustedXp;
      map['base_chips'] = baseChips;
      map['adjusted_chips'] = adjustedChips;
      map['multiplier'] = double.parse(multiplier.toStringAsFixed(2));
      cleanedHistory.add(map);
    }
  } else {
    repairs[path] = 'initialized empty history';
  }

  final output = <String, Object?>{
    'history': cleanedHistory,
    'last_confidence': (decoded['last_confidence'] as num?)?.toDouble() ?? 0.0,
  };

  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(output));
}

Future<void> _repairDifficultyCache(
  Map<String, String> repairs,
  List<String> errors,
) async {
  const path = 'tools/_reports/.adaptive_difficulty_cache.json';
  final file = File(path);
  if (!await file.exists()) {
    return;
  }

  try {
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      throw const FormatException('empty');
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic> &&
        (decoded['average'] is num || decoded['history'] is List)) {
      return;
    }
  } catch (_) {
    final safe = {'average': 0.5, 'history': <double>[]};
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(safe));
    repairs[path] = 'reset difficulty cache';
  }
}
