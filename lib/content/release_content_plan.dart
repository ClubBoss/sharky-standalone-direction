class ReleaseContentModule {
  const ReleaseContentModule({
    required this.id,
    required this.difficultyTier,
    required this.errorClass,
    required this.reasoning,
  });

  final String id;
  final int difficultyTier;
  final String errorClass;
  final String reasoning;
}

class ReleaseContentPlanV1 {
  ReleaseContentPlanV1._();

  static const modules = <ReleaseContentModule>[
    ReleaseContentModule(
      id: 'intro_welcome',
      difficultyTier: 1,
      errorClass: 'intro_orientation',
      reasoning:
          'States poker is a skill game and frames the learning priorities.',
    ),
    ReleaseContentModule(
      id: 'intro_game_types',
      difficultyTier: 1,
      errorClass: 'intro_game_types',
      reasoning:
          'Lists supported poker variants and their structural differences.',
    ),
    ReleaseContentModule(
      id: 'intro_hand_rankings',
      difficultyTier: 1,
      errorClass: 'intro_hand_rankings',
      reasoning: 'Enumerates hand rankings from high card to royal flush.',
    ),
    ReleaseContentModule(
      id: 'intro_game_flow',
      difficultyTier: 1,
      errorClass: 'intro_game_flow',
      reasoning: 'Describes the sequence of rounds and dealer/button motions.',
    ),
    ReleaseContentModule(
      id: 'intro_actions',
      difficultyTier: 1,
      errorClass: 'intro_actions',
      reasoning: 'Defines available player actions and when they occur.',
    ),
    ReleaseContentModule(
      id: 'intro_how_to_win',
      difficultyTier: 1,
      errorClass: 'intro_how_to_win',
      reasoning: 'Clarifies the objective of winning a pot and showdown facts.',
    ),
    ReleaseContentModule(
      id: 'core_rules_and_setup',
      difficultyTier: 2,
      errorClass: 'core_rules_setup',
      reasoning:
          'Documents blinds, antes, and how stacks/interactions are initialized.',
    ),
    ReleaseContentModule(
      id: 'core_positions_and_initiative',
      difficultyTier: 2,
      errorClass: 'core_positions',
      reasoning:
          'States seat names and their responsibilities regarding action order.',
    ),
    ReleaseContentModule(
      id: 'core_starting_hands',
      difficultyTier: 2,
      errorClass: 'core_starting_hands',
      reasoning:
          'Lists starting-hand categories tied to stack depth and position.',
    ),
    ReleaseContentModule(
      id: 'tier_1_checkpoint',
      difficultyTier: 2,
      errorClass: 'tier1_checkpoint',
      reasoning:
          'Summarizes the checkpoint content to verify recall of the facts above.',
    ),
  ];

  static final Map<String, ReleaseContentModule> byId = {
    for (final module in modules) module.id: module,
  };

  static bool isRelease(String moduleId) => byId.containsKey(moduleId);

  static ReleaseContentModule? metadataFor(String moduleId) => byId[moduleId];
}
