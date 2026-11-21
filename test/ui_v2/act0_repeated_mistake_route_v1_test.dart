import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_pattern_coaching_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_authored_repair_goal_fixture_v1.dart';
import '../support/act0_shell_presentation_finders_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
final _now = DateTime.utc(2026, 11, 19, 12);
final _first = Act0AuthoredRepairGoalFixtureV1.noBet(occurrenceId: 'first');
final _second = Act0AuthoredRepairGoalFixtureV1.noBet(occurrenceId: 'second');
const _repeatedCopy =
    'This mistake came up more than once when you answered without help.';

Act0LearningEvidenceRecordV1 _with(
  Act0LearningEvidenceRecordV1 record,
  Map<String, Object?> fields,
) => Act0LearningEvidenceRecordV1.tryParse({...record.toPayload(), ...fields})!;

Act0LearningEvidenceRecordV1 get _miss =>
    act0AuthoredRepairFixtureSourceV1(_first.intent);

Act0LearningEvidenceRecordV1 get _repeat =>
    _with(act0AuthoredRepairFixtureSourceV1(_second.intent, order: 2), {
      'sessionId': 'later-session',
      'recordedAtUtc': _now.subtract(const Duration(days: 1)).toIso8601String(),
      'reviewKind': 'exactReplay',
    });

Iterable<Act0ReviewPatternCoachingPatternV1> _patterns(
  List<Act0LearningEvidenceRecordV1> records, {
  DateTime? nowUtc,
}) => Act0ReviewPatternCoachingProjectionV1.fromSources(
  learningEvidenceHistory: Act0LearningEvidenceHistoryV1(records: records),
  nowUtc: nowUtc ?? _now,
).patterns.where((pattern) => pattern.isRepeatedIndependentMiss);

void main() {
  test('only current independent repeats support the same mistake', () {
    expect(_patterns([_miss, _repeat]).single.sourceTaskIds, [
      _second.intent.sourceTaskId,
    ]);
    expect(
      _patterns([_miss, _repeat]).single.errorType,
      _second.intent.errorType,
    );
    for (final change in <Map<String, Object?>>[
      {'assistanceKind': 'quickHint'},
      {'assistanceKind': 'legacyUnknown'},
      {'reviewKind': 'immediateRepair'},
      {'reviewKind': 'alternateSameSignal'},
      {'sessionId': _miss.sessionId},
      {'authoredSourceFingerprint': 'old-version'},
      {'errorType': 'different_error'},
      {'recordedAtUtc': _now.add(const Duration(hours: 1)).toIso8601String()},
      {
        'recordedAtUtc': _miss.recordedAtUtc!
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
      },
    ]) {
      expect(
        _patterns([_miss, _with(_repeat, change)]),
        isEmpty,
        reason: '$change',
      );
    }
    expect(_patterns([_miss, _miss]), isEmpty);
    expect(
      _patterns([
        _miss,
        _repeat,
      ], nowUtc: _repeat.recordedAtUtc!.subtract(const Duration(seconds: 1))),
      isEmpty,
    );
    final correct = _with(_repeat, {
      'recordId': 'later-correct',
      'createdOrder': 3,
      'choiceId': _miss.expectedChoiceId,
      'isCorrect': true,
      'resultKind': 'correct',
      'errorType': 'none',
    });
    expect(_patterns([_miss, _repeat, correct]), isEmpty);
  });

  test('two independently answered spots can be in the same session', () {
    const differentTaskId = 'actions_check_drill';
    final onAnotherHand = _with(_repeat, {
      'taskId': differentTaskId,
      'sourceTaskId': differentTaskId,
      'choiceId': 'pay_small_blind',
      'sessionId': _miss.sessionId,
      'reviewKind': 'initialAssessment',
      'authoredSourceFingerprint': act0AuthoredRepairFixtureFingerprintV1(
        worldId: _miss.worldId,
        lessonId: _miss.lessonId,
        taskId: differentTaskId,
      ),
    });
    expect(
      _patterns([_miss, onAnotherHand]).single.sameFamilyDifferentTasks,
      isTrue,
    );
  });

  testWidgets(
    'Review opens the existing same-skill exercise without earning XP',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final intent = _second.intent;
      final history = Act0LearningEvidenceHistoryV1(records: [_miss, _repeat]);
      final queue = const Act0MultiRepairQueueV1().upsertIntent(
        intent,
        order: 2,
      );
      final saved = jsonEncode(<String, Object?>{
        'schemaVersion': 20,
        'pendingDecisionAssistance': <Object>[],
        'completedTaskIds': <String>[],
        'skippedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'what_poker_is',
        'selectedTaskId': 'what_poker_is_find_hero',
        'earnedXp': 0,
        'openRepairIntents': [intent.toPayload()],
        'multiRepairQueue': queue.toPayload(),
        'multiRepairQueueOrder': 2,
        'learningEvidenceHistory': history.toPayload(),
        'learningEvidenceLineage': history.lineagePayload(),
      });
      SharedPreferences.setMockInitialValues({_progressKey: saved});
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.review,
            showPlacementOnStart: false,
            clock: Act0FixedUtcClockV1(_now),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(_repeatedCopy), findsOneWidget);
      final cta = act0ShellPresentationFinderV1(
        'act0_shell_review_practice_cta',
      );
      await tester.ensureVisible(cta);
      await tester.tap(cta);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        intent.targetTaskId,
      );
      await tester.runAsync(() async {
        await Act0ProgressStoreV1(
          key: _progressKey,
          isValidPayload: (_) => false,
        ).flush();
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        final head = prefs.getString('${_progressKey}_head');
        final actual =
            jsonDecode(
                  head == null
                      ? saved
                      : (jsonDecode(head) as Map)['payload'] as String,
                )
                as Map;
        expect(actual['earnedXp'], 0);
        expect(actual['completedTaskIds'], isEmpty);
      });
    },
  );
}
