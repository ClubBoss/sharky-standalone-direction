import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _semanticJsonPath =
    '$_reportsDir/semantic_drill_enhancer_summary.json';
const String _semanticTextPath =
    '$_reportsDir/semantic_drill_enhancer_summary.txt';
const String _uxResonanceJsonPath = '$_reportsDir/ux_resonance_summary.json';
const String _adaptiveXpJsonPath =
    '$_reportsDir/adaptive_xp_reward_summary.json';
const String _summaryTextPath =
    '$_reportsDir/adaptive_learning_drift_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_learning_drift_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _driftThreshold = 0.1;

Future<void> main(List<String> args) async {
  final monitor = AdaptiveLearningDriftMonitor();
  final ok = await monitor.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveLearningDriftMonitor {
  Future<bool> run() async {
    final semanticScore = await _loadSemanticScore();
    final resonanceScore = await _loadResonanceScore();
    final xpScore = await _loadAdaptiveXpScore();

    if (semanticScore == null || resonanceScore == null || xpScore == null) {
      stderr.writeln('Missing one or more learning telemetry summaries.');
      return false;
    }

    final average = (semanticScore + resonanceScore + xpScore) / 3;
    final drift = (1 - average).clamp(0.0, 1.0);
    final pass = drift <= _driftThreshold;

    final summaryText = _buildTextSummary(
      semanticScore,
      resonanceScore,
      xpScore,
      drift,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      semanticScore,
      resonanceScore,
      xpScore,
      drift,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        semanticScore,
        resonanceScore,
        xpScore,
        drift,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Adaptive learning drift ${(drift * 100).toStringAsFixed(2)}% exceeds '
        '${(_driftThreshold * 100).toStringAsFixed(2)}%.',
      );
    }

    return pass;
  }

  Future<double?> _loadSemanticScore() async => _loadScore(
    jsonPath: _semanticJsonPath,
    jsonKeys: const [
      'average_ev_uplift',
      'avg_ev_uplift',
      'average_ev',
      'avg_ev',
      'semantic_score',
    ],
    textPath: _semanticTextPath,
    textPattern: RegExp(r'Average EV uplift:\s*([0-9.]+)%'),
    percent: true,
  );

  Future<double?> _loadResonanceScore() async => _loadScore(
    jsonPath: _uxResonanceJsonPath,
    jsonKeys: const [
      'ux_resonance_score',
      'resonance_score',
      'emotional_resonance_score',
      'ux_resonance_index',
    ],
    percent: true,
  );

  Future<double?> _loadAdaptiveXpScore() async => _loadScore(
    jsonPath: _adaptiveXpJsonPath,
    jsonKeys: const [
      'xp_multiplier',
      'xp_score',
      'xp_multiplier_score',
      'multiplier',
      'learning_score',
    ],
    percent: false,
  );

  Future<double?> _loadScore({
    required String jsonPath,
    required List<String> jsonKeys,
    bool percent = false,
    String? textPath,
    RegExp? textPattern,
  }) async {
    final jsonData = await _readJson(jsonPath);
    final fromJson = _extractScore(jsonData, jsonKeys, percent: percent);
    if (fromJson != null) {
      return fromJson;
    }
    if (textPath != null && textPattern != null) {
      final textValue = await _readTextMatch(textPath, textPattern);
      if (textValue != null) {
        return (percent ? (textValue / 100) : textValue)
            .clamp(0.0, 1.0)
            .toDouble();
      }
    }
    return null;
  }

  String _buildTextSummary(
    double semanticScore,
    double resonanceScore,
    double xpScore,
    double drift,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE LEARNING DRIFT SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Semantic drill score: ${pct(semanticScore)}')
      ..writeln('UX resonance score: ${pct(resonanceScore)}')
      ..writeln('Adaptive XP score: ${pct(xpScore)}')
      ..writeln('Drift: ${pct(drift)}')
      ..writeln('Threshold: ${(_driftThreshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double semanticScore,
    double resonanceScore,
    double xpScore,
    double drift,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'semantic_drill_score': semanticScore,
    'ux_resonance_score': resonanceScore,
    'adaptive_xp_score': xpScore,
    'adaptive_drift': drift,
    'threshold': _driftThreshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double semanticScore,
    double resonanceScore,
    double xpScore,
    double drift,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_learning_drift_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'semantic_drill_score': semanticScore,
      'ux_resonance_score': resonanceScore,
      'adaptive_xp_score': xpScore,
      'adaptive_drift': drift,
      'threshold': _driftThreshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _extractScore(
  Map<String, Object?>? data,
  List<String> keys, {
  required bool percent,
}) {
  if (data == null) return null;
  for (final key in keys) {
    if (!data.containsKey(key)) continue;
    final candidate = _normalizeScore(data[key], percent: percent);
    if (candidate != null) return candidate;
  }
  return null;
}

double? _normalizeScore(Object? raw, {required bool percent}) {
  final value = _asDouble(raw);
  if (value == null) return null;
  if (percent) {
    return (value / 100).clamp(0.0, 1.0).toDouble();
  }
  if (value > 2) {
    final percentValue = (value / 100).clamp(0.0, 1.0).toDouble();
    if (percentValue > 0) return percentValue;
  }
  return value.clamp(0.0, 1.0).toDouble();
}

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

Future<Map<String, Object?>?> _readJson(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final decoded = json.decode(await file.readAsString());
    if (decoded is Map<String, Object?>) return decoded;
  } catch (_) {}
  return null;
}

Future<double?> _readTextMatch(String path, RegExp pattern) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final contents = await file.readAsString();
    final match = pattern.firstMatch(contents);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '');
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
