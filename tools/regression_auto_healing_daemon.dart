import 'dart:convert';
import 'dart:io';

const String _maintenanceSummaryPath =
    'release/_reports/regression_maintenance_summary.txt';
const String _healSummaryPath =
    'release/_reports/regression_auto_healing_summary.txt';
const String _historyPath =
    'release/_reports/_regression_maintenance_history.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final daemon = RegressionAutoHealingDaemon();
  await daemon.run();
}

class RegressionAutoHealingDaemon {
  Future<void> run() async {
    final initial = await _readSnapshot();
    if (initial == null) {
      stderr.writeln(
        'Unable to read regression maintenance summary at $_maintenanceSummaryPath',
      );
      exitCode = 1;
      return;
    }

    final healAttempts = <_HealAttempt>[];
    final failures = initial.stages
        .where((stage) => stage.verdict == 'FAIL')
        .toList();

    for (final stage in failures) {
      healAttempts.add(await _runHeal(stage));
    }

    final maintenanceRerun = await _rerunMaintenance();
    final after = await _readSnapshot();

    final healedStages = <_StageHealStatus>[];
    if (after != null) {
      for (final stage in initial.stages) {
        final updated = after.stages.firstWhere(
          (s) => s.name == stage.name,
          orElse: () => stage,
        );
        if (stage.verdict == 'FAIL') {
          healedStages.add(
            _StageHealStatus(
              name: stage.name,
              before: stage.verdict,
              after: updated.verdict,
              healed: updated.verdict == 'PASS' || updated.verdict == 'WARN',
            ),
          );
        }
      }
    }

    final finalSnapshot = after ?? initial;
    final success =
        finalSnapshot.verdict == 'PASS' &&
        finalSnapshot.regressionStabilityIndex >= 90;

    await _withReportsWritable(() async {
      await _writeSummary(
        initial: initial,
        finalSnapshot: finalSnapshot,
        healAttempts: healAttempts,
        maintenanceRerun: maintenanceRerun,
        stageStatuses: healedStages,
      );
      await _updateHistory(finalSnapshot, source: 'auto_healing');
      await _emitTelemetry(
        initial: initial,
        finalSnapshot: finalSnapshot,
        healAttempts: healAttempts,
        success: success,
      );
    });

    if (!success) {
      exitCode = 1;
    }
  }
}

Future<_MaintenanceSnapshot?> _readSnapshot() async {
  final file = File(_maintenanceSummaryPath);
  if (!await file.exists()) return null;
  final lines = await file.readAsLines();
  double? rsi;
  String verdict = 'FAIL';
  final stages = <_StageOutcome>[];
  bool inStages = false;

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.startsWith('Regression Stability Index:')) {
      final value = line.split(':').last.trim().replaceAll('%', '');
      rsi = double.tryParse(value);
    } else if (line.startsWith('Verdict:')) {
      verdict = line.split(':').last.trim();
    } else if (line.startsWith('Per-stage breakdown')) {
      inStages = true;
      continue;
    } else if (inStages && line.startsWith('- ')) {
      final stageLine = line.substring(2);
      final colonIndex = stageLine.indexOf(':');
      if (colonIndex == -1) continue;
      final name = stageLine.substring(0, colonIndex).trim();
      final remainder = stageLine.substring(colonIndex + 1).trim();
      final verdictToken = remainder.split(' ').first;
      var command = '';
      if (i + 1 < lines.length) {
        final nextLine = lines[i + 1].trimLeft();
        if (nextLine.startsWith('command:')) {
          command = nextLine.substring('command:'.length).trim();
        }
      }
      stages.add(
        _StageOutcome(name: name, verdict: verdictToken, command: command),
      );
    } else if (inStages && line.isEmpty) {
      inStages = false;
    }
  }

  if (rsi == null) return null;
  return _MaintenanceSnapshot(
    regressionStabilityIndex: rsi,
    verdict: verdict,
    stages: stages,
  );
}

Future<_HealAttempt> _runHeal(_StageOutcome stage) async {
  final args = _splitCommand(stage.command);
  final stopwatch = Stopwatch()..start();
  final result = await Process.run(
    args.isNotEmpty ? args.first : 'true',
    args.length > 1 ? args.sublist(1) : const <String>[],
    workingDirectory: Directory.current.path,
  );
  stopwatch.stop();
  return _HealAttempt(
    stage: stage.name,
    command: stage.command,
    exitCode: result.exitCode,
    durationMs: stopwatch.elapsedMilliseconds,
  );
}

Future<_MaintenanceRerunResult> _rerunMaintenance() async {
  final stopwatch = Stopwatch()..start();
  final result = await Process.run('dart', [
    'run',
    'tools/regression_maintenance_loop.dart',
  ], workingDirectory: Directory.current.path);
  stopwatch.stop();
  return _MaintenanceRerunResult(
    exitCode: result.exitCode,
    durationMs: stopwatch.elapsedMilliseconds,
  );
}

