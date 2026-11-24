import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

const _enabled = bool.fromEnvironment('actionReasonV1');
const _key = 'act0_shell_progress_v1';
const _source = 'w4_good_price_call';
final _now = DateTime.utc(2026, 11, 24, 10);

void main() {
  test('pilot tasks and changed scenarios have distinct canonical inputs', () {
    expect(act0ActionReasonPilotsV1, hasLength(12));
    final seen = <String>[];
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          final pilot = act0ActionReasonPilotsV1[task.taskId];
          if (pilot == null) continue;
          expect(world.worldNumber, inInclusiveRange(4, 8));
          expect(task.multiStreet, isNull);
          expect(
            task.reasons!.map((reason) => reason.grade).toSet(),
            Act0ReasonGradeV1.values.toSet(),
          );
          final retest = lesson.taskList.singleWhere(
            (candidate) => candidate.taskId == pilot.retestTaskId,
          );
          expect(
            retest.runner.options.any((option) => option.isCorrect),
            isTrue,
          );
          expect((
            retest.runner.caption,
            retest.runner.question,
          ), isNot((task.runner.caption, task.runner.question)));
          seen.add(task.taskId);
        }
      }
    }
    expect(seen, unorderedEquals(act0ActionReasonPilotsV1.keys));
  });

  for (final (action, reason, message, isCorrect) in [
    ('call', 1, 'Right move and sound reasoning', true),
    ('call', 0, 'Right move, but not for that reason', false),
    ('fold', 1, 'Sound reasoning, wrong move', false),
    ('fold', 0, 'Revisit the move and the reason', false),
  ]) {
    testWidgets('$message is shown and archived as graded', (tester) async {
      _init(tester);
      await _openSource(tester);
      await _tap(tester, 'act0_shell_option_$action');
      expect(find.text('Why?'), findsOneWidget);
      expect((await _archive()).attempts, isEmpty);
      await _tap(tester, 'act0_action_reason_$reason');
      expect(find.text(message), findsOneWidget);
      final attempt = (await _archive()).attempts.single;
      expect(attempt.evidence.isIndependentCorrect, isCorrect);
      expect(attempt.actionReason!.actionCorrect, action == 'call');
      if (action == 'call' && reason == 0) {
        expect(find.textContaining('Repair · Call price'), findsOneWidget);
        expect(
          find.textContaining(Act0MisconceptionTagV1.price.repair),
          findsOneWidget,
        );
      }
      if (action == 'fold' && reason == 1) {
        expect(find.textContaining('Fold does not follow'), findsOneWidget);
      }
    }, skip: !_enabled);
  }

  testWidgets(
    'lucky correct earns repaired XP and reloads into changed Day 2',
    (tester) async {
      _init(tester);
      await _openSource(tester);
      await _tap(tester, 'act0_shell_option_call');
      await _tap(tester, 'act0_action_reason_0');
      await tester.tap(find.widgetWithText(TextButton, 'Continue').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      final before = (await _archive()).attempts.single.actionReason!
          .toPayload();
      expect((await _snapshot())['earnedXp'], 7);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _host(review: true, now: _now.add(const Duration(hours: 24))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reason repairs'), findsOneWidget);
      expect(find.text('Call price'), findsOneWidget);
      const legacy = 'act0_shell_review_start_due_spaced_item';
      const academy = 'act0_academy_review_leaf_start_due';
      final cta = find.byKey(const Key(legacy)).evaluate().isNotEmpty
          ? legacy
          : academy;
      await _tap(tester, cta);
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, 'w4_bad_price_fold');
      expect(
        (await _archive()).attempts.single.actionReason!.toPayload(),
        before,
      );
    },
    skip: !_enabled,
  );

  testWidgets('default flag preserves action route, XP and archive encoding', (
    tester,
  ) async {
    _init(tester);
    await _openSource(tester);
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.reasons, isNull);
    await _tap(tester, 'act0_shell_option_call');
    expect(find.text('Why?'), findsNothing);
    await _tap(tester, 'act0_shell_feedback_continue_cta');
    final snapshot = await _snapshot();
    expect(snapshot['earnedXp'], 7);
    final attempt = (await _archive()).attempts.single;
    expect(attempt.evidence.isIndependentCorrect, isTrue);
    expect(attempt.actionReason, isNull);
    final withPilot = await _snapshotBytes();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    _resetPreferences();
    await _openSource(tester, _legacyFixture);
    await _tap(tester, 'act0_shell_option_call');
    expect(find.text('Why?'), findsNothing);
    await _tap(tester, 'act0_shell_feedback_continue_cta');
    expect(await _snapshotBytes(), withPilot);
  }, skip: _enabled);
}

