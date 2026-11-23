import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _previewTableKey = Key('act0_nine_seat_debug_table');

void main() {
  test('registered-six geometry retains the exact image transform', () {
    final profile = act0PremiumTableSceneProfileV1;
    final registration = profile.register(const Size(393, 852));
    final geometry = TableGeometryV1.registered(registration);
    expect(geometry.seatAnchors, hasLength(6));
    expect(
      geometry.seatAnchors.map(geometry.map).toList(),
      profile.seatAnchorsFromHero.map(registration.map).toList(),
    );
    expect(
      geometry.map(geometry.potAnchor),
      registration.map(profile.potAnchor),
    );
  });

  test('preview geometry resolves distinct slots for each supported count', () {
    const viewport = Size(375, 400);
    for (var count = 2; count <= 9; count++) {
      final geometry = TableGeometryV1.preview(
        viewport: viewport,
        seatCount: count,
      );
      for (final anchors in [
        geometry.seatAnchors,
        geometry.betAnchors,
        geometry.dealerAnchors,
        geometry.cardAnchors,
      ]) {
        final positions = anchors.map(geometry.map).toSet();
        expect(positions, hasLength(count));
        expect(
          positions.every((point) => (Offset.zero & viewport).contains(point)),
          isTrue,
        );
      }
    }
  });

  testWidgets('learner Play skips the nine-seat task with the flag off', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setReferenceViewport(tester);
    final sample = Act0ShellStateV1.sample;
    final current = sample.currentLesson;
    final nineSeatTask = Act0LessonTaskV1(
      taskId: 'b33_full_ring_task',
      title: 'Full-ring task',
      phase: Act0LessonPhaseV1.drill,
      runner: _nineSeatRunner(),
      rewardXp: 0,
    );
    final lessons = [
      for (final lesson in sample.lessons)
        if (lesson.lessonId == current.lessonId)
          lesson.copyWith(tasks: [nineSeatTask, ...lesson.taskList])
        else
          lesson,
    ];
    final state = Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: sample.levelLabel,
      xp: sample.xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: sample.selectedWorldId,
      worlds: [
        for (final world in sample.worlds)
          if (world.worldId == sample.selectedWorldId)
            world.copyWith(lessons: lessons)
          else
            world,
      ],
      lessons: lessons,
      review: sample.review,
      profile: sample.profile,
    );

    await tester.pumpWidget(
      _app(
        Act0NineSeatDebugScopeV1(
          enabled: false,
          child: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            showPlacementOnStart: false,
            state: state,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, current.courseTaskList.first.taskId);
    expect(find.byKey(_previewTableKey), findsNothing);
  });

  testWidgets('nine-seat runner needs debug opt-in and can submit a choice', (
    tester,
  ) async {
    _setReferenceViewport(tester);
    final runner = _nineSeatRunner();
    final choices = <String>[];

    Widget entry({required bool enabled}) => _app(
      Act0NineSeatDebugScopeV1(
        enabled: enabled,
        child: Act0LessonRunnerShellV1(
          runner: runner,
          worldNumber: 1,
          selectedTaskFamily: Act0TaskFamilyV1.decision,
          tableChoreographyMode: Act0TableChoreographyModeV1.settled,
          onBack: () {},
          onContinueTheory: () {},
          onContinueReview: () {},
          onChooseOption: (option) => choices.add(option.id),
        ),
      ),
    );

    await tester.pumpWidget(entry(enabled: false));
    await tester.pumpAndSettle();
    expect(find.byKey(_previewTableKey), findsNothing);
    expect(find.byKey(const Key('act0_shell_option_fold')), findsNothing);

    await tester.pumpWidget(entry(enabled: true));
    await tester.pumpAndSettle();
    expect(find.byKey(_previewTableKey), findsOneWidget);
    final centers = <Offset>{};
    for (final seat in runner.table.seats) {
      final widget = find.byKey(Key('act0_shell_seat_node_${seat.seatId}'));
      expect(widget, findsOneWidget);
      centers.add(tester.getCenter(widget));
    }
    expect(centers, hasLength(9));
    expect(find.byKey(const Key('act0_f7_baked_room_cast_hero')), findsNothing);
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    expect(choices, ['fold']);
  });
}

void _setReferenceViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(body: child),
);

Act0RunnerStateV1 _nineSeatRunner() {
  const format = Act0TableFormatV1.nineMax;
  final base = Act0ShellStateV1.sample.currentLesson.runner;
  return base.copyWith(
    phase: Act0LessonPhaseV1.drill,
    question: 'What would you do here?',
    teachingSteps: const [],
    options: const [
      Act0RunnerOptionV1(
        id: 'fold',
        label: 'Fold',
        isCorrect: false,
        preferredLabel: 'Continue',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: '',
        feedbackReason: '',
      ),
      Act0RunnerOptionV1(
        id: 'call',
        label: 'Call',
        isCorrect: true,
        preferredLabel: 'Call',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: '',
        feedbackReason: '',
      ),
    ],
    table: Act0TableStateV1(
      scope: Act0TableScopeV1.playedHand,
      tableFormat: format,
      playerCount: 9,
      seats: [
        for (final position in act0CanonicalSeatOrderForFormatV1(format))
          Act0SeatStateV1(
            seatId: position.toLowerCase(),
            seatLabel: position,
            displayName: position,
            isHero: position == 'BTN',
            isDealerButton: position == 'BTN',
            isActive: position == 'BTN',
            stackLabel: '100 BB',
          ),
      ],
      heroCards: const [
        Act0CardStateV1(rank: 'A', suit: 's'),
        Act0CardStateV1(rank: 'K', suit: 'd'),
      ],
      boardCards: const [],
      streetLabel: 'Preflop',
      potLabel: 'Pot 1.5 BB',
      toCallLabel: 'To call 1 BB',
      centerLabel: '',
      autoPlayHistory: false,
      activeSeatId: 'btn',
      decisionSeatId: 'btn',
      heroSeatId: 'btn',
      highlightedSeatIds: const [],
      highlightedCardIds: const [],
    ),
  );
}
