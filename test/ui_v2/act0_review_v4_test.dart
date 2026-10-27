import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_v4.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const reviewV4Modes = ['multi', 'single', 'zero', 'due', 'both', 'fresh'];
final reviewV4Now = DateTime.utc(2026, 10, 27, 12);
final _sourceWorld = Act0ShellStateV1.sample.worlds.first;
final _tasks = <String, String>{
  'actions_check_drill': 'fold_check_call_raise',
  'what_poker_is_find_hero': 'what_poker_is',
  'what_poker_is_table_read_transfer': 'what_poker_is',
};
Act0LessonTaskV1 _task(String id) => _sourceWorld.lessons
    .singleWhere((l) => l.lessonId == _tasks[id])
    .taskList
    .singleWhere((t) => t.taskId == id);
Act0RepairIntentV1 reviewV4Intent(String id) {
  final task = _task(id);
  final intent = buildAct0RepairIntentV1(
    sourceWorldId: 'world_1',
    sourceLessonId: _tasks[id]!,
    sourceTaskId: id,
    runner: task.runner,
    selectedOption: task.runner.options.firstWhere((o) => !o.isCorrect),
    mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
  );
  if (intent == null) throw StateError('No canonical repair for fixture $id');
  return intent;
}

/// Restored QA state, built from canonical source tasks/intents. Not earned work.
Map<String, Object> reviewV4Fixture(String mode) {
  final ids = mode == 'multi'
      ? _tasks.keys.toList()
      : ['single', 'both'].contains(mode)
      ? ['actions_check_drill']
      : <String>[];
  final hasDue = mode == 'due' || mode == 'both';
  final p = <String, Object>{
    'schemaVersion': 18,
    'completedTaskIds': <String>[],
    'completedLessonIds': <String>[],
    'skippedTaskIds': <String>[],
    'selectedWorldId': 'world_1',
    'selectedLessonId': 'what_poker_is',
    'selectedTaskId': 'what_poker_is_theory',
    'earnedXp': 0,
    'persistedStreakDays': 0,
    'dailyCompletedRepCount': 0,
    'lastEarnedDailyDay': '',
    'lastActiveDay': '2026-10-27',
    'resumeInRunner': false,
    'openRepairIntents': [for (final id in ids) reviewV4Intent(id).toPayload()],
    'retentionMemory': [
      for (final id in ids)
        {
          'taskId': id,
          'lessonId': _tasks[id]!,
          'worldId': 'world_1',
          'status': 'openRepair',
          'attempts': 1,
          'fixedAtSequence': 0,
          'lastRecheckSequence': 0,
          'successfulRecheckCount': 0,
        },
      if (mode == 'zero')
        {
          'taskId': 'actions_check_drill',
          'lessonId': 'fold_check_call_raise',
          'worldId': 'world_1',
          'status': 'fixedRecent',
          'attempts': 1,
          'fixedAtSequence': 1,
          'lastRecheckSequence': 0,
          'successfulRecheckCount': 0,
        },
    ],
    'durableRetentionHistory': [
      if (hasDue)
        {
          'schemaVersion': 1,
          'conceptFamilyId': mode == 'both'
              ? 'hero_cards_board_pot'
              : 'no_bet_yet',
          'worldId': 'world_1',
          'sourceLessonId': mode == 'both'
              ? 'what_poker_is'
              : 'fold_check_call_raise',
          'sourceTaskId': mode == 'both'
              ? 'what_poker_is_table_read_recheck'
              : 'actions_check_drill',
          'retentionState': 'recoveredPendingSpacedReview',
          'nextDueAtUtc': '2026-10-26T12:00:00.000Z',
          'spacedSuccessStage': 0,
          'lapseCount': 0,
          'incorrectCount': 1,
          'correctCount': 1,
          'lastRecordedAtUtc': '2026-10-25T12:00:00.000Z',
          'lastCreatedOrder': 2,
          'lastSessionId': 'session_v1|1',
          'lastReviewKind': 'immediateRepair',
          'hasLegacyUnspacedEvidence': false,
        },
    ],
  };
  return {
    'act0_shell_progress_v1': jsonEncode(p),
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
  };
}

