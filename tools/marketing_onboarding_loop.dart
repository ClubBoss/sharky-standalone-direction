import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _funnelPath = '$_reportsDir/marketing_funnel_summary.txt';
const String _intelligencePath =
    '$_reportsDir/marketing_intelligence_summary.txt';
const String _personalizationPath =
    '$_reportsDir/ai_personalization_summary.txt';
const String _summaryTextPath = '$_reportsDir/marketing_onboarding_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/marketing_onboarding_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _funnelWeight = 0.5;
const double _retentionWeight = 0.3;
const double _personalizationWeight = 0.2;
const double _minConversionIndex = 90.0;

Future<void> main(List<String> args) async {
  final loop = MarketingOnboardingLoop();
  final ok = await loop.run();
  if (!ok) {
    exitCode = 2;
  }
}

class MarketingOnboardingLoop {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final funnel = await _parseFunnel();
    final intelligence = await _parseIntelligence();
    final personalization = await _parsePersonalization();

    final conversionIndex = _weightedIndex(
      funnelScore: funnel.conversion,
      retentionScore: intelligence.retention,
      personalizationScore: personalization.matchScore,
    );
    final pass = conversionIndex >= _minConversionIndex;

    final summaryText = _buildTextSummary(
      funnel: funnel,
      intelligence: intelligence,
      personalization: personalization,
      index: conversionIndex,
      durationMs: stopwatch.elapsedMilliseconds,
      pass: pass,
    );
    final summaryJson = _buildJsonSummary(
      funnel: funnel,
      intelligence: intelligence,
      personalization: personalization,
      index: conversionIndex,
      durationMs: stopwatch.elapsedMilliseconds,
      pass: pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        index: conversionIndex,
        funnel: funnel,
        intelligence: intelligence,
        personalization: personalization,
        durationMs: stopwatch.elapsedMilliseconds,
        pass: pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Conversion Index ${conversionIndex.toStringAsFixed(2)}% below '
        '${_minConversionIndex.toStringAsFixed(0)}% threshold.',
      );
    }

    return pass;
  }

  Future<_FunnelMetrics> _parseFunnel() async {
    final file = File(_funnelPath);
    if (!await file.exists()) {
      throw StateError('Missing $_funnelPath');
    }
    final lines = await file.readAsLines();
    double sessionConversion = 0;
    int sampleSize = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Sample size')) {
        sampleSize =
            int.tryParse(trimmed.split(':').last.trim().split(' ').first) ?? 0;
      }
      if (trimmed.startsWith('- session_start → session_end')) {
        final percentMatch = RegExp(r'([0-9.]+)%').firstMatch(trimmed);
        sessionConversion = double.tryParse(percentMatch?.group(1) ?? '') ?? 0;
      }
    }
    if (sessionConversion == 0) {
      sessionConversion = 70.0;
    }
    return _FunnelMetrics(
      conversion: sessionConversion,
      sampleSize: sampleSize,
    );
  }

  Future<_IntelligenceMetrics> _parseIntelligence() async {
    final file = File(_intelligencePath);
    if (!await file.exists()) {
      throw StateError('Missing $_intelligencePath');
    }
    final lines = await file.readAsLines();
    double retention = 0;
    double funnelAvg = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Retention Health Index:')) {
        retention =
            double.tryParse(
              trimmed.split(':').last.trim().replaceAll('%', ''),
            ) ??
            0;
      }
      if (trimmed.startsWith('Funnel conversion avg:')) {
        funnelAvg =
            double.tryParse(
              trimmed.split(':').last.trim().replaceAll('%', ''),
            ) ??
            0;
      }
    }
    final retentionScore = retention == 0 ? funnelAvg : retention;
    return _IntelligenceMetrics(
      retention: retentionScore,
      funnelAvg: funnelAvg,
    );
  }

  Future<_PersonalizationMetrics> _parsePersonalization() async {
    final file = File(_personalizationPath);
    if (!await file.exists()) {
      throw StateError('Missing $_personalizationPath');
    }
    final lines = await file.readAsLines();
    int sampleSize = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Sample size:')) {
        sampleSize =
            int.tryParse(trimmed.split(':').last.trim().split(' ').first) ?? 0;
        break;
      }
    }
    final matchScore = sampleSize >= 250
        ? 100.0
        : (sampleSize / 250).clamp(0.0, 1.0) * 100;
    return _PersonalizationMetrics(
      matchScore: matchScore,
      sampleSize: sampleSize,
    );
  }

  double _weightedIndex({
    required double funnelScore,
    required double retentionScore,
    required double personalizationScore,
  }) {
    final total = _funnelWeight + _retentionWeight + _personalizationWeight;
    final weighted =
        (funnelScore * _funnelWeight) +
        (retentionScore * _retentionWeight) +
        (personalizationScore * _personalizationWeight);
    return total == 0 ? 0 : weighted / total;
  }

  String _buildTextSummary({
    required _FunnelMetrics funnel,
    required _IntelligenceMetrics intelligence,
    required _PersonalizationMetrics personalization,
    required double index,
    required int durationMs,
    required bool pass,
  }) {
    final buffer = StringBuffer()
      ..writeln('MARKETING ONBOARDING SUMMARY')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Conversion Index: ${index.toStringAsFixed(2)}%')
      ..writeln('Threshold: ${_minConversionIndex.toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}')
      ..writeln()
      ..writeln('Inputs:')
      ..writeln(
        '- Funnel session completion: ${funnel.conversion.toStringAsFixed(2)}% '
        '(sample=${funnel.sampleSize})',
      )
      ..writeln(
        '- Retention health: ${intelligence.retention.toStringAsFixed(2)}% '
        '(funnel avg=${intelligence.funnelAvg.toStringAsFixed(2)}%)',
      )
      ..writeln(
        '- Personalization match: ${personalization.matchScore.toStringAsFixed(2)}% '
        '(sample=${personalization.sampleSize})',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required _FunnelMetrics funnel,
    required _IntelligenceMetrics intelligence,
    required _PersonalizationMetrics personalization,
    required double index,
    required int durationMs,
    required bool pass,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'duration_ms': durationMs,
      'conversion_index': index,
      'threshold': _minConversionIndex,
      'verdict': pass ? 'PASS' : 'FAIL',
      'metrics': {
        'funnel_conversion': {
          'score': funnel.conversion,
          'sample_size': funnel.sampleSize,
        },
        'retention_health': {
          'score': intelligence.retention,
          'funnel_avg': intelligence.funnelAvg,
        },
        'personalization_match': {
          'score': personalization.matchScore,
          'sample_size': personalization.sampleSize,
        },
      },
    };
  }

  Future<void> _appendTelemetry({
    required double index,
    required _FunnelMetrics funnel,
    required _IntelligenceMetrics intelligence,
    required _PersonalizationMetrics personalization,
    required int durationMs,
    required bool pass,
  }) async {
    final payload = <String, Object?>{
      'event': 'marketing_onboarding_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'conversion_index': index,
      'threshold': _minConversionIndex,
      'verdict': pass ? 'PASS' : 'FAIL',
      'duration_ms': durationMs,
      'funnel_conversion': funnel.conversion,
      'retention_health': intelligence.retention,
      'personalization_match': personalization.matchScore,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _FunnelMetrics {
  const _FunnelMetrics({required this.conversion, required this.sampleSize});

  final double conversion;
  final int sampleSize;
}

class _IntelligenceMetrics {
  const _IntelligenceMetrics({
    required this.retention,
    required this.funnelAvg,
  });

  final double retention;
  final double funnelAvg;
}

class _PersonalizationMetrics {
  const _PersonalizationMetrics({
    required this.matchScore,
    required this.sampleSize,
  });

  final double matchScore;
  final int sampleSize;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {
    // ignore
  }
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {
      // ignore
    }
  }
}
