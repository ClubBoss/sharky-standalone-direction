import 'package:flutter/material.dart';

import '../models/challenge_definition.dart';
import '../services/challenge_service.dart';

class ChallengeCardWidget extends StatelessWidget {
  final String label;
  final ChallengeInstance instance;
  final VoidCallback? onTap;

  const ChallengeCardWidget({
    super.key,
    required this.label,
    required this.instance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final def = instance.definition;
    final completed = instance.completed;
    final percent = instance.progressRatio;
    final rewardLabel = '+${def.rewardXp} XP';
    final progressLabel =
        '${instance.progress}/${def.goal} ${_metricLabel(def.metric)}'.trim();
    final timeLeft = _formatTimeLeft(instance.timeLeft);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle
                        : _iconFor(def.duration, def.metric),
                    color: completed ? Colors.green : Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    timeLeft,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                def.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                def.description,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  completed ? Colors.green : Colors.amber[600]!,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progressLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(percent * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rewardLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              if (completed) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _metricLabel(ChallengeMetric metric) {
    switch (metric) {
      case ChallengeMetric.xp:
        return 'XP';
      case ChallengeMetric.hands:
        return 'hands';
      case ChallengeMetric.mistakes:
        return 'mistakes';
    }
  }

  IconData _iconFor(ChallengeDuration duration, ChallengeMetric metric) {
    switch (duration) {
      case ChallengeDuration.daily:
        return metric == ChallengeMetric.xp ? Icons.bolt : Icons.calendar_today;
      case ChallengeDuration.weekly:
        return Icons.flag;
    }
  }

  String _formatTimeLeft(Duration duration) {
    if (duration <= Duration.zero) return '0h';
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    if (days > 0) {
      return '${days}d ${hours}h';
    }
    final totalHours = duration.inHours;
    if (totalHours > 0) {
      return '${totalHours}h';
    }
    final minutes = duration.inMinutes.clamp(0, 59);
    return '${minutes}m';
  }
}
