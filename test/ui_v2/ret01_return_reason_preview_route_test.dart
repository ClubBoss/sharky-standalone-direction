// RET-01 technical package: the real Preview -> fromSources -> copyLine route.
// MACHINE-only widget checks on the EN Preview harness. Not Human proof.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_shell_presentation_finders_v1.dart';

const String _retryLine = 'Your last repair did not land yet. Start there.';
const String _resumeLine = 'Resume your most recent table read.';
const String _continueLine =
    'You missed this clue last time. One more clean rep will keep it visible.';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('failed repair keeps the unfinished-repair reason on Home', (
    tester,
  ) async {
    await _pumpPreview(tester);
    await _answerOption(tester, 'fold');
    await _launchHomeRepair(tester);
    await _advanceTeachingToDrill(tester);
    expect(_activeTaskId(tester), contains('actions_check_drill'));
    await _answerWrongly(tester);
    await _continueAfterFeedback(tester);

    expect(_homeLine(tester), _continueLine);
  });

  testWidgets('a failed then landed repair is not reported as not landed', (
    tester,
  ) async {
    await _pumpPreview(tester);
    await _answerOption(tester, 'fold');

    await _launchHomeRepair(tester);
    await _advanceTeachingToDrill(tester);
    expect(_activeTaskId(tester), contains('actions_check_drill'));
    await _answerWrongly(tester);
    await _continueAfterFeedback(tester);

    await _launchHomeRepair(tester);
    await _advanceTeachingToDrill(tester);
    expect(_activeTaskId(tester), contains('actions_check_drill'));
    await _answerCorrectly(tester);
    await _continueAfterFeedback(tester);

    // Route truth check, not the regression guard: the Preview mask may hide
    // the retry here even without the fix (see the reducer tests).
    expect(_conceptFamilies(tester), isNotEmpty);
    final line = _homeLine(tester);
    expect(line, isNot(_retryLine));
    expect(line, _resumeLine);
  });

  test('garbled last-session dates never count as a consecutive return', () {
    for (final previous in <String>[
      '',
      'not-a-date',
      '2026-13-45',
      '11/11/2026',
      '2026-11-12',
    ]) {
      expect(
        act0AreConsecutiveCivilDaysV1(previous, '2026-11-12'),
        isFalse,
        reason: previous,
      );
    }
    expect(act0AreConsecutiveCivilDaysV1('2026-11-11', '2026-11-12'), isTrue);
  });
}

Future<void> _pumpPreview(WidgetTester tester) async {
  // Agreed reference profile: EN iPhone 14 Pro portrait, 393x852 logical.
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
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
        state: _stateForTasks(const <String>[
          'actions_legal_context',
          'actions_check_drill',
        ]),
        debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
          mode: Act0ControlledDemoCaptureModeV1.directState,
          surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_legal_context',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0ShellStateV1 _stateForTasks(List<String> taskIds) {
  final sample = Act0ShellStateV1.sample;
  final baseWorld = sample.worldById('world_1');
  final baseLesson = baseWorld.lessons.firstWhere(
    (lesson) => lesson.lessonId == 'fold_check_call_raise',
  );
  final lesson = baseLesson.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
    primaryCtaLabel: 'Open lesson',
    tasks: <Act0LessonTaskV1>[
      for (final taskId in taskIds)
        baseLesson.taskList.firstWhere((task) => task.taskId == taskId),
    ],
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

Future<void> _answerOption(WidgetTester tester, String optionId) async {
  final option = find.byKey(Key('act0_shell_option_$optionId'));
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _answerCorrectly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  await _answerOption(
    tester,
    runner.runner.options.firstWhere((option) => option.isCorrect).id,
  );
}

Future<void> _answerWrongly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  await _answerOption(
    tester,
    runner.runner.options.firstWhere((option) => !option.isCorrect).id,
  );
}

Future<void> _continueAfterFeedback(WidgetTester tester) async {
  final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
  if (cta.evaluate().isNotEmpty) {
    await tester.ensureVisible(cta);
    await tester.tap(cta, warnIfMissed: false);
    await tester.pumpAndSettle();
  }
}

Future<void> _launchHomeRepair(WidgetTester tester) async {
  final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
  if (runnerBack.evaluate().isNotEmpty) {
    await tester.ensureVisible(runnerBack);
    await tester.tap(runnerBack, warnIfMissed: false);
    await tester.pumpAndSettle();
  }
  final homeTab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Home'),
  );
  await tester.ensureVisible(homeTab);
  await tester.tap(homeTab, warnIfMissed: false);
  await tester.pumpAndSettle();
  final mainCta = act0ShellPresentationFinderV1('act0_shell_main_cta');
  await tester.ensureVisible(mainCta);
  await tester.tap(mainCta, warnIfMissed: false);
  await tester.pumpAndSettle();
}

Future<void> _advanceTeachingToDrill(WidgetTester tester) async {
  const ctaKeys = <String>[
    'act0_shell_selected_lesson_cta',
    'act0_shell_current_mission_cta',
    'act0_shell_runner_primary_cta',
    'act0_shell_continue_cta',
    'act0_shell_theory_continue_cta',
  ];
  for (var i = 0; i < 12; i++) {
    if (_hasVisibleAnswer()) return;
    var tapped = false;
    for (final key in ctaKeys) {
      final finder = find.byKey(Key(key));
      if (finder.evaluate().isNotEmpty) {
        await tester.ensureVisible(finder);
        await tester.tap(finder, warnIfMissed: false);
        await tester.pumpAndSettle();
        tapped = true;
        break;
      }
    }
    if (!tapped) {
      final featured = act0ShellPresentationFinderV1(
        'act0_shell_play_featured_cta',
      );
      if (featured.evaluate().isNotEmpty) {
        await tester.tap(featured);
        await tester.pumpAndSettle();
        continue;
      }
      await tester.pumpAndSettle();
    }
  }
  if (!_hasVisibleAnswer()) fail('Runner did not reach a visible answer.');
}

bool _hasVisibleAnswer() =>
    find.byKey(const Key('act0_shell_action_panel')).evaluate().isNotEmpty ||
    find
        .byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('act0_shell_option_');
        })
        .evaluate()
        .isNotEmpty;

String _activeTaskId(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugSelectedTaskIdV1() as String;
}

String? _homeLine(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugHomePersonalizedReturnReasonLineV1() as String?;
}

List<Map<String, Object?>> _conceptFamilies(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return (state.debugConceptFamilyStatePayloadV1() as List<Object?>)
      .cast<Map<String, Object?>>();
}
