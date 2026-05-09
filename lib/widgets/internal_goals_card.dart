import 'package:flutter/material.dart';
import '../models/internal_goal.dart';
import '../services/internal_goals_service.dart';

/// Displays active internal goals (max 3) with progress bars.
class InternalGoalsCard extends StatelessWidget {
  const InternalGoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final headingLabel = isRu ? 'Текущие цели' : 'Current Goals';

    return ValueListenableBuilder<List<InternalGoal>>(
      valueListenable: InternalGoalsService.instance.goalsNotifier,
      builder: (context, goals, _) {
        if (goals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headingLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...goals.map((goal) => _buildGoalItem(goal, isRu)),
          ],
        );
      },
    );
  }

  /// Build a single goal item with progress bar.
  Widget _buildGoalItem(InternalGoal goal, bool isRu) {
    final title = goal.title(isRu: isRu);
    final progressText = '${goal.progress}/${goal.target}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: goal.completed
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: goal.completed
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.blue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: goal.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (goal.completed)
                  Icon(Icons.check_circle, color: Colors.green[700], size: 18)
                else
                  Text(
                    progressText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
            if (!goal.completed) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.progressPercent,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
