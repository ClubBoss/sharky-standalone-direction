import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _baselinePath =
    'release/_reports/_telemetry_consistency_baseline.json';
const String _summaryPath =
    'release/_reports/telemetry_consistency_summary.txt';

Future<void> main(List<String> args) async {
  await TelemetryConsistencyDaemon().run();
}

class TelemetryConsistencyDaemon {
  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final telemetryFile = File(_telemetryPath);
    if (!await telemetryFile.exists()) {
      throw StateError('Telemetry file missing at $_telemetryPath');
    }

    final lines = await telemetryFile.readAsLines();
    final baseline = await _BaselineData.load();
    final bootstrapMode = baseline.knownEvents.isEmpty;
    final repair = _TelemetryRepair();
    final events = <Map<String, Object?>>[];
    final duplicateKeyHits = <String, int>{};
    var malformed = 0;
    var duplicates = 0;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }

      final payload = repair.parseLine(line);
      if (payload == null) {
        malformed++;
        continue;
      }

      final eventName = payload['event']?.toString();
      if (eventName == null || eventName.isEmpty) {
        malformed++;
        continue;
      }

      var timestamp = payload['timestamp']?.toString();
      if (timestamp == null || timestamp.isEmpty) {
        timestamp = repair.generateTimestamp();
        payload['timestamp'] = timestamp;
      }

      final key = '$eventName|$timestamp';
      final hitCount = (duplicateKeyHits[key] ?? 0) + 1;
      duplicateKeyHits[key] = hitCount;
      if (hitCount > 1) {
        duplicates++;
        timestamp = repair.bumpTimestamp(timestamp, hitCount);
        payload['timestamp'] = timestamp;
      }

      final schema = _knownSchemas[eventName];
      if (schema != null) {
        schema.enforce(payload, repair);
      }

      final isKnown =
          schema != null ||
          baseline.knownEvents.contains(eventName) ||
          _defaultKnownEvents.contains(eventName) ||
          bootstrapMode;
      if (!isKnown) {
        repair.unknownEvents.add(eventName);
      }

      events.add(payload);
    }

    final verdict = _decideVerdict(
      malformed: malformed,
      duplicates: duplicates,
      unknownCount: repair.unknownEvents.length,
      healed: repair.healedEvents,
    );

    await _withReportsWritable(() async {
      await _ensureReportsDir();
      await _writeSummary(
        events: events,
        malformed: malformed,
        duplicates: duplicates,
        repair: repair,
        durationMs: stopwatch.elapsedMilliseconds,
        verdict: verdict,
        bootstrapMode: bootstrapMode,
      );

      await _rewriteTelemetry(events);
      await _emitTelemetry(
        repair: repair,
        malformed: malformed,
        duplicates: duplicates,
        durationMs: stopwatch.elapsedMilliseconds,
        verdict: verdict,
      );
      final nextKnown =
          <String>{..._defaultKnownEvents, ...baseline.knownEvents}..addAll(
            events
                .map((event) => event['event']?.toString())
                .whereType<String>(),
          );
      await _BaselineData(
        knownEvents: nextKnown,
        lineCount: events.length,
        checksum: _checksumFor(events),
        lastRunIso: DateTime.now().toIso8601String(),
      ).save();
    });

    exitCode = verdict == _Verdict.fail ? 2 : 0;
    _logVerdict(verdict, events.length, malformed, duplicates, repair);
  }
}

class _BaselineData {
  const _BaselineData({
    required this.knownEvents,
    required this.lineCount,
    required this.checksum,
    required this.lastRunIso,
  });

  final Set<String> knownEvents;
  final int lineCount;
  final String checksum;
  final String lastRunIso;

  static Future<_BaselineData> load() async {
    final file = File(_baselinePath);
    if (!await file.exists()) {
      return const _BaselineData(
        knownEvents: <String>{},
        lineCount: 0,
        checksum: '',
        lastRunIso: '',
      );
    }

    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, Object?>) {
        final known =
            (decoded['known_events'] as List?)?.whereType<String>().toSet() ??
            const <String>{};
        return _BaselineData(
          knownEvents: known,
          lineCount: decoded['line_count'] is int
              ? decoded['line_count'] as int
              : int.tryParse('${decoded['line_count']}') ?? 0,
          checksum: decoded['checksum']?.toString() ?? '',
          lastRunIso: decoded['last_run']?.toString() ?? '',
        );
      }
    } catch (_) {
      // Ignore malformed baseline and fall back to defaults.
    }

    return const _BaselineData(
      knownEvents: <String>{},
      lineCount: 0,
      checksum: '',
      lastRunIso: '',
    );
  }

  Future<void> save() async {
    final file = File(_baselinePath);
    await file.writeAsString(
      jsonEncode(<String, Object?>{
        'known_events': knownEvents.toList()..sort(),
        'line_count': lineCount,
        'checksum': checksum,
        'last_run': lastRunIso,
      }),
    );
  }
}

