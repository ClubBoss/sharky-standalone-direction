// LEARN.UX.P1 (#331): source-authored on-table teaching must be visible in the
// order it is authored, before the learner's real decision.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_teaching_integrity_harness_v1.dart';

const _decisionEyebrow = 'YOUR MOVE';
const _decisionSupport = 'Choose one action below.';

Future<void> _expectTeachingStepPresented(
  WidgetTester tester,
  Act0TeachingTaskRefV1 ref,
  int stepIndex,
) async {
  final step = ref.task.runner.teachingSteps[stepIndex];
  final steps = ref.task.runner.teachingSteps.length;
  expect(
    act0CopyPresentedV1(tester, step.title),
    isTrue,
    reason: '${ref.task.taskId} step $stepIndex title must be readable.',
  );
  expect(
    act0CopyPresentedV1(tester, step.body),
    isTrue,
    reason: '${ref.task.taskId} step $stepIndex body must be readable.',
  );
  expect(
    act0TextByKeyV1(tester, 'act0_integrated_scene_purpose'),
    isNot(_decisionEyebrow),
    reason: 'Teaching must not be labelled as the learner decision.',
  );
  expect(find.text(_decisionSupport), findsNothing);
  expect(
    act0TextByKeyV1(tester, 'act0_integrated_scene_prompt'),
    isNot(act0NormalizeCopyV1(ref.task.runner.question)),
    reason: 'The future decision question must not be pinned over teaching.',
  );
  if (steps > 1) {
    expect(
      act0TextByKeyV1(tester, 'act0_learning_scene_v3_progress'),
      '${stepIndex + 1}/$steps',
    );
  }
  expect(
    act0VisibleOptionCountV1(tester, ref.task.runner.options),
    0,
    reason: 'Answers appear only after the authored teaching.',
  );
}

Future<void> _expectDecisionPresented(
  WidgetTester tester,
  Act0TeachingTaskRefV1 ref,
) async {
  final options = ref.task.runner.options;
  expect(act0VisibleOptionCountV1(tester, options), options.length);
  expect(act0TextByKeyV1(tester, 'act0_integrated_scene_purpose'), 'YOUR MOVE');
  expect(
    act0NormalizeCopyV1(
      act0TextByKeyV1(tester, 'act0_integrated_scene_prompt') ?? '',
    ),
    act0NormalizeCopyV1(ref.task.runner.question),
  );
}

