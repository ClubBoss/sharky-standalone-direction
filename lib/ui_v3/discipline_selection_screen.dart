import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/user_path_profile.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

/// Hybrid discipline selector combining intro context, manual choice,
/// and lightweight recommendation quiz (Stage Φ2).
class DisciplineSelectionScreen extends StatefulWidget {
  static const String routeName = '/v3/discipline-selection';

  const DisciplineSelectionScreen({super.key});

  @override
  State<DisciplineSelectionScreen> createState() =>
      _DisciplineSelectionScreenState();
}

class _DisciplineSelectionScreenState extends State<DisciplineSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDiscipline;
  UserPathProfile? _currentProfile;

  static const _cards = <_DisciplineCardData>[
    _DisciplineCardData(
      title: 'Cash Games',
      description:
          'Deep stacks, steady decisions, and precise bankroll control for predictable gains.',
    ),
    _DisciplineCardData(
      title: 'MTT Tournaments',
      description:
          'Dynamic stack depths, ICM pressure, and aggressive bursts to chase ladder jumps.',
    ),
    _DisciplineCardData(
      title: 'Live Events',
      description:
          'Patience-driven reads, table presence, and long session focus to exploit live edges.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = VisualThemeV3.theme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Choose Discipline')),
        body: AnimatedSwitcher(
          duration: VisualThemeV3.speedNormal,
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(VisualThemeV3.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(VisualThemeV3.spacingM),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
            ),
            child: Text(
              'Learn the differences before choosing.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: VisualThemeV3.spacingM),
          Expanded(
            child: ListView.separated(
              itemCount: _cards.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: VisualThemeV3.spacingM),
              itemBuilder: (context, index) {
                final card = _cards[index];
                final isSelected = _selectedDiscipline == card.title;
                return _DisciplineCard(
                  data: card,
                  selected: isSelected,
                  onTap: () => _handleManualSelection(card.title),
                );
              },
            ),
          ),
          const SizedBox(height: VisualThemeV3.spacingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showRecommendationDialog,
                  child: const Text('Not sure -> Take Test'),
                ),
              ),
              const SizedBox(width: VisualThemeV3.spacingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedDiscipline == null
                      ? null
                      : () => _startTraining(context),
                  child: const Text('Start Training'),
                ),
              ),
            ],
          ),
          if (_currentProfile != null)
            Padding(
              padding: const EdgeInsets.only(top: VisualThemeV3.spacingM),
              child: Text(
                'Saved path: ${_currentProfile!.discipline} '
                '(${_currentProfile!.isRecommended ? 'Recommended' : 'Manual'})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  void _handleManualSelection(String discipline) {
    setState(() {
      _selectedDiscipline = discipline;
    });
    _saveProfile(discipline, false);
  }

  Future<void> _showRecommendationDialog() async {
    final answers = await showDialog<_QuizResult>(
      context: context,
      builder: (context) =>
          _RecommendationDialog(initial: _QuizResult.initial()),
    );
    if (answers == null) {
      return;
    }
    final discipline = _computeRecommendation(answers);
    setState(() {
      _selectedDiscipline = discipline;
    });
    _saveProfile(discipline, true);
  }

  void _saveProfile(String discipline, bool isRecommended) {
    final profile = UserPathProfile(
      discipline: discipline,
      isRecommended: isRecommended,
      timestamp: DateTime.now(),
    );
    setState(() {
      _currentProfile = profile;
    });
    FirebaseLiteTelemetryService.instance.logEvent(
      'discipline_selected',
      params: {
        'discipline': discipline,
        'is_recommended': isRecommended,
        'timestamp': profile.timestamp.toIso8601String(),
      },
    );
  }

  void _startTraining(BuildContext context) {
    final discipline = _selectedDiscipline;
    if (discipline == null) {
      return;
    }
    // Placeholder for Stage Φ3 route integration.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Loading training for $discipline...')),
    );
  }

  String _computeRecommendation(_QuizResult result) {
    final aggression = result.aggression;
    final risk = result.risk;
    final patience = result.patience;
    if (aggression >= risk && aggression >= patience) {
      return 'Cash Games';
    }
    if (risk >= aggression && risk >= patience) {
      return 'MTT Tournaments';
    }
    return 'Live Events';
  }
}

class _DisciplineCard extends StatelessWidget {
  const _DisciplineCard({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _DisciplineCardData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: VisualThemeV3.speedNormal,
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: VisualThemeV3.spacingS),
            Text(
              data.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisciplineCardData {
  const _DisciplineCardData({required this.title, required this.description});

  final String title;
  final String description;
}

class _RecommendationDialog extends StatefulWidget {
  const _RecommendationDialog({required this.initial});

  final _QuizResult initial;

  @override
  State<_RecommendationDialog> createState() => _RecommendationDialogState();
}

class _RecommendationDialogState extends State<_RecommendationDialog> {
  late _QuizResult _result;

  @override
  void initState() {
    super.initState();
    _result = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Discipline Test'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestion(
              label: 'How aggressive is your style?',
              value: _result.aggression,
              onChanged: (value) =>
                  _update(result: _result.copyWith(aggression: value)),
            ),
            _buildQuestion(
              label: 'How much risk can you tolerate?',
              value: _result.risk,
              onChanged: (value) =>
                  _update(result: _result.copyWith(risk: value)),
            ),
            _buildQuestion(
              label: 'How patient are you during long sessions?',
              value: _result.patience,
              onChanged: (value) =>
                  _update(result: _result.copyWith(patience: value)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_result),
          child: const Text('Show Recommendation'),
        ),
      ],
    );
  }

  Widget _buildQuestion({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VisualThemeV3.spacingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Slider(
            value: value,
            onChanged: onChanged,
            min: 0,
            max: 1,
            divisions: 10,
            label: value.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  void _update({_QuizResult? result}) {
    if (result == null) {
      return;
    }
    setState(() {
      _result = result;
    });
  }
}

class _QuizResult {
  const _QuizResult({
    required this.aggression,
    required this.risk,
    required this.patience,
  });

  factory _QuizResult.initial() =>
      const _QuizResult(aggression: 0.5, risk: 0.5, patience: 0.5);

  final double aggression;
  final double risk;
  final double patience;

  _QuizResult copyWith({double? aggression, double? risk, double? patience}) {
    return _QuizResult(
      aggression: aggression ?? this.aggression,
      risk: risk ?? this.risk,
      patience: patience ?? this.patience,
    );
  }
}
