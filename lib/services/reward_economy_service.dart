import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_lite_telemetry_service.dart';

/// Simple XP -> chip conversion economy plus reward inventory handling.
class RewardEconomyService {
  RewardEconomyService._();

  static final RewardEconomyService instance = RewardEconomyService._();

  static const String _balanceKey = 'reward_economy_balance';
  static const int _xpPerChip = 5;

  static const List<RewardItem> _rewards = <RewardItem>[
    RewardItem(
      id: 'booster_pack',
      name: 'Booster Pack',
      description: 'Instant +15 XP injection.',
      cost: 25,
    ),
    RewardItem(
      id: 'hud_theme',
      name: 'HUD Theme',
      description: 'Unlock a fresh HUD skin.',
      cost: 40,
    ),
    RewardItem(
      id: 'drill_token',
      name: 'Drill Token',
      description: 'Skip to any premium drill.',
      cost: 30,
    ),
    RewardItem(
      id: 'coach_insight',
      name: 'Coach Insight',
      description: 'One guided review session.',
      cost: 55,
    ),
  ];

  /// Returns the available reward catalog.
  List<RewardItem> listRewards() => List<RewardItem>.unmodifiable(_rewards);

  /// Current chip balance.
  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_balanceKey) ?? 0;
  }

  /// Earn chips by converting XP (floor(xp / rate)).
  Future<int> earnChipsFromXp(int xp, {String reason = 'xp'}) async {
    final chips = xp ~/ _xpPerChip;
    if (chips <= 0) {
      return await getBalance();
    }
    return earnChips(chips: chips, reason: reason, metadata: {'xp': xp});
  }

  /// Directly add chip balance.
  Future<int> earnChips({
    required int chips,
    String reason = 'manual',
    Map<String, Object?> metadata = const {},
  }) async {
    if (chips <= 0) {
      return await getBalance();
    }
    final prefs = await SharedPreferences.getInstance();
    final balance = (prefs.getInt(_balanceKey) ?? 0) + chips;
    await prefs.setInt(_balanceKey, balance);
    FirebaseLiteTelemetryService.instance.logEvent(
      'chips_earned',
      params: {'chips': chips, 'reason': reason, ...metadata},
    );
    return balance;
  }

  /// Spend chips if balance allows. Returns true on success.
  Future<bool> spendChips(int amount, {String reason = 'spend'}) async {
    if (amount <= 0) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_balanceKey) ?? 0;
    if (current < amount) {
      return false;
    }
    final next = current - amount;
    await prefs.setInt(_balanceKey, next);
    FirebaseLiteTelemetryService.instance.logEvent(
      'chips_spent',
      params: {'amount': amount, 'reason': reason, 'balance': next},
    );
    return true;
  }

  /// Attempt to purchase a reward item.
  Future<bool> purchaseReward(RewardItem reward) async {
    final ok = await spendChips(reward.cost, reason: 'reward_${reward.id}');
    if (!ok) {
      return false;
    }
    FirebaseLiteTelemetryService.instance.logEvent(
      'reward_purchased',
      params: {'reward_id': reward.id, 'cost': reward.cost},
    );
    return true;
  }
}

class RewardItem {
  const RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });

  final String id;
  final String name;
  final String description;
  final int cost;
}
