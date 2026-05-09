import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _cohesionPath =
    '$_reportsDir/visual_cohesion_dashboard_v2_summary.txt';
const String _animationPath = '$_reportsDir/ui_micro_animation_summary.txt';
const String _stressPath = '$_reportsDir/dynamic_visual_stress_summary.txt';
const String _motionPath = '$_reportsDir/ui_performance_tuner_summary.txt';
const String _summaryTextPath = '$_reportsDir/visual_qa_final_summary.txt';
const String _summaryJsonPath = '$_reportsDir/visual_qa_final_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _animationTargetMs = 16.0;
const double _stressTargetMs = 16.0;
const double _motionTargetMs = 16.0;
const double _finalHealthThreshold = 90.0;

Future<void> main(List<String> args) async {
  final cli = VisualQaFinalPass();
  final ok = await cli.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualQaFinalPass {
  Future<bool> run() async {
    final cohesion = await _readCohesion();
    final animation = await _readAnimation();
    final stress = await _readStress();
    final motion = await _readMotion();

    final components = [cohesion, motion, animation, stress];
    final finalHealth =
        components.map((metric) => metric.value).reduce((a, b) => a + b) /
        components.length;
    final pass = finalHealth >= _finalHealthThreshold;

    final summaryText = _buildTextSummary(components, finalHealth, pass);
    final summaryJson = _buildJsonSummary(components, finalHealth, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(components, finalHealth, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Final Visual Health ${finalHealth.toStringAsFixed(2)}% below '
        '${_finalHealthThreshold.toStringAsFixed(0)}% threshold.',
      );
    }

    return pass;
  }

  Future<_Metric> _readCohesion() async {
    final contents = await _readFile(_cohesionPath);
    final value = _extractPercent(
      contents,
      RegExp(r'Overall Visual Health Index:\s*([0-9.]+)%'),
    );
    return _Metric(
      name: 'cohesion',
      value: value,
      source: _cohesionPath,
      notes: 'Overall Visual Health Index',
    );
  }

  Future<_Metric> _readAnimation() async {
    final contents = await _readFile(_animationPath);
    final match = RegExp(
      r'Frame timing \(ms\):[\s\S]*?- P95\s*:\s*([0-9.]+)',
    ).firstMatch(contents);
    if (match == null) {
      throw StateError('Missing frame P95 in $_animationPath');
    }
    final p95 = double.parse(match.group(1)!);
    final percent = _percentFromP95(p95, _animationTargetMs);
    return _Metric(
      name: 'animation',
      value: percent,
      source: _animationPath,
      notes: 'Frame timing P95 ${p95.toStringAsFixed(2)}ms',
    );
  }

  Future<_Metric> _readStress() async {
    final contents = await _readFile(_stressPath);
    final match = RegExp(
      r'Frame statistics \(ms\):[\s\S]*?- P95\s*:\s*([0-9.]+)',
    ).firstMatch(contents);
    if (match == null) {
      throw StateError('Missing stress P95 in $_stressPath');
    }
    final p95 = double.parse(match.group(1)!);
    final percent = _percentFromP95(p95, _stressTargetMs);
    return _Metric(
      name: 'stress',
      value: percent,
      source: _stressPath,
      notes: 'Frame P95 ${p95.toStringAsFixed(2)}ms',
    );
  }

  Future<_Metric> _readMotion() async {
    final contents = await _readFile(_motionPath);
    final match = RegExp(
      r'p95 frame:\s*([0-9.]+)ms',
      caseSensitive: false,
    ).firstMatch(contents);
    if (match == null) {
      throw StateError('Missing motion P95 in $_motionPath');
    }
    final p95 = double.parse(match.group(1)!);
    final percent = _percentFromP95(p95, _motionTargetMs);
    return _Metric(
      name: 'motion',
      value: percent,
      source: _motionPath,
      notes: 'p95 frame ${p95.toStringAsFixed(2)}ms',
    );
  }

  String _buildTextSummary(
    List<_Metric> metrics,
    double finalHealth,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('VISUAL QA FINAL SUMMARY')
      ..writeln('=======================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Final Visual Health: ${finalHealth.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_finalHealthThreshold.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Components:');
    for (final metric in metrics) {
      buffer.writeln(
        '- ${metric.name.toUpperCase()}: ${metric.value.toStringAsFixed(2)}% '
        '(${metric.notes})',
      );
      buffer.writeln('  Source: ${metric.source}');
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    List<_Metric> metrics,
    double finalHealth,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'final_health': finalHealth,
      'threshold': _finalHealthThreshold,
      'verdict': pass ? 'PASS' : 'FAIL',
      'components': metrics
          .map(
            (metric) => {
              'name': metric.name,
              'value': metric.value,
              'notes': metric.notes,
              'source': metric.source,
            },
          )
          .toList(),
    };
  }

  Future<void> _appendTelemetry(
    List<_Metric> metrics,
    double finalHealth,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_qa_final_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'final_health': finalHealth,
      'threshold': _finalHealthThreshold,
      'verdict': pass ? 'PASS' : 'FAIL',
      'components': metrics
          .map((metric) => {'name': metric.name, 'value': metric.value})
          .toList(),
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

  double _extractPercent(String contents, RegExp pattern) {
    final match = pattern.firstMatch(contents);
    if (match == null) {
      throw StateError('Unable to extract percent with ${pattern.pattern}');
    }
    final raw = match.group(1);
    final value = double.tryParse(raw ?? '');
    if (value == null) {
      throw StateError('Invalid percent "$raw"');
    }
    return value;
  }

  double _percentFromP95(double observed, double target) {
    if (observed <= 0) {
      return 0;
    }
    final ratio = (target / observed) * 100;
    if (ratio.isNaN || ratio.isInfinite) {
      return 0;
    }
    return ratio.clamp(0, 100);
  }
}

class _Metric {
  _Metric({
    required this.name,
    required this.value,
    required this.source,
    required this.notes,
  });

  final String name;
  final double value;
  final String source;
  final String notes;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore if chmod fails
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
