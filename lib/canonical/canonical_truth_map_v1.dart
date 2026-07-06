import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_registry;
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';

enum CanonicalTruthStatusV1 {
  productionLive,
  pilotLive,
  placeholder,
  scaffold,
  legacy,
  devOnly,
  productionLiveModernized,
  productionLiveLegacy,
}

enum CanonicalTruthHostSurfaceV1 { world1FoundationsRunner, sessionDrillPlayer }

enum CanonicalTruthModeFamilyV1 {
  seatQuiz,
  campaignSpine,
  sessionDrillSingleStep,
  handChain,
}

enum CanonicalTruthSkeletonReadinessV1 { representedReady, needsSkeletonShell }

class CanonicalTruthNodeEntryV1 {
  const CanonicalTruthNodeEntryV1({
    required this.packId,
    required this.moduleId,
    required this.world,
    required this.orderIndex,
    required this.handCount,
    required this.hostSurface,
    required this.modeFamily,
    required this.status,
    required this.skeletonReadiness,
  });

  final String packId;
  final String moduleId;
  final int world;
  final int orderIndex;
  final int handCount;
  final CanonicalTruthHostSurfaceV1 hostSurface;
  final CanonicalTruthModeFamilyV1 modeFamily;
  final CanonicalTruthStatusV1 status;
  final CanonicalTruthSkeletonReadinessV1 skeletonReadiness;
}

class CanonicalTruthWorldEntryV1 {
  const CanonicalTruthWorldEntryV1({
    required this.world,
    required this.entryPackId,
    required this.nodes,
  });

  final int world;
  final String entryPackId;
  final List<CanonicalTruthNodeEntryV1> nodes;
}

class CanonicalTruthSessionEntryV1 {
  const CanonicalTruthSessionEntryV1({
    required this.sessionId,
    required this.world,
    required this.orderIndex,
    required this.hostSurface,
    required this.modeFamily,
    required this.status,
    required this.skeletonReadiness,
  });

  final String sessionId;
  final int world;
  final int orderIndex;
  final CanonicalTruthHostSurfaceV1 hostSurface;
  final CanonicalTruthModeFamilyV1 modeFamily;
  final CanonicalTruthStatusV1 status;
  final CanonicalTruthSkeletonReadinessV1 skeletonReadiness;
}

class CanonicalTruthWorldIdentityV1 {
  const CanonicalTruthWorldIdentityV1({
    required this.world,
    required this.worldId,
    required this.learnerMeaning,
    required this.skillFamily,
    required this.activeSessionRange,
    required this.activeSessionIds,
    required this.runtimeOwner,
    required this.registryOwner,
    required this.telemetryWorldId,
    required this.retiredMeanings,
  });

  final int world;
  final String worldId;
  final String learnerMeaning;
  final String skillFamily;
  final String activeSessionRange;
  final List<String> activeSessionIds;
  final String runtimeOwner;
  final String registryOwner;
  final String telemetryWorldId;
  final List<String> retiredMeanings;
}

const Set<String> _kProductionLiveCampaignPackIdsV1 = <String>{
  'world1_act0_table_literacy',
  'world1_act0_action_literacy',
  'world1_act0_street_flow',
  'world1_spine_campaign_v1',
  'world1_spine_followup_v1_b0',
  'world1_spine_followup_v1_b1',
  'world1_spine_followup_v1_b2',
};

const Set<String> _kCanonicalSessionBackedCampaignPackIdsV1 = <String>{
  'world10_spine_campaign_v1',
  'world2_spine_campaign_v1',
  'world2_spine_followup_v1_b0',
  'world2_spine_followup_v1_b1',
  'world2_spine_followup_v1_b2',
  'world3_spine_campaign_v1',
  'world3_spine_followup_v1_b0',
  'world3_spine_followup_v1_b1',
  'world3_spine_followup_v1_b2',
  'world4_spine_campaign_v1',
  'world4_spine_followup_v1_b0',
  'world4_spine_followup_v1_b1',
  'world4_spine_followup_v1_b2',
  'world5_spine_campaign_v1',
  'world5_spine_followup_v1_b0',
  'world5_spine_followup_v1_b1',
  'world5_spine_followup_v1_b2',
  'world6_spine_campaign_v1',
  'world6_spine_followup_v1_b0',
  'world6_spine_followup_v1_b1',
  'world6_spine_followup_v1_b2',
  'volume_i_terminal_review_v1',
  'world7_spine_campaign_v1',
  'world7_spine_followup_v1_b0',
  'world7_spine_followup_v1_b1',
  'world7_spine_followup_v1_b2',
  'world8_spine_campaign_v1',
  'world8_spine_followup_v1_b0',
  'world8_spine_followup_v1_b1',
  'world8_spine_followup_v1_b2',
  'world9_spine_campaign_v1',
  'world9_spine_followup_v1_b0',
  'world9_spine_followup_v1_b1',
  'world9_spine_followup_v1_b2',
  'world10_spine_followup_v1_b0',
  'world10_spine_followup_v1_b1',
  'world10_spine_followup_v1_b2',
};

