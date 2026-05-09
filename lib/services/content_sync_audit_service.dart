import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/services/smart_pack_store_service.dart';

const String _reportsDir = 'release/_reports';
const String _adaptiveSummaryPath =
    '$_reportsDir/adaptive_loop_tuner_summary.txt';
const String _skillFusionSummaryPath =
    '$_reportsDir/ai_skill_fusion_summary.json';
const String _smartPackSummaryPath =
    '$_reportsDir/preview_packaging_summary.txt';
const String _personaSummaryPath =
    '$_reportsDir/ai_personalization_summary.txt';

class ContentSyncAuditService {
  Future<ContentSyncAuditResult?> audit() async {
    final adaptive = await _readAdaptiveDrillScore();
    final skillFusion = await _readSkillFusionCoverage();
    final smartPack = await _readSmartPackAlignment();
    final personaSync = await _readPersonaSync();
    if (adaptive == null ||
        skillFusion == null ||
        smartPack == null ||
        personaSync == null) {
      return null;
    }

    final index =
        ((adaptive * 0.4) +
                (skillFusion * 0.3) +
                (smartPack * 0.2) +
                (personaSync * 0.1))
            .clamp(0, 1)
            .toDouble();

    return ContentSyncAuditResult(
      adaptiveScore: adaptive,
      skillFusionCoverage: skillFusion,
      smartPackAlignment: smartPack,
      personaSync: personaSync,
      contentConsistencyIndex: index,
    );
  }

  Future<double?> _readAdaptiveDrillScore() async {
    final file = File(_adaptiveSummaryPath);
    if (!await file.exists()) return null;
    try {
      final contents = await file.readAsString();
      final match = RegExp(
        r'Average EV uplift:\s*([0-9.]+)%\s*\(target\s*([0-9.]+)%\)',
      ).firstMatch(contents);
      if (match == null) return null;
      final value = double.tryParse(match.group(1) ?? '');
      final target = double.tryParse(match.group(2) ?? '');
      if (value == null || target == null || target == 0) return null;
      return (value / target).clamp(0, 1).toDouble();
    } catch (_) {
      return null;
    }
  }

  Future<double?> _readSkillFusionCoverage() async {
    final file = File(_skillFusionSummaryPath);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return null;
      final avg = (decoded['average_fusion'] as num?)?.toDouble() ?? 0;
      return (avg / 100).clamp(0, 1).toDouble();
    } catch (_) {
      return null;
    }
  }

  Future<double?> _readSmartPackAlignment() async {
    final file = File(_smartPackSummaryPath);
    if (await file.exists()) {
      try {
        final contents = await file.readAsString();
        final widgetSamples = _extractTableValue(contents, 'Widget Samples');
        final assetEntries = _extractTableValue(contents, 'Asset Entries');
        final violations = _extractTableValue(contents, 'Visual Violations');

        if (widgetSamples == null &&
            assetEntries == null &&
            violations == null) {
          return null;
        }

        final samplesRatio = _normalizeRatio(
          widgetSamples,
          ideal: 6.0,
          floor: 0.6,
        );
        final assetRatio = _normalizeRatio(
          assetEntries,
          ideal: 4.0,
          floor: 0.5,
        );
        final violationRatio = violations == null
            ? 1.0
            : (1 - (violations / 20000)).clamp(0, 1).toDouble();
        return ((samplesRatio * 0.5) +
                (assetRatio * 0.3) +
                (violationRatio * 0.2))
            .clamp(0, 1)
            .toDouble();
      } catch (_) {
        // fall through to backup
      }
    }

    try {
      final fallback = await SmartPackStoreService().buildStorefront();
      final coverage = fallback.coverageRatio.clamp(0, 1);
      final evRatio = ((fallback.averageEv - 0.9) / 0.3).clamp(0, 1).toDouble();
      return ((coverage * 0.7) + (evRatio * 0.3)).clamp(0, 1).toDouble();
    } catch (_) {
      return null;
    }
  }

  Future<double?> _readPersonaSync() async {
    final file = File(_personaSummaryPath);
    if (!await file.exists()) return null;
    try {
      final contents = await file.readAsString();
      final sampleMatch = RegExp(
        r'Sample size:\s*([0-9.]+)',
      ).firstMatch(contents);
      final clusterMatch = RegExp(
        r'Clusters:\s*([0-9.]+)',
      ).firstMatch(contents);
      if (sampleMatch == null) return null;
      final sample = double.tryParse(sampleMatch.group(1) ?? '0') ?? 0;
      final clusters = double.tryParse(clusterMatch?.group(1) ?? '3') ?? 3;
      final sampleRatio = (sample / 300).clamp(0, 1).toDouble();
      final clusterRatio = (1 - (max(clusters, 1) - 1) * 0.03)
          .clamp(0.8, 1)
          .toDouble();
      return ((sampleRatio * 0.7) + (clusterRatio * 0.3))
          .clamp(0, 1)
          .toDouble();
    } catch (_) {
      return null;
    }
  }

  double _normalizeRatio(
    double? value, {
    required double ideal,
    double floor = 0.0,
  }) {
    if (value == null) return floor;
    return (value / ideal).clamp(floor, 1).toDouble();
  }

  double? _extractTableValue(String contents, String label) {
    final match = RegExp(
      '$label\\s*\\|\\s*([0-9.]+)',
      caseSensitive: false,
    ).firstMatch(contents);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '');
    }
    final fallback = RegExp(
      '$label\\s*[:|]\\s*([0-9.]+)',
      caseSensitive: false,
    ).firstMatch(contents);
    return fallback == null ? null : double.tryParse(fallback.group(1) ?? '');
  }
}

class ContentSyncAuditResult {
  const ContentSyncAuditResult({
    required this.adaptiveScore,
    required this.skillFusionCoverage,
    required this.smartPackAlignment,
    required this.personaSync,
    required this.contentConsistencyIndex,
  });

  final double adaptiveScore;
  final double skillFusionCoverage;
  final double smartPackAlignment;
  final double personaSync;
  final double contentConsistencyIndex;
}
