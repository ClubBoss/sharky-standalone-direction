import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class SizingByTextureBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const SizingByTextureBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<SizingByTextureBasicsScenarioScreen> createState() =>
      _SizingByTextureBasicsScenarioScreenState();
}

class _SizingByTextureBasicsScenarioScreenState
    extends State<SizingByTextureBasicsScenarioScreen> {
  static const _gate1Question =
      'Dry A72r SRP range advantage — which default sizing?';
  static const _gate2Question =
      'Wet JT9 two-tone board — which default sizing?';
  static const _dryChoices = ['1/3 pot', '1/2 pot', '2/3 pot'];
  static const _wetChoices = ['1/3 pot', '2/3 pot', 'Full pot'];

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
    final correct = isDryGate ? choice == '1/3 pot' : choice == '2/3 pot';
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
      title: 'Sizing shifts with texture.',
      bodyBuilder: (context, controller) => [
        Text(
          'Dry boards let you keep sizing small while wet boards demand more pressure.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Show the textures',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Dry',
      title: 'Dry A72r favors smaller sizing to preserve fold equity.',
      bodyBuilder: (context, controller) => [
        LessonNumericText(
          '1/3 pot keeps the story tight while still folding out floats.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Keep it small',
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
        hintText: 'Dry boards + range advantage reward smaller sizing.',
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
      metaLabel: 'Wet',
      title: 'Wet JT9 two-tone leans on bigger sizing to charge draws.',
      bodyBuilder: (context, controller) => [
        Text(
          '2/3 pot keeps pressure on drawing ranges while still leaving room for showdown.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Lean into the wet',
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
        hintText: 'Wet boards reward larger sizing when you need fold equity.',
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
            label: 'Pack the pot',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Sizing by texture learned.',
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
      _LegendChip(label: 'Dry sizing', color: Color(0xFF4DB0FF)),
      _LegendChip(label: 'Wet sizing', color: Color(0xFF4CAF50)),
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
              'Match sizing to texture and line.',
              style: LessonTypography.subtitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: lessonSpacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LessonNumericText(
                  'Dry → 1/3',
                  style: LessonTypography.title(context),
                ),
                const SizedBox(width: lessonSpacingMedium),
                LessonNumericText(
                  'Wet → 2/3',
                  style: LessonTypography.title(context),
                ),
              ],
            ),
            const SizedBox(height: lessonSpacingSmall),
            Text(
              'Use a smaller probe on dry boards and push size when texture fills.',
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
