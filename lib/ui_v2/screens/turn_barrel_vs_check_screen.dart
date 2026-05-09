import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class TurnBarrelVsCheckScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const TurnBarrelVsCheckScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<TurnBarrelVsCheckScenarioScreen> createState() =>
      _TurnBarrelVsCheckScenarioScreenState();
}

class _TurnBarrelVsCheckScenarioScreenState
    extends State<TurnBarrelVsCheckScenarioScreen> {
  static const _gate1Question =
      'After a dry flop c-bet and a brick turn, what is your default?';
  static const _gate2Question =
      'When the wet turn fills many draws, what should you do?';
  static const _dryChoices = [
    'Barrel small',
    'Check and pot control',
    'Raise big',
  ];
  static const _wetChoices = [
    'Barrel again',
    'Check and play multi-way',
    'Stack off',
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
    required bool isDryQuestion,
  }) {
    final correct = isDryQuestion
        ? choice == 'Barrel small'
        : choice == 'Check and play multi-way';
    setState(() {
      if (isDryQuestion) {
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
    if (isDryQuestion && !_gate1SuccessPulseShown) {
      _gate1SuccessPulseShown = true;
      controller.showSuccessFeedback();
    }
    if (!isDryQuestion && !_gate2SuccessPulseShown) {
      _gate2SuccessPulseShown = true;
      controller.showSuccessFeedback();
    }
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'Turn heuristics keep pressure predictable.',
      bodyBuilder: (context, controller) => [
        LessonNumericText(
          'You c-bet the dry flop and now face a blank turn.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        Text(
          'Decide whether to barrel or check based on board texture and range advantage.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Map the default',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Dry Turn',
      title: 'Brick turns keep the dry narrative alive.',
      bodyBuilder: (context, controller) => [
        Text(
          'Nailing a small barrel here keeps initiative when the turn brings no new draws.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Commit to the barrel',
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
        hintText: 'Dry bricks let you keep betting small to fold out floats.',
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
                  _selectGateChoice(choice, controller, isDryQuestion: true),
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
      metaLabel: 'Wet Turn',
      title: 'Wet turns freeze aggression.',
      bodyBuilder: (context, controller) => [
        Text(
          'When draws complete, the safer line is to check and play multi-way rather than barrel.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Respect the wet card',
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
        hintText: 'Check down and plan multi-way plays when the board fills.',
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
                  _selectGateChoice(choice, controller, isDryQuestion: false),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_gate2Correct)
          LessonActionButton(
            label: 'Hold the line',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Turn heuristics ready.',
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
      _LegendChip(label: 'Barrel default', color: Color(0xFF4CAF50)),
      _LegendChip(label: 'Check default', color: Color(0xFF4DB0FF)),
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
              'Turn textures keep range advantage in focus.',
              style: LessonTypography.subtitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: lessonSpacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LessonNumericText(
                  'Dry + Brick',
                  style: LessonTypography.title(context),
                ),
                const SizedBox(width: lessonSpacingMedium),
                LessonNumericText(
                  'Wet + Draws',
                  style: LessonTypography.title(context),
                ),
              ],
            ),
            const SizedBox(height: lessonSpacingSmall),
            Text(
              'Keep c-bets small on dry turns and respect completed draws on wet turns.',
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
