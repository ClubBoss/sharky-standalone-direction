import 'package:flutter/foundation.dart';

enum CanonicalTableTopologyProfileIdV1 {
  headsUp2Max,
  shortHanded6Max,
  fullRing9Max,
  fullRing10Max,
  transitionalDerived,
  transitionalSevenMax,
  transitionalEightMax,
}

enum CanonicalTableTopologyMarkerCapabilityV1 {
  dealerPuck,
  blindMarkers,
  seatIdMarkers,
  roleBadges,
  forcedBetOverlays,
  utgPlusOneLabel,
  middlePositionLabels,
  fullRingPositionMarkers,
}

enum CanonicalTableTopologyReadinessBoundaryV1 {
  topologyProfileOwnedByCanonicalShell,
  playerCountRequired,
  seatCoordinatesOwnedByCanonicalShell,
  markerCompositionOwnedByCanonicalShell,
  nineAndTenMaxReady,
  tournamentAntesNotYetLive,
  transitionalCountsStayDerived,
}

enum CanonicalTableTopologySupportSliceV1 {
  topologyContractOnly,
  twoAndSixMaxFormalization,
  nineAndTenMaxSeatLayoutEntry,
  tournamentBlindAndAnteReadiness,
  fullRingDealerBlindPositionSemantics,
}

@immutable
class CanonicalTableTopologyProfileV1 {
  const CanonicalTableTopologyProfileV1({
    required this.id,
    required this.label,
    required this.supportedSeatCounts,
    required this.slotFillOrder,
    required this.markerCapabilities,
    required this.compactnessResponsibility,
  });

  final CanonicalTableTopologyProfileIdV1 id;
  final String label;
  final List<int> supportedSeatCounts;
  final List<int> slotFillOrder;
  final List<CanonicalTableTopologyMarkerCapabilityV1> markerCapabilities;
  final String compactnessResponsibility;

  bool supportsSeatCount(int seatCount) {
    return supportedSeatCounts.contains(seatCount);
  }
}

@immutable
class CanonicalTableTopologyContractV1 {
  const CanonicalTableTopologyContractV1({
    required this.id,
    required this.label,
    required this.topologyProfileOwnership,
    required this.playerCountInputSemantics,
    required this.seatCoordinateResponsibility,
    required this.markerResponsibility,
    required this.compactnessReadabilityConstraint,
    required this.readinessBoundaries,
    required this.profiles,
  });

  final String id;
  final String label;
  final String topologyProfileOwnership;
  final String playerCountInputSemantics;
  final String seatCoordinateResponsibility;
  final String markerResponsibility;
  final String compactnessReadabilityConstraint;
  final List<CanonicalTableTopologyReadinessBoundaryV1> readinessBoundaries;
  final List<CanonicalTableTopologyProfileV1> profiles;
}

@immutable
class CanonicalTableTopologyRecommendationV1 {
  const CanonicalTableTopologyRecommendationV1({
    required this.slice,
    required this.label,
    required this.whyItWins,
    required this.safeForPhaseEntryImplementation,
    required this.exactNextStep,
  });

  final CanonicalTableTopologySupportSliceV1 slice;
  final String label;
  final String whyItWins;
  final bool safeForPhaseEntryImplementation;
  final String exactNextStep;
}

const int kCanonicalTableHeroTopologySlotIdV1 = 0;
const List<int> kCanonicalTableFullRingSlotFillOrderV1 = <int>[
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
];

const CanonicalTableTopologyProfileV1
kCanonicalTableHeadsUp2MaxProfileV1 = CanonicalTableTopologyProfileV1(
  id: CanonicalTableTopologyProfileIdV1.headsUp2Max,
  label: 'Heads-up 2-max topology',
  supportedSeatCounts: <int>[2],
  slotFillOrder: <int>[0, 1],
  markerCapabilities: <CanonicalTableTopologyMarkerCapabilityV1>[
    CanonicalTableTopologyMarkerCapabilityV1.dealerPuck,
    CanonicalTableTopologyMarkerCapabilityV1.blindMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.roleBadges,
    CanonicalTableTopologyMarkerCapabilityV1.forcedBetOverlays,
  ],
  compactnessResponsibility:
      'Two-seat layouts preserve strong vertical separation and do not introduce extra shoulder anchors.',
);

