import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _interactionSummaryPath =
    '$_reportsDir/visual_interaction_summary.json';
const String _polishSummaryPath = '$_reportsDir/visual_ux_polish_summary.json';
const String _cohesionSummaryPath =
    '$_reportsDir/visual_cohesion_qa_v2_summary.json';
const String _summaryTextPath =
    '$_reportsDir/visual_telemetry_aggregator_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_telemetry_aggregator_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final aggregator = VisualTelemetryAggregator();
  final ok = await aggregator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualTelemetryAggregator {
  Future<bool> run() async {
    final interaction = await _readJson(_interactionSummaryPath);
    final polish = await _readJson(_polishSummaryPath);
    final cohesion = await _readJson(_cohesionSummaryPath);

    if (interaction == null || polish == null || cohesion == null) {
      stderr.writeln(
        'Missing one or more visual telemetry summaries '
        '(interaction/polish/cohesion).',
      );
      return false;
    }

    final interactionScore = _normalizeScore(
      (interaction['visual_interaction_index'] as num?)?.toDouble(),
    );
    final polishScore = _normalizeScore(
      (polish['visual_ux_polish_index'] as num?)?.toDouble(),
    );
    final cohesionScore = _normalizeScore(
      (cohesion['vhi'] as num?)?.toDouble(),
    );

    if (interactionScore == null ||
        polishScore == null ||
        cohesionScore == null) {
      stderr.writeln('Could not extract a score from one of the summaries.');
      return false;
    }

    final average = (interactionScore + polishScore + cohesionScore) / 3.0;
    final values = <double>[interactionScore, polishScore, cohesionScore];
    final variance =
        values
            .map((value) => (value - average) * (value - average))
            .fold<double>(0, (sum, value) => sum + value) /
        values.length;
    final stabilityIndex = (average * (1 - variance))
        .clamp(0.0, 1.0)
        .toDouble();
    final pass = stabilityIndex >= _threshold;

    final summaryText = _buildTextSummary(
      interactionScore,
      polishScore,
      cohesionScore,
      variance,
      stabilityIndex,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      interactionScore,
      polishScore,
      cohesionScore,
      variance,
      stabilityIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        interactionScore,
        polishScore,
        cohesionScore,
        variance,
        stabilityIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Visual Stability Index ${stabilityIndex.toStringAsFixed(3)} below '
        '${(_threshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  String _buildTextSummary(
    double interactionScore,
    double polishScore,
    double cohesionScore,
    double variance,
    double stabilityIndex,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('VISUAL TELEMETRY AGGREGATOR SUMMARY')
      ..writeln('===================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Computed stability variance: ${variance.toStringAsFixed(4)}')
      ..writeln('Visual Interaction Index: ${pct(interactionScore)}')
      ..writeln('Visual UX Polish Index: ${pct(polishScore)}')
      ..writeln('Visual Cohesion QA v2 (VHI): ${pct(cohesionScore)}')
      ..writeln('Visual Stability Index: ${pct(stabilityIndex)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double interactionScore,
    double polishScore,
    double cohesionScore,
    double variance,
    double stabilityIndex,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'visual_interaction_index': interactionScore,
    'visual_ux_polish_index': polishScore,
    'visual_cohesion_vhi': cohesionScore,
    'variance': variance,
    'visual_stability_index': stabilityIndex,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double interactionScore,
    double polishScore,
    double cohesionScore,
    double variance,
    double stabilityIndex,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_telemetry_aggregator_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'visual_interaction_index': interactionScore,
      'visual_ux_polish_index': polishScore,
      'visual_cohesion_vhi': cohesionScore,
      'variance': variance,
      'visual_stability_index': stabilityIndex,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _normalizeScore(double? raw) {
  if (raw == null) return null;
  if (raw <= 1.0) {
    return raw.clamp(0, 1).toDouble();
  }
  return (raw / 100).clamp(0, 1).toDouble();
}

Future<Map<String, Object?>?> _readJson(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final decoded = json.decode(await file.readAsString());
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
  } catch (_) {}
  return null;
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
