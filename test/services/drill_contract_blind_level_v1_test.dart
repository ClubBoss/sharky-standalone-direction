import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';

void main() {
  test(
    'DrillSpecV1 exposes optional blind-level state on scenario table context',
    () {
      final spec = DrillSpecV1.fromJsonString('''
{
  "id": "ante_ready_seat_tap_v1",
  "kind": "seat_tap",
  "prompt": "Tap the big blind.",
  "player_count_v1": 6,
  "hero_seat_v1": "btn",
  "villain_seat_v1": "bb",
  "active_seats_v1": ["btn", "co", "hj", "sb", "bb", "utg"],
  "small_blind_seat_v1": "sb",
  "big_blind_seat_v1": "bb",
  "small_blind_amount_v1": 50,
  "big_blind_amount_v1": 100,
  "ante_amount_v1": 10,
  "expected": {"seatId": "bb"},
  "error_class": "seat_tap_mismatch"
}
''');

      final blindLevel =
          spec.scenarioTableContextV1?.seatContextV1?.blindLevelV1;
      expect(blindLevel, isNotNull);
      expect(blindLevel!.smallBlindSeatV1, 'sb');
      expect(blindLevel.bigBlindSeatV1, 'bb');
      expect(blindLevel.smallBlindAmountV1, 50);
      expect(blindLevel.bigBlindAmountV1, 100);
      expect(blindLevel.anteAmountV1, 10);
    },
  );

  test(
    'DrillSpecV1 keeps blind-level authored state backward compatible when absent',
    () {
      final spec = DrillSpecV1.fromJsonString('''
{
  "id": "legacy_seat_tap_v1",
  "kind": "seat_tap",
  "prompt": "Tap the button.",
  "player_count_v1": 6,
  "hero_seat_v1": "btn",
  "villain_seat_v1": "bb",
  "active_seats_v1": ["btn", "co", "hj", "sb", "bb", "utg"],
  "expected": {"seatId": "btn"},
  "error_class": "seat_tap_mismatch"
}
''');

      expect(spec.scenarioTableContextV1, isNotNull);
      expect(spec.scenarioTableContextV1!.seatContextV1!.blindLevelV1, isNull);
    },
  );

  test('DrillSpecV1 rejects partial blind-level authored state', () {
    expect(
      () => DrillSpecV1.fromJsonString('''
{
  "id": "partial_blind_state_v1",
  "kind": "seat_tap",
  "prompt": "Tap the big blind.",
  "player_count_v1": 6,
  "hero_seat_v1": "btn",
  "villain_seat_v1": "bb",
  "active_seats_v1": ["btn", "co", "hj", "sb", "bb", "utg"],
  "big_blind_seat_v1": "bb",
  "big_blind_amount_v1": 100,
  "expected": {"seatId": "bb"},
  "error_class": "seat_tap_mismatch"
}
''').scenarioTableContextV1,
      throwsStateError,
    );
  });
}
