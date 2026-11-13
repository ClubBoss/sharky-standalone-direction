// SIMULATED focused fixture regression for one current-main authored setup.
// Exercises the real decision/feedback consumer; not a native or Human claim.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _worldId = 'world_1';
const _lessonId = 'what_poker_is';
const _taskId = 'first_table_guide_one_clear_choice';

Act0LessonTaskV1 get _task => Act0ShellStateV1.sample
    .lessonById(_lessonId)
    .taskList
    .singleWhere((task) => task.taskId == _taskId);

void main() {
  // Independent meaning oracle from this finite scene: Hero is BTN with KTs;
  // blinds are posted; CO has folded; there is no board. The CO answer states
  // a true subset, while saying Hero has no cards contradicts visible K and T.
  for (final control
      in <
        ({
          String choice,
          String result,
          bool correct,
          Act0FeedbackQualityV1 quality,
          String reason,
        })
      >[
        (
          choice: 'hero_btn_preflop_setup',
          result: 'correct',
          correct: true,
          quality: Act0FeedbackQualityV1.correct,
          reason: 'BTN this hand',
        ),
        (
          choice: 'co_still_acting',
          result: 'suboptimal',
          correct: false,
          quality: Act0FeedbackQualityV1.suboptimal,
          reason: 'CO/cutoff already folded',
        ),
        (
          choice: 'hero_has_no_cards',
          result: 'incorrect',
          correct: false,
          quality: Act0FeedbackQualityV1.wrong,
          reason: 'K and T showing at BTN',
        ),
      ]) {
    testWidgets(
      'setup choice consumer classifies ${control.choice} as ${control.result}',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final decisions = <Act0CompletedDecisionV1>[];
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Scaffold(body: _SetupHarness(onDecision: decisions.add)),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        final choice = find.byKey(Key('act0_shell_option_${control.choice}'));
        expect(choice, findsOneWidget);
        await tester.ensureVisible(choice);
        await tester.pumpAndSettle();
        expect(choice.hitTestable(), findsOneWidget);
        await tester.tap(choice);
        await tester.pumpAndSettle();

        expect(decisions, hasLength(1));
        final decision = decisions.single;
        expect(decision.taskId, _taskId);
        expect(decision.selectedId, control.choice);
        expect(decision.expectedId, 'hero_btn_preflop_setup');
        expect(decision.isCorrect, control.correct);
        expect(decision.resultKind, control.result);
        expect(decision.assistanceKind, Act0DecisionAssistanceV1.none);
        final feedback = tester.widget<Act0FeedbackShellV1>(
          find.byType(Act0FeedbackShellV1),
        );
        expect(feedback.quality, control.quality);
        expect(feedback.reason, contains(control.reason));
        expect(
          find.byKey(const Key('act0_shell_feedback_card')),
          findsOneWidget,
        );
        final visibleReason = find.textContaining(control.reason);
        expect(visibleReason, findsWidgets);
        await tester.ensureVisible(visibleReason.first);
        await tester.pumpAndSettle();
        expect(tester.getRect(visibleReason.first).height, greaterThan(0));
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'setup quality revision preserves historical bytes and rejects old current proof',
    () {
      final task = _task;
      final historicalTask = _withPriorQualities(task);
      final oldFingerprint = act0AuthoredSourceFingerprintV1(
        worldId: _worldId,
        lessonId: _lessonId,
        task: historicalTask,
      )!;
      final currentFingerprint =
          act0CurrentAuthoredSourceFingerprintForIdentityV1(
            worldId: _worldId,
            lessonId: _lessonId,
            taskId: _taskId,
          )!;
      expect(currentFingerprint, isNot(oldFingerprint));
      final old = Act0LearningEvidenceRecordV1(
        recordId: 'synthetic_setup_prior|hero_has_no_cards|1',
        createdOrder: 1,
        worldId: _worldId,
        lessonId: _lessonId,
        taskId: _taskId,
        sourceTaskId: _taskId,
        choiceId: 'hero_has_no_cards',
        expectedChoiceId: 'hero_btn_preflop_setup',
        isCorrect: false,
        errorType: 'missed_table_read',
        conceptFamilyId: 'table_read',
        repairFocusId: '',
        skillAtomId: 'table_read',
        decisionTimeBucket: '3_to_10s',
        resultKind: 'suboptimal',
        assistanceKind: Act0DecisionAssistanceV1.none,
        authoredSourceFingerprint: oldFingerprint,
      );
      final historicalBytes = jsonEncode(old.toPayload());
      final restored = Act0LearningEvidenceRecordV1.tryParse(
        jsonDecode(historicalBytes),
      )!;
      expect(jsonEncode(restored.toPayload()), historicalBytes);
      expect(restored.choiceId, 'hero_has_no_cards');
      expect(restored.resultKind, 'suboptimal');
      expect(restored.authoredSourceFingerprint, oldFingerprint);
      expect(act0CurrentAuthoredSourceProofV1(restored), isNull);

      final currentWrong = Act0LearningEvidenceRecordV1.tryParse(
        restored.toPayload()
          ..['recordId'] = 'synthetic_setup_current|hero_has_no_cards|2'
          ..['createdOrder'] = 2
          ..['resultKind'] = 'incorrect'
          ..['authoredSourceFingerprint'] = currentFingerprint,
      )!;
      expect(act0CurrentAuthoredSourceProofV1(currentWrong), isNotNull);
      expect(
        act0CurrentAuthoredSourceProofV1(currentWrong)!.isCurrentlyCorrect,
        isFalse,
      );
      final currentCorrect = Act0LearningEvidenceRecordV1.tryParse(
        currentWrong.toPayload()
          ..['recordId'] = 'synthetic_setup_current|hero_btn_preflop_setup|3'
          ..['createdOrder'] = 3
          ..['choiceId'] = 'hero_btn_preflop_setup'
          ..['isCorrect'] = true
          ..['resultKind'] = 'correct'
          ..['errorType'] = 'none',
      )!;
      expect(
        act0CurrentAuthoredSourceProofV1(currentCorrect)!.isCurrentlyCorrect,
        isTrue,
      );
      // Resolving against a new source never rewrites the old learner record.
      expect(jsonEncode(restored.toPayload()), historicalBytes);
    },
  );
}

class _SetupHarness extends StatefulWidget {
  const _SetupHarness({required this.onDecision});
  final ValueChanged<Act0CompletedDecisionV1> onDecision;
  @override
  State<_SetupHarness> createState() => _SetupHarnessState();
}

class _SetupHarnessState extends State<_SetupHarness> {
  String? selected;
  @override
  Widget build(BuildContext context) {
    final task = _task;
    return Act0LessonRunnerShellV1(
      runner: task.runner.copyWith(
        phase: selected == null ? task.entryPhase : Act0LessonPhaseV1.review,
        teachingStepIndex: task.runner.teachingSteps.length,
        selectedOptionId: selected,
      ),
      worldNumber: 1,
      selectedWorldId: _worldId,
      selectedLessonId: _lessonId,
      selectedTaskId: _taskId,
      selectedTaskTitle: task.title,
      selectedTaskFamily: task.resolvedTaskFamily,
      compositionFamily: task.resolvedCompositionFamily,
      tablePresentation: task.tablePresentation,
      onBack: () {},
      onContinueTheory: () {},
      onChooseOption: (option) => setState(() => selected = option.id),
      onContinueReview: () {},
      onCompletedDecision: widget.onDecision,
    );
  }
}

Act0LessonTaskV1 _withPriorQualities(Act0LessonTaskV1 task) => Act0LessonTaskV1(
  taskId: task.taskId,
  title: task.title,
  phase: task.phase,
  runner: task.runner.copyWith(
    options: <Act0RunnerOptionV1>[
      for (final option in task.runner.options)
        if (option.id == 'co_still_acting')
          _withQuality(option, Act0FeedbackQualityV1.wrong)
        else if (option.id == 'hero_has_no_cards')
          _withQuality(option, Act0FeedbackQualityV1.suboptimal)
        else
          option,
    ],
  ),
  rewardXp: task.rewardXp,
  stepKind: task.stepKind,
  taskFamily: task.taskFamily,
  tablePresentation: task.tablePresentation,
  summary: task.summary,
  lockedSummary: task.lockedSummary,
);

Act0RunnerOptionV1 _withQuality(
  Act0RunnerOptionV1 option,
  Act0FeedbackQualityV1 quality,
) => Act0RunnerOptionV1(
  id: option.id,
  label: option.label,
  amountLabel: option.amountLabel,
  seatId: option.seatId,
  isCorrect: option.isCorrect,
  preferredLabel: option.preferredLabel,
  betterAnswerLabel: option.betterAnswerLabel,
  quality: quality,
  feedbackTitle: option.feedbackTitle,
  feedbackReason: option.feedbackReason,
  repairFocusSeatIds: option.repairFocusSeatIds,
  repairFocusCardIds: option.repairFocusCardIds,
  repairFocusLabels: option.repairFocusLabels,
);