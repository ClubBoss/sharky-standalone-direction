import 'package:flutter/foundation.dart';

import 'act0_f7_scene_source_v1.dart';
import 'act0_scene_profile_v1.dart';
import 'act0_shell_state_v1.dart';

enum Act0F7SceneDispositionV1 {
  pngSuitable,
  proceduralFallbackRequired,
  sourceContextInsufficient,
}

@immutable
class Act0F7SceneDecisionV1 {
  Act0F7SceneDecisionV1(this.disposition, Iterable<String> reasons)
    : reasons = List.unmodifiable(reasons);

  final Act0F7SceneDispositionV1 disposition;

  /// Variant and exact seat IDs are retained for integrator diagnostics.
  final List<String> reasons;
  bool get canUsePng => disposition == Act0F7SceneDispositionV1.pngSuitable;

  /// Scenery eligibility never certifies a complete hand/economic history,
  /// legal action, assessment answer or strategy. TABLE.TRUTH remains separate.
  bool get certifiesPokerTruth => false;
}

/// A bounded scenery preflight, not a poker validator. Empty and folded are
/// distinct source states; no person is manufactured to raise PNG coverage.
Act0F7SceneDecisionV1 act0F7SceneCompatibilityV1(
  Act0F7SceneSourceV1 source, {
  Act0SceneProfileV1 profile = act0PremiumTableSceneProfileV1,
}) {
  final fallback = <String>[];
  final unknown = <String>[];
  if (!profile.isValid) fallback.add('profile:invalid_registration');
  if (source.scenarioKey.trim().isEmpty) unknown.add('source:missing_scenario');
  if (source.tables.isEmpty) unknown.add('source:missing_tables');
  for (final entry in source.tables.entries) {
    final t = entry.value;
    final variant = entry.key;
    void missing(String reason) => unknown.add('$variant:$reason');
    void unsupported(String reason) => fallback.add('$variant:$reason');
    if (t.scope == Act0TableScopeV1.unclassified) {
      missing('unclassified_source');
    }
    if (t.tableFormat != Act0TableFormatV1.sixMax ||
        t.playerCount != 6 ||
        t.seats.length != 6) {
      unsupported('requires_six_seats');
      continue;
    }
    if (t.seats.map((s) => s.seatId).toSet().length != 6 ||
        t.seats.map((s) => s.seatLabel.toUpperCase()).toSet().length != 6 ||
        !t.seats
            .map((s) => s.seatLabel.toUpperCase())
            .toSet()
            .containsAll(t.canonicalSeatOrder)) {
      missing('ambiguous_seat_identity');
      continue;
    }
    final heroes = t.seats.where((s) => s.isHero).toList();
    if (heroes.length != 1 ||
        (t.heroSeatId != null && t.heroSeatId != heroes.single.seatId)) {
      missing('ambiguous_hero');
    }
    for (final seat in t.seats) {
      if (!seat.isOccupied && !profile.supportsEmptySeats) {
        unsupported('empty_seat/${seat.seatId}');
      }
      if ((seat.isFolded || !seat.isInHand) &&
          !profile.supportsFoldedSeatedPlayers) {
        unsupported('unsupported_fold/${seat.seatId}');
      }
      if (seat.holeCards.length > 2) missing('hole_card_count/${seat.seatId}');
    }
    if (t.heroCards.length > 2) missing('hero_card_count');
    const streetCounts = {'Preflop': 0, 'Flop': 3, 'Turn': 4, 'River': 5};
    if (t.scope == Act0TableScopeV1.playedHand &&
        streetCounts[t.streetLabel] != t.boardCards.length) {
      missing('street_board_context');
    } else if (!const [0, 3, 4, 5].contains(t.boardCards.length)) {
      missing('board_card_count');
    }
    // The current source explicitly uses '' for no actor (orientation and
    // completed showdown). Match the Runner's trimmed optional-ID semantics.
    final active = t.activeSeatId?.trim() ?? '';
    if (active.isNotEmpty) {
      final actors = t.seats.where((s) => s.seatId == active).toList();
      if (actors.length != 1 ||
          !actors.single.isOccupied ||
          actors.single.isFolded ||
          !actors.single.isInHand) {
        missing('actor_context/$active');
      }
    }
  }
  // A known empty seat takes precedence over unrelated incomplete context so
  // the baked-person incompatibility is always visible in the report.
  return Act0F7SceneDecisionV1(
    fallback.isNotEmpty
        ? Act0F7SceneDispositionV1.proceduralFallbackRequired
        : unknown.isNotEmpty
        ? Act0F7SceneDispositionV1.sourceContextInsufficient
        : Act0F7SceneDispositionV1.pngSuitable,
    [...fallback, ...unknown],
  );
}
