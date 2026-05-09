import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'world_mastery_v1.dart';

enum SeasonBadgeV1 { none, bronze, silver, gold }

class Season1SummaryV1 {
  const Season1SummaryV1({
    required this.badge,
    required this.topSkills,
    required this.chipsBalance,
    required this.chipsEarnedTotal,
    required this.chipsSpentTotal,
    required this.line,
  });

  final SeasonBadgeV1 badge;
  final List<String> topSkills;
  final int chipsBalance;
  final int chipsEarnedTotal;
  final int chipsSpentTotal;
  final String line;
}

const String _worldMasteryPrefixV1 = 'world_mastery_v1::';
const String _skillTagsPrefixV1 = 'skill_tags_v1::';
const String _chipsBalanceV1Key = 'chips_balance_v1';
const String _chipsEarnedTotalV1Key = 'chips_earned_total_v1';
const String _chipsSpentTotalV1Key = 'chips_spent_total_v1';

List<String> _season1CampaignPackIdsV1() {
  return List<String>.generate(
    10,
    (index) => 'world${index + 1}_spine_campaign_v1',
    growable: false,
  );
}

SeasonBadgeV1 _badgeForMasteryV1(WorldMasteryLevelV1? level) {
  switch (level) {
    case WorldMasteryLevelV1.gold:
      return SeasonBadgeV1.gold;
    case WorldMasteryLevelV1.silver:
      return SeasonBadgeV1.silver;
    case WorldMasteryLevelV1.bronze:
      return SeasonBadgeV1.bronze;
    case null:
      return SeasonBadgeV1.none;
  }
}

int _badgeRankV1(SeasonBadgeV1 badge) {
  switch (badge) {
    case SeasonBadgeV1.none:
      return 0;
    case SeasonBadgeV1.bronze:
      return 1;
    case SeasonBadgeV1.silver:
      return 2;
    case SeasonBadgeV1.gold:
      return 3;
  }
}

WorldMasteryLevelV1? _parseWorldMasteryLevelV1(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final normalized = raw.trim().toLowerCase();
  for (final level in WorldMasteryLevelV1.values) {
    if (level.name == normalized) return level;
  }
  return null;
}

List<String> _parseSkillTagsV1(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const <String>[];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <String>[];
    return decoded
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  } catch (_) {
    return const <String>[];
  }
}

Season1SummaryV1 computeSeason1SummaryFromPrefsV1({
  required SharedPreferences prefs,
}) {
  var bestBadge = SeasonBadgeV1.none;
  final skills = <String>{};
  for (final packId in _season1CampaignPackIdsV1()) {
    final masteryRaw = prefs.getString('$_worldMasteryPrefixV1$packId');
    final badge = _badgeForMasteryV1(_parseWorldMasteryLevelV1(masteryRaw));
    if (_badgeRankV1(badge) > _badgeRankV1(bestBadge)) {
      bestBadge = badge;
    }
    final tagsRaw = prefs.getString('$_skillTagsPrefixV1$packId');
    skills.addAll(_parseSkillTagsV1(tagsRaw));
  }
  final topSkills = skills.toList(growable: false)..sort();
  final cappedSkills = topSkills.take(4).toList(growable: false);
  final line = bestBadge == SeasonBadgeV1.none
      ? 'Season 1 progress'
      : 'Season 1 complete';
  return Season1SummaryV1(
    badge: bestBadge,
    topSkills: cappedSkills,
    chipsBalance: prefs.getInt(_chipsBalanceV1Key) ?? 0,
    chipsEarnedTotal: prefs.getInt(_chipsEarnedTotalV1Key) ?? 0,
    chipsSpentTotal: prefs.getInt(_chipsSpentTotalV1Key) ?? 0,
    line: line,
  );
}
