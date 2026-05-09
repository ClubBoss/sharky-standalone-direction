import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverValueVsBluffScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverValueVsBluffScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverValueVsBluffScenarioScreen> createState() =>
      _RiverValueVsBluffScenarioScreenState();
}

class _RiverValueVsBluffScenarioScreenState
    extends State<RiverValueVsBluffScenarioScreen> {
  static const _gate1Question =
      'You missed draws but still have strong top pair – what is your default?';
  static const _gate2Question =
      'With weak showdown value after missed draws, what do you choose?';
  static const _valueChoices = ['Value bet strong', 'Check back', 'Fold'];
  static const _bluffChoices = [
    'Bluff selectively',
    'Bet big polarized',
    'Check and concede',
  ];

  bool _gate1Correct = false;
  bool _gate2Correct = false;
  bool _gate1SuccessPulseShown = false;
  bool _gate2SuccessPulseShown = false;
  String? _gate1Choice;
  String? _gate2Choice;
  bool _isCompleting = false;

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
      _gate1Correct = false;
      _gate2Correct = false;
      _gate1SuccessPulseShown = false;
      _gate2SuccessPulseShown = false;
      _gate1Choice = null;
      _gate2Choice = null;
      _isCompleting = false;
    });
  }

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  void _selectGateChoice(
    String choice,
    LessonStepController controller, {
    required bool isValueQuestion,
  }) {
    final correct = isValueQuestion
        ? choice == 'Value bet strong'
        : choice == 'Bluff selectively';
    setState(() {
      if (isValueQuestion) {
        _gate1Choice = choice;
        _gate1Correct = correct;
      } else {
        _gate2Choice = choice;
        _gate2Correct = correct;
      }
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    if (isValueQuestion && !_gate1SuccessPulseShown) {
      _gate1SuccessPulseShown = true;
      controller.showSuccessFeedback();
    }
    if (!isValueQuestion && !_gate2SuccessPulseShown) {
      _gate2SuccessPulseShown = true;
      controller.showSuccessFeedback();
    }
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'River decisions lock in storylines.',
      bodyBuilder: (context, controller) => [
        Text(
          'The river is where you pick between thin value and subtle bluffs depending on what you’ve shown.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonNumericText(
          'Last round: dry turn barrel & opponent called.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Lay the river plan',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Value',
      title: 'Value bet when you still own the nuts.',
      bodyBuilder: (context, controller) => [
        Text(
          'You want value when your top pair has no blockers to worry about.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Lean into the value bet',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate1Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Target thin floats when you still have the strongest hand.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._valueChoices.map((choice) {
          final isSelected = _gate1Choice == choice;
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
              onPressed: () =>
                  _selectGateChoice(choice, controller, isValueQuestion: true),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_gate1Correct)
          LessonActionButton(label: 'Continue', onPressed: controller.advance),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Bluff',
      title: 'Bluff when your showdown is weak.',
      bodyBuilder: (context, controller) => [
        Text(
          'Missed draws can still bluff if the story tells a strong hand.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Paint the bluff line',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate2Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText:
            'Use selective bluffs when you can represent a hand that beats middle pairs.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._bluffChoices.map((choice) {
          final isSelected = _gate2Choice == choice;
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
              onPressed: () =>
                  _selectGateChoice(choice, controller, isValueQuestion: false),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_gate2Correct)
          LessonActionButton(
            label: 'Seal the lesson',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'River heuristics confirmed.',
      showSessionSummary: true,
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
      requiresNumericText: true,
    ),
  ];

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'Value default', color: Color(0xFF4CAF50)),
      _LegendChip(label: 'Bluff default', color: Color(0xFF4DB0FF)),
    ];
  }

  Widget _buildTableArea() {
    return SizedBox(
      height: 220,
      child: Container(
        padding: const EdgeInsets.all(lessonSpacingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'River lines are about credibility and timing.',
              style: LessonTypography.subtitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: lessonSpacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LessonNumericText(
                  'Value line',
                  style: LessonTypography.title(context),
                ),
                const SizedBox(width: lessonSpacingMedium),
                LessonNumericText(
                  'Bluff line',
                  style: LessonTypography.title(context),
                ),
              ],
            ),
            const SizedBox(height: lessonSpacingSmall),
            Text(
              'Tiny sizing when you have the goods, small bluffs when the board still folds.',
              style: LessonTypography.body(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
