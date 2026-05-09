import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;

enum TodayRouterCohortV1 { beginner, intermediate, advanced }

enum TodayRouteKindV1 { gauntlet, practice, leaks }

class TodayProgressStateV1 {
  const TodayProgressStateV1({
    this.leaksEnabled = false,
    this.gauntletPlayedToday = false,
    this.leaksDue = false,
  });

  final bool leaksEnabled;
  final bool gauntletPlayedToday;
  final bool leaksDue;
}

class TodayRouteDecisionV1 {
  const TodayRouteDecisionV1._({
    required this.kind,
    this.gauntletId,
    this.firstStepType,
    this.firstStepRef,
  });

  const TodayRouteDecisionV1.gauntlet({
    required String gauntletId,
    required String firstStepType,
    required String firstStepRef,
  }) : this._(
         kind: TodayRouteKindV1.gauntlet,
         gauntletId: gauntletId,
         firstStepType: firstStepType,
         firstStepRef: firstStepRef,
       );

  const TodayRouteDecisionV1.practice()
    : this._(kind: TodayRouteKindV1.practice);

  const TodayRouteDecisionV1.leaks() : this._(kind: TodayRouteKindV1.leaks);

  final TodayRouteKindV1 kind;
  final String? gauntletId;
  final String? firstStepType;
  final String? firstStepRef;
}

class GauntletStepLaunchTokenV1 {
  const GauntletStepLaunchTokenV1({
    required this.sessionBoundaryId,
    required this.gauntletId,
    required this.stepIndex,
    required this.stepType,
    required this.stepRef,
  });

  final String sessionBoundaryId;
  final String gauntletId;
  final int stepIndex;
  final String stepType;
  final String stepRef;
}

class GauntletStepIsolationCoordinatorV1 {
  int _launchSequence = 0;
  int? _activeStepIndex;
  Map<String, Object?> _stepScratch = <String, Object?>{};

  GauntletStepLaunchTokenV1 beginFreshStepLaunch({
    required String gauntletId,
    required int stepIndex,
    required String stepType,
    required String stepRef,
  }) {
    // Step-local scratch is intentionally reset at every launch boundary.
    _stepScratch = <String, Object?>{};
    _activeStepIndex = stepIndex;
    _launchSequence++;
    return GauntletStepLaunchTokenV1(
      sessionBoundaryId:
          '$gauntletId:step$stepIndex:${_launchSequence.toString().padLeft(4, '0')}',
      gauntletId: gauntletId,
      stepIndex: stepIndex,
      stepType: stepType,
      stepRef: stepRef,
    );
  }

  int? get debugActiveStepIndexForTest => _activeStepIndex;
  String? debugReadStepScratchForTest(String key) =>
      _stepScratch[key] as String?;
  void debugWriteStepScratchForTest(String key, Object? value) {
    _stepScratch[key] = value;
  }
}

class TodayRouterV1 {
  static const String kScheduleAssetPath =
      'content/schedules/daily/v1/schedule.md';

  const TodayRouterV1._();

  static Future<TodayRouteDecisionV1> resolveFromAssets({
    required String utcDayKey,
    required TodayRouterCohortV1 cohort,
    TodayProgressStateV1 progress = const TodayProgressStateV1(),
  }) async {
    try {
      final scheduleRaw = await _loadSnapshotText(kScheduleAssetPath);
      final gauntletId = resolveGauntletIdFromScheduleMarkdown(
        scheduleRaw,
        utcDayKey: utcDayKey,
        cohort: cohort,
      );
      return _resolveLadderFromGauntletId(
        gauntletId: gauntletId,
        progress: progress,
        loadGauntletMarkdown: (id) async =>
            _loadSnapshotText('content/gauntlets/$id/v1/gauntlet.md'),
      );
    } on FlutterError {
      return _resolveFallback(progress);
    } on FileSystemException {
      return _resolveFallback(progress);
    }
  }

  static TodayRouteDecisionV1 resolveDeterministic({
    required String utcDayKey,
    required TodayRouterCohortV1 cohort,
    required String scheduleMarkdown,
    required Map<String, String> gauntletMarkdownById,
    TodayProgressStateV1 progress = const TodayProgressStateV1(),
  }) {
    final gauntletId = resolveGauntletIdFromScheduleMarkdown(
      scheduleMarkdown,
      utcDayKey: utcDayKey,
      cohort: cohort,
    );
    return _resolveLadderFromGauntletIdSync(
      gauntletId: gauntletId,
      progress: progress,
      gauntletMarkdownById: gauntletMarkdownById,
    );
  }

  static Future<TodayRouteDecisionV1> _resolveLadderFromGauntletId({
    required String? gauntletId,
    required TodayProgressStateV1 progress,
    required Future<String> Function(String gauntletId) loadGauntletMarkdown,
  }) async {
    if (!progress.gauntletPlayedToday &&
        gauntletId != null &&
        gauntletId.trim().isNotEmpty) {
      final gauntletRaw = await loadGauntletMarkdown(gauntletId);
      final firstStep = parseFirstStepFromGauntletMarkdown(gauntletRaw);
      if (firstStep != null) {
        return TodayRouteDecisionV1.gauntlet(
          gauntletId: gauntletId,
          firstStepType: firstStep.type,
          firstStepRef: firstStep.ref,
        );
      }
    }
    if (progress.leaksEnabled && progress.leaksDue) {
      return const TodayRouteDecisionV1.leaks();
    }
    return const TodayRouteDecisionV1.practice();
  }

