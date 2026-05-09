import 'dart:io';

import 'package:poker_analyzer/services/auto_recovery_service.dart';

Future<void> main(List<String> args) async {
  final force = args.contains('--force');
  final service = AutoRecoveryService();
  final metrics = await service.collectMetrics();
  _printSummary(metrics);
  final shouldRecover = force || service.shouldTrigger(metrics);
  if (!shouldRecover) {
    stdout.writeln('Stability within thresholds; no auto recovery triggered.');
    return;
  }
  stdout.writeln(
    force
        ? 'Force flag detected; running auto recovery pipeline...'
        : 'Threshold exceeded; running auto recovery pipeline...',
  );
  final result = await service.recover(metrics: metrics, force: force);
  if (result.triggered) {
    stdout.writeln(
      'Auto recovery triggered. Plan written to ${result.planPath}.',
    );
  } else {
    stdout.writeln('Recovery skipped (conditions changed during evaluation).');
  }
}

void _printSummary(AutoRecoveryMetrics metrics) {
  final rows = <List<String>>[
    ['Crash Rate', '${metrics.crashRatePercent.toStringAsFixed(2)}%'],
    [
      'Stability Score',
      metrics.telemetryEvaluated
          ? metrics.stabilityScore.toStringAsFixed(3)
          : 'N/A',
    ],
    ['Hotfix Detected', metrics.hotfixDetected ? 'YES' : 'No'],
    ['Last Hotfix', metrics.lastHotfixAt?.toUtc().toIso8601String() ?? 'N/A'],
    [
      'Last AI Autotune',
      metrics.lastAutotuneAt?.toUtc().toIso8601String() ?? 'N/A',
    ],
  ];
  final widths = <int>[0, 0];
  for (final row in rows) {
    for (var i = 0; i < row.length; i++) {
      if (row[i].length > widths[i]) {
        widths[i] = row[i].length;
      }
    }
  }
  final border = '+-${'-' * widths[0]}-+-${'-' * widths[1]}-+';
  stdout.writeln(border);
  stdout.writeln(
    '| ${'Metric'.padRight(widths[0])} | ${'Value'.padRight(widths[1])} |',
  );
  stdout.writeln(border);
  for (final row in rows) {
    stdout.writeln(
      '| ${row[0].padRight(widths[0])} | ${row[1].padRight(widths[1])} |',
    );
  }
  stdout.writeln(border);
  if (metrics.notes.isNotEmpty) {
    stdout.writeln('Notes:');
    for (final note in metrics.notes) {
      stdout.writeln('  - $note');
    }
  }
}
