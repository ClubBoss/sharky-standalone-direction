import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';

void main() {
  test('canonical truth map v1 keeps world1 production order', () {
    final world1 = canonicalTruthWorldEntriesV1().firstWhere(
      (entry) => entry.world == 1,
    );

    expect(world1.entryPackId, kWorld1CanonicalModuleOrder.first);
    expect(
      world1.nodes.map((node) => node.packId).toList(growable: false),
      equals(kWorld1CanonicalModuleOrder),
    );
    expect(
      world1.nodes.first.status,
      CanonicalTruthStatusV1.productionLiveModernized,
    );
    expect(
      world1.nodes[1].status,
      CanonicalTruthStatusV1.productionLiveModernized,
    );
    expect(
      world1.nodes
          .skip(3)
          .every(
            (node) => node.status == CanonicalTruthStatusV1.productionLive,
          ),
      isTrue,
    );
    expect(
      world1.nodes[2].status,
      CanonicalTruthStatusV1.productionLiveModernized,
    );
    expect(
      world1.nodes.every(
        (node) =>
            node.skeletonReadiness ==
            CanonicalTruthSkeletonReadinessV1.representedReady,
      ),
      isTrue,
    );
  });

  test(
    'canonical truth map v1 stays anchored to production campaign packs',
    () {
      final nodeByPackId = canonicalTruthNodeByPackIdV1();

      expect(
        nodeByPackId.keys.toSet(),
        equals(ProgressService.campaignPackIdsV1.toSet()),
      );
      expect(
        nodeByPackId['world2_spine_campaign_v1']?.status,
        CanonicalTruthStatusV1.pilotLive,
      );
      expect(
        nodeByPackId['world2_spine_campaign_v1']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world2_spine_campaign_v1']?.skeletonReadiness,
        CanonicalTruthSkeletonReadinessV1.representedReady,
      );
      expect(
        nodeByPackId['world2_spine_followup_v1_b2']?.status,
        CanonicalTruthStatusV1.pilotLive,
      );
      expect(
        nodeByPackId['world2_spine_followup_v1_b2']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world3_spine_campaign_v1']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world6_spine_followup_v1_b1']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world9_spine_followup_v1_b2']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world1_act0_table_literacy']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world1_spine_campaign_v1']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world10_spine_campaign_v1']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world10_spine_followup_v1_b0']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world10_spine_followup_v1_b2']?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId[ProgressService.w7W10LearnerRouteGateTerminalPackIdV1]
            ?.world,
        12,
      );
      expect(
        nodeByPackId[ProgressService.w7W10LearnerRouteGateTerminalPackIdV1]
            ?.hostSurface,
        CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      );
      expect(
        nodeByPackId['world2_spine_followup_v1_b2']?.skeletonReadiness,
        CanonicalTruthSkeletonReadinessV1.representedReady,
      );
      expect(
        nodeByPackId['world1_act0_table_literacy']?.modeFamily,
        CanonicalTruthModeFamilyV1.seatQuiz,
      );
      expect(
        nodeByPackId['world1_act0_table_literacy']?.status,
        CanonicalTruthStatusV1.productionLiveModernized,
      );
      expect(
        nodeByPackId['world1_act0_action_literacy']?.status,
        CanonicalTruthStatusV1.productionLiveModernized,
      );
      expect(
        nodeByPackId['world1_act0_street_flow']?.status,
        CanonicalTruthStatusV1.productionLiveModernized,
      );
      expect(
        nodeByPackId['world1_spine_campaign_v1']?.modeFamily,
        CanonicalTruthModeFamilyV1.campaignSpine,
      );
    },
  );

  test('canonical truth map v1 keeps contiguous world-local order indexes', () {
    final worlds = canonicalTruthWorldEntriesV1();

    for (final world in worlds) {
      expect(world.nodes, isNotEmpty, reason: 'World ${world.world} is empty.');
      expect(world.entryPackId, world.nodes.first.packId);
      expect(
        world.nodes.map((node) => node.orderIndex).toList(growable: false),
        equals(
          List<int>.generate(
            world.nodes.length,
            (index) => index,
            growable: false,
          ),
        ),
        reason: 'World ${world.world} order indexes drifted.',
      );
    }
  });

  test('canonical truth map v1 keeps world2 spine as the entry pack', () {
    final world2 = canonicalTruthWorldEntriesV1().firstWhere(
      (entry) => entry.world == 2,
    );

    expect(world2.entryPackId, 'world2_spine_campaign_v1');
    expect(world2.nodes.first.packId, 'world2_spine_campaign_v1');
  });

  test('canonical truth map v1 exposes stable ordered world2 pack ids', () {
    final world2PackIds = canonicalTruthCampaignPackOrderForWorldV1(2);

    expect(world2PackIds, isNotEmpty);
    expect(world2PackIds.first, 'world2_spine_campaign_v1');
    expect(
      world2PackIds.toSet(),
      equals(
        ProgressService.campaignPackIdsV1
            .where((id) => id.startsWith('world2_'))
            .toSet(),
      ),
    );
  });

  test('canonical truth map v1 keeps pack ids unique within each world', () {
    final worlds = canonicalTruthWorldEntriesV1();

    for (final world in worlds) {
      final packIds = world.nodes
          .map((node) => node.packId)
          .toList(growable: false);
      expect(
        packIds.toSet().length,
        packIds.length,
        reason: 'World ${world.world} contains duplicate pack ids.',
      );
    }
  });

  test('canonical truth map v1 resolves world10 followups to track roots', () {
    expect(
      canonicalTruthWorld10TrackRootSessionIdForCampaignPackV1(
        'world10_spine_followup_v1_b0',
      ),
      'cash.s01',
    );
    expect(
      canonicalTruthWorld10TrackRootSessionIdForCampaignPackV1(
        'world10_spine_followup_v1_b1',
      ),
      'tournament.s01',
    );
    expect(
      canonicalTruthWorld10TrackRootSessionIdForCampaignPackV1(
        'world10_spine_followup_v1_b2',
      ),
      'mixed.s01',
    );
    expect(
      canonicalTruthWorld10TrackRootSessionIdForCampaignPackV1(
        'world10_spine_campaign_v1',
      ),
      isNull,
    );
  });

  test(
    'canonical truth map v1 clears world10 spine campaign intentional runner exception',
    () {
      expect(
        canonicalTruthCampaignPackIsIntentionalRunnerExceptionV1(
          'world10_spine_campaign_v1',
        ),
        isFalse,
      );
      expect(
        canonicalTruthCampaignPackIsIntentionalRunnerExceptionV1(
          'world10_spine_followup_v1_b0',
        ),
        isFalse,
      );
    },
  );

  test('canonical truth map v1 keeps basic node completeness', () {
    for (final world in canonicalTruthWorldEntriesV1()) {
      for (final node in world.nodes) {
        expect(node.packId, isNotEmpty);
        expect(node.moduleId, node.packId);
        expect(node.world, world.world);
        expect(node.handCount, greaterThanOrEqualTo(0));
        expect(node.hostSurface, isNotNull);
        expect(node.modeFamily, isNotNull);
        expect(node.status, isNotNull);
        expect(node.skeletonReadiness, isNotNull);
      }
    }
  });

  test('canonical truth map v1 marks W2-W9 sessions as one cohesion spine', () {
    expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w2.s01'), isTrue);
    expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w2.s14'), isTrue);
    expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w3.s01'), isTrue);
    expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w3.s14'), isTrue);
    expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w4.s01'), isTrue);
    expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w9.s10'), isTrue);
    expect(
      canonicalTruthUsesSessionWorldCohesionSpineV1('world2_spine_campaign_v1'),
      isFalse,
    );
  });

  test(
    'canonical truth map v1 formalizes session-world cohesion for worlds 4-9',
    () {
      expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w4.s01'), isTrue);
      expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w6.s05'), isTrue);
      expect(canonicalTruthUsesSessionWorldCohesionSpineV1('w9.s10'), isTrue);
      expect(
        canonicalTruthUsesSessionWorldCohesionSpineV1(
          'world4_spine_campaign_v1',
        ),
        isFalse,
      );
      expect(
        canonicalTruthUsesSessionWorldCohesionSpineV1('cash.s01'),
        isFalse,
      );
    },
  );

  test('canonical truth map v1 locks learner-facing world identity', () {
    final identities = canonicalTruthWorldIdentityEntriesV1();
    expect(identities.map((entry) => entry.world).toList(), <int>[
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
    ]);

    expect(identities.map((entry) => entry.worldId).toSet().length, 12);
    expect(
      identities.map((entry) => entry.telemetryWorldId).toSet().length,
      12,
    );
    expect(identities.map((entry) => entry.learnerMeaning).toSet().length, 12);

    final byWorld = <int, CanonicalTruthWorldIdentityV1>{
      for (final entry in identities) entry.world: entry,
    };
    expect(byWorld[1]!.learnerMeaning, 'Poker from Zero');
    expect(byWorld[2]!.learnerMeaning, 'Hand Discipline');
    expect(byWorld[3]!.learnerMeaning, 'Position Thinking');
    expect(byWorld[4]!.learnerMeaning, 'Bet Purpose / Price');
    expect(byWorld[5]!.learnerMeaning, 'Board Awareness');
    expect(byWorld[6]!.learnerMeaning, 'Range Thinking');
    expect(byWorld[7]!.learnerMeaning, 'Visible Cards Change Ranges');
    expect(byWorld[8]!.learnerMeaning, 'Stack Depth And Risk');
    expect(byWorld[9]!.learnerMeaning, 'Tournament Pressure');
    expect(byWorld[10]!.learnerMeaning, 'Player Adjustment');
    expect(byWorld[11]!.learnerMeaning, 'Real Play Transfer');
    expect(byWorld[12]!.learnerMeaning, 'Mindset Bridge');

    expect(
      byWorld[4]!.retiredMeanings,
      containsAll(<String>['Preflop Framework']),
    );
    expect(
      byWorld[5]!.retiredMeanings,
      containsAll(<String>['Bet Purpose + Price', 'Bet Purpose And Price']),
    );
    expect(
      byWorld[6]!.retiredMeanings,
      containsAll(<String>['Board Awareness', 'Board and Draws']),
    );
  });

  test('canonical truth map v1 matches active Act0 runtime titles', () {
    final state = Act0ShellStateV1.sample;
    for (final identity in canonicalTruthWorldIdentityEntriesV1()) {
      final world = state.worldById(identity.worldId);
      expect(world.worldNumber, identity.world);
      expect(world.title, identity.learnerMeaning);
      expect(identity.telemetryWorldId, identity.worldId);
    }
  });

  test('canonical truth map v1 keeps active world sessions single-owned', () {
    final ownerBySession = <String, int>{};
    for (final identity in canonicalTruthWorldIdentityEntriesV1()) {
      for (final sessionId in identity.activeSessionIds) {
        expect(
          ownerBySession[sessionId],
          isNull,
          reason: '$sessionId has multiple canonical world owners.',
        );
        ownerBySession[sessionId] = identity.world;
      }
    }

    expect(ownerBySession['w4.s01'], 4);
    expect(ownerBySession['w5.s01'], 5);
    expect(ownerBySession['w6.s01'], 6);
    expect(ownerBySession['w9.s10'], 9);
  });

  test(
    'canonical truth map v1 prevents retired W4-W6 aliases in active docs',
    () {
      final activeText = <String>[
        File(
          'docs/plan/FREE_VS_PREMIUM_LAUNCH_BOUNDARY_POLICY_v1.md',
        ).readAsStringSync(),
        File(
          'docs/plan/VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md',
        ).readAsStringSync(),
      ].join('\n');

      expect(activeText, isNot(contains('| W4 | Preflop Framework |')));
      expect(activeText, isNot(contains('| W5 | Bet Purpose + Price |')));
      expect(activeText, isNot(contains('| W6 | Board and Draws |')));
      expect(activeText, isNot(contains('| W4 Preflop Framework |')));
      expect(activeText, isNot(contains('| W5 Bet Purpose + Price |')));
      expect(activeText, isNot(contains('| W6 Board Awareness |')));
    },
  );
}
