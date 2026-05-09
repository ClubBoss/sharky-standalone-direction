/// Defines mastery-based unlock rules for training topics.
///
/// Topics are unlocked when all their prerequisites have been mastered
/// (achieved "strong" category status: ≥3 correct, 0 mistakes in last 14 days).
///
/// **Rules Structure:**
/// - Key: Topic ID that requires unlocking
/// - Value: List of prerequisite topic IDs that must be mastered first
///
/// **Example:**
/// ```dart
/// 'advanced_preflop': ['preflop_basics']
/// ```
/// This means "advanced_preflop" is only accessible after mastering "preflop_basics".
///
/// **Mastery Definition:**
/// A topic is "mastered" when SkillSummaryService categorizes it as "strong":
/// - ≥3 correct spots in last 14 days
/// - 0 mistakes in last 14 days
///
/// Topics not listed here are always unlocked (no prerequisites).
const Map<String, List<String>> skillUnlockRules = {
  // Preflop advanced topics require basics
  'advanced_preflop': ['preflop_basics'],
  'preflop_3bet': ['preflop_basics'],
  'preflop_4bet': ['preflop_basics', 'preflop_3bet'],
  'preflop_cold_call': ['preflop_basics'],

  // Postflop advanced requires basics
  'advanced_postflop': ['postflop_basics'],
  'postflop_cbetting': ['postflop_basics'],
  'postflop_bluffing': ['postflop_basics', 'postflop_cbetting'],
  'postflop_value_betting': ['postflop_basics'],

  // Turn play requires flop mastery
  'turn_strategy': ['postflop_basics', 'postflop_cbetting'],
  'turn_double_barrel': ['postflop_cbetting'],
  'turn_pot_control': ['postflop_basics'],

  // River play requires turn mastery
  'river_strategy': ['turn_strategy'],
  'river_bluff_catching': ['turn_strategy', 'postflop_bluffing'],
  'river_thin_value': ['turn_strategy', 'postflop_value_betting'],

  // Position-based strategies
  'button_play': ['preflop_basics'],
  'blinds_defense': ['preflop_basics', 'button_play'],
  'utg_strategy': ['preflop_basics'],

  // Advanced concepts require multiple prerequisites
  'polarization': [
    'postflop_basics',
    'postflop_bluffing',
    'postflop_value_betting',
  ],
  'range_construction': ['preflop_basics', 'advanced_preflop'],
  'blockers': ['postflop_basics', 'advanced_postflop'],
  'equity_realization': ['postflop_basics', 'turn_strategy'],

  // Multi-way pots require heads-up mastery
  'multiway_pots': ['postflop_basics', 'postflop_cbetting'],
  'multiway_turn': ['multiway_pots', 'turn_strategy'],

  // Short-stack play
  'short_stack': ['preflop_basics'],
  'push_fold': ['short_stack'],

  // Tournament-specific
  'tournament_icm': ['preflop_basics', 'short_stack'],
  'tournament_bubble': ['tournament_icm'],

  // GTO and exploitative
  'gto_fundamentals': ['preflop_basics', 'postflop_basics'],
  'exploitative_adjustments': ['gto_fundamentals'],
  'population_tendencies': ['exploitative_adjustments'],
};

/// Returns the list of prerequisite topic IDs for a given topic.
/// Returns an empty list if the topic has no prerequisites (always unlocked).
List<String> getPrerequisites(String topicId) =>
    skillUnlockRules[topicId] ?? [];

/// Returns true if the topic has any prerequisites defined.
bool hasPrerequisites(String topicId) => skillUnlockRules.containsKey(topicId);

/// Returns all topics that are locked by prerequisites (have unlock rules).
Set<String> getAllLockedTopics() => skillUnlockRules.keys.toSet();

/// Returns all prerequisite topics across all rules (topics that unlock others).
Set<String> getAllPrerequisiteTopics() {
  final prerequisites = <String>{};
  for (final list in skillUnlockRules.values) {
    prerequisites.addAll(list);
  }
  return prerequisites;
}
