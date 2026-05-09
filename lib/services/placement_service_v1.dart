import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'progress_service.dart';

// Append-only order for consumers that rely on enum index stability.
enum PlacementBucketV1 { beginner, intermediate, advanced }

// Weak-area token SSOT (ASCII, deterministic, append-only).
const String kPlacementWeakAreaPositionsV1 = 'positions';
const String kPlacementWeakAreaHandSelectionV1 = 'hand_selection';
const String kPlacementWeakAreaTableBasicsV1 = 'table_basics';
const String kPlacementWeakAreaNoneV1 = 'none';

// Legacy synonyms accepted for backward-compat routing reads.
const String _kPlacementWeakAreaSeatOrderLegacyV1 = 'seat_order';
const String _kPlacementWeakAreaRulesTableBasicsLegacyV1 = 'rules_table_basics';

class PlacementRouteV1 {
  const PlacementRouteV1({
    this.schemaVersion = 1,
    required this.bucket,
    required this.startTargetSessionId,
    required this.repairSessionId,
    required this.reasonCodes,
  });

  final int schemaVersion;
  final PlacementBucketV1 bucket;
  final String startTargetSessionId;
  final String? repairSessionId;
  final List<String> reasonCodes;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'bucket': bucket.name,
    'startTargetSessionId': startTargetSessionId,
    'repairSessionId': repairSessionId,
    'reasonCodes': List<String>.unmodifiable(reasonCodes),
  };

  static PlacementRouteV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final schemaVersion =
        PlacementResultV1._parseInt(raw['schemaVersion']) ?? 0;
    if (schemaVersion != 1) return null;
    final bucketRaw = (raw['bucket'] ?? '').toString().trim();
    final bucket = PlacementResultV1._parseBucket(bucketRaw);
    final startTargetSessionId = (raw['startTargetSessionId'] ?? '')
        .toString()
        .trim();
    final repairRaw = (raw['repairSessionId'] ?? '').toString().trim();
    final reasonCodesRaw = raw['reasonCodes'];
    if (bucket == null ||
        startTargetSessionId.isEmpty ||
        reasonCodesRaw is! List) {
      return null;
    }
    final reasonCodes = reasonCodesRaw
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    return PlacementRouteV1(
      schemaVersion: schemaVersion,
      bucket: bucket,
      startTargetSessionId: startTargetSessionId,
      repairSessionId: repairRaw.isEmpty ? null : repairRaw,
      reasonCodes: List<String>.unmodifiable(reasonCodes),
    );
  }
}

class PlacementResultV1 {
  const PlacementResultV1({
    this.schemaVersion = 1,
    required this.bucket,
    required this.confidence,
    required this.weakAreas,
  });

  final int schemaVersion;
  final PlacementBucketV1 bucket;
  final double confidence;
  final List<String> weakAreas;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'bucket': bucket.name,
    'confidence': confidence,
    'weakAreas': List<String>.unmodifiable(weakAreas),
  };

  static PlacementResultV1? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final schemaVersion = _parseInt(raw['schemaVersion']) ?? 0;
    if (schemaVersion != 1) return null;
    final bucketRaw = (raw['bucket'] ?? '').toString().trim();
    final confidence = _parseDouble(raw['confidence']);
    final weakAreasRaw = raw['weakAreas'];
    if (confidence == null || weakAreasRaw is! List) return null;
    final weakAreas = weakAreasRaw
        .map((entry) => entry.toString().trim())
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
    final bucket = _parseBucket(bucketRaw);
    if (bucket == null) return null;
    return PlacementResultV1(
      schemaVersion: schemaVersion,
      bucket: bucket,
      confidence: confidence.clamp(0.0, 1.0),
      weakAreas: List<String>.unmodifiable(weakAreas),
    );
  }

  static int? _parseInt(Object? raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  static double? _parseDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }

  static PlacementBucketV1? _parseBucket(String raw) {
    switch (raw) {
      case 'beginner':
        return PlacementBucketV1.beginner;
      case 'intermediate':
        return PlacementBucketV1.intermediate;
      case 'advanced':
        return PlacementBucketV1.advanced;
      default:
        return null;
    }
  }
}

class PlacementServiceV1 {
  static const String _placementRunStateKey = 'placement_run_state_v1';
  static const String _placementResultKey = 'placement_result_v1';
  static const String _placementRouteKey = 'placement_route_v1';
  static const String _placementRouteProgressKey =
      'placement_route_progress_v1';
  static const double _advancedDowngradeConfidenceThresholdV1 = 0.70;

