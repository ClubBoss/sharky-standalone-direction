import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

// This is a source/projection inventory, not an oracle built from correct flags.
// Only the two complete authored hands below have independent numeric receipts.
// Every other source and every conceptual option remains visible in the output.
const _knownNumericCalls = {
  'asm05_new_known_holes_turn_call_10': (10.0, 50.0),
  'asm05_new_known_holes_turn_call_40': (40.0, 80.0),
};

// These are already-authored pot-fraction QUESTIONS, not executable bet
// submissions. The pot is proved separately from the exact source trail below.
// No player stack is assumed and no legal-bet certificate is issued.
const _w4PotFractionMath = <String, double>{
  'w4_small_bet': 2,
  'w4_half_pot_bet': 3,
  'w4_pot_bet': 6,
};
const _w4SixBbTrail = <String>[
  'SB blind 0.5 BB',
  'BB blind 1 BB',
  'UTG folds',
  'HJ folds',
  'CO folds',
  'BTN raises 2.75 BB',
  'SB folds',
  'BB calls 2.75 BB',
  'Flop: BB checks',
];

void main() {
  test(
    'full source denominator and every option remain explicit, including held scenes',
    () {
      final tasks = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .toList();
      expect(tasks.length, 369);
      expect(tasks.map((t) => t.taskId).toSet().length, tasks.length);
      expect(
        tasks
            .where((t) => t.runner.table.scope == Act0TableScopeV1.playedHand)
            .length,
        316,
      );
      final explicitTeaching = tasks
          .expand((t) => t.runner.teachingSteps)
          .where((s) => s.table != null)
          .toList();
      expect(explicitTeaching.length, 4);
      expect(
        explicitTeaching.every(
          (s) => s.table!.scope == Act0TableScopeV1.orientation,
        ),
        isTrue,
      );
      final rows = <Map<String, Object?>>[];
      var numericChoices = 0;
      var correctNumericChoices = 0;
      var sizingChoices = 0;
      var arithmeticSizingChoices = 0;
      var conceptualAdmissions = 0;
      var actionDefinitionChoices = 0;
      final provedNumericTasks = <String>{};
      for (final world in Act0ShellStateV1.sample.worlds) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final runner = task.runner;
            // Mirror the ACTUAL Runner: a sizing task is an executable wager
            // only when its sizing UI is enabled. W4's seven numeric labels
            // are ordinary choices about fractions of an already-built pot.
            final familyIsSizing =
                task.resolvedTaskFamily == Act0TaskFamilyV1.sizing;
            final typedSizing = familyIsSizing && runner.sizingConfig.isEnabled;
            final arithmeticSizing =
                familyIsSizing && !runner.sizingConfig.isEnabled;
            if (arithmeticSizing) {
              expect(
                _w4PotFractionMath.containsKey(task.taskId),
                isTrue,
                reason: 'Unknown sizing semantics need source-owner review',
              );
              expect(runner.table.streetLabel, 'Flop');
              expect(runner.table.activeSeatId, 'btn');
              expect(runner.table.potLabel, 'Pot 6 BB');
              expect(
                runner.table.actionTrail
                    .where((item) => !item.isNote)
                    .map((item) => item.label)
                    .toList(),
                _w4SixBbTrail,
              );
              // Independent pot: SB 0.5 + BTN 2.75 + BB 2.75 = 6.
              expect(0.5 + 2.75 + 2.75, 6);
            }
            final options = <Map<String, Object?>>[];
            for (final option in runner.options) {
              final numeric =
                  RegExp(
                    r'^(call|bet|raise|shove|jam)\b',
                    caseSensitive: false,
                  ).hasMatch(option.label.trim()) &&
                  option.amountLabel.trim().isNotEmpty;
              final result = act0BettingPriceForOptionV1(
                runner.table,
                option,
                sizingBet: typedSizing,
                taskId: task.taskId,
                question: runner.question,
              );
              final blocked = act0BettingPriceBlocksAuthoredSuccessV1(
                runner.table,
                option,
                sizingBet: typedSizing,
                taskId: task.taskId,
                question: runner.question,
              );
              if (result.reason == 'source_action_definition') {
                actionDefinitionChoices++;
                expect(
                  task.taskId,
                  isIn(const ['actions_legal_context', 'actions_check_drill']),
                );
                expect(option.amountLabel, isEmpty);
                expect(typedSizing, isFalse);
                expect(blocked, isFalse);
              }
              if (result.reason == 'source_conceptual_answer') {
                conceptualAdmissions++;
                expect(option.amountLabel, isEmpty);
                expect(typedSizing, isFalse);
                expect(blocked, isFalse);
              }
              if (typedSizing) sizingChoices++;
              if (arithmeticSizing) {
                arithmeticSizingChoices++;
                final match = RegExp(
                  r'^([0-9]+(?:\.[0-9]+)?) BB$',
                ).firstMatch(option.label.trim());
                expect(match, isNotNull, reason: task.taskId);
                final selectedSize = double.parse(match![1]!);
                final actualMathAnswer =
                    selectedSize == _w4PotFractionMath[task.taskId];
                expect(
                  option.isCorrect,
                  actualMathAnswer,
                  reason: '${task.taskId}/${option.id}: fraction oracle',
                );
                expect(result.appliesToWager, isFalse);
                expect(result.reason, 'not_wager_action');
                expect(blocked, isFalse);
              }
              if (numeric) {
                numericChoices++;
                if (option.isCorrect) correctNumericChoices++;
                final oracle = _knownNumericCalls[task.taskId];
                if (oracle != null) {
                  // Both calls are legal. The 40 BB call's wrong strategic grade
                  // is preserved, and must not become a false source failure.
                  expect(result.truth, Act0BettingPriceTruthV1.consistent);
                  expect(result.callCostBb, oracle.$1);
                  expect(result.potBeforeActionBb, oracle.$2);
                  expect(blocked, isFalse);
                  provedNumericTasks.add(task.taskId);
                } else {
                  // Base author-data gaps have no approved replacement facts.
                  // A future source repair must update its independent receipt.
                  expect(result.sourceReady, isFalse, reason: task.taskId);
                  expect(
                    blocked,
                    isTrue,
                    reason: '${task.taskId}/${option.id}',
                  );
                }
              }
              if (typedSizing) {
                // All seven canonical presets lack actor stack capacity today.
                expect(result.appliesToWager, isTrue);
                expect(result.sourceReady, isFalse);
                expect(blocked, isTrue);
              }
              options.add({
                'id': option.id,
                'label': option.label,
                'amount': option.amountLabel,
                'source_correct': option.isCorrect,
                'source_quality': option.quality.name,
                'source_rationale': option.feedbackReason,
                'typed_sizing': typedSizing,
                'numeric_wager': numeric,
                'parser_applicable': result.appliesToWager,
                'truth': result.truth.name,
                'reason': result.reason,
                'source_ready': result.sourceReady,
                'grading_withheld': blocked,
                'call_cost_bb': result.callCostBb,
                'additional_cost_bb': result.additionalCostBb,
                'pot_before_action_bb': result.potBeforeActionBb,
                'minimum_raise_to_bb': result.minimumRaiseToBb,
              });
            }
            rows.add({
              'world': world.worldId,
              'lesson': lesson.lessonId,
              'task': task.taskId,
              'phase': task.phase.name,
              'family': task.resolvedTaskFamily.name,
              'question': runner.question,
              'source_fingerprint': act0AuthoredSourceFingerprintV1(
                worldId: world.worldId,
                lessonId: lesson.lessonId,
                task: task,
              ),
              'table': _table(runner.table),
              'options': options,
              'teaching': [
                for (final step in runner.teachingSteps)
                  {
                    'authored': step.table == null ? null : _table(step.table!),
                    'projected': _table(
                      act0TeachingTableForRunnerV1(runner.table, step),
                    ),
                  },
              ],
              'feedback': {
                for (final option in runner.options)
                  option.id: _table(
                    act0FeedbackTableForRunnerV1(
                      runner: runner.copyWith(
                        phase: Act0LessonPhaseV1.review,
                        selectedOptionId: option.id,
                        teachingStepIndex: runner.teachingSteps.length,
                      ),
                      taskFamily: task.resolvedTaskFamily,
                    ),
                  ),
              },
            });
          }
        }
      }
      expect(numericChoices, 65);
      expect(correctNumericChoices, 29);
      expect(sizingChoices, 7);
      expect(conceptualAdmissions, 19);
      expect(actionDefinitionChoices, 6);
      expect(provedNumericTasks, _knownNumericCalls.keys.toSet());
      final out = File('output/pkr0205/catalog-coverage.json');
      out.parent.createSync(recursive: true);
      out.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'evidence':
              'source and real projection inventory; not native/Human or full DoD acceptance',
          'source_tasks': tasks.length,
          'authored_tables': tasks.length + explicitTeaching.length,
          'numeric_choices': numericChoices,
          'numeric_correct': correctNumericChoices,
          'sizing_choices': sizingChoices,
          'conceptual_answer_admissions': conceptualAdmissions,
          'action_definition_admissions': actionDefinitionChoices,
          'independent_numeric_receipts': _knownNumericCalls.keys.toList(),
          'limits':
              'Non-numeric directions need explicit author intent. No absent stack/history/pot is fabricated. Strategic grades are not legality oracles.',
          'rows': rows,
        }),
      );
    },
  );
}

Map<String, Object?> _table(Act0TableStateV1 table) => {
  'scope': table.scope.name,
  'street': table.streetLabel,
  'actor': table.activeSeatId,
  'hero': table.heroSeatId,
  'pot_claim': table.potLabel,
  'call_claim': table.toCallLabel,
  'order_truth': act0BettingRoundOrderProofForTableV1(table).truth.name,
  'order_reason': act0BettingRoundOrderProofForTableV1(table).reason,
  'trail': [
    for (final item in table.actionTrail)
      {'kind': item.kind.name, 'label': item.label},
  ],
  'seats': [
    for (final seat in table.seats)
      {
        'id': seat.seatId,
        'position': seat.seatLabel,
        'hero': seat.isHero,
        'occupied': seat.isOccupied,
        'in_hand': seat.isInHand,
        'folded': seat.isFolded,
        'stack': seat.stackLabel,
        'current_bet': seat.currentBetLabel,
      },
  ],
};