// Staged host-family truth:
// - sessionDrillPlayer is the canonical campaign/session launch owner.
// - World1 campaign packs still render through the World1 runner internally,
//   but only as a temporary adapter beneath sessionDrillPlayer.
const Map<int, List<String>> _kCanonicalPlayableScenarioSessionIdsByWorldV1 =
    <int, List<String>>{
      2: <String>[
        'w2.s01',
        'w2.s02',
        'w2.s03',
        'w2.s04',
        'w2.s05',
        'w2.s06',
        'w2.s07',
        'w2.s08',
        'w2.s09',
        'w2.s10',
        'w2.s11',
        'w2.s12',
        'w2.s13',
        'w2.s14',
      ],
      4: <String>[
        'w4.s01',
        'w4.s02',
        'w4.s03',
        'w4.s04',
        'w4.s05',
        'w4.s06',
        'w4.s07',
        'w4.s08',
        'w4.s09',
        'w4.s10',
      ],
      3: <String>[
        'w3.s01',
        'w3.s02',
        'w3.s03',
        'w3.s04',
        'w3.s05',
        'w3.s06',
        'w3.s07',
        'w3.s08',
        'w3.s09',
        'w3.s10',
        'w3.s11',
        'w3.s12',
        'w3.s13',
        'w3.s14',
      ],
      5: <String>[
        'w5.s01',
        'w5.s02',
        'w5.s03',
        'w5.s04',
        'w5.s05',
        'w5.s06',
        'w5.s07',
        'w5.s08',
        'w5.s09',
        'w5.s10',
      ],
      6: <String>[
        'w6.s01',
        'w6.s02',
        'w6.s03',
        'w6.s04',
        'w6.s05',
        'w6.s06',
        'w6.s07',
        'w6.s08',
        'w6.s09',
        'w6.s10',
      ],
      7: <String>[
        'w7.s01',
        'w7.s02',
        'w7.s03',
        'w7.s04',
        'w7.s05',
        'w7.s06',
        'w7.s07',
        'w7.s08',
        'w7.s09',
        'w7.s10',
      ],
      8: <String>[
        'w8.s01',
        'w8.s02',
        'w8.s03',
        'w8.s04',
        'w8.s05',
        'w8.s06',
        'w8.s07',
        'w8.s08',
        'w8.s09',
        'w8.s10',
      ],
      9: <String>[
        'w9.s01',
        'w9.s02',
        'w9.s03',
        'w9.s04',
        'w9.s05',
        'w9.s06',
        'w9.s07',
        'w9.s08',
        'w9.s09',
        'w9.s10',
      ],
    };

const Set<String> _kCanonicalPlayableHandChainSessionIdsV1 = <String>{
  'w2.s07',
  'w2.s08',
  'w2.s09',
  'w2.s10',
  'w2.s11',
  'w2.s12',
  'w2.s13',
  'w2.s14',
  'w3.s01',
  'w3.s02',
  'w3.s03',
  'w3.s04',
  'w3.s05',
  'w3.s06',
  'w3.s07',
  'w3.s08',
  'w3.s09',
  'w3.s10',
  'w3.s11',
  'w3.s12',
  'w3.s13',
  'w3.s14',
};

