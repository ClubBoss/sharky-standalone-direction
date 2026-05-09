import 'package:flutter/material.dart';
import '../services/topic_progress_service.dart';
import '../services/content_module_loader_service.dart';

class TopicProgressCard extends StatelessWidget {
  final String topicId;

  const TopicProgressCard({Key? key, required this.topicId}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<TopicProgress>(
    future: TopicProgressService.instance.getTopicProgress(topicId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return _buildFallback(context);
      }

      final progress = snapshot.data!;
      final seenCount = progress.seenCount;
      final correctCount = progress.correctCount;
      final streak = progress.streak;
      final lastUpdated = progress.lastUpdated;
      final accuracy = seenCount > 0 ? correctCount / seenCount : 0.0;

      return FutureBuilder<String>(
        future: ContentModuleLoaderService.instance.getModuleTitle(topicId),
        builder: (context, titleSnapshot) {
          final title = titleSnapshot.data ?? 'Unknown Module';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8.0),
                  LinearProgressIndicator(
                    value: accuracy,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      accuracy >= 0.8
                          ? Colors.green
                          : accuracy >= 0.5
                          ? Colors.yellow
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _buildSubtitle(context, seenCount, lastUpdated, streak),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  Widget _buildFallback(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final fallbackText = locale.languageCode == 'ru'
        ? 'Прогресс отсутствует'
        : 'No progress yet';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            fallbackText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(
    BuildContext context,
    int seenCount,
    DateTime lastUpdated,
    int streak,
  ) {
    final locale = Localizations.localeOf(context);
    final drillsText = locale.languageCode == 'ru'
        ? '$seenCount упражнений пройдено'
        : '$seenCount drills completed';

    final daysAgo = DateTime.now().difference(lastUpdated).inDays;
    final lastTrainedText = locale.languageCode == 'ru'
        ? 'Последняя тренировка: $daysAgoд назад'
        : 'Last trained: ${daysAgo}d ago';

    final streakEmoji = streak >= 3 ? ' 🔥' : '';

    return '$drillsText\n$lastTrainedText$streakEmoji';
  }
}
