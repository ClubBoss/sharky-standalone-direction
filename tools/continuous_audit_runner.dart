import 'dart:convert';
import 'dart:io';

const String _summaryPath = 'release/_reports/continuous_audit_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

const List<_ToolSpec> _orderedTools = [
  _ToolSpec(
    'content_evolution_refactor',
    'tools/content_evolution_refactor.dart',
  ),
  _ToolSpec('adaptive_drill_balancer', 'tools/adaptive_drill_balancer.dart'),
  _ToolSpec('adaptive_quiz_composer', 'tools/adaptive_quiz_composer.dart'),
  _ToolSpec('adaptive_recap_generator', 'tools/adaptive_recap_generator.dart'),
  _ToolSpec(
    'regression_protection_prep',
    'tools/regression_protection_prep.dart',
  ),
  _ToolSpec(
    'regression_metrics_aggregator',
    'tools/regression_metrics_aggregator.dart',
  ),
];

Future<void> main(List<String> args) async {
  final overallTimer = Stopwatch()..start();
  final results = <_AuditResult>[];

  for (final tool in _orderedTools) {
    results.add(await _runTool(tool));
  }

  final passCount = results.where((r) => r.result == 'PASS').length;
  final score = (passCount / results.length) * 100;
  final verdict = score >= 90 ? 'PASS' : (score >= 75 ? 'WARN' : 'FAIL');

  await _withReportsWritable(() async {
    await _writeSummary(
      results: results,
      score: score,
      verdict: verdict,
      durationMs: overallTimer.elapsedMilliseconds,
    );
    await _emitTelemetry(
      score: score,
      verdict: verdict,
      durationMs: overallTimer.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'continuous_audit_runner: score=${score.toStringAsFixed(1)}% verdict=$verdict',
  );

  if (score < 90) {
    stderr.writeln(
      'continuous_audit_runner: Audit Stability Score below threshold.',
    );
    exitCode = 1;
  }
}

Future<_AuditResult> _runTool(_ToolSpec spec) async {
  final timer = Stopwatch()..start();
  final process = await Process.run('dart', ['run', spec.scriptPath]);
  final success = process.exitCode == 0;
  final stderrOutput = process.stderr.toString().trim();
  final stdoutOutput = process.stdout.toString().trim();
  final result = success ? 'PASS' : 'FAIL';
  final message = stderrOutput.isNotEmpty ? stderrOutput : stdoutOutput;

  return _AuditResult(
    name: spec.name,
    result: result,
    durationMs: timer.elapsedMilliseconds,
    message: message,
  );
}

Future<void> _writeSummary({
  required List<_AuditResult> results,
  required double score,
  required String verdict,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('CONTINUOUS AUDIT SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Audit Stability Score: ${score.toStringAsFixed(1)}%  Verdict: $verdict',
    )
    ..writeln('Total duration: ${durationMs}ms')
    ..writeln();

  for (final result in results) {
    buffer..writeln(
      'Tool: ${result.name} → ${result.result} (${result.durationMs}ms)',
    );
    if (result.message.isNotEmpty) {
      buffer.writeln('  ${result.message}');
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry({
  required double score,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'continuous_audit_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'score': double.parse(score.toStringAsFixed(1)),
    'verdict': verdict,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'continuous_audit_runner: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ToolSpec {
  const _ToolSpec(this.name, this.scriptPath);

  final String name;
  final String scriptPath;
}

class _AuditResult {
  const _AuditResult({
    required this.name,
    required this.result,
    required this.durationMs,
    required this.message,
  });

  final String name;
  final String result;
  final int durationMs;
  final String message;
}
