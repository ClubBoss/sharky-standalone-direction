import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final sweep = _StakeholderSweep();
  final result = await sweep.run();
  result.printTable();
  await result.writeSummary();
  await result.emitTelemetry();
  if (result.failureCount > 0) {
    exit(1);
  }
}

class _StakeholderSweep {
  static const String _summaryPath =
      'release/_reports/final_stakeholder_summary.txt';
  static const List<_SweepStep> _steps = <_SweepStep>[
    _SweepStep(
      label: 'Telemetry drift cleanup',
      command: ['dart', 'run', 'tools/telemetry_drift_cleanup.dart'],
      toolPath: 'tools/telemetry_drift_cleanup.dart',
    ),
    _SweepStep(
      label: 'Dedup pass 2',
      command: ['dart', 'run', 'tools/dedup_pass2_cli.dart'],
      toolPath: 'tools/dedup_pass2_cli.dart',
    ),
    _SweepStep(
      label: 'Launch readiness audit',
      command: ['dart', 'run', 'tools/launch_readiness_audit.dart'],
      toolPath: 'tools/launch_readiness_audit.dart',
    ),
    _SweepStep(
      label: 'Governance audit',
      command: ['dart', 'run', 'tools/governance_integrity_audit.dart'],
      toolPath: 'tools/governance_integrity_audit.dart',
    ),
    _SweepStep(
      label: 'Stakeholder report',
      command: ['dart', 'run', 'tools/release_stakeholder_report.dart'],
      toolPath: 'tools/release_stakeholder_report.dart',
    ),
  ];

  Future<_SweepResult> run() async {
    final entries = <_StepResult>[];
    for (final step in _steps) {
      if (!File(step.toolPath).existsSync()) {
        entries.add(
          _StepResult(
            label: step.label,
            status: _StepStatus.skipped,
            duration: Duration.zero,
            note: 'tool missing',
          ),
        );
        continue;
      }
      final stopwatch = Stopwatch()..start();
      final process = await Process.run(
        step.command.first,
        step.command.skip(1).toList(),
      );
      stopwatch.stop();
      final exitCode = process.exitCode;
      final status = exitCode == 0 ? _StepStatus.pass : _StepStatus.fail;
      entries.add(
        _StepResult(
          label: step.label,
          status: status,
          duration: stopwatch.elapsed,
          note: process.stderr.toString().trim().isEmpty
              ? null
              : 'stderr: ${process.stderr}',
        ),
      );
      if (exitCode != 0) {
        break;
      }
    }
    return _SweepResult(entries);
  }
}

class _SweepStep {
  const _SweepStep({
    required this.label,
    required this.command,
    required this.toolPath,
  });

  final String label;
  final List<String> command;
  final String toolPath;
}

class _StepResult {
  _StepResult({
    required this.label,
    required this.status,
    required this.duration,
    this.note,
  });

  final String label;
  final _StepStatus status;
  final Duration duration;
  final String? note;

  String get statusLabel => switch (status) {
    _StepStatus.pass => 'PASS',
    _StepStatus.fail => 'FAIL',
    _StepStatus.skipped => 'SKIP',
  };
}

enum _StepStatus { pass, fail, skipped }

class _SweepResult {
  _SweepResult(this.steps);

  final List<_StepResult> steps;

  int get failureCount =>
      steps.where((step) => step.status == _StepStatus.fail).length;

  void printTable() {
    final headers = ['Step', 'Status', 'Duration (ms)'];
    final rows = steps
        .map(
          (step) => [
            step.label,
            step.statusLabel,
            step.duration.inMilliseconds.toString(),
          ],
        )
        .toList();
    final widths = List<int>.filled(headers.length, 0);
    void updateWidths(List<String> row) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }

    updateWidths(headers);
    for (final row in rows) {
      updateWidths(row);
    }

    String border() => '+${widths.map((w) => '-' * (w + 2)).join('+')}+';
    String formatRow(List<String> row) =>
        '|${[for (var i = 0; i < row.length; i++) ' ${row[i].padRight(widths[i])} '].join('|')}|';

    stdout.writeln(border());
    stdout.writeln(formatRow(headers));
    stdout.writeln(border());
    for (final row in rows) {
      stdout.writeln(formatRow(row));
    }
    stdout.writeln(border());
  }

  Future<void> writeSummary() async {
    final file = File(_StakeholderSweep._summaryPath);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Final Stakeholder Sweep')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('');
    for (final step in steps) {
      buffer..writeln(
        '- ${step.label}: ${step.statusLabel} '
        '(${step.duration.inMilliseconds} ms)',
      );
      if (step.note != null) {
        buffer.writeln('  note: ${step.note}');
      }
    }
    buffer
      ..writeln('')
      ..writeln('Failures: $failureCount');
    await file.writeAsString(buffer.toString());
  }

  Future<void> emitTelemetry() async {
    final payload = <String, Object>{
      'event': TelemetryEvents.finalStakeholderSweepCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'failureCount': failureCount,
      'steps': [
        for (final step in steps)
          {
            'label': step.label,
            'status': step.statusLabel,
            'duration_ms': step.duration.inMilliseconds,
          },
      ],
    };
    stdout.writeln(jsonEncode(payload));
  }
}
