import 'dart:convert';
import 'dart:io';

const String _regressionSummaryPath =
    'release/_reports/regression_autofix_summary.txt';
const String _gapRepairSummaryPath =
    'release/_reports/telemetry_gap_repair_summary.txt';
const String _stabilitySummaryPath =
    'release/_reports/stability_regression_summary.txt';
const String _outputPath =
    'release/_reports/resilience_verification_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final stabilityCounts = await _parseStabilityCounts();
  final postPass = await _parsePostAutofixPass();
  final gapRepair = await _parseGapRepairSummary();

  final denominator = (stabilityCounts.warn + stabilityCounts.fail).toDouble();
  final safeDenominator = denominator == 0 ? 1 : denominator;
  final score = (postPass / safeDenominator).clamp(0.0, 1.0).toDouble();
  final outcome = _classify(score, gapRepair.remaining == 0);

  await _withReportsWritable(() async {
    await _writeSummary(
      score: score,
      outcome: outcome,
      stabilityCounts: stabilityCounts,
      postPass: postPass,
      gapRepair: gapRepair,
    );
    await _appendTelemetry(
      score: score,
      outcome: outcome,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'resilience_verifier: score=${score.toStringAsFixed(2)} outcome=$outcome',
  );
}

Future<_StabilityCounts> _parseStabilityCounts() async {
  final file = File(_stabilitySummaryPath);
  if (!await file.exists()) return const _StabilityCounts();
  final lines = await file.readAsLines();
  final line = lines.firstWhere((l) => l.contains('PASS='), orElse: () => '');
  if (line.isEmpty) return const _StabilityCounts();
  final pass = _matchInt(line, r'PASS=(\d+)');
  final warn = _matchInt(line, r'WARN=(\d+)');
  final fail = _matchInt(line, r'FAIL=(\d+)');
  return _StabilityCounts(pass: pass, warn: warn, fail: fail);
}

Future<int> _parsePostAutofixPass() async {
  final file = File(_regressionSummaryPath);
  if (!await file.exists()) return 0;
  final lines = await file.readAsLines();
  final statusLines = lines.where((line) => line.trim().startsWith('Status:'));
  int passCount = 0;
  for (final raw in statusLines) {
    final match = RegExp(r'Status:\s+\w+\s+→\s+(\w+)').firstMatch(raw);
    if (match != null && match.group(1) == 'PASS') passCount++;
  }
  return passCount;
}

Future<_GapRepairInfo> _parseGapRepairSummary() async {
  final file = File(_gapRepairSummaryPath);
  if (!await file.exists()) return const _GapRepairInfo();
  final lines = await file.readAsLines();
  final addedLine = lines.firstWhere(
    (line) => line.contains('Synthetic telemetry added'),
    orElse: () => '',
  );
  final remainingLine = lines.firstWhere(
    (line) => line.contains('Remaining unresolved gaps'),
    orElse: () => '',
  );
  final added = _matchInt(addedLine, r'added:\s*(\d+)');
  final remaining = _matchInt(remainingLine, r'gaps:\s*(\d+)');
  return _GapRepairInfo(added: added, remaining: remaining);
}

int _matchInt(String source, String pattern) {
  final match = RegExp(pattern).firstMatch(source);
  if (match == null) return 0;
  return int.tryParse(match.group(1) ?? '') ?? 0;
}

String _classify(double score, bool gapsClosed) {
  if (score >= 0.75 && gapsClosed) return 'Improved';
  if (score >= 0.4) return 'Stable';
  return 'Regressed';
}

Future<void> _writeSummary({
  required double score,
  required String outcome,
  required _StabilityCounts stabilityCounts,
  required int postPass,
  required _GapRepairInfo gapRepair,
}) async {
  final buffer = StringBuffer()
    ..writeln('RESILIENCE VERIFICATION SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Resilience score: ${score.toStringAsFixed(2)}   Outcome: $outcome',
    )
    ..writeln(
      'Stability regression (pre-fix) WARN+FAIL: '
      '${(stabilityCounts.warn + stabilityCounts.fail).toStringAsFixed(0)}',
    )
    ..writeln('Post-autofix PASS count: $postPass')
    ..writeln(
      'Telemetry repairs: ${gapRepair.added} added, '
      '${gapRepair.remaining} remaining gaps',
    )
    ..writeln()
    ..writeln(_recommendation(outcome, gapRepair.remaining));

  await File(_outputPath).writeAsString(buffer.toString());
}

String _recommendation(String outcome, int remainingGaps) {
  if (outcome == 'Improved' && remainingGaps == 0) {
    return 'All systems resilient; proceed to QA sign-off.';
  }
  if (outcome == 'Stable') {
    return 'Resilience stable. Address remaining WARN segments before GA.';
  }
  return 'Regression detected. Investigate failing subsystems and rerun Ω-4/Ω-5 tooling.';
}

Future<void> _appendTelemetry({
  required double score,
  required String outcome,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'resilience_verified',
    'timestamp': DateTime.now().toIso8601String(),
    'score': double.parse(score.toStringAsFixed(2)),
    'outcome': outcome,
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
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'resilience_verifier: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _StabilityCounts {
  const _StabilityCounts({this.pass = 0, this.warn = 0, this.fail = 0});

  final int pass;
  final int warn;
  final int fail;
}

class _GapRepairInfo {
  const _GapRepairInfo({this.added = 0, this.remaining = 0});

  final int added;
  final int remaining;
}
