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
  final match = RegExp(r'^world(\d+)_').firstMatch(packId.trim().toLowerCase());
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
