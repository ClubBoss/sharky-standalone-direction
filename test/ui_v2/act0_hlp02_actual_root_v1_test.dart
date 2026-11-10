// HLP-02 C1: actual production AppRoot, not the B1 local Learn/Runner probe.
// Only pre-test storage is seeded. Every tested transition uses a visible UI
// control; no root callbacks, private State access, local completion Set or
// substitute navigation/reward/assistance implementation is used.
// Widget remount is NOT an OS process restart or native persistence receipt.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_reference_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
const _lessonId = 'hand_rankings_table';
const _theoryId = 'hand_rankings_theory';
const _pairId = 'hand_rankings_pair_drill';
const _openReference = Key('act0_hlp02_open_theory_reference');
const _referenceRegion = Key('act0_hlp02_inline_reference_region');
const _rankPair = Key('act0_hlp02_rank_rank.one_pair');

final _world = Act0ShellStateV1.sample.worldById('world_1');
final _lesson = _world.lessons.singleWhere((row) => row.lessonId == _lessonId);

// Observe the real store's shared pending-write queue only. This instance
// cannot save/accept payloads and is never used to load or heal checkpoints.
Future<void> _flushWrites() => Act0ProgressStoreV1(
  key: _progressKey,
  isValidPayload: (_) => false,
).flush();

Future<Map<String, dynamic>> _progress() async {
  await _flushWrites();
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final raw = prefs.getString(_progressKey);
  expect(raw, isNotNull);
  // Compatibility mirror inspection is not a durable/native storage audit.
  // The actual AppRoot remount separately restores via the production store.
  return jsonDecode(raw!) as Map<String, dynamic>;
}

List<Map<String, dynamic>> _records(Map<String, dynamic> progress, String task) {
  return (progress['learningEvidenceHistory'] as List<dynamic>? ?? <dynamic>[])
      .cast<Map<String, dynamic>>()
      .where((row) => row['taskId'] == task)
      .toList();
}

Map<String, dynamic> _gradedFields(Map<String, dynamic> progress) => {
  for (final field in <String>[
    'earnedXp',
    'completedTaskIds',
    'learningEvidenceHistory',
    'openRepairIntents',
  ])
    field: progress[field],
};

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await _flushWrites();
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final target = find.byKey(key);
  expect(target, findsOneWidget, reason: 'Missing actual UI control: $key');
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await _settle(tester);
}

Act0LessonRunnerShellV1 _runner(WidgetTester tester) {
  expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
  return tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
}

void _expectNoReference() {
  expect(find.byKey(_openReference), findsNothing);
  expect(find.byKey(_referenceRegion), findsNothing);
  expect(find.byKey(_rankPair), findsNothing);
}

Future<void> _mountFreshFixture(WidgetTester tester) async {
  await _loadRealReferenceAsset(tester);
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await _flushWrites();
  final priorLessons = _world.lessons
      .takeWhile((row) => row.lessonId != _lessonId)
      .toList();
  // Existing schema-18 import setup, not evidence for this test's HLP steps.
  // No hand-ranking task, grade, assistance or completion is prepopulated.
  SharedPreferences.setMockInitialValues(<String, Object>{
    'onboardingCompleted': true,
    'onboarding_complete': true,
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    'app_language_code': 'en',
    _progressKey: jsonEncode(<String, Object?>{
      'schemaVersion': 18,
      'completedTaskIds': <String>[
        for (final lesson in priorLessons)
          for (final task in lesson.taskList) task.taskId,
      ]..sort(),
      'completedLessonIds': <String>[
        for (final lesson in priorLessons) lesson.lessonId,
      ],
      'skippedTaskIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': _lessonId,
      'selectedTaskId': _theoryId,
      'earnedXp': 0,
      'learningEvidenceHistory': <Object>[],
      'openRepairIntents': <Object>[],
    }),
  });
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await _settle(tester);
  });
  await tester.pumpWidget(const AppRoot());
  await _settle(tester);
  final root = tester.widget<Act0ShellPreviewScreenV1>(
    find.byType(Act0ShellPreviewScreenV1),
  );
  expect(root.debugHarnessEntry, isNull);
  expect(root.state, isNull);
  expect(root.showPlacementOnStart, isFalse);
  expect(Localizations.localeOf(tester.element(find.byType(
    Act0ShellPreviewScreenV1,
  ))).languageCode, 'en');
  await _learnTab(tester);
  expect(find.byKey(_openReference), findsOneWidget);
  expect(find.byKey(_referenceRegion), findsNothing);
}

Future<void> _learnTab(WidgetTester tester) async {
  if (find.byType(Act0LessonRunnerShellV1).evaluate().isNotEmpty) {
    await _tap(tester, const Key('act0_shell_runner_back'));
  }
  if (find.byType(Act0LearnPathShellV1).evaluate().isEmpty) {
    final tab = find.descendant(
      of: find.byKey(const Key('act0_shell_bottom_nav')),
      matching: find.text('Learn'),
    );
    expect(tab, findsOneWidget);
    await tester.tap(tab);
    await _settle(tester);
  }
  expect(find.byType(Act0LearnPathShellV1), findsOneWidget);
}

