import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/weekly_loop_service.dart';

class WeeklyLoopCard extends StatelessWidget {
  final Locale locale;

  const WeeklyLoopCard({Key? key, required this.locale}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<int>(
    future: WeeklyLoopService.instance.getCompletionsCountThisWeek(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data == 0) {
        return const SizedBox.shrink();
      }

      final count = snapshot.data!;
      final String title = locale.languageCode == 'ru'
          ? 'Прогресс за неделю'
          : 'Weekly Loop Progress';
      final String subtitle = locale.languageCode == 'ru'
          ? 'Завершено циклов: $count'
          : 'Loops completed: $count';

      String medal = '⬜';
      if (count >= 3) {
        medal = '🥇';
      } else if (count == 2) {
        medal = '🥈';
      } else if (count == 1) {
        medal = '🥉';
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8.0),
                  Text(medal, style: const TextStyle(fontSize: 24.0)),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
