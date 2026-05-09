import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:test/test.dart';

void main() {
  const evaluator = DrillEvaluatorV1();

  test('card_tap alias normalizes hole_left to canonical hole_cards_tap', () {
    final spec = DrillSpecV1.fromJsonString(
      '{"id":"tap_hole_left_anchor","kind":"card_tap","prompt":"Tap hole_left","expected":{"cardSlot":"hole_left"},"error_class":"focus_anchor_mismatch"}',
    );

    expect(spec.kind, DrillKindV1.holeCardsTap);
    expect(spec.expected.cardSlot, 'p0');
    expect(
      evaluator
          .evaluate(spec, DrillUserEventV1.holeCardsTap(cardSlot: 'p0'))
          .isPass,
      isTrue,
    );
    expect(
      evaluator
          .evaluate(spec, DrillUserEventV1.holeCardsTap(cardSlot: 'p1'))
          .isPass,
      isFalse,
    );
  });
}
