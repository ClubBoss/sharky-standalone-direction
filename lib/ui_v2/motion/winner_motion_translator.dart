import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../engine/motion/motion_engine.dart';
import 'chip_motion.dart';
import 'side_pot_layout.dart';

class WinnerMotionTranslator {
  WinnerMotionTranslator({
    required this.sidePotLayout,
    required this.seatOffset,
    this.durationMs = 250,
  });

  final SidePotLayout sidePotLayout;
  final Offset Function(int seat) seatOffset;
  final double durationMs;

  List<ChipMotion> build({
    required MotionCommand command,
    required double nowMs,
  }) {
    final potCenter = sidePotLayout.getPotCenter(command.potTier);
    final winners = _resolveWinners(command);
    final shares = _resolveShares(command.amount, winners.length);
    final motions = <ChipMotion>[];
    for (var i = 0; i < winners.length; i++) {
      final winner = winners[i];
      final share = shares[i];
      final particleCount = math.max(
        1,
        math.min(
          8,
          (math.log(share + 1)).isFinite ? math.log(share + 1).floor() : 1,
        ),
      );
      for (var j = 0; j < particleCount; j++) {
        final seed =
            command.timestamp.millisecondsSinceEpoch ^
            command.potTier ^
            winner ^
            j;
        final random = math.Random(seed);
        final jitterStart = Offset(
          potCenter.dx + (random.nextDouble() * 12 - 6),
          potCenter.dy + (random.nextDouble() * 12 - 6),
        );
        final endBase = seatOffset(winner);
        final end = Offset(
          endBase.dx + (random.nextDouble() * 8 - 4),
          endBase.dy + (random.nextDouble() * 8 - 4),
        );
        final base = Offset(
          (jitterStart.dx + end.dx) * 0.5,
          (jitterStart.dy + end.dy) * 0.5,
        );
        final lift = Offset(0, -50);
        final sideways = Offset(random.nextDouble() * 40 - 20, 0);
        final control = base + lift + sideways;
        motions.add(
          ChipMotion(
            startOffset: jitterStart,
            controlOffset: control,
            endOffset: end,
            startTimeMs: nowMs,
            endTimeMs: nowMs + durationMs,
            amount: share,
          ),
        );
      }
    }
    return motions;
  }

  List<int> _resolveWinners(MotionCommand command) {
    return [command.seat];
  }

  List<double> _resolveShares(double amount, int winners) {
    final share = winners == 0 ? 0.0 : amount / winners;
    return List<double>.filled(winners, share);
  }
}
