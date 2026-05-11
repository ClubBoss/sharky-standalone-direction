import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/learner_action_semantics_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';

void main() {
  test(
    'canonical learner action semantics maps preflop bet into raise family',
    () {
      expect(
        canonicalizeLearnerActionKindV1(
          kind: ActionKindV1.bet,
          isPreflop: true,
          toCall: 0,
        ),
        ActionKindV1.raise,
      );
      expect(
        canonicalizeLearnerActionTokenV1(
          token: 'bet',
          isPreflop: true,
          toCall: 0,
        ),
        'raise',
      );
    },
  );

  test(
    'canonical learner action semantics maps facing-price bet into raise family',
    () {
      expect(
        canonicalizeLearnerActionKindV1(
          kind: ActionKindV1.bet,
          isPreflop: false,
          toCall: 4,
        ),
        ActionKindV1.raise,
      );
    },
  );

  test(
    'canonical learner action semantics maps zero-price call into check',
    () {
      expect(
        canonicalizeLearnerActionKindV1(
          kind: ActionKindV1.call,
          isPreflop: true,
          toCall: 0,
        ),
        ActionKindV1.check,
      );
      expect(
        canonicalizeLearnerActionTokenV1(
          token: 'call',
          isPreflop: true,
          toCall: 0,
        ),
        'check',
      );
    },
  );

  test(
    'canonical learner action semantics preserves postflop zero-price bet',
    () {
      expect(
        canonicalizeLearnerActionKindV1(
          kind: ActionKindV1.bet,
          isPreflop: false,
          toCall: 0,
        ),
        ActionKindV1.bet,
      );
    },
  );
}
