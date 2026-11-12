// HLP-02 C1: actual production AppRoot, not the B1 local Learn/Runner probe.
// Only pre-test storage is seeded. Every tested transition uses a visible UI
// control; no root callbacks, private State access, local completion Set or
// substitute navigation/reward/assistance implementation is used.
// Widget remount is NOT an OS process restart or native persistence receipt.
import 'dart:convert';

import 'package:flutter/material.dart';
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
const _lessonId = 'call_price';
const _theoryId = 'w4_price_intro';
const _pairId = 'w4_good_price_call';
const _openReference = Key('act0_hlp02_open_theory_reference');
const _referenceRegion = Key('act0_hlp02_inline_reference_region');

final _world = Act0ShellStateV1.sample.worldById('world_4');
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

List<Map<String, dynamic>> _records(
  Map<String, dynamic> progress,
  String task,
) {
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
}

Future<void> _mountFreshFixture(
  WidgetTester tester, {
  String targetLessonId = _lessonId,
}) async {
  final fixtureWorld = Act0ShellStateV1.sample.worlds.firstWhere(
    (world) => world.lessons.any((lesson) => lesson.lessonId == targetLessonId),
  );
  final fixtureLesson = fixtureWorld.lessons.singleWhere(
    (lesson) => lesson.lessonId == targetLessonId,
  );
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await _flushWrites();
  final priorLessons = <Act0LessonCardV1>[
    for (final world in Act0ShellStateV1.sample.worlds.takeWhile(
      (world) => world.worldId != fixtureWorld.worldId,
    ))
      ...world.lessons,
    ...fixtureWorld.lessons.takeWhile((row) => row.lessonId != targetLessonId),
  ];
  // Existing schema-18 import setup, not evidence for this test's HLP steps.
  // No target W4 task, grade, assistance or completion is prepopulated.
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
      'selectedWorldId': fixtureWorld.worldId,
      'selectedLessonId': targetLessonId,
      'selectedTaskId': fixtureLesson.taskList.first.taskId,
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
  expect(
    Localizations.localeOf(
      tester.element(find.byType(Act0ShellPreviewScreenV1)),
    ).languageCode,
    'en',
  );
  await _learnTab(tester);
  final learn = tester.widget<Act0LearnPathShellV1>(
    find.byType(Act0LearnPathShellV1),
  );
  expect(
    find.byKey(_openReference),
    findsOneWidget,
    reason:
        'Requested $targetLessonId / ${fixtureLesson.taskList.first.taskId}; '
        'actual ${learn.selectedWorldId} / ${learn.selectedLessonId} / ${learn.selectedTaskId}; '
        'reference widgets ${find.byType(Act0Hlp02ReferenceButtonV1).evaluate().length}',
  );
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
  await _tap(
    tester,
    rail.evaluate().isNotEmpty
        ? const Key('act0_shell_theory_continue_cta')
        : const Key('act0_shell_continue_cta'),
  );
}

Future<void> _completeTheory(WidgetTester tester) async {
  for (var step = 0; step < 12; step++) {
    if (_runner(tester).selectedTaskId != _theoryId) break;
    await _continueTeaching(tester);
  }
  expect(_runner(tester).selectedTaskId, _pairId);
  _expectNoReference();
}

Future<void> _replayFromLearn(WidgetTester tester, String taskId) async {
  await _learnTab(tester);
  final currentLessonRow = find.byKey(
    Key('act0_shell_lesson_${_lesson.title}'),
  );
  // The collapsed path still has one current mission, not a duplicate row.
  expect(currentLessonRow, findsNothing);
  await _tap(tester, const Key('act0_shell_learn_v5_view_full_path'));
  // Actual completed earlier steps now have a real UI replay route.
  expect(currentLessonRow, findsOneWidget);
  await _tap(tester, Key('act0_shell_lesson_${_lesson.title}'));
  await _tap(tester, Key('act0_shell_lesson_step_$taskId'));
  await _tap(tester, const Key('act0_shell_selected_lesson_cta'));
  expect(_runner(tester).selectedTaskId, taskId);
  _expectNoReference();
}

