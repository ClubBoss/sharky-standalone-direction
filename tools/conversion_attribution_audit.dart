import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _funnelPath = '$_reportsDir/marketing_funnel_summary.txt';
const String _optimizerPath = '$_reportsDir/campaign_optimizer_summary.json';
const String _recoveryPath = '$_reportsDir/engagement_recovery_summary.json';
const String _summaryTextPath =
    '$_reportsDir/conversion_attribution_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/conversion_attribution_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const double _minAccuracy = 90.0;

Future<void> main(List<String> args) async {
  final audit = ConversionAttributionAudit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ConversionAttributionAudit {
  Future<bool> run() async {
    final funnel = await _parseFunnelConversions();
    final optimizer = await _readJson(_optimizerPath);
    final recovery = await _readRecoveryRate();

    final adjustments = optimizer['campaigns'] as List<dynamic>? ?? const [];
    final totalConversion = funnel.values.fold<double>(0, (a, b) => a + b);

    final weights = <String, double>{};
    final actuals = <String, double>{};
    for (final entry in adjustments) {
      if (entry is! Map<String, dynamic>) continue;
      final name = entry['name']?.toString() ?? 'unknown';
      final conversion = (entry['delta_conversion'] as num?)?.toDouble() ?? 0;
      final retention = (entry['delta_retention'] as num?)?.toDouble() ?? 0;
      final recoveryRate = recovery;
      final weight = (conversion * retention * recoveryRate).abs();
      weights[name] = weight;
      actuals[name] = conversion;
    }
    final weightSum = weights.values.fold<double>(0, (a, b) => a + b);
    if (weightSum > 0) {
      weights.updateAll((key, value) => value / weightSum);
    }

    double accuracySum = 0;
    int accuracyCount = 0;
    funnel.forEach((name, actual) {
      final predicted = (weights[name] ?? 0) * totalConversion;
      final accuracy = _ratioAccuracy(predicted, actual);
      accuracySum += accuracy;
      accuracyCount++;
    });
    final accuracy = accuracyCount == 0 ? 0.0 : accuracySum / accuracyCount;
    final pass = accuracy >= _minAccuracy;

    final summaryText = _buildTextSummary(weights, funnel, accuracy, pass);
    final summaryJson = _buildJsonSummary(weights, funnel, accuracy, pass);

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(accuracy, pass);
    });

    if (!pass) {
      stderr.writeln(
        'Conversion attribution accuracy ${accuracy.toStringAsFixed(2)}% below 90%.',
      );
    }

    return pass;
  }

  Future<Map<String, double>> _parseFunnelConversions() async {
    final file = File(_funnelPath);
    if (!await file.exists()) return const {};
    final lines = await file.readAsLines();
    final conversions = <String, double>{};
    for (final line in lines) {
      final match = RegExp(
        r'- ([a-zA-Z0-9_]+) → ([a-zA-Z0-9_]+): ([0-9.]+)% \(([0-9]+)/([0-9]+)\)',
      ).firstMatch(line);
      if (match != null) {
        final name = '${match.group(1)}_${match.group(2)}';
        final rate = double.tryParse(match.group(3) ?? '') ?? 0;
        conversions[name] = rate;
      }
    }
    return conversions;
  }

  Future<Map<String, dynamic>> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return const {};
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return const {};
    }
    return const {};
  }

  Future<double> _readRecoveryRate() async {
    final file = File(_recoveryPath);
    if (!await file.exists()) return 1.0;
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final actions = decoded['actions'];
      if (actions is List && actions.isNotEmpty) {
        final avg =
            actions
                .map((entry) => (entry['potential'] as num?)?.toDouble() ?? 70)
                .reduce((a, b) => a + b) /
            actions.length;
        return (avg / 100).clamp(0.5, 1.5).toDouble();
      }
    } catch (_) {
      return 1.0;
    }
    return 1.0;
  }

  double _ratioAccuracy(double predicted, double actual) {
    if (actual == 0) return predicted == 0 ? 100 : 0;
    final diff = (predicted - actual).abs();
    return (1 - (diff / actual)).clamp(0, 1).toDouble() * 100;
  }

  String _buildTextSummary(
    Map<String, double> weights,
    Map<String, double> actuals,
    double accuracy,
    bool pass,
  ) {
    final buffer = StringBuffer()
      ..writeln('CONVERSION ATTRIBUTION SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Accuracy: ${accuracy.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minAccuracy.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln();
    if (weights.isEmpty) {
      buffer.writeln('No campaign data available.');
    } else {
      buffer.writeln('Attribution weights:');
      weights.forEach((name, weight) {
        buffer.writeln('  - $name: ${weight.toStringAsFixed(3)}');
      });
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    Map<String, double> weights,
    Map<String, double> actuals,
    double accuracy,
    bool pass,
  ) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'accuracy': accuracy,
      'threshold': _minAccuracy,
      'weights': weights,
      'actuals': actuals,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(double accuracy, bool pass) async {
    final payload = <String, Object?>{
      'event': 'conversion_attribution_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'accuracy': accuracy,
      'threshold': _minAccuracy,
      'verdict': pass ? 'PASS' : 'FAIL',
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
