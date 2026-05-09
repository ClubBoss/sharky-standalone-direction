// AI Personalization Core Service
// Stage Φ-v2-B
// Pure Dart (no Flutter)

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:poker_analyzer/personalization/personalization_contracts_v1.dart';

/// Aggregates user telemetry and computes personalization weights.
/// Exposes recommendation and visual profile APIs.
class AiPersonalizationService {
  final String telemetryDir;
  final String sessionLogDir;
  final Map<String, dynamic> config;
  final DateTime Function() _now;
  final Future<List<String>> Function()? _readTelemetryLines;
  final Future<List<String>> Function()? _readSessionLogs;
  final Future<void> Function(String line)? _writeOut;

  Map<String, dynamic> _lastWeights = {};
  DateTime? _lastUpdate;

  AiPersonalizationService({
    required this.telemetryDir,
    required this.sessionLogDir,
    this.config = const {},
    DateTime Function()? now,
    Future<List<String>> Function()? readTelemetryLines,
    Future<List<String>> Function()? readSessionLogs,
    Future<void> Function(String line)? writeOut,
  }) : _now = now ?? DateTime.now,
       _readTelemetryLines = readTelemetryLines,
       _readSessionLogs = readSessionLogs,
       _writeOut = writeOut;

  /// Aggregates telemetry and computes personalization weights.
  Future<void> updatePersonalization() async {
    final telemetry = await _aggregateTelemetry();
    final sessionHistory = await _aggregateSessionHistory();
    final weights = _computeWeights(telemetry, sessionHistory);
    _lastWeights = weights;
    _lastUpdate = _now();
    await _emitTelemetry(weights);
  }

  /// Returns the next recommended training pack/module.
  String getNextRecommendedPack() {
    // Example: pick based on lowest accuracy or streak
    final modules = _lastWeights['modules'] ?? [];
    if (modules.isEmpty) return 'default_pack';
    modules.sort((a, b) => (a['score'] as num).compareTo(b['score'] as num));
    return modules.first['id'] ?? 'default_pack';
  }

  /// Adjusts the user's visual profile (e.g., mood, theme).
  Map<String, dynamic> adjustVisualProfile() {
    // Example: set mood based on recent streak
    final streak = _lastWeights['streak'] ?? 0;
    final mood = streak > 5
        ? 'confident'
        : (streak < 0 ? 'frustrated' : 'neutral');
    return {'mood': mood};
  }

  // --- Internal helpers ---

  Future<Map<String, dynamic>> _aggregateTelemetry() async {
    final injectedLines = _readTelemetryLines != null
        ? await _readTelemetryLines()
        : null;
    final dir = Directory(telemetryDir);
    if (injectedLines == null && !await dir.exists()) return {};
    final files = injectedLines == null
        ? await dir.list().where((f) => f.path.endsWith('.jsonl')).toList()
        : const <FileSystemEntity>[];
    int total = 0, correct = 0, streak = 0, lastStreak = 0;
    final moduleStats = <String, Map<String, dynamic>>{};
    final sources = injectedLines != null
        ? [injectedLines]
        : await Future.wait(files.map((file) => File(file.path).readAsLines()));
    for (final lines in sources) {
      for (final line in lines) {
        final event = json.decode(line);
        if (event is! Map) continue;
        if (event['type'] == 'spot_answered') {
          total++;
          if (event['correct'] == true) {
            correct++;
            streak++;
          } else {
            streak = 0;
          }
          final mod = event['module'] ?? 'unknown';
          moduleStats.putIfAbsent(mod, () => {'total': 0, 'correct': 0});
          moduleStats[mod]!['total'] += 1;
          if (event['correct'] == true) moduleStats[mod]!['correct'] += 1;
        }
        if (event['type'] == 'session_end') {
          lastStreak = streak;
          streak = 0;
        }
      }
    }
    final accuracy = total > 0 ? correct / total : 0.0;
    final modules = moduleStats.entries.map((e) {
      final acc = e.value['total'] > 0
          ? e.value['correct'] / e.value['total']
          : 0.0;
      return {'id': e.key, 'score': acc};
    }).toList();
    return {'accuracy': accuracy, 'streak': lastStreak, 'modules': modules};
  }

  Future<Map<String, dynamic>> _aggregateSessionHistory() async {
    final injectedLines = _readSessionLogs != null
        ? await _readSessionLogs()
        : null;
    final dir = Directory(sessionLogDir);
    if (injectedLines == null && !await dir.exists()) return {};
    final files = injectedLines == null
        ? await dir.list().where((f) => f.path.endsWith('.json')).toList()
        : const <FileSystemEntity>[];
    int totalSessions = 0;
    double totalTime = 0;
    final moduleHistory = <String, int>{};
    final sources = injectedLines != null
        ? injectedLines
        : await Future.wait(
            files.map((file) => File(file.path).readAsString()),
          );
    for (final payload in sources) {
      final data = json.decode(payload);
      if (data is! Map) continue;
      totalSessions++;
      totalTime += (data['duration_sec'] ?? 0) as num;
      final mod = data['module'] ?? 'unknown';
      moduleHistory[mod] = (moduleHistory[mod] ?? 0) + 1;
    }
    return {
      'totalSessions': totalSessions,
      'avgSessionTime': totalSessions > 0 ? totalTime / totalSessions : 0.0,
      'moduleHistory': moduleHistory,
    };
  }

  Map<String, dynamic> _computeWeights(
    Map<String, dynamic> telemetry,
    Map<String, dynamic> session,
  ) {
    // Example: combine accuracy, streak, session time, module history
    final accuracy = telemetry['accuracy'] ?? 0.0;
    final streak = telemetry['streak'] ?? 0;
    final avgTime = session['avgSessionTime'] ?? 0.0;
    final modules = telemetry['modules'] ?? [];
    // Simple weights: higher accuracy = harder packs, low = easier
    final difficulty = accuracy > 0.85
        ? 'hard'
        : (accuracy < 0.6 ? 'easy' : 'medium');
    return {
      'accuracy': accuracy,
      'streak': streak,
      'avgSessionTime': avgTime,
      'difficulty': difficulty,
      'modules': modules,
      'moduleHistory': session['moduleHistory'] ?? {},
    };
  }

  Future<void> _emitTelemetry(Map<String, dynamic> weights) async {
    final event = {
      kAiPersonalizationCompletedKeyEvent: kAiPersonalizationCompletedSchemaV1,
      kAiPersonalizationCompletedKeyTimestamp: _now().toIso8601String(),
      kAiPersonalizationCompletedKeyWeights: weights,
      kAiPersonalizationCompletedKeyDurationMs: 0,
      if (_lastUpdate != null)
        kAiPersonalizationCompletedKeyLastUpdate: _lastUpdate!
            .toIso8601String(),
    };
    final line = json.encode(event) + '\n';
    if (_writeOut != null) {
      await _writeOut(line);
      return;
    }
    final outPath = p.join(telemetryDir, 'ai_personalization_telemetry.jsonl');
    final outFile = File(outPath);
    await outFile.writeAsString(line, mode: FileMode.append);
  }
}
