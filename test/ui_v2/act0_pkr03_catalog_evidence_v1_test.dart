// PKR-03 inventory, not a declaration that an unproved hand is valid.
// Captures the full catalog and real consumer projections for poker review.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

// Direct typed source inputs, not inferred history or an independent oracle.
Map<String, Object?> _tableSourceInputs(Act0TableStateV1 table) => {
  'scope': table.scope.name,
  'table_format': table.tableFormat.name,
  'player_count': table.playerCount,
  'canonical_player_count': table.usesCanonicalPlayerCount,
  'canonical_seat_order': table.canonicalSeatOrder,
  'street': table.streetLabel,
  'pot_label': table.potLabel,
  'to_call_label': table.toCallLabel,
  'active_seat_id': table.activeSeatId,
  if (table.decisionSeatId != null) 'decision_seat_id': table.decisionSeatId,
  'hero_seat_id': table.heroSeatId,
  'seats': [
    for (final seat in table.seats)
      {
        'id': seat.seatId,
        'label': seat.seatLabel,
        'hero': seat.isHero,
        'dealer_button': seat.isDealerButton,
        'small_blind': seat.isSmallBlind,
        'big_blind': seat.isBigBlind,
        'blind_amount_label': seat.blindAmountLabel,
        'stack_label': seat.stackLabel,
        'current_bet_label': seat.currentBetLabel,
        'bet_kind': seat.bet?.kind.name,
        'bet_amount_label': seat.bet?.amountLabel,
        'in_hand': seat.isInHand,
        'folded': seat.isFolded,
        'occupied': seat.isOccupied,
        'active': seat.isActive,
        'has_acted': seat.hasActed,
        'last_aggressor': seat.isLastAggressor,
        'cards_mode': seat.cardsVisibleMode.name,
        'cards': [
          for (final card in seat.holeCards)
            {'rank': card.rank, 'suit': card.suit},
        ],
      },
  ],
  'hero_cards': [
    for (final card in table.heroCards) {'rank': card.rank, 'suit': card.suit},
  ],
  'board_cards': [
    for (final card in table.boardCards) {'rank': card.rank, 'suit': card.suit},
  ],
};

