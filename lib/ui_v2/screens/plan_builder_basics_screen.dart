import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual_micro_card.dart';

class PlanBuilderBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const PlanBuilderBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<PlanBuilderBasicsScenarioScreen> createState() =>
      _PlanBuilderBasicsScenarioScreenState();
}

class _PlanBuilderBasicsScenarioScreenState
    extends State<PlanBuilderBasicsScenarioScreen> {
  static const _gate1Question =
      'Dry board + range advantage + folding opponent — what plan bets the line?';
  static const _gate2Question =
      'Wet board + calling opponent — what plan keeps you ahead?';
  static const _dryChoices = [
    'Bet flop, bet turn, value river',
    'Check flop, lead turn, bluff river',
    'Float flop, check turn, bluff river',
  ];
  static const _wetChoices = [
    'Check more streets, value thin',
    'Barrel wide on turn',
    'Jam river regardless',
  ];

  bool _gate1Correct = false;
  bool _gate2Correct = false;
  bool _gate1PulseShown = false;
  bool _gate2PulseShown = false;
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
      _gate1PulseShown = false;
      _gate2PulseShown = false;
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
    required bool isDryGate,
  }) {
    final correct = isDryGate
        ? choice == 'Bet flop, bet turn, value river'
        : choice == 'Check more streets, value thin';
    setState(() {
      if (isDryGate) {
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
    if (isDryGate && !_gate1PulseShown) {
      _gate1PulseShown = true;
      controller.showSuccessFeedback();
    }
    if (!isDryGate && !_gate2PulseShown) {
      _gate2PulseShown = true;
      controller.showSuccessFeedback();
    }
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'Plans start with texture and tendencies.',
      bodyBuilder: (context, controller) => [
        Text(
          'Align flop→turn→river around what foe shows you and the board texture.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'See the plan builder',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Dry Plan',
      title: 'Dry boards let you hammer value.',
      bodyBuilder: (context, controller) => [
        Text(
          'When you have range advantage on a dry board and they fold, keep pressuring with bets.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Burn the plan',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate1Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Dry boards + folds = follow-through value.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._dryChoices.map((choice) {
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
                  _selectGateChoice(choice, controller, isDryGate: true),
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
      metaLabel: 'Wet Plan',
      title: 'Wet boards call for caution.',
      bodyBuilder: (context, controller) => [
        Text(
          'When the board is wet and opponents call wide, keep bets focused on value and fewer bluffs.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Hold the course',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate2Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Wet boards demand check/value rather than barrels.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._wetChoices.map((choice) {
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
                  _selectGateChoice(choice, controller, isDryGate: false),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_gate2Correct)
          LessonActionButton(
            label: 'Lock the plan',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Plan builder ready.',
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
      _LegendChip(label: 'Plan A', color: Color(0xFF4CAF50)),
      _LegendChip(label: 'Plan B', color: Color(0xFF4DB0FF)),
    ];
  }

  Widget _buildTableArea() {
    return SizedBox(
      height: 300,
      child: VisualMicroCard(
        title: 'Flop→Turn→River should feel like a single plan.',
        diagram: _buildPlanBuilderDiagram(context),
        body: [
          const SizedBox(height: lessonSpacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LessonNumericText(
                'Dry line',
                style: LessonTypography.title(context),
              ),
              const SizedBox(width: lessonSpacingMedium),
              LessonNumericText(
                'Wet line',
                style: LessonTypography.title(context),
              ),
            ],
          ),
          const SizedBox(height: lessonSpacingSmall),
          Text(
            'Builder keeps each street consistent with where you expect folds or calls.',
            style: LessonTypography.body(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBuilderDiagram(BuildContext context) {
    const arrowColor = Colors.white70;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LessonNumericText('Flop', style: LessonTypography.title(context)),
          const SizedBox(width: lessonSpacingSmall),
          const Icon(Icons.arrow_forward, size: 18, color: arrowColor),
          const SizedBox(width: lessonSpacingSmall),
          LessonNumericText('Turn', style: LessonTypography.title(context)),
          const SizedBox(width: lessonSpacingSmall),
          const Icon(Icons.arrow_forward, size: 18, color: arrowColor),
          const SizedBox(width: lessonSpacingSmall),
          LessonNumericText('River', style: LessonTypography.title(context)),
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
