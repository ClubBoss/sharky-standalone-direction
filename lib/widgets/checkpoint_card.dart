import 'package:flutter/material.dart';
import '../services/checkpoint_service.dart';
import '../services/review_launcher_service.dart';

class CheckpointCard extends StatelessWidget {
  const CheckpointCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<CheckpointEntry?>(
    future: CheckpointService.instance.getEligibleCheckpoint(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data == null) {
        return const SizedBox.shrink();
      }

      final checkpoint = snapshot.data!;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'ru'
                    ? 'Контрольная точка'
                    : 'Checkpoint Available',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                checkpoint.subtitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  ReviewLauncherService.instance.launch(checkpoint.topics);
                  CheckpointService.instance.markCheckpointCompleted(
                    checkpoint.id,
                  );
                },
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ru'
                      ? 'Начать контрольную'
                      : 'Start Checkpoint',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
