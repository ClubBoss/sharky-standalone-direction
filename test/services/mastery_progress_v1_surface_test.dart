import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/mastery_progress_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

Map<String, Object?> _encodeSnapshotV1(MasterySnapshotV1 snapshot) {
  final perWorld = <String, Object?>{};
  final keys = snapshot.perWorld.keys.toList(growable: false)..sort();
  for (final worldId in keys) {
    final item = snapshot.perWorld[worldId]!;
    perWorld[worldId] = <String, Object?>{
      'totalSessions': item.totalSessions,
      'completedSessions': item.completedSessions,
      'rollingAccuracy': item.rollingAccuracy,
      'isEligibleForHighTier': item.isEligibleForHighTier,
    };
  }
  return <String, Object?>{
    'schemaVersion': snapshot.schemaVersion,
    'perWorld': perWorld,
  };
}

Map<String, Object?> _encodeBadgesV1(Map<String, MasteryBadgeV1> badges) {
  final sortedKeys = badges.keys.toList(growable: false)..sort();
  final out = <String, Object?>{};
  for (final key in sortedKeys) {
    out[key] = badges[key]!.name;
  }
  return out;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'mastery read surface is unmodifiable and tier derivation is deterministic',
    () async {
      const rawPayload =
          '{"schema_version":1,"worlds":[{"schemaVersion":1,"worldId":"world2","totalSessions":10,"completedSessions":10,"rollingAccuracy":0.8},{"schemaVersion":1,"worldId":"world3","totalSessions":10,"completedSessions":9,"rollingAccuracy":0.95}]}';
      SharedPreferences.setMockInitialValues(<String, Object>{
        'mastery_progress_v1': rawPayload,
      });

      final prefs = await SharedPreferences.getInstance();
      final rawBefore = prefs.getString('mastery_progress_v1');

      final progress = await ProgressService.getMasteryProgressV1();
      expect(progress.keys.toList()..sort(), <String>['world2', 'world3']);
      expect(progress['world2']?.rollingAccuracy, 0.8);
      expect(
        () => progress['world4'] = const MasteryProgressV1(
          worldId: 'world4',
          totalSessions: 1,
          completedSessions: 1,
          rollingAccuracy: 1.0,
        ),
        throwsUnsupportedError,
      );

      final rawAfterRead = prefs.getString('mastery_progress_v1');
      expect(rawAfterRead, rawBefore);
      expect(jsonDecode(rawAfterRead!), jsonDecode(rawPayload));

      final world2Cfg = await ProgressService.masteryTierConfigForSessionIdV1(
        'w2.s01',
      );
      expect(world2Cfg.hintsOff, isTrue);
      expect(world2Cfg.lives, 1);

      final world3Cfg = await ProgressService.masteryTierConfigForSessionIdV1(
        'w3.s01',
      );
      expect(world3Cfg.hintsOff, isFalse);

      final snapshotA = await ProgressService.getMasterySnapshotV1();
      final snapshotB = await ProgressService.getMasterySnapshotV1();
      expect(snapshotA.schemaVersion, 1);
      expect(snapshotA.perWorld.keys.toList(), <String>['world2', 'world3']);
      expect(snapshotB.perWorld.keys.toList(), <String>['world2', 'world3']);
      expect(
        snapshotA.perWorld['world2']?.isEligibleForHighTier,
        world2Cfg.hintsOff,
      );
      expect(
        snapshotA.perWorld['world3']?.isEligibleForHighTier,
        world3Cfg.hintsOff,
      );
      final snapshotJsonA = jsonEncode(_encodeSnapshotV1(snapshotA));
      final snapshotJsonB = jsonEncode(_encodeSnapshotV1(snapshotB));
      expect(snapshotJsonA, snapshotJsonB);
      final snapshotDecoded = jsonDecode(snapshotJsonA) as Map<String, dynamic>;
      final perWorldDecoded =
          snapshotDecoded['perWorld'] as Map<String, dynamic>;
      expect(perWorldDecoded.keys.toList(), <String>['world2', 'world3']);

      final badges = await ProgressService.getMasteryBadgesV1();
      expect(badges.keys.toList(), snapshotA.perWorld.keys.toList());
      expect(badges['world2'], MasteryBadgeV1.highTier);
      expect(badges['world3'], MasteryBadgeV1.inProgress);
      final badgesAgain = await ProgressService.getMasteryBadgesV1();
      final badgesJsonA = jsonEncode(_encodeBadgesV1(badges));
      final badgesJsonB = jsonEncode(_encodeBadgesV1(badgesAgain));
      expect(badgesJsonA, badgesJsonB);
      final badgesDecoded = jsonDecode(badgesJsonA) as Map<String, dynamic>;
      expect(badgesDecoded.keys.toList(), <String>['world2', 'world3']);

      final bundleA = await ProgressService.getMasteryReadBundleV1();
      final bundleB = await ProgressService.getMasteryReadBundleV1();
      final bundleJsonA = jsonEncode(bundleA.toJson());
      final bundleJsonB = jsonEncode(bundleB.toJson());
      expect(bundleJsonA, bundleJsonB);
      final bundleDecoded = jsonDecode(bundleJsonA) as Map<String, dynamic>;
      final bundleSnapshot = bundleDecoded['snapshot'] as Map<String, dynamic>;
      final bundlePerWorld = bundleSnapshot['perWorld'] as Map<String, dynamic>;
      expect(bundlePerWorld.keys.toList(), <String>['world2', 'world3']);

      final planA = await ProgressService.getGauntletPlanV1();
      final planB = await ProgressService.getGauntletPlanV1();
      expect(planA.recommendedWorldIds, <String>['world3']);
      expect(planA.reasonCodes, <String>['needs_completion']);
      expect(jsonEncode(planA.toJson()), jsonEncode(planB.toJson()));
      for (final code in planA.reasonCodes) {
        final ascii = code.codeUnits.every((u) => u >= 32 && u <= 126);
        expect(ascii, isTrue);
      }

      final emotionA = await ProgressService.getEmotionReadBundleV1();
      final emotionB = await ProgressService.getEmotionReadBundleV1();
      expect(jsonEncode(emotionA.toJson()), jsonEncode(emotionB.toJson()));
      expect(emotionA.schemaVersion, 1);
      expect(emotionA.tag, EmotionTagV1.cautious);
      expect(emotionA.reasons, <String>['in_progress']);
      expect(emotionA.recommendedWorldIds, planA.recommendedWorldIds);
      expect(emotionA.masteryBadges.keys.toList(), <String>[
        'world2',
        'world3',
      ]);
    },
  );

  test(
    'module completion emits deterministic mastery and emotion telemetry once per new completion',
    () async {
      Future<({String mastery, String emotion, String phrase})>
      runCapture() async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final masteryPayloads = <String>[];
        final emotionPayloads = <String>[];
        final phrasePayloads = <String>[];
        Telemetry.overrideLogHandler((name, payload) async {
          if (name == 'mastery_read_bundle_v1' && payload != null) {
            masteryPayloads.add(jsonEncode(payload));
          }
          if (name == 'emotion_tag_v1' && payload != null) {
            emotionPayloads.add(jsonEncode(payload));
          }
          if (name == 'emotion_phrase_shown_v1' && payload != null) {
            phrasePayloads.add(jsonEncode(payload));
          }
        });
        try {
          await ProgressService.markModuleCompleted(
            'w2.s01',
            correctCount: 4,
            totalCount: 5,
          );
          await Future<void>.delayed(Duration.zero);
          await ProgressService.markModuleCompleted(
            'w2.s01',
            correctCount: 5,
            totalCount: 5,
          );
          await Future<void>.delayed(Duration.zero);
          expect(masteryPayloads, hasLength(1));
          expect(emotionPayloads, hasLength(1));
          expect(phrasePayloads, hasLength(1));
          return (
            mastery: masteryPayloads.single,
            emotion: emotionPayloads.single,
            phrase: phrasePayloads.single,
          );
        } finally {
          Telemetry.overrideLogHandler(null);
        }
      }

      final payloadsA = await runCapture();
      final payloadsB = await runCapture();
      expect(payloadsA.mastery, payloadsB.mastery);
      expect(payloadsA.emotion, payloadsB.emotion);
      expect(payloadsA.phrase, payloadsB.phrase);

      final decoded = jsonDecode(payloadsA.mastery) as Map<String, dynamic>;
      expect(decoded['schemaVersion'], 1);
      final perWorld = decoded['perWorld'] as Map<String, dynamic>;
      expect(perWorld.keys.toList(), <String>['world2']);
      final world2 = perWorld['world2'] as Map<String, dynamic>;
      expect(world2['completedSessions'], 1);
      expect(world2['totalSessions'], 10);
      expect(world2['rollingAccuracy'], 0.8);
      expect(world2['badge'], 'inProgress');

      final emotionDecoded =
          jsonDecode(payloadsA.emotion) as Map<String, dynamic>;
      expect(emotionDecoded['schemaVersion'], 1);
      expect(emotionDecoded['tag'], 'urgent');
      expect(emotionDecoded['reasons'], <String>['low_completion_ratio']);
      expect(emotionDecoded['recommendedWorldIds'], <String>['world2']);
      final masteryBadges =
          emotionDecoded['masteryBadges'] as Map<String, dynamic>;
      expect(masteryBadges.keys.toList(), <String>['world2']);
      expect(masteryBadges['world2'], 'inProgress');

      final phraseDecoded =
          jsonDecode(payloadsA.phrase) as Map<String, dynamic>;
      expect(phraseDecoded['schemaVersion'], 1);
      expect(phraseDecoded['context'], 'identity');
      expect(phraseDecoded['tag'], 'urgent');
      expect(phraseDecoded['phraseId'], 'identity_urgent_v1');
      expect(phraseDecoded.keys.toList(growable: false), <String>[
        'schemaVersion',
        'phraseId',
        'context',
        'tag',
        'text',
      ]);
    },
  );
}
