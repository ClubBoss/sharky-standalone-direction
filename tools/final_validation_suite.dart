import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _integrationPath = '$_reportsDir/final_integration_summary.json';
const String _releaseQaPath =
    '$_reportsDir/release_qa_consolidation_summary.json';
const String _certificationPath =
    '$_reportsDir/final_release_certification_summary.json';
const String _summaryTextPath = '$_reportsDir/final_validation_summary.txt';
const String _summaryJsonPath = '$_reportsDir/final_validation_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _window = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final suite = FinalValidationSuite();
  final ok = await suite.run();
  if (!ok) exitCode = 2;
}

class FinalValidationSuite {
  Future<bool> run() async {
    final integration = await _readReport(
      _integrationPath,
      'final_integration_score',
    );
    final qa = await _readReport(_releaseQaPath, 'release_qa_index');
    final certification = await _readReport(
      _certificationPath,
      'certification_score',
    );

    if (integration == null || qa == null || certification == null) {
      stderr.writeln('Missing final validation inputs.');
      return false;
    }

    if (!integration.pass || !qa.pass || !certification.pass) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (integration.timestamp != null) integration.timestamp!,
      if (qa.timestamp != null) qa.timestamp!,
      if (certification.timestamp != null) certification.timestamp!,
    ];
    if (!_withinWindow(timestamps)) {
      stderr.writeln('Timestamps exceed ${_window.inHours}h.');
      return false;
    }

    final integrationScore = _normalize(integration.score);
    final qaScore = _normalize(qa.score);
    final certificationScore = _normalize(certification.score);

    if (integrationScore == null ||
        qaScore == null ||
        certificationScore == null) {
      stderr.writeln('Unable to parse the scores.');
      return false;
    }

    final index =
        ((integrationScore * 0.4) +
                (qaScore * 0.35) +
                (certificationScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = index >= _threshold;

    final text = _buildText(
      integrationScore,
      qaScore,
      certificationScore,
      index,
      pass,
    );
    final json = _buildJson(
      integrationScore,
      qaScore,
      certificationScore,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        integrationScore,
        qaScore,
        certificationScore,
        index,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Final Integrity Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Report?> _readReport(String path, String key) async {
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
      final score = _toDouble(decoded[key]);
      return _Report(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  bool _withinWindow(List<DateTime> timestamps) {
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
    double integration,
    double qa,
    double certification,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('FINAL VALIDATION SUMMARY')
      ..writeln('========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Final integration: ${pct(integration)}')
      ..writeln('Release QA index: ${pct(qa)}')
      ..writeln('Certification score: ${pct(certification)}')
      ..writeln('Final Integrity Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double integration,
    double qa,
    double certification,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'final_integration_score': integration,
    'release_qa_index': qa,
    'certification_score': certification,
    'final_integrity_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double integration,
    double qa,
    double certification,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'final_validation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'final_integration_score': integration,
      'release_qa_index': qa,
      'certification_score': certification,
      'final_integrity_index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Report {
  _Report({required this.pass, required this.timestamp, required this.score});

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
