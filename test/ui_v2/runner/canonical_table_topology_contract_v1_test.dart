import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_table_topology_contract_v1.dart';

void main() {
  test('topology contract is explicit and deterministic', () {
    expect(
      kCanonicalTableTopologyContractV1.id,
      'canonicalTableTopologyExpansionV1',
    );
    expect(
      kCanonicalTableTopologyContractV1.readinessBoundaries,
      contains(CanonicalTableTopologyReadinessBoundaryV1.nineAndTenMaxReady),
    );
    expect(
      kCanonicalTableTopologyContractV1.readinessBoundaries,
      contains(
        CanonicalTableTopologyReadinessBoundaryV1.tournamentAntesNotYetLive,
      ),
    );
    expect(
      kCanonicalTableFirstTopologyRecommendationV1.slice,
      CanonicalTableTopologySupportSliceV1.nineAndTenMaxSeatLayoutEntry,
    );
    expect(
      kCanonicalTableFirstTopologyRecommendationV1
          .safeForPhaseEntryImplementation,
      isTrue,
    );
    expect(
      kCanonicalTableNextTopologySemanticsRecommendationV1.slice,
      CanonicalTableTopologySupportSliceV1.fullRingDealerBlindPositionSemantics,
    );
  });

  test('explicit profiles cover 2 6 9 and 10 max counts', () {
    expect(
      canonicalTableTopologyProfileForSeatCountV1(2).id,
      CanonicalTableTopologyProfileIdV1.headsUp2Max,
    );
    expect(
      canonicalTableTopologyProfileForSeatCountV1(6).id,
      CanonicalTableTopologyProfileIdV1.shortHanded6Max,
    );
    expect(
      canonicalTableTopologyProfileForSeatCountV1(9).id,
      CanonicalTableTopologyProfileIdV1.fullRing9Max,
    );
    expect(
      canonicalTableTopologyProfileForSeatCountV1(10).id,
      CanonicalTableTopologyProfileIdV1.fullRing10Max,
    );
  });

  test('7 max now selects its own explicit transitional profile', () {
    final profile = canonicalTableTopologyProfileForSeatCountV1(7);

    expect(profile.id, CanonicalTableTopologyProfileIdV1.transitionalSevenMax);
    expect(profile.supportedSeatCounts, const <int>[7]);
    expect(
      profile.markerCapabilities,
      contains(
        CanonicalTableTopologyMarkerCapabilityV1.fullRingPositionMarkers,
      ),
    );
    expect(
      profile.markerCapabilities,
      isNot(contains(CanonicalTableTopologyMarkerCapabilityV1.utgPlusOneLabel)),
    );
  });

  test('8 max now selects its own explicit transitional profile', () {
    final profile = canonicalTableTopologyProfileForSeatCountV1(8);

    expect(profile.id, CanonicalTableTopologyProfileIdV1.transitionalEightMax);
    expect(profile.supportedSeatCounts, const <int>[8]);
    expect(
      profile.markerCapabilities,
      contains(CanonicalTableTopologyMarkerCapabilityV1.utgPlusOneLabel),
    );
    expect(
      profile.markerCapabilities,
      isNot(
        contains(CanonicalTableTopologyMarkerCapabilityV1.middlePositionLabels),
      ),
    );
  });

  test('remaining transitional counts stay on derived profile', () {
    for (final seatCount in <int>[3, 4, 5]) {
      expect(
        canonicalTableTopologyProfileForSeatCountV1(seatCount).id,
        CanonicalTableTopologyProfileIdV1.transitionalDerived,
      );
    }
  });

  test(
    'slot ids stay stable for 7 max 8 max 9 max and 10 max with hero at seat zero',
    () {
      expect(
        canonicalTableSlotIdsForSeatCountV1(7, heroSeatIndex: 0),
        const <int>[0, 1, 2, 3, 4, 5, 6],
      );
      expect(
        canonicalTableSlotIdsForSeatCountV1(8, heroSeatIndex: 0),
        const <int>[0, 1, 2, 3, 4, 5, 6, 7],
      );
      expect(
        canonicalTableSlotIdsForSeatCountV1(9, heroSeatIndex: 0),
        const <int>[0, 1, 2, 3, 4, 5, 6, 7, 8],
      );
      expect(
        canonicalTableSlotIdsForSeatCountV1(10, heroSeatIndex: 0),
        const <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      );
    },
  );

  test('slot ids keep hero anchored when hero seat shifts', () {
    expect(
      canonicalTableSlotIdsForSeatCountV1(7, heroSeatIndex: 4),
      const <int>[1, 2, 3, 4, 0, 5, 6],
    );
    expect(
      canonicalTableSlotIdsForSeatCountV1(8, heroSeatIndex: 5),
      const <int>[1, 2, 3, 4, 5, 0, 6, 7],
    );
    expect(
      canonicalTableSlotIdsForSeatCountV1(6, heroSeatIndex: 3),
      const <int>[1, 2, 4, 0, 5, 3],
    );
    expect(
      canonicalTableSlotIdsForSeatCountV1(9, heroSeatIndex: 5),
      const <int>[1, 2, 3, 4, 5, 0, 6, 7, 8],
    );
    expect(
      canonicalTableSlotIdsForSeatCountV1(10, heroSeatIndex: 5),
      const <int>[1, 2, 3, 4, 5, 0, 6, 7, 8, 9],
    );
  });

  test(
    '6-max slot ids keep the learner-facing orbit contiguous for off-button heroes',
    () {
      expect(
        canonicalTableSlotIdsForSeatCountV1(6, heroSeatIndex: 2),
        const <int>[2, 4, 0, 5, 3, 1],
      );
      expect(
        canonicalTableSlotIdsForSeatCountV1(6, heroSeatIndex: 0),
        const <int>[0, 5, 3, 1, 2, 4],
      );
    },
  );

  test(
    'full-ring semantics promote rich position labels while short-handed stays compact',
    () {
      expect(
        canonicalTableUsesFullRingPositionSemanticsV1(const <String>[
          'btn',
          'co',
          'hj',
          'lj',
          'utg',
          'sb',
          'bb',
        ]),
        isTrue,
      );
      expect(
        canonicalTableMarkerLabelsForSeatOrderV1(
          seatOrder: const <String>['btn', 'co', 'hj', 'lj', 'utg', 'sb', 'bb'],
          includeSeatIds: true,
        ),
        const <int, String>{
          0: 'S1/BTN',
          1: 'S2/CO',
          2: 'S3/HJ',
          3: 'S4/LJ',
          4: 'S5/UTG',
          5: 'S6/SB',
          6: 'S7/BB',
        },
      );
      expect(
        canonicalTableMarkerLabelsForSeatOrderV1(
          seatOrder: const <String>[
            'btn',
            'co',
            'hj',
            'lj',
            'utg',
            'utg1',
            'mp1',
            'mp',
            'sb',
            'bb',
          ],
          includeSeatIds: true,
        ),
        const <int, String>{
          0: 'S1/BTN',
          1: 'S2/CO',
          2: 'S3/HJ',
          3: 'S4/LJ',
          4: 'S5/UTG',
          5: 'S6/UTG+1',
          6: 'S7/MP+1',
          7: 'S8/MP',
          8: 'S9/SB',
          9: 'S10/BB',
        },
      );
      expect(
        canonicalTableMarkerLabelsForSeatOrderV1(
          seatOrder: const <String>['btn', 'co', 'hj', 'sb', 'bb', 'utg'],
          includeSeatIds: false,
        ),
        const <int, String>{0: 'BTN', 3: 'SB', 4: 'BB'},
      );
    },
  );
}
