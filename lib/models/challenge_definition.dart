import 'package:flutter/foundation.dart';

enum ChallengeDuration { daily, weekly }

enum ChallengeMetric { xp, hands, mistakes }

@immutable
class ChallengeDefinition {
  final String id;
  final String title;
  final String description;
  final ChallengeMetric metric;
  final int goal;
  final int rewardXp;
  final ChallengeDuration duration;

  const ChallengeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.goal,
    required this.rewardXp,
    required this.duration,
  });
}
