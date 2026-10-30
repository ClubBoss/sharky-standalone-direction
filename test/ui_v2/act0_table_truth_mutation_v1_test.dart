import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test(
    'claim guard rejects an underpair and board trips as top pair or a set',
    () {
      final source = Act0ShellStateV1.sample
          .lessonById('your_first_hand')
          .taskList
          .first
          .runner
          .table;
      final underpair = source.copyWith(
        heroCards: const [
          Act0CardStateV1(rank: 'Q', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 'd'),
        ],
        boardCards: const [
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: '7', suit: 'd'),
          Act0CardStateV1(rank: '2', suit: 's'),
        ],
      );
      expect(madeHandClaimMatches(underpair, 'top pair'), isFalse);
      final topPair = underpair.copyWith(
        heroCards: const [
          Act0CardStateV1(rank: 'K', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 'd'),
        ],
      );
      expect(madeHandClaimMatches(topPair, 'top pair'), isTrue);
      final trips = underpair.copyWith(
        heroCards: const [
          Act0CardStateV1(rank: 'K', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 'd'),
        ],
        boardCards: const [
          Act0CardStateV1(rank: 'K', suit: 'c'),
          Act0CardStateV1(rank: 'K', suit: 'd'),
          Act0CardStateV1(rank: '2', suit: 's'),
        ],
      );
      expect(madeHandClaimMatches(trips, 'a set'), isFalse);
      final set = underpair.copyWith(
        heroCards: const [
          Act0CardStateV1(rank: 'K', suit: 's'),
          Act0CardStateV1(rank: 'K', suit: 'd'),
        ],
      );
      expect(madeHandClaimMatches(set, 'a set'), isTrue);
    },
  );
  test('previous-street bet does not demand a new chip on a checked turn', () {
    final source = Act0ShellStateV1.sample
        .lessonById('your_first_hand')
        .taskList
        .first
        .runner
        .table;
    final turn = source.copyWith(
      streetLabel: 'Turn',
      actionTrail: const [
        Act0ActionTrailItemV1(label: 'Flop: BB bets 2 BB'),
        Act0ActionTrailItemV1(label: 'Turn: BB checks'),
      ],
    );
    expect(explicitCurrentStreetBet(turn), isNull);
    expect(
      explicitCurrentStreetBet(
        turn.copyWith(
          actionTrail: const [
            Act0ActionTrailItemV1(label: 'Turn: BB bets 3 BB'),
          ],
        ),
      ),
      ('BB', 3.0),
    );
  });
  test(
    'approved no-ante bubble line conserves chips without dictating strategy',
    () {
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'w9_bubble_table_risk_transfer');
      final table = task.runner.table;
      final sums = <String, double>{};
      for (final item in table.actionTrail) {
        final m = RegExp(
          r'^(SB|BB|BTN) (blind|raises to|shoves to) ([\d.]+) BB',
        ).firstMatch(item.label);
        if (m != null) sums[m[1]!] = double.parse(m[3]!);
      }
      final pot = sums.values.fold<double>(0, (a, b) => a + b);
      expect(pot, 21);
      expect(table.potLabel, 'Pot $pot BB'.replaceFirst('21.0', '21'));
      expect(table.toCallLabel, 'To call ${sums['BB']! - sums['BTN']!} BB');
      expect(table.activeSeatId, table.heroSeat.seatId);
      expect(
        table.seats
            .where((s) => s.isInHand && !s.isFolded)
            .map((s) => s.seatId)
            .toSet(),
        {'bb', 'btn'},
      );
      expect(
        table.seats.singleWhere((s) => s.seatId == 'bb').bet!.amountLabel,
        '18 BB',
      );
      // This question tests tournament risk premium, not a numerical call threshold.
      final correct = task.runner.options.singleWhere((o) => o.isCorrect);
      expect(correct.id, 'tighten_stackoff');
      expect(correct.feedbackReason, contains('risk premium'));
    },
  );
}
