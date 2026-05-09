import 'package:flutter/material.dart';

import '../services/training_roadmap_service.dart';

/// Renders the user's scoped training roadmap progress.
class TrainingRoadmapWidget extends StatelessWidget {
  final List<TrainingRoadmapScope> scopes;

  const TrainingRoadmapWidget({super.key, required this.scopes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final strings = _localizedStrings[locale] ?? _localizedStrings['en']!;
    final scopeByKey = {for (final scope in scopes) scope.scopeKey: scope};

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.heading,
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _scopeOrder.length; i++)
              _ScopeProgressRow(
                strings: strings,
                config: _scopeConfigs[_scopeOrder[i]]!,
                scope:
                    scopeByKey[_scopeOrder[i]] ??
                    const TrainingRoadmapScope(
                      scopeKey: '',
                      modulesCompleted: 0,
                      modulesTotal: 0,
                    ),
                showDivider: i < _scopeOrder.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _ScopeProgressRow extends StatelessWidget {
  final _LocalizedStrings strings;
  final _ScopeConfig config;
  final TrainingRoadmapScope scope;
  final bool showDivider;

  const _ScopeProgressRow({
    required this.strings,
    required this.config,
    required this.scope,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = scope.completionFraction;
    final percent = (ratio * 100).clamp(0, 100).round();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(config.icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.label[strings.localeCode] ??
                        config.label[_fallbackLocale] ??
                        config.label.values.first,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          strings.modulesCompleted(
                            scope.modulesCompleted,
                            scope.modulesTotal,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        config.progressColor ?? theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 16),
          Divider(
            height: 16,
            thickness: 0.6,
            color: theme.dividerColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ScopeConfig {
  final IconData icon;
  final Map<String, String> label;
  final Color? progressColor;

  const _ScopeConfig({required this.icon, required this.label});
}

class _LocalizedStrings {
  final String localeCode;
  final String heading;
  final String Function(int completed, int total) modulesCompleted;

  const _LocalizedStrings({
    required this.localeCode,
    required this.heading,
    required this.modulesCompleted,
  });
}

const _fallbackLocale = 'en';

const List<String> _scopeOrder = [
  'core',
  'cash',
  'mtt',
  'live',
  'math',
  'solver',
];

const Map<String, _ScopeConfig> _scopeConfigs = {
  'core': _ScopeConfig(
    icon: Icons.school_outlined,
    label: {'en': 'Core', 'ru': 'Основы'},
  ),
  'cash': _ScopeConfig(
    icon: Icons.attach_money_outlined,
    label: {'en': 'Cash', 'ru': 'Кэш'},
  ),
  'mtt': _ScopeConfig(
    icon: Icons.emoji_events_outlined,
    label: {'en': 'MTT', 'ru': 'MTT'},
  ),
  'live': _ScopeConfig(
    icon: Icons.people_alt_outlined,
    label: {'en': 'Live', 'ru': 'Live'},
  ),
  'math': _ScopeConfig(
    icon: Icons.calculate_outlined,
    label: {'en': 'Math', 'ru': 'Математика'},
  ),
  'solver': _ScopeConfig(
    icon: Icons.memory_outlined,
    label: {'en': 'Solver', 'ru': 'Солвер'},
  ),
};

const Map<String, _LocalizedStrings> _localizedStrings = {
  'en': _LocalizedStrings(
    localeCode: 'en',
    heading: 'Training Roadmap',
    modulesCompleted: _enModulesCompleted,
  ),
  'ru': _LocalizedStrings(
    localeCode: 'ru',
    heading: 'Дорожная карта обучения',
    modulesCompleted: _ruModulesCompleted,
  ),
};

String _enModulesCompleted(int completed, int total) =>
    '$completed of $total modules';

String _ruModulesCompleted(int completed, int total) =>
    '$completed из $total модулей';
