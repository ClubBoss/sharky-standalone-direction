import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _insightSummaryPath =
    '$_reportsDir/telemetry_insight_summary.json';
const String _interactionSummaryPath =
    '$_reportsDir/visual_interaction_summary.json';
const String _summaryTextPath =
    '$_reportsDir/post_release_adaptive_feedback_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/post_release_adaptive_feedback_summary.json';

const double _threshold = 0.85;
const double _minFactor = 0.8;
const double _maxFactor = 1.2;

Future<void> main(List<String> args) async {
  final engine = PostReleaseAdaptiveFeedbackEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PostReleaseAdaptiveFeedbackEngine {
  Future<bool> run() async {
    final insight = await _readJson(_insightSummaryPath);
    final interaction = await _readJson(_interactionSummaryPath);
    if (insight == null || interaction == null) {
      stderr.writeln('Missing insight or interaction summaries.');
      return false;
    }
    final healthScore = _asDouble(insight['ux_health_score']);
    final visualIndex = _asDouble(interaction['visual_interaction_index']);
    if (healthScore == null || visualIndex == null) {
      stderr.writeln('Required metrics missing.');
      return false;
    }
    if (healthScore < _threshold) {
      stderr.writeln('UX health score $healthScore below $_threshold.');
      return false;
    }

    const baseFade = 250;
    const baseEventDelay = 120;
    final factor = (1 / healthScore).clamp(_minFactor, _maxFactor);
    final recommendedFade = (baseFade * factor).round();
    final recommendedDelay = (baseEventDelay * factor).round();

    final summaryText = _buildText(
      healthScore: healthScore,
      visualIndex: visualIndex,
      fadeMs: recommendedFade,
      delayMs: recommendedDelay,
    );
    final summaryJson = _buildJson(
      healthScore: healthScore,
      visualIndex: visualIndex,
      fadeMs: recommendedFade,
      delayMs: recommendedDelay,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        healthScore,
        visualIndex,
        recommendedFade,
        recommendedDelay,
      );
    });

    return true;
  }

  Future<Map<String, Object?>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final data = json.decode(await file.readAsString());
      if (data is Map<String, Object?>) {
        return data;
      }
    } catch (_) {}
    return null;
  }

  String _buildText({
    required double healthScore,
    required double visualIndex,
    required int fadeMs,
    required int delayMs,
  }) {
    return '''
POST-RELEASE ADAPTIVE FEEDBACK
Generated: ${DateTime.now().toIso8601String()}
UX Health Score: ${healthScore.toStringAsFixed(3)}
Visual Interaction Index: ${visualIndex.toStringAsFixed(3)}
Recommended fade duration: $fadeMs ms
Recommended event delay: $delayMs ms
''';
  }

  Map<String, Object?> _buildJson({
    required double healthScore,
    required double visualIndex,
    required int fadeMs,
    required int delayMs,
  }) => {
    'generated_at': DateTime.now().toIso8601String(),
    'ux_health_score': healthScore,
    'visual_interaction_index': visualIndex,
    'recommended_fade_ms': fadeMs,
    'recommended_event_delay_ms': delayMs,
  };

  Future<void> _appendTelemetry(
    double healthScore,
    double visualIndex,
    int fadeMs,
    int delayMs,
  ) async {
    final payload = <String, Object?>{
      'event': 'post_release_adaptive_feedback_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'ux_health_score': healthScore,
      'visual_interaction_index': visualIndex,
      'fade_ms': fadeMs,
      'delay_ms': delayMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
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
