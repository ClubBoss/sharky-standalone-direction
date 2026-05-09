import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _phiSummaryPath = '$_reportsDir/phi_v2_bootstrap_summary.txt';
const String _motionPath = '$_reportsDir/ui_micro_animation_summary.txt';
const String _contrastPath = '$_reportsDir/contrast_accessibility_summary.txt';
const String _summaryTextPath =
    '$_reportsDir/adaptive_design_reactor_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_design_reactor_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _targetCohesion = 95.0;

Future<void> main(List<String> args) async {
  final reactor = AdaptiveDesignReactor();
  final ok = await reactor.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveDesignReactor {
  Future<bool> run() async {
    final phiMetrics = await _parsePhiSummary();
    final motionHealth = await _extractMotionHealth();
    final contrastHealth = await _extractContrastHealth();

    final cohesionGain =
        (phiMetrics.visualDelta + motionHealth.delta + contrastHealth.delta)
            .clamp(0, 100)
            .toDouble();

    final adjustments = _tuneDesignCohesion(cohesionGain);
    final pass = cohesionGain >= _targetCohesion;

    final summaryText = _buildTextSummary(
      phi: phiMetrics,
      motion: motionHealth,
      contrast: contrastHealth,
      cohesionGain: cohesionGain,
      adjustments: adjustments,
      pass: pass,
    );

    final summaryJson = _buildJsonSummary(
      phi: phiMetrics,
      motion: motionHealth,
      contrast: contrastHealth,
      cohesionGain: cohesionGain,
      adjustments: adjustments,
      pass: pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(cohesionGain, adjustments, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Adaptive Design Reactor failed: cohesion gain '
        '${cohesionGain.toStringAsFixed(2)} below ${_targetCohesion.toStringAsFixed(0)}.',
      );
    }

    return pass;
  }

  Future<_PhiMetrics> _parsePhiSummary() async {
    final file = File(_phiSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_phiSummaryPath');
    }
    final contents = await file.readAsString();
    final visual = _extractMetric(contents, 'Visual Cohesion');
    final motion = _extractMetric(contents, 'Motion Performance');
    final feedback = _extractMetric(contents, 'UX Feedback');
    final profile = _extractMetric(contents, 'Profile Clarity');
    return _PhiMetrics(
      visual: visual.current,
      visualDelta: visual.delta,
      motion: motion.current,
      feedback: feedback.current,
      profile: profile.current,
    );
  }

  Future<_MetricDelta> _extractMotionHealth() async {
    final file = File(_motionPath);
    if (!await file.exists()) return const _MetricDelta(current: 0, delta: 0);
    final contents = await file.readAsString();
    final p95Match = RegExp(r'P95\s*:\s*([0-9.]+)').firstMatch(contents);
    if (p95Match == null) return const _MetricDelta(current: 0, delta: 0);
    final p95 = double.tryParse(p95Match.group(1) ?? '') ?? 0;
    if (p95 <= 0) return const _MetricDelta(current: 0, delta: 0);
    const target = 16.0;
    final current = (target / p95 * 100).clamp(0, 100).toDouble();
    return _MetricDelta(current: current, delta: current - 90);
  }

  Future<_MetricDelta> _extractContrastHealth() async {
    final file = File(_contrastPath);
    if (!await file.exists()) return const _MetricDelta(current: 0, delta: 0);
    final contents = await file.readAsString();
    final scoreMatch = RegExp(
      r'Contrast score:\s*([0-9.]+)%',
    ).firstMatch(contents);
    if (scoreMatch == null) return const _MetricDelta(current: 0, delta: 0);
    final current = double.tryParse(scoreMatch.group(1) ?? '') ?? 0;
    return _MetricDelta(current: current, delta: current - 90);
  }

  _Adjustments _tuneDesignCohesion(double cohesion) {
    final deficit = (_targetCohesion - cohesion).clamp(0, 100).toDouble();
    final darkness = (50 + deficit * 0.2).clamp(0, 100).toDouble();
    final saturation = (60 + deficit * 0.3).clamp(0, 100).toDouble();
    final animationSpeed = (1.0 + deficit * 0.01).clamp(0.5, 1.5).toDouble();
    return _Adjustments(
      darkness: darkness,
      saturation: saturation,
      animationSpeed: animationSpeed,
    );
  }

  String _buildTextSummary({
    required _PhiMetrics phi,
    required _MetricDelta motion,
    required _MetricDelta contrast,
    required double cohesionGain,
    required _Adjustments adjustments,
    required bool pass,
  }) {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE DESIGN REACTOR SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Cohesion gain: ${cohesionGain.toStringAsFixed(2)}')
      ..writeln('Threshold: ${_targetCohesion.toStringAsFixed(2)}')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Inputs:')
      ..writeln('  Visual delta: ${phi.visualDelta.toStringAsFixed(2)}')
      ..writeln('  Motion delta: ${motion.delta.toStringAsFixed(2)}')
      ..writeln('  Contrast delta: ${contrast.delta.toStringAsFixed(2)}')
      ..writeln()
      ..writeln('Adjusted coefficients:')
      ..writeln('  Darkness: ${adjustments.darkness.toStringAsFixed(1)}')
      ..writeln('  Saturation: ${adjustments.saturation.toStringAsFixed(1)}')
      ..writeln(
        '  Animation speed: ${adjustments.animationSpeed.toStringAsFixed(2)}x',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required _PhiMetrics phi,
    required _MetricDelta motion,
    required _MetricDelta contrast,
    required double cohesionGain,
    required _Adjustments adjustments,
    required bool pass,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'cohesion_gain': cohesionGain,
      'threshold': _targetCohesion,
      'visual_delta': phi.visualDelta,
      'motion_delta': motion.delta,
      'contrast_delta': contrast.delta,
      'adjustments': {
        'darkness': adjustments.darkness,
        'saturation': adjustments.saturation,
        'animation_speed': adjustments.animationSpeed,
      },
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    double cohesionGain,
    _Adjustments adjustments,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_design_reactor_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'cohesion_gain': cohesionGain,
      'threshold': _targetCohesion,
      'darkness': adjustments.darkness,
      'saturation': adjustments.saturation,
      'animation_speed': adjustments.animationSpeed,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }

  _MetricParse _extractMetric(String contents, String label) {
    final regex = RegExp(
      '$label: ([0-9.]+)% \\(baseline ([0-9.]+)%\\, delta ([0-9.\\-]+)%\\)',
    );
    final match = regex.firstMatch(contents);
    if (match == null) {
      return const _MetricParse(current: 0, baseline: 0, delta: 0);
    }
    final current = double.tryParse(match.group(1) ?? '') ?? 0;
    final baseline = double.tryParse(match.group(2) ?? '') ?? 0;
    final delta = double.tryParse(match.group(3) ?? '') ?? 0;
    return _MetricParse(current: current, baseline: baseline, delta: delta);
  }
}

class _PhiMetrics {
  const _PhiMetrics({
    required this.visual,
    required this.visualDelta,
    required this.motion,
    required this.feedback,
    required this.profile,
  });

  final double visual;
  final double visualDelta;
  final double motion;
  final double feedback;
  final double profile;
}

class _MetricParse {
  const _MetricParse({
    required this.current,
    required this.baseline,
    required this.delta,
  });

  final double current;
  final double baseline;
  final double delta;
}

class _MetricDelta {
  const _MetricDelta({required this.current, required this.delta});

  final double current;
  final double delta;
}

class _Adjustments {
  const _Adjustments({
    required this.darkness,
    required this.saturation,
    required this.animationSpeed,
  });

  final double darkness;
  final double saturation;
  final double animationSpeed;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore
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
