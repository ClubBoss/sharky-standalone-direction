class SmartPackRecommenderV1 {
  const SmartPackRecommenderV1();

  Map<String, Object> buildRecommendations(
    Map<String, Object?> personaSignals,
    Map<String, Object?> coachingSurface,
    Map<String, Object?> rpgFusion,
    Map<String, Object?> xpRewardSurface,
    Map<String, Object?> marketingAnalytics,
  ) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    Map<String, Object> _clean(Map<String, Object?> input) {
      final entries = input.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final out = <String, Object>{};
      for (final entry in entries) {
        final key = entry.key.toString();
        if (!_isAscii(key)) continue;
        final v = entry.value;
        if (v is String) {
          if (_isAscii(v)) out[key] = v;
        } else if (v is num || v is bool) {
          out[key] = v as Object;
        }
      }
      return out;
    }

    final drivers = <String>[];
    final conflicts = <String>[];
    final recommendations = <String>[];

    if (personaSignals.isNotEmpty && coachingSurface.isNotEmpty) {
      recommendations.add('persona_coaching_pack');
      drivers.add('persona_coaching');
    } else {
      conflicts.add('missing_persona_coaching');
    }
    if (rpgFusion.isNotEmpty && xpRewardSurface.isNotEmpty) {
      recommendations.add('rpg_reward_pack');
      drivers.add('rpg_reward');
    } else {
      conflicts.add('missing_rpg_reward');
    }
    if ((marketingAnalytics['analytics_ok'] == true) &&
        marketingAnalytics.isNotEmpty) {
      recommendations.add('marketing_alignment_pack');
      drivers.add('marketing_ok');
    } else {
      conflicts.add('marketing_alignment');
    }

    recommendations.sort();
    drivers.sort();
    conflicts.sort();

    final ok = conflicts.isEmpty;

    return <String, Object>{
      'recommended_packs': List<String>.unmodifiable(recommendations),
      'drivers': List<String>.unmodifiable(drivers),
      'conflicts': List<String>.unmodifiable(conflicts),
      'ok': ok,
      'persona': _clean(personaSignals),
      'coaching': _clean(coachingSurface),
      'rpg': _clean(rpgFusion),
      'xp_reward': _clean(xpRewardSurface),
      'marketing': _clean(marketingAnalytics),
    };
  }
}