void main() {
  setUpAll(act0LoadRealTextFontsV1);

  testWidgets(
    'A: cards_ranks_suits_rank_drill shows both authored steps, then king/ace/suit',
    (tester) async {
      final ref = act0TeachingTaskByIdV1('cards_ranks_suits_rank_drill');
      final events = <String>[];
      expect(ref.task.phase, Act0LessonPhaseV1.drill);
      expect(ref.task.runner.teachingSteps.map((s) => s.title), <String>[
        'Every card has two parts.',
        'Ranks have an order.',
      ]);
      expect(
        ref.task.runner.options.map((o) => o.id),
        unorderedEquals(<String>['king', 'ace', 'suit']),
      );

      await act0PumpTeachingHarnessV1(tester, ref, events: events);
      await _expectTeachingStepPresented(tester, ref, 0);

      await act0TapTeachingContinueV1(tester);
      expect(events, <String>['teaching_step:1']);
      await _expectTeachingStepPresented(tester, ref, 1);

      await act0TapTeachingContinueV1(tester);
      expect(events, <String>[
        'teaching_step:1',
        'teaching_done',
      ], reason: 'Exactly one Continue per authored step.');
      await _expectDecisionPresented(tester, ref);
    },
  );

  testWidgets(
    'B: what_poker_is_table_read_transfer shows every paragraph with one Continue',
    (tester) async {
      final ref = act0TeachingTaskByIdV1('what_poker_is_table_read_transfer');
      final events = <String>[];
      final body = ref.task.runner.teachingSteps.single.body;
      expect(body.split('\n\n'), hasLength(3));

      await act0PumpTeachingHarnessV1(tester, ref, events: events);
      await _expectTeachingStepPresented(tester, ref, 0);
      for (final paragraph in body.split('\n\n')) {
        expect(act0CopyPresentedV1(tester, paragraph), isTrue);
      }

      await act0TapTeachingContinueV1(tester);
      expect(events, <String>['teaching_done']);
      await _expectDecisionPresented(tester, ref);
    },
  );

  testWidgets(
    'C: actions_raise_drill conveys both action-prep steps and their table focus',
    (tester) async {
      final ref = act0TeachingTaskByIdV1('actions_raise_drill');
      final events = <String>[];
      final steps = ref.task.runner.teachingSteps;
      expect(steps, hasLength(2));

      await act0PumpTeachingHarnessV1(tester, ref, events: events);
      for (var index = 0; index < steps.length; index++) {
        await _expectTeachingStepPresented(tester, ref, index);
        final stage = act0StageTableV1(tester)!;
        final step = steps[index];
        if (step.focusSeatIds.isNotEmpty) {
          expect(stage.highlightedSeatIds, step.focusSeatIds);
        }
        if (step.focusCardIds.isNotEmpty) {
          expect(stage.highlightedCardIds, step.focusCardIds);
        }
        if (step.table != null) {
          expect(stage.boardCards.length, step.table!.boardCards.length);
        }
        await act0TapTeachingContinueV1(tester);
      }
      expect(events, <String>['teaching_step:1', 'teaching_done']);
      await _expectDecisionPresented(tester, ref);

      await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
      await act0SettleTeachingV1(tester);
      expect(events.last, 'choose:raise');
    },
  );

  testWidgets(
    'E: your_first_hand_action_trail mounts its answers after teaching',
    (tester) async {
      final ref = act0TeachingTaskByIdV1('your_first_hand_action_trail');
      final events = <String>[];
      await act0PumpTeachingHarnessV1(tester, ref, events: events);
      await _expectTeachingStepPresented(tester, ref, 0);
      await act0TapTeachingContinueV1(tester);
      await tester.pump(const Duration(seconds: 4));
      expect(events, <String>['teaching_done']);
      await _expectDecisionPresented(tester, ref);
      await tester.tap(find.byKey(const Key('act0_shell_option_bb_check')));
      await act0SettleTeachingV1(tester);
      expect(events.last, 'choose:bb_check');
    },
  );

  testWidgets(
    'F: seat answers are not live while a teaching step is on screen',
    (tester) async {
      final ref = act0TeachingTaskByIdV1('positions_button');
      final events = <String>[];
      final seatOptions = ref.task.runner.options.where(
        (option) => option.seatId != null,
      );
      expect(seatOptions, isNotEmpty);
      await act0PumpTeachingHarnessV1(tester, ref, events: events);
      await _expectTeachingStepPresented(tester, ref, 0);
      for (var i = 0; i < ref.task.runner.teachingSteps.length; i++) {
        await act0TapTeachingContinueV1(tester);
      }
      expect(events.last, 'teaching_done');
      expect(
        act0VisibleOptionCountV1(tester, ref.task.runner.options),
        ref.task.runner.options.length,
      );
      final correct = ref.task.runner.options.firstWhere((o) => o.isCorrect);
      await tester.tap(
        find.byKey(Key('act0_shell_seat_tap_${correct.seatId}')),
        warnIfMissed: false,
      );
      await act0SettleTeachingV1(tester);
      expect(events.last, 'choose:${correct.id}');
    },
  );

  for (final variant in Act0ShellTableVisualVariantV1.values) {
    testWidgets(
      'G: ${variant.name} keeps drill-phase teaching visible on phone and tablet',
      (tester) async {
        for (final viewport in const <Size>[
          act0TeachingReferenceViewportV1,
          Size(820, 1180),
        ]) {
          final ref = act0TeachingTaskByIdV1('cards_ranks_suits_rank_drill');
          await act0PumpTeachingHarnessV1(
            tester,
            ref,
            viewport: viewport,
            tableVisualVariant: variant,
          );
          if (variant == Act0ShellTableVisualVariantV1.classic) {
            // The classic fallback already overflows its lower stage at the
            // base (pre-existing, not part of #331); only its copy is checked.
            tester.takeException();
          }
          final step = ref.task.runner.teachingSteps.first;
          expect(
            act0CopyPresentedV1(tester, step.title),
            isTrue,
            reason: '${variant.name} $viewport title',
          );
          expect(
            act0CopyPresentedV1(tester, step.body),
            isTrue,
            reason: '${variant.name} $viewport body',
          );
          expect(act0VisibleOptionCountV1(tester, ref.task.runner.options), 0);
        }
      },
    );
  }

  testWidgets('H: long authored teaching stays readable at 200% text', (
    tester,
  ) async {
    for (final taskId in const <String>[
      'what_poker_is_table_read_transfer',
      'hand_rankings_flush_drill',
    ]) {
      final ref = act0TeachingTaskByIdV1(taskId);
      await act0PumpTeachingHarnessV1(tester, ref, textScale: 2);
      final step = ref.task.runner.teachingSteps.first;
      expect(
        act0CopyPresentedV1(tester, step.title, allowScroll: true),
        isTrue,
        reason: taskId,
      );
      expect(
        act0CopyPresentedV1(tester, step.body, allowScroll: true),
        isTrue,
        reason: taskId,
      );
      expect(tester.takeException(), isNull, reason: taskId);
    }
  });

  testWidgets(
    'I: an answer-free recap teaches its authored step before its takeaway',
    (tester) async {
      final ref = act0TeachingTaskByIdV1('w4_value_recap');
      final events = <String>[];
      expect(ref.task.entryPhase, Act0LessonPhaseV1.review);
      expect(ref.task.runner.options, isEmpty);
      await act0PumpTeachingHarnessV1(tester, ref, events: events);
      final step = ref.task.runner.teachingSteps.single;
      expect(act0CopyPresentedV1(tester, step.title), isTrue);
      expect(act0CopyPresentedV1(tester, step.body), isTrue);
      expect(find.text('CORRECT READ'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      await act0TapTeachingContinueV1(tester);
      expect(events, <String>['teaching_done']);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );
      expect(act0CopyPresentedV1(tester, ref.task.runner.reviewTitle), isTrue);
    },
  );

  testWidgets('D: what_poker_is_theory remains the correct theory baseline', (
    tester,
  ) async {
    final ref = act0TeachingTaskByIdV1('what_poker_is_theory');
    final events = <String>[];
    expect(ref.task.phase, Act0LessonPhaseV1.theory);

    await act0PumpTeachingHarnessV1(tester, ref, events: events);
    await _expectTeachingStepPresented(tester, ref, 0);
    expect(
      act0TextByKeyV1(tester, 'act0_integrated_scene_purpose'),
      'ONE TABLE IDEA',
    );
    await act0TapTeachingContinueV1(tester);
    await _expectTeachingStepPresented(tester, ref, 1);
    await act0TapTeachingContinueV1(tester);
    expect(events, <String>['teaching_step:1', 'theory_task_completed']);
  });
}
