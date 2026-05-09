import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath =
    '$_reportsDir/post_release_maintenance_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/post_release_maintenance_summary.json';
const String _maintenanceLogPath = '$_reportsDir/maintenance_log.jsonl';

const double _coverageThreshold = 90.0;
const Duration _defaultInterval = Duration(hours: 24);
const int _maxAttempts = 3;

const List<_MaintenanceTool> _tools = <_MaintenanceTool>[
  _MaintenanceTool(
    name: 'post_release_telemetry_monitor',
    command: ['dart', 'run', 'tools/post_release_telemetry_monitor.dart'],
  ),
  _MaintenanceTool(
    name: 'baseline_diff_checker',
    command: ['dart', 'run', 'tools/baseline_diff_checker.dart'],
  ),
  _MaintenanceTool(
    name: 'release_qa_consolidation',
    command: ['dart', 'run', 'tools/release_qa_consolidation.dart'],
  ),
];

Future<void> main(List<String> args) async {
  final scheduler = PostReleaseMaintenanceScheduler();
  final ok = await scheduler.run(args);
  if (!ok) {
    exitCode = 2;
  }
}

class PostReleaseMaintenanceScheduler {
  Future<bool> run(List<String> args) async {
    final interval = _parseInterval(args);
    final executionResults = <_ToolResult>[];
    bool hasFailure = false;

    for (final tool in _tools) {
      final result = await _runTool(tool);
      executionResults.add(result);
      if (!result.success) {
        hasFailure = true;
      }
    }

    final coverage = await _readCoverage();
    final coverageOk = coverage != null && coverage >= _coverageThreshold;
    final success = !hasFailure && coverageOk;

    final summaryText = _buildTextSummary(
      executionResults: executionResults,
      interval: interval,
      coverage: coverage,
      success: success,
    );
    final summaryJson = _buildJsonSummary(
      executionResults: executionResults,
      interval: interval,
      coverage: coverage,
      success: success,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendMaintenanceLog(summaryJson);
      await _appendTelemetry(success, coverage);
    });

    if (!success) {
      stderr.writeln('Post-release maintenance scheduler detected failures.');
    }
    return success;
  }

  Duration _parseInterval(List<String> args) {
    if (args.isEmpty) return _defaultInterval;
    final hours = int.tryParse(args.first);
    if (hours == null || hours <= 0) {
      return _defaultInterval;
    }
    return Duration(hours: hours);
  }

  Future<_ToolResult> _runTool(_MaintenanceTool tool) async {
    final attempts = <_ToolAttempt>[];
    for (var i = 0; i < _maxAttempts; i++) {
      final start = DateTime.now();
      final exitCode = await _runCommand(tool.command);
      final end = DateTime.now();
      attempts.add(
        _ToolAttempt(
          attempt: i + 1,
          exitCode: exitCode,
          durationMs: end.difference(start).inMilliseconds,
        ),
      );
      if (exitCode == 0) {
        return _ToolResult(tool: tool, attempts: attempts, success: true);
      }
    }
    return _ToolResult(tool: tool, attempts: attempts, success: false);
  }

  Future<int> _runCommand(List<String> command) async {
    final process = await Process.start(
      command.first,
      command.skip(1).toList(),
    );
    await stdout.addStream(process.stdout);
    await stderr.addStream(process.stderr);
    return await process.exitCode;
  }

  Future<double?> _readCoverage() async {
    final file = File('$_reportsDir/post_release_telemetry_summary.json');
    if (!await file.exists()) {
      return null;
    }
    try {
      final jsonMap =
          json.decode(await file.readAsString()) as Map<String, Object?>;
      final coverage = jsonMap['coverage_percent'];
      if (coverage is num) {
        return coverage.toDouble();
      }
    } catch (_) {
      // ignore parse failures and treat as unknown
    }
    return null;
  }

  String _buildTextSummary({
    required List<_ToolResult> executionResults,
    required Duration interval,
    required double? coverage,
    required bool success,
  }) {
    final buffer = StringBuffer()
      ..writeln('POST-RELEASE MAINTENANCE SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Interval hours: ${interval.inHours}')
      ..writeln(
        'Coverage: ${coverage == null ? 'n/a' : coverage.toStringAsFixed(2)} '
        '(threshold ${_coverageThreshold.toStringAsFixed(0)}%)',
      )
      ..writeln('Verdict: ${success ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Tool results:');
    for (final result in executionResults) {
      buffer.writeln(
        '- ${result.tool.name}: ${result.success ? 'PASS' : 'FAIL'} '
        '(attempts=${result.attempts.length})',
      );
      for (final attempt in result.attempts) {
        buffer.writeln(
          '  • attempt ${attempt.attempt} => exit ${attempt.exitCode} '
          '(${attempt.durationMs} ms)',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required List<_ToolResult> executionResults,
    required Duration interval,
    required double? coverage,
    required bool success,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'interval_hours': interval.inHours,
      'coverage_percent': coverage,
      'coverage_threshold': _coverageThreshold,
      'verdict': success ? 'PASS' : 'FAIL',
      'tools': executionResults.map((result) => result.toJson()).toList(),
    };
  }

  Future<void> _appendMaintenanceLog(Map<String, Object?> summaryJson) async {
    final file = File(_maintenanceLogPath);
    final sink = file.openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(summaryJson));
    await sink.close();
  }

  Future<void> _appendTelemetry(bool success, double? coverage) async {
    final payload = <String, Object?>{
      'event': 'post_release_maintenance_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'coverage_percent': coverage,
      'verdict': success ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _MaintenanceTool {
  const _MaintenanceTool({required this.name, required this.command});

  final String name;
  final List<String> command;
}

class _ToolResult {
  _ToolResult({
    required this.tool,
    required this.attempts,
    required this.success,
  });

  final _MaintenanceTool tool;
  final List<_ToolAttempt> attempts;
  final bool success;

  Map<String, Object?> toJson() {
    return {
      'tool': tool.name,
      'success': success,
      'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
    };
  }
}

class _ToolAttempt {
  _ToolAttempt({
    required this.attempt,
    required this.exitCode,
    required this.durationMs,
  });

  final int attempt;
  final int exitCode;
  final int durationMs;

  Map<String, Object?> toJson() {
    return {
      'attempt': attempt,
      'exit_code': exitCode,
      'duration_ms': durationMs,
    };
  }
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore permission issues
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
