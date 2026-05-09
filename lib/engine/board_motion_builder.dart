import 'dart:ui' show Offset;

import 'card_motion_spec.dart';

CardMotionSequence buildFlopMotion({required Offset cardPosition}) {
  return [
    CardMotionSpec(
      id: 'board:flop',
      from: cardPosition,
      to: cardPosition,
      durationMs: 180,
      delayMs: 0,
      flipFactor: 0.8,
    ),
  ];
}

CardMotionSequence buildTurnMotion({required Offset cardPosition}) {
  return [
    CardMotionSpec(
      id: 'board:turn',
      from: cardPosition,
      to: cardPosition,
      durationMs: 180,
      delayMs: 0,
      flipFactor: 0.8,
    ),
  ];
}

CardMotionSequence buildRiverMotion({required Offset cardPosition}) {
  return [
    CardMotionSpec(
      id: 'board:river',
      from: cardPosition,
      to: cardPosition,
      durationMs: 180,
      delayMs: 0,
      flipFactor: 0.8,
    ),
  ];
}
