enum SharedLearnerHostPrimitiveV1 {
  progressionChrome,
  completionSurface,
  promptStatusCapsule,
  seatStateBadge,
  compactHeaderBand,
  sceneSupportLane,
  bottomActionHierarchy,
}

enum SharedLearnerHostGapV1 {
  headerComposition,
  sceneHierarchy,
  bottomInteractionRhythm,
}

class SharedLearnerHostGrammarProfileV1 {
  const SharedLearnerHostGrammarProfileV1({
    required this.id,
    required this.label,
    required this.primitives,
    required this.remainingGaps,
  });

  final String id;
  final String label;
  final List<SharedLearnerHostPrimitiveV1> primitives;
  final List<SharedLearnerHostGapV1> remainingGaps;
}

class SharedLearnerHostGrammarAdoptionV1 {
  const SharedLearnerHostGrammarAdoptionV1({
    required this.hostFamily,
    required this.screenFamily,
    required this.itemTypes,
    required this.modeFamilies,
    required this.profile,
  });

  final String hostFamily;
  final String screenFamily;
  final List<String> itemTypes;
  final List<String> modeFamilies;
  final SharedLearnerHostGrammarProfileV1 profile;
}

const String kCanonicalSharedLearnerHostGrammarIdV1 =
    'canonicalLearnerHostGrammarV1';
const String kWorld1SharedLearnerHostGrammarIdV1 =
    'world1SharedLearnerHostGrammarV1';

const SharedLearnerHostGrammarProfileV1
kCanonicalSharedLearnerHostGrammarProfileV1 = SharedLearnerHostGrammarProfileV1(
  id: kCanonicalSharedLearnerHostGrammarIdV1,
  label: 'Canonical learner-facing host grammar',
  primitives: <SharedLearnerHostPrimitiveV1>[
    SharedLearnerHostPrimitiveV1.progressionChrome,
    SharedLearnerHostPrimitiveV1.completionSurface,
    SharedLearnerHostPrimitiveV1.promptStatusCapsule,
    SharedLearnerHostPrimitiveV1.seatStateBadge,
    SharedLearnerHostPrimitiveV1.compactHeaderBand,
    SharedLearnerHostPrimitiveV1.sceneSupportLane,
    SharedLearnerHostPrimitiveV1.bottomActionHierarchy,
  ],
  remainingGaps: <SharedLearnerHostGapV1>[],
);

const SharedLearnerHostGrammarProfileV1
kWorld1SharedLearnerHostGrammarProfileV1 = SharedLearnerHostGrammarProfileV1(
  id: kWorld1SharedLearnerHostGrammarIdV1,
  label: 'World 1 learner-facing host grammar',
  primitives: <SharedLearnerHostPrimitiveV1>[
    SharedLearnerHostPrimitiveV1.progressionChrome,
    SharedLearnerHostPrimitiveV1.completionSurface,
    SharedLearnerHostPrimitiveV1.promptStatusCapsule,
    SharedLearnerHostPrimitiveV1.seatStateBadge,
    SharedLearnerHostPrimitiveV1.compactHeaderBand,
    SharedLearnerHostPrimitiveV1.sceneSupportLane,
    SharedLearnerHostPrimitiveV1.bottomActionHierarchy,
  ],
  remainingGaps: <SharedLearnerHostGapV1>[],
);

const List<SharedLearnerHostGrammarAdoptionV1>
kSharedLearnerHostGrammarAdoptionsV1 = <SharedLearnerHostGrammarAdoptionV1>[
  SharedLearnerHostGrammarAdoptionV1(
    hostFamily: 'sessionDrillPlayer',
    screenFamily: 'CanonicalTerminalSessionDrillSurfacedRunnerV1',
    itemTypes: <String>['campaign_pack', 'session', 'track_session'],
    modeFamilies: <String>[
      'campaignSpine',
      'handChain',
      'sessionDrillSingleStep',
    ],
    profile: kCanonicalSharedLearnerHostGrammarProfileV1,
  ),
  SharedLearnerHostGrammarAdoptionV1(
    hostFamily: 'world1FoundationsRunner',
    screenFamily: 'World1FoundationsMicroTaskRunnerScreen',
    itemTypes: <String>['campaign_pack'],
    modeFamilies: <String>['campaignSpine', 'seatQuiz'],
    profile: kWorld1SharedLearnerHostGrammarProfileV1,
  ),
];

String normalizeSharedLearnerHostScreenFamilyV1(String screenFamily) {
  switch (screenFamily) {
    case 'SessionDrillPlayerV1Screen':
      return 'CanonicalTerminalSessionDrillSurfacedRunnerV1';
  }
  return screenFamily;
}

SharedLearnerHostGrammarAdoptionV1? resolveSharedLearnerHostGrammarAdoptionV1({
  required String hostFamily,
  required String screenFamily,
  required String itemType,
  required String modeFamily,
}) {
  final normalizedScreenFamily = normalizeSharedLearnerHostScreenFamilyV1(
    screenFamily,
  );
  for (final adoption in kSharedLearnerHostGrammarAdoptionsV1) {
    if (adoption.hostFamily != hostFamily ||
        adoption.screenFamily != normalizedScreenFamily) {
      continue;
    }
    if (!adoption.itemTypes.contains(itemType)) {
      continue;
    }
    if (!adoption.modeFamilies.contains(modeFamily)) {
      continue;
    }
    return adoption;
  }
  return null;
}

String sharedLearnerHostPrimitiveIdV1(SharedLearnerHostPrimitiveV1 primitive) {
  switch (primitive) {
    case SharedLearnerHostPrimitiveV1.progressionChrome:
      return 'progression_chrome';
    case SharedLearnerHostPrimitiveV1.completionSurface:
      return 'completion_surface';
    case SharedLearnerHostPrimitiveV1.promptStatusCapsule:
      return 'prompt_status_capsule';
    case SharedLearnerHostPrimitiveV1.seatStateBadge:
      return 'seat_state_badge';
    case SharedLearnerHostPrimitiveV1.compactHeaderBand:
      return 'compact_header_band';
    case SharedLearnerHostPrimitiveV1.sceneSupportLane:
      return 'scene_support_lane';
    case SharedLearnerHostPrimitiveV1.bottomActionHierarchy:
      return 'bottom_action_hierarchy';
  }
}

String sharedLearnerHostGapIdV1(SharedLearnerHostGapV1 gap) {
  switch (gap) {
    case SharedLearnerHostGapV1.headerComposition:
      return 'header_composition';
    case SharedLearnerHostGapV1.sceneHierarchy:
      return 'scene_hierarchy';
    case SharedLearnerHostGapV1.bottomInteractionRhythm:
      return 'bottom_interaction_rhythm';
  }
}
