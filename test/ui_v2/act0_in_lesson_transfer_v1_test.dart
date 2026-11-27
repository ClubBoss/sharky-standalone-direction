import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_retry_option_order_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_verified_transfer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w14_skill_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tools/transfer_novelty_check_v1.dart';
import '../../tools/export_transfer_novelty_v1.dart'
    show act0InLessonTransferPairsV1;
import '../support/act0_source_choreography_test_wait_v1.dart';
import '../support/act0_widget_test_theme_v1.dart';

const _source = 'board_texture_basics_w5_dry_board';
const _target = 'board_texture_basics_w5_wet_board';
const _noPair = 'w7_count_winning_rivers';
const _progressKey = 'act0_shell_progress_v1';
final _worlds = Act0ShellStateV1.sample.worlds;

Act0LessonCardV1 _lesson(String id) => _worlds
    .expand((world) => world.lessons)
    .singleWhere(
      (lesson) => lesson.courseTaskList.any((task) => task.taskId == id),
    );

Act0LessonTaskV1 _task(String id) =>
    _lesson(id).courseTaskList.singleWhere((task) => task.taskId == id);

Act0LearningEvidenceRecordV1 _answer(
  String id,
  int order, {
  bool correct = true,
  Act0ReviewKindV1 kind = Act0ReviewKindV1.initialAssessment,
  String signal = 'board_cards',
  String? reviewSource,
}) {
  final lesson = _lesson(reviewSource ?? id);
  final world = _worlds.singleWhere((w) => w.lessons.contains(lesson));
  return Act0LearningEvidenceRecordV1(
    recordId: 'answer_$order',
    createdOrder: order,
    worldId: world.worldId,
    lessonId: lesson.lessonId,
    taskId: id,
    choiceId: correct ? 'correct' : 'wrong',
    expectedChoiceId: 'correct',
    isCorrect: correct,
    errorType: correct ? 'none' : 'miss',
    repairFocusId: signal,
    skillAtomId: 'board_read',
    decisionTimeBucket: 'under_3s',
    resultKind: correct ? 'correct' : 'incorrect',
    reviewKind: kind,
    assistanceKind: Act0DecisionAssistanceV1.none,
    runKind: 'lesson',
    authoredSourceFingerprint:
        act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: world.worldId,
          lessonId: lesson.lessonId,
          taskId: id,
        )!,
  );
}

Act0W14SkillStateV1 _state(List<Act0LearningEvidenceRecordV1> records) {
  final skill = act0SkillsForTaskV1(_lesson(_source).lessonId, _source).first;
  return act0W14SkillStatesV1(
    worlds: _worlds,
    history: Act0LearningEvidenceHistoryV1(records: records),
  ).singleWhere((state) => state.label == skill);
}

Act0LessonRunnerShellV1 _runner(WidgetTester t) =>
    t.widget(find.byType(Act0LessonRunnerShellV1));

Future<void> _tap(WidgetTester t, String key) async {
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  await Scrollable.ensureVisible(t.element(finder), alignment: .5);
  await t.pumpAndSettle();
  await t.tap(finder);
  await t.pump(const Duration(seconds: 1));
  await t.pumpAndSettle();
}

Future<void> _open(WidgetTester t, String source) async {
  final lesson = _lesson(source);
  final world = _worlds.singleWhere((w) => w.lessons.contains(lesson));
  final previous = [
    for (final w in _worlds.takeWhile((w) => w != world)) ...w.lessons,
    ...world.lessons.takeWhile((l) => l != lesson),
  ];
  final completed = [
    for (final l in previous) ...l.courseTaskList,
    ...lesson.courseTaskList.takeWhile((task) => task.taskId != source),
  ];
  SharedPreferences.setMockInitialValues({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _progressKey: jsonEncode({
      'schemaVersion': 20,
      'pendingDecisionAssistance': <Object>[],
      'learningEvidenceHistory': <Object>[],
      'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
          .lineagePayload(),
      'durableRetentionHistory': <Object>[],
      'completedTaskIds': completed.map((task) => task.taskId).toList(),
      'completedLessonIds': previous.map((l) => l.lessonId).toList(),
      'skippedTaskIds': <String>[],
      'earnedXp': completed.fold(0, (sum, task) => sum + task.rewardXp),
      'selectedWorldId': world.worldId,
      'selectedLessonId': lesson.lessonId,
      'selectedTaskId': source,
    }),
  });
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: act0WidgetTestThemeV1,
      home: const Act0ShellPreviewScreenV1(showPlacementOnStart: false),
    ),
  );
  await t.pumpAndSettle();
  await t.runAsync(
    () async => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await t.pumpAndSettle();
  await t.tap(find.text('Learn').last);
  await t.pumpAndSettle();
  await _tap(t, 'act0_shell_current_mission_cta');
  expect(_runner(t).selectedTaskId, source);
}