  static Future<void> startPlacementV1({required int totalItems}) async {
    final prefs = await SharedPreferences.getInstance();
    final nowMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    await prefs.remove(_placementRouteKey);
    await prefs.remove(_placementRouteProgressKey);
    await prefs.setString(
      _placementRunStateKey,
      jsonEncode(<String, Object>{
        'schemaVersion': 1,
        'startedAtMs': nowMs,
        'totalItems': totalItems.clamp(0, 12),
        'answeredCount': 0,
        'correctCount': 0,
        'decisionMsTotal': 0,
        'wrongCount': 0,
      }),
    );
  }

  static Future<void> recordAnswerV1({
    required bool correct,
    required int decisionMs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final run = _readRunStateV1(prefs.getString(_placementRunStateKey));
    if (run == null) return;
    final next = <String, Object>{
      'schemaVersion': 1,
      'startedAtMs': run.startedAtMs,
      'totalItems': run.totalItems,
      'answeredCount': run.answeredCount + 1,
      'correctCount': run.correctCount + (correct ? 1 : 0),
      'decisionMsTotal': run.decisionMsTotal + decisionMs.clamp(0, 600000),
      'wrongCount': run.wrongCount + (correct ? 0 : 1),
    };
    await prefs.setString(_placementRunStateKey, jsonEncode(next));
  }

  static Future<PlacementResultV1> finishPlacementV1({
    required String skillBand,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final run =
        _readRunStateV1(prefs.getString(_placementRunStateKey)) ??
        const _PlacementRunStateV1(
          startedAtMs: 0,
          totalItems: 0,
          answeredCount: 0,
          correctCount: 0,
          decisionMsTotal: 0,
          wrongCount: 0,
        );
    final nowMs = ProgressService.nowUtc().millisecondsSinceEpoch;
    final answered = run.answeredCount <= 0 ? 1 : run.answeredCount;
    final accuracy = (run.correctCount / answered).clamp(0.0, 1.0);
    final avgDecisionMs = run.decisionMsTotal ~/ answered;
    final speedScore = _speedScoreV1(avgDecisionMs);
    final confidenceRaw = ((accuracy * 0.8) + (speedScore * 0.2)).clamp(
      0.0,
      1.0,
    );
    final confidence = _round3(confidenceRaw);
    final bucket = _resolveBucketV1(
      accuracy: accuracy,
      avgDecisionMs: avgDecisionMs,
      skillBand: skillBand,
    );
    final weakAreas = _resolveWeakAreasV1(
      wrongCount: run.wrongCount,
      avgDecisionMs: avgDecisionMs,
    );
    final result = PlacementResultV1(
      bucket: bucket,
      confidence: confidence,
      weakAreas: weakAreas,
    );
    final durationMs = run.startedAtMs <= 0
        ? 0
        : (nowMs - run.startedAtMs).clamp(0, 600000).toInt();
    final telemetry = <String, Object?>{
      'durationMs': durationMs,
      'correctCount': run.correctCount,
      'totalCount': run.totalItems > 0 ? run.totalItems : run.answeredCount,
    };
    final payload = <String, Object?>{
      ...result.toJson(),
      'telemetry': telemetry,
    };
    await prefs.setString(_placementResultKey, jsonEncode(payload));
    await prefs.remove(_placementRunStateKey);
    return result;
  }

  static Future<PlacementRouteV1> computePlacementRouteV1(
    PlacementResultV1 result,
  ) async {
    final reasonCodes = <String>[];
    var startTargetSessionId = _defaultStartTargetForBucketV1(result.bucket);
    var repairSessionId = _repairSessionForWeakAreasV1(result.weakAreas);
    reasonCodes.add('target_${startTargetSessionId.replaceAll('.', '_')}');

    if (result.bucket == PlacementBucketV1.advanced &&
        result.confidence < _advancedDowngradeConfidenceThresholdV1) {
      startTargetSessionId = 'w3.s01';
      reasonCodes.add('advanced_low_confidence_downgrade');
      reasonCodes.add('target_w3_s01');
    }
    if (repairSessionId != null) {
      reasonCodes.add('repair_${repairSessionId.replaceAll('.', '_')}');
    } else {
      reasonCodes.add('repair_none');
    }

    final fallbackTarget = await _resolveFallForwardStartTargetV1(
      startTargetSessionId,
      reasonCodes,
    );
    startTargetSessionId = fallbackTarget;
    final route = PlacementRouteV1(
      bucket: result.bucket,
      startTargetSessionId: startTargetSessionId,
      repairSessionId: repairSessionId,
      reasonCodes: List<String>.unmodifiable(reasonCodes),
    );
    await _persistPlacementRouteV1(route);
    await _persistPlacementRouteProgressV1(
      repairPending: repairSessionId != null,
      targetPending: true,
    );
    return route;
  }

  static Future<PlacementRouteV1?> getLastRouteV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_placementRouteKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return PlacementRouteV1.tryParse(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> consumeNextPlacementSessionIdV1() async {
    final prefs = await SharedPreferences.getInstance();
    final route = await getLastRouteV1();
    if (route == null) return null;
    final progress = _readPlacementRouteProgressV1(
      prefs.getString(_placementRouteProgressKey),
      route,
    );
    if (progress.repairPending && route.repairSessionId != null) {
      await _persistPlacementRouteProgressV1(
        repairPending: false,
        targetPending: progress.targetPending,
      );
      return route.repairSessionId;
    }
    if (progress.targetPending) {
      await _persistPlacementRouteProgressV1(
        repairPending: progress.repairPending,
        targetPending: false,
      );
      return route.startTargetSessionId;
    }
    return null;
  }

  static Future<PlacementResultV1?> getLastResultV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_placementResultKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return PlacementResultV1.tryParse(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, int>> getLastResultMetricsV1() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_placementResultKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <String, int>{
        'durationMs': 0,
        'correctCount': 0,
        'totalCount': 0,
      };
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const <String, int>{
          'durationMs': 0,
          'correctCount': 0,
          'totalCount': 0,
        };
      }
      final telemetry = decoded['telemetry'];
      if (telemetry is! Map) {
        return const <String, int>{
          'durationMs': 0,
          'correctCount': 0,
          'totalCount': 0,
        };
      }
      return <String, int>{
        'durationMs': _safeInt(telemetry['durationMs']),
        'correctCount': _safeInt(telemetry['correctCount']),
        'totalCount': _safeInt(telemetry['totalCount']),
      };
    } catch (_) {
      return const <String, int>{
        'durationMs': 0,
        'correctCount': 0,
        'totalCount': 0,
      };
    }
  }

  static int _safeInt(Object? raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static double _speedScoreV1(int avgDecisionMs) {
    if (avgDecisionMs <= 1500) return 1.0;
    if (avgDecisionMs <= 3000) return 0.8;
    if (avgDecisionMs <= 5000) return 0.6;
    return 0.4;
  }

  static PlacementBucketV1 _resolveBucketV1({
    required double accuracy,
    required int avgDecisionMs,
    required String skillBand,
  }) {
    if (accuracy >= 0.85 && avgDecisionMs <= 3500) {
      return PlacementBucketV1.advanced;
    }
    if (accuracy >= 0.60) {
      return PlacementBucketV1.intermediate;
    }
    final normalizedBand = skillBand.trim().toLowerCase();
    if (normalizedBand == 'advanced') {
      return PlacementBucketV1.intermediate;
    }
    return PlacementBucketV1.beginner;
  }

  static List<String> _resolveWeakAreasV1({
    required int wrongCount,
    required int avgDecisionMs,
  }) {
    final areas = <String>[];
    if (wrongCount > 0) {
      areas.add(kPlacementWeakAreaPositionsV1);
    }
    if (wrongCount >= 2) {
      areas.add(kPlacementWeakAreaHandSelectionV1);
    }
    if (wrongCount >= 4 || avgDecisionMs > 4500) {
      areas.add(kPlacementWeakAreaTableBasicsV1);
    }
    if (areas.isEmpty) {
      areas.add(kPlacementWeakAreaNoneV1);
    }
    return List<String>.unmodifiable(areas);
  }

  static double _round3(double value) {
    return (value * 1000).round() / 1000;
  }

  static String _defaultStartTargetForBucketV1(PlacementBucketV1 bucket) {
    switch (bucket) {
      case PlacementBucketV1.beginner:
        return 'w1.s01';
      case PlacementBucketV1.intermediate:
        return 'w3.s01';
      case PlacementBucketV1.advanced:
        return 'w5.s01';
    }
  }

  static String? _repairSessionForWeakAreasV1(List<String> weakAreas) {
    final normalized = weakAreas
        .map(_normalizeWeakAreaTokenForRoutingV1)
        .where((area) => area.isNotEmpty)
        .toList(growable: false);
    if (normalized.any((area) => area == kPlacementWeakAreaPositionsV1)) {
      return 'w2.s01';
    }
    if (normalized.any((area) => area == kPlacementWeakAreaHandSelectionV1)) {
      return 'w1.s01';
    }
    if (normalized.any((area) => area == kPlacementWeakAreaTableBasicsV1)) {
      return 'w0.s01';
    }
    return null;
  }

  static String _normalizeWeakAreaTokenForRoutingV1(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (normalized == _kPlacementWeakAreaSeatOrderLegacyV1) {
      return kPlacementWeakAreaPositionsV1;
    }
    if (normalized == _kPlacementWeakAreaRulesTableBasicsLegacyV1) {
      return kPlacementWeakAreaTableBasicsV1;
    }
    return normalized;
  }

  static Future<String> _resolveFallForwardStartTargetV1(
    String startTargetSessionId,
    List<String> reasonCodes,
  ) async {
    final alreadyCompleted = await ProgressService.isModuleCompleted(
      startTargetSessionId,
    );
    if (!alreadyCompleted) {
      return startTargetSessionId;
    }
    final match = RegExp(
      r'^w([0-9])\.s([0-9]{2})$',
    ).firstMatch(startTargetSessionId);
    if (match == null) {
      reasonCodes.add('target_completed_no_fallforward');
      return startTargetSessionId;
    }
    final worldIndex = int.tryParse(match.group(1) ?? '');
    final currentSessionOrdinal = int.tryParse(match.group(2) ?? '');
    if (worldIndex == null || currentSessionOrdinal == null) {
      reasonCodes.add('target_completed_no_fallforward');
      return startTargetSessionId;
    }
    for (
      var sessionOrdinal = currentSessionOrdinal + 1;
      sessionOrdinal <= 10;
      sessionOrdinal++
    ) {
      final candidate =
          'w$worldIndex.s${sessionOrdinal.toString().padLeft(2, '0')}';
      final candidateCompleted = await ProgressService.isModuleCompleted(
        candidate,
      );
      if (!candidateCompleted) {
        reasonCodes.add('target_completed_fallforward');
        reasonCodes.add('target_${candidate.replaceAll('.', '_')}');
        return candidate;
      }
    }
    reasonCodes.add('target_completed_no_fallforward');
    return startTargetSessionId;
  }

  static _PlacementRunStateV1? _readRunStateV1(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final schemaVersion = _safeInt(decoded['schemaVersion']);
      if (schemaVersion != 1) return null;
      return _PlacementRunStateV1(
        startedAtMs: _safeInt(decoded['startedAtMs']),
        totalItems: _safeInt(decoded['totalItems']),
        answeredCount: _safeInt(decoded['answeredCount']),
        correctCount: _safeInt(decoded['correctCount']),
        decisionMsTotal: _safeInt(decoded['decisionMsTotal']),
        wrongCount: _safeInt(decoded['wrongCount']),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _persistPlacementRouteV1(PlacementRouteV1 route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_placementRouteKey, jsonEncode(route.toJson()));
  }

  static Future<void> _persistPlacementRouteProgressV1({
    required bool repairPending,
    required bool targetPending,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _placementRouteProgressKey,
      jsonEncode(<String, Object?>{
        'schemaVersion': 1,
        'repairPending': repairPending,
        'targetPending': targetPending,
      }),
    );
  }

  static _PlacementRouteProgressV1 _readPlacementRouteProgressV1(
    String? raw,
    PlacementRouteV1 route,
  ) {
    if (raw == null || raw.trim().isEmpty) {
      return _PlacementRouteProgressV1(
        repairPending: route.repairSessionId != null,
        targetPending: true,
      );
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return _PlacementRouteProgressV1(
          repairPending: route.repairSessionId != null,
          targetPending: true,
        );
      }
      final schemaVersion = _safeInt(decoded['schemaVersion']);
      if (schemaVersion != 1) {
        return _PlacementRouteProgressV1(
          repairPending: route.repairSessionId != null,
          targetPending: true,
        );
      }
      return _PlacementRouteProgressV1(
        repairPending: decoded['repairPending'] == true,
        targetPending: decoded['targetPending'] == true,
      );
    } catch (_) {
      return _PlacementRouteProgressV1(
        repairPending: route.repairSessionId != null,
        targetPending: true,
      );
    }
  }
}

class _PlacementRunStateV1 {
  const _PlacementRunStateV1({
    required this.startedAtMs,
    required this.totalItems,
    required this.answeredCount,
    required this.correctCount,
    required this.decisionMsTotal,
    required this.wrongCount,
  });

  final int startedAtMs;
  final int totalItems;
  final int answeredCount;
  final int correctCount;
  final int decisionMsTotal;
  final int wrongCount;
}

class _PlacementRouteProgressV1 {
  const _PlacementRouteProgressV1({
    required this.repairPending,
    required this.targetPending,
  });

  final bool repairPending;
  final bool targetPending;
}