Future<void> _startMission(WidgetTester tester, String expectedTask) async {
  await _tap(tester, const Key('act0_shell_current_mission_cta'));
  expect(_runner(tester).selectedTaskId, expectedTask);
  _expectNoReference();
}

Future<void> _continueTeaching(WidgetTester tester) async {
  // Advance the production dwell timer; do not override the advance lock.
  await tester.pump(const Duration(milliseconds: 1000));
  final rail = find.byKey(const Key('act0_shell_theory_continue_cta'));
  await _tap(tester, rail.evaluate().isNotEmpty
      ? const Key('act0_shell_theory_continue_cta')
      : const Key('act0_shell_continue_cta'));
}

Future<void> _completeTheory(WidgetTester tester) async {
  for (var step = 0; step < 12; step++) {
    if (_runner(tester).selectedTaskId != _theoryId) break;
    await _continueTeaching(tester);
  }
  expect(_runner(tester).selectedTaskId, _pairId);
  _expectNoReference();
}

Future<void> _reachOptions(WidgetTester tester, String taskId) async {
  for (var step = 0; step < 12; step++) {
    final runner = _runner(tester);
    expect(runner.selectedTaskId, taskId);
    if (runner.runner.options.any((option) =>
        find.byKey(Key('act0_shell_option_${option.id}')).evaluate().isNotEmpty)) {
      await tester.pump(const Duration(seconds: 3));
      await _settle(tester);
      expect(_runner(tester).runner.selectedOptionId, isNull);
      _expectNoReference();
      return;
    }
    await _continueTeaching(tester);
  }
  fail('Actual task $taskId did not expose its choices through UI controls');
}

Future<void> _replayFromLearn(WidgetTester tester, String taskId) async {
  await _learnTab(tester);
  await _tap(tester, const Key('act0_shell_learn_v5_view_full_path'));
  await _tap(tester, Key('act0_shell_lesson_${_lesson.title}'));
  await _tap(tester, Key('act0_shell_lesson_step_$taskId'));
  await _tap(tester, const Key('act0_shell_selected_lesson_cta'));
  expect(_runner(tester).selectedTaskId, taskId);
  _expectNoReference();
}

// Asset I/O must run outside the widget test's fake clock. This loads the
// real registered production asset through its parser; no fake catalog or
// replacement bundle is injected. UI assertions still require the real panel.
Future<void> _loadRealReferenceAsset(WidgetTester tester) async {
  await tester.runAsync(() async {
    final catalog = await Act0Hlp02ReferenceCatalogV1.load(rootBundle);
    expect(catalog.rankings, hasLength(9));
  });
}

