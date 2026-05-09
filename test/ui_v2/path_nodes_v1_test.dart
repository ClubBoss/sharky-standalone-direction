import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/map/path_nodes_v1.dart';

void main() {
  group('buildPathNodesV1', () {
    const packs = <String>[
      'world1_spine_campaign_v1',
      'world2_spine_campaign_v1',
      'world3_spine_campaign_v1',
    ];

    test('returns pack-only nodes when no review and no checkpoint', () {
      final nodes = buildPathNodesV1(
        packIds: packs,
        nextPackId: 'world1_spine_campaign_v1',
        completedPacksCount: 0,
        hasReviewQueueForNextPack: false,
      );

      expect(nodes.map((n) => n.kind).toList(), <PathNodeKindV1>[
        PathNodeKindV1.pack,
        PathNodeKindV1.pack,
        PathNodeKindV1.pack,
      ]);
      expect(nodes[1].packId, 'world2_spine_campaign_v1');
    });

    test(
      'inserts optional world1 streets drill after world1 once completed',
      () {
        final nodes = buildPathNodesV1(
          packIds: packs,
          nextPackId: 'world2_spine_campaign_v1',
          completedPacksCount: 1,
          hasReviewQueueForNextPack: false,
        );

        expect(nodes.map((n) => n.kind).toList(), <PathNodeKindV1>[
          PathNodeKindV1.pack,
          PathNodeKindV1.optionalPack,
          PathNodeKindV1.pack,
          PathNodeKindV1.pack,
        ]);
        expect(nodes[0].packId, 'world1_spine_campaign_v1');
        expect(nodes[1].packId, 'world1_streets_demo_v1');
        expect(nodes[1].reason, 'Streets Drill');
        expect(nodes[2].packId, 'world2_spine_campaign_v1');
      },
    );

    test(
      'does not insert streets drill before any spine pack is completed',
      () {
        final nodes = buildPathNodesV1(
          packIds: packs,
          nextPackId: 'world1_spine_campaign_v1',
          completedPacksCount: 0,
          hasReviewQueueForNextPack: false,
        );

        expect(
          nodes.any((n) => n.kind == PathNodeKindV1.optionalPack),
          isFalse,
        );
      },
    );

    test('inserts review before next pack when queue exists', () {
      final nodes = buildPathNodesV1(
        packIds: const <String>[
          'world1_spine_campaign_v1',
          'world2_spine_campaign_v1',
          'world2_spine_followup_v1_b2',
          'world3_spine_campaign_v1',
        ],
        nextPackId: 'world3_spine_campaign_v1',
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );

      expect(nodes.map((n) => n.kind).toList(), <PathNodeKindV1>[
        PathNodeKindV1.pack,
        PathNodeKindV1.optionalPack,
        PathNodeKindV1.pack,
        PathNodeKindV1.pack,
        PathNodeKindV1.optionalPack,
        PathNodeKindV1.review,
        PathNodeKindV1.checkpoint,
        PathNodeKindV1.pack,
        PathNodeKindV1.optionalPack,
        ]);
      expect(nodes[1].packId, 'world1_streets_demo_v1');
      expect(nodes[2].packId, 'world2_spine_campaign_v1');
      expect(nodes[3].packId, 'world2_spine_followup_v1_b2');
      expect(nodes[4].packId, 'world2_streets_demo_v1');
      expect(nodes[4].reason, 'Streets Challenge');
      expect(nodes[5].reason, 'Review required');
      expect(nodes[6].reason, 'Checkpoint');
      expect(nodes[7].packId, 'world3_spine_campaign_v1');
      expect(nodes[8].packId, 'world3_streets_demo_v1');
      expect(nodes[8].reason, 'Streets Challenge');
    });

    test('inserts review and checkpoint at rhythm boundary', () {
      final nodes = buildPathNodesV1(
        packIds: const <String>['w1', 'w2', 'w3', 'w4'],
        nextPackId: 'w4',
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );

      expect(nodes.map((n) => n.kind).toList(), <PathNodeKindV1>[
        PathNodeKindV1.pack,
        PathNodeKindV1.pack,
        PathNodeKindV1.pack,
        PathNodeKindV1.review,
        PathNodeKindV1.checkpoint,
        PathNodeKindV1.pack,
      ]);
      expect(nodes[3].reason, 'Review required');
      expect(nodes[4].reason, 'Checkpoint');
      expect(nodes[5].packId, 'w4');
    });

    test(
      'inserts checkpoint without review when boundary hit and no queue',
      () {
        final nodes = buildPathNodesV1(
          packIds: const <String>['w1', 'w2', 'w3', 'w4'],
          nextPackId: 'w4',
          completedPacksCount: 3,
          hasReviewQueueForNextPack: false,
        );

        expect(nodes.map((n) => n.kind).toList(), <PathNodeKindV1>[
          PathNodeKindV1.pack,
          PathNodeKindV1.pack,
          PathNodeKindV1.pack,
          PathNodeKindV1.checkpoint,
          PathNodeKindV1.pack,
        ]);
      },
    );

    test('returns unchanged nodes when nextPackId is missing', () {
      final nodes = buildPathNodesV1(
        packIds: packs,
        nextPackId: 'missing_pack',
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );

      expect(nodes.length, 3);
      expect(nodes.every((n) => n.kind == PathNodeKindV1.pack), isTrue);
    });

    test('is deterministic for same inputs', () {
      final a = buildPathNodesV1(
        packIds: const <String>['w1', 'w2', 'w3', 'w4'],
        nextPackId: 'w4',
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );
      final b = buildPathNodesV1(
        packIds: const <String>['w1', 'w2', 'w3', 'w4'],
        nextPackId: 'w4',
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );

      expect(
        a.map((n) => '${n.kind.name}:${n.packId ?? ''}:${n.reason ?? ''}'),
        b.map((n) => '${n.kind.name}:${n.packId ?? ''}:${n.reason ?? ''}'),
      );
    });

    test('special nodes insert before next pack in stable order', () {
      final nodes = buildPathNodesV1(
        packIds: const <String>['w1', 'w2', 'w3', 'w4'],
        nextPackId: 'w4',
        completedPacksCount: 3,
        hasReviewQueueForNextPack: true,
      );

      final nextPackIndex = nodes.indexWhere(
        (node) => node.kind == PathNodeKindV1.pack && node.packId == 'w4',
      );
      expect(nextPackIndex, greaterThan(1));
      expect(nodes[nextPackIndex - 2].kind, PathNodeKindV1.review);
      expect(nodes[nextPackIndex - 1].kind, PathNodeKindV1.checkpoint);
      expect(nodes[nextPackIndex - 2].reason, 'Review required');
      expect(nodes[nextPackIndex - 1].reason, 'Checkpoint');
    });

    test(
      'optional streets drill coexists with review/checkpoint insertions',
      () {
        final nodes = buildPathNodesV1(
          packIds: const <String>[
            'world1_spine_campaign_v1',
            'world2_spine_campaign_v1',
            'world2_spine_followup_v1_b1',
            'world3_spine_campaign_v1',
            'world4_spine_campaign_v1',
          ],
          nextPackId: 'world4_spine_campaign_v1',
          completedPacksCount: 3,
          hasReviewQueueForNextPack: true,
        );

        final optionalIndex = nodes.indexWhere(
          (n) =>
              n.kind == PathNodeKindV1.optionalPack &&
              n.packId == 'world1_streets_demo_v1',
        );
        final optionalWorld2Index = nodes.indexWhere(
          (n) =>
              n.kind == PathNodeKindV1.optionalPack &&
              n.packId == 'world2_streets_demo_v1',
        );
        final optionalWorld3Index = nodes.indexWhere(
          (n) =>
              n.kind == PathNodeKindV1.optionalPack &&
              n.packId == 'world3_streets_demo_v1',
        );
        final reviewIndex = nodes.indexWhere(
          (n) => n.kind == PathNodeKindV1.review,
        );
        final checkpointIndex = nodes.indexWhere(
          (n) => n.kind == PathNodeKindV1.checkpoint,
        );
        final nextPackIndex = nodes.indexWhere(
          (n) =>
              n.kind == PathNodeKindV1.pack &&
              n.packId == 'world4_spine_campaign_v1',
        );

        expect(optionalIndex, 1);
        expect(optionalWorld2Index, greaterThan(optionalIndex));
        final world2FollowupIndex = nodes.indexWhere(
          (n) =>
              n.kind == PathNodeKindV1.pack &&
              n.packId == 'world2_spine_followup_v1_b1',
        );
        expect(optionalWorld2Index, world2FollowupIndex + 1);
        expect(optionalWorld3Index, greaterThan(optionalWorld2Index));
        expect(reviewIndex, greaterThan(optionalWorld3Index));
        expect(checkpointIndex, reviewIndex + 1);
        expect(nextPackIndex, checkpointIndex + 1);
      },
    );

    test(
      'does not insert world2 streets challenge before world2 followup anchor exists',
      () {
        final nodes = buildPathNodesV1(
          packIds: const <String>[
            'world1_spine_campaign_v1',
            'world2_spine_campaign_v1',
            'world3_spine_campaign_v1',
          ],
          nextPackId: 'world3_spine_campaign_v1',
          completedPacksCount: 3,
          hasReviewQueueForNextPack: false,
        );

        expect(
          nodes.any((n) => n.packId == 'world2_streets_demo_v1'),
          isFalse,
        );
      },
    );
  });
}
