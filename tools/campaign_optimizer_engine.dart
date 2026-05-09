import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _retentionPath = '$_reportsDir/retention_insight_summary.json';
const String _marketingPath = '$_reportsDir/marketing_onboarding_summary.json';
const String _aiSummaryPath = '$_reportsDir/ai_personalization_summary.txt';
const String _summaryTextPath = '$_reportsDir/campaign_optimizer_summary.txt';
const String _summaryJsonPath = '$_reportsDir/campaign_optimizer_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _minGlobalEv = 5.0;

Future<void> main(List<String> args) async {
  final engine = CampaignOptimizerEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class CampaignOptimizerEngine {
  Future<bool> run() async {
    final retention = await _readJson(_retentionPath);
    final marketing = await _readJson(_marketingPath);
    final campaigns = await _parseCampaigns();

    final conversionActual =
        (marketing['conversion_index'] as num?)?.toDouble() ?? 0;
    final retentionScore = (retention['retention'] as num?)?.toDouble() ?? 0;
    final coverage =
        (retention['telemetry_coverage'] as num?)?.toDouble() ?? 100;

    double totalEv = 0;
    final optimized = <CampaignAdjustment>[];

    for (final campaign in campaigns) {
      final deltaConversion = conversionActual - campaign.forecast;
      final deltaRetention = retentionScore - campaign.retentionBaseline;
      final uplift = (deltaConversion + deltaRetention) / 2;
      final shouldIncrease = deltaConversion > 0 && deltaRetention > 0;
      final currentWeight = campaign.weight;
      final newWeight = shouldIncrease
          ? (currentWeight * 1.05).clamp(0.8, 1.2).toDouble()
          : (currentWeight * 0.95).clamp(0.8, 1.2).toDouble();
      optimized.add(
        CampaignAdjustment(
          name: campaign.name,
          forecast: campaign.forecast,
          weight: newWeight,
          deltaConversion: deltaConversion,
          deltaRetention: deltaRetention,
          evUplift: uplift,
        ),
      );
      totalEv += uplift;
    }

    final globalEv = campaigns.isEmpty ? 0.0 : totalEv / campaigns.length;
    final pass = globalEv >= _minGlobalEv;

    final summaryText = _buildTextSummary(
      conversion: conversionActual,
      retention: retentionScore,
      coverage: coverage,
      adjustments: optimized,
      globalEv: globalEv,
      pass: pass,
    );
    final summaryJson = _buildJsonSummary(
      conversion: conversionActual,
      retention: retentionScore,
      coverage: coverage,
      adjustments: optimized,
      globalEv: globalEv,
      pass: pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(globalEv, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Campaign optimizer global EV uplift ${globalEv.toStringAsFixed(2)} below 5%.',
      );
    }

    return pass;
  }

  Future<Map<String, dynamic>> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return const {};
    try {
      final contents = await file.readAsString();
      final decoded = json.decode(contents);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return const {};
    }
    return const {};
  }

  Future<List<_Campaign>> _parseCampaigns() async {
    final file = File(_aiSummaryPath);
    if (!await file.exists()) return const [];
    final campaigns = <_Campaign>[];
    final lines = await file.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      final match = RegExp(
        r'- Cluster .*?"([^"]+)" .*?sessions=([0-9.]+).*?engagement=([0-9.]+)',
      ).firstMatch(trimmed);
      if (match != null) {
        final name = match.group(1) ?? 'unknown';
        final forecast = double.tryParse(match.group(2) ?? '') ?? 30;
        final retentionBase = double.tryParse(match.group(3) ?? '') ?? 30;
        campaigns.add(
          _Campaign(
            name: name,
            forecast: forecast,
            retentionBaseline: retentionBase,
            weight: 1.0,
          ),
        );
      }
    }
    return campaigns;
  }

  String _buildTextSummary({
    required double conversion,
    required double retention,
    required double coverage,
    required List<CampaignAdjustment> adjustments,
    required double globalEv,
    required bool pass,
  }) {
    final buffer = StringBuffer()
      ..writeln('CAMPAIGN OPTIMIZER SUMMARY')
      ..writeln('==========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Actual conversion: ${conversion.toStringAsFixed(2)}%')
      ..writeln('Retention score: ${retention.toStringAsFixed(2)}%')
      ..writeln('Telemetry coverage: ${coverage.toStringAsFixed(2)}%')
      ..writeln('Global EV uplift: ${globalEv.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minGlobalEv.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Campaign adjustments:');
    if (adjustments.isEmpty) {
      buffer.writeln('  (none detected)');
    } else {
      for (final adj in adjustments) {
        buffer.writeln(
          '  - ${adj.name}: weight ${adj.weight.toStringAsFixed(3)}, '
          'Δconv ${adj.deltaConversion.toStringAsFixed(2)}%, '
          'Δret ${adj.deltaRetention.toStringAsFixed(2)}%, '
          'EV ${adj.evUplift.toStringAsFixed(2)}%',
        );
      }
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required double conversion,
    required double retention,
    required double coverage,
    required List<CampaignAdjustment> adjustments,
    required double globalEv,
    required bool pass,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'conversion_actual': conversion,
      'retention_score': retention,
      'telemetry_coverage': coverage,
      'global_ev_uplift': globalEv,
      'threshold': _minGlobalEv,
      'campaigns': adjustments
          .map(
            (adj) => {
              'name': adj.name,
              'weight': adj.weight,
              'delta_conversion': adj.deltaConversion,
              'delta_retention': adj.deltaRetention,
              'ev_uplift': adj.evUplift,
            },
          )
          .toList(),
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(double globalEv, bool pass) async {
    final payload = <String, Object?>{
      'event': 'campaign_optimizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'global_ev_uplift': globalEv,
      'threshold': _minGlobalEv,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class CampaignAdjustment {
  CampaignAdjustment({
    required this.name,
    required this.weight,
    required this.forecast,
    required this.deltaConversion,
    required this.deltaRetention,
    required this.evUplift,
  });

  final String name;
  final double weight;
  final double forecast;
  final double deltaConversion;
  final double deltaRetention;
  final double evUplift;
}

class _Campaign {
  _Campaign({
    required this.name,
    required this.forecast,
    required this.retentionBaseline,
    required this.weight,
  });

  final String name;
  final double forecast;
  final double retentionBaseline;
  final double weight;
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
