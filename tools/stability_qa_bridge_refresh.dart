import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _stabilityQaPath =
    '$_reportsDir/stability_qa_consolidator_v2_summary.json';
const String _systemSnapshotPath =
    '$_reportsDir/system_snapshot_v3_summary.json';
const String _visualPath = '$_reportsDir/visual_ux_polish_summary.json';
const String _validationPath = '$_reportsDir/final_validation_summary.json';
const String _summaryTextPath =
    '$_reportsDir/stability_qa_bridge_refresh_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/stability_qa_bridge_refresh_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final bridge = StabilityQaBridgeRefresh();
  final ok = await bridge.run();
  if (!ok) {
    exitCode = 2;
  }
}

class StabilityQaBridgeRefresh {
  Future<bool> run() async {
    final stabilityQa = await _loadSummary(
      _stabilityQaPath,
      'stability_integrity_score',
    );
    final systemSnapshot = await _loadSummary(
      _systemSnapshotPath,
      'system_snapshot_v3_score',
    );
    final visual = await _loadSummary(_visualPath, 'visual_ux_polish_index');
    final validation = await _loadSummary(
      _validationPath,
      'final_integrity_index',
    );

    if (stabilityQa == null ||
        systemSnapshot == null ||
        visual == null ||
        validation == null) {
      stderr.writeln('Missing stability bridge inputs.');
      return false;
    }

    if (!stabilityQa.pass ||
        !systemSnapshot.pass ||
        !visual.pass ||
        !validation.pass) {
      stderr.writeln('One or more summaries failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (stabilityQa.timestamp != null) stabilityQa.timestamp!,
      if (systemSnapshot.timestamp != null) systemSnapshot.timestamp!,
      if (visual.timestamp != null) visual.timestamp!,
      if (validation.timestamp != null) validation.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final scores = [
      _normalize(stabilityQa.score),
      _normalize(systemSnapshot.score),
      _normalize(visual.score),
      _normalize(validation.score),
    ];
    if (scores.any((value) => value == null)) {
      stderr.writeln('Unable to normalize scores.');
      return false;
    }

    final stabilityScore = scores[0]!;
    final systemScore = scores[1]!;
    final visualScore = scores[2]!;
    final validationScore = scores[3]!;

    final bridgeScore =
        ((stabilityScore * 0.35) +
                (systemScore * 0.3) +
                (visualScore * 0.2) +
                (validationScore * 0.15))
            .clamp(0.0, 1.0);
    final pass = bridgeScore >= _threshold;

    final text = _buildText(
      stabilityScore,
      systemScore,
      visualScore,
      validationScore,
      bridgeScore,
      pass,
    );
    final json = _buildJson(
      stabilityScore,
      systemScore,
      visualScore,
      validationScore,
      bridgeScore,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        stabilityScore,
        systemScore,
        visualScore,
        validationScore,
        bridgeScore,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Stability Bridge Score ${(bridgeScore * 100).toStringAsFixed(2)}% below threshold.',
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
      final score = _toDouble(decoded[key]) ?? _toDouble(decoded['score']);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  bool _aligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
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
    double stability,
    double system,
    double visual,
    double validation,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('STABILITY QA BRIDGE REFRESH')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Stability QA score: ${pct(stability)}')
      ..writeln('System snapshot: ${pct(system)}')
      ..writeln('Visual UX polish: ${pct(visual)}')
      ..writeln('Final validation: ${pct(validation)}')
      ..writeln('Stability Bridge Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double stability,
    double system,
    double visual,
    double validation,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'stability_integrity_score': stability,
    'system_snapshot_score': system,
    'visual_ux_polish_score': visual,
    'final_validation_score': validation,
    'stability_bridge_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double stability,
    double system,
    double visual,
    double validation,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'stability_qa_bridge_refresh_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'stability_integrity_score': stability,
      'system_snapshot_score': system,
      'visual_ux_polish_score': visual,
      'final_validation_score': validation,
      'stability_bridge_score': score,
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
