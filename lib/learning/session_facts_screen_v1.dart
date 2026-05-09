import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/learning/phase1_debug_log_capture_v1.dart';

class SessionFactsScreenV1 extends StatefulWidget {
  const SessionFactsScreenV1({super.key});

  @override
  State<SessionFactsScreenV1> createState() => _SessionFactsScreenV1State();
}

class _SessionFactsScreenV1State extends State<SessionFactsScreenV1> {
  @override
  void initState() {
    super.initState();
    assert(kDebugMode);
  }

  void _clearCaptured() {
    Phase1DebugLogCaptureV1.instance.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final capture = Phase1DebugLogCaptureV1.instance;
    final lines = capture.lines;
    final summary = _summarize(lines);
    return Scaffold(
      appBar: AppBar(title: const Text('Session Facts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phase 1 facts-only snapshot'),
            const SizedBox(height: 12),
            Text('Capture: ${capture.isEnabled ? 'ON' : 'OFF'}'),
            if (!capture.isEnabled)
              const Text('Enable capture in Progress Map debug controls.'),
            if (capture.isEnabled && lines.isEmpty)
              const Text('No Phase 1 logs captured yet. Run a session.'),
            if (lines.isNotEmpty) ...[
              Text('Runs: ${summary.totalRuns}'),
              Text('Attempts: ${summary.attemptsTotal}'),
              Text('Correct: ${summary.correctCount}'),
              Text('Incorrect: ${summary.incorrectCount}'),
              Text('Accuracy: ${summary.accuracyPercent.toStringAsFixed(1)}%'),
              Text(
                'Decision time (ms): min ${summary.timeMin ?? '-'} · p50 ${summary.timeP50 ?? '-'} · p90 ${summary.timeP90 ?? '-'} · max ${summary.timeMax ?? '-'} · mean ${summary.timeMean ?? '-'}',
              ),
              Text('Pass A/B delta: ${summary.passDeltaLabel}'),
              const SizedBox(height: 12),
              const Text('Captured lines:'),
              Text('${lines.length}'),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _clearCaptured,
              child: const Text('Clear captured logs'),
            ),
          ],
        ),
      ),
    );
  }
}

_FactsSummary _summarize(List<String> lines) {
  final runRecords = <String, _RunRecord>{};
  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final marker = _detectMarker(line);
    if (marker == null) continue;
    final payload = _parsePayload(line, marker);
    final runId = payload['run_id'] as String?;
    if (runId == null || runId.isEmpty) continue;
    final record = runRecords.putIfAbsent(runId, () => _RunRecord(runId));
    record.kick(marker, payload);
  }
  return _FactsSummary.fromRecords(runRecords.values.toList());
}

String? _detectMarker(String line) {
  if (line.contains('PHASE1_FLOW_END')) return 'PHASE1_FLOW_END';
  if (line.contains('PHASE1_ATTEMPT_RESULT')) return 'PHASE1_ATTEMPT_RESULT';
  if (line.contains('PHASE1_ATTEMPT_START')) return 'PHASE1_ATTEMPT_START';
  if (line.contains('PHASE1_PASS')) return 'PHASE1_PASS';
  if (line.contains('PHASE1_SESSION_START')) return 'PHASE1_SESSION_START';
  return null;
}

Map<String, dynamic> _parsePayload(String line, String marker) {
  final idx = line.indexOf(marker);
  if (idx == -1) return {};
  final start = line.indexOf('{', idx);
  if (start == -1) return {};
  final jsonPart = line.substring(start).trim();
  return jsonDecode(jsonPart) as Map<String, dynamic>;
}

class _RunRecord {
  _RunRecord(this.runId);

  final String runId;
  String? currentPass;
  int attemptTotal = 0;
  int correctCount = 0;
  int incorrectCount = 0;
  final List<double> decisionTimes = [];
  final Map<String, _PassStats> passes = {};

