import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _revenueStabilityPath =
    '$_reportsDir/revenue_stability_summary.json';
const String _profitabilityPath = '$_reportsDir/profitability_ltv_summary.json';
const String _monetizationPath =
    '$_reportsDir/monetization_insight_summary.json';
const String _campaignPath = '$_reportsDir/campaign_optimizer_summary.json';
const String _summaryTextPath = '$_reportsDir/global_monetization_summary.txt';
const String _summaryJsonPath = '$_reportsDir/global_monetization_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.80;
const double _passThreshold = 0.90;

Future<void> main(List<String> args) async {
  final qa = GlobalMonetizationQaFinal();
  final ok = await qa.run();
  if (!ok) {
    exitCode = 2;
  }
}

class GlobalMonetizationQaFinal {
  Future<bool> run() async {
    final revenue = await _readJson(_revenueStabilityPath);
    final profitability = await _readJson(_profitabilityPath);
    final monetization = await _readJson(_monetizationPath);
    if (revenue == null || profitability == null || monetization == null) {
      stderr.writeln('Required monetization summaries missing or malformed.');
      return false;
    }

    final revenueScore =
        (revenue['revenue_stability_index'] as num?)?.toDouble() ?? 0;
    final profitabilityScore =
        (profitability['profitability_ltv_index'] as num?)?.toDouble() ?? 0;
    final monetizationScore =
        (monetization['monetization_insight_score'] as num?)?.toDouble() ?? 0;

    double gmi =
        (revenueScore * 0.4) +
        (profitabilityScore * 0.3) +
        (monetizationScore * 0.3);

    final campaign = await _readJson(_campaignPath);
    if (campaign != null) {
      gmi = (gmi * 1.05).clamp(0, 1);
    } else {
      gmi = gmi.clamp(0, 1);
    }

    final verdict = gmi >= _passThreshold
        ? 'PASS'
        : gmi >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      revenueScore,
      profitabilityScore,
      monetizationScore,
      gmi,
      verdict,
      campaignIncluded: campaign != null,
    );
    final summaryJson = _buildJsonSummary(
      revenueScore,
      profitabilityScore,
      monetizationScore,
      gmi,
      verdict,
      campaignIncluded: campaign != null,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        revenueScore,
        profitabilityScore,
        monetizationScore,
        gmi,
        verdict,
        campaignIncluded: campaign != null,
      );
    });

    if (gmi < _warnThreshold) {
      stderr.writeln(
        'Global Monetization Index ${gmi.toStringAsFixed(3)} below 0.80.',
      );
    } else if (gmi < _passThreshold) {
      stderr.writeln(
        'Global Monetization Index ${gmi.toStringAsFixed(3)} warning range.',
      );
    }

    return gmi >= _passThreshold;
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  String _buildTextSummary(
    double revenue,
    double profitability,
    double monetization,
    double gmi,
    String verdict, {
    required bool campaignIncluded,
  }) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('GLOBAL MONETIZATION SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Revenue Stability: ${pct(revenue)}')
      ..writeln('Profitability & LTV: ${pct(profitability)}')
      ..writeln('Monetization Insight: ${pct(monetization)}')
      ..writeln('Global Monetization Index: ${pct(gmi)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict')
      ..writeln(
        'Campaign optimizer bonus: ${campaignIncluded ? 'applied (+5% cap)' : 'not applied (missing summary)'}',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double revenue,
    double profitability,
    double monetization,
    double gmi,
    String verdict, {
    required bool campaignIncluded,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'revenue_stability_index': revenue,
      'profitability_ltv_index': profitability,
      'monetization_insight_score': monetization,
      'global_monetization_index': gmi,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'verdict': verdict,
      'campaign_bonus_applied': campaignIncluded,
    };
  }

  Future<void> _appendTelemetry(
    double revenue,
    double profitability,
    double monetization,
    double gmi,
    String verdict, {
    required bool campaignIncluded,
  }) async {
    final payload = <String, Object?>{
      'event': 'global_monetization_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'revenue_stability_index': revenue,
      'profitability_ltv_index': profitability,
      'monetization_insight_score': monetization,
      'global_monetization_index': gmi,
      'campaign_bonus_applied': campaignIncluded,
      'verdict': verdict,
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
