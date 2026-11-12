import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/features/hst06/pokerstars_text_v1.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'hst06_review_route_proposal_test.dart' as fixture;

// Real host callback/repair integration with source-owned W1 tasks and synthetic
// initial harness state. NOT AppRoot cold-start or genuine-user-history proof.
void main() {
  testWidgets('personal-hand chooser launches actual existing W1 repair', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final saved = await Hst06PersonalStore().confirm(
      Hst06PokerStarsPreview().parse(fixture.synthetic).single,
    );
    await _pumpLifecycleHost(
      tester,
      viewport: const Size(393, 852),
      state: _stateForFoldCheckCallRaiseTasks([
        'actions_check_drill',
        'actions_legal_context',
      ]),
      taskId: 'actions_check_drill',
    );
    await _advanceTeachingToDrill(tester);
    expect(_openRepairIntentPayload(tester, 'actions_check_drill'), isNull);
    expect(_openRepairIntentCount(tester), 0);
    await _answerOption(tester, 'fold');
    final debt = _openRepairIntentPayload(tester, 'actions_check_drill');
    expect(debt?['targetTaskId'], 'actions_legal_context');
    expect(_openRepairIntentCount(tester), 1);
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('act0_shell_bottom_nav')),
        matching: find.text('Review'),
      ),
    );
    await tester.pumpAndSettle();
    final leaf = tester.widget<Act0AcademyReviewLeafV1>(
      find.byType(Act0AcademyReviewLeafV1),
    );
    final source = leaf.input.openMistakes.singleWhere(
      (m) => m.taskId == 'actions_check_drill',
    );
    final before = (await fixture.snapshot())[Hst06PersonalStore.storageKey];
    await fixture.open(tester);
    final choose = find.byKey(Key('hst06-learning-' + saved.stored!.localId));
    await tester.ensureVisible(choose);
    await tester.pumpAndSettle();
    await tester.tap(choose);
    await tester.pumpAndSettle();
    await tester.tap(find.text(source.title).last);
    await tester.pumpAndSettle();
    expect(find.byType(Hst06PersonalHandScreen), findsNothing);
    expect(_activeTaskId(tester), 'actions_legal_context');
    expect(
      _openRepairIntentPayload(tester, 'actions_check_drill'),
      debt,
      reason: 'Opening repair must not clear the debt.',
    );
    expect((await fixture.snapshot())[Hst06PersonalStore.storageKey], before);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpLifecycleHost(
  WidgetTester tester, {
  required Act0ShellStateV1 state,
  required String taskId,
  Act0InMemoryTelemetrySinkV1? telemetrySink,
  Size viewport = const Size(1200, 1600),
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
        state: state,
        telemetrySink: telemetrySink,
        debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
          mode: Act0ControlledDemoCaptureModeV1.directState,
          surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: taskId,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0ShellStateV1 _stateForFoldCheckCallRaiseTasks(List<String> taskIds) {
  final sample = Act0ShellStateV1.sample;
  final baseWorld = sample.worldById('world_1');
  final baseLesson = baseWorld.lessons.firstWhere(
    (lesson) => lesson.lessonId == 'fold_check_call_raise',
  );
  final tasks = <Act0LessonTaskV1>[
    for (final taskId in taskIds)
      baseLesson.taskList.firstWhere((task) => task.taskId == taskId),
  ];
  final lesson = baseLesson.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
    primaryCtaLabel: 'Open lesson',
    tasks: tasks,
  );
  final world = baseWorld.copyWith(
    status: Act0WorldStateV1.current,
    isSelectable: true,
    isLocked: false,
    lessons: <Act0LessonCardV1>[lesson],
  );

  return Act0ShellStateV1(
    courseTitle: sample.courseTitle,
    courseSubtitle: sample.courseSubtitle,
    levelLabel: sample.levelLabel,
    xp: sample.xp,
    xpTarget: sample.xpTarget,
    streakDays: sample.streakDays,
    dailyGoalLabel: sample.dailyGoalLabel,
    dailyGoalValue: sample.dailyGoalValue,
    pathProgressLabel: sample.pathProgressLabel,
    selectedWorldId: 'world_1',
    worlds: <Act0WorldCardV1>[world],
    lessons: <Act0LessonCardV1>[lesson],
    review: sample.review,
    profile: sample.profile,
  );
}

Future<void> _advanceTeachingToDrill(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    if (_hasVisibleAnswer()) {
      return;
    }
    final selectedLessonCta = find.byKey(
      const Key('act0_shell_selected_lesson_cta'),
    );
    if (selectedLessonCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(selectedLessonCta);
      await tester.tap(selectedLessonCta, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final currentMissionCta = find.byKey(
      const Key('act0_shell_current_mission_cta'),
    );
    if (currentMissionCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(currentMissionCta);
      await tester.tap(currentMissionCta, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final featuredCta = find.byKey(const Key('act0_shell_play_featured_cta'));
    if (featuredCta.evaluate().isNotEmpty) {
      await tester.tap(featuredCta);
      await tester.pumpAndSettle();
      continue;
    }
    final dailyGroup = find.byKey(const Key('act0_shell_practice_group_daily'));
    if (dailyGroup.evaluate().isNotEmpty) {
      await tester.tap(dailyGroup);
      await tester.pumpAndSettle();
      continue;
    }
    final cta = find.byKey(const Key('act0_shell_runner_primary_cta'));
    if (cta.evaluate().isNotEmpty) {
      await tester.tap(cta);
      await tester.pumpAndSettle();
      continue;
    }
    final continueButton = find.byKey(const Key('act0_shell_continue_cta'));
    if (continueButton.evaluate().isNotEmpty) {
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      continue;
    }
    final continueCta = find.byKey(const Key('act0_shell_theory_continue_cta'));
    if (continueCta.evaluate().isNotEmpty) {
      await tester.tap(continueCta);
      await tester.pumpAndSettle();
      continue;
    }
    await tester.pumpAndSettle();
  }
  if (_hasVisibleAnswer()) {
    return;
  }
  fail('Runner did not reach a visible answer surface.');
}

bool _hasVisibleAnswer() {
  return find
          .byKey(const Key('act0_shell_action_panel'))
          .evaluate()
          .isNotEmpty ||
      find
          .byWidgetPredicate((widget) {
            final key = widget.key;
            return key is ValueKey<String> &&
                key.value.startsWith('act0_shell_option_');
          })
          .evaluate()
          .isNotEmpty;
}

Future<void> _answerOption(WidgetTester tester, String optionId) async {
  final option = find.byKey(Key('act0_shell_option_$optionId'));
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Map<String, Object?>? _openRepairIntentPayload(
  WidgetTester tester,
  String sourceTaskId,
) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugOpenRepairIntentPayloadForSourceTaskV1(sourceTaskId)
      as Map<String, Object?>?;
}

int _openRepairIntentCount(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugOpenRepairIntentCountV1() as int;
}

String _activeTaskId(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugSelectedTaskIdV1() as String;
}
