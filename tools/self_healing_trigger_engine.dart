import 'dart:convert';
import 'dart:io';

const String _systemicRiskPath = 'release/_reports/systemic_risk_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/self_healing_summary.txt';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final systemic = await _parseSystemicSummary();
  final actions = _deriveActions(systemic);

  final totalDelta = actions.fold<double>(
    0,
    (sum, action) => sum + action.delta,
  );
  final riskAfter = ((systemic.riskScore - totalDelta).clamp(
    0,
    systemic.riskScore,
  )).toDouble();
  final riskReduction = double.parse(
    (systemic.riskScore - riskAfter).toStringAsFixed(2),
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      systemic: systemic,
      actions: actions,
      riskAfter: riskAfter,
    );
    await _appendTelemetry(
      actionsCount: actions.length,
      riskReduction: riskReduction,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'self_healing_trigger_engine: actions=${actions.length} '
    'riskAfter=${riskAfter.toStringAsFixed(2)}',
  );
}

Future<_SystemicSnapshot> _parseSystemicSummary() async {
  final file = File(_systemicRiskPath);
  if (!await file.exists()) return const _SystemicSnapshot();
  final lines = await file.readAsLines();
  double riskScore = 0;
  String band = 'GREEN';
  final recs = <String>[];
  bool inRecs = false;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Risk Score:')) {
      final match = RegExp(
        r'Risk Score:\s*([\d.]+)\s*\((\w+)\)',
      ).firstMatch(trimmed);
      if (match != null) {
        riskScore = double.tryParse(match.group(1) ?? '') ?? 0;
        band = match.group(2) ?? band;
      }
    } else if (trimmed == 'Recommendations') {
      inRecs = true;
      continue;
    } else if (inRecs) {
      if (!trimmed.startsWith('- ')) break;
      recs.add(trimmed.substring(2).trim());
    }
  }
  return _SystemicSnapshot(
    riskScore: riskScore,
    riskBand: band,
    recommendations: recs,
  );
}

List<_HealingAction> _deriveActions(_SystemicSnapshot snapshot) {
  final shouldTrigger =
      snapshot.riskBand == 'RED' ||
      (snapshot.riskBand == 'ORANGE' && snapshot.riskScore >= 0.35);
  if (!shouldTrigger) return const [];

  final actionMap = <String, _HealingAction>{};
  for (final rec in snapshot.recommendations) {
    final action = _mapRecommendation(rec);
    if (action == null) continue;
    actionMap[action.name] = action;
  }
  return actionMap.values.toList();
}

_HealingAction? _mapRecommendation(String rec) {
  final lower = rec.toLowerCase();
  if (lower.contains('telemetry')) {
    return const _HealingAction(
      name: 'Telemetry Reference Repair',
      detail: 'Auto-heal missing telemetry links across Ω-series reports.',
      delta: 0.07,
    );
  }
  if (lower.contains('retention')) {
    return const _HealingAction(
      name: 'Retention Playbook Sprint',
      detail: 'Spin up retention boosters to reduce drift.',
      delta: 0.05,
    );
  }
  if (lower.contains('variance')) {
    return const _HealingAction(
      name: 'Cross-channel Cadence Sync',
      detail: 'Align messaging cadence to dampen variance.',
      delta: 0.04,
    );
  }
  if (lower.contains('mitigation')) {
    return const _HealingAction(
      name: 'Mitigation Review Council',
      detail: 'Trigger executive mitigation review within 48h.',
      delta: 0.03,
    );
  }
  if (lower.contains('risk')) {
    return const _HealingAction(
      name: 'Systemic Risk Audit',
      detail: 'Run ad-hoc systemic risk audit.',
      delta: 0.02,
    );
  }
  return null;
}

Future<void> _writeSummary({
  required _SystemicSnapshot systemic,
  required List<_HealingAction> actions,
  required double riskAfter,
}) async {
  final buffer = StringBuffer()
    ..writeln('SELF-HEALING SUMMARY')
    ..writeln('====================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Risk before: ${systemic.riskScore.toStringAsFixed(2)} '
      '(${systemic.riskBand})',
    )
    ..writeln('Risk after (predicted): ${riskAfter.toStringAsFixed(2)}')
    ..writeln('Actions triggered: ${actions.length}')
    ..writeln();

  if (actions.isEmpty) {
    buffer.writeln('No self-healing actions required at current risk level.');
  } else {
    buffer
      ..writeln('| Action | Delta | Detail |')
      ..writeln('|--------|-------|--------|');
    for (final action in actions) {
      buffer.writeln(
        '| ${action.name} | ${action.delta.toStringAsFixed(2)} | ${action.detail} |',
      );
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int actionsCount,
  required double riskReduction,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'self_healing_triggered',
    'timestamp': DateTime.now().toIso8601String(),
    'actions_count': actionsCount,
    'risk_reduction': riskReduction,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
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
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'self_healing_trigger_engine: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _SystemicSnapshot {
  const _SystemicSnapshot({
    this.riskScore = 0,
    this.riskBand = 'GREEN',
    this.recommendations = const [],
  });

  final double riskScore;
  final String riskBand;
  final List<String> recommendations;
}

class _HealingAction {
  const _HealingAction({
    required this.name,
    required this.detail,
    required this.delta,
  });

  final String name;
  final String detail;
  final double delta;
}
