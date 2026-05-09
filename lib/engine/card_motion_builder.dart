import 'dart:ui' show Offset;

import 'card_motion_spec.dart';
import 'table_seat_slots.dart';

CardMotionSequence buildPreflopDealMotion({
  required TableSeatSlot seat,
  required Offset boardPosition,
}) {
  return [
    CardMotionSpec(
      id: 'seat:${seat.index}',
      from: seat.position,
      to: boardPosition,
      durationMs: 260,
      delayMs: 0,
      flipFactor: 1.0,
    ),
  ];
}