const CanonicalTableTopologyProfileV1
kCanonicalTableShortHanded6MaxProfileV1 = CanonicalTableTopologyProfileV1(
  id: CanonicalTableTopologyProfileIdV1.shortHanded6Max,
  label: 'Short-handed 6-max topology',
  supportedSeatCounts: <int>[6],
  slotFillOrder: <int>[0, 5, 3, 1, 2, 4],
  markerCapabilities: <CanonicalTableTopologyMarkerCapabilityV1>[
    CanonicalTableTopologyMarkerCapabilityV1.dealerPuck,
    CanonicalTableTopologyMarkerCapabilityV1.blindMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.roleBadges,
    CanonicalTableTopologyMarkerCapabilityV1.forcedBetOverlays,
  ],
  compactnessResponsibility:
      'Six-max layouts keep BTN/SB/BB plus UTG/HJ/CO readable on a hero-anchored clockwise orbit without shoulder overflow.',
);

const CanonicalTableTopologyProfileV1
kCanonicalTableFullRing9MaxProfileV1 = CanonicalTableTopologyProfileV1(
  id: CanonicalTableTopologyProfileIdV1.fullRing9Max,
  label: 'Full-ring 9-max topology',
  supportedSeatCounts: <int>[9],
  slotFillOrder: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8],
  markerCapabilities: <CanonicalTableTopologyMarkerCapabilityV1>[
    CanonicalTableTopologyMarkerCapabilityV1.dealerPuck,
    CanonicalTableTopologyMarkerCapabilityV1.blindMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.seatIdMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.roleBadges,
    CanonicalTableTopologyMarkerCapabilityV1.forcedBetOverlays,
    CanonicalTableTopologyMarkerCapabilityV1.utgPlusOneLabel,
    CanonicalTableTopologyMarkerCapabilityV1.fullRingPositionMarkers,
  ],
  compactnessResponsibility:
      'Nine-max layouts must preserve UTG+1 readability while avoiding lower-shoulder label collisions.',
);

const CanonicalTableTopologyProfileV1
kCanonicalTableFullRing10MaxProfileV1 = CanonicalTableTopologyProfileV1(
  id: CanonicalTableTopologyProfileIdV1.fullRing10Max,
  label: 'Full-ring 10-max topology',
  supportedSeatCounts: <int>[10],
  slotFillOrder: kCanonicalTableFullRingSlotFillOrderV1,
  markerCapabilities: <CanonicalTableTopologyMarkerCapabilityV1>[
    CanonicalTableTopologyMarkerCapabilityV1.dealerPuck,
    CanonicalTableTopologyMarkerCapabilityV1.blindMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.seatIdMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.roleBadges,
    CanonicalTableTopologyMarkerCapabilityV1.forcedBetOverlays,
    CanonicalTableTopologyMarkerCapabilityV1.utgPlusOneLabel,
    CanonicalTableTopologyMarkerCapabilityV1.middlePositionLabels,
    CanonicalTableTopologyMarkerCapabilityV1.fullRingPositionMarkers,
  ],
  compactnessResponsibility:
      'Ten-max layouts may use the extra middle-position anchor, but the canonical shell still owns collision avoidance and marker stacking.',
);

const CanonicalTableTopologyProfileV1
kCanonicalTableTransitionalDerivedProfileV1 = CanonicalTableTopologyProfileV1(
  id: CanonicalTableTopologyProfileIdV1.transitionalDerived,
  label: 'Derived transitional topology',
  supportedSeatCounts: <int>[3, 4, 5],
  slotFillOrder: kCanonicalTableFullRingSlotFillOrderV1,
  markerCapabilities: <CanonicalTableTopologyMarkerCapabilityV1>[
    CanonicalTableTopologyMarkerCapabilityV1.dealerPuck,
    CanonicalTableTopologyMarkerCapabilityV1.blindMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.roleBadges,
    CanonicalTableTopologyMarkerCapabilityV1.forcedBetOverlays,
  ],
  compactnessResponsibility:
      'Transitional counts stay derived from the canonical full-ring slot order until dedicated profile tuning is admitted.',
);

const CanonicalTableTopologyProfileV1
kCanonicalTableTransitionalSevenMaxProfileV1 = CanonicalTableTopologyProfileV1(
  id: CanonicalTableTopologyProfileIdV1.transitionalSevenMax,
  label: 'Transitional 7-max topology',
  supportedSeatCounts: <int>[7],
  slotFillOrder: kCanonicalTableFullRingSlotFillOrderV1,
  markerCapabilities: <CanonicalTableTopologyMarkerCapabilityV1>[
    CanonicalTableTopologyMarkerCapabilityV1.dealerPuck,
    CanonicalTableTopologyMarkerCapabilityV1.blindMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.roleBadges,
    CanonicalTableTopologyMarkerCapabilityV1.forcedBetOverlays,
    CanonicalTableTopologyMarkerCapabilityV1.fullRingPositionMarkers,
  ],
  compactnessResponsibility:
      'Seven-max layouts preserve BTN/CO/HJ/LJ/UTG plus blind readability on the canonical full-ring slot order without introducing extra shoulder labels.',
);

