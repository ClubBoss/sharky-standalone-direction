import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath =
    '$_reportsDir/automation_maintenance_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/automation_maintenance_summary.json';

const double _minCompleteness = 95.0;

const Map<String, List<String>> _eventToolMap = {
  'rsi_auto_recovery_completed': [
    'dart',
    'run',
    'tools/rsi_auto_recovery_booster.dart',
  ],
  'regression_health_forecast_completed': [
    'dart',
    'run',
    'tools/regression_health_forecaster.dart',
  ],
  'stability_qa_bridge_completed': [
    'dart',
    'run',
    'tools/stability_qa_bridge.dart',
  ],
  'visual_qa_final_completed': [
    'dart',
    'run',
    'tools/visual_qa_final_pass.dart',
  ],
  'visual_cohesion_final_completed': [
    'dart',
    'run',
    'tools/visual_cohesion_final_qa.dart',
  ],
  'content_evolution_qa_completed': [
    'dart',
    'run',
    'tools/content_evolution_qa_pass.dart',
  ],
  'marketing_onboarding_completed': [
    'dart',
    'run',
    'tools/marketing_onboarding_loop.dart',
  ],
  'release_inventory_cleaner_completed': [
    'dart',
    'run',
    'tools/release_inventory_cleaner.dart',
  ],
  'automation_maintenance_completed': [
    'dart',
    'run',
    'tools/automation_maintenance_loop.dart',
  ],
};

Future<void> main(List<String> args) async {
  final loop = AutomationMaintenanceLoop();
  final ok = await loop.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AutomationMaintenanceLoop {
  Future<bool> run() async {
    final telemetry = await _loadTelemetry();
    final initialLogged = _eventsObserved(telemetry);
    final missing = _missingEvents(initialLogged);

    final rerunResults = <_RerunResult>[];
    for (final event in missing) {
      final command = _eventToolMap[event];
      if (command == null) {
        rerunResults.add(
          _RerunResult(
            event: event,
            success: false,
            message: 'No tool mapping for event.',
          ),
        );
        continue;
      }
      final result = await _runTool(event, command);
      rerunResults.add(result);
    }

    final refreshedTelemetry = await _loadTelemetry();
    final finalLogged = _eventsObserved(refreshedTelemetry);
    final completeness = _completeness(finalLogged.length);
    final finalMissing = _missingEvents(finalLogged);
    final rerunFailures = rerunResults
        .where((result) => result.success == false)
        .toList();

    final summaryText = _buildTextSummary(
      completeness: completeness,
      missing: finalMissing,
      reruns: rerunResults,
    );
    final summaryJson = _buildJsonSummary(
      completeness: completeness,
      missing: finalMissing,
      reruns: rerunResults,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        completeness: completeness,
        missing: finalMissing,
        rerunFailures: rerunFailures,
      );
    });

    final success =
        completeness >= _minCompleteness &&
        rerunFailures.isEmpty &&
        finalMissing.isEmpty;
    if (!success) {
      stderr.writeln(
        'Automation Maintenance Loop incomplete: index=${completeness.toStringAsFixed(2)}%',
      );
      if (finalMissing.isNotEmpty) {
        stderr.writeln('Still missing events: ${finalMissing.join(', ')}');
      }
      if (rerunFailures.isNotEmpty) {
        stderr.writeln(
          'Failed reruns: ${rerunFailures.map((e) => e.event).join(', ')}',
        );
      }
    }
    return success;
  }

  Future<List<Map<String, Object?>>> _loadTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      return const [];
    }
    final entries = <Map<String, Object?>>[];
    try {
      final lines = await file.readAsLines();
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final decoded = json.decode(line) as Map<String, Object?>;
          entries.add(decoded);
        } catch (_) {
          // ignore malformed lines
        }
      }
    } catch (_) {
      return entries;
    }
    return entries;
  }

  Set<String> _eventsObserved(List<Map<String, Object?>> telemetry) {
    final observed = <String>{};
    for (final entry in telemetry) {
      final event = entry['event']?.toString();
      if (event != null && _eventToolMap.containsKey(event)) {
        observed.add(event);
      }
    }
    return observed;
  }

  List<String> _missingEvents(Set<String> logged) {
    return _eventToolMap.keys
        .where((event) => event != 'automation_maintenance_completed')
        .where((event) => !logged.contains(event))
        .toList();
  }

  double _completeness(int loggedCount) {
    final expected = _eventToolMap.length - 1; // exclude self event
    if (expected <= 0) return 100;
    return (loggedCount / expected) * 100;
  }

  Future<_RerunResult> _runTool(String event, List<String> command) async {
    try {
      final process = await Process.run(
        command.first,
        command.sublist(1),
        runInShell: false,
      );
      if (process.exitCode != 0) {
        return _RerunResult(
          event: event,
          success: false,
          message: 'Exit ${process.exitCode}',
        );
      }
      return _RerunResult(event: event, success: true);
    } catch (error) {
      return _RerunResult(
        event: event,
        success: false,
        message: error.toString(),
      );
    }
  }

  String _buildTextSummary({
    required double completeness,
    required List<String> missing,
    required List<_RerunResult> reruns,
  }) {
    final buffer = StringBuffer()
      ..writeln('AUTOMATION MAINTENANCE SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Event completeness: ${completeness.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minCompleteness.toStringAsFixed(2)}%')
      ..writeln('Missing events after rerun: ${missing.length}')
      ..writeln();
    if (missing.isNotEmpty) {
      buffer.writeln('Remaining gaps:');
      for (final name in missing) {
        buffer.writeln('  - $name');
      }
      buffer.writeln();
    }
    if (reruns.isNotEmpty) {
      buffer.writeln('Rerun attempts:');
      for (final result in reruns) {
        buffer.writeln(
          '  - ${result.event}: ${result.success ? 'SUCCESS' : 'FAIL'}'
          '${result.message != null ? ' (${result.message})' : ''}',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double completeness,
    required List<String> missing,
    required List<_RerunResult> reruns,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'completeness': completeness,
      'threshold': _minCompleteness,
      'missing_events': missing,
      'reruns': reruns
          .map(
            (result) => {
              'event': result.event,
              'success': result.success,
              'message': result.message,
            },
          )
          .toList(),
    };
  }

  Future<void> _appendTelemetry({
    required double completeness,
    required List<String> missing,
    required List<_RerunResult> rerunFailures,
  }) async {
    final payload = <String, Object?>{
      'event': 'automation_maintenance_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'completeness': completeness,
      'threshold': _minCompleteness,
      'missing_events': missing,
      'rerun_failures': rerunFailures.map((result) => result.event).toList(),
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _RerunResult {
  const _RerunResult({
    required this.event,
    required this.success,
    this.message,
  });

  final String event;
  final bool success;
  final String? message;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore
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
