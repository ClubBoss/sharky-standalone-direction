import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'board_motion_builder.dart';
import 'card_motion_builder.dart';
import 'card_motion_spec.dart';
import 'chip_motion_spec.dart';
import 'street_engine.dart';
import 'table_seat_slots.dart';

class SidePotReveal {
  const SidePotReveal({
    required this.winners,
    required this.potOffset,
    required this.seatOffsets,
  });

  final List<int> winners;
  final Offset potOffset;
  final List<Offset> seatOffsets;
}

const int _kTableSeatCount = 6;

class MotionScriptBuilder {
  const MotionScriptBuilder();

  static List<CardMotionSequence> demo({
    required List<TableSeatSlot> seats,
    required Offset boardPosition,
  }) {
    return _buildScript(seats: seats, boardPosition: boardPosition);
  }

  static List<CardMotionSequence> buildDualDealSequence({
    required List<TableSeatSlot> seats,
    required Offset boardPosition,
  }) {
    final seq = <CardMotionSequence>[];
    var delay = 0;
    for (final seat in seats) {
      seq.add([
        CardMotionSpec(
          id: 'deal_dual:${seat.index}:1',
          from: seat.position,
          to: boardPosition,
          durationMs: 220.0,
          delayMs: delay.toDouble(),
        ),
      ]);
      seq.add([
        CardMotionSpec(
          id: 'deal_dual:${seat.index}:2',
          from: seat.position,
          to: boardPosition,
          durationMs: 220.0,
          delayMs: (delay + 60).toDouble(),
        ),
      ]);
      delay += 40;
    }
    return seq;
  }

  static List<CardMotionSequence> _buildScript({
    required List<TableSeatSlot> seats,
    required Offset boardPosition,
    List<CardMotionSequence> extras = const [],
  }) {
    final script = <CardMotionSequence>[];
    for (final seat in seats) {
      script.add(
        buildPreflopDealMotion(seat: seat, boardPosition: boardPosition),
      );
    }
    script.add(buildFlopMotion(cardPosition: boardPosition));
    script.add(buildTurnMotion(cardPosition: boardPosition));
    script.add(buildRiverMotion(cardPosition: boardPosition));
    if (extras.isNotEmpty) {
      script.addAll(extras);
    }
    return script;
  }

  static const double _defaultCardStaggerMs = 80.0;

  static List<CardMotionSequence> buildStreetReveal(
    Street street, {
    required List<Offset> boardCardPositions,
    required Offset boardPosition,
    double delayMs = 0.0,
    double staggerMs = _defaultCardStaggerMs,
  }) {
    final indexes = _indexesForStreet(street);
    if (indexes.isEmpty) {
      return const [];
    }
    final script = <CardMotionSequence>[];
    var slotDelay = 0.0;
    for (final cardIndex in indexes) {
      final position = cardIndex < boardCardPositions.length
          ? boardCardPositions[cardIndex]
          : (boardCardPositions.isNotEmpty
                ? boardCardPositions.last
                : boardPosition);
      final template = _boardMotionForStreet(street, position);
      if (template.isEmpty) {
        continue;
      }
      final baseSpec = template.first;
      final revealSpec = CardMotionSpec(
        id: '${baseSpec.id}:$cardIndex',
        from: position,
        to: position,
        durationMs: baseSpec.durationMs,
        delayMs: delayMs + slotDelay + baseSpec.delayMs,
        burstFactor: baseSpec.burstFactor,
        smoothFactor: baseSpec.smoothFactor,
        bloomFactor: baseSpec.bloomFactor,
        flipFactor: baseSpec.flipFactor,
      );
      script.add([revealSpec]);
      slotDelay += staggerMs;
    }
    return script;
  }

  static List<CardMotionSequence> buildStreetTransition(
    Street street, {
    required List<Offset> boardCardPositions,
    required Offset boardPosition,
    double delayMs = 0.0,
    double staggerMs = _defaultCardStaggerMs,
  }) => buildStreetReveal(
    street,
    boardCardPositions: boardCardPositions,
    boardPosition: boardPosition,
    delayMs: delayMs,
    staggerMs: staggerMs,
  );

  static List<int> _indexesForStreet(Street street) {
    switch (street) {
      case Street.flop:
        return const [0, 1, 2];
      case Street.turn:
        return const [3];
      case Street.river:
        return const [4];
      default:
        return const [];
    }
  }

  static CardMotionSequence _boardMotionForStreet(
    Street street,
    Offset cardPosition,
  ) {
    switch (street) {
      case Street.flop:
        return buildFlopMotion(cardPosition: cardPosition);
      case Street.turn:
        return buildTurnMotion(cardPosition: cardPosition);
      case Street.river:
        return buildRiverMotion(cardPosition: cardPosition);
      default:
        return const [];
    }
  }

