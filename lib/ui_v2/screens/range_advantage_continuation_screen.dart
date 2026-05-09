import 'package:flutter/material.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/ui_v2/widgets/visual_micro_card.dart';

class RangeAdvantageContinuationScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RangeAdvantageContinuationScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RangeAdvantageContinuationScreen> createState() =>
      _RangeAdvantageContinuationScreenState();
}

class _RangeAdvantageContinuationScreenState
    extends State<RangeAdvantageContinuationScreen> {
  bool _gate1Correct = false;
  bool _gate2Correct = false;
  String? _gate1Selection;
  String? _gate2Selection;
  bool _isCompleting = false;

  static const _gate1Question =
      'BTN vs BB SRP on an A-high dry board — optimal default?';
  static const _gate2Question =
      'BTN vs BB SRP on a low connected board like 8-7-6 — better default?';
  final List<String> _gateChoices = const ['Small c-bet', 'Check back'];

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

  void _selectGateChoice(
    String choice,
    LessonStepController controller,
    bool isFirstGate,
  ) {
    final correct =
        (isFirstGate && choice == 'Small c-bet') ||
        (!isFirstGate && choice == 'Check back');
    if (isFirstGate) {
      setState(() {
        _gate1Selection = choice;
        _gate1Correct = correct;
      });
    } else {
      setState(() {
        _gate2Selection = choice;
        _gate2Correct = correct;
      });
    }
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
      title: 'Range advantage directs continuation strategy.',
      bodyBuilder: (context, controller) => [
        Text(
          'BTN and BB SRP ranges interact differently on dry vs connected boards.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'See the continuation map',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Flop',
      title: 'Dry ace boards favor BTN c-bets.',
      bodyBuilder: (context, controller) => [
        Text(
          'BTN holds more top pairs so a small c-bet often folds out weak answers.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Ask the gate',
          onPressed: controller.advance,
        ),
      ],
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _gate1Question,
      gateEngagementConfig: const GateEngagementConfig(
        comboEligible: true,
        hintText:
            'Dry boards reward BTN high-card combos, so he keeps continuing.',
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
              onPressed: () => _selectGateChoice(choice, controller, true),
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
        hintText:
            'Connected lows let BB leverage more draws, so he checks more often.',
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
              onPressed: () => _selectGateChoice(choice, controller, false),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_gate2Correct)
          LessonActionButton(
            label: 'Summarize impact',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Compare',
      title: 'Continuation strategy choices',
      bodyBuilder: (context, controller) => [
        Text(
          'Dry boards call for small c-bets; wet ones favor check/back with a later plan.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(label: 'Finish', onPressed: controller.advance),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Range advantage feeds your continuation range.',
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
        title: 'Continuation choice',
        diagram: buildVisualMicroCardArrowDiagram(
          context,
          startLabel: 'C-bet',
          endLabel: 'Check',
        ),
        body: [
          const SizedBox(height: lessonSpacingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LessonNumericText('C-bet', style: LessonTypography.body(context)),
              const SizedBox(width: lessonSpacingMedium),
              LessonNumericText('Check', style: LessonTypography.body(context)),
            ],
          ),
          const SizedBox(height: lessonSpacingSmall),
          Text(
            'Range advantage says when to keep applying pressure vs when to slow down.',
            style: LessonTypography.body(context),
            textAlign: TextAlign.center,
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
          legendChips: const [
            _LegendChip(label: 'C-bet', color: Color(0xFF4DB0FF)),
            _LegendChip(label: 'Check Back', color: Color(0xFF4CAF50)),
          ],
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