void main() {
  testWidgets('AppRoot Learn disclosure, Back, completion and theory replay', (
    tester,
  ) async {
    await _mountFreshFixture(tester);
    final before = _gradedFields(await _progress());
    await _tap(tester, _openReference);
    await _tap(tester, _rankPair);
    expect(find.byKey(_referenceRegion), findsOneWidget);
    expect(_gradedFields(await _progress()), before);

    await _startMission(tester, _theoryId);
    await _tap(tester, const Key('act0_shell_runner_back'));
    expect(find.byType(Act0LearnPathShellV1), findsOneWidget);
    expect(find.byKey(_openReference), findsOneWidget);
    expect(find.byKey(_referenceRegion), findsNothing);
    expect(_gradedFields(await _progress()), before);

    await _startMission(tester, _theoryId);
    await _completeTheory(tester);
    final completed = await _progress();
    expect(completed['completedTaskIds'], contains(_theoryId));
    expect(completed['earnedXp'], _lesson.taskList.first.rewardXp);
    expect(_records(completed, _theoryId), isEmpty);
    expect(_records(completed, _pairId), isEmpty);
    await _learnTab(tester);
    // Learn is current-mission-first: selected/replayed past theory does not
    // re-admit a reference while the first unclosed mission is a drill.
    _expectNoReference();
    await _replayFromLearn(tester, _theoryId);
    await _completeTheory(tester);
    final replayed = await _progress();
    expect(replayed['earnedXp'], completed['earnedXp']);
    expect(replayed['completedTaskIds'], completed['completedTaskIds']);
    expect(_records(replayed, _theoryId), isEmpty);
    expect(_records(replayed, _pairId), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('actual wrong and Quick Hint attempts keep distinct provenance', (
    tester,
  ) async {
    await _mountFreshFixture(tester);
    await _tap(tester, _openReference);
    await _tap(tester, _rankPair);
    await _startMission(tester, _theoryId);
    await _completeTheory(tester);
    await _reachOptions(tester, _pairId);
    final wrong = _runner(tester).runner.options.singleWhere((o) => !o.isCorrect);
    await _tap(tester, Key('act0_shell_option_${wrong.id}'));
    final wrongRecords = _records(await _progress(), _pairId);
    expect(wrongRecords, hasLength(1));
    final original = Map<String, dynamic>.from(wrongRecords.single);
    expect(original['choiceId'], wrong.id);
    expect(original['isCorrect'], isFalse);
    expect(original['assistanceKind'], 'none');
    expect(original['errorType'], allOf(isA<String>(), isNot(isEmpty)));
    expect(original['errorType'], isNot('none'));
    expect(original['runId'], allOf(isA<String>(), isNot(isEmpty)));

    // Re-enter the unfinished task with real Back/Learn Start, not a local
    // reset of the runner or its private choice-assistance state.
    await _learnTab(tester);
    _expectNoReference();
    await _startMission(tester, _pairId);
    await _reachOptions(tester, _pairId);
    await _tap(tester, const Key('act0_shell_theory_recall_cta'));
    expect(find.byKey(const Key('act0_shell_theory_recall_sheet')), findsOneWidget);
    _expectNoReference();
    expect(_records(await _progress(), _pairId), <Object>[original]);
    await _tap(tester, const Key('act0_shell_theory_recall_close_cta'));
    final correct = _runner(tester).runner.options.singleWhere((o) => o.isCorrect);
    await _tap(tester, Key('act0_shell_option_${correct.id}'));
    final assisted = _records(await _progress(), _pairId);
    expect(assisted, hasLength(2));
    expect(assisted.first, original);
    expect(assisted.last['choiceId'], correct.id);
    expect(assisted.last['isCorrect'], isTrue);
    expect(assisted.last['assistanceKind'], 'quickHint');
    expect(assisted.last['recordId'], allOf(isA<String>(), isNot(isEmpty)));
    expect(assisted.last['runId'], allOf(isA<String>(), isNot(isEmpty)));
    expect(assisted.last['recordId'], isNot(original['recordId']));
    expect(assisted.last['runId'], isNot(original['runId']));
    await _tap(tester, const Key('act0_shell_feedback_continue_cta'));
    expect(_runner(tester).selectedTaskId, 'hand_rankings_two_pair_drill');
    final continued = await _progress();
    expect(continued['completedTaskIds'], contains(_pairId));
    expect(continued['earnedXp'],
        _lesson.taskList.first.rewardXp + _lesson.taskList[1].rewardXp);

    // Keep the real protected-store bytes. This exercises root restore, not
    // native process restart or canonical matched independent recheck.
    await tester.pumpWidget(const SizedBox.shrink());
    await _settle(tester);
    await tester.pumpWidget(const AppRoot());
    await _settle(tester);
    await _learnTab(tester);
    _expectNoReference();
    expect(_records(await _progress(), _pairId), assisted);
    expect((await _progress())['earnedXp'], continued['earnedXp']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('actual lesson completion and summary advance replace context', (
    tester,
  ) async {
    await _mountFreshFixture(tester);
    await _tap(tester, _openReference);
    await _tap(tester, _rankPair);
    await _startMission(tester, _theoryId);
    await _completeTheory(tester);
    for (final task in _lesson.taskList.skip(1)) {
      await _reachOptions(tester, task.taskId);
      final correct = _runner(tester).runner.options.singleWhere((o) => o.isCorrect);
      await _tap(tester, Key('act0_shell_option_${correct.id}'));
      _expectNoReference();
      await _tap(tester, const Key('act0_shell_feedback_continue_cta'));
    }
    expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
    _expectNoReference();
    final completed = await _progress();
    expect(completed['completedTaskIds'], containsAll(
      _lesson.taskList.map((task) => task.taskId),
    ));
    expect(completed['completedLessonIds'], contains(_lessonId));
    expect(completed['earnedXp'], _lesson.taskList.fold<int>(
      0, (sum, task) => sum + task.rewardXp,
    ));
    for (final task in _lesson.taskList.where((t) => t.phase == Act0LessonPhaseV1.drill)) {
      final evidence = _records(completed, task.taskId);
      expect(evidence, hasLength(1), reason: task.taskId);
      expect(evidence.single['assistanceKind'], 'none');
      expect(evidence.single['isCorrect'], isTrue);
    }
    await _tap(tester, const Key('act0_shell_block_summary_continue_cta'));
    expect(_runner(tester).selectedLessonId, 'showdown_winning');
    expect(_runner(tester).selectedTaskId, 'showdown_theory');
    _expectNoReference();
    await _learnTab(tester);
    expect(find.byKey(_openReference), findsOneWidget);
    expect(find.byKey(_referenceRegion), findsNothing);
    await _tap(tester, _openReference);
    expect(find.byKey(_referenceRegion), findsOneWidget);
    expect(find.byKey(_rankPair), findsNothing);
    expect(find.byKey(const Key('act0_hlp02_term_term.equity')), findsNothing);
    expect((await _progress())['earnedXp'], completed['earnedXp']);
    expect(tester.takeException(), isNull);
  });
}
