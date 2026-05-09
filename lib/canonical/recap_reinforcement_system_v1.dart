enum RecapReinforcementPlacementKindV1 {
  specializedCheckpoint,
  blockClosureRecap,
  advancedWorldRecapClosure,
  synthesisCheckpointClosure,
  differentiatedLateClosure,
  world10AppliedTrackRecap,
}

class RecapReinforcementAnchorV1 {
  const RecapReinforcementAnchorV1({
    required this.world,
    required this.sessionId,
    required this.anchorPath,
    this.trackKind,
  });

  final int world;
  final String sessionId;
  final String anchorPath;
  final String? trackKind;
}

class RecapReinforcementPatternProfileV1 {
  const RecapReinforcementPatternProfileV1({
    required this.id,
    required this.label,
    required this.rolloutOrder,
    required this.placementKind,
    required this.placementRule,
    required this.description,
    required this.anchors,
  });

  final String id;
  final String label;
  final int rolloutOrder;
  final RecapReinforcementPlacementKindV1 placementKind;
  final String placementRule;
  final String description;
  final List<RecapReinforcementAnchorV1> anchors;
}

const List<RecapReinforcementPatternProfileV1>
kRecapReinforcementPatternProfilesV1 = <RecapReinforcementPatternProfileV1>[
  RecapReinforcementPatternProfileV1(
    id: 'specialized_checkpoint_chain_v1',
    label: 'Specialized checkpoint recap chain',
    rolloutOrder: 10,
    placementKind: RecapReinforcementPlacementKindV1.specializedCheckpoint,
    placementRule:
        'Use bounded mixed-checkpoint or capstone chains to close early-world '
        'blocks once the learner has enough stable reps for a blended read.',
    description:
        'Foundational worlds close repetition clusters through one compact '
        'checkpoint chain rather than a broad branchy review surface.',
    anchors: <RecapReinforcementAnchorV1>[
      RecapReinforcementAnchorV1(
        world: 0,
        sessionId: 'w0.s06',
        anchorPath: 'content/worlds/world0/v1/sessions/w0.s06/session.md',
      ),
      RecapReinforcementAnchorV1(
        world: 1,
        sessionId: 'w1.s06',
        anchorPath:
            'content/worlds/world1/v1/sessions/w1.s06/drills/'
            'd.chain_world1_mixed_checkpoint_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 2,
        sessionId: 'w2.s12',
        anchorPath:
            'content/worlds/world2/v1/sessions/w2.s12/drills/'
            'd.chain_world2_capstone_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 3,
        sessionId: 'w3.s10',
        anchorPath:
            'content/worlds/world3/v1/sessions/w3.s10/drills/'
            'd.chain_preflop_final_checkpoint_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 4,
        sessionId: 'w4.s10',
        anchorPath:
            'content/worlds/world4/v1/sessions/w4.s10/drills/'
            'd.chain_world4_denial_capstone_v1.json',
      ),
    ],
  ),
  RecapReinforcementPatternProfileV1(
    id: 'block_closure_recap_chain_v1',
    label: 'Block-closure recap chain',
    rolloutOrder: 20,
    placementKind: RecapReinforcementPlacementKindV1.blockClosureRecap,
    placementRule:
        'Place recap chains at the end of focused concept blocks so the '
        'learner replays one ordered story before the next block begins.',
    description:
        'World-local board-reading arcs already use explicit recap chains to '
        'close dry, turn-shift, in-position, and blocker-context blocks.',
    anchors: <RecapReinforcementAnchorV1>[
      RecapReinforcementAnchorV1(
        world: 5,
        sessionId: 'w5.s02',
        anchorPath:
            'content/worlds/world5/v1/sessions/w5.s02/drills/'
            'd.chain_world5_dry_discipline_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 5,
        sessionId: 'w5.s04',
        anchorPath:
            'content/worlds/world5/v1/sessions/w5.s04/drills/'
            'd.chain_world5_turn_shift_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 5,
        sessionId: 'w5.s06',
        anchorPath:
            'content/worlds/world5/v1/sessions/w5.s06/drills/'
            'd.chain_world5_in_position_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 5,
        sessionId: 'w5.s09',
        anchorPath:
            'content/worlds/world5/v1/sessions/w5.s09/drills/'
            'd.chain_world5_blocker_context_recap_v1.json',
      ),
    ],
  ),
  RecapReinforcementPatternProfileV1(
    id: 'advanced_world_recap_closure_v1',
    label: 'Advanced-world recap closure',
    rolloutOrder: 30,
    placementKind: RecapReinforcementPlacementKindV1.advancedWorldRecapClosure,
    placementRule:
        'Use explicit recap closures inside advanced worlds when the lesson '
        'needs to restate one decision grammar before full synthesis.',
    description:
        'Range-thinking worlds already close specific advanced arcs through '
        'flop-advantage, river-polarization, and blocker-modifier recap chains.',
    anchors: <RecapReinforcementAnchorV1>[
      RecapReinforcementAnchorV1(
        world: 6,
        sessionId: 'w6.s03',
        anchorPath:
            'content/worlds/world6/v1/sessions/w6.s03/drills/'
            'd.chain_world6_flop_advantage_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 6,
        sessionId: 'w6.s05',
        anchorPath:
            'content/worlds/world6/v1/sessions/w6.s05/drills/'
            'd.chain_world6_river_polarization_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 6,
        sessionId: 'w6.s08',
        anchorPath:
            'content/worlds/world6/v1/sessions/w6.s08/drills/'
            'd.chain_world6_blocker_modifier_recap_v1.json',
      ),
    ],
  ),
  RecapReinforcementPatternProfileV1(
    id: 'synthesis_checkpoint_closure_v1',
    label: 'Synthesis checkpoint closure',
    rolloutOrder: 40,
    placementKind: RecapReinforcementPlacementKindV1.synthesisCheckpointClosure,
    placementRule:
        'End a mature world arc with one bounded synthesis checkpoint that '
        'tests whether the earlier recap lanes now hold together as one read.',
    description:
        'Capstone sessions in the mid and late worlds already use synthesis '
        'checkpoint chains as the final closure layer.',
    anchors: <RecapReinforcementAnchorV1>[
      RecapReinforcementAnchorV1(
        world: 5,
        sessionId: 'w5.s10',
        anchorPath:
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
            'd.chain_world5_capstone_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 6,
        sessionId: 'w6.s10',
        anchorPath:
            'content/worlds/world6/v1/sessions/w6.s10/drills/'
            'd.chain_world6_range_synthesis_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 7,
        sessionId: 'w7.s10',
        anchorPath:
            'content/worlds/world7/v1/sessions/w7.s10/drills/'
            'd.chain_depth_synthesis_checkpoint_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 8,
        sessionId: 'w8.s10',
        anchorPath:
            'content/worlds/world8/v1/sessions/w8.s10/drills/'
            'd.chain_icm_synthesis_checkpoint_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 9,
        sessionId: 'w9.s10',
        anchorPath:
            'content/worlds/world9/v1/sessions/w9.s10/drills/'
            'd.chain_exploit_synthesis_checkpoint_v1.json',
      ),
    ],
  ),
  RecapReinforcementPatternProfileV1(
    id: 'late_world_differentiated_recap_v1',
    label: 'Late-world differentiated recap closure',
    rolloutOrder: 50,
    placementKind: RecapReinforcementPlacementKindV1.differentiatedLateClosure,
    placementRule:
        'Use differentiated late-street recap closures when the same final '
        'street needs distinct discipline by stack, ICM, or exploit context.',
    description:
        'Depth, ICM, and exploit worlds already use late-street recap closures '
        'that differ by pressure source rather than reusing one generic summary.',
    anchors: <RecapReinforcementAnchorV1>[
      RecapReinforcementAnchorV1(
        world: 7,
        sessionId: 'w7.s09',
        anchorPath:
            'content/worlds/world7/v1/sessions/w7.s09/drills/'
            'd.chain_world7_river_depth_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 8,
        sessionId: 'w8.s09',
        anchorPath:
            'content/worlds/world8/v1/sessions/w8.s09/drills/'
            'd.chain_world8_late_icm_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 9,
        sessionId: 'w9.s09',
        anchorPath:
            'content/worlds/world9/v1/sessions/w9.s09/drills/'
            'd.chain_world9_late_exploit_recap_v1.json',
      ),
    ],
  ),
  RecapReinforcementPatternProfileV1(
    id: 'world10_applied_track_recap_v1',
    label: 'World10 applied track recap seam',
    rolloutOrder: 60,
    placementKind: RecapReinforcementPlacementKindV1.world10AppliedTrackRecap,
    placementRule:
        'Apply one differentiated recap seam early in each World10 track so '
        'cash, tournament, and mixed followups all inherit a stable closure loop.',
    description:
        'World10 already anchors its applied followup tracks with one late-street '
        'recap chain per track at session three.',
    anchors: <RecapReinforcementAnchorV1>[
      RecapReinforcementAnchorV1(
        world: 10,
        sessionId: 'cash.s03',
        trackKind: 'cash',
        anchorPath:
            'content/worlds/world10/v1/tracks/cash/sessions/cash.s03/drills/'
            'd.chain_cash_late_street_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 10,
        sessionId: 'tournament.s03',
        trackKind: 'tournament',
        anchorPath:
            'content/worlds/world10/v1/tracks/tournament/sessions/'
            'tournament.s03/drills/d.chain_tournament_late_street_recap_v1.json',
      ),
      RecapReinforcementAnchorV1(
        world: 10,
        sessionId: 'mixed.s03',
        trackKind: 'mixed',
        anchorPath:
            'content/worlds/world10/v1/tracks/mixed/sessions/mixed.s03/drills/'
            'd.chain_mixed_late_street_recap_v1.json',
      ),
    ],
  ),
];

String recapReinforcementPlacementKindIdV1(
  RecapReinforcementPlacementKindV1 kind,
) {
  switch (kind) {
    case RecapReinforcementPlacementKindV1.specializedCheckpoint:
      return 'specialized_checkpoint';
    case RecapReinforcementPlacementKindV1.blockClosureRecap:
      return 'block_closure_recap';
    case RecapReinforcementPlacementKindV1.advancedWorldRecapClosure:
      return 'advanced_world_recap_closure';
    case RecapReinforcementPlacementKindV1.synthesisCheckpointClosure:
      return 'synthesis_checkpoint_closure';
    case RecapReinforcementPlacementKindV1.differentiatedLateClosure:
      return 'late_world_differentiated_closure';
    case RecapReinforcementPlacementKindV1.world10AppliedTrackRecap:
      return 'world10_applied_track_recap';
  }
}
