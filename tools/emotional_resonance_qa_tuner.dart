import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _harmonyPath = '$_reportsDir/ux_harmony_summary.json';
const String _resonancePath =
    '$_reportsDir/ux_emotional_resonance_summary.json';
const String _summaryTextPath =
    '$_reportsDir/emotional_resonance_qa_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/emotional_resonance_qa_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final tuner = EmotionalResonanceQaTuner();
  final ok = await tuner.run();
  if (!ok) {
    exitCode = 2;
  }
}

class EmotionalResonanceQaTuner {
  Future<bool> run() async {
    final harmony = await _readJson(_harmonyPath);
    final resonance = await _readJson(_resonancePath);
    if (harmony == null || resonance == null) {
      stderr.writeln('Missing UX harmony or resonance summaries.');
      return false;
    }

    final harmonyScore = (harmony['harmony_score'] as num?)?.toDouble() ?? 0;
    final resonanceScore =
        (resonance['average_resonance'] as num?)?.toDouble() ?? 0;

    final score = ((harmonyScore + resonanceScore) / 2).clamp(0, 1).toDouble();
    final pass = score >= _threshold;

    final summaryText = _buildTextSummary(
      harmonyScore,
      resonanceScore,
      score,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      harmonyScore,
      resonanceScore,
      score,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(score, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Resonance QA Score ${score.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String _buildTextSummary(
    double harmony,
    double resonance,
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('EMOTIONAL RESONANCE QA SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('UX Harmony Score: ${pct(harmony)}')
      ..writeln('UX Resonance Score: ${pct(resonance)}')
      ..writeln('Resonance QA Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double harmony,
    double resonance,
    double score,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'harmony_score': harmony,
      'resonance_score': resonance,
      'resonance_qa_score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(double score, bool pass) async {
    final payload = <String, Object?>{
      'event': 'emotional_resonance_qa_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'resonance_qa_score': score,
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
