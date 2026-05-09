import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/training_streak_service.dart';

class TrainingStreakCard extends StatelessWidget {
  const TrainingStreakCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<int>(
    future: TrainingStreakService().getCurrentStreak(),
    builder: (context, snapshot) {
      if (!snapshot.hasData || snapshot.data == 0) {
        return const SizedBox.shrink(); // Auto-hide if streak is 0
      }

      final streak = snapshot.data!;
      final streakText = Intl.message(
        "You’ve trained $streak days in a row",
        name: "streakText",
        args: [streak],
        examples: const {"streak": 5},
      );

      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text("🔥", style: TextStyle(fontSize: 32.0)),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  streakText,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