Future<void> _answerOnScreen(WidgetTester t, {required bool correct}) async {
  final runner = _runner(t).runner;
  await pumpSourceChoreographyToDecisionV1(t, runner.table);
  final option = runner.options.firstWhere(
    (option) => option.isCorrect == correct,
  );
  if (runner.sizingConfig.isEnabled) {
    await _tap(t, 'act0_shell_sizing_preset_${option.id}');
    await _tap(t, 'act0_shell_sizing_confirm_cta');
  } else {
    await _tap(
      t,
      option.seatId == null
          ? 'act0_shell_option_${option.id}'
          : 'act0_shell_seat_tap_${option.seatId}',
    );
  }
}

Future<void> _finishTeaching(WidgetTester t) async {
  for (var i = 0; i < 20; i++) {
    if (_runner(t).runner.activeTeachingStep == null) return;
    await t.pump(const Duration(seconds: 1));
    final key =
        find
            .byKey(const Key('act0_shell_theory_continue_cta'))
            .evaluate()
            .isNotEmpty
        ? 'act0_shell_theory_continue_cta'
        : 'act0_shell_continue_cta';
    await _tap(t, key);
  }
  fail('Teaching did not finish');
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  return (await t.runAsync(() async {
    await Act0ProgressStoreV1(
      key: _progressKey,
      isValidPayload: (_) => false,
    ).flush();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final head = prefs.getString('${_progressKey}_head');
    return jsonDecode(
          head == null
              ? prefs.getString(_progressKey)!
              : (jsonDecode(head) as Map)['payload'] as String,
        )
        as Map<String, dynamic>;
  }))!;
}

