import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poker_analyzer/engine/table_layout_adapter.dart';
import 'package:poker_analyzer/engine/table_layout_resolver.dart';
import 'package:poker_analyzer/engine/table_shape.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/table/action_bar_model.dart';
import 'package:poker_analyzer/ui_v2/table/table_composite_surface.dart';
import 'package:poker_analyzer/ui_v2/theme/numeric_text.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';

class CheckVsBetBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const CheckVsBetBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<CheckVsBetBasicsScenarioScreen> createState() =>
      _CheckVsBetBasicsScenarioScreenState();
}

class _CheckVsBetBasicsScenarioScreenState
    extends State<CheckVsBetBasicsScenarioScreen> {
  static const _heroSeat = 2;
  static const _opponentSeat = 5;

  double _potBb = 2.0;
  bool _checkConfirmed = false;
  bool _betPlaced = false;
  bool _isCompleting = false;
  int _stageIndex = 0;

  String _checkQuestion = 'Does the pot change when you check?';
  List<String> _checkChoices = const ['Yes', 'No'];
  String _checkCorrectAnswer = 'No';
  String _checkExplanation =
      'Nobody adds chips when you check, so the pot stays the same.';
  String _checkFeedback = '';
  String? _selectedCheckChoice;
  bool _checkQuestionCorrect = false;

  String _betQuestion =
      'If the pot is 2.0 BB and you bet 1 BB, how much does the pot increase immediately?';
  List<String> _betChoices = const ['+0.5 BB', '+1 BB', '+2 BB'];
  String _betCorrectAnswer = '+1 BB';
  String _betExplanation = 'The pot grows by the amount you commit, so +1 BB.';
  String _betFeedback = '';
  String? _selectedBetChoice;
  bool _betQuestionCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  Future<void> _loadQuestionData() async {
    try {
      final raw = await rootBundle.loadString(
        'content/check_vs_bet_basics/v1/drills.jsonl',
      );
      final lines = raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      for (final line in lines) {
        final parsed = json.decode(line) as Map<String, dynamic>;
        final id = parsed['id'];
        if (id == 'check_vs_bet_q1') {
          _updateCheckQuestion(parsed);
        } else if (id == 'check_vs_bet_q2') {
          _updateBetQuestion(parsed);
        }
      }
    } catch (_) {
      // keep defaults
    }
  }

  void _updateCheckQuestion(Map<String, dynamic> data) {
    setState(() {
      final question = data['question'];
      if (question is String && question.isNotEmpty) {
        _checkQuestion = question;
      }
      final choices = data['answer_choices'];
      if (choices is List && choices.isNotEmpty) {
        _checkChoices = choices.map((entry) => entry.toString()).toList();
      }
      final correct = data['correct_answer'];
      if (correct is String && correct.isNotEmpty) {
        _checkCorrectAnswer = correct;
      }
      final explanation = data['reaction_text'] ?? data['rationale'];
      if (explanation is String && explanation.isNotEmpty) {
        _checkExplanation = explanation;
      }
    });
  }

  void _updateBetQuestion(Map<String, dynamic> data) {
    setState(() {
      final question = data['question'];
      if (question is String && question.isNotEmpty) {
        _betQuestion = question;
      }
      final choices = data['answer_choices'];
      if (choices is List && choices.isNotEmpty) {
        _betChoices = choices.map((entry) => entry.toString()).toList();
      }
      final correct = data['correct_answer'];
      if (correct is String && correct.isNotEmpty) {
        _betCorrectAnswer = correct;
      }
      final explanation = data['reaction_text'] ?? data['rationale'];
      if (explanation is String && explanation.isNotEmpty) {
        _betExplanation = explanation;
      }
    });
  }

  void _setStage(int stage) {
    setState(() {
      _stageIndex = stage;
    });
  }

  void _confirmCheck() {
    if (_checkConfirmed) return;
    setState(() {
      _checkConfirmed = true;
    });
  }

  void _placeBet() {
    if (_betPlaced) return;
    setState(() {
      _betPlaced = true;
      _potBb += 1.0;
    });
  }

  void _selectCheckAnswer(String choice) {
    setState(() {
      _selectedCheckChoice = choice;
      _checkQuestionCorrect = choice == _checkCorrectAnswer;
      _checkFeedback = _checkQuestionCorrect
          ? 'Correct · $_checkExplanation'
          : 'Try again · $_checkExplanation';
    });
  }

  void _selectBetAnswer(String choice) {
    setState(() {
      _selectedBetChoice = choice;
      _betQuestionCorrect = choice == _betCorrectAnswer;
      _betFeedback = _betQuestionCorrect
          ? 'Correct · $_betExplanation'
          : 'Try again · $_betExplanation';
    });
  }

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
      _potBb = 2.0;
      _checkConfirmed = false;
      _betPlaced = false;
      _isCompleting = false;
      _stageIndex = 0;
      _selectedCheckChoice = null;
      _checkQuestionCorrect = false;
      _checkFeedback = '';
      _selectedBetChoice = null;
      _betQuestionCorrect = false;
      _betFeedback = '';
    });
    _loadQuestionData();
  }

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  List<SeatVisualState> _seatStates() {
    return List.generate(6, (index) {
      final isHero = index == _heroSeat;
      return SeatVisualState(
        seatIndex: index,
        isActive: isHero && _stageIndex >= 1,
        isFolded: false,
        isActed: isHero && (_checkConfirmed || _betPlaced),
        isAllIn: false,
      );
    });
  }

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'Hero (You)', color: Color(0xFF4CAF50)),
      _LegendChip(label: 'Opponent', color: Color(0xFFE6B800)),
    ];
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
                potAmount: _potBb,
              ),
              if (seatPositions.length > _heroSeat)
                Positioned(
                  left: seatPositions[_heroSeat].dx - 48,
                  top: seatPositions[_heroSeat].dy + 8,
                  child: _SeatLabel(
                    label: 'Hero',
                    style: LessonTypography.subtitle(context),
                  ),
                ),
              if (seatPositions.length > _opponentSeat)
                Positioned(
                  left: seatPositions[_opponentSeat].dx - 48,
                  top: seatPositions[_opponentSeat].dy + 8,
                  child: _SeatLabel(
                    label: 'Opponent',
                    style: LessonTypography.subtitle(context),
                  ),
                ),
              if (seatPositions.length > _heroSeat)
                Positioned(
                  left: seatPositions[_heroSeat].dx - 22,
                  top: seatPositions[_heroSeat].dy - 38,
                  child: LessonChipMoveTransition(
                    active: _betPlaced,
                    child: _chipBadge('1.0 BB bet', const Color(0xFF4DB0FF)),
                  ),
                ),
              Positioned(
                left: layout.boardPosition.dx - 52,
                top: layout.boardPosition.dy - 110,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Pot: ', style: LessonTypography.subtitle(context)),
                      LessonNumericText(
                        '${_potBb.toStringAsFixed(1)} BB',
                        style: LessonTypography.subtitle(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chipBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(label, style: LessonTypography.body(context)),
    );
  }

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'Postflop action is ready with 2.0 BB in the pot.',
      bodyBuilder: (context, controller) => [
        Text(
          'See how a check leaves the pot unchanged.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Show the check',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
      onEnter: () => _setStage(0),
    ),
    LessonStep(
      metaLabel: 'Step 1',
      title: 'Check keeps the pot where it started.',
      bodyBuilder: (context, controller) => [
        LessonActionButton(
          label: _checkConfirmed ? 'Check confirmed' : 'Check',
          enabled: !_checkConfirmed,
          onPressed: _confirmCheck,
          helperText: _checkConfirmed ? null : 'Tap to confirm the check.',
        ),
        if (_checkConfirmed) ...[
          const SizedBox(height: lessonSpacingMedium),
          Text(
            'Pot stays at ${_potBb.toStringAsFixed(1)} BB.',
            style: LessonTypography.body(context),
          ),
          const SizedBox(height: lessonSpacingMedium),
          LessonActionButton(
            label: 'Ask the check question',
            onPressed: controller.advance,
          ),
        ],
      ],
      requiresNumericText: true,
      onEnter: () => _setStage(1),
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _checkQuestion,
      gateEngagementConfig: const GateEngagementConfig(comboEligible: true),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._checkChoices.map((choice) {
          final isSelected = _selectedCheckChoice == choice;
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
              onPressed: () => _selectCheckAnswer(choice),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_checkFeedback.isNotEmpty) ...[
          Text(
            _checkFeedback,
            style: LessonTypography.helper(context).copyWith(
              color: _checkQuestionCorrect
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: lessonSpacingMedium),
        ],
        if (_checkQuestionCorrect)
          LessonActionButton(label: 'Continue', onPressed: controller.advance),
      ],
      requiresNumericText: true,
      onEnter: () => _setStage(2),
    ),
    LessonStep(
      metaLabel: 'Step 2',
      title: 'Bet 1 BB to add chips to the pot.',
      bodyBuilder: (context, controller) => [
        LessonActionButton(
          label: _betPlaced ? 'Bet confirmed' : 'Bet 1 BB',
          enabled: !_betPlaced,
          onPressed: _placeBet,
        ),
        if (_betPlaced) ...[
          const SizedBox(height: lessonSpacingMedium),
          Text(
            'Pot is now ${_potBb.toStringAsFixed(1)} BB.',
            style: LessonTypography.body(context),
          ),
          const SizedBox(height: lessonSpacingMedium),
          LessonActionButton(
            label: 'Explain the bet',
            onPressed: controller.advance,
          ),
        ],
      ],
      requiresNumericText: true,
      onEnter: () => _setStage(3),
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: _betQuestion,
      gateEngagementConfig: const GateEngagementConfig(comboEligible: true),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingSmall),
        ..._betChoices.map((choice) {
          final isSelected = _selectedBetChoice == choice;
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
              onPressed: () => _selectBetAnswer(choice),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(choice, style: LessonTypography.body(context)),
              ),
            ),
          );
        }),
        if (_betFeedback.isNotEmpty) ...[
          Text(
            _betFeedback,
            style: LessonTypography.helper(context).copyWith(
              color: _betQuestionCorrect
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: lessonSpacingMedium),
        ],
        if (_betQuestionCorrect)
          LessonActionButton(
            label: 'Acknowledge',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
      onEnter: () => _setStage(4),
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Great—checks keep the pot steady while bets add chips.',
      bodyBuilder: (_, __) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: _isCompleting ? 'Wrapping up…' : 'Finish',
          onPressed: _isCompleting ? null : _completeScenario,
        ),
      ],
      requiresNumericText: true,
      onEnter: () => _setStage(5),
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
