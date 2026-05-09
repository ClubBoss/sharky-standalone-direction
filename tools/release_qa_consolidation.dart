import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _stabilitySummaryPath =
    '$_reportsDir/stability_qa_consolidator_v2_summary.json';
const String _visualSummaryPath = '$_reportsDir/visual_ux_polish_summary.json';
const String _contentSummaryPath =
    '$_reportsDir/content_sync_audit_summary.json';
const String _monetizationSummaryPath =
    '$_reportsDir/global_monetization_summary.json';
const String _regressionSummaryPath =
    '$_reportsDir/continuous_regression_assurance_summary.json';
const String _profileSummaryPath =
    '$_reportsDir/profile_persistence_summary.json';
const String _summaryTextPath =
    '$_reportsDir/release_qa_consolidation_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/release_qa_consolidation_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final consolidator = ReleaseQaConsolidation();
  final ok = await consolidator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ReleaseQaConsolidation {
  Future<bool> run() async {
    final stability = await _readScore(
      path: _stabilitySummaryPath,
      key: 'stability_integrity_score',
    );
    final visual = await _readScore(
      path: _visualSummaryPath,
      key: 'visual_ux_polish_index',
    );
    final content = await _readScore(
      path: _contentSummaryPath,
      key: 'content_consistency_index',
    );
    final monetization = await _readScore(
      path: _monetizationSummaryPath,
      key: 'global_monetization_index',
    );
    final regression = await _readScore(
      path: _regressionSummaryPath,
      key: 'regression_assurance_score',
    );
    final profile = await _readProfileScore();

    if (stability == null ||
        visual == null ||
        content == null ||
        monetization == null ||
        regression == null ||
        profile == null) {
      stderr.writeln(
        'Missing release QA summaries (stability/visual/content/monetization/regression/profile).',
      );
      return false;
    }

    final releaseQaIndex =
        ((stability * 0.25) +
                (visual * 0.2) +
                (content * 0.2) +
                (monetization * 0.15) +
                (regression * 0.1) +
                (profile * 0.1))
            .clamp(0, 1)
            .toDouble();
    final pass = releaseQaIndex >= _threshold;

    final summaryText = _buildTextSummary(
      stability,
      visual,
      content,
      monetization,
      regression,
      profile,
      releaseQaIndex,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      stability,
      visual,
      content,
      monetization,
      regression,
      profile,
      releaseQaIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        stability,
        visual,
        content,
        monetization,
        regression,
        profile,
        releaseQaIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Release QA Index ${releaseQaIndex.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  Future<double?> _readScore({
    required String path,
    required String key,
  }) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final value = decoded[key];
        if (value is num) {
          return value.toDouble().clamp(0, 1);
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<double?> _readProfileScore() async {
    final file = File(_profileSummaryPath);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      final verified = decoded['verified'] == true;
      final resonance =
          (decoded['ux_resonance'] as num?)?.toDouble().clamp(0, 1) ?? 0;
      if (!verified) return null;
      return resonance.toDouble();
    } catch (_) {
      return null;
    }
  }

  String _buildTextSummary(
    double stability,
    double visual,
    double content,
    double monetization,
    double regression,
    double profile,
    double releaseQaIndex,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('RELEASE QA CONSOLIDATION SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Stability Integrity Score: ${pct(stability)}')
      ..writeln('Visual UX Polish Index: ${pct(visual)}')
      ..writeln('Content Consistency Index: ${pct(content)}')
      ..writeln('Global Monetization Index: ${pct(monetization)}')
      ..writeln('Regression Assurance Score: ${pct(regression)}')
      ..writeln('Profile Persistence Score: ${pct(profile)}')
      ..writeln('Release QA Index: ${pct(releaseQaIndex)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double stability,
    double visual,
    double content,
    double monetization,
    double regression,
    double profile,
    double releaseQaIndex,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'stability_integrity_score': stability,
      'visual_ux_polish_index': visual,
      'content_consistency_index': content,
      'global_monetization_index': monetization,
      'regression_assurance_score': regression,
      'profile_persistence_score': profile,
      'release_qa_index': releaseQaIndex,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    double stability,
    double visual,
    double content,
    double monetization,
    double regression,
    double profile,
    double releaseQaIndex,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'release_qa_consolidation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'stability_integrity_score': stability,
      'visual_ux_polish_index': visual,
      'content_consistency_index': content,
      'global_monetization_index': monetization,
      'regression_assurance_score': regression,
      'profile_persistence_score': profile,
      'release_qa_index': releaseQaIndex,
      'threshold': _threshold,
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
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