const Set<String> _kCanonicalSessionWorldCohesionSessionIdsV1 = <String>{
  'w2.s01',
  'w2.s02',
  'w2.s03',
  'w2.s04',
  'w2.s05',
  'w2.s06',
  'w2.s07',
  'w2.s08',
  'w2.s09',
  'w2.s10',
  'w2.s11',
  'w2.s12',
  'w2.s13',
  'w2.s14',
  'w3.s01',
  'w3.s02',
  'w3.s03',
  'w3.s04',
  'w3.s05',
  'w3.s06',
  'w3.s07',
  'w3.s08',
  'w3.s09',
  'w3.s10',
  'w3.s11',
  'w3.s12',
  'w3.s13',
  'w3.s14',
  'w4.s01',
  'w4.s02',
  'w4.s03',
  'w4.s04',
  'w4.s05',
  'w4.s06',
  'w4.s07',
  'w4.s08',
  'w4.s09',
  'w4.s10',
  'w5.s01',
  'w5.s02',
  'w5.s03',
  'w5.s04',
  'w5.s05',
  'w5.s06',
  'w5.s07',
  'w5.s08',
  'w5.s09',
  'w5.s10',
  'w6.s01',
  'w6.s02',
  'w6.s03',
  'w6.s04',
  'w6.s05',
  'w6.s06',
  'w6.s07',
  'w6.s08',
  'w6.s09',
  'w6.s10',
  'w7.s01',
  'w7.s02',
  'w7.s03',
  'w7.s04',
  'w7.s05',
  'w7.s06',
  'w7.s07',
  'w7.s08',
  'w7.s09',
  'w7.s10',
  'w8.s01',
  'w8.s02',
  'w8.s03',
  'w8.s04',
  'w8.s05',
  'w8.s06',
  'w8.s07',
  'w8.s08',
  'w8.s09',
  'w8.s10',
  'w9.s01',
  'w9.s02',
  'w9.s03',
  'w9.s04',
  'w9.s05',
  'w9.s06',
  'w9.s07',
  'w9.s08',
  'w9.s09',
  'w9.s10',
};

const Map<String, List<String>> _kCanonicalWorld10TrackSessionIdsByTrackV1 =
    <String, List<String>>{
      'cash': <String>[
        'cash.s01',
        'cash.s02',
        'cash.s03',
        'cash.s04',
        'cash.s05',
        'cash.s06',
        'cash.s07',
        'cash.s08',
        'cash.s09',
        'cash.s10',
      ],
      'tournament': <String>[
        'tournament.s01',
        'tournament.s02',
        'tournament.s03',
        'tournament.s04',
        'tournament.s05',
        'tournament.s06',
        'tournament.s07',
        'tournament.s08',
        'tournament.s09',
        'tournament.s10',
      ],
      'mixed': <String>[
        'mixed.s01',
        'mixed.s02',
        'mixed.s03',
        'mixed.s04',
        'mixed.s05',
        'mixed.s06',
        'mixed.s07',
        'mixed.s08',
        'mixed.s09',
        'mixed.s10',
      ],
    };

