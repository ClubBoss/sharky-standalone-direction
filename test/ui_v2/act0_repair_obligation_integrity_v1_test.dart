import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_practice_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Machine regression only: normal persisted product root, authored sample
// curriculum, public Learn/Practice callbacks and real answer/Continue widgets.
// Mock preferences and widget remounts do not establish native restart evidence.
const _key = 'act0_shell_progress_v1';
const _actionLesson = 'fold_check_call_raise';
const _actionSource = 'actions_legal_context';
const _actionRepair = 'actions_check_drill';
const _rankLesson = 'cards_ranks_suits';
const _rankTask = 'cards_ranks_suits_rank_drill';
final _store = Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true);

Map<String, Object?> _fixture(String lessonId, String taskId) {
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final lesson = world.lessons.firstWhere((l) => l.lessonId == lessonId);
  return {
    'schemaVersion': 18,
    // Prerequisites establish route access, not earned curriculum completion.
    // In particular Daily has no candidate until rank is really completed.
    'completedTaskIds': <String>[],
    'skippedTaskIds': [
      for (final l in world.lessons.takeWhile((l) => l.lessonId != lessonId))
        for (final t in l.taskList) t.taskId,
      for (final t in lesson.taskList.takeWhile((t) => t.taskId != taskId))
        t.taskId,
    ],
    'completedLessonIds': <String>[],
    'selectedWorldId': 'world_1',
    'selectedLessonId': lessonId,
    'selectedTaskId': taskId,
    'earnedXp': 0,
    'learningEvidenceHistory': <Object>[],
  };
}

Future<void> _mount(WidgetTester tester, Act0ShellTabV1 tab) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await _store.flush();
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        showPlacementOnStart: false,
        initialTab: tab == Act0ShellTabV1.play ? Act0ShellTabV1.learn : tab,
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (tab == Act0ShellTabV1.play) {
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('act0_shell_bottom_nav')),
        matching: find.text('Practice'),
      ),
    );
    await tester.pumpAndSettle();
  }
}

Future<void> _setup(WidgetTester tester, String lesson, String task) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _key: jsonEncode(_fixture(lesson, task)),
  });
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await _store.flush();
  });
  await _mount(tester, Act0ShellTabV1.learn);
}

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
  state.debugPersistProgressV1();
  await tester.pump(const Duration(milliseconds: 300));
  await _store.flush();
  return jsonDecode((await _store.load())!) as Map<String, dynamic>;
}

Future<void> _startTask(WidgetTester tester, String lesson, String task) async {
  await _mount(tester, Act0ShellTabV1.learn);
  tester
      .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
      .onStartTask(lesson, task);
  await tester.pumpAndSettle();
}