  void kick(String marker, Map<String, dynamic> payload) {
    switch (marker) {
      case 'PHASE1_PASS':
        final pass = (payload['pass'] as String?)?.toUpperCase();
        if (pass == 'A' || pass == 'B') {
          final passKey = pass!;
          currentPass = passKey;
          passes.putIfAbsent(passKey, _PassStats.new);
        }
        break;
      case 'PHASE1_ATTEMPT_RESULT':
        attemptTotal++;
        final result = payload['result'] as String? ?? '';
        final isCorrect = result == 'correct';
        if (isCorrect) {
          correctCount++;
        } else {
          incorrectCount++;
        }
        final duration = payload['decision_time_ms'];
        if (duration is num) {
          decisionTimes.add(duration.toDouble());
        }
        final pass = currentPass;
        if (pass != null) {
          final stats = passes.putIfAbsent(pass, _PassStats.new);
          stats.record(isCorrect, duration);
        }
        break;
    }
  }
}

class _PassStats {
  int attempts = 0;
  int correct = 0;
  final List<double> decisionTimes = [];

  void record(bool isCorrect, Object? duration) {
    attempts++;
    if (isCorrect) {
      correct++;
      if (duration is num) {
        decisionTimes.add(duration.toDouble());
      }
    }
  }

  double get accuracy => attempts == 0 ? 0 : correct / attempts;

  double? get decisionTimeMean {
    if (decisionTimes.isEmpty) return null;
    final sum = decisionTimes.reduce((a, b) => a + b);
    return sum / decisionTimes.length;
  }
}

class _FactsSummary {
  _FactsSummary({
    required this.totalRuns,
    required this.attemptsTotal,
    required this.correctCount,
    required this.incorrectCount,
    required this.accuracyPercent,
    required this.timeMin,
    required this.timeP50,
    required this.timeP90,
    required this.timeMax,
    required this.timeMean,
    required this.passDeltaLabel,
  });

  final int totalRuns;
  final int attemptsTotal;
  final int correctCount;
  final int incorrectCount;
  final double accuracyPercent;
  final int? timeMin;
  final int? timeP50;
  final int? timeP90;
  final int? timeMax;
  final int? timeMean;
  final String passDeltaLabel;

  static _FactsSummary fromRecords(List<_RunRecord> records) {
    final attempts = records.fold<int>(0, (a, b) => a + b.attemptTotal);
    final correct = records.fold<int>(0, (a, b) => a + b.correctCount);
    final incorrect = records.fold<int>(0, (a, b) => a + b.incorrectCount);
    final times = records.expand((r) => r.decisionTimes).toList();
    times.sort();
    final accuracy = attempts == 0 ? 0.0 : (correct / attempts) * 100;

    int? pct(double p) {
      if (times.isEmpty) return null;
      final index = (times.length - 1) * p;
      final lower = times[index.floor()];
      final upper = times[index.ceil()];
      final value = lower + (upper - lower) * (index - index.floor());
      return value.round();
    }

    final timeMean = times.isEmpty
        ? null
        : (times.reduce((a, b) => a + b) / times.length).round();

    final passDelta = _passDelta(records);
    final deltaLabel = passDelta == null
        ? 'not available'
        : '${passDelta.toStringAsFixed(2)} accuracy (B-A)';

    return _FactsSummary(
      totalRuns: records.length,
      attemptsTotal: attempts,
      correctCount: correct,
      incorrectCount: incorrect,
      accuracyPercent: accuracy,
      timeMin: times.isEmpty ? null : times.first.round(),
      timeP50: pct(0.5),
      timeP90: pct(0.9),
      timeMax: times.isEmpty ? null : times.last.round(),
      timeMean: timeMean,
      passDeltaLabel: deltaLabel,
    );
  }

  static double? _passDelta(List<_RunRecord> records) {
    for (final record in records) {
      final passA = record.passes['A'];
      final passB = record.passes['B'];
      if (passA != null && passB != null) {
        return passB.accuracy - passA.accuracy;
      }
    }
    return null;
  }
}
