import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';

class PositionIpOopBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const PositionIpOopBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<PositionIpOopBasicsScenarioScreen> createState() =>
      _PositionIpOopBasicsScenarioScreenState();
}

class _PositionIpOopBasicsScenarioScreenState
    extends State<PositionIpOopBasicsScenarioScreen> {
  bool _gate1Correct = false;
  bool _gate2Correct = false;
  bool _gate1SuccessPulseShown = false;
  bool _gate2SuccessPulseShown = false;
  String? _gate1Selection;
  String? _gate2Selection;
  bool _isCompleting = false;

  static const _gate1Question = 'Who is in position on the flop?';
  static const _gate2Question = 'Who acts first postflop?';
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
      _gate1SuccessPulseShown = false;
      _gate2SuccessPulseShown = false;
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
    if (!_gate1SuccessPulseShown) {
      _gate1SuccessPulseShown = true;
      controller.showSuccessFeedback();
    }
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
    if (!_gate2SuccessPulseShown) {
      _gate2SuccessPulseShown = true;
      controller.showSuccessFeedback();
    }
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'Heads-up, position matters on every street.',
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('You are the ', style: LessonTypography.body(context)),
            LessonNumericText('Button', style: LessonTypography.body(context)),
            Text(' vs the ', style: LessonTypography.body(context)),
            LessonNumericText(
              'Big Blind',
              style: LessonTypography.body(context),
            ),
            Text('.', style: LessonTypography.body(context)),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        Text(
          'Per-street order shifts from the flop through the river.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Show the flop picture',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Flop',
      title: 'Button closes streets after the flop.',
      bodyBuilder: (context, controller) => [
        Container(
          padding: const EdgeInsets.all(lessonSpacingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.65),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              Text(
                'Flop arrives — Button now acts last.',
                style: LessonTypography.body(context),
              ),
              const SizedBox(height: lessonSpacingSmall),
              Text(
                'Big Blind leads from OOP.',
                style: LessonTypography.body(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Ask who closes action?',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate1Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText: 'Button closes action each street after the flop.',
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
        hintText: 'OOP acts before IP postflop and on future streets.',
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
            label: 'Summarize position',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Compare',
      title: 'IP vs OOP in heads-up',
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('IP (Button) ', style: LessonTypography.body(context)),
            LessonNumericText(
              'acts last',
              style: LessonTypography.body(context),
            ),
            Text(' • OOP (Big Blind) ', style: LessonTypography.body(context)),
            LessonNumericText(
              'acts first',
              style: LessonTypography.body(context),
            ),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Finish the lesson',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Position Basics locked in.',
      showSessionSummary: true,
      bodyBuilder: (_, __) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: _isCompleting ? 'Wrapping up…' : 'Finish',
          onPressed: _isCompleting ? null : _completeScenario,
        ),
      ],
      completionActions: CompletionActions(
        showReplay: true,
        showNext: _nextModuleId != null,
        onReplay: _resetScenarioState,
        onNext: _nextModuleId != null ? _goToNextLesson : null,
      ),
      requiresNumericText: true,
    ),
  ];

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'Button (IP)', color: Color(0xFF4DB0FF)),
      _LegendChip(label: 'Big Blind (OOP)', color: Color(0xFF4CAF50)),
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
              'Heads-Up Centerstage',
              style: LessonTypography.subtitle(context),
            ),
            const SizedBox(height: lessonSpacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LessonNumericText(
                  'You (BTN)',
                  style: LessonTypography.title(context),
                ),
                const SizedBox(width: lessonSpacingMedium),
                LessonNumericText('BB', style: LessonTypography.title(context)),
              ],
            ),
            const SizedBox(height: lessonSpacingSmall),
            Text(
              'Position shifts each reply—Button closes after the flop.',
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
