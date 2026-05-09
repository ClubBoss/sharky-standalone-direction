import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/template_storage_service.dart';
import '../services/training_pack_stats_service.dart';
import '../services/xp_history_service.dart';

class TrainingSummaryWidget extends StatefulWidget {
  const TrainingSummaryWidget({
    super.key,
    required this.onAction,
    this.showEmptyState = false,
    this.initialModuleName,
    this.initialLastActivity,
  });

  final VoidCallback onAction;
  final bool showEmptyState;
  final String? initialModuleName;
  final DateTime? initialLastActivity;

  @override
  State<TrainingSummaryWidget> createState() => _TrainingSummaryWidgetState();
}

class _TrainingSummaryWidgetState extends State<TrainingSummaryWidget> {
  String? _moduleName;
  DateTime? _lastXpDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.showEmptyState) {
      _isLoading = false;
      return;
    }
    if (widget.initialModuleName != null ||
        widget.initialLastActivity != null) {
      _moduleName = widget.initialModuleName;
      _lastXpDate = widget.initialLastActivity;
      _isLoading = false;
      return;
    }
    _load();
  }

  Future<void> _load() async {
    final templates = context.read<TemplateStorageService>().templates;
    String? latestModule;
    DateTime? latestPractice;

    final recent = await TrainingPackStatsService.recentlyPractisedTemplates(
      templates,
      days: 60,
    );
    final entries = <MapEntry<TrainingPackStat, String>>[];
    for (final template in recent) {
      final stat = await TrainingPackStatsService.getStats(template.id);
      if (stat != null) entries.add(MapEntry(stat, template.name));
    }
    if (entries.isNotEmpty) {
      entries.sort((a, b) => b.key.last.compareTo(a.key.last));
      latestModule = entries.first.value;
      latestPractice = entries.first.key.last;
    }

    final history = await XpHistoryService().getHistory();
    DateTime? lastXp;
    if (history.isNotEmpty) {
      lastXp = history.last.timestamp;
    }

    if (!mounted) return;
    setState(() {
      _moduleName = latestModule;
      _lastXpDate = lastXp ?? latestPractice;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final strings = _localizedStrings[locale] ?? _localizedStrings['en']!;

    final hasData =
        !_isLoading && !widget.showEmptyState && _moduleName != null;
    final moduleLabel = hasData ? _moduleName! : strings.noTraining;
    final dateLabel = hasData ? _formatDate(context, strings) : strings.never;
    final buttonLabel = hasData ? strings.continueLabel : strings.startLabel;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: _isLoading
            ? const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _summaryRow(strings.latestModule, moduleLabel),
                  const SizedBox(height: 12),
                  _summaryRow(strings.lastActivity, dateLabel),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasData ? widget.onAction : null,
                      child: Text(buttonLabel),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Row(
    children: [
      Expanded(
        flex: 2,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Expanded(
        flex: 3,
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    ],
  );

  String _formatDate(BuildContext context, _LocalizedStrings strings) {
    final date = _lastXpDate;
    if (date == null) return strings.never;
    final format = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return format.format(date);
  }
}

class _LocalizedStrings {
  const _LocalizedStrings({
    required this.title,
    required this.latestModule,
    required this.lastActivity,
    required this.noTraining,
    required this.never,
    required this.continueLabel,
    required this.startLabel,
  });

  final String title;
  final String latestModule;
  final String lastActivity;
  final String noTraining;
  final String never;
  final String continueLabel;
  final String startLabel;
}

const _localizedStrings = <String, _LocalizedStrings>{
  'en': _LocalizedStrings(
    title: 'Training Summary',
    latestModule: 'Latest module',
    lastActivity: 'Last activity',
    noTraining: 'No training yet',
    never: 'Never',
    continueLabel: 'Continue Training',
    startLabel: 'Start Training',
  ),
  'ru': _LocalizedStrings(
    title: 'Сводка по обучению',
    latestModule: 'Последний модуль',
    lastActivity: 'Последняя активность',
    noTraining: 'Пока не начато',
    never: 'Никогда',
    continueLabel: 'Продолжить',
    startLabel: 'Начать тренировку',
  ),
};
