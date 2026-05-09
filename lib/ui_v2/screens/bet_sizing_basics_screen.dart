import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';

class BetSizingBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const BetSizingBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<BetSizingBasicsScenarioScreen> createState() =>
      _BetSizingBasicsScenarioScreenState();
}

class _BetSizingBasicsScenarioScreenState
    extends State<BetSizingBasicsScenarioScreen> {
  static const double _basePotBb = 4.0;

  double _potBb = _basePotBb;
  bool _halfPotBetPlaced = false;
  bool _potBetPlaced = false;
  bool _isCompleting = false;
  bool _halfPotSuccessPulseShown = false;

  final String _halfPotQuestion =
      'If the pot is 4 BB and you bet half-pot, how much do you bet?';
  final List<String> _halfPotChoices = const ['1 BB', '2 BB', '3 BB'];
  final String _halfPotCorrectAnswer = '2 BB';
  String? _halfPotSelectedChoice;
  bool _halfPotCorrect = false;
  String _halfPotFeedback = '';

  final String _potBetQuestion =
      'If the pot is 4 BB and you bet pot, how much does the pot increase immediately?';
  final List<String> _potBetChoices = const ['+2 BB', '+3 BB', '+4 BB'];
  final String _potBetCorrectAnswer = '+4 BB';
  String? _potBetSelectedChoice;
  bool _potBetCorrect = false;
  String _potBetFeedback = '';

  void _applyHalfPotBet() {
    if (_halfPotBetPlaced) return;
    setState(() {
      _halfPotBetPlaced = true;
      _potBb = _basePotBb + 2.0;
    });
  }

  void _resetForPotBet() {
    setState(() {
      _potBetPlaced = false;
      _potBb = _basePotBb;
    });
  }

  void _applyPotBet() {
    if (_potBetPlaced) return;
    setState(() {
      _potBetPlaced = true;
      _potBb = _basePotBb + 4.0;
    });
  }

  void _resetHalfPotGate() {
    setState(() {
      _halfPotSelectedChoice = null;
      _halfPotCorrect = false;
      _halfPotFeedback = '';
      _halfPotSuccessPulseShown = false;
    });
  }

  void _selectHalfPotChoice(String choice) {
    setState(() {
      _halfPotSelectedChoice = choice;
      _halfPotCorrect = choice == _halfPotCorrectAnswer;
      _halfPotFeedback = _halfPotCorrect
          ? 'Correct · Half-pot is 2 BB on a 4 BB pot.'
          : 'Try again · half-pot is 2 BB here.';
    });
  }

  void _selectPotBetChoice(String choice) {
    setState(() {
      _potBetSelectedChoice = choice;
      _potBetCorrect = choice == _potBetCorrectAnswer;
      _potBetFeedback = _potBetCorrect
          ? 'Correct · Pot bet adds +4 BB immediately.'
          : 'Try again · pot bet equals the pot and adds +4 BB.';
    });
  }

  Future<void> _completeScenario() async {
    setState(() {
      _isCompleting = true;
    });
    await ProgressService.markModuleCompleted(widget.moduleId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _resetScenarioState() {
    setState(() {
      _potBb = _basePotBb;
      _halfPotBetPlaced = false;
      _potBetPlaced = false;
      _halfPotSelectedChoice = null;
      _halfPotCorrect = false;
      _halfPotFeedback = '';
      _potBetSelectedChoice = null;
      _potBetCorrect = false;
      _potBetFeedback = '';
      _halfPotSuccessPulseShown = false;
      _isCompleting = false;
    });
  }

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'The pot sits at 4 BB before you size a bet.',
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('Pot: ', style: LessonTypography.subtitle(context)),
            LessonNumericText(
              '$_basePotBb BB',
              style: LessonTypography.subtitle(context),
            ),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        Text(
          'Watch how half-pot and pot bets grow the total immediately.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'See the half-pot bet',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Half-Pot',
      title: 'Half-pot bet adds exactly 2 BB.',
      timeHintMs: 4000,
      onTimeHintExpired: _applyHalfPotBet,
      bodyBuilder: (context, controller) {
        return [
          Row(
            children: [
              Text('Pot now: ', style: LessonTypography.subtitle(context)),
              LessonNumericText(
                '${_potBb.toStringAsFixed(1)} BB',
                style: LessonTypography.subtitle(context),
              ),
            ],
          ),
          const SizedBox(height: lessonSpacingMedium),
          Text(
            'Tap to bet 2 BB and see the chips join the pot.',
            style: LessonTypography.body(context),
          ),
          const SizedBox(height: lessonSpacingMedium),
          LessonActionButton(
            label: _halfPotBetPlaced ? 'Bet confirmed' : 'Bet 2 BB',
            enabled: !_halfPotBetPlaced,
            helperText: !_halfPotBetPlaced
                ? 'Half-pot is 2 BB on a 4 BB pot.'
                : 'Pot shows ${_potBb.toStringAsFixed(1)} BB.',
            onPressed: _applyHalfPotBet,
          ),
          if (_halfPotBetPlaced) ...[
            const SizedBox(height: lessonSpacingMedium),
            LessonActionButton(
              label: 'Continue',
              onPressed: controller.advance,
            ),
          ],
        ];
      },
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: 'What does half-pot equal here?',
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Half-pot means bet = pot / 2.',
      ),
      countsAsGate: true,
      onEnter: _resetHalfPotGate,
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('Pot: ', style: LessonTypography.subtitle(context)),
            LessonNumericText(
              '$_basePotBb BB',
              style: LessonTypography.subtitle(context),
            ),
          ],
        ),
        const SizedBox(height: lessonSpacingSmall),
        Text(_halfPotQuestion, style: LessonTypography.body(context)),
        const SizedBox(height: lessonSpacingSmall),
        ..._halfPotChoices.map((choice) {
          final isSelected = _halfPotSelectedChoice == choice;
          return Padding(
            padding: const EdgeInsets.only(bottom: lessonSpacingSmall),
            child: OutlinedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.white.withOpacity(0.08)
                    : null,
                foregroundColor: isSelected ? Colors.white : null,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                _selectHalfPotChoice(choice);
                if (!_halfPotCorrect) {
                  controller.registerWrongAnswerHint();
                  return;
                }
                controller.clearWrongAnswerHint();
                if (_halfPotCorrect && !_halfPotSuccessPulseShown) {
                  _halfPotSuccessPulseShown = true;
                  controller.showSuccessFeedback();
                }
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }).toList(),
        if (_halfPotFeedback.isNotEmpty) ...[
          Text(
            _halfPotFeedback,
            style: LessonTypography.helper(context).copyWith(
              color: _halfPotCorrect ? Colors.greenAccent : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: lessonSpacingMedium),
        ],
        if (_halfPotCorrect)
          LessonActionButton(label: 'Continue', onPressed: controller.advance),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Pot Bet',
      title: 'Pot bet adds 4 BB to the pot.',
      onEnter: _resetForPotBet,
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('Pot now: ', style: LessonTypography.subtitle(context)),
            LessonNumericText(
              '${_potBb.toStringAsFixed(1)} BB',
              style: LessonTypography.subtitle(context),
            ),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        Text(
          'Tap to bet 4 BB and watch the pot jump again.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: _potBetPlaced ? 'Bet confirmed' : 'Bet 4 BB',
          enabled: !_potBetPlaced,
          helperText: !_potBetPlaced
              ? 'Pot bet equals the current pot.'
              : 'Pot shows ${_potBb.toStringAsFixed(1)} BB.',
          onPressed: _applyPotBet,
        ),
        if (_potBetPlaced) ...[
          const SizedBox(height: lessonSpacingMedium),
          LessonActionButton(label: 'Continue', onPressed: controller.advance),
        ],
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: 'What happens after a pot bet?',
      gateEngagementConfig: const GateEngagementConfig(comboEligible: true),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('Pot: ', style: LessonTypography.subtitle(context)),
            LessonNumericText(
              '$_basePotBb BB',
              style: LessonTypography.subtitle(context),
            ),
          ],
        ),
        const SizedBox(height: lessonSpacingSmall),
        Text(_potBetQuestion, style: LessonTypography.body(context)),
        const SizedBox(height: lessonSpacingSmall),
        ..._potBetChoices.map((choice) {
          final isSelected = _potBetSelectedChoice == choice;
          return Padding(
            padding: const EdgeInsets.only(bottom: lessonSpacingSmall),
            child: OutlinedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.white.withOpacity(0.08)
                    : null,
                foregroundColor: isSelected ? Colors.white : null,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _selectPotBetChoice(choice),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }).toList(),
        if (_potBetFeedback.isNotEmpty) ...[
          Text(
            _potBetFeedback,
            style: LessonTypography.helper(context).copyWith(
              color: _potBetCorrect ? Colors.greenAccent : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: lessonSpacingMedium),
        ],
        if (_potBetCorrect)
          LessonActionButton(label: 'Continue', onPressed: controller.advance),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Compare',
      title: 'Half-pot vs pot bet',
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('Half-pot adds ', style: LessonTypography.body(context)),
            LessonNumericText('2 BB', style: LessonTypography.body(context)),
            Text(' while pot adds ', style: LessonTypography.body(context)),
            LessonNumericText('4 BB', style: LessonTypography.body(context)),
            Text('.', style: LessonTypography.body(context)),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Explain the difference',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'You feel how bets grow the pot immediately.',
      showSessionSummary: true,
      showRewardPing: true,
      completionActions: CompletionActions(
        showReplay: true,
        showNext: _nextModuleId != null,
        onReplay: _resetScenarioState,
        onNext: _nextModuleId != null ? _goToNextLesson : null,
      ),
      bodyBuilder: (_, __) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: _isCompleting ? 'Wrapping up…' : 'Finish',
          onPressed: _isCompleting ? null : _completeScenario,
        ),
      ],
    ),
  ];

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'Half-pot', color: Color(0xFF4DB0FF)),
      _LegendChip(label: 'Pot bet', color: Color(0xFFFFB74D)),
    ];
  }

  Widget _chipBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildTableArea() {
    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Table Pot', style: LessonTypography.subtitle(context)),
                const SizedBox(height: lessonSpacingSmall),
                LessonNumericText(
                  '${_potBb.toStringAsFixed(1)} BB',
                  style: LessonTypography.title(context),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 72,
            child: LessonChipMoveTransition(
              active: _halfPotBetPlaced,
              child: _chipBadge('2 BB half-pot', const Color(0xFF4DB0FF)),
            ),
          ),
          Positioned(
            bottom: 34,
            child: LessonChipMoveTransition(
              active: _potBetPlaced,
              hiddenOffset: const Offset(0, 0.45),
              child: _chipBadge('4 BB pot bet', const Color(0xFFFFB74D)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: LessonStepSequence(
          steps: _steps,
          legendChips: _legendChips(),
          tableArea: _buildTableArea(),
          lessonModuleId: widget.moduleId,
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final style =
        Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ) ??
        TextStyle(fontWeight: FontWeight.w600, color: color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: style),
    );
  }
}
