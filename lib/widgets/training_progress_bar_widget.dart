import 'package:flutter/material.dart';

import '../models/training_progress_snapshot.dart';

/// Displays a horizontal progress bar with a textual summary.
class TrainingProgressBarWidget extends StatelessWidget {
  final TrainingProgressSnapshot snapshot;
  final String? label;
  final Color? color;

  const TrainingProgressBarWidget({
    super.key,
    required this.snapshot,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final strings = _localizedStrings[localeCode] ?? _localizedStrings['en']!;
    final scopeLabel = _localizedScopeLabels[snapshot.label]?[localeCode];
    final heading = label ?? scopeLabel ?? strings.progressLabel;
    final progressPercent = (snapshot.asPercentage() * 100)
        .clamp(0, 100)
        .toInt();
    final detailLabel = strings.modulesComplete(
      snapshot.completedModules,
      snapshot.totalModules,
    );
    final isComplete =
        snapshot.totalModules > 0 &&
        snapshot.completedModules >= snapshot.totalModules;
    final barColor =
        color ?? (isComplete ? Colors.green : theme.colorScheme.primary);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    detailLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$progressPercent%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: snapshot.asPercentage().clamp(0, 1),
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalizedStrings {
  final String progressLabel;
  final String Function(int completed, int total) modulesComplete;

  const _LocalizedStrings({
    required this.progressLabel,
    required this.modulesComplete,
  });
}

const _localizedStrings = <String, _LocalizedStrings>{
  'en': _LocalizedStrings(
    progressLabel: 'Training Progress',
    modulesComplete: _modulesCompleteEn,
  ),
  'ru': _LocalizedStrings(
    progressLabel: 'Прогресс обучения',
    modulesComplete: _modulesCompleteRu,
  ),
};

const _localizedScopeLabels = <String, Map<String, String>>{
  'core': {'en': 'Core', 'ru': 'Основы'},
  'cash': {'en': 'Cash', 'ru': 'Кэш'},
  'mtt': {'en': 'MTT', 'ru': 'MTT'},
  'live': {'en': 'Live', 'ru': 'Live'},
  'overall': {'en': 'Training Progress', 'ru': 'Прогресс обучения'},
};

String _modulesCompleteEn(int completed, int total) =>
    '$completed of $total modules complete';

String _modulesCompleteRu(int completed, int total) =>
    '$completed из $total модулей завершено';
