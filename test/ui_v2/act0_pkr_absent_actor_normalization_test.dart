import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';

void main() {
  for (final id in ['actions_fold_drill', 'actions_call_drill']) {
    final source = Act0ShellStateV1.sample
        .lessonById('fold_check_call_raise')
        .taskList
        .singleWhere((t) => t.taskId == id)
        .runner;
    test(
      '$id drill normalization preserves absent actor and valid definition',
      () {
        expect(source.table.activeSeatId, isNull);
        final normalized = normalizeAct0DrillSeatHighlightPolicyV1(
          source.copyWith(phase: Act0LessonPhaseV1.drill),
        );
        expect(normalized.table.activeSeatId, isNull);
        expect(normalized.table.heroSeatId, source.table.heroSeatId);
        expect(normalized.table.highlightedSeatIds, isEmpty);
        expect(normalized.table.seats, orderedEquals(source.table.seats));
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            normalized.table,
            normalized.options.singleWhere((o) => o.isCorrect),
            taskId: id,
            question: normalized.question,
          ),
          false,
        );
      },
    );
    for (final actor in ['co', '', ' ']) {
      test(
        '$id mutated explicit actor "$actor" still rejected after normalization',
        () {
          final normalized = normalizeAct0DrillSeatHighlightPolicyV1(
            source.copyWith(
              phase: Act0LessonPhaseV1.drill,
              table: source.table.copyWith(activeSeatId: actor),
            ),
          );
          expect(
            act0BettingPriceBlocksAuthoredSuccessV1(
              normalized.table,
              normalized.options.singleWhere((o) => o.isCorrect),
              taskId: id,
              question: normalized.question,
            ),
            true,
          );
        },
      );
    }
  }
  test('real explicit actor is trimmed and remains the highlight owner', () {
    final source = Act0ShellStateV1.sample
        .lessonById('fold_check_call_raise')
        .taskList
        .singleWhere((t) => t.taskId == 'actions_raise_drill')
        .runner;
    final normalized = normalizeAct0DrillSeatHighlightPolicyV1(
      source.copyWith(
        phase: Act0LessonPhaseV1.drill,
        table: source.table.copyWith(activeSeatId: ' btn '),
      ),
    );
    expect(normalized.table.activeSeatId, 'btn');
    expect(normalized.table.highlightedSeatIds, ['btn']);
  });
}
