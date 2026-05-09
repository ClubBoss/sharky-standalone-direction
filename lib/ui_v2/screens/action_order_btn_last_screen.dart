import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/engine/table_layout_adapter.dart';
import 'package:poker_analyzer/engine/table_layout_resolver.dart';
import 'package:poker_analyzer/engine/table_shape.dart';
import 'package:poker_analyzer/personalization/corrective_practice_entry_contract_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/table/action_bar_model.dart';
import 'package:poker_analyzer/ui_v2/table/table_composite_surface.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';

class ActionOrderBtnLastScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;
  final ProgressionHandoffContextV1? handoffContextV1;

  const ActionOrderBtnLastScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    this.handoffContextV1,
  });

  @override
  State<ActionOrderBtnLastScenarioScreen> createState() =>
      _ActionOrderBtnLastScenarioScreenState();
}

class _ActionOrderBtnLastScenarioScreenState
    extends State<ActionOrderBtnLastScenarioScreen> {
  static const _buttonSeat = 5;
  static const _heroSeat = 2;

  int _stageIndex = 0;
  String _questionText = 'Who acts last postflop?';
  String _correctAnswer = 'Button';
  List<String> _answerChoices = const ['Button', 'Big Blind', 'Small Blind'];
  String? _selectedChoice;
  bool _questionCorrect = false;
  String _questionFeedback = '';

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  Future<void> _loadQuestionData() async {
    try {
      final raw = await rootBundle.loadString(
        'content/action_order_btn_last/v1/drills.jsonl',
      );
      final lines = raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.isNotEmpty) {
        final parsed = json.decode(lines.first) as Map<String, dynamic>;
        final question = parsed['question'];
        final choices = parsed['answer_choices'];
        final correct = parsed['correct_answer'];
        final explanation = parsed['reaction_text'] ?? parsed['rationale'];
        setState(() {
          if (question is String && question.isNotEmpty) {
            _questionText = question;
          }
          if (choices is List && choices.isNotEmpty) {
            _answerChoices = choices.map((entry) => entry.toString()).toList();
          }
          if (correct is String && correct.isNotEmpty) {
            _correctAnswer = correct;
          }
          if (explanation is String && explanation.isNotEmpty) {
            _questionFeedback = explanation;
          }
        });
      }
    } catch (_) {
      // keep defaults
    }
  }

  void _setStage(int stage) {
    if (_stageIndex == stage) return;
    setState(() {
      _stageIndex = stage;
    });
  }

  void _selectAnswer(String choice) {
    setState(() {
      _selectedChoice = choice;
      _questionCorrect = choice == _correctAnswer;
    });
  }

  Future<void> _completeScenario() async {
    await ProgressService.markModuleCompleted(widget.moduleId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  void _resetScenarioState() {
    setState(() {
      _stageIndex = 0;
      _selectedChoice = null;
      _questionCorrect = false;
    });
    _loadQuestionData();
  }

  CorrectivePracticeEntryContractV1? get _correctivePracticeEntryV1 =>
      CorrectivePracticeEntryContractFactoryV1.forActionOrderFamily(
        handoffContextV1: widget.handoffContextV1,
      );

  List<SeatVisualState> _seatStates() {
    return List.generate(6, (index) {
      final threshold = _stageIndex > 2 ? _buttonSeat : _heroSeat;
      final isButton = index == _buttonSeat;
      return SeatVisualState(
        seatIndex: index,
        isActive: isButton,
        isFolded: false,
        isActed: index <= threshold,
        isAllIn: false,
      );
    });
  }

  List<Widget> _legendChips() {
    return const [_LegendChip(label: 'Button', color: Color(0xFFE6B800))];
  }

  Widget _buildTableArea() {
    return SizedBox(
      height: 320,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolver = TableLayoutResolver(
            adapter: const TableLayoutAdapter(),
          );
          final layout = resolver.resolve(
            shape: TableShapeSpec.sixMax(),
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            safeArea: const EdgeInsets.all(18),
          );
          final seatPositions = layout.seatPositions;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              TableCompositeSurface(
                layout: layout,
                actionModel: const ActionBarModel(
                  canCall: false,
                  canFold: false,
                  canRaise: false,
                  callAmount: 0,
                  minRaiseAmount: 0,
                  maxRaiseAmount: 0,
                ),
                seatStates: _seatStates(),
              ),
              if (seatPositions.length > _buttonSeat)
                Positioned(
                  left: seatPositions[_buttonSeat].dx - 48,
                  top: seatPositions[_buttonSeat].dy + 8,
                  child: _SeatLabel(
                    label: 'Button',
                    style: LessonTypography.subtitle(context),
                  ),
                ),
              if (seatPositions.length > _heroSeat)
                Positioned(
                  left: seatPositions[_heroSeat].dx - 48,
                  top: seatPositions[_heroSeat].dy + 8,
                  child: _SeatLabel(
                    label: 'Hero',
                    style: LessonTypography.body(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: _correctivePracticeEntryV1 == null ? 'Context' : 'Review',
      title:
          _correctivePracticeEntryV1?.title ??
          'You are observing a 6-max postflop hand.',
      bodyBuilder: (context, controller) => [
        if (_correctivePracticeEntryV1 != null) ...[
          Text(
            _correctivePracticeEntryV1!.weaknessLine,
            key: const Key('action_order_btn_last_review_weakness_line_v1'),
            style: LessonTypography.body(context),
          ),
          const SizedBox(height: lessonSpacingSmall),
          Text(
            _correctivePracticeEntryV1!.goalLine,
            key: const Key('action_order_btn_last_review_goal_line_v1'),
            style: LessonTypography.body(context),
          ),
          const SizedBox(height: lessonSpacingSmall),
          Text(
            _correctivePracticeEntryV1!.practiceRuleLine,
            key: const Key('action_order_btn_last_review_rule_line_v1'),
            style: LessonTypography.helper(context),
          ),
        ] else
          Text(
            'The button closes every street after the flop.',
            style: LessonTypography.body(context),
          ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: _correctivePracticeEntryV1 == null
              ? 'See the button highlight'
              : 'See the last-actor anchor',
          onPressed: controller.advance,
        ),
      ],
      onEnter: () => _setStage(0),
    ),
    LessonStep(
      metaLabel: 'Step 1',
      title: 'Button acts last postflop.',
      bodyBuilder: (context, controller) => [
        Text(
          'Every other player checks first so the button can close action.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Show check sequence',
          onPressed: controller.advance,
        ),
      ],
      onEnter: () => _setStage(1),
    ),
    LessonStep(
      metaLabel: 'Step 2',
      title: 'Hero → SB → BB → Button',
      bodyBuilder: (context, controller) => [
        Text(
          'Hero checks, SB checks, BB checks, then the button checks to close the street.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Ask who acts last',
          onPressed: controller.advance,
        ),
      ],
      onEnter: () => _setStage(2),
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _questionText,
      gateEngagementConfig: const GateEngagementConfig(),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._answerChoices.map((choice) {
          final isSelected = _selectedChoice == choice;
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
              onPressed: () => _selectAnswer(choice),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }).toList(),
        if (_selectedChoice != null)
          Padding(
            padding: const EdgeInsets.only(top: lessonSpacingSmall),
            child: Text(
              _questionCorrect
                  ? 'Correct · Button closes action.'
                  : 'Try again · the button sees everyone before acting.',
              style: LessonTypography.helper(context).copyWith(
                color: _questionCorrect
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
              ),
            ),
          ),
        const SizedBox(height: lessonSpacingMedium),
        if (_questionCorrect)
          LessonActionButton(label: 'Finish', onPressed: controller.advance),
      ],
      onEnter: () => _setStage(3),
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Nice work. The button always acts last postflop.',
      bodyBuilder: (_, __) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(label: 'Done', onPressed: _completeScenario),
      ],
      onEnter: () => _setStage(4),
      showSessionSummary: true,
      completionActions: CompletionActions(
        showReplay: true,
        showNext: _nextModuleId != null,
        onReplay: _resetScenarioState,
        onNext: _goToNextLesson,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            final bottomInset =
                AppSpacing.lg + MediaQuery.of(context).viewPadding.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                bottomInset,
              ),
              child: LessonStepSequence(
                steps: _steps,
                legendChips: _legendChips(),
                tableArea: _buildTableArea(),
                lessonModuleId: widget.moduleId,
              ),
            );
          },
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

class _SeatLabel extends StatelessWidget {
  final String label;
  final TextStyle style;

  const _SeatLabel({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: style),
    );
  }
}