void main() {
  test('retry permutation preserves every option object and preferred ID', () {
    final options = _task(_source).runner.options;
    for (var i = 0; i < 50; i++) {
      final shuffled = act0RetryOptionOrderV1(
        options,
        'attempt_$i',
        isPreferred: act0RunnerOptionIsPreferredV1,
      );
      expect(shuffled, unorderedEquals(options));
      expect(
        shuffled,
        act0RetryOptionOrderV1(
          options,
          'attempt_$i',
          isPreferred: act0RunnerOptionIsPreferredV1,
        ),
      );
      expect(
        shuffled.indexWhere(act0RunnerOptionIsPreferredV1),
        isNot(options.indexWhere(act0RunnerOptionIsPreferredV1)),
      );
      expect(
        shuffled.where(act0RunnerOptionIsPreferredV1).first.id,
        options.where(act0RunnerOptionIsPreferredV1).first.id,
      );
    }
  });

  test(
    'verified mapping rejects uncompleted and locked targets, no generic fallback',
    () {
      expect(act0VerifiedTransferTargetV1(_source)?.taskId, _target);
      expect(act0VerifiedTransferTargetV1(_noPair), isNull);
      final world = _worlds.singleWhere((w) => w.worldId == 'world_5');
      final lesson = _lesson(_source);
      final unlocked = world.copyWith(
        isSelectable: true,
        isLocked: false,
        lessons: [lesson.copyWith(isSelectable: true, isLocked: false)],
      );
      expect(act0CompletedTransferTargetV1(_source, [unlocked], {}), isNull);
      expect(
        act0CompletedTransferTargetV1(_source, [unlocked], {_target})?.taskId,
        _target,
      );
      expect(
        act0CompletedTransferTargetV1(
          _source,
          [unlocked.copyWith(isSelectable: false, isLocked: true)],
          {_target},
        ),
        isNull,
      );
    },
  );

  test('B58 exact replay is never a verified transfer', () {
    final exact = act0RepairGapAdjudicationsV1.firstWhere(
      (row) =>
          row.outcome == Act0RepairGapOutcomeV1.intentionalExactReplay &&
          act0VerifiedTransferTargetV1(row.sourceTaskId) == null,
    );
    final snapshot = <String, dynamic>{'id': exact.sourceTaskId};
    expect(classifyTransferPairV2(snapshot, snapshot).exactReplay, isTrue);
    expect(act0VerifiedTransferTargetV1(exact.sourceTaskId), isNull);
  });

  test(
    'same identity does not clear or count; a different verified target does',
    () {
      final miss = _answer(_source, 1, correct: false);
      final exact = _answer(_source, 2, kind: Act0ReviewKindV1.exactReplay);
      final matched = _answer(_source, 3, kind: Act0ReviewKindV1.spacedReview);
      final before = _state([miss, exact, matched]);
      expect(before.independentTasks, 0);
      expect(before.tasksToRevisit, 1);
      final after = _state([miss, exact, matched, _answer(_target, 4)]);
      expect(after.independentTasks, 1);
      expect(after.tasksToRevisit, 0);
    },
  );

  test('Day 7 authored unseen of the same signal can clear a miss', () {
    const source = 'actions_check_drill';
    const unseen = 'spaced_review_check_turn_v1';
    final miss = _answer(source, 1, correct: false, signal: 'no_bet_yet');
    final matched = _answer(
      source,
      2,
      kind: Act0ReviewKindV1.spacedReview,
      signal: 'no_bet_yet',
    );
    final transfer = _answer(
      unseen,
      3,
      kind: Act0ReviewKindV1.unseenTransfer,
      signal: 'no_bet_yet',
      reviewSource: source,
    );
    final skill = act0SkillsForTaskV1(_lesson(source).lessonId, source).first;
    Act0W14SkillStateV1 state(List<Act0LearningEvidenceRecordV1> records) =>
        act0W14SkillStatesV1(
          worlds: _worlds,
          history: Act0LearningEvidenceHistoryV1(records: records),
        ).singleWhere((s) => s.label == skill);
    expect(state([miss, matched]).independentTasks, 0);
    expect(state([miss, matched]).tasksToRevisit, 1);
    expect(state([miss, matched, transfer]).independentTasks, 1);
    expect(state([miss, matched, transfer]).tasksToRevisit, 0);
  });

  test('exported candidate pairs contain no B58 exact replay', () {
    final pairs = act0InLessonTransferPairsV1();
    expect(pairs, isNotEmpty);
    final counts = <int, int>{};
    for (final pair in pairs) {
      final source = Map<String, dynamic>.from(pair['source'] as Map);
      final target = Map<String, dynamic>.from(pair['repeat'] as Map);
      expect(classifyTransferPairV2(source, target).exactReplay, isFalse);
      final world = pair['world'] as int;
      counts.update(world, (n) => n + 1, ifAbsent: () => 1);
    }
    expect(counts[5], greaterThan(0));
    expect(counts[7] ?? 0, 0);
    debugPrint('B152 potential transfer pairs per world: $counts');
  });

  for (final (source, expectedWrap) in [
    (_source, _target),
    (_noPair, _noPair),
  ]) {
    testWidgets('$source: correction then $expectedWrap at wrap-up', (t) async {
      await _open(t, source);
      await _finishTeaching(t);
      final slot = _runner(
        t,
      ).runner.options.indexWhere(act0RunnerOptionIsPreferredV1);
      await _answerOnScreen(t, correct: false);
      await _tap(t, 'act0_shell_feedback_continue_cta');
      expect(_runner(t).selectedTaskId, source);
      expect(
        _runner(t).runner.options.indexWhere(act0RunnerOptionIsPreferredV1),
        isNot(slot),
      );
      await _answerOnScreen(t, correct: true);
      await _tap(t, 'act0_shell_feedback_continue_cta');
      final course = _lesson(source).courseTaskList;
      for (final task
          in course.skipWhile((task) => task.taskId != source).skip(1)) {
        expect(_runner(t).selectedTaskId, task.taskId);
        await _finishTeaching(t);
        if (_runner(t).runner.options.isNotEmpty) {
          await _answerOnScreen(t, correct: true);
          await _tap(t, 'act0_shell_feedback_continue_cta');
        } else {
          final key = [
            'act0_shell_feedback_continue_cta',
            'act0_shell_continue_cta',
            'act0_shell_theory_continue_cta',
          ].firstWhere((key) => find.byKey(Key(key)).evaluate().isNotEmpty);
          await _tap(t, key);
        }
      }
      expect(_runner(t).selectedTaskId, expectedWrap);
      if (source == _source) {
        final before = await _saved(t);
        expect(
          (before['reviewMistakeHistory'] as List).any(
            (row) => row['sourceTaskId'] == source,
          ),
          isTrue,
        );
        await _answerOnScreen(t, correct: true);
        final after = await _saved(t);
        expect(
          (before['openRepairIntents'] as List).any(
            (row) => row['sourceTaskId'] == source,
          ),
          isTrue,
        );
        expect(after['openRepairIntents'], before['openRepairIntents']);
        expect(after['reviewMistakeHistory'], before['reviewMistakeHistory']);
        final history = Act0LearningEvidenceHistoryV1.restore(
          after['learningEvidenceHistory'],
          after['learningEvidenceLineage'],
        )!;
        final extra = history.records.last;
        expect(extra.taskId, _target);
        expect(extra.startedBy, 'lesson_extra_example');
        expect(extra.isIndependentCorrect, isTrue);
        await _tap(t, 'act0_shell_feedback_continue_cta');
        expect(
          find.byKey(const Key('act0_shell_block_summary_continue_cta')),
          findsOneWidget,
        );
      }
    });
  }
}
