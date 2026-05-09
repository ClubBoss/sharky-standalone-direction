import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

final List<String> _resonanceKeys = <String>[
  'average_resonance',
  'average_resonance_score',
  'global_score',
  'ux_resonance_score',
];
final List<String> _calibrationKeys = <String>[
  'visual_calibration_score',
  'calibration_score',
];

class AdaptiveAestheticFeedbackService {
  const AdaptiveAestheticFeedbackService();

  Future<AdaptiveAestheticFeedbackResult?> evaluate() async {
    final calibrationScore = await _readNormalizedScore(
      '$_reportsDir/visual_calibration_summary.json',
      _calibrationKeys,
      percent: false,
    );
    final resonanceScore = await _readNormalizedScore(
      '$_reportsDir/ux_resonance_summary.json',
      _resonanceKeys,
      percent: true,
    );
    final sessionScore = await _readSessionFeedbackScore();

    if (calibrationScore == null ||
        resonanceScore == null ||
        sessionScore == null) {
      return null;
    }

    return AdaptiveAestheticFeedbackResult(
      calibrationScore: calibrationScore,
      resonanceScore: resonanceScore,
      sessionFeedbackScore: sessionScore,
    );
  }

  Future<double?> _readNormalizedScore(
    String path,
    List<String> keys, {
    required bool percent,
  }) async {
    final jsonData = await _readJson(path);
    if (jsonData == null) return null;
    for (final key in keys) {
      if (!jsonData.containsKey(key)) continue;
      final value = _asDouble(jsonData[key]);
      if (value == null) continue;
      if (percent) {
        return (value / 100).clamp(0.0, 1.0).toDouble();
      }
      return value.clamp(0.0, 1.0).toDouble();
    }
    return null;
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

  Future<double?> _readSessionFeedbackScore() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    final lines = await file.readAsLines();
    for (var i = lines.length - 1; i >= 0; i--) {
      final data = _decodeLine(lines[i]);
      if (data == null) continue;
      if (data['event'] != 'session_replay_snapshot_completed') continue;
      final accuracy = _asDouble(data['accuracy_percent']);
      final ev = _asDouble(data['ev_percent']);
      if (accuracy == null || ev == null) continue;
      final score = ((accuracy / 100) * 0.6) + ((ev / 100) * 0.4);
      return score.clamp(0.0, 1.0).toDouble();
    }
    return null;
  }

  Map<String, Object?>? _decodeLine(String line) {
    if (line.trim().isEmpty) return null;
    try {
      final decoded = json.decode(line);
      if (decoded is Map<String, Object?>) return decoded;
    } catch (_) {}
    return null;
  }
}

class AdaptiveAestheticFeedbackResult {
  AdaptiveAestheticFeedbackResult({
    required this.calibrationScore,
    required this.resonanceScore,
    required this.sessionFeedbackScore,
  });

  final double calibrationScore;
  final double resonanceScore;
  final double sessionFeedbackScore;

  double get aestheticIndex {
    final raw =
        (calibrationScore * 0.5) +
        (resonanceScore * 0.3) +
        (sessionFeedbackScore * 0.2);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
