import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual_micro_card.dart';

class RangeAdvantageBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RangeAdvantageBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RangeAdvantageBasicsScenarioScreen> createState() =>
      _RangeAdvantageBasicsScenarioScreenState();
}

class _RangeAdvantageBasicsScenarioScreenState
    extends State<RangeAdvantageBasicsScenarioScreen> {
  bool _gate1Correct = false;
  bool _gate2Correct = false;
  String? _gate1Selection;
  String? _gate2Selection;
  bool _isCompleting = false;

  static const _gate1Question =
      'Who has range advantage on A-high boards in BTN vs BB SRP?';
  static const _gate2Question =
      'On low connected boards (8-7-6), who more often holds nutted combos?';
  final List<String> _gateChoices = const ['Button', 'Big Blind'];

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
      _gate1Selection = null;
      _gate2Selection = null;
      _isCompleting = false;
    });
  }

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  void _selectGate1Choice(String choice, LessonStepController controller) {
    final correct = choice == 'Button';
    setState(() {
      _gate1Selection = choice;
      _gate1Correct = correct;
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    controller.showSuccessFeedback();
  }

  void _selectGate2Choice(String choice, LessonStepController controller) {
    final correct = choice == 'Big Blind';
    setState(() {
      _gate2Selection = choice;
      _gate2Correct = correct;
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    controller.showSuccessFeedback();
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'Single raised pot, BTN vs BB.',
      bodyBuilder: (context, controller) => [
        Text(
          'BTN opens and BB defends, creating a familiar range dynamic.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Map the ranges',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Range',
      title: 'BTN carries more value hands after opening.',
      bodyBuilder: (context, controller) => [
        Text(
          'Button range is tighter; Big Blind has more speculative tries.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(label: 'Talk boards', onPressed: controller.advance),
      ],
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate1Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText:
            'Button opens with more high cards, so A-high boards favor his range.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._gateChoices.map((choice) {
          final isSelected = _gate1Selection == choice;
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
              onPressed: () => _selectGate1Choice(choice, controller),
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
      metaLabel: 'Gate',
      title: _gate2Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Connected lows let the defender hold more nut combinations.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._gateChoices.map((choice) {
          final isSelected = _gate2Selection == choice;
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
              onPressed: () => _selectGate2Choice(choice, controller),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_gate2Correct)
          LessonActionButton(
            label: 'Understand the advantage',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Compare',
      title: 'Range advantage map',
      bodyBuilder: (context, controller) => [
        Text(
          'BTN holds more top-pair combos; BB has more draws/nut advantages on low boards.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(label: 'Finish', onPressed: controller.advance),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Range advantage basics locked in.',
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

  Widget _buildTableArea() {
    return SizedBox(
      height: 260,
      child: VisualMicroCard(
        title: 'Single Raised Pot',
        diagram: _buildRangeAdvantageDiagram(context),
        body: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LessonNumericText(
                      'BTN range',
                      style: LessonTypography.body(context),
                    ),
                    const SizedBox(width: lessonSpacingMedium),
                    LessonNumericText(
                      'BB range',
                      style: LessonTypography.body(context),
                    ),
                  ],
                ),
                const SizedBox(height: lessonSpacingSmall),
                Text(
                  'High cards favor BTN; low connected boards boost BB equity.',
                  style: LessonTypography.body(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeAdvantageDiagram(BuildContext context) {
    return buildVisualMicroCardArrowDiagram(
      context,
      startLabel: 'High cards',
      endLabel: 'Connected lows',
    );
  }

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'BTN Value', color: Color(0xFF4DB0FF)),
      _LegendChip(label: 'BB Spec', color: Color(0xFF4CAF50)),
    ];
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
