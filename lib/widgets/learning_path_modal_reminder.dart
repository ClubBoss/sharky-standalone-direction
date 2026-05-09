import 'package:flutter/material.dart';
import '../screens/learning_path_overview_screen.dart';

class LearningPathModalReminder extends StatelessWidget {
  const LearningPathModalReminder({super.key});

  static Future<void> show(BuildContext context) => showDialog(
    context: context,
    builder: (_) => const LearningPathModalReminder(),
  );

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.school, color: accent, size: 28),
          const SizedBox(width: 8),
          const Text('Продолжим обучение?'),
        ],
      ),
      content: const Text(
        'Ты можешь прокачать свои навыки уже сейчас. Дорога к мастерству ждёт тебя 💡',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Позже'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LearningPathOverviewScreen()),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: accent),
          child: const Text('Начать тренировку'),
        ),
      ],
    );
  }
}
