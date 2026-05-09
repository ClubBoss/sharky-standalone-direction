import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/phi_v2_bootstrap_summary.txt';
const String _summaryJsonPath = '$_reportsDir/phi_v2_bootstrap_summary.json';

const double _minDesignLiftIndex = 90.0;

const Map<String, String> _baselineMetrics = {
  'visual': 'visual_cohesion_v2_summary.txt',
  'motion': 'ui_micro_animation_summary.txt',
  'feedback': 'visual_qa_final_summary.txt',
  'profile': 'player_profile_explanation_summary.txt',
};

Future<void> main(List<String> args) async {
  final bootstrap = PhiV2Bootstrap();
  final ok = await bootstrap.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PhiV2Bootstrap {
  Future<bool> run() async {
    final nowMetrics = await _collectCurrentMetrics();
    final baseline = await _collectBaseline();
    final deltas = _computeDeltas(nowMetrics, baseline);
    final designLiftIndex = _weightedIndex(deltas);
    final pass = designLiftIndex >= _minDesignLiftIndex;

    final summaryText = _buildTextSummary(
      nowMetrics,
      baseline,
      deltas,
      designLiftIndex,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      nowMetrics,
      baseline,
      deltas,
      designLiftIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(designLiftIndex, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Design Lift Index ${designLiftIndex.toStringAsFixed(2)} below threshold.',
      );
    }

    return pass;
  }

  Future<Map<String, double>> _collectCurrentMetrics() async {
    final visual = await _readVisualLift();
    final motion = await _readMotionLift();
    final feedback = await _readFeedbackLift();
    final profile = await _readProfileClarity();
    return {
      'visual': visual,
      'motion': motion,
      'feedback': feedback,
      'profile': profile,
    };
  }

  Future<Map<String, double>> _collectBaseline() async {
    final results = <String, double>{};
    for (final entry in _baselineMetrics.entries) {
      final path = '$_reportsDir/${entry.value}';
      final value = await _extractPercent(path);
      results[entry.key] = value;
    }
    return results;
  }

  Future<double> _readVisualLift() async {
    final file = File('$_reportsDir/visual_cohesion_final_summary.txt');
    return _extractPercent(file.path);
  }

  Future<double> _readMotionLift() async {
    final file = File('$_reportsDir/ui_micro_animation_summary.txt');
    if (!await file.exists()) return 0;
    final contents = await file.readAsString();
    final match = RegExp(r'P95\s*:\s*([0-9.]+)ms').firstMatch(contents);
    if (match == null) return 0;
    final p95 = double.tryParse(match.group(1) ?? '') ?? 0;
    if (p95 <= 0) return 0;
    const target = 16.0;
    return (target / p95 * 100).clamp(0, 100);
  }

  Future<double> _readFeedbackLift() async {
    final file = File('$_reportsDir/visual_qa_final_summary.txt');
    return _extractPercent(file.path);
  }

  Future<double> _readProfileClarity() async {
    final file = File('$_reportsDir/player_profile_explanation_summary.txt');
    if (!await file.exists()) return 0;
    final contents = await file.readAsString();
    final match = RegExp(
      r'Profile clarity index:\s*([0-9.]+)%',
    ).firstMatch(contents);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '') ?? 0;
    }
    return _extractPercent(file.path);
  }

  Future<double> _extractPercent(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    try {
      final contents = await file.readAsString();
      final match = RegExp(r'([0-9.]+)%').firstMatch(contents);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '') ?? 0;
      }
    } catch (_) {
      return 0;
    }
    return 0;
  }

  Map<String, double> _computeDeltas(
    Map<String, double> current,
    Map<String, double> baseline,
  ) {
    final deltas = <String, double>{};
    for (final entry in current.entries) {
      final key = entry.key;
      final base = baseline[key] ?? 0;
      deltas[key] = entry.value - base;
    }
    return deltas;
  }

  double _weightedIndex(Map<String, double> metrics) {
    final visual = metrics['visual'] ?? 0;
    final motion = metrics['motion'] ?? 0;
    final feedback = metrics['feedback'] ?? 0;
    final profile = metrics['profile'] ?? 0;
    return (visual * 0.35) +
        (motion * 0.25) +
        (feedback * 0.25) +
        (profile * 0.15);
  }

  String _buildTextSummary(
    Map<String, double> now,
    Map<String, double> baseline,
    Map<String, double> deltas,
    double index,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('PHI V2 BOOTSTRAP SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Design Lift Index: ${index.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minDesignLiftIndex.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Metrics:')
      ..writeln(
        _metricLine(
          'Visual Cohesion',
          now['visual'],
          baseline['visual'],
          deltas['visual'],
        ),
      )
      ..writeln(
        _metricLine(
          'Motion Performance',
          now['motion'],
          baseline['motion'],
          deltas['motion'],
        ),
      )
      ..writeln(
        _metricLine(
          'UX Feedback',
          now['feedback'],
          baseline['feedback'],
          deltas['feedback'],
        ),
      )
      ..writeln(
        _metricLine(
          'Profile Clarity',
          now['profile'],
          baseline['profile'],
          deltas['profile'],
        ),
      );
    return buffer.toString();
  }

  String _metricLine(
    String label,
    double? current,
    double? baseline,
    double? delta,
  ) {
    return '- $label: ${current?.toStringAsFixed(2) ?? '0.00'}% '
        '(baseline ${baseline?.toStringAsFixed(2) ?? '0.00'}%, '
        'delta ${delta?.toStringAsFixed(2) ?? '0.00'}%)';
  }

  Map<String, Object?> _buildJsonSummary(
    Map<String, double> now,
    Map<String, double> baseline,
    Map<String, double> deltas,
    double index,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'design_lift_index': index,
      'threshold': _minDesignLiftIndex,
      'metrics': {
        'visual': {
          'current': now['visual'],
          'baseline': baseline['visual'],
          'delta': deltas['visual'],
        },
        'motion': {
          'current': now['motion'],
          'baseline': baseline['motion'],
          'delta': deltas['motion'],
        },
        'feedback': {
          'current': now['feedback'],
          'baseline': baseline['feedback'],
          'delta': deltas['feedback'],
        },
        'profile': {
          'current': now['profile'],
          'baseline': baseline['profile'],
          'delta': deltas['profile'],
        },
      },
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(double index, bool pass) async {
    final payload = <String, Object?>{
      'event': 'phi_v2_bootstrap_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'design_lift_index': index,
      'threshold': _minDesignLiftIndex,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
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
