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
  test('W01 Button definition explains the marker for every choice', () {
    final task = _task('positions', 'positions_theory');
    expect(task.phase, Act0LessonPhaseV1.theory);
    expect(task.runner.options.map((option) => option.id), <String>[
      'top',
      'random',
      'bottom',
    ]);
    expect(
      task.runner.options.where(act0RunnerOptionIsAuthoredCorrectV1).single.id,
      'bottom',
    );
    final expected = <String, String>{
      'top': 'UTG is an early position, not the dealer button.',
      'bottom': 'BTN marks the dealer button in this six-seat table.',
      'random': 'BB is the big blind, not the dealer button.',
    };
    for (final option in task.runner.options) {
      expect(option.feedbackReason, expected[option.id]);
    }
  });

  test('W01 position recap explains its stated postflop question', () {
    final task = _task('positions', 'positions_review');
    expect(task.phase, Act0LessonPhaseV1.review);
    expect(task.entryPhase, Act0LessonPhaseV1.drill);
    expect(task.runner.question, 'Which seat is latest after the flop here?');
    expect(task.runner.options.map((option) => option.id), <String>[
      'top',
      'random',
      'bottom',
    ]);
    expect(
      task.runner.options.where(act0RunnerOptionIsAuthoredCorrectV1).single.id,
      'bottom',
    );
    final expected = <String, String>{
      'top': 'UTG acts before BTN after the flop in this six-seat hand.',
      'bottom': 'BTN acts last after the flop in this six-seat hand.',
      'random': 'BB acts before BTN after the flop in this six-seat hand.',
    };
    for (final option in task.runner.options) {
      expect(option.feedbackReason, expected[option.id]);
    }
  });

  testWidgets('W01 recap shows postflop feedback after the BB choice', (
    tester,
  ) async {
    final task = _task('positions', 'positions_review');
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
              return Act0LessonRunnerShellV1(
                runner: runner,
                worldNumber: 1,
                selectedWorldId: 'world_1',
                selectedLessonId: 'positions',
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
                onChooseOption: (option) => update(() {
                  chosen = option.id;
                  runner = runner.copyWith(
                    selectedOptionId: option.id,
                    phase: Act0LessonPhaseV1.review,
                  );
                }),
                onChooseSeat: (seatId) => update(() {
                  final option = runner.options.singleWhere(
                    (option) => option.seatId == seatId,
                  );
                  chosen = option.id;
                  runner = runner.copyWith(
                    selectedOptionId: option.id,
                    phase: Act0LessonPhaseV1.review,
                  );
                }),
                onContinueReview: () {},
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final choice = find.byKey(const Key('act0_shell_seat_tap_bb'));
    // Follow the real teaching rail; do not force a recap into a drill or
    // bypass its authored explanation. This remains a widget consumer harness.
    for (var step = 0; step < 12 && runner.activeTeachingStep != null; step++) {
      await tester.pump(const Duration(milliseconds: 900));
      final next = find.byKey(const Key('act0_shell_continue_cta'));
      expect(next, findsOneWidget);
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(runner.activeTeachingStep, isNull);
    expect(choice, findsOneWidget);
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
    expect(chosen, 'random');
    final rendered = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
        .where((text) => text.isNotEmpty)
        .toList();
    print('W01_POSITION_RENDER=${jsonEncode(rendered)}');
    expect(
      find.text('BB acts before BTN after the flop in this six-seat hand.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('one-BB teaching keeps its normal drill and unconfirmed repairs held', () {
    const lesson = 'blinds_action_order';
    final tasks = Act0ShellStateV1.sample.lessonById(lesson).taskList;
    final source = _task(lesson, 'blinds_theory');
    final target = _task(lesson, 'blinds_posts_drill');
    // The normal lesson path still advances from this theory to its drill.
    // That authored path does not itself validate a repair relation.
    expect(source.phase, Act0LessonPhaseV1.theory);
    expect(target.phase, Act0LessonPhaseV1.drill);
    expect(tasks[tasks.indexOf(source) + 1].taskId, target.taskId);
    expect(source.runner.question, 'Which blind posts 1 BB?');
    expect(
      target.runner.question,
      'Tap the blind that sets the 1 BB baseline.',
    );
    expect(target.runner.options.map((option) => option.id), <String>[
      'bb',
      'sb',
    ]);
    expect(
      target.runner.options
          .where(act0RunnerOptionIsAuthoredCorrectV1)
          .single
          .id,
      'bb',
    );
    final expectedReasons = <String, String>{
      'bb':
          'BB posts the full 1 BB blind, so later prices count from that baseline.',
      'sb':
          'SB posts only 0.5 BB. BB is the full 1 BB post players count from.',
    };
    for (final option in target.runner.options) {
      expect(option.feedbackReason, expectedReasons[option.id]);
      expect(
        option.quality,
        option.id == 'bb'
            ? Act0FeedbackQualityV1.correct
            : Act0FeedbackQualityV1.wrong,
      );
    }

    void expectHeld(Act0RepairIntentV1 intent) {
      expect(intent.sourceWorldId, 'world_1');
      expect(intent.sourceLessonId, lesson);
      expect(intent.targetWorldId, intent.sourceWorldId);
      expect(intent.targetLessonId, intent.sourceLessonId);
      expect(intent.targetTaskId, intent.sourceTaskId);
      expect(intent.mappingType, 'unresolved_product_gap');
      expect(intent.goalId, isEmpty);
      expect(intent.relationId, isEmpty);
      expect(intent.relationRevision, 0);
      expect(intent.sourceFingerprint, isEmpty);
      expect(intent.targetFingerprint, isEmpty);
      final resolution = act0RepairGoalResolutionForIntentV1(
        intent,
        learningEvidence: const Act0LearningEvidenceHistoryV1(),
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );
      expect(resolution.reason, 'relation_unconfirmed');
      expect(resolution.isHeld, isTrue);
      expect(resolution.retainsObligation, isTrue);
      expect(resolution.canLaunch, isFalse);
      expect(resolution.canClaimIndependentApplication, isFalse);
      expect(resolution.canClaimMatchedRecheck, isFalse);
    }

    for (final option in source.runner.options) {
      final intent = buildAct0RepairIntentV1(
        sourceWorldId: 'world_1',
        sourceLessonId: lesson,
        sourceTaskId: source.taskId,
        runner: source.runner,
        selectedOption: option,
        mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );
      if (act0RunnerOptionIsAuthoredCorrectV1(option)) {
        expect(intent, isNull);
        continue;
      }
      expect(intent, isNotNull);
      expect(intent!.skillAtomId, 'table_read');
      expect(intent.missedSignalId, 'big_blind');
      expect(intent.sourceTaskId, source.taskId);
      expectHeld(intent);
    }
    // Preserve the legacy mechanical mapper, without treating it as semantic
    // permission to launch a repair or claim independent learning evidence.
    final legacyMapping = act0FirstValueSameSignalRepMappingV1(
      nextRepId: 'repeat_table_read',
      skillAtomId: 'table_read',
      sourceSignalId: 'big_blind',
      sourceTaskId: source.taskId,
      receiptOutcome: 'repair_started',
    );
    expect(legacyMapping, isNotNull);
    expect(legacyMapping!.taskId, target.taskId);
    expect(legacyMapping.mappingType, 'repair');
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
      currentFingerprintForIdentity:
          act0CurrentAuthoredSourceFingerprintForIdentityV1,
    )!;
    expect(donorIntent.sourceTaskId, target.taskId);
    expectHeld(donorIntent);
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