Future<void> _writeSummary({
  required _MaintenanceSnapshot initial,
  required _MaintenanceSnapshot finalSnapshot,
  required List<_HealAttempt> healAttempts,
  required _MaintenanceRerunResult maintenanceRerun,
  required List<_StageHealStatus> stageStatuses,
}) async {
  final buffer = StringBuffer()
    ..writeln('REGRESSION AUTO-HEALING SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Initial RSI: ${initial.regressionStabilityIndex.toStringAsFixed(2)}% (${initial.verdict})',
    )
    ..writeln(
      'Final RSI: ${finalSnapshot.regressionStabilityIndex.toStringAsFixed(2)}% (${finalSnapshot.verdict})',
    )
    ..writeln(
      'Maintenance rerun: exit ${maintenanceRerun.exitCode} in ${maintenanceRerun.durationMs}ms',
    )
    ..writeln();

  if (healAttempts.isEmpty) {
    buffer.writeln('No failing stages detected.');
  } else {
    buffer.writeln('Heal attempts:');
    for (final attempt in healAttempts) {
      buffer.writeln(
        '- ${attempt.stage}: exit ${attempt.exitCode}, ${attempt.durationMs}ms',
      );
      buffer.writeln('  command: ${attempt.command}');
    }
  }

  if (stageStatuses.isEmpty) {
    buffer.writeln('\nNo stage verdict changes detected.');
  } else {
    buffer.writeln('\nStage verdict changes:');
    for (final status in stageStatuses) {
      buffer.writeln(
        '- ${status.name}: ${status.before} → ${status.after} '
        '(${status.healed ? 'healed' : 'still failing'})',
      );
    }
  }

  await File(_healSummaryPath).writeAsString(buffer.toString());
}

Future<void> _updateHistory(
  _MaintenanceSnapshot snapshot, {
  required String source,
}) async {
  final history = await _loadHistory();
  final passCount = snapshot.stages
      .where((stage) => stage.verdict == 'PASS')
      .length;
  final warnCount = snapshot.stages
      .where((stage) => stage.verdict == 'WARN')
      .length;
  final failCount = snapshot.stages
      .where((stage) => stage.verdict == 'FAIL')
      .length;
  history.add({
    'timestamp': DateTime.now().toIso8601String(),
    'regression_stability_index': snapshot.regressionStabilityIndex,
    'pass': passCount,
    'warn': warnCount,
    'fail': failCount,
    'verdict': snapshot.verdict,
    'source': source,
  });
  while (history.length > 25) {
    history.removeAt(0);
  }
  await File(
    _historyPath,
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(history));
}

Future<void> _emitTelemetry({
  required _MaintenanceSnapshot initial,
  required _MaintenanceSnapshot finalSnapshot,
  required List<_HealAttempt> healAttempts,
  required bool success,
}) async {
  final payload = <String, Object?>{
    'event': 'regression_auto_healing_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'initial_rsi': initial.regressionStabilityIndex,
    'final_rsi': finalSnapshot.regressionStabilityIndex,
    'initial_verdict': initial.verdict,
    'final_verdict': finalSnapshot.verdict,
    'heal_attempts': healAttempts
        .map(
          (attempt) => {
            'stage': attempt.stage,
            'exit_code': attempt.exitCode,
            'duration_ms': attempt.durationMs,
          },
        )
        .toList(),
    'success': success,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<List<Map<String, Object?>>> _loadHistory() async {
  final file = File(_historyPath);
  if (!await file.exists()) return <Map<String, Object?>>[];
  try {
    final decoded = json.decode(await file.readAsString());
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((entry) => entry.cast<String, Object?>())
          .toList();
    }
  } catch (_) {
    // Ignore malformed history.
  }
  return <Map<String, Object?>>[];
}

List<String> _splitCommand(String command) {
  if (command.isEmpty) return const <String>[];
  final parts = <String>[];
  final buffer = StringBuffer();
  bool inQuote = false;
  for (final char in command.runes) {
    final value = String.fromCharCode(char);
    if (value == '"') {
      inQuote = !inQuote;
      continue;
    }
    if (value == ' ' && !inQuote) {
      if (buffer.isNotEmpty) {
        parts.add(buffer.toString());
        buffer.clear();
      }
    } else {
      buffer.write(value);
    }
  }
  if (buffer.isNotEmpty) {
    parts.add(buffer.toString());
  }
  return parts;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory('release/_reports');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore if chmod unavailable
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}

class _MaintenanceSnapshot {
  _MaintenanceSnapshot({
    required this.regressionStabilityIndex,
    required this.verdict,
    required this.stages,
  });

  final double regressionStabilityIndex;
  final String verdict;
  final List<_StageOutcome> stages;
}

class _StageOutcome {
  _StageOutcome({
    required this.name,
    required this.verdict,
    required this.command,
  });

  final String name;
  final String verdict;
  final String command;
}

class _HealAttempt {
  _HealAttempt({
    required this.stage,
    required this.command,
    required this.exitCode,
    required this.durationMs,
  });

  final String stage;
  final String command;
  final int exitCode;
  final int durationMs;
}

class _StageHealStatus {
  _StageHealStatus({
    required this.name,
    required this.before,
    required this.after,
    required this.healed,
  });

  final String name;
  final String before;
  final String after;
  final bool healed;
}

class _MaintenanceRerunResult {
  _MaintenanceRerunResult({required this.exitCode, required this.durationMs});

  final int exitCode;
  final int durationMs;
}
