final RegExp _kIntentV1Pattern = RegExp(r'^[a-z0-9_]+$');
final RegExp _kSessionIdWorldPattern = RegExp(r'^w([0-9]+)\.s[0-9]+$');

class WorldIntentRuleV1 {
  const WorldIntentRuleV1({
    required this.requiresIntentV1,
    required this.allowedIntentsV1,
  });

  final bool requiresIntentV1;
  final Set<String> allowedIntentsV1;
}

const Set<String> _kEmptyIntentSet = <String>{};

const Map<int, WorldIntentRuleV1> kWorldIntentRulesV1 =
    <int, WorldIntentRuleV1>{
      0: WorldIntentRuleV1(
        requiresIntentV1: false,
        allowedIntentsV1: _kEmptyIntentSet,
      ),
      1: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'hand_discipline_fold',
          'dominated_aces',
          'trash_hands',
        },
      ),
      2: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'world2_showdown_bridge',
          'world2_initiative_bridge',
          'world2_outs_bridge',
          'world2_authored_bridge',
          'position_ip_advantage',
          'position_oop_pain',
          'position_btn_vs_early',
          'texture_pressure_building',
          'draw_pressure_assertive',
          'draw_price_continue',
          'draw_price_release',
        },
      ),
      3: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'decision_order',
          'street_structure',
          'action_sequence',
        },
      ),
      4: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'bet_for_value',
          'bet_as_bluff',
          'bet_for_protection',
          'bet_for_denial',
        },
      ),
      5: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'texture_wet_vs_dry',
          'texture_pairing',
          'texture_high_card',
          'texture_connectivity',
        },
      ),
      6: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'range_vs_hand',
          'think_in_ranges',
          'equity_realization',
          'blockers_basics',
        },
      ),
      7: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'shallow_stack_pressure',
          'deep_stack_playability',
          'stack_to_pot_awareness',
          'stack_depth_adjustment',
        },
      ),
      8: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'bubble_intuition',
          'survival_pressure',
          'risk_premium_intuition',
          'tournament_context_shift',
        },
      ),
      9: WorldIntentRuleV1(
        requiresIntentV1: true,
        allowedIntentsV1: <String>{
          'player_profile_tight_loose',
          'player_profile_passive_aggressive',
          'one_lever_adjustment',
          'avoid_leveling',
        },
      ),
    };

bool isValidIntentV1(String s) => _kIntentV1Pattern.hasMatch(s);

int? worldIndexFromSessionId(String sessionId) {
  final match = _kSessionIdWorldPattern.firstMatch(sessionId);
  if (match == null) return null;
  return int.tryParse(match.group(1)!);
}

bool requiresIntentV1ForSessionId(String sessionId) {
  final world = worldIndexFromSessionId(sessionId);
  if (world == null) return false;
  final rule = kWorldIntentRulesV1[world];
  return rule?.requiresIntentV1 ?? false;
}

Set<String> allowedIntentsV1ForSessionId(String sessionId) {
  final world = worldIndexFromSessionId(sessionId);
  if (world == null) return _kEmptyIntentSet;
  return kWorldIntentRulesV1[world]?.allowedIntentsV1 ?? _kEmptyIntentSet;
}
