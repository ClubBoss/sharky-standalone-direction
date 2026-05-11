import 'package:poker_analyzer/ui_v2/runner/world1_foundations_entry_metadata_v1.dart';

class DuelCodePayloadV1 {
  const DuelCodePayloadV1({
    required this.moduleId,
    required this.focusLabel,
    required this.stampYmdHour,
  });

  final String moduleId;
  final String focusLabel;
  final String stampYmdHour;
}

const Set<String> kTodayPlanSupportedModuleIds = <String>{
  'world1_spine_campaign_v1',
  'world1_spine_followup_v1_b0',
  'world1_spine_followup_v1_b1',
  'world1_spine_followup_v1_b2',
  'world1_act0_table_literacy',
  'world1_act0_action_literacy',
  'world1_act0_street_flow',
  'core_positions_and_initiative',
  'core_starting_hands',
  'core_pot_odds_equity',
  'core_board_textures',
  'core_flop_fundamentals',
  'core_equity_realization',
  'core_turn_fundamentals',
  'core_river_fundamentals',
  'core_bankroll_management',
};

String campaignNextPackIdForBandV1(int band) {
  switch (band) {
    case 2:
      return 'world1_spine_followup_v1_b2';
    case 1:
      return 'world1_spine_followup_v1_b1';
    default:
      return 'world1_spine_followup_v1_b0';
  }
}

String recommendedModuleIdForFocus({
  required String? focusLabel,
  required bool reviewDue,
  String? skillBand,
  int? placementScore,
}) {
  if (reviewDue) {
    return 'world1_act0_action_literacy';
  }
  final band = (skillBand ?? '').trim().toLowerCase();
  final score = (placementScore ?? 0).clamp(0, 3);
  if (band == 'advanced') {
    return score >= 2
        ? 'world1_spine_followup_v1_b2'
        : 'world1_spine_followup_v1_b1';
  }
  if (band == 'intermediate') {
    return score >= 2
        ? 'world1_spine_followup_v1_b1'
        : 'world1_spine_followup_v1_b0';
  }
  switch ((focusLabel ?? '').trim().toLowerCase()) {
    case 'initiative':
    case 'action_order':
      return 'core_positions_and_initiative';
    case 'starting_hands':
    case 'hand_selection':
      return 'core_starting_hands';
    case 'pot_odds':
    case 'equity':
      return 'core_pot_odds_equity';
    case 'board_texture':
      return 'core_board_textures';
    case 'flop':
      return 'core_flop_fundamentals';
    case 'equity_realization':
      return 'core_equity_realization';
    case 'turn':
      return 'core_turn_fundamentals';
    case 'river':
      return 'core_river_fundamentals';
    case 'bankroll':
      return 'core_bankroll_management';
    case 'range':
      return 'world1_act0_action_literacy';
    default:
      return 'world1_act0_table_literacy';
  }
}

String recommendedCompatibilityModuleTitleForId(String moduleId) {
  switch (moduleId) {
    case 'intro_actions':
      return 'Actions and Flow';
    case 'intro_game_types':
      return 'Game Types';
    case 'intro_hand_rankings':
      return 'Hand Rankings';
    case 'intro_how_to_win':
      return 'How to Win';
    case 'core_rules_and_setup':
      return 'Rules and Setup';
    case 'tier_1_checkpoint':
      return 'Tier 1 Checkpoint';
    default:
      return 'Welcome to Poker';
  }
}

String recommendedLearningModuleTitleForId(String moduleId) {
  final entryMetadata = resolveWorld1FoundationsEntryMetadataV1(moduleId);
  if (entryMetadata != null) {
    return entryMetadata.titleText;
  }
  switch (moduleId) {
    case 'world1_spine_followup_v1_b0':
      return 'Campaign Follow-up B0';
    case 'world1_spine_followup_v1_b1':
      return 'Campaign Follow-up B1';
    case 'world1_spine_followup_v1_b2':
      return 'Campaign Follow-up B2';
    case 'core_positions_and_initiative':
      return 'Positions and Initiative';
    case 'core_starting_hands':
      return 'Starting Hands';
    case 'core_pot_odds_equity':
      return 'Pot Odds & Equity';
    case 'core_board_textures':
      return 'Board Texture';
    case 'core_flop_fundamentals':
      return 'Flop Fundamentals';
    case 'core_equity_realization':
      return 'Equity Realization';
    case 'core_turn_fundamentals':
      return 'Turn Fundamentals';
    case 'core_river_fundamentals':
      return 'River Fundamentals';
    case 'core_bankroll_management':
      return 'Bankroll Management';
    default:
      return recommendedCompatibilityModuleTitleForId(moduleId);
  }
}

String recommendedModuleTitleForId(String moduleId) {
  return recommendedLearningModuleTitleForId(moduleId);
}

String formatYmdHour(DateTime dtUtc) {
  final y = dtUtc.year.toString().padLeft(4, '0');
  final m = dtUtc.month.toString().padLeft(2, '0');
  final d = dtUtc.day.toString().padLeft(2, '0');
  final h = dtUtc.hour.toString().padLeft(2, '0');
  return '$y$m$d$h';
}

String encodeDuelCodeV1({
  required String moduleId,
  required String focusLabel,
  required String stampYmdHour,
}) {
  final normalizedModule = moduleId.trim().toLowerCase();
  final normalizedFocus = focusLabel.trim().toLowerCase();
  return 'DUEL1|$normalizedModule|$normalizedFocus|$stampYmdHour';
}

DuelCodePayloadV1? parseDuelCodeV1(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;
  final parts = value.split('|');
  if (parts.length != 4) return null;
  if (parts[0] != 'DUEL1') return null;
  final moduleId = parts[1].trim().toLowerCase();
  final focusLabel = parts[2].trim().toLowerCase();
  final stamp = parts[3].trim();
  if (!kTodayPlanSupportedModuleIds.contains(moduleId)) return null;
  if (focusLabel.isEmpty) return null;
  if (!RegExp(r'^\d{10}$').hasMatch(stamp)) return null;
  return DuelCodePayloadV1(
    moduleId: moduleId,
    focusLabel: focusLabel,
    stampYmdHour: stamp,
  );
}
