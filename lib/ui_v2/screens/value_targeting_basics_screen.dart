import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual_micro_card.dart';

class ValueTargetingBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const ValueTargetingBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<ValueTargetingBasicsScenarioScreen> createState() =>
      _ValueTargetingBasicsScenarioScreenState();
}

class _ValueTargetingBasicsScenarioScreenState
    extends State<ValueTargetingBasicsScenarioScreen> {
  static const _gate1Question =
      'Dry board, top pair top kicker — who calls your value bet?';
  static const _gate2Question = 'Wet board, strong two pair — who still calls?';
  static const _gate1Choices = ['Worse top pairs', 'Sets', 'Nut combos'];
  static const _gate2Choices = ['Top pair + draws', 'Nut flush', 'Trips'];

  bool _gate1Correct = false;
  bool _gate2Correct = false;
  bool _gate1Pulse = false;
  bool _gate2Pulse = false;
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
      _gate1Pulse = false;
      _gate2Pulse = false;
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

  void _selectGate(
    String choice,
    LessonStepController controller, {
    required bool isFirstGate,
  }) {
    final correct = isFirstGate
        ? choice == 'Worse top pairs'
        : choice == 'Top pair + draws';
    setState(() {
      if (isFirstGate) {
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
    if (isFirstGate && !_gate1Pulse) {
      _gate1Pulse = true;
      controller.showSuccessFeedback();
    }
    if (!isFirstGate && !_gate2Pulse) {
      _gate2Pulse = true;
      controller.showSuccessFeedback();
    }
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'Value targeting explains who calls.',
      bodyBuilder: (context, controller) => [
        Text(
          'Name the worse hands that still call before you size for value.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Reveal the targets',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Dry',
      title: 'Top pair top kicker needs tiny finishers.',
      bodyBuilder: (context, controller) => [
        Text(
          'Worse top pairs or second pairs still call on dry boards even when you bet small.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Set the size',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate1Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Dry boards + top pair top kicker call worse top pairs.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._gate1Choices.map((choice) {
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
                  _selectGate(choice, controller, isFirstGate: true),
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
    ),
    LessonStep(
      metaLabel: 'Wet',
      title: 'Two pair on wet boards still targets top pair draws.',
      bodyBuilder: (context, controller) => [
        Text(
          'Top pair plus draws or pair+draw combos still stay in the calling range against bigger sizing.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Focus the range',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate2Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Wet boards keep top pair + draw combos calling.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._gate2Choices.map((choice) {
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
                  _selectGate(choice, controller, isFirstGate: false),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_gate2Correct)
          LessonActionButton(
            label: 'Tag the calls',
            onPressed: controller.advance,
          ),
      ],
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Value targeting locked.',
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
    ),
  ];

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'Dry calls', color: Color(0xFF4CAF50)),
      _LegendChip(label: 'Wet calls', color: Color(0xFF4DB0FF)),
    ];
  }

  Widget _buildTableArea() {
    return SizedBox(
      height: 260,
      child: VisualMicroCard(
        title: 'Name who calls before sizing up.',
        diagram: _buildValueTargetDiagram(context),
        body: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LessonNumericText(
                      'Dry → Worse tops',
                      style: LessonTypography.title(context),
                    ),
                    const SizedBox(width: lessonSpacingMedium),
                    LessonNumericText(
                      'Wet → Pair+draws',
                      style: LessonTypography.title(context),
                    ),
                  ],
                ),
                const SizedBox(height: lessonSpacingSmall),
                Text(
                  'Value bets land when you know which worse hands still call.',
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

  Widget _buildValueTargetDiagram(BuildContext context) {
    return buildVisualMicroCardDryWetDiagram(context);
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
