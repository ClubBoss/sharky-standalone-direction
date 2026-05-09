import 'module_progress_service.dart';

/// Provides scoped training roadmap data based on completed modules.
class TrainingRoadmapService {
  TrainingRoadmapService({ModuleProgressService? moduleProgressService})
    : _moduleProgressService = moduleProgressService ?? ModuleProgressService();

  final ModuleProgressService _moduleProgressService;

  /// Returns roadmap entries for the predefined scopes.
  List<TrainingRoadmapScope> buildRoadmap({Set<String>? completedOverride}) {
    final completed =
        completedOverride ?? _moduleProgressService.getCompletedModules();
    final normalizedCompleted = completed.map((id) => id.trim()).toSet();
    final items = <TrainingRoadmapScope>[];

    for (final scopeKey in _scopeOrder) {
      final moduleIds = _scopeModuleIds[scopeKey] ?? const <String>[];
      if (moduleIds.isEmpty) {
        items.add(
          TrainingRoadmapScope(
            scopeKey: scopeKey,
            modulesCompleted: 0,
            modulesTotal: 0,
          ),
        );
        continue;
      }
      final completedCount = moduleIds
          .where(normalizedCompleted.contains)
          .length;
      items.add(
        TrainingRoadmapScope(
          scopeKey: scopeKey,
          modulesCompleted: completedCount > moduleIds.length
              ? moduleIds.length
              : completedCount,
          modulesTotal: moduleIds.length,
        ),
      );
    }

    return items;
  }
}

/// Describes roadmap progress for a single training scope.
class TrainingRoadmapScope {
  final String scopeKey;
  final int modulesCompleted;
  final int modulesTotal;

  const TrainingRoadmapScope({
    required this.scopeKey,
    required this.modulesCompleted,
    required this.modulesTotal,
  });

  double get completionFraction {
    if (modulesTotal <= 0) return 0;
    final ratio = modulesCompleted / modulesTotal;
    if (ratio.isNaN) return 0;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }
}

const List<String> _scopeOrder = [
  'core',
  'cash',
  'mtt',
  'live',
  'math',
  'solver',
];

const Map<String, List<String>> _scopeModuleIds = {
  'core': [
    'core_bankroll_management',
    'core_bet_sizing_fe',
    'core_board_textures',
    'core_check_raise_systems',
    'core_equity_realization',
    'core_flop_fundamentals',
    'core_gto_vs_exploit',
    'core_mental_game',
    'core_note_taking',
    'core_positions_and_initiative',
    'core_pot_odds_equity',
    'core_river_fundamentals',
    'core_rules_and_setup',
    'core_starting_hands',
    'core_turn_fundamentals',
  ],
  'cash': [
    'cash_3bet_oop_playbook',
    'cash_blind_defense',
    'cash_blind_defense_vs_btn_co',
    'cash_blind_vs_blind',
    'cash_delayed_cbet_and_probe_systems',
    'cash_fourbet_pots',
    'cash_isolation_raises',
    'cash_limp_pots_systems',
    'cash_multiway_3bet_pots',
    'cash_multiway_pots',
    'cash_overbets_and_blocker_bets',
    'cash_population_exploits',
    'cash_rake_and_stakes',
    'cash_short_handed',
    'cash_single_raised_pots',
    'cash_squeeze_strategy',
    'cash_threebet_pots',
    'cash_turn_river_barreling',
  ],
  'mtt': [
    'mtt_antes_phases',
    'mtt_day2_bagging_and_reentry_ev',
    'mtt_deep_stack',
    'mtt_final_table_playbooks',
    'mtt_icm_basics',
    'mtt_icm_endgame_advanced',
    'mtt_late_reg_strategy',
    'mtt_mid_stack',
    'mtt_pko_advanced_bounty_routing',
    'mtt_pko_strategy',
    'mtt_satellite_strategy',
    'mtt_short_stack',
  ],
  'live': [
    'live_chip_handling_and_bet_declares',
    'live_etiquette_and_procedures',
    'live_floor_calls_and_dispute_resolution',
    'live_full_ring_adjustments',
    'live_rake_structures_and_tips',
    'live_security_and_game_integrity',
    'live_session_log_and_review',
    'live_special_formats_straddle_bomb_ante',
    'live_speech_timing_basics',
    'live_table_selection_and_seat_change',
    'live_tells_and_dynamics',
  ],
  'math': [
    'math_combo_blockers',
    'math_ev_calculations',
    'math_icm_advanced',
    'math_icm_basics',
    'math_intro_basics',
    'math_pot_odds_equity',
  ],
  'solver': ['math_solver_basics', 'solver_node_locking_basics'],
};
