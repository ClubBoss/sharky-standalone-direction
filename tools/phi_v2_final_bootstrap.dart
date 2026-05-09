import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _uxHarmonyTextPath =
    '$_reportsDir/ux_harmony_integrator_summary.txt';
const String _designCohesionTextPath =
    '$_reportsDir/design_cohesion_summary.txt';
const String _cognitiveSummaryTextPath =
    '$_reportsDir/cognitive_design_coherence_summary.txt';
const String _uxHarmonyJsonPath =
    '$_reportsDir/ux_harmony_integrator_summary.json';
const String _designCohesionJsonPath =
    '$_reportsDir/design_cohesion_summary.json';
const String _cognitiveSummaryJsonPath =
    '$_reportsDir/cognitive_design_coherence_summary.json';
const String _summaryTextPath = '$_reportsDir/phi_v2_final_summary.txt';
const String _summaryJsonPath = '$_reportsDir/phi_v2_final_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final bootstrap = PhiV2FinalBootstrap();
  final ok = await bootstrap.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PhiV2FinalBootstrap {
  Future<bool> run() async {
    final uxHarmony = await _readScore(
      textPath: _uxHarmonyTextPath,
      jsonPath: _uxHarmonyJsonPath,
      jsonKeys: const ['harmony_score'],
      labelHints: const ['Harmony score', 'Harmony'],
    );
    final designCohesion = await _readScore(
      textPath: _designCohesionTextPath,
      jsonPath: _designCohesionJsonPath,
      jsonKeys: const ['design_cohesion_score'],
      labelHints: const ['Design Cohesion Score', 'Design Cohesion'],
    );
    final cognitiveCoherence = await _readScore(
      textPath: _cognitiveSummaryTextPath,
      jsonPath: _cognitiveSummaryJsonPath,
      jsonKeys: const ['cognitive_coherence_score'],
      labelHints: const ['Cognitive Coherence Score', 'Cognitive Coherence'],
    );

    if (uxHarmony == null ||
        designCohesion == null ||
        cognitiveCoherence == null) {
      stderr.writeln(
        'Missing Φ-v2 inputs (ux harmony/design cohesion/cognitive coherence).',
      );
      return false;
    }

    final index =
        ((uxHarmony * 0.4) +
                (designCohesion * 0.3) +
                (cognitiveCoherence * 0.3))
            .clamp(0, 1)
            .toDouble();
    final pass = index >= _threshold;

    final summaryText = _buildTextSummary(
      uxHarmony,
      designCohesion,
      cognitiveCoherence,
      index,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      uxHarmony,
      designCohesion,
      cognitiveCoherence,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Φ-v2 Final Design Index ${index.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  Future<double?> _readScore({
    required String textPath,
    required String jsonPath,
    required List<String> jsonKeys,
    required List<String> labelHints,
  }) async {
    final jsonValue = await _readJsonValue(jsonPath, jsonKeys);
    if (jsonValue != null) {
      return _normalizeScore(jsonValue);
    }
    final textValue = await _readTextValue(textPath, labelHints);
    if (textValue != null) {
      return _normalizeScore(textValue);
    }
    return null;
  }

  Future<double?> _readJsonValue(String path, List<String> keys) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        for (final key in keys) {
          final value = decoded[key];
          if (value is num) {
            return value.toDouble();
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<double?> _readTextValue(String path, List<String> labelHints) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final contents = await file.readAsString();
      for (final label in labelHints) {
        final regex = RegExp('$label[^0-9]*([0-9.]+)%', caseSensitive: false);
        final match = regex.firstMatch(contents);
        if (match != null) {
          final value = double.tryParse(match.group(1) ?? '');
          if (value != null) {
            return value;
          }
        }
      }
      final fallback = RegExp(r'([0-9.]+)%').firstMatch(contents);
      if (fallback != null) {
        return double.tryParse(fallback.group(1) ?? '');
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  double _normalizeScore(double raw) {
    if (raw <= 1.0) {
      return raw.clamp(0, 1).toDouble();
    }
    return (raw / 100).clamp(0, 1).toDouble();
  }

  String _buildTextSummary(
    double uxHarmony,
    double designCohesion,
    double cognitiveCoherence,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('Φ-V2 FINAL BOOTSTRAP SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('UX Harmony Score: ${pct(uxHarmony)}')
      ..writeln('Design Cohesion Score: ${pct(designCohesion)}')
      ..writeln('Cognitive Coherence Score: ${pct(cognitiveCoherence)}')
      ..writeln('Φ-v2 Final Design Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double uxHarmony,
    double designCohesion,
    double cognitiveCoherence,
    double index,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'ux_harmony_score': uxHarmony,
      'design_cohesion_score': designCohesion,
      'cognitive_coherence_score': cognitiveCoherence,
      'phi_v2_final_design_index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(double index, bool pass) async {
    final payload = <String, Object?>{
      'event': 'phi_v2_final_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'phi_v2_final_design_index': index,
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