const CanonicalTableTopologyProfileV1
kCanonicalTableTransitionalEightMaxProfileV1 = CanonicalTableTopologyProfileV1(
  id: CanonicalTableTopologyProfileIdV1.transitionalEightMax,
  label: 'Transitional 8-max topology',
  supportedSeatCounts: <int>[8],
  slotFillOrder: kCanonicalTableFullRingSlotFillOrderV1,
  markerCapabilities: <CanonicalTableTopologyMarkerCapabilityV1>[
    CanonicalTableTopologyMarkerCapabilityV1.dealerPuck,
    CanonicalTableTopologyMarkerCapabilityV1.blindMarkers,
    CanonicalTableTopologyMarkerCapabilityV1.roleBadges,
    CanonicalTableTopologyMarkerCapabilityV1.forcedBetOverlays,
    CanonicalTableTopologyMarkerCapabilityV1.utgPlusOneLabel,
    CanonicalTableTopologyMarkerCapabilityV1.fullRingPositionMarkers,
  ],
  compactnessResponsibility:
      'Eight-max layouts preserve full-ring label semantics through UTG+1 while remaining on the canonical full-ring slot order.',
);

const String kCanonicalTableTopologyContractIdV1 =
    'canonicalTableTopologyExpansionV1';

const CanonicalTableTopologyContractV1
kCanonicalTableTopologyContractV1 = CanonicalTableTopologyContractV1(
  id: kCanonicalTableTopologyContractIdV1,
  label: 'Canonical table topology and player-count expansion contract',
  topologyProfileOwnership:
      'The unified canonical table shell owns topology profiles, slot fill order, and readiness gating for supported player counts.',
  playerCountInputSemantics:
      'Player count is an explicit scenario input. Hosts pass seat count only; they do not synthesize topology-specific seat coordinates.',
  seatCoordinateResponsibility:
      'Seat coordinates and profile slot order belong to the canonical shell. Family-specific screens must not fork bespoke seat maps.',
  markerResponsibility:
      'Dealer, blind, seat-id, position, and future ante markers are composed by the canonical shell from normalized topology state.',
  compactnessReadabilityConstraint:
      'Expanded topologies must preserve marker legibility and avoid shoulder-collision overload before any visual-polish phase.',
  readinessBoundaries: <CanonicalTableTopologyReadinessBoundaryV1>[
    CanonicalTableTopologyReadinessBoundaryV1
        .topologyProfileOwnedByCanonicalShell,
    CanonicalTableTopologyReadinessBoundaryV1.playerCountRequired,
    CanonicalTableTopologyReadinessBoundaryV1
        .seatCoordinatesOwnedByCanonicalShell,
    CanonicalTableTopologyReadinessBoundaryV1
        .markerCompositionOwnedByCanonicalShell,
    CanonicalTableTopologyReadinessBoundaryV1.nineAndTenMaxReady,
    CanonicalTableTopologyReadinessBoundaryV1.tournamentAntesNotYetLive,
    CanonicalTableTopologyReadinessBoundaryV1.transitionalCountsStayDerived,
  ],
  profiles: <CanonicalTableTopologyProfileV1>[
    kCanonicalTableHeadsUp2MaxProfileV1,
    kCanonicalTableShortHanded6MaxProfileV1,
    kCanonicalTableFullRing9MaxProfileV1,
    kCanonicalTableFullRing10MaxProfileV1,
    kCanonicalTableTransitionalDerivedProfileV1,
    kCanonicalTableTransitionalSevenMaxProfileV1,
    kCanonicalTableTransitionalEightMaxProfileV1,
  ],
);

const CanonicalTableTopologyRecommendationV1
kCanonicalTableFirstTopologyRecommendationV1 = CanonicalTableTopologyRecommendationV1(
  slice: CanonicalTableTopologySupportSliceV1.nineAndTenMaxSeatLayoutEntry,
  label: '9/10-max seat layout support entry',
  whyItWins:
      'The canonical shell already carries explicit 10-seat anchors and World 9 seat-id semantics, so 9/10-max formalization offers the most leverage with the least behavioral churn.',
  safeForPhaseEntryImplementation: true,
  exactNextStep:
      'Formalize 9/10-max topology profiles as SSOT and route canonical table seat-slot selection through them while keeping transitional counts derived.',
);

