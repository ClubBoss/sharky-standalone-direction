import 'dart:ui' show Offset;

import 'card_motion_spec.dart';

CardMotionSequence buildSeatToPotMotion({
  required Offset from,
  required Offset potPosition,
}) {
  return [
    CardMotionSpec(
      id: 'pot:seat',
      from: from,
      to: potPosition,
      durationMs: 240,
      delayMs: 0,
    ),
  ];
}

CardMotionSequence buildPotToSeatMotion({
  required Offset potPosition,
  required Offset to,
}) {
  return [
    CardMotionSpec(
      id: 'pot:return',
      from: potPosition,
      to: to,
      durationMs: 300,
      delayMs: 0,
    ),
  ];
}

CardMotionSequence buildChipDistribution({
  required Offset fromPot,
  required Offset toSeat,
  required Duration duration,
  required Duration delay,
}) {
  return [
    CardMotionSpec(
      id: 'chip:distribution',
      from: fromPot,
      to: toSeat,
      durationMs: duration.inMilliseconds.toDouble(),
      delayMs: delay.inMilliseconds.toDouble(),
    ),
  ];
}
