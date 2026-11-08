// Output-only source proposal. NOT_RUN. Actual Preview route cases are added
// to the existing concept-repair harness; these tests do not replace them.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _call10 = 'asm05_new_known_holes_turn_call_10';
const _call40 = 'asm05_new_known_holes_turn_call_40';

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample
    .worldById('world_12')
    .lessons
    .singleWhere((lesson) => lesson.lessonId == 'decision_over_outcome')
    .taskList
    .singleWhere((task) => task.taskId == id);

void main() {
  for (final pair in const [
    (source: _call10, target: _call40, wrong: 'fold', correct: 'call'),
    (source: _call40, target: _call10, wrong: 'call', correct: 'fold'),
  ]) {
    test('${pair.source}: actual receipt maps to the other authored price', () {
      final source = _task(pair.source);
      final target = _task(pair.target);
      final wrong = source.runner.options.singleWhere(
        (o) => o.id == pair.wrong,
      );
      final receipt = act0FirstValueSkillReceiptForRunnerV1(
        runner: source.runner,
        option: wrong,
        taskFamily: source.resolvedTaskFamily,
      );
      expect(receipt, isNotNull);
      expect(receipt!.skillAtomId, 'mindset_process_discipline');
      expect(receipt.sourceSignalId, 'process_over_outcome');
      expect(receipt.nextRepId, 'repeat_mindset_process_discipline');
      final intent = buildAct0RepairIntentV1(
        sourceWorldId: 'world_12',
        sourceLessonId: 'decision_over_outcome',
        sourceTaskId: source.taskId,
        runner: source.runner,
        selectedOption: wrong,
        mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
      );
      expect(intent, isNotNull);
      expect(intent!.mappingType, 'repair');
      expect(intent.targetWorldId, 'world_12');
      expect(intent.targetLessonId, 'decision_over_outcome');
      expect(intent.targetTaskId, target.taskId);
      expect(intent.targetTaskId, isNot(source.taskId));
      expect(intent.choiceId, pair.wrong);
      expect(intent.errorType, 'misread_mindset_discipline');
      expect(intent.reasonCode, startsWith('same_signal_'));
      // Match the canonical target resolver: distinct identity, existing
      // world/lesson/task, and drill phase. No lock or grade bypass is added.
      expect(target.phase, Act0LessonPhaseV1.drill);
      expect(target.resolvedTaskFamily, Act0TaskFamilyV1.decision);
      expect(target.rewardXp, 0);
      expect(source.rewardXp, 0);
      expect(source.runner.feedbackSignalId, 'asm05_known_holes_ev');
      expect(target.runner.feedbackSignalId, source.runner.feedbackSignalId);
      expect(
        target.runner.table.toCallLabel,
        isNot(source.runner.table.toCallLabel),
      );
      expect(
        target.runner.options.singleWhere((o) => o.isCorrect).id,
        pair.wrong,
      );
      expect(
        source.runner.options.singleWhere((o) => o.isCorrect).id,
        pair.correct,
      );
      expect(
        target.runner.table.heroCards.map((c) => c.label),
        source.runner.table.heroCards.map((c) => c.label),
      );
      expect(
        target.runner.table.boardCards.map((c) => c.label),
        source.runner.table.boardCards.map((c) => c.label),
      );
    });

    test('${pair.source}: correct answer creates no repair obligation', () {
      final source = _task(pair.source);
      expect(
        buildAct0RepairIntentV1(
          sourceWorldId: 'world_12',
          sourceLessonId: 'decision_over_outcome',
          sourceTaskId: source.taskId,
          runner: source.runner,
          selectedOption: source.runner.options.singleWhere((o) => o.isCorrect),
          mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
        ),
        isNull,
      );
    });

    test(
      '${pair.source}: mapping requires the exact admitted repair tuple',
      () {
        for (final outcome in ['repair_started', 'needs_rep']) {
          final mapping = act0FirstValueSameSignalRepMappingV1(
            nextRepId: 'repeat_mindset_process_discipline',
            skillAtomId: 'mindset_process_discipline',
            sourceSignalId: 'process_over_outcome',
            sourceTaskId: pair.source,
            receiptOutcome: outcome,
          );
          expect(mapping?.taskId, pair.target);
          expect(mapping?.mappingType, 'repair');
        }
        for (final bad in [
          'next',
          'skill',
          'signal',
          'source',
          'learned',
          'outcome',
        ]) {
          final mapping = act0FirstValueSameSignalRepMappingV1(
            nextRepId: bad == 'next'
                ? 'repeat_price_read'
                : 'repeat_mindset_process_discipline',
            skillAtomId: bad == 'skill'
                ? 'price_read'
                : 'mindset_process_discipline',
            sourceSignalId: bad == 'signal'
                ? 'pot_to_call'
                : 'process_over_outcome',
            sourceTaskId: bad == 'source'
                ? 'asm05_new_known_holes_turn_call_999'
                : pair.source,
            receiptOutcome: bad == 'learned'
                ? 'learned'
                : bad == 'outcome'
                ? 'unknown'
                : 'repair_started',
          );
          expect(mapping, isNull, reason: '${pair.source}/$bad');
        }
      },
    );
  }

  test(
    'existing W12 process pair retains repair and reinforcement targets',
    () {
      for (final pair in const [
        (
          source: 'w12_bad_call_good_result',
          lesson: 'mindset_bridge_checkpoint',
          target: 'w12_checkpoint_process_line',
        ),
        (
          source: 'w12_checkpoint_process_line',
          lesson: 'decision_over_outcome',
          target: 'w12_bad_call_good_result',
        ),
      ]) {
        for (final outcome in ['repair_started', 'needs_rep', 'learned']) {
          final mapping = act0FirstValueSameSignalRepMappingV1(
            nextRepId: 'repeat_mindset_process_discipline',
            skillAtomId: 'mindset_process_discipline',
            sourceSignalId: 'process_over_outcome',
            sourceTaskId: pair.source,
            receiptOutcome: outcome,
          );
          expect(mapping?.worldId, 'world_12');
          expect(mapping?.lessonId, pair.lesson);
          expect(mapping?.taskId, pair.target);
          expect(
            mapping?.mappingType,
            outcome == 'learned' ? 'reinforcement' : 'repair',
          );
        }
      }
    },
  );
}