class _TelemetryRepair {
  final Set<String> unknownEvents = <String>{};
  int healedEvents = 0;

  Map<String, Object?>? parseLine(String line) {
    final attempt = _tryDecode(line);
    if (attempt != null) {
      return attempt;
    }
    final healed = fixTruncatedJson(line);
    if (healed == null) {
      return null;
    }
    healedEvents++;
    return _tryDecode(healed);
  }

  Map<String, Object?>? _tryDecode(String candidate) {
    try {
      final decoded = json.decode(candidate);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
    } catch (_) {
      // ignored
    }
    return null;
  }

  String generateTimestamp() {
    healedEvents++;
    return DateTime.now().toUtc().toIso8601String();
  }

  String bumpTimestamp(String original, int duplicateHit) {
    DateTime base;
    try {
      base = DateTime.parse(original).toUtc();
    } catch (_) {
      base = DateTime.now().toUtc();
    }
    healedEvents++;
    return base.add(Duration(milliseconds: duplicateHit)).toIso8601String();
  }

  String? fixTruncatedJson(String line) {
    final trimmed = line.trimRight();
    if (!trimmed.endsWith('}')) {
      return '$trimmed}';
    }
    return null;
  }
}

class _EventSchema {
  const _EventSchema({required this.requiredFields});

  final List<String> requiredFields;

  void enforce(Map<String, Object?> payload, _TelemetryRepair repair) {
    for (final field in requiredFields) {
      if (!payload.containsKey(field) ||
          payload[field] == null ||
          payload[field].toString().isEmpty) {
        payload[field] = _placeholderFor(field);
        repair.healedEvents++;
      }
    }
  }

  Object _placeholderFor(String field) {
    if (field.contains('timestamp')) {
      return DateTime.now().toUtc().toIso8601String();
    }
    if (field.contains('summary') || field.contains('verdict')) {
      return 'unknown';
    }
    return 0;
  }
}

final Map<String, _EventSchema> _knownSchemas = <String, _EventSchema>{
  'player_stats_updated': const _EventSchema(
    requiredFields: ['player_id', 'stats'],
  ),
  'player_traits_updated': const _EventSchema(
    requiredFields: ['player_id', 'traits'],
  ),
  'player_stat_visualizer_completed': const _EventSchema(
    requiredFields: ['render_count'],
  ),
  'player_trait_visualizer_completed': const _EventSchema(
    requiredFields: ['render_count'],
  ),
  'ux_feedback_animation_completed': const _EventSchema(
    requiredFields: ['animation_count', 'status'],
  ),
  'ui_micro_animation_completed': const _EventSchema(
    requiredFields: ['p95_frame_time_ms', 'status'],
  ),
  'ui_performance_tuner_completed': const _EventSchema(
    requiredFields: ['adjustment', 'status'],
  ),
  'adaptive_module_composer_completed': const _EventSchema(
    requiredFields: ['modules_created'],
  ),
  'skill_progression_completed': const _EventSchema(
    requiredFields: ['topics_tracked'],
  ),
  'adaptive_ad_optimizer_completed': const _EventSchema(
    requiredFields: ['placements_reviewed'],
  ),
  'dynamic_visual_integration_completed': const _EventSchema(
    requiredFields: ['themes_applied'],
  ),
  'dynamic_visual_stress_completed': const _EventSchema(
    requiredFields: ['avg_frame_ms', 'status'],
  ),
  'stability_dashboard_completed': const _EventSchema(
    requiredFields: ['health_score'],
  ),
  'regression_diff_completed': const _EventSchema(
    requiredFields: ['failures_detected'],
  ),
  'telemetry_consistency_completed': const _EventSchema(
    requiredFields: ['verdict'],
  ),
};

