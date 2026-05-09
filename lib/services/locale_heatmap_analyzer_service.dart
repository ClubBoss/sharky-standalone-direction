import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/pseudo_localization_service.dart';

class LocaleHeatmapBundle {
  LocaleHeatmapBundle({
    required this.avgLengthRatio,
    required this.maxLengthRatio,
    required this.riskDensity,
    required this.highRiskEntries,
    required this.safeEntries,
    required this.timestamp,
  });

  final double avgLengthRatio;
  final double maxLengthRatio;
  final double riskDensity;
  final List<PseudoLocalizedEntry> highRiskEntries;
  final List<PseudoLocalizedEntry> safeEntries;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'avg_length_ratio': avgLengthRatio,
    'max_length_ratio': maxLengthRatio,
    'risk_density': riskDensity,
    'high_risk_entries': highRiskEntries
        .map((entry) => entry.toJson())
        .toList(),
    'safe_entries': safeEntries.map((entry) => entry.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };
}

class LocaleHeatmapAnalyzerService {
  static const _inputPath = 'release/_reports/pseudo_localization.json';

  const LocaleHeatmapAnalyzerService();

  Future<LocaleHeatmapBundle> run() async {
    final raw = await _loadJson(_inputPath);
    final pseudoEntries = _extractEntries(raw);

    if (pseudoEntries.isEmpty) {
      return LocaleHeatmapBundle(
        avgLengthRatio: 0,
        maxLengthRatio: 0,
        riskDensity: 0,
        highRiskEntries: const [],
        safeEntries: const [],
        timestamp: DateTime.now().toUtc(),
      );
    }

    var sumRatio = 0.0;
    var maxRatio = 0.0;
    final highRiskEntries = <PseudoLocalizedEntry>[];
    final safeEntries = <PseudoLocalizedEntry>[];

    for (final entry in pseudoEntries) {
      final ratio = entry.lengthRatio;
      sumRatio += ratio;
      if (ratio > maxRatio) {
        maxRatio = ratio;
      }
      if (ratio > 1.35) {
        highRiskEntries.add(entry);
      }
      if (ratio < 1.1) {
        safeEntries.add(entry);
      }
    }

    final avgRatio = sumRatio / pseudoEntries.length;
    final riskDensity = pseudoEntries.isEmpty
        ? 0.0
        : highRiskEntries.length / pseudoEntries.length;

    return LocaleHeatmapBundle(
      avgLengthRatio: avgRatio,
      maxLengthRatio: maxRatio,
      riskDensity: riskDensity,
      highRiskEntries: highRiskEntries,
      safeEntries: safeEntries,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw LocaleHeatmapAnalyzerException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw LocaleHeatmapAnalyzerException('Empty $path');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw LocaleHeatmapAnalyzerException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  List<PseudoLocalizedEntry> _extractEntries(Map<String, Object?> raw) {
    final entriesValue = raw['pseudo_entries'];
    if (entriesValue is! List<Object?>) {
      return const [];
    }
    final entries = <PseudoLocalizedEntry>[];
    for (final candidate in entriesValue) {
      if (candidate is Map<String, Object?>) {
        final key = candidate['key'];
        final source = candidate['source_en'];
        final pseudo = candidate['pseudo_ru'];
        final ratioValue = candidate['length_ratio'];
        final ratio = ratioValue is num ? ratioValue.toDouble() : null;
        if (key is String &&
            source is String &&
            pseudo is String &&
            ratio != null) {
          entries.add(
            PseudoLocalizedEntry(
              key: key,
              sourceEn: source,
              pseudoRu: pseudo,
              lengthRatio: ratio,
            ),
          );
        }
      }
    }
    return entries;
  }
}

class LocaleHeatmapAnalyzerException implements Exception {
  final String message;

  LocaleHeatmapAnalyzerException(this.message);

  @override
  String toString() => 'LocaleHeatmapAnalyzerException: $message';
}
