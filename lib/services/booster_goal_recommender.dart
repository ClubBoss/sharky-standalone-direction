import '../models/booster_stats.dart';
import '../models/weak_theory_tag.dart';
import '../models/player_profile.dart';
import '../models/training_goal.dart';

/// Generates simple short-term goals from booster stats and weaknesses.
class BoosterGoalRecommender {
  BoosterGoalRecommender();

  /// Returns up to two training goals based on [stats], [weakTags] and [profile].
  List<TrainingGoal> recommend({
    required BoosterStats stats,
    required List<WeakTheoryTag> weakTags,
    required PlayerProfile profile,
  }) {
    final goals = <TrainingGoal>[];

    // Goal 1: encourage booster streaks.
    if (stats.streak < 5) {
      goals.add(
        const TrainingGoal(
          '🔥 Достигни серии из 5 дней',
          description: 'Играйте хотя бы один бустер каждый день',
          tag: 'boosterStreak',
        ),
      );
    }

    // Goal 2: focus on weakest tag or most played tag.
    String? focusTag;
    if (weakTags.isNotEmpty) {
      focusTag = weakTags.first.tag;
    } else if (stats.counts.isNotEmpty) {
      final entries = stats.counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      focusTag = entries.first.key;
    }

    if (focusTag != null) {
      final completed = stats.counts[focusTag] ?? 0;
      final target = completed + 2;
      goals.add(
        TrainingGoal(
          '🎯 Заверши $target бустера по $focusTag',
          description: 'Текущий прогресс: $completed из $target',
          tag: focusTag,
        ),
      );
    }

    // Additional goal: review tags with low accuracy.
    if (goals.length < 2) {
      final lowAcc = profile.tagAccuracy.entries
          .where((e) => e.value < 0.7)
          .map((e) => e.key)
          .toList();
      if (lowAcc.isNotEmpty) {
        final list = lowAcc.take(3).join(', ');
        goals.add(
          TrainingGoal(
            '📚 Повтори теги: $list',
            description: 'Отработай бустеры по слабым тегам',
            tag: lowAcc.first,
          ),
        );
      }
    }

    return goals.take(2).toList();
  }
}
