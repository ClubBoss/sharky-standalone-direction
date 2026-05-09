import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final verifier = _FinalReleaseVerifier();
  final report = await verifier.run();
  await verifier.writeReport(report);
  await verifier.emitTelemetry(report);
  if (report.failCount > 0) {
    exitCode = 1;
  }
}

class _FinalReleaseVerifier {
  _FinalReleaseVerifier() {
    _gates = <_Gate>[
      _Gate(name: 'dart analyze', command: const ['dart', 'analyze']),
      _Gate(
        name: 'telemetry guard',
        command: const ['dart', 'run', 'tools/telemetry_events_guard.dart'],
      ),
      _Gate(
        name: 'visual audit',
        command: const ['dart', 'run', 'tools/visual_integrity_audit.dart'],
      ),
      _Gate(
        name: 'full QA (fast)',
        command: const ['dart', 'run', 'tools/full_qa_sweep.dart', '--fast'],
      ),
      _Gate(
        name: 'stability scaling',
        command: const ['dart', 'run', 'tools/stability_scaling_audit.dart'],
      ),
      _Gate(
        name: 'stakeholder sweep',
        command: const ['dart', 'run', 'tools/final_stakeholder_sweep.dart'],
      ),
      _Gate(
        name: 'release packaging',
        command: const ['dart', 'run', 'tools/release_packaging_audit.dart'],
      ),
    ];
  }

  late final List<_Gate> _gates;
  final DateTime _timestamp = DateTime.now().toUtc();

  Future<_VerifierReport> run() async {
    final results = <_GateResult>[];
    for (final gate in _gates) {
      results.add(await _runGate(gate));
    }
    return _VerifierReport(results: results, timestamp: _timestamp);
  }

  Future<_GateResult> _runGate(_Gate gate) async {
    final timer = Stopwatch()..start();
    ProcessResult process;
    try {
      process = await Process.run(
        gate.command.first,
        gate.command.skip(1).toList(),
      );
    } catch (error) {
      process = ProcessResult(-1, 1, '', 'Command error: $error');
    }
    timer.stop();
    final combined = '${process.stdout}\n${process.stderr}'.trim();
    final warnings = _extractWarnings(combined);
    return _GateResult(
      gate: gate,
      success: process.exitCode == 0,
      durationMs: timer.elapsedMilliseconds,
      warnings: warnings,
      output: combined,
    );
  }

  int _extractWarnings(String output) {
    final match = RegExp(r'warnings?=?\s*(\d+)').firstMatch(output);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    return 0;
  }

  Future<void> writeReport(_VerifierReport report) async {
    final buffer = StringBuffer()
      ..writeln('Final Release Verification')
      ..writeln('Timestamp: ${report.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('| Gate | Status | Duration ms | Warnings |')
      ..writeln('| ---- | ------ | ----------- | -------- |');
    for (final result in report.results) {
      buffer.writeln(
        '| ${result.gate.name} | ${result.success ? 'PASS' : 'FAIL'} | '
        '${result.durationMs} | ${result.warnings} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('Pass: ${report.passCount}')
      ..writeln('Fail: ${report.failCount}')
      ..writeln('Total Duration: ${report.totalDurationMs} ms');

    final file = File('release/_reports/final_release_verification.txt');
    await file.parent.create(recursive: true);
    await file.writeAsString(buffer.toString());
  }

  Future<void> emitTelemetry(_VerifierReport report) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.finalReleaseVerified,
      'timestamp': report.timestamp.toIso8601String(),
      'pass': report.passCount,
      'fail': report.failCount,
      'duration_ms': report.totalDurationMs,
    };
    final file = File('release/_reports/telemetry.jsonl');
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

class _VerifierReport {
  _VerifierReport({required this.results, required this.timestamp});

  final List<_GateResult> results;
  final DateTime timestamp;

  int get passCount => results.where((r) => r.success).length;
  int get failCount => results.length - passCount;
  int get totalDurationMs => results.fold(0, (sum, r) => sum + r.durationMs);
}

class _Gate {
  const _Gate({required this.name, required this.command});

  final String name;
  final List<String> command;
}

class _GateResult {
  _GateResult({
    required this.gate,
    required this.success,
    required this.durationMs,
    required this.warnings,
    required this.output,
  });

  final _Gate gate;
  final bool success;
  final int durationMs;
  final int warnings;
  final String output;
}
