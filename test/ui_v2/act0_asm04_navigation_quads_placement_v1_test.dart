import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

final _catalog = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  // The eight Chat J controls, plus the two adjacent bucket labels sharing
  // exactly the same navigation disclosure. No catalog-wide semantic census.
  const titles = {
    'w4_good_price_call': 'Price decision 1',
    'w4_bad_price_fold': 'Price decision 2',
    'hand_discipline_buckets_premium': 'Starting hand 1',
    'hand_discipline_buckets_strong': 'Starting hand 2',
    'hand_discipline_buckets_medium': 'Starting hand 3',
    'hand_discipline_buckets_trash': 'Starting hand 4',
    'w6_missed_dry_board': 'Dry-board decision',
    'w11_trigger_bad_price_fold': 'Price under pressure',
    'w9_m_ratio_red_zone': 'Stack-pressure decision',
    'w12_revenge_raise_trap': 'Next-hand decision',
  };
  for (final entry in titles.entries) {
    testWidgets('J1 actual Learn consumer neutralizes ${entry.key}', (
      tester,
    ) async {
      _phone(tester);
      final row = _catalog.singleWhere(
        (r) => r.task.taskId.endsWith(entry.key),
      );
      final source = row.task;
      print('J1 canonical=${source.taskId} source=${source.title}');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LearnPathShellV1(
              moduleTitle: row.world.title,
              moduleProgressLabel: '0 completed',
              worlds: [row.world],
              selectedWorldId: row.world.worldId,
              showWorldMenu: false,
              worldDetailId: null,
              lessons: [
                row.lesson.copyWith(
                  state: Act0LessonStateV1.current,
                  isSelectable: true,
                  isLocked: false,
                ),
              ],
              selectedLessonId: row.lesson.lessonId,
              selectedTaskId: source.taskId,
              activePopupTaskId: source.taskId,
              completedTaskIds: {
                for (final t in row.lesson.taskList.takeWhile(
                  (t) => t.taskId != source.taskId,
                ))
                  t.taskId,
              },
              perfectTaskIds: const {},
              skippedTaskIds: const {},
              pathClosedTaskIds: {
                for (final t in row.lesson.taskList.takeWhile(
                  (t) => t.taskId != source.taskId,
                ))
                  t.taskId,
              },
              detailLessonId: row.lesson.lessonId,
              lessonOutcomeLabels: const {},
              onSelectWorld: (_) {},
              onOpenWorldMenu: () {},
              onCloseWorldMenu: () {},
              onDismissWorldDetail: () {},
              onPreviewPremiumWorld: (_) {},
              onSelectLesson: (_) => true,
              onOpenLessonAfterScroll: (_) {},
              onDismissDetail: () {},
              onSelectTask: (_, _) {},
              onDismissTaskPopup: () {},
              onStartTask: (_, _) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(entry.value), findsWidgets);
      expect(find.text(source.title), findsNothing);
      expect(row.task, same(source));
    });
  }

  testWidgets('J2 quads pre-choice keeps cards but removes solution cues', (
    tester,
  ) async {
    _phone(tester);
    final row = _catalog.singleWhere(
      (r) => r.task.taskId == 'hand_rankings_quads_drill',
    );
    final task = row.task;
    final assistance = <String>[];
    Future<void> mount(Act0RunnerStateV1 runner) async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              theoryRecallStep: task.runner.teachingSteps.first,
              onChoiceAssistance: (value) => assistance.add(value.name),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    dynamic table() => tester.widget(
      find.byWidgetPredicate((w) => w.runtimeType.toString() == '_Act0TableV1'),
    );
    await mount(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingStepIndex: task.runner.teachingSteps.length,
      ),
    );
    expect(table().centerLabelOverride, isNot(contains('Four queens')));
    expect(table().highlightedCardIds, isEmpty);
    // Seat cards consume the projected table directly, while board cards
    // consume the merged overlay. Both paths must be neutral before choice.
    expect(table().table.highlightedCardIds, isEmpty);
    final solutionCards = <String>{};
    for (final widget in tester.widgetList(
      find.byWidgetPredicate(
        (w) => const [
          '_CardV1',
          '_BoardCardV1',
        ].contains(w.runtimeType.toString()),
      ),
    )) {
      final dynamic card = widget;
      if (const [
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
      ].contains(card.cardId)) {
        solutionCards.add(card.cardId as String);
        expect(card.highlighted, isFalse);
      }
    }
    expect(
      solutionCards,
      containsAll(['hero_0', 'hero_1', 'board_0', 'board_1']),
    );
    expect(table().table.heroCards, task.runner.table.heroCards);
    expect(table().table.boardCards, task.runner.table.boardCards);
    for (final option in task.runner.options) {
      expect(find.byKey(Key('act0_shell_option_${option.id}')), findsOneWidget);
    }
    final help = find.byKey(const Key('act0_shell_theory_recall_cta'));
    expect(help, findsOneWidget);
    await tester.ensureVisible(help);
    await tester.tap(help);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_hint_body')), findsOneWidget);
    final full = find.byKey(const Key('act0_shell_review_full_idea_cta'));
    await tester.ensureVisible(full);
    await tester.tap(full);
    await tester.pumpAndSettle();
    expect(find.text(task.runner.teachingSteps.first.body), findsWidgets);
    await tester.tap(
      find.byKey(const Key('act0_shell_theory_recall_close_cta')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_option_quads')));
    await tester.pumpAndSettle();
    expect(assistance, contains('theoryRecall'));
    await mount(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.theory,
        teachingStepIndex: 0,
      ),
    );
    expect(find.text('Quads mean all four cards.'), findsWidgets);
    expect(
      table().highlightedCardIds,
      containsAll(['hero_0', 'hero_1', 'board_0', 'board_1']),
    );
    final answer = task.runner.options.firstWhere((o) => o.isCorrect);
    await mount(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: answer.id,
        feedbackTitle: answer.feedbackTitle,
        feedbackReason: answer.feedbackReason,
      ),
    );
    expect(find.text(answer.feedbackReason), findsWidgets);
    expect(table().centerLabelOverride, 'Four queens play');
    expect(
      table().highlightedCardIds,
      containsAll(['hero_0', 'hero_1', 'board_0', 'board_1']),
    );
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'J3 ordinary Placement at scale $scale never auto-exposes hint',
      (tester) async {
        _phone(tester);
        SharedPreferences.setMockInitialValues({});
        final textScale = ValueNotifier(1.0);
        addTearDown(textScale.dispose);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => ValueListenableBuilder<double>(
              valueListenable: textScale,
              builder: (context, value, _) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: const EdgeInsets.only(top: 59, bottom: 34),
                  viewPadding: const EdgeInsets.only(top: 59, bottom: 34),
                  textScaler: TextScaler.linear(value),
                ),
                child: child!,
              ),
            ),
            home: const Act0ShellPreviewScreenV1(),
          ),
        );
        await tester.pumpAndSettle();
        Future<void> tap(Key key) async {
          final target = find.byKey(key);
          await tester.ensureVisible(target);
          await tester.tap(target);
          await tester.pumpAndSettle();
        }

        await tap(const Key('act0_shell_placement_intro_cta'));
        for (final id in ['friends', 'rules']) {
          await tap(Key('act0_shell_placement_option_$id'));
          await tap(const Key('act0_shell_placement_next_cta'));
        }
        await tap(const Key('act0_shell_placement_start_diagnostic'));
        var shell = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(shell.runner.options, hasLength(4));
        final correct = shell.runner.options.firstWhere((o) => o.isCorrect);
        await tap(Key('act0_shell_option_${correct.id}'));
        await tap(const Key('act0_shell_feedback_continue_cta'));
        shell = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(shell.runner.question, 'Which cards can everyone use?');
        textScale.value = scale;
        await tester.pumpAndSettle();
        shell = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        if (scale == 2.0) expect(shell.accessibilityPrototypeStep, isNotNull);
        expect(find.text(shell.runner.hint), findsNothing);
        for (final option in shell.runner.options) {
          final target = find.byKey(Key('act0_shell_option_${option.id}'));
          expect(target, findsOneWidget);
          final rect = tester.getRect(target);
          expect(rect.height, greaterThanOrEqualTo(44));
          expect(rect.bottom, lessThanOrEqualTo(852));
        }
        final board = shell.runner.options.firstWhere((o) => o.isCorrect);
        await tap(Key('act0_shell_option_${board.id}'));
        shell = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(shell.runner.selectedOptionId, board.id);
        expect(shell.runner.phase, Act0LessonPhaseV1.review);
        expect(shell.runner.reviewQuality, Act0FeedbackQualityV1.correct);
        expect(shell.isAssistedDecision, isFalse);
        expect(
          find.byKey(const Key('act0_shell_feedback_card')),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