Finder _key(String key) => find.byKey(Key(key));
Future<void> _mount(WidgetTester t, String mode) async {
  SharedPreferences.setMockInitialValues(reviewV4Fixture(mode));
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  await t.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.review,
        showPlacementOnStart: false,
        clock: Act0FixedUtcClockV1(reviewV4Now),
      ),
    ),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Act0ReviewShellV1 _source(WidgetTester t) =>
    t.widget<Act0ReviewShellV1>(find.byType(Act0ReviewShellV1));
Future<void> _reveal(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) {
    final list = _key('act0_shell_review_screen');
    await t.drag(list, const Offset(0, 1800));
    await t.pumpAndSettle();
    if (f.evaluate().isEmpty) {
      await t.scrollUntilVisible(
        f,
        150,
        scrollable: find
            .descendant(of: list, matching: find.byType(Scrollable))
            .first,
      );
    }
  }
  await t.ensureVisible(f);
  await t.pumpAndSettle();
}

Future<void> _tap(WidgetTester t, Finder f) async {
  await _reveal(t, f);
  await t.tap(f);
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

void main() {
  test(
    'export canonical task/repair fixtures, not genuine earned learning',
    () {
      final out = Directory('output/review_v4_20261027/fixtures')
        ..createSync(recursive: true);
      for (final mode in reviewV4Modes) {
        File(
          '${out.path}/$mode.json',
        ).writeAsStringSync(jsonEncode(reviewV4Fixture(mode)));
      }
      File('${out.path}/repair_targets.json').writeAsStringSync(
        jsonEncode({
          for (final id in _tasks.keys) id: reviewV4Intent(id).toPayload(),
        }),
      );
      for (final id in _tasks.keys) {
        final intent = reviewV4Intent(id);
        final w = Act0ShellStateV1.sample.worlds.singleWhere(
          (w) => w.worldId == intent.targetWorldId,
        );
        expect(
          w.lessons
              .singleWhere((l) => l.lessonId == intent.targetLessonId)
              .taskList
              .any((t) => t.taskId == intent.targetTaskId),
          isTrue,
        );
      }
    },
  );
  testWidgets('Review V4 remains opt-in and English-only dispatch', (t) async {
    await _mount(t, 'fresh');
    expect(
      find.byType(Act0ReviewV4),
      kAct0ReviewV4Preview ? findsOneWidget : findsNothing,
    );
  });
  for (final mode in reviewV4Modes) {
    testWidgets(
      'source-backed $mode Review is honest, scrollable and has one photo',
      (t) async {
        await _mount(t, mode);
        final source = _source(t);
        final projection = Directory('output/review_v4_20261027/projections')
          ..createSync(recursive: true);
        File('${projection.path}/$mode.json').writeAsStringSync(
          jsonEncode({
            'classification': 'SOURCE_BACKED_RESTORED_QA_FIXTURE',
            'open': [
              for (final m in source.review.mistakes)
                {
                  'taskId': m.taskId,
                  'title': m.title,
                  'displayTitle': act0ReviewV4MistakeTitle(m),
                  'category': m.weaknessLabel,
                  'target': reviewV4Intent(m.taskId).toPayload(),
                },
            ],
            'due': [
              for (final d in source.dueReviewItems)
                {
                  'worldId': d.worldId,
                  'lessonId': d.lessonId,
                  'taskId': d.taskId,
                },
            ],
            'fixed': [
              for (final m in source.review.fixedMistakes)
                {'taskId': m.taskId, 'title': m.title},
            ],
          }),
        );
        expect(
          source.review.mistakes.length,
          mode == 'multi'
              ? 3
              : ['single', 'both'].contains(mode)
              ? 1
              : 0,
        );
        expect(
          source.dueReviewItems.length,
          ['due', 'both'].contains(mode) ? 1 : 0,
        );
        expect(find.byType(Image), findsOneWidget);
        expect(find.text('Check when no bet'), findsNothing);
        if (source.review.mistakes.isNotEmpty)
          expect(find.text('No bet yet'), findsOneWidget);
        if (mode == 'fresh')
          expect(find.text('No saved mistakes yet'), findsOneWidget);
        if (mode == 'zero') expect(find.text('All caught up'), findsOneWidget);
        if (['due', 'both'].contains(mode))
          expect(find.text('1 independent review due'), findsOneWidget);
        if (mode == 'single')
          expect(find.text('OTHER MISTAKES TO REVIEW'), findsNothing);
        expect(find.text('Fix all'), findsNothing);
        expect(find.text('100% mastered'), findsNothing);
        final last = source.review.mistakes.lastOrNull;
        if (source.review.mistakes.length > 1)
          await _reveal(t, _key('act0_review_v4_mistake_${last!.taskId}'));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(_key('act0_shell_bottom_nav'), findsOneWidget);
      },
      skip: !kAct0ReviewV4Preview,
    );
  }
  testWidgets(
    'each open mistake routes to its own canonical mapped repair and returns to Review',
    (t) async {
      await _mount(t, 'multi');
      final order = _source(t).review.mistakes.toList();
      for (var i = 0; i < order.length; i++) {
        final m = order[i];
        final intent = reviewV4Intent(m.taskId);
        await _tap(
          t,
          i == 0
              ? _key('act0_shell_review_practice_cta')
              : _key('act0_review_v4_mistake_${m.taskId}'),
        );
        final runner = t.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(runner.selectedWorldId, intent.targetWorldId);
        expect(runner.selectedLessonId, intent.targetLessonId);
        expect(runner.selectedTaskId, intent.targetTaskId);
        expect(runner.reviewKindId, isNot('spacedReview'));
        await _tap(t, _key('act0_shell_runner_back'));
        expect(find.byType(Act0ReviewV4), findsOneWidget);
      }
    },
    skip: !kAct0ReviewV4Preview,
  );
  for (final mode in ['due', 'both']) {
    testWidgets(
      '$mode due uses independent flow with exact source identity',
      (t) async {
        await _mount(t, mode);
        final due = _source(t).dueReviewItems.single;
        if (mode == 'both')
          expect(due.taskId, isNot(_source(t).review.mistakes.single.taskId));
        await _tap(t, _key('act0_shell_review_start_due_spaced_item'));
        final runner = t.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(runner.reviewKindId, 'spacedReview');
        expect(runner.selectedWorldId, due.worldId);
        expect(runner.selectedLessonId, due.lessonId);
        expect(runner.selectedTaskId, due.taskId);
      },
      skip: !kAct0ReviewV4Preview,
    );
  }
  testWidgets(
    'gateway excludes answers, reasons, chosen action and aggregate spoiler fields',
    (t) async {
      const m = Act0MistakeCardV1(
        taskId: 'actions_check_drill',
        lessonId: 'fold_check_call_raise',
        title: 'No bet yet',
        weaknessLabel: 'Action read',
        selectedOptionId: 'fold',
        selectedLabel: 'SECRET_CHOSEN',
        betterLabel: 'SECRET_ANSWER',
        reason: 'SECRET_EXPLANATION',
        attempts: 1,
      );
      const r = Act0ReviewStateV1(
        title: 'Review',
        subtitle: 'SECRET_SUBTITLE',
        weaknessLabel: 'Action read',
        reason: 'SECRET_REASON',
        stats: [],
        chosenLabel: 'SECRET_CHOSEN',
        betterLabel: 'SECRET_ANSWER',
        mistakes: [m],
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0ReviewShellV1(
              review: r,
              selected: null,
              onSelected: (_) {},
              onFixMistake: (_) {},
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.textContaining('SECRET_'), findsNothing);
      expect(find.text('No bet yet'), findsOneWidget);
    },
    skip: !kAct0ReviewV4Preview,
  );
  testWidgets(
    'fresh fallback opens existing Learn; fixed replay remains optional',
    (t) async {
      await _mount(t, 'fresh');
      await _tap(t, _key('act0_review_v4_learn'));
      expect(find.byType(Act0ReviewV4), findsNothing);
      await t.pumpWidget(const SizedBox.shrink());
      await _mount(t, 'zero');
      await _tap(t, _key('act0_review_v4_past_repairs'));
      expect(find.text('Past repair · optional replay'), findsOneWidget);
      await _tap(t, _key('act0_shell_fixed_mistake_actions_check_drill'));
      expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
    },
    skip: !kAct0ReviewV4Preview,
  );
}
