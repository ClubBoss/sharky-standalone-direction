import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _maintenanceLogPath = '$_reportsDir/maintenance_log.jsonl';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/automated_recovery_summary.txt';
const String _summaryJsonPath = '$_reportsDir/automated_recovery_summary.json';

const double _coverageThreshold = 90.0;
const int _maxPasses = 2;

Future<void> main(List<String> args) async {
  final agent = AutomatedRecoveryAgent();
  final ok = await agent.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AutomatedRecoveryAgent {
  Future<bool> run() async {
    final failingModules = await _detectFailingModules();
    if (failingModules.isEmpty) {
      await _writeNoopSummary();
      return true;
    }

    final moduleResults = <_ModuleResult>[];
    bool hasFailures = false;

    for (final module in failingModules) {
      final pipeline = await _buildPipeline(module);
      if (pipeline.isEmpty) {
        moduleResults.add(
          _ModuleResult(
            module: module,
            attempts: const [],
            resolved: false,
            note: 'No recovery commands available',
          ),
        );
        hasFailures = true;
        continue;
      }
      final result = await _recoverModule(module, pipeline);
      moduleResults.add(result);
      if (!result.resolved) {
        hasFailures = true;
      }
    }

    final coverage = await _readCoverage();
    final coverageOk = coverage != null && coverage >= _coverageThreshold;
    final success = !hasFailures && coverageOk;

    final summaryText = _buildTextSummary(
      moduleResults: moduleResults,
      coverage: coverage,
      success: success,
    );
    final summaryJson = _buildJsonSummary(
      moduleResults: moduleResults,
      coverage: coverage,
      success: success,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(success, coverage, moduleResults);
    });

    if (!success) {
      stderr.writeln('Automated recovery agent could not resolve all modules.');
    }

    return success;
  }

  Future<Set<String>> _detectFailingModules() async {
    final modules = <String>{};

    final maintenanceFile = File(_maintenanceLogPath);
    if (await maintenanceFile.exists()) {
      final lines = await maintenanceFile.readAsLines();
      for (final line in lines.reversed) {
        if (line.trim().isEmpty) continue;
        try {
          final payload = json.decode(line) as Map<String, Object?>;
          if (payload['verdict'] == 'FAIL') {
            final tools = payload['tools'];
            if (tools is List) {
              for (final toolEntry in tools) {
                if (toolEntry is Map &&
                    toolEntry['success'] == false &&
                    toolEntry['tool'] is String) {
                  modules.add(toolEntry['tool'] as String);
                }
              }
            }
          }
        } catch (_) {
          // ignore malformed entries
        }
        if (modules.isNotEmpty) {
          // only consider most recent failure block
          break;
        }
      }
    }

    return modules;
  }

  Future<List<String>> _buildPipeline(String module) async {
    final candidates = <String>{
      module,
      '${module}_monitor',
      '${module}_repair',
      '${module}_rebuild',
      '${module}_guardian',
      '${module}_agent',
      '${module}_scheduler',
    };
    if (module.endsWith('_telemetry')) {
      candidates.add('${module}_monitor');
    }
    final pipeline = <String>[];
    for (final candidate in candidates) {
      final file = File('tools/$candidate.dart');
      if (await file.exists()) {
        pipeline.add(candidate);
      }
    }
    return pipeline;
  }

  Future<_ModuleResult> _recoverModule(
    String module,
    List<String> pipeline,
  ) async {
    final attempts = <_CommandAttempt>[];
    bool resolved = false;

    for (var pass = 1; pass <= _maxPasses && !resolved; pass++) {
      bool passSuccess = true;
      for (final commandName in pipeline) {
        final command = ['dart', 'run', 'tools/$commandName.dart'];
        final attempt = await _runCommand(module, pass, command);
        attempts.add(attempt);
        if (attempt.exitCode != 0) {
          passSuccess = false;
          break;
        }
      }
      if (passSuccess) {
        resolved = true;
      }
    }

    return _ModuleResult(
      module: module,
      attempts: attempts,
      resolved: resolved,
      note: resolved ? '' : 'Recovery commands exhausted',
    );
  }

  Future<_CommandAttempt> _runCommand(
    String module,
    int pass,
    List<String> command,
  ) async {
    final start = DateTime.now();
    int exitCode;
    try {
      final process = await Process.start(
        command.first,
        command.skip(1).toList(),
      );
      await stdout.addStream(process.stdout);
      await stderr.addStream(process.stderr);
      exitCode = await process.exitCode;
    } catch (error) {
      stderr.writeln('Failed to run ${command.join(' ')}: $error');
      exitCode = 99;
    }
    final end = DateTime.now();
    return _CommandAttempt(
      module: module,
      pass: pass,
      command: command.join(' '),
      exitCode: exitCode,
      durationMs: end.difference(start).inMilliseconds,
    );
  }

  Future<double?> _readCoverage() async {
    final file = File('$_reportsDir/post_release_telemetry_summary.json');
    if (!await file.exists()) {
      return null;
    }
    try {
      final jsonMap =
          json.decode(await file.readAsString()) as Map<String, Object?>;
      final value = jsonMap['coverage_percent'];
      if (value is num) {
        return value.toDouble();
      }
    } catch (_) {
      // ignore parse errors
    }
    return null;
  }

  Future<void> _writeNoopSummary() async {
    final summaryText = StringBuffer()
      ..writeln('AUTOMATED RECOVERY SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('No failing modules detected.')
      ..writeln('Verdict: PASS');

    final summaryJson = {
      'generated_at': DateTime.now().toIso8601String(),
      'verdict': 'PASS',
      'modules': <Object>[],
    };

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText.toString());
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(true, null, const <_ModuleResult>[]);
    });
  }

  String _buildTextSummary({
    required List<_ModuleResult> moduleResults,
    required double? coverage,
    required bool success,
  }) {
    final buffer = StringBuffer()
      ..writeln('AUTOMATED RECOVERY SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln(
        'Coverage: ${coverage == null ? 'n/a' : coverage.toStringAsFixed(2)} '
        '(threshold ${_coverageThreshold.toStringAsFixed(0)}%)',
      )
      ..writeln('Verdict: ${success ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Module results:');
    for (final result in moduleResults) {
      buffer.writeln(
        '- ${result.module}: ${result.resolved ? 'PASS' : 'FAIL'}'
        '${result.note.isEmpty ? '' : ' (${result.note})'}',
      );
      for (final attempt in result.attempts) {
        buffer.writeln(
          '  • pass ${attempt.pass} cmd "${attempt.command}" => '
          'exit ${attempt.exitCode} (${attempt.durationMs} ms)',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required List<_ModuleResult> moduleResults,
    required double? coverage,
    required bool success,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'coverage_percent': coverage,
      'coverage_threshold': _coverageThreshold,
      'verdict': success ? 'PASS' : 'FAIL',
      'modules': moduleResults.map((result) => result.toJson()).toList(),
    };
  }

  Future<void> _appendTelemetry(
    bool success,
    double? coverage,
    List<_ModuleResult> results,
  ) async {
    final payload = <String, Object?>{
      'event': 'automated_recovery_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'coverage_percent': coverage,
      'verdict': success ? 'PASS' : 'FAIL',
      'modules': results
          .map(
            (result) => {
              'name': result.module,
              'resolved': result.resolved,
              'note': result.note,
            },
          )
          .toList(),
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _ModuleResult {
  _ModuleResult({
    required this.module,
    required this.attempts,
    required this.resolved,
    required this.note,
  });

  final String module;
  final List<_CommandAttempt> attempts;
  final bool resolved;
  final String note;

  Map<String, Object?> toJson() {
    return {
      'module': module,
      'resolved': resolved,
      'note': note,
      'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
    };
  }
}

class _CommandAttempt {
  _CommandAttempt({
    required this.module,
    required this.pass,
    required this.command,
    required this.exitCode,
    required this.durationMs,
  });

  final String module;
  final int pass;
  final String command;
  final int exitCode;
  final int durationMs;

  Map<String, Object?> toJson() {
    return {
      'module': module,
      'pass': pass,
      'command': command,
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
      // ignore cleanup failures
    }
  }
}
