// SIMULATED source/teaching regression, not native or independent learning proof.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

const _controls = [
  (
    lesson: 'blinds_action_order',
    task: 'blinds_theory',
    correct: 'bb',
    answer: 'BB',
    meaning: '1 BB',
    oldChoice: 'bottom',
    oldFingerprint:
        'b10ea2093f254cae6df8d3a8702aed685bfd49de9a65724f76342fd6cd9ad46f',
    oldIds: ['top', 'bottom', 'random'],
  ),
  (
    lesson: 'cards_ranks_suits',
    task: 'cards_ranks_suits_theory',
    correct: 'rank_and_suit',
    answer: 'Rank and suit',
    meaning: 'rank',
    oldChoice: 'ace',
    oldFingerprint:
        'da18579f003d9a05d2feb9ba458ed793be8ab2fc5d98943e8daf13101533d6fd',
    oldIds: ['king', 'ace', 'suit'],
  ),
  (
    lesson: 'hand_rankings_table',
    task: 'hand_rankings_theory',
    correct: 'hand_strength',
    answer: 'Hand strength',
    meaning: 'stronger',
    oldChoice: 'pair',
    oldFingerprint:
        '9211311af696efd47e86e41bf2a670711541def3254083aa1b134903129bf43c',
    oldIds: ['pair', 'high_card'],
  ),
];

Act0LessonTaskV1 _task(String lesson, String id) => Act0ShellStateV1.sample
    .lessonById(lesson)
    .taskList
    .singleWhere((task) => task.taskId == id);

void main() {
  test('blind concept repairs keep the one-BB signal and existing drill', () {
    const lesson = 'blinds_action_order';
    final source = _task(lesson, 'blinds_theory');
    final target = _task(lesson, 'blinds_posts_drill');
    expect(
      target.runner.options
          .where(act0RunnerOptionIsAuthoredCorrectV1)
          .single
          .id,
      'bb',
    );
    expect(target.runner.question, contains('1 BB'));
    for (final option in source.runner.options) {
      final intent = buildAct0RepairIntentV1(
        sourceWorldId: 'world_1',
        sourceLessonId: lesson,
        sourceTaskId: source.taskId,
        runner: source.runner,
        selectedOption: option,
        mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
      );
      if (act0RunnerOptionIsAuthoredCorrectV1(option)) {
        expect(intent, isNull);
        continue;
      }
      expect(intent, isNotNull);
      expect(intent!.skillAtomId, 'table_read');
      expect(intent.missedSignalId, 'big_blind');
      expect(intent.targetWorldId, 'world_1');
      expect(intent.targetLessonId, lesson);
      expect(intent.targetTaskId, target.taskId);
      expect(intent.targetTaskId, isNot(source.taskId));
      expect(intent.mappingType, 'repair');
    }
    expect(
      act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'small_blind',
        sourceTaskId: source.taskId,
        receiptOutcome: 'repair_started',
      ),
      isNull,
    );
    final donorIntent = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: lesson,
      sourceTaskId: target.taskId,
      runner: target.runner,
      selectedOption: target.runner.options.singleWhere((o) => o.id == 'sb'),
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    )!;
    expect(donorIntent.mappingType, 'intentional_exact');
    expect(donorIntent.targetTaskId, target.taskId);
  });

  for (final control in _controls) {
    // Finite meaning controls independent of source's isCorrect flag:
    // BB posts the full blind; a card has rank+suit; rankings compare strength.
    test(
      '${control.task} answers its own concept and explains each choice',
      () {
        final task = _task(control.lesson, control.task);
        final options = task.runner.options;
        expect(task.phase, Act0LessonPhaseV1.theory);
        expect(task.resolvedTaskFamily, Act0TaskFamilyV1.learn);
        final correct = options
            .where(act0RunnerOptionIsAuthoredCorrectV1)
            .single;
        expect(correct.id, control.correct);
        expect(correct.label, control.answer);
        expect(
          correct.feedbackReason.toLowerCase(),
          contains(control.meaning.toLowerCase()),
        );
        expect(
          task.runner.feedbackReason.toLowerCase(),
          contains(control.meaning.toLowerCase()),
        );
        expect(options.map((o) => o.id).toSet().length, options.length);
        for (final option in options) {
          expect(control.oldIds, isNot(contains(option.id)));
          expect(option.feedbackReason.trim(), isNotEmpty);
          expect(
            option.quality,
            option.id == control.correct
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
          );
        }
      },
    );

    test(
      '${control.task} preserves old teaching history without current proof',
      () {
        final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: 'world_1',
          lessonId: control.lesson,
          taskId: control.task,
        )!;
        expect(fingerprint, isNot(control.oldFingerprint));
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic_old_theory|${control.task}|1',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: control.lesson,
          taskId: control.task,
          sourceTaskId: control.task,
          choiceId: control.oldChoice,
          expectedChoiceId: control.oldChoice,
          isCorrect: true,
          errorType: 'none',
          conceptFamilyId: 'table_read',
          repairFocusId: '',
          skillAtomId: 'table_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          assistanceKind: Act0DecisionAssistanceV1.none,
          authoredSourceFingerprint: control.oldFingerprint,
        );
        final bytes = jsonEncode(old.toPayload());
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          jsonDecode(bytes),
        )!;
        expect(act0RecordIsAuthoredTeachingV1(restored), isTrue);
        expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
        final currentTeaching = Act0LearningEvidenceRecordV1.tryParse(
          restored.toPayload()
            ..['recordId'] = 'synthetic_current_theory|${control.task}|2'
            ..['createdOrder'] = 2
            ..['choiceId'] = control.correct
            ..['expectedChoiceId'] = control.correct
            ..['authoredSourceFingerprint'] = fingerprint,
        )!;
        expect(act0RecordIsAuthoredTeachingV1(currentTeaching), isTrue);
        expect(act0CurrentAuthoredSourceProofV1(currentTeaching), isNull);
        expect(jsonEncode(restored.toPayload()), bytes);
      },
    );

    testWidgets('${control.task} remains teaching with reachable Continue', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final task = _task(control.lesson, control.task);
      final decisions = <Act0CompletedDecisionV1>[];
      var continued = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: 0,
              ),
              worldNumber: 1,
              selectedWorldId: 'world_1',
              selectedLessonId: control.lesson,
              selectedTaskId: control.task,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () => continued++,
              onChooseOption: (_) =>
                  fail('Teaching must not submit an assessment'),
              onContinueReview: () {},
              onCompletedDecision: decisions.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final option in task.runner.options) {
        expect(find.byKey(Key('act0_shell_option_${option.id}')), findsNothing);
      }
      // The real theory rail may show several Next segments before Continue.
      // Follow those controls; do not skip teaching or force a drill phase.
      for (var step = 0; step < 12 && continued == 0; step++) {
        await tester.pump(const Duration(milliseconds: 900));
        final next = find.byKey(const Key('act0_shell_continue_cta'));
        expect(next, findsOneWidget);
        await tester.ensureVisible(next);
        await tester.pumpAndSettle();
        expect(next.hitTestable(), findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(decisions, isEmpty);
        for (final option in task.runner.options) {
          expect(
            find.byKey(Key('act0_shell_option_${option.id}')),
            findsNothing,
          );
        }
      }
      expect(continued, 1);
      expect(decisions, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}
