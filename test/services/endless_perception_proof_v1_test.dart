import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';

Map<String, Object?> _encodeMasteryReadBundleV1(MasteryReadBundleV1 bundle) {
  final sortedWorldIds = bundle.badges.keys.toList(growable: false)..sort();
  final badges = <String, Object?>{};
  for (final worldId in sortedWorldIds) {
    badges[worldId] = bundle.badges[worldId]!.name;
  }

  final snapshotWorldIds = bundle.snapshot.perWorld.keys.toList(growable: false)
    ..sort();
  final snapshot = <String, Object?>{};
  for (final worldId in snapshotWorldIds) {
    final world = bundle.snapshot.perWorld[worldId]!;
    snapshot[worldId] = <String, Object?>{
      'totalSessions': world.totalSessions,
      'completedSessions': world.completedSessions,
      'rollingAccuracy': world.rollingAccuracy,
      'isEligibleForHighTier': world.isEligibleForHighTier,
    };
  }

  return <String, Object?>{
    'schemaVersion': bundle.schemaVersion,
    'snapshot': <String, Object?>{
      'schemaVersion': bundle.snapshot.schemaVersion,
      'perWorld': snapshot,
    },
    'badges': badges,
  };
}

Map<String, Object?> _encodeGauntletPlanV1(GauntletPlanV1 plan) =>
    <String, Object?>{
      'schemaVersion': plan.schemaVersion,
      'recommendedWorldIds': plan.recommendedWorldIds,
      'reasonCodes': plan.reasonCodes,
    };

List<Object?> _encodeLeakQueueV1(List<LeakLogEntryV1> queue) =>
    queue.map((e) => e.toJson()).toList(growable: false);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'endless perception chain is deterministic and non-contradictory for mastery/gauntlet/leaks',
    () async {
      const rawPayload =
          '{"schema_version":1,"worlds":[{"schemaVersion":1,"worldId":"world2","totalSessions":10,"completedSessions":10,"rollingAccuracy":0.8},{"schemaVersion":1,"worldId":"world3","totalSessions":10,"completedSessions":9,"rollingAccuracy":0.95}]}';
      SharedPreferences.setMockInitialValues(<String, Object>{
        'mastery_progress_v1': rawPayload,
      });

      final bundleA = await ProgressService.getMasteryReadBundleV1();
      final bundleB = await ProgressService.getMasteryReadBundleV1();
      final bundleJsonA = jsonEncode(_encodeMasteryReadBundleV1(bundleA));
      final bundleJsonB = jsonEncode(_encodeMasteryReadBundleV1(bundleB));
      expect(bundleJsonA, bundleJsonB);
      expect(bundleA.schemaVersion, 1);
      expect(bundleA.snapshot.schemaVersion, 1);
      expect(bundleA.badges.keys.toList(), <String>['world2', 'world3']);

      final planA = await ProgressService.getGauntletPlanV1();
      final planB = await ProgressService.getGauntletPlanV1();
      final planJsonA = jsonEncode(_encodeGauntletPlanV1(planA));
      final planJsonB = jsonEncode(_encodeGauntletPlanV1(planB));
      expect(planJsonA, planJsonB);
      expect(planA.schemaVersion, 1);
      expect(planA.recommendedWorldIds, <String>['world3']);
      expect(planA.reasonCodes, <String>['needs_completion']);
      for (final reason in planA.reasonCodes) {
        expect(reason.codeUnits.every((u) => u >= 32 && u <= 126), isTrue);
      }

      // No contradictions: recommended worlds are always inside mastery badges.
      final masteryWorldSet = bundleA.badges.keys.toSet();
      expect(planA.recommendedWorldIds.every(masteryWorldSet.contains), isTrue);

      // Leaks compatibility proof via pure deterministic compute path (no writes).
      final leakEntries = <LeakLogEntryV1>[
        const LeakLogEntryV1(
          leakId: 'leak:v1:1000:runner:pack:world3:timing',
          utcTsMs: 1000,
          source: 'runner',
          packId: 'pack',
          moduleId: 'world3',
          errorType: 'timing',
        ),
        const LeakLogEntryV1(
          leakId: 'leak:v1:2000:runner:pack:world3:sizing',
          utcTsMs: 2000,
          source: 'runner',
          packId: 'pack',
          moduleId: 'world3',
          errorType: 'sizing',
        ),
      ];
      final resolutions = <LeakResolutionLogEntryV1>[
        const LeakResolutionLogEntryV1(
          leakId: 'leak:v1:1000:runner:pack:world3:timing',
          resolvedUtcTsMs: 3000,
        ),
      ];

      final queueA = ProgressService.computeLeaksQueueForDayV1(
        leakEntries,
        utcDayKey: '2026-01-02',
        dailyCap: ProgressService.leaksDailyCapV1,
        resolutionEntries: resolutions,
      );
      final queueB = ProgressService.computeLeaksQueueForDayV1(
        leakEntries,
        utcDayKey: '2026-01-02',
        dailyCap: ProgressService.leaksDailyCapV1,
        resolutionEntries: resolutions,
      );
      expect(
        jsonEncode(_encodeLeakQueueV1(queueA)),
        jsonEncode(_encodeLeakQueueV1(queueB)),
      );
      expect(queueA.map((e) => e.leakId).toList(), <String>[
        'leak:v1:2000:runner:pack:world3:sizing',
      ]);
    },
  );
}