const CanonicalTableTopologyRecommendationV1
kCanonicalTableNextTopologySemanticsRecommendationV1 =
    CanonicalTableTopologyRecommendationV1(
      slice: CanonicalTableTopologySupportSliceV1
          .fullRingDealerBlindPositionSemantics,
      label: 'Full-ring dealer/blind/position semantics',
      whyItWins:
          'The canonical shell already renders seat markers, blind overlays, and seat-id labels. Promoting full-ring position labels from authored seat order makes 7-plus handed topology product-meaningful without forcing ante support.',
      safeForPhaseEntryImplementation: true,
      exactNextStep:
          'Promote BTN/SB/BB plus CO/HJ/LJ/UTG/UTG+1/MP labels from authored seat order on 7-plus handed canonical table sessions.',
    );

CanonicalTableTopologyProfileV1 canonicalTableTopologyProfileForSeatCountV1(
  int seatCount,
) {
  for (final profile in kCanonicalTableTopologyContractV1.profiles) {
    if (profile.supportsSeatCount(seatCount)) {
      return profile;
    }
  }
  throw ArgumentError.value(
    seatCount,
    'seatCount',
    'Unsupported canonical table seat count',
  );
}

List<int> canonicalTableSlotIdsForSeatCountV1(
  int seatCount, {
  required int heroSeatIndex,
}) {
  if (seatCount < 2 || seatCount > 10) {
    throw ArgumentError.value(
      seatCount,
      'seatCount',
      'Canonical table supports seat counts from 2 to 10',
    );
  }
  if (heroSeatIndex < 0 || heroSeatIndex >= seatCount) {
    throw ArgumentError.value(
      heroSeatIndex,
      'heroSeatIndex',
      'Hero seat index must fit within the active seat count',
    );
  }
  if (seatCount == 6) {
    final heroRelativeFillOrder =
        kCanonicalTableShortHanded6MaxProfileV1.slotFillOrder;
    return List<int>.unmodifiable(
      List<int>.generate(seatCount, (index) {
        final relativeOffset = (index - heroSeatIndex + seatCount) % seatCount;
        return heroRelativeFillOrder[relativeOffset];
      }, growable: false),
    );
  }
  final profile = canonicalTableTopologyProfileForSeatCountV1(seatCount);
  final remaining = profile.slotFillOrder
      .where((slotId) => slotId != kCanonicalTableHeroTopologySlotIdV1)
      .toList(growable: false);
  final slots = List<int>.filled(
    seatCount,
    kCanonicalTableHeroTopologySlotIdV1,
  );
  var nextRemaining = 0;
  for (var i = 0; i < seatCount; i++) {
    if (i == heroSeatIndex) {
      slots[i] = kCanonicalTableHeroTopologySlotIdV1;
      continue;
    }
    slots[i] = remaining[nextRemaining];
    nextRemaining++;
  }
  return List<int>.unmodifiable(slots);
}

const Map<String, String> _kCanonicalTopologyPositionLabelsV1 =
    <String, String>{
      'btn': 'BTN',
      'sb': 'SB',
      'bb': 'BB',
      'co': 'CO',
      'hj': 'HJ',
      'lj': 'LJ',
      'utg': 'UTG',
      'utg1': 'UTG+1',
      'mp1': 'MP+1',
      'mp': 'MP',
    };

bool canonicalTableUsesFullRingPositionSemanticsV1(List<String> seatOrder) {
  if (seatOrder.length < 7) {
    return false;
  }
  return seatOrder.any(
    (seat) => const <String>{
      'co',
      'hj',
      'lj',
      'utg',
      'utg1',
      'mp1',
      'mp',
    }.contains(seat.trim().toLowerCase()),
  );
}

Map<int, String>? canonicalTableMarkerLabelsForSeatOrderV1({
  required List<String> seatOrder,
  required bool includeSeatIds,
}) {
  final useFullRingLabels = canonicalTableUsesFullRingPositionSemanticsV1(
    seatOrder,
  );
  final labels = <int, String>{};
  for (var i = 0; i < seatOrder.length; i++) {
    final normalizedSeat = seatOrder[i].trim().toLowerCase();
    final positionLabel = _kCanonicalTopologyPositionLabelsV1[normalizedSeat];
    if (positionLabel == null) {
      continue;
    }
    final shouldExposePosition =
        useFullRingLabels ||
        positionLabel == 'BTN' ||
        positionLabel == 'SB' ||
        positionLabel == 'BB';
    if (!shouldExposePosition) {
      continue;
    }
    if (includeSeatIds) {
      labels[i] = 'S${i + 1}/$positionLabel';
    } else {
      labels[i] = positionLabel;
    }
  }
  return labels.isEmpty ? null : labels;
}