Future<void> _ready(WidgetTester tester, String choice) async {
  final option = find.byKey(Key('act0_shell_option_$choice'));
  for (var step = 0; step < 15 && option.evaluate().isEmpty; step++) {
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    final next = theory.evaluate().isNotEmpty
        ? theory
        : find.byKey(const Key('act0_shell_continue_cta'));
    expect(
      next,
      findsOneWidget,
      reason: 'authored teaching route reaches $choice',
    );
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  expect(option, findsOneWidget);
}

Future<void> _answer(
  WidgetTester tester,
  String choice, {
  bool settle = true,
}) async {
  await _ready(tester, choice);
  await tester.tap(find.byKey(Key('act0_shell_option_$choice')));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _continue(WidgetTester tester) async {
  final next = find.byKey(const Key('act0_shell_feedback_continue_cta'));
  expect(next, findsOneWidget);
  await tester.tap(next);
  await tester.pumpAndSettle();
}

Future<void> _launchRepair(WidgetTester tester, String sourceTask) async {
  await _mount(tester, Act0ShellTabV1.play);
  final play = _practice(tester);
  final request = play.repairQueueConsumer.items
      .map((item) => item.launchRequest)
      .where((request) => request?.sourceTaskId == sourceTask)
      .single!;
  if (sourceTask == _actionSource) expect(request.repairTaskId, _actionRepair);
  play.onLaunchRepairQueueTarget!(request);
  await tester.pumpAndSettle();
}

// The queue's authored repair has no hint CTA in this route. Exercise both
// public callbacks, including the canonical completed decision, with explicit
// assisted provenance. This checks semantics, not hint discoverability.
Future<void> _assistedAnswer(WidgetTester tester, String choice) async {
  await _ready(tester, choice);
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.singleWhere((o) => o.id == choice);
  runner.onChoiceAssistance!(Act0DecisionAssistanceV1.quickHint);
  runner.onChooseOption(option);
  final attempt =
      'machine_assisted|${runner.evidenceRunId}|${runner.evidenceNextOrder}';
  // A rejected completion must not consume exposed help.
  runner.onCompletedDecision!(
    _decisionForRunner(
      runner,
      choice,
      '$attempt|rejected',
      assistance: Act0DecisionAssistanceV1.quickHint,
      includeSkill: false,
    ),
  );
  await tester.pumpAndSettle();
  final rejected = await _saved(tester);
  expect(
    _rows(
      rejected,
      'learningEvidenceHistory',
    ).where((r) => r['recordId'] == '$attempt|rejected'),
    isEmpty,
  );
  expect(
    _rows(
      rejected,
      'pendingDecisionAssistance',
    ).where((r) => r['taskId'] == runner.selectedTaskId),
    hasLength(1),
  );
  runner.onCompletedDecision!(
    _decisionForRunner(
      runner,
      choice,
      attempt,
      assistance: Act0DecisionAssistanceV1.quickHint,
    ),
  );
  await tester.pumpAndSettle();
  final accepted = await _saved(tester);
  final canonical = _rows(
    accepted,
    'learningEvidenceHistory',
  ).singleWhere((r) => r['recordId'] == attempt);
  expect(canonical['assistanceKind'], 'quickHint');
  expect(canonical['skillAtomId'], isNotEmpty);
  expect(
    _rows(
      accepted,
      'pendingDecisionAssistance',
    ).where((r) => r['taskId'] == runner.selectedTaskId),
    isEmpty,
  );
}

Act0CompletedDecisionV1 _decisionForRunner(
  Act0LessonRunnerShellV1 runner,
  String choice,
  String attempt, {
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  bool includeSkill = true,
}) {
  final option = runner.runner.options.singleWhere((o) => o.id == choice);
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: runner.runner,
    option: option,
    taskFamily: runner.selectedTaskFamily,
  );
  final concept = act0ConceptErrorDefinitionForTaskV1(
    worldId: runner.selectedWorldId ?? '',
    lessonId: runner.selectedLessonId!,
    taskId: runner.selectedTaskId!,
  );
  return Act0CompletedDecisionV1(
    attemptKey: attempt,
    worldId: runner.selectedWorldId,
    lessonId: runner.selectedLessonId!,
    taskId: runner.selectedTaskId!,
    sourceTaskId: runner.selectedTaskId!,
    decisionKind: Act0CompletedDecisionKindV1.actionList,
    selectedId: choice,
    expectedId: runner.runner.options.singleWhere((o) => o.isCorrect).id,
    isCorrect: option.isCorrect,
    decisionTimeBucket: '3_to_10s',
    taskFamily: runner.selectedTaskFamily,
    resultKind: option.isCorrect ? 'correct' : 'incorrect',
    errorType: option.isCorrect ? 'none' : null,
    assistanceKind: assistance,
    skillAtomId: includeSkill
        ? receipt?.skillAtomId ?? concept?.eligibleRepairFamily
        : null,
    repairFocusId: receipt?.sourceSignalId ?? concept?.id,
    missedSignalId: receipt?.sourceSignalId ?? concept?.id,
  );
}

List<Map> _rows(Map<String, dynamic> data, String key) =>
    ((data[key] as List?) ?? []).cast<Map>();
List<Map> _debt(Map<String, dynamic> data, String task) => _rows(
  data,
  'openRepairIntents',
).where((intent) => intent['sourceTaskId'] == task).toList();

Future<void> _tab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('act0_shell_bottom_nav')),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
  await tester.pumpAndSettle();
}

Future<void> _startWithoutRemount(WidgetTester tester, String task) async {
  await _tab(tester, 'Learn');
  tester
      .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
      .onStartTask(_actionLesson, task);
  await tester.pumpAndSettle();
}

