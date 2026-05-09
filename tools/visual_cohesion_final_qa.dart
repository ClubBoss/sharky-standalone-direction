import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _cohesionFinalPath = '$_reportsDir/visual_qa_final_summary.txt';
const String _animationPath = '$_reportsDir/ui_micro_animation_summary.txt';
const String _stressPath = '$_reportsDir/dynamic_visual_stress_summary.txt';
const String _summaryTextPath =
    '$_reportsDir/visual_cohesion_final_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_cohesion_final_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _animationTargetMs = 16.0;
const double _stressTargetMs = 16.0;
const double _threshold = 90.0;

Future<void> main(List<String> args) async {
  final qa = VisualCohesionFinalQa();
  final ok = await qa.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualCohesionFinalQa {
  Future<bool> run() async {
    final cohesion = await _readCohesionFinal();
    final animation = await _readAnimation();
    final stress = await _readStress();

    final index = _weightedIndex(
      cohesion: cohesion.score,
      animation: animation.score,
      stress: stress.score,
    );
    final pass = index >= _threshold;

    final summaryText = _buildTextSummary(
      cohesion: cohesion,
      animation: animation,
      stress: stress,
      index: index,
      pass: pass,
    );
    final summaryJson = _buildJsonSummary(
      cohesion: cohesion,
      animation: animation,
      stress: stress,
      index: index,
      pass: pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        cohesion: cohesion,
        animation: animation,
        stress: stress,
        index: index,
        pass: pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Visual Cohesion Index ${index.toStringAsFixed(2)}% below '
        '${_threshold.toStringAsFixed(0)}% threshold.',
      );
    }

    return pass;
  }

  Future<_MetricScore> _readCohesionFinal() async {
    final contents = await _readFile(_cohesionFinalPath);
    final match = RegExp(
      r'Final Visual Health:\s*([0-9.]+)%',
    ).firstMatch(contents);
    if (match == null) {
      throw StateError(
        'Unable to parse Final Visual Health in $_cohesionFinalPath',
      );
    }
    final value = double.tryParse(match.group(1) ?? '') ?? 0;
    return _MetricScore(
      name: 'cohesion',
      score: value,
      detail: 'Final Visual Health',
      source: _cohesionFinalPath,
    );
  }

  Future<_MetricScore> _readAnimation() async {
    final contents = await _readFile(_animationPath);
    final match = RegExp(
      r'Frame timing \(ms\):[\s\S]*?- P95\s*:\s*([0-9.]+)',
    ).firstMatch(contents);
    if (match == null) {
      throw StateError('Missing animation P95 in $_animationPath');
    }
    final p95 = double.tryParse(match.group(1) ?? '') ?? _animationTargetMs;
    final pct = _scoreFromP95(p95, _animationTargetMs);
    return _MetricScore(
      name: 'animation',
      score: pct,
      detail: 'P95 ${p95.toStringAsFixed(2)}ms',
      source: _animationPath,
    );
  }

  Future<_MetricScore> _readStress() async {
    final contents = await _readFile(_stressPath);
    final match = RegExp(
      r'Frame statistics \(ms\):[\s\S]*?- P95\s*:\s*([0-9.]+)',
    ).firstMatch(contents);
    if (match == null) {
      throw StateError('Missing stress P95 in $_stressPath');
    }
    final p95 = double.tryParse(match.group(1) ?? '') ?? _stressTargetMs;
    final pct = _scoreFromP95(p95, _stressTargetMs);
    return _MetricScore(
      name: 'stress',
      score: pct,
      detail: 'P95 ${p95.toStringAsFixed(2)}ms',
      source: _stressPath,
    );
  }

  double _scoreFromP95(double observed, double target) {
    if (observed <= 0) return 0;
    return (target / observed * 100).clamp(0, 100);
  }

  double _weightedIndex({
    required double cohesion,
    required double animation,
    required double stress,
  }) {
    return (cohesion * 0.4) + (animation * 0.3) + (stress * 0.3);
  }

  String _buildTextSummary({
    required _MetricScore cohesion,
    required _MetricScore animation,
    required _MetricScore stress,
    required double index,
    required bool pass,
  }) {
    final buffer = StringBuffer()
      ..writeln('VISUAL COHESION FINAL SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Visual Cohesion Final Index: ${index.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_threshold.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Metrics:')
      ..writeln(
        '- Cohesion: ${cohesion.score.toStringAsFixed(2)}% (${cohesion.detail})',
      )
      ..writeln(
        '- Animation: ${animation.score.toStringAsFixed(2)}% (${animation.detail})',
      )
      ..writeln(
        '- Stress: ${stress.score.toStringAsFixed(2)}% (${stress.detail})',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required _MetricScore cohesion,
    required _MetricScore animation,
    required _MetricScore stress,
    required double index,
    required bool pass,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'visual_cohesion_index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
      'metrics': {
        'cohesion': {
          'score': cohesion.score,
          'detail': cohesion.detail,
          'source': cohesion.source,
        },
        'animation': {
          'score': animation.score,
          'detail': animation.detail,
          'source': animation.source,
        },
        'stress': {
          'score': stress.score,
          'detail': stress.detail,
          'source': stress.source,
        },
      },
    };
  }

  Future<void> _appendTelemetry({
    required _MetricScore cohesion,
    required _MetricScore animation,
    required _MetricScore stress,
    required double index,
    required bool pass,
  }) async {
    final payload = <String, Object?>{
      'event': 'visual_cohesion_final_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
      'metrics': {
        'cohesion': cohesion.score,
        'animation': animation.score,
        'stress': stress.score,
      },
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }

  Future<String> _readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing $path');
    }
    return file.readAsString();
  }
}

class _MetricScore {
  const _MetricScore({
    required this.name,
    required this.score,
    required this.detail,
    required this.source,
  });

  final String name;
  final double score;
  final String detail;
  final String source;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore chmod failures
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore failures
    }
  }
}
