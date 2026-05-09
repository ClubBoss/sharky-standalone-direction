import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryTextPath =
    '$_reportsDir/adaptive_campaign_mixer_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_campaign_mixer_summary.json';

const double _threshold = 0.90;
const double _adjustmentCap = 0.1;

Future<void> main(List<String> args) async {
  final mixer = AdaptiveCampaignMixer();
  final ok = await mixer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveCampaignMixer {
  Future<bool> run() async {
    final marketingData = await _readJson(
      '$_reportsDir/marketing_onboarding_qa_final_summary.json',
    );
    final retentionMarketing = await _readJson(
      '$_reportsDir/retention_marketing_loop_v2_summary.json',
    );
    final persona = await _readLatestPersona();

    if (marketingData == null ||
        retentionMarketing == null ||
        persona == null) {
      stderr.writeln(
        'Missing marketing, retention loop, or persona reaction data.',
      );
      return false;
    }

    final marketingScore = _asDouble(
      marketingData['marketing_onboarding_score'],
    );
    final baseRetention = _asDouble(retentionMarketing['retention_score']);
    final baseConversion = _asDouble(retentionMarketing['conversion_score']);
    final baseReaction = _asDouble(retentionMarketing['reaction_score']);

    if (marketingScore == null ||
        baseRetention == null ||
        baseConversion == null ||
        baseReaction == null) {
      stderr.writeln('One of the required metrics is null.');
      return false;
    }

    final adjustments = <String, double>{
      'retention_campaign': _clampAdjustment(baseRetention),
      'marketing_campaign': _clampAdjustment(baseConversion),
      'persona_campaign': _reactionAdjustment(persona),
    };

    final baseIndex =
        (0.4 * baseRetention) + (0.35 * baseConversion) + (0.25 * baseReaction);
    final meanAdjustment =
        adjustments.values.reduce((a, b) => a + b) / adjustments.length;
    final ami = (baseIndex * (1 + meanAdjustment)).clamp(0.0, 1.0);
    final verdict = ami >= _threshold ? 'PASS' : 'FAIL';

    final summaryText = _buildTextSummary(
      baseRetention: baseRetention,
      baseConversion: baseConversion,
      baseReaction: baseReaction,
      marketingScore: marketingScore,
      adjustments: adjustments,
      ami: ami,
      verdict: verdict,
    );
    final summaryJson = _buildJsonSummary(
      baseRetention: baseRetention,
      baseConversion: baseConversion,
      baseReaction: baseReaction,
      marketingScore: marketingScore,
      adjustments: adjustments,
      ami: ami,
      verdict: verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        marketingScore,
        baseRetention,
        baseConversion,
        baseReaction,
        ami,
        adjustments,
        verdict,
      );
    });

    if (verdict == 'FAIL') {
      stderr.writeln(
        'Adaptive Campaign Mixer AMI ${ami.toStringAsFixed(4)} below threshold.',
      );
    }

    return verdict == 'PASS';
  }

  Future<Map<String, Object?>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      final decoded = json.decode(content);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  Future<_PersonaSnapshot?> _readLatestPersona() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    _PersonaSnapshot? snapshot;
    final lines = await file.readAsLines();
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      try {
        final payload = json.decode(line) as Map<String, Object?>;
        if (payload['event'] == 'persona_reactions_completed') {
          final celebrate = _asDouble(payload['celebrate_count']) ?? 0.0;
          final encourage = _asDouble(payload['encourage_count']) ?? 0.0;
          final thinking = _asDouble(payload['thinking_count']) ?? 0.0;
          snapshot = _PersonaSnapshot(celebrate, encourage, thinking);
          break;
        }
      } catch (_) {
        continue;
      }
    }
    return snapshot;
  }

  double _clampAdjustment(double metric) =>
      ((metric - 0.5) * 2 * _adjustmentCap).clamp(
        -_adjustmentCap,
        _adjustmentCap,
      );

  double _reactionAdjustment(_PersonaSnapshot persona) {
    final total = persona.total;
    if (total == 0) return 0.0;
    final positive = (persona.celebrate + (persona.encourage * 0.75));
    final ratio = (positive / total).clamp(0.0, 1.0);
    return ((ratio - 0.5) * 2 * _adjustmentCap).clamp(
      -_adjustmentCap,
      _adjustmentCap,
    );
  }

  String _buildTextSummary({
    required double baseRetention,
    required double baseConversion,
    required double baseReaction,
    required double marketingScore,
    required Map<String, double> adjustments,
    required double ami,
    required String verdict,
  }) {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE CAMPAIGN MIXER v2 SUMMARY')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Retention score: ${(baseRetention * 100).toStringAsFixed(2)}%')
      ..writeln(
        'Conversion score: ${(baseConversion * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Reaction score: ${(baseReaction * 100).toStringAsFixed(2)}%')
      ..writeln('Campaigns:');
    adjustments.forEach((campaign, adjustment) {
      buffer.writeln(
        '- $campaign adjustment: ${(adjustment * 100).toStringAsFixed(2)}%',
      );
    });
    buffer
      ..writeln(
        'Marketing onboarding: ${(marketingScore * 100).toStringAsFixed(2)}%',
      )
      ..writeln('Adaptive Marketing Index: ${(ami * 100).toStringAsFixed(2)}%')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double baseRetention,
    required double baseConversion,
    required double baseReaction,
    required double marketingScore,
    required Map<String, double> adjustments,
    required double ami,
    required String verdict,
  }) => {
    'generated_at': DateTime.now().toIso8601String(),
    'retention_score': baseRetention,
    'conversion_score': baseConversion,
    'reaction_score': baseReaction,
    'marketing_score': marketingScore,
    'adjustments': adjustments.map(MapEntry.new),
    'adaptive_marketing_index': ami,
    'threshold': _threshold,
    'verdict': verdict,
  };

  Future<void> _appendTelemetry(
    double marketingScore,
    double retentionScore,
    double conversionScore,
    double reactionScore,
    double ami,
    Map<String, double> adjustments,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'adaptive_campaign_mixer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'marketing_score': marketingScore,
      'retention_score': retentionScore,
      'conversion_score': conversionScore,
      'reaction_score': reactionScore,
      'adaptive_marketing_index': ami,
      'adjustments': adjustments,
      'verdict': verdict,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _PersonaSnapshot {
  _PersonaSnapshot(this.celebrate, this.encourage, this.thinking);

  final double celebrate;
  final double encourage;
  final double thinking;

  double get total => celebrate + encourage + thinking;
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
