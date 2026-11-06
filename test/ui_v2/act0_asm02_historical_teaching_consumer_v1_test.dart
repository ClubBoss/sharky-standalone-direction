// Replays actual prior widget saves unchanged; these are not user/native saves.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

const _captureDir = String.fromEnvironment(
  'ASM02_CAPTURED_PAYLOAD_DIR',
  defaultValue: 'test/fixtures/asm02_prior_teaching_v1',
);
const _key = 'act0_shell_progress_v1';
const _captures = [
  'positions_theory__bottom__none',
  'positions_theory__top__none',
  'positions_theory__continue__no_assessment',
  'positions_utg__hj__none',
  'positions_utg__hj__theoryRecall',
  'positions_utg__utg__none',
  'positions_utg__utg__theoryRecall',
];

Act0LearningEvidenceHistoryV1 _history(Map<String, dynamic> payload) =>
    Act0LearningEvidenceHistoryV1.restore(
      payload['learningEvidenceHistory'],
      payload['learningEvidenceLineage'],
    )!;

Map<String, dynamic> _originalPayload(Map fixture) {
  final snapshot = fixture['observation']['durableSnapshot'] as Map;
  final head = jsonDecode(snapshot['headEnvelope'] as String) as Map;
  expect(snapshot['headEnvelope'], snapshot['recoveryEnvelope']);
  // The report wrapper sorted map keys. Its decoded payload is for display;
  // replay the actual protected bytes, preserving sealed anchor key order.
  final payload = jsonDecode(head['payload'] as String) as Map<String, dynamic>;
  expect(payload, snapshot['payload']);
  return payload;
}

