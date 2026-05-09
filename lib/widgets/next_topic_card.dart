import 'package:flutter/material.dart';
import '../services/next_topic_planner_service.dart';
import '../services/skill_unlock_service.dart';
import '../services/review_launcher_service.dart';

class NextTopicCard extends StatelessWidget {
  const NextTopicCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<PlannedTopic?>(
    future: NextTopicPlannerService.instance.getNextTopic(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data == null) {
        return const SizedBox.shrink();
      }

      final plannedTopic = snapshot.data!;
      final isUnlocked = SkillUnlockService.instance.isUnlocked(
        plannedTopic.topicId,
      );

      String motivationalSubtitle = '';
      if (plannedTopic.streakDaysRequired != null) {
        motivationalSubtitle =
            Localizations.localeOf(context).languageCode == 'ru'
            ? 'Поддерживайте свою серию из ${plannedTopic.streakDaysRequired} дней!'
            : 'Maintain your ${plannedTopic.streakDaysRequired}-day streak!';
      } else if (plannedTopic.minAccuracyRequired != null) {
        motivationalSubtitle =
            Localizations.localeOf(context).languageCode == 'ru'
            ? 'Улучшите точность до ${plannedTopic.minAccuracyRequired! * 100}%'
            : 'Improve to ${plannedTopic.minAccuracyRequired! * 100}% accuracy';
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plannedTopic.labelEn,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                _getReasonText(context, plannedTopic.reasonTag),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (motivationalSubtitle.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  motivationalSubtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blueAccent),
                ),
              ],
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: isUnlocked
                    ? () {
                        ReviewLauncherService.instance.launch(
                          plannedTopic.topicId,
                        );
                      }
                    : null,
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ru'
                      ? 'Начать тренировку'
                      : 'Train Now',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  String _getReasonText(BuildContext context, String reasonTag) {
    final locale = Localizations.localeOf(context);
    switch (reasonTag) {
      case 'mistakes':
        return locale.languageCode == 'ru'
            ? 'Требует практики'
            : 'Needs practice';
      case 'low_accuracy':
        return locale.languageCode == 'ru' ? 'Низкая точность' : 'Low accuracy';
      case 'new_unlock':
        return locale.languageCode == 'ru' ? 'Новая тема' : 'Newly unlocked';
      case 'fresh':
        return locale.languageCode == 'ru' ? 'Свежая тема' : 'Fresh topic';
      case 'fallback':
        return locale.languageCode == 'ru'
            ? 'Резервная тема'
            : 'Fallback topic';
      default:
        return locale.languageCode == 'ru'
            ? 'Неизвестная причина'
            : 'Unknown reason';
    }
  }
}
