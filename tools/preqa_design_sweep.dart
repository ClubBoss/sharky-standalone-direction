import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _designSummaryPath = 'release/_reports/design_ai_sync_summary.txt';
const String _calibrationSummaryPath =
    'release/_reports/user_palette_calibration_summary.txt';
const String _visualizationPath =
    'release/_reports/adaptive_feedback_visualization.txt';
const String _outputPath = 'release/_reports/preqa_design_sweep_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final designScore = _scoreDesignAlignment(
    await _readFile(_designSummaryPath),
  );
  final paletteScore = _scorePaletteCalibration(
    await _readFile(_calibrationSummaryPath),
  );
  final feedbackScore = _scoreFeedbackVisualization(
    await _readFile(_visualizationPath),
  );

  final overallIndex = double.parse(
    (0.4 * designScore + 0.35 * paletteScore + 0.25 * feedbackScore)
        .toStringAsFixed(2),
  );
  final status = _statusFor(overallIndex);

  await _withReportsWritable(() async {
    await _writeSummary(
      designScore: designScore,
      paletteScore: paletteScore,
      feedbackScore: feedbackScore,
      overallIndex: overallIndex,
      status: status,
    );
    await _appendTelemetry(
      index: overallIndex,
      status: status,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'preqa_design_sweep: index=${overallIndex.toStringAsFixed(2)} status=$status',
  );
}

Future<String> _readFile(String path) async {
  final file = File(path);
  if (!await file.exists()) return '';
  return file.readAsString();
}

double _scoreDesignAlignment(String content) {
  if (content.isEmpty) return 0;
  final gaps = RegExp(
    r'Gaps:\s*(.*)',
  ).allMatches(content).map((match) => match.group(1)?.trim() ?? '').toList();
  if (gaps.isEmpty) return 1;
  final penalty = gaps.where((gap) => gap != 'none').fold<double>(0, (
    sum,
    gap,
  ) {
    final tokens = gap.split(',').length;
    return sum + min(tokens * 0.1, 0.3);
  });
  return (1 - penalty).clamp(0, 1);
}

double _scorePaletteCalibration(String content) {
  if (content.isEmpty) return 0;
  final avgMatch = RegExp(r'Average delta:\s*([0-9.]+)').firstMatch(content);
  final avgDelta = double.tryParse(avgMatch?.group(1) ?? '') ?? 0;
  return (1 - min(avgDelta / 10, 1)).clamp(0, 1).toDouble();
}

double _scoreFeedbackVisualization(String content) {
  if (content.isEmpty) return 0;
  final strengthMatch = RegExp(
    r'Trend strength:\s*([0-9.]+)',
  ).firstMatch(content);
  final strength = double.tryParse(strengthMatch?.group(1) ?? '') ?? 0;
  final notes = RegExp(
    r'Note:\s*(.*)',
  ).allMatches(content).map((match) => match.group(1)?.trim() ?? '').toList();
  final negativeNotes = notes
      .where(
        (note) => note.contains('Needs data') || note.contains('Declining'),
      )
      .length;
  final penalty = min(negativeNotes * 0.1, 0.4);
  return (min(strength / 2, 1) - penalty).clamp(0, 1).toDouble();
}

String _statusFor(double index) {
  if (index >= 0.8) return 'PASS';
  if (index >= 0.6) return 'WARN';
  return 'FAIL';
}

Future<void> _writeSummary({
  required double designScore,
  required double paletteScore,
  required double feedbackScore,
  required double overallIndex,
  required String status,
}) async {
  final buffer = StringBuffer()
    ..writeln('PRE-QA DESIGN SWEEP SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Design cohesion index: ${overallIndex.toStringAsFixed(2)} ($status)',
    )
    ..writeln()
    ..writeln('Category scores')
    ..writeln('- AI design alignment: ${designScore.toStringAsFixed(2)}')
    ..writeln('- Palette calibration: ${paletteScore.toStringAsFixed(2)}')
    ..writeln('- Feedback visualization: ${feedbackScore.toStringAsFixed(2)}')
    ..writeln()
    ..writeln(
      status == 'PASS'
          ? 'Ready for QA visual verification.'
          : status == 'WARN'
          ? 'Visual polish recommended before QA.'
          : 'BLOCKER: address gaps before QA entry.',
    );

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double index,
  required String status,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'preqa_design_sweep_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'index': double.parse(index.toStringAsFixed(2)),
    'status': status,
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
      'preqa_design_sweep: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
