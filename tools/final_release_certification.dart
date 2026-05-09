import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _releaseQaPath =
    '$_reportsDir/release_qa_consolidation_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _certificateTextPath =
    '$_reportsDir/release_certification_summary.txt';
const String _certificateJsonPath =
    '$_reportsDir/release_certification_summary.json';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final tool = FinalReleaseCertification();
  final ok = await tool.run();
  if (!ok) {
    exitCode = 2;
  }
}

class FinalReleaseCertification {
  Future<bool> run() async {
    final releaseQa = await _readReleaseQaIndex();
    final telemetryCoverage = await _computeTelemetryCoverage();
    if (releaseQa == null || telemetryCoverage == null) {
      stderr.writeln(
        'Missing release QA summary or telemetry coverage metrics.',
      );
      return false;
    }

    final certificationScore = ((releaseQa + telemetryCoverage) / 2)
        .clamp(0, 1)
        .toDouble();
    final pass = certificationScore >= _threshold;

    final summaryText = _buildTextSummary(
      releaseQa,
      telemetryCoverage,
      certificationScore,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      releaseQa,
      telemetryCoverage,
      certificationScore,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_certificateTextPath).writeAsString(summaryText);
      await File(
        _certificateJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        releaseQa,
        telemetryCoverage,
        certificationScore,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Certification Score ${certificationScore.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  Future<double?> _readReleaseQaIndex() async {
    final file = File(_releaseQaPath);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        final index = decoded['release_qa_index'];
        if (index is num) {
          return index.toDouble().clamp(0, 1);
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<double?> _computeTelemetryCoverage() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    double? lastCoverage;
    try {
      final lines = await file.readAsLines();
      for (final raw in lines) {
        final line = raw.trim();
        if (line.isEmpty) continue;
        Map<String, dynamic>? decoded;
        try {
          decoded = json.decode(line) as Map<String, dynamic>?;
        } catch (_) {
          continue;
        }
        if (decoded == null) continue;
        if (decoded.containsKey('coverage_pct')) {
          final value = decoded['coverage_pct'];
          if (value is num) {
            lastCoverage = (value / 100).clamp(0, 1).toDouble();
            continue;
          }
        }
        if (decoded.containsKey('coverage')) {
          final value = decoded['coverage'];
          if (value is num) {
            final normalized = value > 1
                ? (value / 100).clamp(0, 1).toDouble()
                : value.toDouble();
            lastCoverage = normalized.clamp(0, 1).toDouble();
            continue;
          }
        }
      }
    } catch (_) {
      return null;
    }
    return lastCoverage;
  }

  String _buildTextSummary(
    double releaseQa,
    double telemetryCoverage,
    double certificationScore,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('FINAL RELEASE CERTIFICATION')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Release QA Index: ${pct(releaseQa)}')
      ..writeln('Telemetry Coverage: ${pct(telemetryCoverage)}')
      ..writeln('Certification Score: ${pct(certificationScore)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Certification Status: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double releaseQa,
    double telemetryCoverage,
    double certificationScore,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'release_qa_index': releaseQa,
      'telemetry_coverage': telemetryCoverage,
      'certification_score': certificationScore,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    double releaseQa,
    double telemetryCoverage,
    double certificationScore,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'final_release_certification_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'release_qa_index': releaseQa,
      'telemetry_coverage': telemetryCoverage,
      'certification_score': certificationScore,
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