void main() {
  test(
    'all authored tasks and consumer variants retain explicit proof status',
    () {
      final inventory = <Map<String, Object?>>[];
      for (final world in Act0ShellStateV1.sample.worlds) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final runner = task.runner;
            final states = <String, Act0TableStateV1>{
              'authored': runner.table,
              'review/unselected': act0FeedbackTableForRunnerV1(
                runner: runner.copyWith(phase: Act0LessonPhaseV1.review),
                taskFamily: task.resolvedTaskFamily,
              ),
              for (var i = 0; i < runner.teachingSteps.length; i++)
                'teaching/$i/raw':
                    runner.teachingSteps[i].table ?? runner.table,
              for (var i = 0; i < runner.teachingSteps.length; i++)
                'teaching/$i/projected': act0TeachingTableForRunnerV1(
                  runner.table,
                  runner.teachingSteps[i],
                ),
              for (final option in runner.options)
                'feedback/${option.id}': act0FeedbackTableForRunnerV1(
                  runner: runner.copyWith(
                    phase: Act0LessonPhaseV1.review,
                    selectedOptionId: option.id,
                    teachingStepIndex: runner.teachingSteps.length,
                  ),
                  taskFamily: task.resolvedTaskFamily,
                ),
              for (final option in runner.options)
                'repair/${option.id}': act0RepairTableForRunnerV1(
                  runner.table,
                  option,
                ),
            };
            final plan = act0TableChoreographyPlanForTableV1(runner.table);
            if (plan != null) {
              for (var i = -1; i < plan.beats.length; i++) {
                states['choreography/$i'] = act0TableForChoreographyFrameV1(
                  runner.table,
                  act0TableChoreographyFrameAfterBeatV1(plan, i),
                );
              }
            }
            final rows = <Map<String, Object?>>[];
            for (final entry in states.entries) {
              final table = entry.value;
              final proof = act0BettingRoundOrderProofForTableV1(table);
              final truth = proof.truth;
              final conditional =
                  act0BettingRoundOrderConditionalProofForTableV1(table);
              final replay = act0StreetReplayFromTableV1(table);
              final choreography = act0TableChoreographyPlanForTableV1(table);
              if (truth == Act0BettingRoundOrderTruthV1.contradiction) {
                expect(
                  replay?.isConsumerSafe ?? false,
                  isFalse,
                  reason: '${task.taskId}/${entry.key}',
                );
                expect(
                  choreography,
                  isNull,
                  reason: '${task.taskId}/${entry.key}',
                );
              }
              rows.add({
                'variant': entry.key,
                'scope': table.scope.name,
                'order_proof': truth.name,
                'order_reason': proof.reason,
                'conditional_only_not_proof': {
                  'truth': conditional.truth.name,
                  'reason': conditional.reason,
                  'assumptions': conditional.assumptions,
                },
                'source_inputs': _tableSourceInputs(table),
                'replay_safe': replay?.isConsumerSafe ?? false,
                'choreography_available': choreography != null,
                'street': table.streetLabel,
                'actor': table.activeSeatId,
                'trail': [
                  for (final a in table.actionTrail)
                    {'kind': a.kind.name, 'label': a.label},
                ],
              });
            }
            inventory.add({
              'world': world.worldId,
              'lesson': lesson.lessonId,
              'task': task.taskId,
              'source_fingerprint': act0AuthoredSourceFingerprintV1(
                worldId: world.worldId,
                lessonId: lesson.lessonId,
                task: task,
              ),
              'source_phase': task.phase.name,
              'source_step_kind': task.stepKind.name,
              'source_family': task.resolvedTaskFamily.name,
              'source_inputs': _tableSourceInputs(runner.table),
              'caption': runner.caption,
              'question': runner.question,
              'hint': runner.hint,
              'feedback_reason': runner.feedbackReason,
              'teaching_source': [
                for (var i = 0; i < runner.teachingSteps.length; i++)
                  {
                    'index': i,
                    'title': runner.teachingSteps[i].title,
                    'body': runner.teachingSteps[i].body,
                  },
              ],
              'source_seats': [
                for (final seat in runner.table.seats)
                  {
                    'id': seat.seatId,
                    'label': seat.seatLabel,
                    'stack_label': seat.stackLabel,
                    'bet_kind': seat.bet?.kind.name,
                    'in_hand': seat.isInHand,
                    'folded': seat.isFolded,
                    'occupied': seat.isOccupied,
                  },
              ],
              'options': [
                for (final o in runner.options)
                  {
                    'id': o.id,
                    'label': o.label,
                    'correct': o.isCorrect,
                    'source_authored_correct':
                        act0RunnerOptionIsAuthoredCorrectV1(o),
                    'quality': o.quality.name,
                    'feedback_reason': o.feedbackReason,
                    'seat_id': o.seatId,
                  },
              ],
              'applicability': runner.table.scope == Act0TableScopeV1.playedHand
                  ? 'PLAYED_HAND_REQUIRES_SOURCE_POKER_REVIEW'
                  : 'CONCEPTUAL_SCOPE_REVIEW_PROMPT_SEPARATELY',
              'variants': rows,
            });
          }
        }
      }
      expect(inventory.map((r) => r['task']).toSet().length, inventory.length);
      final directory = Directory(
        Platform.environment['PKR03_OUTPUT'] ?? 'output/pkr03-full',
      );
      directory.createSync(recursive: true);
      File('${directory.path}/catalog-proof-status.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(inventory),
      );
      print(
        'PKR03 task_records=${inventory.length} '
        'variant_records=${inventory.fold<int>(0, (n, r) => n + (r['variants'] as List).length)} '
        'accepted_denominator=UNRESOLVED',
      );
    },
  );
}
