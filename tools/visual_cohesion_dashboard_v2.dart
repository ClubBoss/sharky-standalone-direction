import 'dart:convert';
import 'dart:io';

const String _uiMicroSummaryPath =
    'release/_reports/ui_micro_animation_summary.txt';
const String _contrastSummaryPath =
    'release/_reports/contrast_accessibility_summary.txt';
const String _cohesionSummaryPath =
    'release/_reports/visual_cohesion_v2_summary.txt';
const String _summaryOutPath =
    'release/_reports/visual_cohesion_dashboard_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  await VisualCohesionDashboardV2().run();
}

class VisualCohesionDashboardV2 {
  Future<void> run() async {
    final animation = await _AnimationReport.load(_uiMicroSummaryPath);
    final contrast = await _ContrastReport.load(_contrastSummaryPath);
    final cohesion = await _CohesionReport.load(_cohesionSummaryPath);

    final passScores = <double>[contrast.passScore, cohesion.passScore];
    final avgPassScore = passScores.reduce((a, b) => a + b) / passScores.length;
    final visualHealthIndex =
        (avgPassScore * animation.smoothnessModifier * 100).clamp(0.0, 100.0);
    final verdict = _verdictFor(visualHealthIndex);

    await _withReportsWritable(() async {
      await _writeSummary(
        animation: animation,
        contrast: contrast,
        cohesion: cohesion,
        avgPassScore: avgPassScore,
        visualHealthIndex: visualHealthIndex,
        verdict: verdict,
      );
      await _emitTelemetry(
        animation: animation,
        contrast: contrast,
        cohesion: cohesion,
        avgPassScore: avgPassScore,
        visualHealthIndex: visualHealthIndex,
        verdict: verdict,
      );
    });

    if (verdict == 'FAIL') {
      exitCode = 2;
    } else if (verdict == 'WARN') {
      exitCode = 1;
    }
  }
}

class _AnimationReport {
  _AnimationReport({required this.p95, required this.verdict});

  final double p95;
  final String verdict;

  double get smoothnessModifier {
    if (p95 <= 0) return 0;
    final modifier = (16 / p95).clamp(0.0, 1.2);
    return modifier.clamp(0.0, 1.0);
  }

  static Future<_AnimationReport> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing animation report at $path');
    }
    final lines = await file.readAsLines();
    double? p95;
    String verdict = 'UNKNOWN';
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Verdict:')) {
        verdict = _valueAfterColon(trimmed).toUpperCase();
      } else if (trimmed.startsWith('- P95')) {
        p95 = _extractNumber(trimmed);
      }
    }
    if (p95 == null) {
      throw StateError('Unable to parse P95 frame time from $path');
    }
    return _AnimationReport(p95: p95, verdict: verdict);
  }
}

class _ContrastReport {
  _ContrastReport({required this.minContrast, required this.threshold});

  final double minContrast;
  final double threshold;

  double get passScore {
    if (threshold <= 0) return 0;
    return (minContrast / threshold).clamp(0.0, 1.0);
  }

  static Future<_ContrastReport> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing contrast summary at $path');
    }
    final lines = await file.readAsLines();
    double? minContrast;
    double? threshold;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Average contrast:')) {
        final parts = trimmed.split('|');
        if (parts.length > 1) {
          final minPart = parts[1].trim().replaceFirst('Min:', '').trim();
          minContrast = double.tryParse(minPart);
        }
      } else if (trimmed.startsWith('WCAG AA threshold:')) {
        threshold = double.tryParse(_valueAfterColon(trimmed));
      }
    }
    if (minContrast == null || threshold == null) {
      throw StateError('Contrast summary missing metrics.');
    }
    return _ContrastReport(minContrast: minContrast, threshold: threshold);
  }
}

class _CohesionReport {
  _CohesionReport({
    required this.cohesionIndex,
    required this.violations,
    required this.references,
  });

  final double cohesionIndex;
  final int violations;
  final int references;

  double get passScore => (cohesionIndex / 100).clamp(0.0, 1.0);

  static Future<_CohesionReport> load(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing cohesion summary at $path');
    }
    final lines = await file.readAsLines();
    double? index;
    int? references;
    int? violations;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Theme references')) {
        references = int.tryParse(trimmed.split(':').last.trim());
      } else if (trimmed.startsWith('- Violations')) {
        violations = int.tryParse(trimmed.split(':').last.trim());
      } else if (trimmed.startsWith('- Visual Cohesion Index')) {
        final value = trimmed.split(':').last.trim().replaceAll('%', '');
        index = double.tryParse(value);
      }
    }
    if (index == null || references == null || violations == null) {
      throw StateError('Cohesion summary missing metrics.');
    }
    return _CohesionReport(
      cohesionIndex: index,
      violations: violations,
      references: references,
    );
  }
}

double? _extractNumber(String line) {
  final matches = RegExp(r'([-+]?\d+(?:\.\d+)?)').allMatches(line).toList();
  if (matches.isEmpty) return null;
  return double.tryParse(matches.last.group(1)!);
}

String _verdictFor(double healthIndex) {
  if (healthIndex >= 90) return 'PASS';
  if (healthIndex >= 70) return 'WARN';
  return 'FAIL';
}

String _valueAfterColon(String line) {
  final index = line.indexOf(':');
  if (index == -1) {
    return '';
  }
  return line.substring(index + 1).trim();
}

Future<void> _writeSummary({
  required _AnimationReport animation,
  required _ContrastReport contrast,
  required _CohesionReport cohesion,
  required double avgPassScore,
  required double visualHealthIndex,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION DASHBOARD v2 SUMMARY')
    ..writeln('===================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Verdict: $verdict')
    ..writeln(
      'Overall Visual Health Index: ${visualHealthIndex.toStringAsFixed(2)}%',
    )
    ..writeln('Average PASS score: ${(avgPassScore * 100).toStringAsFixed(2)}%')
    ..writeln(
      'Animation smoothness modifier: '
      '${(animation.smoothnessModifier * 100).toStringAsFixed(2)}%',
    )
    ..writeln()
    ..writeln('Sources:')
    ..writeln(
      '- ui_micro_animation_summary.txt: P95=${animation.p95.toStringAsFixed(2)}ms '
      'verdict=${animation.verdict}',
    )
    ..writeln(
      '- contrast_accessibility_summary.txt: '
      'minContrast=${contrast.minContrast.toStringAsFixed(2)} '
      'threshold=${contrast.threshold}',
    )
    ..writeln(
      '- visual_cohesion_v2_summary.txt: '
      'index=${cohesion.cohesionIndex.toStringAsFixed(2)}% '
      'references=${cohesion.references} '
      'violations=${cohesion.violations}',
    )
    ..writeln();

  await File(_summaryOutPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry({
  required _AnimationReport animation,
  required _ContrastReport contrast,
  required _CohesionReport cohesion,
  required double avgPassScore,
  required double visualHealthIndex,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'visual_cohesion_dashboard_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'visual_health_index': visualHealthIndex,
    'avg_pass_score': avgPassScore,
    'animation_p95_ms': animation.p95,
    'animation_modifier': animation.smoothnessModifier,
    'contrast_min': contrast.minContrast,
    'contrast_threshold': contrast.threshold,
    'cohesion_index': cohesion.cohesionIndex,
    'cohesion_references': cohesion.references,
    'cohesion_violations': cohesion.violations,
    'verdict': verdict,
  };

  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
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
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