({
  List<Act0PracticeGroupV1> groups,
  ValueChanged<Act0PracticeGroupV1> onStartGroup,
  Act0PracticeRepairQueueConsumerV1 repairQueueConsumer,
  ValueChanged<Act0PracticeRepairQueueLaunchRequestV1>?
  onLaunchRepairQueueTarget,
})
_practice(WidgetTester tester) {
  if (act0AcademyPracticePreviewV1) {
    final input = tester
        .widget<Act0AcademyPracticeLeafV1>(
          find.byType(Act0AcademyPracticeLeafV1),
        )
        .input;
    return (
      groups: input.groups,
      onStartGroup: input.onStartGroup,
      repairQueueConsumer: input.repairQueue,
      onLaunchRepairQueueTarget: input.onLaunchRepair,
    );
  }
  final legacy = tester.widget<Act0PlayShellV1>(find.byType(Act0PlayShellV1));
  return (
    groups: legacy.groups,
    onStartGroup: legacy.onStartGroup,
    repairQueueConsumer: legacy.repairQueueConsumer,
    onLaunchRepairQueueTarget: legacy.onLaunchRepairQueueTarget,
  );
}

List<Act0MistakeCardV1> _openMistakes(WidgetTester tester) =>
    act0AcademyReviewPreviewV1
    ? tester
          .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
          .input
          .openMistakes
    : tester
          .widget<Act0ReviewShellV1>(find.byType(Act0ReviewShellV1))
          .review
          .mistakes;

ValueChanged<Act0MistakeCardV1>? _repairCallback(WidgetTester tester) =>
    act0AcademyReviewPreviewV1
    ? tester
          .widget<Act0AcademyReviewLeafV1>(find.byType(Act0AcademyReviewLeafV1))
          .input
          .onRepairMistake
    : tester
          .widget<Act0ReviewShellV1>(find.byType(Act0ReviewShellV1))
          .onFixMistake;

Finder _openDebtCaption(int count) => act0AcademyReviewPreviewV1
    ? find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.key == const Key('act0_academy_review_leaf_open_count') &&
            w.data == '$count',
      )
    : find.text('$count ${count == 1 ? 'miss' : 'misses'} to fix');

