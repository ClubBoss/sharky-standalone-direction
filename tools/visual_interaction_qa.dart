import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath = '$_reportsDir/visual_interaction_summary.txt';
const String _summaryJsonPath = '$_reportsDir/visual_interaction_summary.json';

const double _threshold = 0.90;
const int _eventDelayMs = 120;

Future<void> main(List<String> args) async {
  final qa = VisualInteractionQa();
  final ok = await qa.run();
  if (!ok) {
    exitCode = 2;
  }
}

class VisualInteractionQa {
  Future<bool> run() async {
    final polish = await _readJson(
      '$_reportsDir/visual_ux_polish_summary.json',
    );
    if (polish == null) {
      stderr.writeln('Missing visual UX polish summary.');
      return false;
    }
    final overlayDuration = await _extractOverlayFadeDuration();
    if (overlayDuration == null) {
      stderr.writeln('Could not parse overlay duration.');
      return false;
    }

    final fadeMs = overlayDuration;
    final latencyIndex = _computeLatencyIndex(fadeMs, _eventDelayMs);
    final cohesionIndex = _computeCohesionIndex(
      polish['visual_ux_polish_index'],
      polish['visual_cohesion_final_score'],
    );

    if (cohesionIndex == null) {
      stderr.writeln('Cohesion metrics missing.');
      return false;
    }

    final visualInteractionIndex = (0.6 * latencyIndex) + (0.4 * cohesionIndex);
    final verdict = visualInteractionIndex >= _threshold ? 'PASS' : 'FAIL';

    final summaryText = _buildTextSummary(
      latencyIndex: latencyIndex,
      cohesionIndex: cohesionIndex,
      visualInteractionIndex: visualInteractionIndex,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      latencyIndex: latencyIndex,
      cohesionIndex: cohesionIndex,
      visualInteractionIndex: visualInteractionIndex,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        latencyIndex,
        cohesionIndex,
        visualInteractionIndex,
        verdict,
      );
    });

    if (verdict == 'FAIL') {
      stderr.writeln(
        'Visual Interaction Index ${visualInteractionIndex.toStringAsFixed(4)} below threshold.',
      );
    }
    return verdict == 'PASS';
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

  Future<int?> _extractOverlayFadeDuration() async {
    final file = File('lib/ui/player_explanation_overlay.dart');
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    final match = RegExp(
      r'Duration\(milliseconds:\s*(\d+)\)',
    ).firstMatch(content);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  double _computeLatencyIndex(int fadeMs, int eventDelayMs) {
    final total = fadeMs + eventDelayMs;
    final ratio = (200 - total).clamp(0, 200) / 200;
    return ratio.clamp(0.0, 1.0);
  }

  double? _computeCohesionIndex(Object? polish, Object? cohesion) {
    final polishValue = _asDouble(polish);
    final cohesionValue = _asDouble(cohesion);
    if (polishValue == null || cohesionValue == null) return null;
    final diff = (polishValue - cohesionValue).abs();
    final ratio = (1 - (diff / 0.1)).clamp(0.0, 1.0);
    return ratio;
  }

  String _buildTextSummary({
    required double latencyIndex,
    required double cohesionIndex,
    required double visualInteractionIndex,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('VISUAL INTERACTION QA SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Interaction latency score: ${latencyIndex.toStringAsFixed(4)}')
      ..writeln('Cohesion score: ${cohesionIndex.toStringAsFixed(4)}')
      ..writeln(
        'Visual Interaction Index: ${visualInteractionIndex.toStringAsFixed(4)}',
      )
      ..writeln('Threshold: ${_threshold.toStringAsFixed(2)}')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double latencyIndex,
    required double cohesionIndex,
    required double visualInteractionIndex,
    required String verdict,
  }) => {
    'generated_at': DateTime.now().toIso8601String(),
    'latency_index': latencyIndex,
    'cohesion_index': cohesionIndex,
    'visual_interaction_index': visualInteractionIndex,
    'threshhold': _threshold,
    'verdict': verdict,
  };

  Future<void> _appendTelemetry(
    double latencyIndex,
    double cohesionIndex,
    double visualInteractionIndex,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'visual_interaction_qa_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'latency_index': latencyIndex,
      'cohesion_index': cohesionIndex,
      'visual_interaction_index': visualInteractionIndex,
      'verdict': verdict,
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
