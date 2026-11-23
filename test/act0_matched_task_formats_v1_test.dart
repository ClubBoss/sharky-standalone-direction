import 'dart:convert';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_poker_reference_math_v1.dart';
import 'package:test/test.dart';

enum _Format { decisionOnly, clue, twoDecisions }

typedef _Spot = ({String id, double currentPot, double call, double winRate});
typedef _Response = ({_Spot spot, String action});

void main() {
  test('LRN-01.b compares decisions on the same two spots', () {
    // Same starting pot and win chance; changing the opposing bet flips the
    // break-even choice. Two players, no ties or further bets.
    const low = (id: 'low_price', currentPot: 8.0, call: 1.0, winRate: .25);
    const high = (id: 'high_price', currentPot: 14.0, call: 7.0, winRate: .25);
    const clue =
        'Compare the chips you still owe with the pot after your call.';

    // Recorded AI dry-run responses. In Clue the same prompt includes the
    // generic clue. In TwoDecisions both prices are posed together without
    // feedback between the decisions, in both orders.
    const runs = <(_Format, List<_Response>)>[
      (_Format.decisionOnly, [(spot: low, action: 'call')]),
      (_Format.decisionOnly, [(spot: high, action: 'fold')]),
      (_Format.clue, [(spot: low, action: 'call')]),
      (_Format.clue, [(spot: high, action: 'fold')]),
      (
        _Format.twoDecisions,
        [(spot: low, action: 'call'), (spot: high, action: 'fold')],
      ),
      (
        _Format.twoDecisions,
        [(spot: high, action: 'fold'), (spot: low, action: 'call')],
      ),
    ];
    final results = {
      for (final format in _Format.values)
        format: <({String spot, String action, bool correct})>[],
    };
    for (final (format, responses) in runs) {
      expect(responses, hasLength(format == _Format.twoDecisions ? 2 : 1));
      final decisions = [
        for (final (:spot, :action) in responses)
          (
            spot: spot.id,
            action: action,
            correct:
                action ==
                (spot.winRate >
                        act0CallPriceV1(spot.currentPot, spot.call)!.equity
                    ? 'call'
                    : 'fold'),
          ),
      ];
      results[format]!.addAll(decisions);
      print(
        jsonEncode({
          'evidence': 'SIMULATED',
          'format': format.name,
          'prompt': [
            'Heads-up. Both players check to showdown after a call. No ties.',
            for (final (:spot, action: _) in responses)
              'The current pot is ${spot.currentPot} BB, including the bet. '
                  'You owe ${spot.call} BB and win ${spot.winRate * 100}% '
                  'of the time if you call. Which earns more, call or fold?',
            if (format == _Format.clue) clue,
          ],
          'decisions': [
            for (final (:spot, :action, :correct) in decisions)
              {'spot': spot, 'action': action, 'correct': correct},
          ],
        }),
      );
    }

    for (final format in _Format.values) {
      final decisions = results[format]!;
      final repeats = format == _Format.twoDecisions ? 2 : 1;
      for (final spot in [low, high]) {
        expect(
          decisions.where((decision) => decision.spot == spot.id),
          hasLength(repeats),
        );
      }
      expect(
        decisions.where((decision) => decision.correct),
        hasLength(2 * repeats),
      );
    }
  });
}