  static CardMotionSequence buildResetSequence({
    required List<Offset> boardOffsets,
    required Offset potOffset,
  }) {
    final seq = <CardMotionSpec>[];
    var base = Duration.zero;
    for (final offset in boardOffsets) {
      seq.add(
        CardMotionSpec(
          id: 'reset:board',
          from: offset,
          to: offset,
          durationMs: 300.0,
          delayMs: base.inMilliseconds.toDouble(),
        ),
      );
      base += const Duration(milliseconds: 80);
    }
    seq.add(
      CardMotionSpec(
        id: 'reset:pot',
        from: potOffset,
        to: potOffset,
        durationMs: 300.0,
        delayMs: base.inMilliseconds.toDouble(),
      ),
    );
    return seq;
  }

  static List<CardMotionSpec> buildHandResetBundle(
    List<Offset> board,
    Offset pot,
  ) {
    final script = _buildScript(
      seats: const [],
      boardPosition: pot,
      extras: [buildResetSequence(boardOffsets: board, potOffset: pot)],
    );
    if (script.isEmpty) {
      return const [];
    }
    return script.last;
  }

  static CardMotionSequence buildSidePotDistribution(
    List<Offset> seatOffsets,
    List<int> winners,
    Offset potOffset,
  ) {
    final seq = <CardMotionSpec>[];
    var baseDelay = Duration.zero;
    for (final winner in winners) {
      final toSeat = seatOffsets[winner % seatOffsets.length];
      seq.addAll(
        buildChipDistribution(
          fromPot: potOffset,
          toSeat: toSeat,
          duration: const Duration(milliseconds: 500),
          delay: baseDelay,
        ),
      );
      baseDelay += const Duration(milliseconds: 120);
    }
    return seq;
  }

  static List<CardMotionSequence> demoWithChipFlow({
    required List<TableSeatSlot> seats,
    required Offset boardPosition,
    List<CardMotionSequence> extras = const [],
  }) {
    final script = demo(seats: seats, boardPosition: boardPosition);
    script.addAll(extras);
    return script;
  }

  static List<CardMotionSequence> demoWithDualDeal({
    required List<TableSeatSlot> seats,
    required Offset boardPosition,
    List<CardMotionSequence> extras = const [],
  }) {
    final script = <CardMotionSequence>[];
    script.addAll(
      buildDualDealSequence(seats: seats, boardPosition: boardPosition),
    );
    script.addAll(_buildScript(seats: seats, boardPosition: boardPosition));
    script.addAll(extras);
    return script;
  }

  static List<CardMotionSequence> buildSidePotReveal(
    CardMotionSequence mainPotSequence,
    List<SidePotReveal> reveals,
  ) {
    if (mainPotSequence.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          'MotionScriptBuilder.buildSidePotReveal called with empty mainPotSequence.',
        );
      }
      return const [];
    }
    if (reveals.isEmpty) {
      return const [];
    }
    final sequences = <CardMotionSequence>[];
    for (var revealIndex = 0; revealIndex < reveals.length; revealIndex++) {
      final reveal = reveals[revealIndex];
      if (reveal.winners.isEmpty) {
        if (kDebugMode) {
          debugPrint('SidePotReveal at index $revealIndex has no winners.');
        }
        return const [];
      }
      if (reveal.seatOffsets.length != reveal.winners.length &&
          reveal.seatOffsets.length != _kTableSeatCount) {
        if (kDebugMode) {
          debugPrint(
            'SidePotReveal at index $revealIndex has ${reveal.seatOffsets.length} seatOffsets '
            'but ${reveal.winners.length} winners.',
          );
        }
        return const [];
      }
      final staggerMs = revealIndex * 90.0;
      final sequence = <CardMotionSpec>[];
      for (var specIndex = 0; specIndex < mainPotSequence.length; specIndex++) {
        final spec = mainPotSequence[specIndex];
        final winner = reveal.winners[specIndex % reveal.winners.length];
        final toSeat = reveal.seatOffsets[winner % reveal.seatOffsets.length];
        sequence.add(
          CardMotionSpec(
            id: spec.id,
            from: reveal.potOffset,
            to: toSeat,
            durationMs: spec.durationMs,
            delayMs: spec.delayMs + staggerMs,
            burstFactor: spec.burstFactor,
            smoothFactor: spec.smoothFactor,
            bloomFactor: spec.bloomFactor,
            flipFactor: spec.flipFactor,
          ),
        );
      }
      if (sequence.isNotEmpty) {
        sequences.add(sequence);
      }
    }
    return sequences;
  }
}