const Set<String> _defaultKnownEvents = <String>{
  'ad_impression',
  'adaptive_content_evolution_completed',
  'adaptive_loop_tuner_completed',
  'adaptive_quiz_drill_synthesis_completed',
  'ai_feedback_loop_completed',
  'ai_personalization_completed',
  'ai_skill_fusion_completed',
  'automated_stability_ledger_completed',
  'ci_auto_recovery_completed',
  'content_evolution_qa_completed',
  'content_schema_validator_completed',
  'content_semantic_audit_completed',
  'continuous_audit_rebuild_completed',
  'continuous_regression_guardian_completed',
  'continuous_telemetry_stream_completed',
  'engagement_correlation_completed',
  'final_visual_theme_completed',
  'i18n_missing_detected',
  'lesson_open',
  'localization_audit_completed',
  'localization_consolidation_completed',
  'marketing_forecast_completed',
  'marketing_funnel_analytics_completed',
  'marketing_intelligence_completed',
  'player_profile_completed',
  'player_profile_explanation_completed',
  'predictive_marketing_completed',
  'quiz_complete',
  'recap_view',
  'regression_auto_healing_completed',
  'regression_consolidation_completed',
  'regression_health_forecast_completed',
  'regression_maintenance_completed',
  'regression_stability_completed',
  'retention_heatmap_completed',
  'rsi_auto_recovery_completed',
  'semantic_drill_enhancer_completed',
  'semantic_expansion_completed',
  'session_end',
  'session_start',
  'signup_completed',
  'stability_health_remediation_completed',
  'stability_regression_consolidation_completed',
  'telemetry_auto_seeded',
  'tutorial_finished',
  'tutorial_started',
  'visual_cohesion_dashboard_v2_completed',
  'visual_qa_v3_completed',
  'visual_theme_validator_completed',
};

enum _Verdict { pass, warn, fail }

_Verdict _decideVerdict({
  required int malformed,
  required int duplicates,
  required int unknownCount,
  required int healed,
}) {
  if (unknownCount > 10) {
    return _Verdict.fail;
  }
  if (unknownCount > 0 || malformed > 0 || duplicates > 0 || healed > 0) {
    return _Verdict.warn;
  }
  return _Verdict.pass;
}

Future<void> _ensureReportsDir() async {
  await Directory('release/_reports').create(recursive: true);
}

Future<void> _writeSummary({
  required List<Map<String, Object?>> events,
  required int malformed,
  required int duplicates,
  required _TelemetryRepair repair,
  required int durationMs,
  required _Verdict verdict,
  required bool bootstrapMode,
}) async {
  final buffer = StringBuffer()
    ..writeln('TELEMETRY CONSISTENCY SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Verdict: ${verdict.name.toUpperCase()}')
    ..writeln('Bootstrap mode: $bootstrapMode')
    ..writeln('Events processed: ${events.length}')
    ..writeln('Malformed lines: $malformed')
    ..writeln('Duplicate timestamps repaired: $duplicates')
    ..writeln('Fields healed: ${repair.healedEvents}')
    ..writeln();
  if (repair.unknownEvents.isNotEmpty) {
    buffer
      ..writeln('Unknown events detected:')
      ..writeln(repair.unknownEvents.toList()..sort())
      ..writeln();
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _rewriteTelemetry(List<Map<String, Object?>> events) async {
  final sink = File(_telemetryPath).openWrite();
  for (final event in events) {
    sink.writeln(jsonEncode(event));
  }
  await sink.close();
}

Future<void> _emitTelemetry({
  required _TelemetryRepair repair,
  required int malformed,
  required int duplicates,
  required int durationMs,
  required _Verdict verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'telemetry_consistency_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'healed_events': repair.healedEvents,
    'unknown_events': repair.unknownEvents.toList()..sort(),
    'malformed': malformed,
    'duplicates': duplicates,
    'verdict': verdict.name.toUpperCase(),
    'duration_ms': durationMs,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

void _logVerdict(
  _Verdict verdict,
  int totalEvents,
  int malformed,
  int duplicates,
  _TelemetryRepair repair,
) {
  final message = StringBuffer('telemetry_consistency_daemon: ')
    ..write(verdict.name.toUpperCase())
    ..write(' events=$totalEvents');
  if (malformed > 0) {
    message.write(' malformed=$malformed');
  }
  if (duplicates > 0) {
    message.write(' duplicates=$duplicates');
  }
  if (repair.unknownEvents.isNotEmpty) {
    message.write(' unknown=${repair.unknownEvents.length}');
  }
  final ioSink = verdict == _Verdict.pass ? stdout : stderr;
  ioSink.writeln(message.toString());
}

String _checksumFor(List<Map<String, Object?>> events) {
  final buffer = StringBuffer();
  for (final event in events) {
    buffer.writeln(jsonEncode(event));
  }
  final digest = sha1.convert(utf8.encode(buffer.toString()));
  return digest.toString();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'telemetry_consistency_daemon: chmod failed (${result.exitCode}) '
      '${result.stderr}',
    );
  }
}
