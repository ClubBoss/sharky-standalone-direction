import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _uxHarmonyPath = '$_reportsDir/ux_harmony_integrator_summary.json';
const String _aestheticCalibrationPath =
    '$_reportsDir/aesthetic_calibration_final_summary.json';
const String _visualCalibrationPath =
    '$_reportsDir/visual_calibration_summary.json';

class SystemUxSnapshotV2Service {
  const SystemUxSnapshotV2Service();

  Future<SystemUxSnapshotV2Result?> summarize() async {
    final harmonyScore = await _readScore(
      _uxHarmonyPath,
      keys: const ['ux_harmony_score', 'ux_harmony_index'],
    );
    final aestheticScore = await _readScore(
      _aestheticCalibrationPath,
      keys: const [
        'final_aesthetic_calibration_index',
        'aesthetic_calibration_score',
      ],
    );
    final visualScore = await _readScore(
      _visualCalibrationPath,
      keys: const ['visual_calibration_score', 'visual_calibration_index'],
    );

    if (harmonyScore == null || aestheticScore == null || visualScore == null) {
      return null;
    }

    return SystemUxSnapshotV2Result(
      harmonyScore: harmonyScore,
      aestheticScore: aestheticScore,
      visualScore: visualScore,
    );
  }

  Future<double?> _readScore(String path, {required List<String> keys}) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      for (final key in keys) {
        if (!decoded.containsKey(key)) continue;
        final raw = _asDouble(decoded[key]);
        if (raw == null) continue;
        final value = raw > 1 ? raw / 100 : raw;
        return value.clamp(0.0, 1.0).toDouble();
      }
    } catch (_) {}
    return null;
  }
}

class SystemUxSnapshotV2Result {
  SystemUxSnapshotV2Result({
    required this.harmonyScore,
    required this.aestheticScore,
    required this.visualScore,
  });

  final double harmonyScore;
  final double aestheticScore;
  final double visualScore;

  double get integrityIndex {
    final raw =
        (harmonyScore * 0.4) + (aestheticScore * 0.35) + (visualScore * 0.25);
    return raw.clamp(0.0, 1.0).toDouble();
  }
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