void main() {
  testWidgets(
    'G0 live Review discharges only the independently repaired occurrence',
    (tester) async {
      await _setup(tester, _actionLesson, _actionRepair);
      final root = tester.state(find.byType(Act0ShellPreviewScreenV1));
      await _startWithoutRemount(tester, _actionRepair);
      await _answer(tester, 'fold');
      final firstMiss = await _saved(tester);
      final firstOccurrence = _debt(firstMiss, _actionRepair).single;
      await _back(tester);
      await _startWithoutRemount(tester, _actionSource);
      await _answer(tester, 'fold');
      final twoMisses = await _saved(tester);
      final pending = _debt(twoMisses, _actionSource).single;
      expect(_rows(twoMisses, 'openRepairIntents'), hasLength(2));
      await _back(tester);
      await _tab(tester, 'Practice');
      final play = _practice(tester);
      final request = play.repairQueueConsumer.items
          .map((item) => item.launchRequest)
          .singleWhere((request) => request?.sourceTaskId == _actionRepair)!;
      expect(request.repairTaskId, _actionSource);
      play.onLaunchRepairQueueTarget!(request);
      await tester.pumpAndSettle();
      await _answer(tester, 'check');
      final repaired = await _saved(tester);
      expect(_debt(repaired, _actionRepair), isEmpty);
      expect(_debt(repaired, _actionSource).single, pending);
      final receipt = _rows(repaired, 'reviewResolutionReceipts').single;
      expect(receipt['resolutionReason'], 'repair_succeeded');
      expect(
        receipt['learningEvidenceId'],
        firstOccurrence['repairOccurrenceId'],
      );
      final outcome = _rows(repaired, 'repairOutcomeProjection').single;
      expect(
        outcome['repairOccurrenceId'],
        firstOccurrence['repairOccurrenceId'],
      );
      final evidence = _rows(repaired, 'learningEvidenceHistory').last;
      expect(evidence['assistanceKind'], 'none');
      expect(evidence['startedBy'], 'practice_repair_queue');
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      runner.onCompletedDecision!(
        _decisionForRunner(runner, 'check', evidence['recordId'] as String),
      );
      await tester.pumpAndSettle();
      final duplicate = await _saved(tester);
      for (final key in [
        'learningEvidenceHistory',
        'repairOutcomeProjection',
        'reviewResolutionReceipts',
        'multiRepairQueue',
        'earnedXp',
      ]) {
        expect(
          duplicate[key],
          repaired[key],
          reason: 'duplicate delivery: $key',
        );
      }
      await _continue(tester);
      expect(tester.state(find.byType(Act0ShellPreviewScreenV1)), same(root));
      expect(
        _openMistakes(tester).map((mistake) => mistake.taskId),
        [_actionSource],
        reason: 'resolved Check must disappear immediately, without a remount',
      );
      expect(_openDebtCaption(1), findsOneWidget);
      expect(_repairCallback(tester), isNotNull);
      final after = await _saved(tester);
      final reward = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .singleWhere((lesson) => lesson.lessonId == _actionLesson)
          .taskList
          .singleWhere((task) => task.taskId == _actionSource)
          .rewardXp;
      expect(
        after['earnedXp'],
        (repaired['earnedXp'] as int) + reward,
        reason: 'first target completion earns its authored reward on Continue',
      );
      for (final key in [
        'learningEvidenceHistory',
        'repairOutcomeProjection',
        'reviewResolutionReceipts',
        'openRepairIntents',
      ]) {
        expect(
          after[key],
          repaired[key],
          reason: 'Review is a projection: $key',
        );
      }
      await _mount(tester, Act0ShellTabV1.review);
      expect(_openMistakes(tester).map((mistake) => mistake.taskId), [
        _actionSource,
      ]);
      final restored = await _saved(tester);
      expect(restored['earnedXp'], after['earnedXp']);
      expect(
        restored['reviewResolutionReceipts'],
        repaired['reviewResolutionReceipts'],
      );
      expect(_debt(restored, _actionSource).single, pending);

      // A receipt for the old occurrence must not hide the next real miss.
      await _startWithoutRemount(tester, _actionRepair);
      await _answer(tester, 'fold');
      final reopened = await _saved(tester);
      final newOccurrence = _debt(reopened, _actionRepair).single;
      expect(
        newOccurrence['repairOccurrenceId'],
        isNot(firstOccurrence['repairOccurrenceId']),
      );
      expect(
        newOccurrence['repairOccurrenceId'],
        _rows(reopened, 'learningEvidenceHistory').last['recordId'],
      );
      expect(_debt(reopened, _actionSource).single, pending);
      expect(
        reopened['reviewResolutionReceipts'],
        repaired['reviewResolutionReceipts'],
      );
      expect(
        reopened['repairOutcomeProjection'],
        repaired['repairOutcomeProjection'],
      );
      await _back(tester);
      await _tab(tester, 'Review');
      expect(
        _openMistakes(tester).map((mistake) => mistake.taskId),
        unorderedEquals([_actionRepair, _actionSource]),
      );
      expect(_openDebtCaption(2), findsOneWidget);
    },
  );

  for (final kind in ['wrong', 'assisted', 'unverified']) {
    testWidgets('G0 $kind cannot discharge live Review debt', (tester) async {
      await _setup(tester, _actionLesson, _actionRepair);
      final root = tester.state(find.byType(Act0ShellPreviewScreenV1));
      await _startWithoutRemount(tester, _actionRepair);
      await _answer(tester, 'fold');
      await _back(tester);
      await _startWithoutRemount(tester, _actionSource);
      await _answer(tester, 'fold');
      final owed = await _saved(tester);
      await _back(tester);
      await _tab(tester, 'Practice');
      final play = _practice(tester);
      final request = play.repairQueueConsumer.items
          .map((item) => item.launchRequest)
          .singleWhere((request) => request?.sourceTaskId == _actionRepair)!;
      play.onLaunchRepairQueueTarget!(request);
      await tester.pumpAndSettle();
      await _ready(tester, 'check');
      if (kind == 'unverified') {
        // A UI choice without the owned completed-decision contract supplies
        // no independently verified occurrence resolution.
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        runner.onChooseOption(
          runner.runner.options.singleWhere((o) => o.id == 'check'),
        );
        await tester.pumpAndSettle();
      } else {
        if (kind == 'assisted') {
          await tester.tap(
            find.byKey(const Key('act0_shell_theory_recall_cta')),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const Key('act0_shell_theory_recall_close_cta')),
          );
          await tester.pumpAndSettle();
        }
        await _answer(tester, kind == 'wrong' ? 'fold' : 'check');
      }
      await _continue(tester);
      expect(tester.state(find.byType(Act0ShellPreviewScreenV1)), same(root));
      expect(
        _openMistakes(tester).map((mistake) => mistake.taskId),
        unorderedEquals([_actionRepair, _actionSource]),
      );
      expect(_openDebtCaption(2), findsOneWidget);
      final after = await _saved(tester);
      expect(after['reviewResolutionReceipts'], isEmpty);
      for (final task in [_actionRepair, _actionSource]) {
        expect(_debt(after, task).single, _debt(owed, task).single);
      }
      final reward = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .singleWhere((lesson) => lesson.lessonId == _actionLesson)
          .taskList
          .singleWhere((task) => task.taskId == _actionSource)
          .rewardXp;
      expect(
        after['earnedXp'],
        (owed['earnedXp'] as int) + (kind == 'unverified' ? reward : 0),
        reason: 'preserve the existing task award; it is not repair proof',
      );
      await _mount(tester, Act0ShellTabV1.review);
      expect((await _saved(tester))['earnedXp'], after['earnedXp']);
    });
  }

  testWidgets('A new source miss after repair and remount remains owed', (
    tester,
  ) async {
    await _setup(tester, _actionLesson, _actionSource);
    await _startTask(tester, _actionLesson, _actionSource);
    await _answer(tester, 'fold');
    expect(_debt(await _saved(tester), _actionSource), hasLength(1));
    await _launchRepair(tester, _actionSource);
    await _answer(tester, 'check');
    final first = await _saved(tester);
    expect(_debt(first, _actionSource), isEmpty);
    final oldOutcome = _rows(first, 'repairOutcomeProjection').single;
    expect(oldOutcome['isCorrect'], isTrue);
    await _startTask(tester, _actionLesson, _actionSource);
    await _answer(tester, 'fold');
    final repeated = await _saved(tester);
    expect(
      _rows(repeated, 'repairOutcomeProjection').first,
      equals(oldOutcome),
      reason: 'historical success remains intact',
    );
    expect(
      _debt(repeated, _actionSource),
      hasLength(1),
      reason: 'old successful repair cannot resolve a fresh source miss',
    );
    await _mount(tester, Act0ShellTabV1.play);
    final restored = await _saved(tester);
    expect(_debt(restored, _actionSource), hasLength(1));
    final play = _practice(tester);
    expect(
      play.repairQueueConsumer.items.where(
        (i) => i.launchRequest?.sourceTaskId == _actionSource,
      ),
      hasLength(1),
    );
    final sourceRecords = _rows(
      repeated,
      'learningEvidenceHistory',
    ).where((r) => r['taskId'] == _actionSource).toList();
    final occurrence = _debt(
      repeated,
      _actionSource,
    ).single['repairOccurrenceId'];
    expect(occurrence, sourceRecords.last['recordId']);
    expect(occurrence, isNot(oldOutcome['repairOccurrenceId']));
    expect(
      _rows(restored, 'reviewResolutionReceipts'),
      _rows(first, 'reviewResolutionReceipts'),
    );
    await _launchRepair(tester, _actionSource);
    await _answer(tester, 'check');
    final closed = await _saved(tester);
    expect(_debt(closed, _actionSource), isEmpty);
    expect(_rows(closed, 'repairOutcomeProjection').first, oldOutcome);
    expect(
      _rows(closed, 'repairOutcomeProjection').last['repairOccurrenceId'],
      occurrence,
    );
    expect(_rows(closed, 'reviewResolutionReceipts'), isNotEmpty);
    await _mount(tester, Act0ShellTabV1.review);
    expect(
      _rows(await _saved(tester), 'reviewResolutionReceipts'),
      _rows(closed, 'reviewResolutionReceipts'),
    );
  });

  testWidgets(
    'B completed rank Daily wrong and Continue retains debt without XP twice',
    (tester) async {
      await _setup(tester, _rankLesson, _rankTask);
      await _startTask(tester, _rankLesson, _rankTask);
      await _answer(tester, 'ace');
      await _continue(tester);
      final completed = await _saved(tester);
      expect(completed['completedTaskIds'], contains(_rankTask));
      final earned = completed['earnedXp'];
      expect(earned, greaterThan(0));
      await _mount(tester, Act0ShellTabV1.play);
      final play = _practice(tester);
      final daily = play.groups.singleWhere((g) => g.groupId == 'daily');
      expect(daily.isEnabled, isTrue);
      expect(
        daily.targetTaskId,
        _rankTask,
        reason: 'only legitimately completed rank is a Daily candidate',
      );
      play.onStartGroup(daily);
      await tester.pumpAndSettle();
      await _answer(tester, 'king', settle: false);
      final wrongAnswer = await _saved(tester);
      final wrongRecord = _rows(
        wrongAnswer,
        'learningEvidenceHistory',
      ).lastWhere((r) => r['taskId'] == _rankTask && r['isCorrect'] == false);
      expect(
        _debt(wrongAnswer, _rankTask),
        hasLength(1),
        reason: 'debt exists before rapid Daily automatic Continue',
      );
      // Daily invokes the actual Continue callback after its 650ms feedback.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      final after = await _saved(tester);
      expect(after['earnedXp'], earned);
      expect(
        _debt(after, _rankTask),
        hasLength(1),
        reason:
            'completed curriculum identity cannot clear current wrong replay',
      );
      await _mount(tester, Act0ShellTabV1.play);
      final restored = await _saved(tester);
      expect(restored['earnedXp'], earned);
      expect(_debt(restored, _rankTask), hasLength(1));
      final occurrence = _debt(
        restored,
        _rankTask,
      ).single['repairOccurrenceId'];
      expect(occurrence, wrongRecord['recordId']);
      for (final assisted in [false, true]) {
        await _launchRepair(tester, _rankTask);
        if (assisted) {
          await _assistedAnswer(tester, 'ace');
        } else {
          await _answer(tester, 'king');
        }
        await _continue(tester);
        await _mount(tester, Act0ShellTabV1.play);
        final retained = await _saved(tester);
        expect(retained['earnedXp'], earned);
        expect(
          _debt(retained, _rankTask).single['repairOccurrenceId'],
          occurrence,
        );
      }
      await _launchRepair(tester, _rankTask);
      await _answer(tester, 'ace');
      final fixed = await _saved(tester);
      expect(_debt(fixed, _rankTask), isEmpty);
      expect(fixed['earnedXp'], earned);
      expect(
        _rows(
          fixed,
          'learningEvidenceHistory',
        ).singleWhere((r) => r['recordId'] == wrongRecord['recordId']),
        wrongRecord,
      );
      await _mount(tester, Act0ShellTabV1.play);
      final finalRestored = await _saved(tester);
      expect(_debt(finalRestored, _rankTask), isEmpty);
      expect(finalRestored['earnedXp'], earned);
    },
  );

  testWidgets(
    'D same mounted Learn start cannot reuse a completed queue request',
    (tester) async {
      await _setup(tester, _rankLesson, _rankTask);
      final rootState = tester.state(find.byType(Act0ShellPreviewScreenV1));
      tester
          .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
          .onStartTask(_rankLesson, _rankTask);
      await tester.pumpAndSettle();
      await _answer(tester, 'king');
      final firstMiss = await _saved(tester);
      final firstOccurrence = _debt(
        firstMiss,
        _rankTask,
      ).single['repairOccurrenceId'];
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Practice'),
        ),
      );
      await tester.pumpAndSettle();
      final play = _practice(tester);
      final request = play.repairQueueConsumer.items
          .map((item) => item.launchRequest)
          .where((r) => r?.sourceTaskId == _rankTask)
          .single!;
      expect(request.repairTaskId, _rankTask);
      play.onLaunchRepairQueueTarget!(request);
      await tester.pumpAndSettle();
      await _answer(tester, 'ace');
      final fixed = await _saved(tester);
      expect(_debt(fixed, _rankTask), isEmpty);
      await _continue(tester);
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Learn'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.state(find.byType(Act0ShellPreviewScreenV1)),
        same(rootState),
        reason: 'no remount may erase the stale queue launch context',
      );
      tester
          .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
          .onStartTask(_rankLesson, _rankTask);
      await tester.pumpAndSettle();
      await _answer(tester, 'king');
      final repeated = await _saved(tester);
      final latestWrong = _rows(
        repeated,
        'learningEvidenceHistory',
      ).lastWhere((r) => r['taskId'] == _rankTask && r['isCorrect'] == false);
      expect(latestWrong['recordId'], isNot(firstOccurrence));
      expect(
        _debt(repeated, _rankTask),
        hasLength(1),
        reason:
            'same-mounted Learn source miss must create fresh actionable debt',
      );
      expect(
        _debt(repeated, _rankTask).single['repairOccurrenceId'],
        latestWrong['recordId'],
      );
      expect(
        _rows(repeated, 'repairOutcomeProjection'),
        _rows(fixed, 'repairOutcomeProjection'),
        reason: 'new Learn source answer is not another old queue repair',
      );
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Practice'),
        ),
      );
      await tester.pumpAndSettle();
      final nextPlay = _practice(tester);
      expect(
        nextPlay.repairQueueConsumer.items.where(
          (i) => i.launchRequest?.sourceTaskId == _rankTask && i.isLaunchable,
        ),
        hasLength(1),
      );
      expect(
        tester.state(find.byType(Act0ShellPreviewScreenV1)),
        same(rootState),
      );
    },
  );

  for (final outcome in ['correct', 'wrong', 'assisted']) {
    testWidgets('C $outcome repair has truthful durable Review receipt', (
      tester,
    ) async {
      await _setup(tester, _actionLesson, _actionSource);
      await _startTask(tester, _actionLesson, _actionSource);
      await _answer(tester, 'fold');
      await _launchRepair(tester, _actionSource);
      if (outcome == 'assisted') {
        await _assistedAnswer(tester, 'check');
      } else {
        await _answer(tester, outcome == 'wrong' ? 'fold' : 'check');
      }
      final before = await _saved(tester);
      final receipts = _rows(before, 'reviewResolutionReceipts');
      if (outcome == 'correct') {
        expect(
          receipts,
          hasLength(1),
          reason: 'first success owns a durable Review receipt',
        );
        expect(receipts.single['resolutionReason'], 'repair_succeeded');
        expect(receipts.single['repairOutcomeId'], isNotEmpty);
        expect(_debt(before, _actionSource), isEmpty);
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        final record = _rows(
          before,
          'learningEvidenceHistory',
        ).lastWhere((r) => r['taskId'] == _actionRepair);
        runner.onCompletedDecision!(
          _decisionForRunner(runner, 'check', record['recordId'] as String),
        );
        await tester.pumpAndSettle();
        final duplicate = await _saved(tester);
        for (final key in [
          'learningEvidenceHistory',
          'repairOutcomeProjection',
          'reviewResolutionReceipts',
          'earnedXp',
          'openRepairIntents',
        ]) {
          expect(
            duplicate[key],
            before[key],
            reason: '$key is idempotent for duplicate completed delivery',
          );
        }
      } else {
        expect(
          receipts,
          isEmpty,
          reason: 'wrong/assisted repair cannot claim success',
        );
        expect(_debt(before, _actionSource), hasLength(1));
        expect(
          _rows(
            before,
            'repairOutcomeProjection',
          ).where((o) => o['isCorrect'] == true),
          isEmpty,
        );
      }
      await _mount(tester, Act0ShellTabV1.review);
      expect(_rows(await _saved(tester), 'reviewResolutionReceipts'), receipts);
    });
  }
}