// Await the Future owned by the rendered panel, not a separate prefetch.
// Start its asset read in the real async zone; keep every UI assertion below.
Future<void> _openRealReference(WidgetTester tester) async {
  final open = find.byKey(const Key('act0_hlp02_open_theory_reference'));
  expect(open, findsOneWidget);
  await tester.ensureVisible(open);
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await tester.tap(open);
    await tester.pump();
    final loader = find.descendant(
      of: find.byKey(const Key('act0_hlp02_inline_reference_region')),
      matching: find.byType(FutureBuilder<Act0Hlp02ReferenceCatalogV1>),
    );
    expect(loader, findsOneWidget);
    final future = tester
        .widget<FutureBuilder<Act0Hlp02ReferenceCatalogV1>>(loader)
        .future;
    expect(future, isNotNull);
    final catalog = await future!;
    expect(catalog.rankings, hasLength(9));
  });
  await tester.pumpAndSettle();
}

// Keep the nested reference viewport on screen after scrolling its contents.
// WidgetTester.ensureVisible alone can scroll the outer Learn viewport past
// this fixed-height panel; require an actual hit target before every action.
Future<Finder> _revealTool(WidgetTester tester, String key) async {
  final region = find.byKey(_referenceRegion);
  final target = find.byKey(Key(key));
  expect(region, findsOneWidget);
  await Scrollable.ensureVisible(tester.element(region), alignment: 0.15);
  await tester.pumpAndSettle();
  if (target.evaluate().isEmpty) {
    final scrollable = find
        .descendant(
          of: find.byKey(const Key('act0_hlp02_theory_reference_panel')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(target, 120, scrollable: scrollable);
  } else {
    await tester.ensureVisible(target);
  }
  await tester.pumpAndSettle();
  await Scrollable.ensureVisible(tester.element(region), alignment: 0.15);
  await tester.pumpAndSettle();
  expect(
    target.hitTestable(),
    findsOneWidget,
    reason: 'Unreachable HLP control $key',
  );
  return target;
}

void main() {
  testWidgets(
    'new authored theory actual AppRoot Continue rewards five once and replay remount stay inert',
    (tester) async {
      await _mountFreshFixture(tester);
      final before = await _progress();
      expect(before['earnedXp'], 0);
      expect(before['completedTaskIds'], isNot(contains(_theoryId)));
      expect(_records(before, _theoryId), isEmpty);
      await _openRealReference(tester);
      await tester.tap(await _revealTool(tester, 'hlp02_tool_price'));
      await _settle(tester);
      final price = await _revealTool(tester, 'hlp02_source_result');
      expect(
        tester.widget<Text>(price).data,
        'Before: 8 BB\nCall: 2 BB\nAfter: 10 BB\nBreak-even threshold: 20.00%',
      );
      expect(_gradedFields(await _progress()), _gradedFields(before));
      await _startMission(tester, _theoryId);
      expect(_runner(tester).runner.options, isEmpty);
      expect(_runner(tester).runner.table.activeSeatId, 'btn');
      expect(_runner(tester).runner.teachingSteps.length, 4);
      await _completeTheory(tester);
      final completed = await _progress();
      expect(
        completed['learningEvidenceHistory'],
        before['learningEvidenceHistory'],
      );
      expect(
        completed['completedTaskIds'],
        unorderedEquals([...(before['completedTaskIds'] as List), _theoryId]),
      );
      expect(completed['earnedXp'], 5);
      expect(completed['completedTaskIds'], contains(_theoryId));
      expect(_records(completed, _theoryId), isEmpty);
      expect(_records(completed, _pairId), isEmpty);
      expect(completed['openRepairIntents'], before['openRepairIntents']);
      await _replayFromLearn(tester, _theoryId);
      await _completeTheory(tester);
      final replay = await _progress();
      expect(_gradedFields(replay), _gradedFields(completed));
      await tester.pumpWidget(const SizedBox.shrink());
      await _settle(tester);
      await tester.pumpWidget(const AppRoot());
      await _settle(tester);
      final restored = await _progress();
      expect(_gradedFields(restored), _gradedFields(completed));
      await _replayFromLearn(tester, _theoryId);
      await _completeTheory(tester);
      expect(_gradedFields(await _progress()), _gradedFields(completed));
      expect(tester.takeException(), isNull);
    },
  );
}