  static TodayRouteDecisionV1 _resolveLadderFromGauntletIdSync({
    required String? gauntletId,
    required TodayProgressStateV1 progress,
    required Map<String, String> gauntletMarkdownById,
  }) {
    if (!progress.gauntletPlayedToday &&
        gauntletId != null &&
        gauntletId.trim().isNotEmpty) {
      final gauntletRaw = gauntletMarkdownById[gauntletId];
      if (gauntletRaw != null) {
        final firstStep = parseFirstStepFromGauntletMarkdown(gauntletRaw);
        if (firstStep != null) {
          return TodayRouteDecisionV1.gauntlet(
            gauntletId: gauntletId,
            firstStepType: firstStep.type,
            firstStepRef: firstStep.ref,
          );
        }
      }
    }
    if (progress.leaksEnabled && progress.leaksDue) {
      return const TodayRouteDecisionV1.leaks();
    }
    return const TodayRouteDecisionV1.practice();
  }

  static TodayRouteDecisionV1 _resolveFallback(TodayProgressStateV1 progress) {
    if (progress.leaksEnabled && progress.leaksDue) {
      return const TodayRouteDecisionV1.leaks();
    }
    return const TodayRouteDecisionV1.practice();
  }

  static Future<String> _loadSnapshotText(String path) async {
    try {
      return await rootBundle.loadString(path);
    } on FlutterError {
      return File(path).readAsStringSync();
    }
  }

  static String? resolveGauntletIdFromScheduleMarkdown(
    String markdown, {
    required String utcDayKey,
    required TodayRouterCohortV1 cohort,
  }) {
    final cohortValue = cohort.name;
    String? exactMatchGauntletId;
    String? latestPastDate;
    String? latestPastGauntletId;
    String? earliestDate;
    String? earliestGauntletId;
    for (final line in markdown.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('@entry ')) continue;
      final kv = _parseDirectiveKv(trimmed.substring(7));
      if (kv == null) continue;
      if (kv['cohort'] != cohortValue) continue;
      final date = (kv['date'] ?? '').trim();
      final gauntletId = (kv['gauntlet_id'] ?? '').trim();
      if (gauntletId.isEmpty) continue;
      if (!_isIsoUtcDayKeyV1(date)) continue;
      if (date == utcDayKey) {
        exactMatchGauntletId = gauntletId;
        break;
      }
      if (date.compareTo(utcDayKey) <= 0 &&
          (latestPastDate == null || date.compareTo(latestPastDate) > 0)) {
        latestPastDate = date;
        latestPastGauntletId = gauntletId;
      }
      if (earliestDate == null || date.compareTo(earliestDate) < 0) {
        earliestDate = date;
        earliestGauntletId = gauntletId;
      }
    }
    return exactMatchGauntletId ?? latestPastGauntletId ?? earliestGauntletId;
  }

  static GauntletStepRefV1? parseFirstStepFromGauntletMarkdown(
    String markdown,
  ) {
    for (final line in markdown.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('@step ')) continue;
      final kv = _parseDirectiveKv(trimmed.substring(6));
      if (kv == null) continue;
      final type = (kv['type'] ?? '').trim();
      final ref = (kv['ref'] ?? '').trim();
      if (!_kAllowedStepTypes.contains(type) || ref.isEmpty) {
        continue;
      }
      return GauntletStepRefV1(type: type, ref: ref);
    }
    return null;
  }

  static List<GauntletStepRefV1> parseAllStepsFromGauntletMarkdown(
    String markdown,
  ) {
    final steps = <GauntletStepRefV1>[];
    for (final line in markdown.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('@step ')) continue;
      final kv = _parseDirectiveKv(trimmed.substring(6));
      if (kv == null) continue;
      final type = (kv['type'] ?? '').trim();
      final ref = (kv['ref'] ?? '').trim();
      if (!_kAllowedStepTypes.contains(type) || ref.isEmpty) {
        continue;
      }
      steps.add(GauntletStepRefV1(type: type, ref: ref));
    }
    return steps;
  }

  static const Set<String> _kAllowedStepTypes = <String>{
    'module',
    'pack',
    'checkpoint',
    'review_queue',
  };

  static Map<String, String>? _parseDirectiveKv(String input) {
    final result = <String, String>{};
    var i = 0;
    while (i < input.length) {
      while (i < input.length && input.codeUnitAt(i) == 32) {
        i++;
      }
      if (i >= input.length) break;
      final keyStart = i;
      while (i < input.length && input.codeUnitAt(i) != 61) {
        if (input.codeUnitAt(i) == 32) return null;
        i++;
      }
      if (i >= input.length) return null;
      final key = input.substring(keyStart, i).trim();
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(key)) return null;
      i++;
      if (i >= input.length) return null;

      String value;
      if (input.codeUnitAt(i) == 34) {
        i++;
        final buffer = StringBuffer();
        var closed = false;
        while (i < input.length) {
          final ch = input.codeUnitAt(i);
          if (ch == 92) {
            if (i + 1 >= input.length) return null;
            final next = input.codeUnitAt(i + 1);
            if (next == 34 || next == 92) {
              buffer.writeCharCode(next);
              i += 2;
              continue;
            }
            return null;
          }
          if (ch == 34) {
            i++;
            closed = true;
            break;
          }
          buffer.writeCharCode(ch);
          i++;
        }
        if (!closed) return null;
        value = buffer.toString();
      } else {
        final valueStart = i;
        while (i < input.length && input.codeUnitAt(i) != 32) {
          i++;
        }
        value = input.substring(valueStart, i).trim();
      }
      result[key] = value;
    }
    return result;
  }

  static bool _isIsoUtcDayKeyV1(String value) {
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
  }
}

class GauntletStepRefV1 {
  const GauntletStepRefV1({required this.type, required this.ref});

  final String type;
  final String ref;
}
