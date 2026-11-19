import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  group('Act0 Wave 2 canonical assessment validity', () {
    Act0LessonCardV1 lessonFor({
      required String worldId,
      required String lessonId,
    }) {
      return Act0ShellStateV1.sample
          .worldById(worldId)
          .lessons
          .firstWhere((lesson) => lesson.lessonId == lessonId);
    }

    Act0LessonTaskV1 taskFor({
      required String worldId,
      required String lessonId,
      required String taskId,
    }) {
      return lessonFor(
        worldId: worldId,
        lessonId: lessonId,
      ).taskList.firstWhere((task) => task.taskId == taskId);
    }

    Act0RunnerOptionV1 correctOption(Act0LessonTaskV1 task) {
      return task.runner.options.firstWhere((option) => option.isCorrect);
    }

    String assessedPromptText(Act0LessonTaskV1 task) {
      return '${task.runner.caption}\n${task.runner.hint}'.toLowerCase();
    }

    for (final control in const [
      (
        lesson: 'button_advantage',
        task: 'button_advantage_button_recap',
        xp: 12,
      ),
      (
        lesson: 'early_vs_late',
        task: 'early_vs_late_w2_position_recap',
        xp: 10,
      ),
    ]) {
      test('${control.task} asks and explains the same postflop order', () {
        final task = taskFor(
          worldId: 'world_3',
          lessonId: control.lesson,
          taskId: control.task,
        );
        expect(task.phase, Act0LessonPhaseV1.review);
        expect(task.entryPhase, Act0LessonPhaseV1.drill);
        expect(
          task.runner.question,
          'Which seat acts last after the flop here?',
        );
        expect(task.runner.hint, 'Compare the live-seat order after the flop.');
        expect(task.runner.options.map((option) => option.id), <String>[
          'top',
          'bottom',
          'random',
        ]);
        expect(task.runner.options.map((option) => option.seatId), <String>[
          'utg',
          'btn',
          'bb',
        ]);
        expect(task.runner.options.indexWhere((option) => option.isCorrect), 1);
        expect(task.rewardXp, control.xp);
        const reasons = {
          'top': 'UTG acts before BTN after the flop on this six-seat table.',
          'bottom': 'BTN acts last after the flop on this six-seat table.',
          'random': 'BB acts before BTN after the flop on this six-seat table.',
        };
        for (final option in task.runner.options) {
          expect(option.feedbackReason, reasons[option.id]);
        }
      });

      testWidgets('${control.task} shows postflop feedback after BB tap', (
        tester,
      ) async {
        final task = taskFor(
          worldId: 'world_3',
          lessonId: control.lesson,
          taskId: control.task,
        );
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var runner = task.runner.copyWith(
          phase: task.entryPhase,
          teachingStepIndex: 0,
        );
        String? chosen;
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, update) {
                  void choose(Act0RunnerOptionV1 option) => update(() {
                    chosen = option.id;
                    runner = runner.copyWith(
                      selectedOptionId: option.id,
                      phase: Act0LessonPhaseV1.review,
                    );
                  });
                  return Act0LessonRunnerShellV1(
                    runner: runner,
                    worldNumber: 3,
                    selectedWorldId: 'world_3',
                    selectedLessonId: control.lesson,
                    selectedTaskId: task.taskId,
                    selectedTaskTitle: task.title,
                    selectedTaskFamily: task.resolvedTaskFamily,
                    compositionFamily: task.resolvedCompositionFamily,
                    tablePresentation: task.tablePresentation,
                    onBack: () {},
                    onContinueTheory: () => update(() {
                      runner = runner.copyWith(
                        teachingStepIndex: runner.teachingStepIndex + 1,
                      );
                    }),
                    onChooseOption: choose,
                    onChooseSeat: (seat) => choose(
                      runner.options.singleWhere(
                        (option) => option.seatId == seat,
                      ),
                    ),
                    onContinueReview: () {},
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        // Follow each real task's teaching rail and seat control. This is a
        // widget consumer witness, not native navigation or learner evidence.
        for (
          var step = 0;
          step < 12 && runner.activeTeachingStep != null;
          step++
        ) {
          await tester.pump(const Duration(milliseconds: 900));
          final next = find.byKey(const Key('act0_shell_continue_cta'));
          expect(next, findsOneWidget);
          await tester.ensureVisible(next);
          await tester.tap(next);
          await tester.pumpAndSettle();
        }
        expect(runner.activeTeachingStep, isNull);
        final bb = find.byKey(const Key('act0_shell_seat_tap_bb'));
        expect(bb, findsOneWidget);
        await tester.ensureVisible(bb);
        await tester.tap(bb);
        await tester.pumpAndSettle();
        expect(chosen, 'random');
        final text = tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
            .where((text) => text.isNotEmpty)
            .toList();
        print('W3_POSITION_RENDER_${control.task}=${jsonEncode(text)}');
        expect(
          find.text(
            'BB acts before BTN after the flop on this six-seat table.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    test('confirmed leakage is removed from assessed runner prompts', () {
      final leakCases = <({Act0LessonTaskV1 task, List<String> banned})>[
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'hand_rankings_upper',
            taskId: 'hand_rankings_flush_drill',
          ),
          banned: <String>['flush beats straight'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_premium',
          ),
          banned: <String>['premium preflop hand', 'premium hands'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_strong',
          ),
          banned: <String>['strong preflop hand', 'strong hands'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_medium',
          ),
          banned: <String>['medium preflop hand', 'medium hands'],
        ),
        (
          task: taskFor(
            worldId: 'world_2',
            lessonId: 'hand_discipline_buckets',
            taskId: 'hand_discipline_buckets_trash',
          ),
          banned: <String>['trash bucket', 'weak bucket'],
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'why_bets_happen',
            taskId: 'w4_value_purpose',
          ),
          banned: <String>['worse hands can call', 'wants calls'],
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'why_bets_happen',
            taskId: 'w4_bluff_purpose',
          ),
          banned: <String>['wins by folds', 'fold pressure'],
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'protection_and_denial',
            taskId: 'w4_protection_check',
          ),
          banned: <String>['free next card'],
        ),
        (
          task: taskFor(
            worldId: 'world_5',
            lessonId: 'board_texture_basics',
            taskId: 'board_texture_basics_w5_wet_board',
          ),
          banned: <String>['make this wet', 'this is wet'],
        ),
      ];

      for (final leakCase in leakCases) {
        final prompt = assessedPromptText(leakCase.task);
        for (final banned in leakCase.banned) {
          expect(prompt, isNot(contains(banned)), reason: leakCase.task.taskId);
        }
      }
    });

    test('theory tasks may still explain concepts explicitly', () {
      final intro = taskFor(
        worldId: 'world_2',
        lessonId: 'hand_discipline_buckets',
        taskId: 'hand_discipline_buckets_intro',
      );
      final teachingText = intro.runner.teachingSteps
          .expand(
            (step) => <String>[step.title, step.body, ...step.focusLabels],
          )
          .join('\n');

      expect(teachingText, contains('Premium'));
      expect(teachingText, contains('Strong'));
      expect(teachingText, contains('Medium'));
      expect(teachingText, contains('Weak'));
    });

    test(
      'W3 position_six_seats covers all six positions from table evidence',
      () {
        final world3 = Act0ShellStateV1.sample.worldById('world_3');
        expect(world3.lessons.first.lessonId, 'position_six_seats');

        final lesson = lessonFor(
          worldId: 'world_3',
          lessonId: 'position_six_seats',
        );
        final correctSeatIds = <String>{
          for (final task in lesson.taskList)
            for (final option in task.runner.options)
              if (option.isCorrect && option.seatId != null) option.seatId!,
        };

        expect(correctSeatIds, containsAll(<String>['utg', 'hj', 'co', 'btn']));
        expect(correctSeatIds, containsAll(<String>['sb', 'bb']));

        final runnerIds = lesson.taskList
            .map((task) => task.runner.lessonId)
            .toSet();
        expect(
          runnerIds,
          isNot(
            containsAll(<String>['button_seat', 'utg_seat', 'late_position']),
          ),
        );
      },
    );

    test('W3 independently assesses HJ versus CO recognition', () {
      final lesson = lessonFor(
        worldId: 'world_3',
        lessonId: 'position_six_seats',
      );

      final contrastTask = lesson.taskList.firstWhere(
        (task) =>
            task.runner.table.selectableSeatIds.contains('hj') &&
            task.runner.table.selectableSeatIds.contains('co') &&
            correctOption(task).seatId == 'hj',
      );

      expect(contrastTask.taskId, 'position_six_seats_hj_co_contrast');
      expect(contrastTask.runner.table.selectableSeatIds, <String>['hj', 'co']);
      expect(contrastTask.runner.table.highlightedSeatIds, isEmpty);
      expect(contrastTask.runner.table.activeSeatId, isEmpty);
      final teaching = contrastTask.runner.teachingSteps.single;
      expect(teaching.focusSeatIds, <String>['hj', 'co']);
      final teachingTable = act0TeachingTableForRunnerV1(
        contrastTask.runner.table,
        teaching,
      );
      expect(teachingTable.highlightedSeatIds, contains('hj'));
      expect(teachingTable.highlightedSeatIds, contains('co'));
    });

    test('W2 strong and borderline bucket tasks use distinct examples', () {
      final world2 = Act0ShellStateV1.sample.worldById('world_2');
      final world2LessonIds = world2.lessons
          .map((lesson) => lesson.lessonId)
          .toList(growable: false);
      expect(
        world2LessonIds.indexOf('hand_discipline_buckets'),
        lessThan(world2LessonIds.indexOf('hand_discipline_apply')),
      );

      final strong = taskFor(
        worldId: 'world_2',
        lessonId: 'hand_discipline_buckets',
        taskId: 'hand_discipline_buckets_strong',
      );
      final borderline = taskFor(
        worldId: 'world_2',
        lessonId: 'hand_discipline_buckets',
        taskId: 'hand_discipline_buckets_borderline',
      );

      expect(strong.taskId, 'hand_discipline_buckets_strong');
      expect(borderline.taskId, 'hand_discipline_buckets_borderline');
      expect(strong.runner.lessonId, isNot(borderline.runner.lessonId));
      expect(strong.runner.caption, isNot(borderline.runner.caption));
      expect(strong.runner.table.heroCards.map((card) => card.label), <String>[
        'Jh',
        'Js',
      ]);
      expect(
        borderline.runner.table.heroCards.map((card) => card.label),
        <String>['Qs', 'Js'],
      );

      expect(correctOption(strong).id, 'strong');
      expect(correctOption(borderline).id, 'medium');
      expect(
        correctOption(borderline).feedbackReason.toLowerCase(),
        contains('context'),
      );
    });

    test('QJs facts agree with the hero projection and neutral task title', () {
      final task = taskFor(
        worldId: 'world_2',
        lessonId: 'hand_discipline_buckets',
        taskId: 'hand_discipline_buckets_borderline',
      );
      expect(task.title, 'Borderline hand');
      expect(task.runner.caption, 'Hero holds Qs Js before the flop.');
      expect(
        task.runner.table.heroSeat.holeCards.map((card) => card.label),
        <String>['Qs', 'Js'],
      );
      expect(task.runner.options.map((option) => option.id), <String>[
        'strong',
        'medium',
        'trash',
      ]);
      expect(task.runner.options.indexWhere((option) => option.isCorrect), 1);
      expect(correctOption(task).quality, Act0FeedbackQualityV1.correct);
      expect(task.rewardXp, 7);
    });

    test(
      'position fold feedback follows every authored hand and seat alias',
      () {
        const expected = <String, (String, String, int)>{
          'same_hand_different_seat_same_hand_early_fold': ('ATo', 'UTG', 0),
          'position_apply_early_fold': ('ATo', 'UTG', 0),
          'position_apply_hj_fold': ('KTo', 'HJ', 1),
          'position_checkpoint_position_checkpoint_early_fold': (
            'A9o',
            'UTG',
            1,
          ),
        };
        final tasks = Act0ShellStateV1.sample.worlds
            .expand((world) => world.lessons)
            .expand((lesson) => lesson.taskList)
            .where((task) => expected.containsKey(task.taskId))
            .toList();
        expect(tasks.map((task) => task.taskId).toSet(), expected.keys.toSet());
        for (final task in tasks) {
          final (hand, seat, correctIndex) = expected[task.taskId]!;
          expect(task.runner.table.heroSeatId, seat.toLowerCase());
          expect(
            task.runner.options.map((option) => option.id).toSet(),
            <String>{'fold', 'raise'},
          );
          expect(
            task.runner.options.indexWhere((option) => option.isCorrect),
            correctIndex,
          );
          expect(correctOption(task).id, 'fold');
          for (final option in task.runner.options) {
            expect(option.feedbackReason, contains(hand), reason: task.taskId);
            expect(option.feedbackReason, contains(seat), reason: task.taskId);
            expect(option.feedbackReason, contains('Sharky starting chart'));
            expect(option.feedbackReason, isNot(contains('J8o')));
            expect(
              option.feedbackReason,
              isNot(contains('hand bucket is too weak')),
            );
            expect(option.preferredLabel, 'Fold');
            expect(
              option.quality,
              option.isCorrect
                  ? Act0FeedbackQualityV1.correct
                  : Act0FeedbackQualityV1.wrong,
            );
            expect(option.repairFocusSeatIds, isEmpty);
            expect(option.repairFocusCardIds, isEmpty);
            expect(option.repairFocusLabels, isEmpty);
          }
        }
      },
    );

    const atoTeachingBody =
        'ATo means ace-ten offsuit. The displayed cards are the ace of diamonds and ten of clubs. Read this hand with the Button seat and unopened-pot context.';
    const atoTeachingAliases = [
      (
        lesson: 'same_hand_different_seat',
        task: 'same_hand_different_seat_same_hand_late_open',
      ),
      (lesson: 'position_apply', task: 'position_apply_late_open'),
      (
        lesson: 'position_checkpoint',
        task: 'position_checkpoint_position_checkpoint_late_open',
      ),
    ];
    for (final control in atoTeachingAliases) {
      test('${control.task} teaches its displayed ATo hand and BTN seat', () {
        final task = taskFor(
          worldId: 'world_3',
          lessonId: control.lesson,
          taskId: control.task,
        );
        final table = task.runner.table;
        expect(table.heroCards.map((card) => card.label), ['Ad', 'Tc']);
        expect(table.heroSeat.seatId, 'btn');
        expect(table.centerLabel, 'Unopened pot');
        final teaching = task.runner.teachingSteps.single;
        expect(teaching.title, 'Read the displayed hand and seat.');
        expect(teaching.body, atoTeachingBody);
        expect(teaching.focusSeatIds, ['btn']);
        expect(teaching.focusCardIds, ['hero_0', 'hero_1']);
        expect(teaching.focusLabels, ['ATo', 'BTN', 'Unopened pot']);
        final teachingTable = act0TeachingTableForRunnerV1(table, teaching);
        expect(teachingTable.heroCards.map((card) => card.label), ['Ad', 'Tc']);
        expect(teachingTable.highlightedSeatIds, contains('btn'));
      });
    }

    test(
      'ATo correction preserves independently authored neighbouring teaching',
      () {
        Act0TeachingStepV1 teachingFor(String taskId) => Act0ShellStateV1.sample
            .worldById('world_3')
            .lessons
            .expand((lesson) => lesson.taskList)
            .singleWhere((task) => task.taskId == taskId)
            .runner
            .teachingSteps
            .single;
        expect(
          teachingFor('button_advantage_button_open').body,
          'KTs on the Button is playable when nobody entered.',
        );
        expect(
          teachingFor('position_apply_btn_open').body,
          'QTs can still open first in from the Button.',
        );
        for (final id in [
          'position_apply_recap',
          'position_checkpoint_position_checkpoint_review',
        ]) {
          final teaching = teachingFor(id);
          expect(teaching.title, 'Position checklist.');
          expect(
            teaching.body,
            'Bucket the hand, then ask if the seat helps or hurts.',
          );
        }
        expect(
          teachingFor(
            'position_checkpoint_position_checkpoint_table_notice',
          ).title,
          'Seat read before action.',
        );
      },
    );

    testWidgets('ATo teaching renders the actual composed source in English', (
      tester,
    ) async {
      final control = atoTeachingAliases.first;
      final task = taskFor(
        worldId: 'world_3',
        lessonId: control.lesson,
        taskId: control.task,
      );
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: 0,
              ),
              worldNumber: 3,
              selectedWorldId: 'world_3',
              selectedLessonId: control.lesson,
              selectedTaskId: task.taskId,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onChooseSeat: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final prompt = find.byKey(const Key('act0_integrated_scene_prompt'));
      final support = find.byKey(const Key('act0_learning_scene_v3_support'));
      expect(prompt, findsOneWidget);
      expect(support, findsOneWidget);
      expect(
        tester.widget<Text>(prompt).data,
        'Read the displayed hand and seat.',
      );
      expect(tester.widget<Text>(support).data, atoTeachingBody);
      expect(find.textContaining('KTs on the Button'), findsNothing);
      final supportScroll = find.byKey(
        const Key('act0_learning_scene_v3_theory_support_scroll'),
      );
      expect(supportScroll, findsOneWidget);
      final scrollable = find.descendant(
        of: supportScroll,
        matching: find.byType(Scrollable),
      );
      final scrollState = tester.state<ScrollableState>(scrollable);
      expect(scrollState.position.maxScrollExtent, greaterThan(0));
      await tester.drag(supportScroll, const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(scrollState.position.pixels, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    for (final control in const [
      (
        lesson: 'position_apply',
        task: 'position_apply_recap',
        oldFingerprint:
            '1983e106773b0dd388792a2cf146d426159a80e67d65aa5bf26d1ef676e5d618',
      ),
      (
        lesson: 'position_checkpoint',
        task: 'position_checkpoint_position_checkpoint_review',
        oldFingerprint:
            '05c0c6c3ecab78869602c1ea6a689aafb25f5f85abb4021d3fea4eef293a4244',
      ),
    ]) {
      test(
        '${control.task} aligns its action question and retires only old proof',
        () {
          final task = taskFor(
            worldId: 'world_3',
            lessonId: control.lesson,
            taskId: control.task,
          );
          final parent = taskFor(
            worldId: 'world_3',
            lessonId: 'position_apply',
            taskId: 'position_apply_late_open',
          );
          expect(task.phase, Act0LessonPhaseV1.review);
          expect(task.entryPhase, Act0LessonPhaseV1.drill);
          expect(task.stepKind, Act0LessonStepKindV1.proveIt);
          expect(task.resolvedTaskFamily, Act0TaskFamilyV1.transfer);
          expect(task.runner.question, parent.runner.question);
          expect(
            task.runner.question,
            'By the Sharky starting chart, what is the simple action?',
          );
          expect(task.runner.teachingSteps.single.title, 'Position checklist.');
          final historicalTask = Act0LessonTaskV1(
            taskId: task.taskId,
            title: task.title,
            phase: task.phase,
            runner: task.runner.copyWith(
              question: 'What should you check after the bucket?',
              table: task.runner.table.copyWith(
                actionTrail: const [
                  Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
                  Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
                  Act0ActionTrailItemV1(label: 'BTN acts'),
                ],
                seats: [
                  for (final seat in task.runner.table.seats)
                    if (seat.seatId == 'utg')
                      const Act0SeatStateV1(
                        seatId: 'utg',
                        seatLabel: 'UTG',
                        displayName: 'Seat',
                        isOccupied: false,
                        isInHand: false,
                        cardsVisibleMode: Act0CardsVisibleModeV1.none,
                      )
                    else
                      seat,
                ],
              ),
            ),
            rewardXp: task.rewardXp,
            stepKind: task.stepKind,
            taskFamily: task.taskFamily,
            tablePresentation: task.tablePresentation,
            summary: task.summary,
            lockedSummary: task.lockedSummary,
          );
          String fingerprint(Act0LessonTaskV1 value) =>
              act0AuthoredSourceFingerprintV1(
                worldId: 'world_3',
                lessonId: control.lesson,
                task: value,
              )!;
          expect(fingerprint(historicalTask), control.oldFingerprint);
          expect(fingerprint(task), isNot(control.oldFingerprint));
          final raise = task.runner.options.singleWhere(
            (option) => option.id == 'raise',
          );
          final receipt = act0FirstValueSkillReceiptForRunnerV1(
            runner: task.runner,
            option: raise,
            taskFamily: task.resolvedTaskFamily,
          )!;
          final oldReceipt = act0FirstValueSkillReceiptForRunnerV1(
            runner: historicalTask.runner,
            option: raise,
            taskFamily: historicalTask.resolvedTaskFamily,
          )!;
          expect(receipt.skillAtomId, oldReceipt.skillAtomId);
          expect(receipt.sourceSignalId, oldReceipt.sourceSignalId);
          Act0LearningEvidenceRecordV1 record(String source) =>
              Act0LearningEvidenceRecordV1(
                recordId: 'old-${task.taskId}',
                createdOrder: 1,
                worldId: 'world_3',
                lessonId: control.lesson,
                taskId: task.taskId,
                sourceTaskId: task.taskId,
                choiceId: 'raise',
                expectedChoiceId: 'raise',
                isCorrect: true,
                errorType: 'none',
                conceptFamilyId: receipt.sourceSignalId,
                repairFocusId: receipt.sourceSignalId,
                skillAtomId: receipt.skillAtomId,
                decisionTimeBucket: '3_to_10s',
                resultKind: 'correct',
                assistanceKind: Act0DecisionAssistanceV1.quickHint,
                authoredSourceFingerprint: source,
                sessionId: 'historical-session',
                recordedAtUtc: DateTime.utc(2026, 1, 1),
              );
          final oldRecord = record(control.oldFingerprint);
          expect(
            act0CurrentAuthoredSourceProofForTaskV1(
              record: oldRecord,
              worldId: 'world_3',
              lessonId: control.lesson,
              task: historicalTask,
            ),
            isNotNull,
          );
          expect(act0CurrentAuthoredSourceProofV1(oldRecord), isNull);
          final newRecord = record(fingerprint(task));
          expect(act0CurrentAuthoredSourceProofV1(newRecord), isNotNull);
          expect(newRecord.isIndependentCorrect, isFalse);
          final history = Act0LearningEvidenceHistoryV1(
            records: [oldRecord],
            sourceAnchors: [oldRecord],
          );
          final saved = history.toStorageString();
          final restored = Act0LearningEvidenceHistoryV1.tryParse(
            jsonDecode(saved),
          )!;
          expect(
            act0CurrentAuthoredSourceProofV1(restored.records.single),
            isNull,
          );
          expect(restored.records.single.toPayload(), oldRecord.toPayload());
          expect(restored.toStorageString(), saved);
        },
      );

      for (final choiceId in const ['raise', 'call']) {
        testWidgets('${control.task} asks for an action and grades $choiceId', (
          tester,
        ) async {
          final task = taskFor(
            worldId: 'world_3',
            lessonId: control.lesson,
            taskId: control.task,
          );
          tester.view.physicalSize = const Size(393, 852);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var runner = task.runner.copyWith(
            phase: task.entryPhase,
            teachingStepIndex: task.runner.teachingSteps.length,
          );
          Act0CompletedDecisionV1? completed;
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('en'),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, update) => Act0LessonRunnerShellV1(
                    runner: runner,
                    worldNumber: 3,
                    selectedWorldId: 'world_3',
                    selectedLessonId: control.lesson,
                    selectedTaskId: task.taskId,
                    selectedTaskTitle: task.title,
                    selectedTaskFamily: task.resolvedTaskFamily,
                    compositionFamily: task.resolvedCompositionFamily,
                    tablePresentation: task.tablePresentation,
                    onBack: () {},
                    onContinueTheory: () {},
                    onChooseOption: (option) => update(() {
                      runner = runner.copyWith(
                        selectedOptionId: option.id,
                        phase: Act0LessonPhaseV1.review,
                      );
                    }),
                    onChooseSeat: (_) {},
                    onCompletedDecision: (value) => completed = value,
                    onContinueReview: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final prompt = find.byKey(const Key('act0_integrated_scene_prompt'));
          expect(
            tester.widget<Text>(prompt).data,
            'By the Sharky starting chart, what is the simple action?',
          );
          final choice = find.byKey(Key('act0_shell_option_$choiceId'));
          expect(choice, findsOneWidget);
          await tester.ensureVisible(choice);
          await tester.tap(choice);
          await tester.pumpAndSettle();
          expect(runner.selectedOptionId, choiceId);
          expect(completed, isNotNull);
          expect(completed!.selectedId, choiceId);
          expect(completed!.expectedId, 'raise');
          expect(completed!.isCorrect, choiceId == 'raise');
          expect(completed!.taskId, task.taskId);
          expect(tester.takeException(), isNull);
        });
      }
    }

    test(
      'Button-last teaching names the postflop street in both languages',
      () {
        final task = taskFor(
          worldId: 'world_2',
          lessonId: 'hand_discipline_apply',
          taskId: 'apply_btn_open',
        );
        expect(
          task.runner.teachingSteps.single.body,
          contains('BTN acts last after the flop.'),
        );
        expect(correctOption(task).id, 'raise');
        expect(
          act0LocalizedTeachingStepBodyAtomByTaskIdV1(
            task.taskId,
            0,
            fallback: '',
            languageCode: 'ru',
          ),
          contains('После флопа баттон действует последним.'),
        );
      },
    );

    test('related Russian task facts preserve QJs and the HJ KTo hand', () {
      const id = 'hand_discipline_buckets_borderline';
      expect(
        act0LocalizedTaskTitleAtomByIdV1(id, fallback: '', languageCode: 'ru'),
        'Пограничная рука',
      );
      expect(
        act0LocalizedRunnerPromptAtomByTaskIdV1(
          id,
          fallback: '',
          languageCode: 'ru',
        ),
        'У Hero Qs Js до флопа.',
      );
      expect(
        act0LocalizedTeachingStepBodyAtomByTaskIdV1(
          id,
          0,
          fallback: '',
          languageCode: 'ru',
        ),
        contains('средняя'),
      );
      expect(
        act0LocalizedRunnerPromptAtomByTaskIdV1(
          'position_apply_hj_fold',
          fallback: '',
          languageCode: 'ru',
        ),
        'Банк не открыт. Ты в HJ с KTo.',
      );
    });
  });
}
