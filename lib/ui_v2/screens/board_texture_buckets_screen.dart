import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class BoardTextureBucketsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const BoardTextureBucketsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<BoardTextureBucketsScenarioScreen> createState() =>
      _BoardTextureBucketsScenarioScreenState();
}

class _BoardTextureBucketsScenarioScreenState
    extends State<BoardTextureBucketsScenarioScreen> {
  bool _gate1Correct = false;
  bool _gate2Correct = false;
  bool _gate1SuccessPulseShown = false;
  bool _gate2SuccessPulseShown = false;
  String? _gate1Choice;
  String? _gate2Choice;
  bool _isCompleting = false;

  static const _gate1Question = 'Classify board A72r';
  static const _gate2Question = 'Classify board 987ss';
  static const _textureChoices = ['Dry', 'Semi-wet', 'Wet'];

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
    final correct =
        (isDryQuestion && choice == 'Dry') ||
        (!isDryQuestion && choice == 'Wet');
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
      title: 'Board texture buckets guide every sizing plan.',
      bodyBuilder: (context, controller) => [
        Text(
          'Dry, semi-wet, and wet boards demand different probing bets.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LessonNumericText('A72r', style: LessonTypography.title(context)),
            const SizedBox(width: lessonSpacingMedium),
            LessonNumericText('987ss', style: LessonTypography.title(context)),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Inspect the textures',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Dry',
      title: 'Dry boards resist draws and favor high-card equity.',
      bodyBuilder: (context, controller) => [
        Text(
          'Dry boards have fewer connected or suited combos.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A board like ', style: LessonTypography.body(context)),
            LessonNumericText('A72r', style: LessonTypography.body(context)),
            Expanded(
              child: Text(
                ' leaves fewer straight and flush outs, so aggression sticks.',
                style: LessonTypography.body(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Test the dryness',
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
        hintText: 'Dry boards lack too many connected or suited cards.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._textureChoices.map((choice) {
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
      metaLabel: 'Wet',
      title: 'Wet boards flood draws and reward defense.',
      bodyBuilder: (context, controller) => [
        Row(
          children: [
            Text('Wet boards like ', style: LessonTypography.body(context)),
            LessonNumericText('987ss', style: LessonTypography.body(context)),
            Expanded(
              child: Text(
                ' deliver many straight and flush combinations, so check-calling stays strong.',
                style: LessonTypography.body(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'See the wet texture',
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
        hintText: 'Wet boards show low connectors and suited combos.',
      ),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._textureChoices.map((choice) {
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
            label: 'Lock the bucket',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Texture buckets locked.',
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
      _LegendChip(label: 'Dry', color: Color(0xFFE8B429)),
      _LegendChip(label: 'Semi-wet', color: Color(0xFF4DB0FF)),
      _LegendChip(label: 'Wet', color: Color(0xFF4CAF50)),
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
              'Balanced boards keep texture tracking visible.',
              style: LessonTypography.subtitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: lessonSpacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LessonNumericText(
                  'A72r',
                  style: LessonTypography.title(context),
                ),
                const SizedBox(width: lessonSpacingMedium),
                LessonNumericText(
                  '987ss',
                  style: LessonTypography.title(context),
                ),
              ],
            ),
            const SizedBox(height: lessonSpacingSmall),
            Text(
              'Match each surface to the right aggression rhythm.',
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