void _resetPreferences() {
  SharedPreferences.setMockInitialValues({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
  });
}

void _init(WidgetTester tester) {
  _resetPreferences();
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

final _fixture = _buildFixture();
final _legacyFixture = _buildFixture(includeReasons: false);

class _TaskWithoutReasons extends Act0LessonTaskV1 {
  _TaskWithoutReasons(Act0LessonTaskV1 source)
    : super(
        taskId: source.taskId,
        title: source.title,
        phase: source.phase,
        runner: source.runner,
        rewardXp: source.rewardXp,
        stepKind: source.stepKind,
        taskFamily: source.taskFamily,
        tablePresentation: source.tablePresentation,
        repairOnly: source.repairOnly,
        guidedDecision: source.guidedDecision,
        summary: source.summary,
        lockedSummary: source.lockedSummary,
        multiStreet: source.multiStreet,
      );

  @override
  List<Act0ReasonV1>? get reasons => null;
}

Act0ShellStateV1 _buildFixture({bool includeReasons = true}) {
  final base = Act0ShellStateV1.sample;
  final w4 = base.worldById('world_4');
  final price = w4.lessons.singleWhere(
    (lesson) => lesson.lessonId == 'call_price',
  );
  final tasks = price.taskList
      .where(
        (task) => task.taskId == _source || task.taskId == 'w4_bad_price_fold',
      )
      .map((task) => includeReasons ? task : _TaskWithoutReasons(task))
      .toList();
  final lesson = price.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
    runner: tasks.first.runner,
    tasks: tasks,
  );
  final world = w4.copyWith(
    status: Act0WorldStateV1.current,
    isSelectable: true,
    isLocked: false,
    lessons: [lesson],
  );
  return Act0ShellStateV1(
    courseTitle: base.courseTitle,
    courseSubtitle: base.courseSubtitle,
    levelLabel: base.levelLabel,
    xp: 0,
    xpTarget: base.xpTarget,
    streakDays: 0,
    dailyGoalLabel: base.dailyGoalLabel,
    dailyGoalValue: base.dailyGoalValue,
    pathProgressLabel: base.pathProgressLabel,
    selectedWorldId: world.worldId,
    worlds: [world],
    lessons: [lesson],
    review: base.review,
    profile: base.profile,
  );
}

Widget _host({bool review = false, DateTime? now, Act0ShellStateV1? state}) =>
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        state: state ?? _fixture,
        debugPersistFixtureProgress: true,
        initialTab: review ? Act0ShellTabV1.review : Act0ShellTabV1.home,
        initialPhase: Act0LessonPhaseV1.drill,
        clock: Act0FixedUtcClockV1(now ?? _now),
        showPlacementOnStart: false,
        enableBetaMetrics: false,
      ),
    );

Future<void> _openSource(WidgetTester tester, [Act0ShellStateV1? state]) async {
  await tester.pumpWidget(_host(state: state));
  await tester.pumpAndSettle();
  const legacy = 'act0_shell_main_cta';
  const academy = 'act0_academy_home_leaf_cta';
  final cta = find.byKey(const Key(academy)).hitTestable().evaluate().isEmpty
      ? legacy
      : academy;
  await _tap(tester, cta);
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  expect(runner.selectedTaskId, _source);
  await pumpSourceChoreographyToDecisionV1(tester, runner.runner.table);
}

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  await tester.ensureVisible(target);
  await tester.tap(target.hitTestable());
  await tester.pumpAndSettle();
}

Future<String?> _snapshotBytes() async =>
    (await SharedPreferences.getInstance()).getString(_key);

Future<Map<String, Object?>> _snapshot() async {
  final raw = await _snapshotBytes();
  return raw == null ? {} : Map<String, Object?>.from(jsonDecode(raw) as Map);
}

Future<Act0AttemptArchiveV1> _archive() async {
  final snapshot = await _snapshot();
  final evidence = Act0LearningEvidenceHistoryV1.restore(
    snapshot['learningEvidenceHistory'],
    snapshot['learningEvidenceLineage'],
  );
  return Act0AttemptArchiveV1.restore(
    snapshot['attemptArchive'],
    snapshotRecords: evidence?.records ?? const [],
  );
}
