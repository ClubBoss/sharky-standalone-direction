import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _perceptualPath =
    '$_reportsDir/perceptual_continuity_summary.json';
const String _visualPath = '$_reportsDir/visual_cohesion_final_v2_summary.json';
const String _uxPath = '$_reportsDir/system_ux_snapshot_v2_summary.json';
const String _summaryTextPath =
    '$_reportsDir/design_audit_consolidator_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/design_audit_consolidator_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _window = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final consolidator = DesignAuditConsolidator();
  final ok = await consolidator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class DesignAuditConsolidator {
  Future<bool> run() async {
    final perceptual = await _loadSummary(
      _perceptualPath,
      'perceptual_continuity_score',
    );
    final visual = await _loadSummary(
      _visualPath,
      'visual_cohesion_final_v2_index',
    );
    final ux = await _loadSummary(_uxPath, 'system_ux_integrity_index');

    if (perceptual == null || visual == null || ux == null) {
      stderr.writeln('Missing design audit inputs.');
      return false;
    }

    if (!perceptual.pass || !visual.pass || !ux.pass) {
      stderr.writeln('One or more summaries failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (perceptual.timestamp != null) perceptual.timestamp!,
      if (visual.timestamp != null) visual.timestamp!,
      if (ux.timestamp != null) ux.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Inputs span more than 24h.');
      return false;
    }

    final perceptualScore = _normalize(perceptual.score);
    final visualScore = _normalize(visual.score);
    final uxScore = _normalize(ux.score);

    if (perceptualScore == null || visualScore == null || uxScore == null) {
      stderr.writeln('Unable to parse numeric scores.');
      return false;
    }

    final score =
        ((perceptualScore * 0.4) + (visualScore * 0.35) + (uxScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = score >= _threshold;

    final summaryText = _buildText(
      perceptualScore,
      visualScore,
      uxScore,
      score,
      pass,
    );
    final summaryJson = _buildJson(
      perceptualScore,
      visualScore,
      uxScore,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        perceptualScore,
        visualScore,
        uxScore,
        score,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Design Audit Score ${(score * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _loadSummary(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      final verdict = ((decoded['verdict'] as String?) ?? '').toUpperCase();
      final timestamp =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      final parsed = timestamp != null ? DateTime.tryParse(timestamp) : null;
      final score = _nullableScore(decoded[key], decoded['score']);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  double? _nullableScore(Object? primary, Object? fallback) =>
      _toDouble(primary) ?? _toDouble(fallback);

  bool _aligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _window;
  }

  double? _normalize(double? value) {
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  String _buildText(
    double perceptual,
    double visual,
    double ux,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('DESIGN AUDIT CONSOLIDATOR')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Perceptual continuity: ${pct(perceptual)}')
      ..writeln('Visual cohesion: ${pct(visual)}')
      ..writeln('UX integrity: ${pct(ux)}')
      ..writeln('Design Audit Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double perceptual,
    double visual,
    double ux,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'perceptual_continuity_score': perceptual,
    'visual_cohesion_score': visual,
    'ux_integrity_score': ux,
    'design_audit_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double perceptual,
    double visual,
    double ux,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'design_audit_consolidator_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'perceptual_continuity_score': perceptual,
      'visual_cohesion_score': visual,
      'ux_integrity_score': ux,
      'design_audit_score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Summary {
  _Summary({required this.pass, required this.timestamp, required this.score});

  final bool pass;
  final DateTime? timestamp;
  final double? score;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