const List<CanonicalTruthWorldIdentityV1>
_kCanonicalWorldIdentityEntriesV1 = <CanonicalTruthWorldIdentityV1>[
  CanonicalTruthWorldIdentityV1(
    world: 1,
    worldId: 'world_1',
    learnerMeaning: 'Poker from Zero',
    skillFamily: 'table_rules_and_first_action',
    activeSessionRange: 'world1 campaign modules',
    activeSessionIds: <String>[],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/world1_canonical_module_order_v1.dart',
    telemetryWorldId: 'world_1',
    retiredMeanings: <String>['Table Basics'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 2,
    worldId: 'world_2',
    learnerMeaning: 'Hand Discipline',
    skillFamily: 'starting_hand_discipline',
    activeSessionRange: 'w2.s01-w2.s14',
    activeSessionIds: <String>[
      'w2.s01',
      'w2.s02',
      'w2.s03',
      'w2.s04',
      'w2.s05',
      'w2.s06',
      'w2.s07',
      'w2.s08',
      'w2.s09',
      'w2.s10',
      'w2.s11',
      'w2.s12',
      'w2.s13',
      'w2.s14',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_2',
    retiredMeanings: <String>['Hand buckets bridge'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 3,
    worldId: 'world_3',
    learnerMeaning: 'Position Thinking',
    skillFamily: 'position_and_preflop_frame_bridge',
    activeSessionRange: 'w3.s01-w3.s14',
    activeSessionIds: <String>[
      'w3.s01',
      'w3.s02',
      'w3.s03',
      'w3.s04',
      'w3.s05',
      'w3.s06',
      'w3.s07',
      'w3.s08',
      'w3.s09',
      'w3.s10',
      'w3.s11',
      'w3.s12',
      'w3.s13',
      'w3.s14',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_3',
    retiredMeanings: <String>['Preflop Framework as W4-owned route'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 4,
    worldId: 'world_4',
    learnerMeaning: 'Bet Purpose / Price',
    skillFamily: 'bet_purpose_price',
    activeSessionRange: 'w4.s01-w4.s10',
    activeSessionIds: <String>[
      'w4.s01',
      'w4.s02',
      'w4.s03',
      'w4.s04',
      'w4.s05',
      'w4.s06',
      'w4.s07',
      'w4.s08',
      'w4.s09',
      'w4.s10',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_4',
    retiredMeanings: <String>['Preflop Framework'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 5,
    worldId: 'world_5',
    learnerMeaning: 'Board Awareness',
    skillFamily: 'board_texture_draws_and_street_changes',
    activeSessionRange: 'w5.s01-w5.s10',
    activeSessionIds: <String>[
      'w5.s01',
      'w5.s02',
      'w5.s03',
      'w5.s04',
      'w5.s05',
      'w5.s06',
      'w5.s07',
      'w5.s08',
      'w5.s09',
      'w5.s10',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_5',
    retiredMeanings: <String>['Bet Purpose + Price', 'Bet Purpose And Price'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 6,
    worldId: 'world_6',
    learnerMeaning: 'Range Thinking',
    skillFamily: 'range_buckets_and_board_fit',
    activeSessionRange: 'w6.s01-w6.s10',
    activeSessionIds: <String>[
      'w6.s01',
      'w6.s02',
      'w6.s03',
      'w6.s04',
      'w6.s05',
      'w6.s06',
      'w6.s07',
      'w6.s08',
      'w6.s09',
      'w6.s10',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_6',
    retiredMeanings: <String>['Board Awareness', 'Board and Draws'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 7,
    worldId: 'world_7',
    learnerMeaning: 'Visible Cards Change Ranges',
    skillFamily: 'visible_card_range_narrowing',
    activeSessionRange: 'w7.s01-w7.s10',
    activeSessionIds: <String>[
      'w7.s01',
      'w7.s02',
      'w7.s03',
      'w7.s04',
      'w7.s05',
      'w7.s06',
      'w7.s07',
      'w7.s08',
      'w7.s09',
      'w7.s10',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_7',
    retiredMeanings: <String>['Range Thinking Lite'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 8,
    worldId: 'world_8',
    learnerMeaning: 'Stack Depth And Risk',
    skillFamily: 'stack_depth_and_risk_control',
    activeSessionRange: 'w8.s01-w8.s10',
    activeSessionIds: <String>[
      'w8.s01',
      'w8.s02',
      'w8.s03',
      'w8.s04',
      'w8.s05',
      'w8.s06',
      'w8.s07',
      'w8.s08',
      'w8.s09',
      'w8.s10',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_8',
    retiredMeanings: <String>['Draws as W8 primary route'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 9,
    worldId: 'world_9',
    learnerMeaning: 'Tournament Pressure',
    skillFamily: 'tournament_pressure_and_risk_premium',
    activeSessionRange: 'w9.s01-w9.s10',
    activeSessionIds: <String>[
      'w9.s01',
      'w9.s02',
      'w9.s03',
      'w9.s04',
      'w9.s05',
      'w9.s06',
      'w9.s07',
      'w9.s08',
      'w9.s09',
      'w9.s10',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_9',
    retiredMeanings: <String>['Price and Pot Odds as W9 primary route'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 10,
    worldId: 'world_10',
    learnerMeaning: 'Player Adjustment',
    skillFamily: 'player_type_adjustment',
    activeSessionRange:
        'cash.s01-cash.s10, tournament.s01-tournament.s10, mixed.s01-mixed.s10',
    activeSessionIds: <String>[
      'cash.s01',
      'cash.s02',
      'cash.s03',
      'cash.s04',
      'cash.s05',
      'cash.s06',
      'cash.s07',
      'cash.s08',
      'cash.s09',
      'cash.s10',
      'tournament.s01',
      'tournament.s02',
      'tournament.s03',
      'tournament.s04',
      'tournament.s05',
      'tournament.s06',
      'tournament.s07',
      'tournament.s08',
      'tournament.s09',
      'tournament.s10',
      'mixed.s01',
      'mixed.s02',
      'mixed.s03',
      'mixed.s04',
      'mixed.s05',
      'mixed.s06',
      'mixed.s07',
      'mixed.s08',
      'mixed.s09',
      'mixed.s10',
    ],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/canonical/canonical_truth_map_v1.dart',
    telemetryWorldId: 'world_10',
    retiredMeanings: <String>['Bet Purpose transfer taxonomy as W10 route'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 11,
    worldId: 'world_11',
    learnerMeaning: 'Real Play Transfer',
    skillFamily: 'real_play_transfer_and_capstone',
    activeSessionRange: 'source-owned W11 route packet',
    activeSessionIds: <String>[],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/campaign/w11_route_admission_contract_v1.dart',
    telemetryWorldId: 'world_11',
    retiredMeanings: <String>['Board Texture as W11 primary route'],
  ),
  CanonicalTruthWorldIdentityV1(
    world: 12,
    worldId: 'world_12',
    learnerMeaning: 'Mindset Bridge',
    skillFamily: 'process_mindset_and_tilt_reset',
    activeSessionRange:
        'source-owned W12 route packet plus Volume I terminal review',
    activeSessionIds: <String>[],
    runtimeOwner: 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
    registryOwner: 'lib/campaign/w12_route_admission_contract_v1.dart',
    telemetryWorldId: 'world_12',
    retiredMeanings: <String>['Review Decision as W12 primary route'],
  ),
];

List<CanonicalTruthWorldIdentityV1> canonicalTruthWorldIdentityEntriesV1() =>
    List<CanonicalTruthWorldIdentityV1>.unmodifiable(
      _kCanonicalWorldIdentityEntriesV1,
    );

CanonicalTruthWorldIdentityV1? canonicalTruthWorldIdentityForWorldIdV1(
  String worldId,
) {
  final normalized = worldId.trim().toLowerCase();
  for (final entry in _kCanonicalWorldIdentityEntriesV1) {
    if (entry.worldId == normalized ||
        entry.telemetryWorldId == normalized ||
        entry.world == int.tryParse(normalized.replaceFirst('world_', ''))) {
      return entry;
    }
  }
  return null;
}

CanonicalTruthStatusV1 canonicalTruthStatusForCampaignPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  if (normalized == 'world1_act0_table_literacy') {
    return CanonicalTruthStatusV1.productionLiveModernized;
  }
  if (normalized == 'world1_act0_action_literacy') {
    return CanonicalTruthStatusV1.productionLiveModernized;
  }
  if (normalized == 'world1_act0_street_flow') {
    return CanonicalTruthStatusV1.productionLiveModernized;
  }
  if (_kProductionLiveCampaignPackIdsV1.contains(normalized)) {
    return CanonicalTruthStatusV1.productionLive;
  }
  if (normalized.startsWith('world2_spine_')) {
    return CanonicalTruthStatusV1.pilotLive;
  }
  return CanonicalTruthStatusV1.scaffold;
}

CanonicalTruthModeFamilyV1 canonicalTruthModeFamilyForCampaignPackIdV1(
  String packId,
) {
  final normalized = packId.trim().toLowerCase();
  if (normalized.contains('_act0_')) {
    return CanonicalTruthModeFamilyV1.seatQuiz;
  }
  return CanonicalTruthModeFamilyV1.campaignSpine;
}

CanonicalTruthHostSurfaceV1 canonicalTruthHostSurfaceForCampaignPackIdV1(
  String packId,
) {
  final normalized = packId.trim().toLowerCase();
  if (_kProductionLiveCampaignPackIdsV1.contains(normalized)) {
    return CanonicalTruthHostSurfaceV1.sessionDrillPlayer;
  }
  if (_kCanonicalSessionBackedCampaignPackIdsV1.contains(normalized)) {
    return CanonicalTruthHostSurfaceV1.sessionDrillPlayer;
  }
  return CanonicalTruthHostSurfaceV1.world1FoundationsRunner;
}

bool canonicalTruthCampaignPackUsesSessionDrillPlayerV1(String packId) {
  return canonicalTruthHostSurfaceForCampaignPackIdV1(packId) ==
      CanonicalTruthHostSurfaceV1.sessionDrillPlayer;
}

bool canonicalTruthIsPlayableSessionEntryIdV1(String entryId) {
  final normalized = entryId.trim().toLowerCase();
  final trackMatch = RegExp(
    r'^(cash|tournament|mixed)\.s([0-9]{2})$',
  ).firstMatch(normalized);
  if (trackMatch != null) {
    final sessionIndex = int.tryParse(trackMatch.group(2) ?? '');
    return sessionIndex != null && sessionIndex >= 1 && sessionIndex <= 10;
  }
  final worldMatch = RegExp(r'^w([0-9]+)\.s[0-9]{2}$').firstMatch(normalized);
  final worldIndex = int.tryParse(worldMatch?.group(1) ?? '');
  if (worldIndex == null || worldIndex <= 0) {
    return false;
  }
  return canonicalTruthPlayableSessionEntriesForWorldV1(
    worldIndex,
  ).any((entry) => entry.sessionId.trim().toLowerCase() == normalized);
}

bool canonicalTruthCampaignPackIsIntentionalRunnerExceptionV1(String packId) =>
    false;

String? canonicalTruthWorld10TrackRootSessionIdForCampaignPackV1(
  String packId,
) {
  switch (packId.trim().toLowerCase()) {
    case 'world10_spine_followup_v1_b0':
      return 'cash.s01';
    case 'world10_spine_followup_v1_b1':
      return 'tournament.s01';
    case 'world10_spine_followup_v1_b2':
      return 'mixed.s01';
  }
  return null;
}

Future<String> canonicalTruthResolveCampaignLaunchTargetV1(
  String packId,
) async {
  final normalized = packId.trim().toLowerCase();
  if (canonicalTruthIsPlayableSessionEntryIdV1(normalized)) {
    return normalized;
  }
  final world10TrackRootSessionId =
      canonicalTruthWorld10TrackRootSessionIdForCampaignPackV1(normalized);
  if (world10TrackRootSessionId != null) {
    return world10TrackRootSessionId;
  }
  if (canonicalTruthCampaignPackUsesSessionDrillPlayerV1(normalized)) {
    final worldMatch = RegExp(r'^world([0-9]+)_').firstMatch(normalized);
    final worldIndex = int.tryParse(worldMatch?.group(1) ?? '');
    if (worldIndex != null && worldIndex > 1) {
      final sessionCandidate =
          await canonicalTruthNextIncompletePlayableSessionForWorldV1(
            worldIndex,
          ) ??
          'w$worldIndex.s01';
      if (canonicalTruthIsPlayableSessionEntryIdV1(sessionCandidate)) {
        return sessionCandidate;
      }
    }
  }
  final match = RegExp(
    r'^world([0-9]+)_spine_campaign_v1$',
  ).firstMatch(normalized);
  final worldIndex = int.tryParse(match?.group(1) ?? '');
  if (worldIndex == null || worldIndex <= 1) {
    return normalized;
  }
  final sessionCandidate =
      await canonicalTruthNextIncompletePlayableSessionForWorldV1(worldIndex) ??
      'w$worldIndex.s01';
  if (canonicalTruthIsPlayableSessionEntryIdV1(sessionCandidate)) {
    return sessionCandidate;
  }
  return normalized;
}

CanonicalTruthStatusV1 canonicalTruthStatusForSessionIdV1(String sessionId) {
  final normalized = sessionId.trim().toLowerCase();
  final isPlayable = _kCanonicalPlayableScenarioSessionIdsByWorldV1.values.any(
    (sessionIds) => sessionIds.contains(normalized),
  );
  final isTrackSession = _kCanonicalWorld10TrackSessionIdsByTrackV1.values.any(
    (sessionIds) => sessionIds.contains(normalized),
  );
  if (isPlayable || isTrackSession) {
    return CanonicalTruthStatusV1.pilotLive;
  }
  return CanonicalTruthStatusV1.scaffold;
}

CanonicalTruthModeFamilyV1 canonicalTruthModeFamilyForSessionIdV1(
  String sessionId,
) {
  final normalized = sessionId.trim().toLowerCase();
  if (_kCanonicalPlayableHandChainSessionIdsV1.contains(normalized)) {
    return CanonicalTruthModeFamilyV1.handChain;
  }
  return CanonicalTruthModeFamilyV1.sessionDrillSingleStep;
}

bool canonicalTruthUsesSessionWorldCohesionSpineV1(String sessionId) {
  final normalized = sessionId.trim().toLowerCase();
  return _kCanonicalSessionWorldCohesionSessionIdsV1.contains(normalized);
}

CanonicalTruthSkeletonReadinessV1 canonicalTruthSkeletonReadinessForSessionIdV1(
  String sessionId,
) {
  return canonicalTruthSkeletonReadinessForCampaignPackIdV1(sessionId);
}

CanonicalTruthSkeletonReadinessV1
canonicalTruthSkeletonReadinessForCampaignPackIdV1(String packId) {
  final status = canonicalTruthStatusForCampaignPackIdV1(packId);
  if (status == CanonicalTruthStatusV1.productionLive ||
      status == CanonicalTruthStatusV1.productionLiveModernized ||
      status == CanonicalTruthStatusV1.productionLiveLegacy ||
      status == CanonicalTruthStatusV1.pilotLive) {
    return CanonicalTruthSkeletonReadinessV1.representedReady;
  }
  return CanonicalTruthSkeletonReadinessV1.needsSkeletonShell;
}

int? _campaignWorldForPackIdV1(String packId) {
  final normalized = packId.trim().toLowerCase();
  if (normalized == ProgressService.w7W10LearnerRouteGateTerminalPackIdV1) {
    return 12;
  }
  final match = RegExp(r'^world(\d+)_').firstMatch(normalized);
  if (match == null) return null;
  return int.tryParse(match.group(1) ?? '');
}

List<String> canonicalTruthCampaignPackOrderForWorldV1(int world) {
  if (world == 1) {
    return List<String>.unmodifiable(kWorld1CanonicalModuleOrder);
  }
  final prefix = 'world${world}_';
  final sortable = ProgressService.campaignPackIdsV1
      .where((id) => id.startsWith(prefix))
      .toList(growable: true);
  sortable.sort((a, b) {
    const spineCoreToken = '_spine_campaign_v1';
    final aIsSpineCore = a.contains(spineCoreToken);
    final bIsSpineCore = b.contains(spineCoreToken);
    if (aIsSpineCore != bIsSpineCore) {
      return aIsSpineCore ? -1 : 1;
    }
    final aSuffix = RegExp(r'_b(\d+)$').firstMatch(a);
    final bSuffix = RegExp(r'_b(\d+)$').firstMatch(b);
    if (aSuffix != null && bSuffix != null) {
      final aNum = int.tryParse(aSuffix.group(1) ?? '');
      final bNum = int.tryParse(bSuffix.group(1) ?? '');
      if (aNum != null && bNum != null) {
        final byNum = aNum.compareTo(bNum);
        if (byNum != 0) {
          return byNum;
        }
      }
    }
    return a.compareTo(b);
  });
  if (world == 12 &&
      ProgressService.campaignPackIdsV1.contains(
        ProgressService.w7W10LearnerRouteGateTerminalPackIdV1,
      )) {
    sortable.add(ProgressService.w7W10LearnerRouteGateTerminalPackIdV1);
  }
  return List<String>.unmodifiable(sortable);
}

List<CanonicalTruthWorldEntryV1> canonicalTruthWorldEntriesV1() {
  final worlds = ProgressService.campaignPackIdsV1
      .map(_campaignWorldForPackIdV1)
      .whereType<int>()
      .toSet()
      .toList(growable: true);
  worlds.sort();
  return worlds
      .map((world) {
        final packIds = canonicalTruthCampaignPackOrderForWorldV1(world);
        final nodes = List<CanonicalTruthNodeEntryV1>.generate(
          packIds.length,
          (index) => CanonicalTruthNodeEntryV1(
            packId: packIds[index],
            moduleId: packIds[index],
            world: world,
            orderIndex: index,
            handCount: campaign_registry.campaignHandCountForPackIdV1(
              packIds[index],
            ),
            hostSurface: canonicalTruthHostSurfaceForCampaignPackIdV1(
              packIds[index],
            ),
            modeFamily: canonicalTruthModeFamilyForCampaignPackIdV1(
              packIds[index],
            ),
            status: canonicalTruthStatusForCampaignPackIdV1(packIds[index]),
            skeletonReadiness:
                canonicalTruthSkeletonReadinessForCampaignPackIdV1(
                  packIds[index],
                ),
          ),
          growable: false,
        );
        return CanonicalTruthWorldEntryV1(
          world: world,
          entryPackId: nodes.first.packId,
          nodes: List<CanonicalTruthNodeEntryV1>.unmodifiable(nodes),
        );
      })
      .where((entry) => entry.nodes.isNotEmpty)
      .toList(growable: false);
}

List<String> canonicalManifestBackedModuleIdsForWorldV1(int world) {
  final matchingWorlds = canonicalTruthWorldEntriesV1().where(
    (entry) => entry.world == world,
  );
  if (matchingWorlds.isEmpty) {
    return const <String>[];
  }
  return List<String>.unmodifiable(
    matchingWorlds.first.nodes
        .where(
          (node) =>
              node.modeFamily == CanonicalTruthModeFamilyV1.seatQuiz &&
              node.skeletonReadiness ==
                  CanonicalTruthSkeletonReadinessV1.representedReady,
        )
        .map((node) => node.moduleId),
  );
}

Map<String, CanonicalTruthNodeEntryV1> canonicalTruthNodeByPackIdV1() {
  final nodes = <String, CanonicalTruthNodeEntryV1>{};
  for (final world in canonicalTruthWorldEntriesV1()) {
    for (final node in world.nodes) {
      nodes[node.packId] = node;
    }
  }
  return Map<String, CanonicalTruthNodeEntryV1>.unmodifiable(nodes);
}

List<CanonicalTruthSessionEntryV1>
canonicalTruthPlayableSessionEntriesForWorldV1(int world) {
  final sessionIds =
      _kCanonicalPlayableScenarioSessionIdsByWorldV1[world] ?? const <String>[];
  return List<CanonicalTruthSessionEntryV1>.generate(
    sessionIds.length,
    (index) => CanonicalTruthSessionEntryV1(
      sessionId: sessionIds[index],
      world: world,
      orderIndex: index,
      hostSurface: CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      modeFamily: canonicalTruthModeFamilyForSessionIdV1(sessionIds[index]),
      status: canonicalTruthStatusForSessionIdV1(sessionIds[index]),
      skeletonReadiness: canonicalTruthSkeletonReadinessForSessionIdV1(
        sessionIds[index],
      ),
    ),
    growable: false,
  );
}

String? canonicalTruthWorld10TrackKindForSessionIdV1(String sessionId) {
  final normalized = sessionId.trim().toLowerCase();
  for (final entry in _kCanonicalWorld10TrackSessionIdsByTrackV1.entries) {
    if (entry.value.contains(normalized)) {
      return entry.key;
    }
  }
  return null;
}

List<String> canonicalTruthPlayableTrackSessionIdsForWorld10V1(
  String trackKind,
) {
  final normalized = trackKind.trim().toLowerCase();
  return List<String>.unmodifiable(
    _kCanonicalWorld10TrackSessionIdsByTrackV1[normalized] ?? const <String>[],
  );
}

List<CanonicalTruthSessionEntryV1>
canonicalTruthPlayableTrackSessionEntriesForWorld10V1(String trackKind) {
  final sessionIds = canonicalTruthPlayableTrackSessionIdsForWorld10V1(
    trackKind,
  );
  return List<CanonicalTruthSessionEntryV1>.generate(
    sessionIds.length,
    (index) => CanonicalTruthSessionEntryV1(
      sessionId: sessionIds[index],
      world: 10,
      orderIndex: index,
      hostSurface: CanonicalTruthHostSurfaceV1.sessionDrillPlayer,
      modeFamily: canonicalTruthModeFamilyForSessionIdV1(sessionIds[index]),
      status: canonicalTruthStatusForSessionIdV1(sessionIds[index]),
      skeletonReadiness: canonicalTruthSkeletonReadinessForSessionIdV1(
        sessionIds[index],
      ),
    ),
    growable: false,
  );
}

Future<String?> canonicalTruthNextIncompletePlayableSessionForWorldV1(
  int world,
) async {
  final entries = canonicalTruthPlayableSessionEntriesForWorldV1(world);
  if (entries.isEmpty) {
    return null;
  }
  for (final entry in entries) {
    final completed = await ProgressService.isModuleCompleted(entry.sessionId);
    if (!completed) {
      return entry.sessionId;
    }
  }
  return null;
}
