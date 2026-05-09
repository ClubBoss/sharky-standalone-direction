import 'package:flutter/material.dart';
import '../services/review_checkpoint_service.dart';
import '../services/review_launcher_service.dart';

class ReviewCheckpointCard extends StatelessWidget {
  const ReviewCheckpointCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: ReviewCheckpointService.instance.shouldShowCheckpoint(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!) {
        return const SizedBox.shrink();
      }

      return FutureBuilder<List<String>>(
        future: ReviewCheckpointService.instance.getReviewCheckpointTopics(),
        builder: (context, topicSnapshot) {
          if (!topicSnapshot.hasData || topicSnapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final topics = topicSnapshot.data!;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'Повторение блока'
                        : 'Review Checkpoint',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ru'
                        ? 'Давайте повторим 3 темы, которые вы могли забыть'
                        : 'Let’s revisit 3 topics you may be forgetting',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      ReviewLauncherService.instance.launch(topics);
                      ReviewCheckpointService.instance.markCheckpointReviewed();
                    },
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ru'
                          ? 'Начать повторение'
                          : 'Start Review',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