void main() {
  for (final capture in _captures) {
    testWidgets('unchanged baseline save $capture retains history and honest You', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      expect(_captureDir, isNotEmpty);
      final file = File('$_captureDir/$capture.json');
      final rawCapture = file.readAsStringSync();
      final fixture = jsonDecode(rawCapture) as Map<String, dynamic>;
      expect(
        fixture['provenance']['source_sha'],
        'd0b202309c7906e4d1a67056cf22dcc1944f8646',
      );
      expect(
        fixture['provenance']['test_sha256'],
        'f1f01a8604314392406bd0c4598d52ed20a996a406ff6e014cc8e4c624927ac1',
      );
      final snapshot = fixture['observation']['durableSnapshot'] as Map;
      final original = _originalPayload(fixture);
      final before = _history(original);
      final isTheory = capture.startsWith('positions_theory');
      final assisted = capture.endsWith('theoryRecall');
      final genuineCorrect = capture == 'positions_utg__utg__none';
      final expectedEligible = !isTheory && !assisted ? 1 : 0;
      final prefsSeed = <String, Object>{
        _key: jsonEncode(original),
        '${_key}_head': snapshot['headEnvelope'] as String,
        '${_key}_recovery': snapshot['recoveryEnvelope'] as String,
      };
      SharedPreferences.setMockInitialValues(prefsSeed);
      final reader = Act0ProgressStoreV1(
        key: _key,
        isValidPayload: (raw) => jsonDecode(raw) is Map,
      );
      final loaded = jsonDecode((await reader.load())!) as Map<String, dynamic>;
      expect(loaded, original);
      final history = _history(loaded);
      final serializedBefore = history.toStorageString();
      final lineageBefore = history.lineagePayload();
      final current = Act0LearningTransferMeasurementV1.fromLearningEvidence(
        history,
      );
      final eligible = current.signals.fold<int>(
        0,
        (total, signal) => total + signal.eligibleEvidenceCount,
      );
      final first = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: history,
      ).seedForId(act0AchievementSeedFirstCorrectReadV1);
      // The fixture may contain a raw independent=true teaching receipt. Keep
      // it intact; current consumers must exclude it without resealing history.
      expect(history.toStorageString(), serializedBefore);
      expect(history.toPayload(), before.toPayload());
      expect(history.lineagePayload(), lineageBefore);
      expect(file.readAsStringSync(), rawCapture);

      final sink = Act0InMemoryTelemetrySinkV1();
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            showPlacementOnStart: false,
            initialTab: Act0ShellTabV1.profile,
            telemetrySink: sink,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await reader.flush();
      final saveStart = sink.events.length;
      final dynamic restoredShell = tester.state(
        find.byType(Act0ShellPreviewScreenV1),
      );
      restoredShell.debugPersistProgressV1();
      await tester.pump();
      await reader.flush();
      await tester.pump();
      final saves = sink.events
          .skip(saveStart)
          .where((event) => event.name == 'progress_persist_result')
          .toList();
      expect(saves, hasLength(1));
      expect(saves.single.fields['operation'], 'save');
      expect(saves.single.fields['outcome'], 'acknowledged');
      final legacy = find.byType(Act0ProfileShellV1);
      final academy = find.byType(Act0AcademyYouLeafV1);
      expect(legacy.evaluate().length + academy.evaluate().length, 1);
      final moments = legacy.evaluate().isNotEmpty
          ? tester
                .widget<Act0ProfileShellV1>(legacy)
                .achievementSeedConsumer
                .moments
          : tester.widget<Act0AcademyYouLeafV1>(academy).input.earnedMoments;
      final visibleFirst = moments.any(
        (moment) => moment.seedId == act0AchievementSeedFirstCorrectReadV1,
      );
      final persisted =
          jsonDecode((await reader.load())!) as Map<String, dynamic>;
      for (final field in [
        'learningEvidenceHistory',
        'learningEvidenceLineage',
        'completedTaskIds',
        'completedLessonIds',
        'earnedXp',
        'openRepairIntents',
        'multiRepairQueue',
        'retentionMemory',
      ]) {
        expect(persisted[field], original[field], reason: field);
      }
      debugPrint(
        'ASM02_HISTORICAL_REPLAY ${jsonEncode({'capture': capture, 'rawRecords': history.records.length, 'eligible': eligible, 'firstEarned': first.earned, 'youFirstVisible': visibleFirst, 'rawHistoryAndProgressPreserved': true})}',
      );
      // Contract checks come last so baseline RED retains all compatibility data.
      if (isTheory) {
        for (final record in history.records) {
          expect(act0CurrentAuthoredSourceProofV1(record), isNull);
        }
      }
      expect(eligible, expectedEligible);
      expect(first.earned, genuineCorrect);
      expect(visibleFirst, genuineCorrect);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await reader.flush();
    });
  }

  test(
    'synthetic mixed chronology ignores teaching without blocking real proof',
    () {
      Act0LearningEvidenceRecordV1 captured(String name) {
        final fixture =
            jsonDecode(File('$_captureDir/$name.json').readAsStringSync())
                as Map;
        return _history(_originalPayload(fixture)).records.single;
      }

      final teaching = captured('positions_theory__bottom__none');
      final genuine = captured('positions_utg__utg__none');
      final mixed = Act0LearningEvidenceHistoryV1(
        records: [
          for (var order = 1; order <= 6; order++)
            Act0LearningEvidenceRecordV1.tryParse(
              (order == 3 ? teaching : genuine).toPayload()
                ..['recordId'] = 'synthetic_mixed|$order'
                ..['createdOrder'] = order
                ..['recordedAtUtc'] = DateTime.utc(
                  2026,
                  11,
                  5,
                  14,
                  order,
                ).toIso8601String(),
            )!,
        ],
      );
      final original = mixed.toStorageString();
      final complete = act0CompleteCurrentAuthoredEvidenceV1(mixed);
      expect(complete.records, hasLength(5));
      final measurement =
          Act0LearningTransferMeasurementV1.fromLearningEvidence(
            mixed,
            nowUtc: DateTime.utc(2026, 11, 5, 15),
          );
      expect(measurement.signals.single.eligibleEvidenceCount, 5);
      final first = Act0AchievementSeedProjectionV1.fromSources(
        learningEvidenceHistory: mixed,
      ).seedForId(act0AchievementSeedFirstCorrectReadV1);
      expect(first.earned, isTrue);
      expect(first.earnedSequence, 1);
      expect(first.sourceSummary['completedCorrectDecisions'], 5);
      expect(mixed.toStorageString(), original);
    },
  );

  test(
    'synthetic Placement and legacy nonteaching first moments remain accepted',
    () {
      final fixture =
          jsonDecode(
                File(
                  '$_captureDir/positions_utg__utg__none.json',
                ).readAsStringSync(),
              )
              as Map;
      final genuine = _history(_originalPayload(fixture)).records.single;
      for (final placement in [true, false]) {
        final payload = genuine.toPayload();
        if (placement) {
          payload['runKind'] = act0PlacementAssessmentRunKindV1;
        } else {
          payload['taskId'] = 'historical_non_teaching_unknown_task';
          payload['sourceTaskId'] = 'historical_non_teaching_unknown_task';
        }
        final history = Act0LearningEvidenceHistoryV1(
          records: [Act0LearningEvidenceRecordV1.tryParse(payload)!],
        );
        final first = Act0AchievementSeedProjectionV1.fromSources(
          learningEvidenceHistory: history,
        ).seedForId(act0AchievementSeedFirstCorrectReadV1);
        expect(first.earned, isTrue);
        expect(first.sourceSummary['completedCorrectDecisions'], 1);
      }
    },
  );
}
