// SIMULATED prior-version data/civil dates. No genuine elapsed/native proof.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_last_session_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_queue_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_session_identity_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import '../support/act0_authored_repair_goal_fixture_v1.dart';

const _key = 'act0_shell_progress_v1';
final _store = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);

class _Disk extends SharedPreferencesStorePlatform {
  _Disk(Map<String, Object> values)
    : values = {
        for (final entry in values.entries) 'flutter.${entry.key}': entry.value,
      };
  final Map<String, Object> values;
  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async =>
      throw StateError('No reset after fixture setup');
}

String _civil(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Act0ReviewMistakeHistoryV1 _review(Act0LearningEvidenceRecordV1 source) =>
    Act0ReviewMistakeHistoryV1(
      records: [
        Act0ReviewMistakeRecordV1(
          recordId: 'review-${source.recordId}',
          sourceDecisionId: source.recordId,
          createdOrder: source.createdOrder,
          updatedOrder: source.createdOrder,
          worldId: source.worldId,
          lessonId: source.lessonId,
          decisionTaskId: source.taskId,
          sourceTaskId: source.taskId,
          decisionKind:
              act0AuthoredRepairFixtureTaskV1(
                source.worldId,
                source.lessonId,
                source.taskId,
              ).runner.sizingConfig.isEnabled
              ? 'sizing'
              : 'actionList',
          selectedId: source.choiceId,
          expectedId: source.expectedChoiceId,
          resultKind: source.resultKind,
          errorType: source.errorType,
          skillAtomId: source.skillAtomId,
          repairFocusId: source.repairFocusId,
          runId: source.runId,
          runKind: source.runKind,
          runOrdinal: source.runOrdinal,
          attemptRecordIds: [source.recordId],
          dedupUsesFallback: false,
        ),
      ],
    );

Map<String, Object?> _fixture(String kind, DateTime yesterday) {
  final sessions = const Act0SessionIdentityStateV1().startOrResume(
    startedAtOrder: 1,
    startedWorldId: 'world_1',
    startedLessonId: 'fold_check_call_raise',
  );
  final base = Act0AuthoredRepairGoalFixtureV1.noBet();
  var intent = base.intent;
  final legacy = kind.startsWith('legacy_');
  if (legacy) {
    final ids = switch (kind) {
      'legacy_aa' => (
        'world_2',
        'hand_discipline_buckets',
        'hand_discipline_buckets_premium',
        'medium',
        'fold_check_call_raise',
        'actions_call_drill',
      ),
      'legacy_half' => (
        'world_4',
        'small_half_pot',
        'w4_half_pot_bet',
        'two',
        'cards_ranks_suits',
        'cards_ranks_suits_board_count',
      ),
      _ => (
        'world_1',
        'your_first_hand',
        'your_first_hand_showdown',
        'first_actor',
        'what_poker_is',
        'what_poker_is_table_read_recheck',
      ),
    };
    final task = act0AuthoredRepairFixtureTaskV1(ids.$1, ids.$2, ids.$3);
    final built = buildAct0RepairIntentV1(
      sourceWorldId: ids.$1,
      sourceLessonId: ids.$2,
      sourceTaskId: ids.$3,
      runner: task.runner,
      selectedOption: task.runner.options.singleWhere(
        (option) => option.id == ids.$4,
      ),
      currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
    )!;
    final payload = <String, Object?>{
      ...built.toPayload(),
      'repairOccurrenceId': 'historical-${ids.$3}',
      'targetWorldId': 'world_1',
      'targetLessonId': ids.$5,
      'targetTaskId': ids.$6,
      'mappingType': 'repair',
    };
    for (final key in [
      'goalId',
      'relationId',
      'relationRevision',
      'sourceFingerprint',
      'targetFingerprint',
    ]) {
      payload.remove(key);
    }
    intent = Act0RepairIntentV1.tryParse(payload)!;
  }
  final target = act0AuthoredRepairFixtureTaskV1(
    intent.targetWorldId,
    intent.targetLessonId,
    intent.targetTaskId,
  );
  final correct = target.runner.options.singleWhere(
    (option) => option.isCorrect,
  );
  final outcome = Act0RepairOutcomeV1(
    repairIntent: intent,
    repairOccurrenceId: intent.repairOccurrenceId,
    repairAttemptId: 'actual-target-attempt',
    sourceTaskId: intent.sourceTaskId,
    repairTaskId: intent.targetTaskId,
    repairFocusKey: intent.missedSignalId,
    queueItemId: queueItemIdForAct0RepairIntentV1(intent),
    targetWorldId: intent.targetWorldId,
    targetLessonId: intent.targetLessonId,
    targetTaskId: intent.targetTaskId,
    selectedChoiceId: correct.id,
    correctChoiceId: correct.id,
    isCorrect: true,
    outcomeState: act0RepairOutcomeStateCorrectV1,
    sequence: 3,
    sourceType: 'active_repair_v1',
    sessionId: sessions.session.sessionId,
  );
  final eventDate = kind == 'wrong_date'
      ? DateTime(yesterday.year, yesterday.month, yesterday.day - 1, 12)
      : yesterday;
  Act0LearningEvidenceRecordV1 onDate(Act0LearningEvidenceRecordV1 record) =>
      Act0LearningEvidenceRecordV1.tryParse({
        ...record.toPayload(),
        'recordedAtUtc': eventDate.toUtc().toIso8601String(),
      })!;
  final source = onDate(act0AuthoredRepairFixtureSourceV1(intent));
  final targetRecord = onDate(
    act0AuthoredRepairFixtureAttemptV1(outcome, order: 2),
  );
  final records = <Act0LearningEvidenceRecordV1>[source, targetRecord];
  if (kind == 'later_assisted' || kind == 'ordinary_practice') {
    records.add(
      Act0LearningEvidenceRecordV1.tryParse({
        ...targetRecord.toPayload(),
        'recordId': 'later-target-attempt',
        'createdOrder': 3,
        'runId': 'later-run',
        'runOrdinal': 3,
        'runKind': kind == 'ordinary_practice' ? 'practice' : 'repair',
        'assistanceKind': 'quickHint',
      })!,
    );
  }
  final history = Act0LearningEvidenceHistoryV1(records: records);
  final review = _review(source);
  if (Act0ReviewMistakeHistoryV1.tryParse(review.toPayload())?.records.length !=
      1) {
    throw StateError('Fixture review must survive the public persisted parser');
  }
  final projection = Act0RepairOutcomeProjectionV1(outcomes: [outcome]);
  final receipts = reviewResolutionReceiptHistoryFromSourcesV1(
    reviewMistakeHistory: review,
    activeRepairIntents: [intent],
    repairOutcomeProjection: projection,
    existingReceiptHistory: const Act0ReviewResolutionReceiptHistoryV1(),
    learningEvidenceHistory: history,
    currentFingerprintForIdentity: act0AuthoredRepairFixtureFingerprintV1,
  );
  final ref = 'repair_outcome_v1|${outcome.sequence}|${outcome.queueItemId}';
  final cache = <String, Object>{
    'last_session_repair_focus_id': kind == 'wrong_focus'
        ? 'other-focus'
        : outcome.repairFocusKey,
    'last_session_proof_result': act0LastSessionProofFixLandedV1,
    'last_session_date': _civil(yesterday),
    'last_session_world_id': kind == 'wrong_world'
        ? 'world_2'
        : outcome.targetWorldId,
    if (!legacy && kind != 'missing_ref')
      'last_session_repair_outcome_ref': kind == 'unknown_ref'
          ? 'unknown-outcome'
          : ref,
  };
  final rawOutcome = Map<String, Object?>.of(outcome.toPayload());
  if (legacy) rawOutcome.remove('repairIntent');
  return {
    'schemaVersion': 20,
    'pendingDecisionAssistance': <Object?>[],
    'completedTaskIds': <String>[],
    'completedLessonIds': <String>[],
    'skippedTaskIds': <String>[],
    'selectedWorldId': 'world_1',
    'selectedLessonId': 'what_poker_is',
    'selectedTaskId': 'what_poker_is_intro',
    'earnedXp': 7,
    'learningEvidenceHistory': history.toPayload(),
    'learningEvidenceLineage': history.lineagePayload(),
    'reviewMistakeHistory': review.toPayload(),
    'reviewResolutionReceipts': receipts.toPayload(),
    'repairOutcomeProjection': [rawOutcome],
    'sessionIdentityState': kind == 'wrong_session'
        ? const Act0SessionIdentityStateV1().toPayload()
        : sessions.state.toPayload(),
    'lastSessionLearnerState': cache,
    'multiRepairQueue': Act0MultiRepairQueueV1.fromLegacyOpenRepairIntents(
      legacy ? [intent] : [],
    ).toPayload(),
    'multiRepairQueueOrder': 1,
  };
}

void main() {
  test(
    'legacy cache stays byte-compatible; explicit reference participates in equality',
    () {
      final old = {
        'last_session_repair_focus_id': 'no_bet_yet',
        'last_session_proof_result': 'fix_landed',
        'last_session_date': '2026-11-16',
        'last_session_world_id': 'world_1',
      };
      final parsed = Act0LastSessionLearnerStateV1.tryParse(old)!;
      expect(parsed.toJson(), old);
      final linked = Act0LastSessionLearnerStateV1.tryParse({
        ...old,
        'last_session_repair_outcome_ref': 'actual-ref',
      })!;
      expect(linked, isNot(parsed));
      expect(linked.toJson()['last_session_repair_outcome_ref'], 'actual-ref');
    },
  );
  for (final kind in [
    'legacy_aa',
    'legacy_half',
    'legacy_showdown',
    'valid',
    'missing_ref',
    'unknown_ref',
    'wrong_focus',
    'wrong_world',
    'wrong_date',
    'wrong_session',
    'later_assisted',
    'ordinary_practice',
  ]) {
    testWidgets(
      'SIMULATED Day2 cold restore $kind projects proof without rewriting history',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.runAsync(() => _store.flush());
        final today = DateTime.now();
        final yesterday = DateTime(today.year, today.month, today.day - 1, 12);
        final payload = _fixture(kind, yesterday);
        final preserved = {
          for (final key in [
            'lastSessionLearnerState',
            'repairOutcomeProjection',
            'learningEvidenceHistory',
            'reviewMistakeHistory',
            'earnedXp',
          ])
            key: jsonEncode(payload[key]),
        };
        final prior = SharedPreferencesStorePlatform.instance;
        final disk = _Disk({
          'app_language_code': 'en',
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          _key: jsonEncode(payload),
        });
        SharedPreferences.resetStatic();
        SharedPreferencesStorePlatform.instance = disk;
        final sink = Act0InMemoryTelemetrySinkV1();
        addTearDown(() async {
          try {
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
            await tester.runAsync(() => _store.flush());
          } finally {
            SharedPreferences.resetStatic();
            SharedPreferencesStorePlatform.instance = prior;
          }
        });
        for (var mount = 0; mount < 2; mount++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Act0ShellPreviewScreenV1(
                showPlacementOnStart: false,
                initialTab: Act0ShellTabV1.home,
                telemetrySink: sink,
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() => _store.flush());
          final returns = sink.events
              .where((event) => event.name == 'day2_return')
              .toList();
          expect(returns, hasLength(mount + 1));
          final expected = kind == 'valid' || kind == 'ordinary_practice'
              ? 'fix_landed'
              : 'unconfirmed';
          expect(
            returns.every((event) => event.fields['proof_result'] == expected),
            isTrue,
          );
          String? durable;
          await tester.runAsync(() async {
            durable = await _store.load();
          });
          expect(durable, isNotNull);
          final restored = jsonDecode(durable!) as Map;
          for (final entry in preserved.entries) {
            expect(
              jsonEncode(restored[entry.key]),
              entry.value,
              reason: '${entry.key} stays historical',
            );
          }
          if (kind.startsWith('legacy_')) {
            expect(
              Act0MultiRepairQueueV1.tryParse(
                restored['multiRepairQueue'],
              ).entries,
              hasLength(1),
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          await tester.runAsync(() => _store.flush());
          SharedPreferences.resetStatic();
          expect(
            identical(SharedPreferencesStorePlatform.instance, disk),
            isTrue,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
