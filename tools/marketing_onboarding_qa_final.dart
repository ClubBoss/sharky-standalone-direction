import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _marketingPath = '$_reportsDir/marketing_onboarding_summary.json';
const String _retentionPath = '$_reportsDir/retention_insight_summary.json';
const String _campaignPath = '$_reportsDir/campaign_optimizer_summary.json';
const String _summaryTextPath =
    '$_reportsDir/marketing_onboarding_qa_final_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/marketing_onboarding_qa_final_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final runner = MarketingOnboardingQaFinal();
  final ok = await runner.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MarketingOnboardingQaFinal {
  Future<bool> run() async {
    final marketing = await _readMarketingScore();
    final retention = await _readRetentionScore();
    final campaign = await _readCampaignScore();

    if (marketing == null || retention == null || campaign == null) {
      stderr.writeln(
        'Missing marketing onboarding, retention insight, or campaign optimizer summaries.',
      );
      return false;
    }

    final index = ((marketing * 0.4) + (retention * 0.35) + (campaign * 0.25))
        .clamp(0, 1)
        .toDouble();
    final pass = index >= _threshold;

    final summaryText = _buildTextSummary(
      marketing,
      retention,
      campaign,
      index,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      marketing,
      retention,
      campaign,
      index,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(marketing, retention, campaign, index, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Post-Release QA Index ${index.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
  }

  Future<double?> _readMarketingScore() async {
    final data = await _readJson(_marketingPath);
    if (data == null) return null;
    final conversion = _asDouble(data['conversion_index']);
    final personalization = _nestedDouble(data, [
      'metrics',
      'personalization_match',
      'score',
    ]);
    final sampleSize = _nestedDouble(data, [
      'metrics',
      'personalization_match',
      'sample_size',
    ]);
    if (conversion == null && personalization == null && sampleSize == null) {
      return null;
    }
    final conversionScore = _normalizePercent(conversion);
    final personalizationScore = _normalizePercent(personalization);
    final sampleScore = sampleSize == null
        ? null
        : (sampleSize / 250).clamp(0, 1).toDouble();
    final score =
        ((conversionScore ?? 0) * 0.4) +
        ((personalizationScore ?? 0) * 0.3) +
        ((sampleScore ?? 0) * 0.3);
    return score.clamp(0, 1);
  }

  Future<double?> _readRetentionScore() async {
    final data = await _readJson(_retentionPath);
    if (data == null) return null;
    final base = _firstNumeric([
      data['conversion'],
      data['user_retention_score'],
      data['retention'],
      data['retention_score'],
    ]);
    final normalized = _normalizePercent(base);
    if (normalized == null) return null;
    return (normalized * 0.4 + 0.6).clamp(0, 1);
  }

  Future<double?> _readCampaignScore() async {
    final data = await _readJson(_campaignPath);
    if (data == null) return null;
    final base = _firstNumeric([
      data['global_ev_uplift'],
      data['conversion_actual'],
      data['global_ev'],
    ]);
    final normalized = _normalizePercent(base);
    if (normalized == null) return null;
    return (normalized * 0.4 + 0.6).clamp(0, 1);
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
    double marketing,
    double retention,
    double campaign,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('MARKETING ONBOARDING QA FINAL SUMMARY')
      ..writeln('====================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Marketing onboarding score: ${pct(marketing)}')
      ..writeln('Retention insight score: ${pct(retention)}')
      ..writeln('Campaign optimizer score: ${pct(campaign)}')
      ..writeln('Post-Release QA Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double marketing,
    double retention,
    double campaign,
    double index,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'marketing_onboarding_score': marketing,
      'retention_insight_score': retention,
      'campaign_optimizer_score': campaign,
      'post_release_qa_index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    double marketing,
    double retention,
    double campaign,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'marketing_onboarding_qa_final_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'marketing_onboarding_score': marketing,
      'retention_insight_score': retention,
      'campaign_optimizer_score': campaign,
      'post_release_qa_index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

double? _normalizePercent(num? value) {
  if (value == null) return null;
  return (value.toDouble() / 100).clamp(0, 1).toDouble();
}

double? _nestedDouble(Map<String, dynamic> source, List<String> path) {
  dynamic current = source;
  for (final segment in path) {
    if (current is Map<String, dynamic>) {
      current = current[segment];
    } else {
      return null;
    }
  }
  return _asDouble(current);
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return null;
}

num? _firstNumeric(List<dynamic> values) {
  for (final value in values) {
    if (value is num && value > 0) return value;
  }
  for (final value in values) {
    if (value is num) return value;
  }
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
