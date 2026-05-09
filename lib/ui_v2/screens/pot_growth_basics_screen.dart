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

class PotGrowthBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const PotGrowthBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<PotGrowthBasicsScenarioScreen> createState() =>
      _PotGrowthBasicsScenarioScreenState();
}

class _PotGrowthBasicsScenarioScreenState
    extends State<PotGrowthBasicsScenarioScreen> {
  static const _opponentSeat = 5;
  static const _heroSeat = 2;

  double _potBb = 0;
  bool _betPlaced = false;
  bool _betAnimationScheduled = false;
  bool _callPlaced = false;
  bool _isCompleting = false;

  String _questionText =
      'If you bet 1 BB and the opponent calls 1 BB, how much does the pot grow?';
  String _correctAnswer = '+2 BB total';
  String _questionFeedback = '';
  String _explanation = 'Both contributions add to the pot.';
  List<String> _answerChoices = const [
    '+2 BB total',
    '+1 BB total',
    '+0.5 BB total',
  ];
  String? _selectedChoice;
  bool _questionCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  Future<void> _loadQuestionData() async {
    try {
      final raw = await rootBundle.loadString(
        'content/pot_growth_basics/v1/drills.jsonl',
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
            _explanation = explanation;
          }
        });
      }
    } catch (_) {
      // keep defaults
    }
  }

  void _startBetAnimation() {
    if (_betAnimationScheduled) return;
    _betAnimationScheduled = true;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _betPlaced = true;
        _potBb = 1.0;
      });
    });
  }

  void _callBet() {
    if (_callPlaced) return;
    setState(() {
      _callPlaced = true;
      _potBb = 2.0;
    });
  }

  void _selectAnswer(String choice) {
    setState(() {
      _selectedChoice = choice;
      _questionCorrect = choice == _correctAnswer;
      _questionFeedback = _questionCorrect
          ? 'Correct · $_explanation'
          : 'Try again · both chips join the pot.';
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
      _potBb = 0;
      _betPlaced = false;
      _betAnimationScheduled = false;
      _callPlaced = false;
      _isCompleting = false;
      _selectedChoice = null;
      _questionCorrect = false;
      _questionFeedback = '';
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
      final isOpponent = index == _opponentSeat;
      return SeatVisualState(
        seatIndex: index,
        isActive: isHero,
        isFolded: false,
        isActed: isHero ? _callPlaced : isOpponent && _betPlaced,
        isAllIn: false,
      );
    });
  }

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'Opponent', color: Color(0xFFE6B800)),
      _LegendChip(label: 'Hero (You)', color: Color(0xFF4CAF50)),
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
              if (seatPositions.length > _opponentSeat)
                Positioned(
                  left: seatPositions[_opponentSeat].dx - 22,
                  top: seatPositions[_opponentSeat].dy - 38,
                  child: LessonChipMoveTransition(
                    active: _betPlaced,
                    child: _chipBadge('1.0 BB bet', const Color(0xFF4DB0FF)),
                  ),
                ),
              if (seatPositions.length > _heroSeat)
                Positioned(
                  left: seatPositions[_heroSeat].dx - 22,
                  top: seatPositions[_heroSeat].dy - 38,
                  child: LessonChipMoveTransition(
                    active: _callPlaced,
                    child: _chipBadge('1.0 BB call', const Color(0xFF4CAF50)),
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

  List<LessonStep> get _steps => [
    LessonStep(
      metaLabel: 'Context',
      title: 'The pot starts empty and the board awaits action.',
      bodyBuilder: (context, controller) => [
        Text(
          'Watch a bet and then a call grow the pot.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Show the bet',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Step 1',
      title: 'Opponent bets 1.0 BB into the pot.',
      bodyBuilder: (context, controller) {
        final isReady = _betPlaced;
        return [
          Text(
            'Pot is now ${_potBb.toStringAsFixed(1)} BB.',
            style: LessonTypography.body(context),
          ),
          const SizedBox(height: lessonSpacingMedium),
          LessonActionButton(
            label: 'Continue',
            enabled: isReady,
            helperText: isReady ? null : 'Wait while the chips move in.',
            onPressed: isReady ? controller.advance : null,
          ),
        ];
      },
      requiresNumericText: true,
      onEnter: _startBetAnimation,
    ),
    LessonStep(
      metaLabel: 'Step 2',
      title: 'Match the bet to add your 1.0 BB.',
      bodyBuilder: (context, controller) {
        return [
          LessonActionButton(
            label: _callPlaced ? 'Call confirmed' : 'Call 1.0 BB',
            enabled: !_callPlaced,
            onPressed: _callPlaced ? null : _callBet,
          ),
          if (_callPlaced) ...[
            const SizedBox(height: lessonSpacingMedium),
            Text(
              'Pot is now ${_potBb.toStringAsFixed(1)} BB.',
              style: LessonTypography.body(context),
            ),
            const SizedBox(height: lessonSpacingMedium),
            LessonActionButton(
              label: 'Explain the pot',
              onPressed: controller.advance,
            ),
          ],
        ];
      },
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Concept',
      title: 'Pot = sum of every chip committed this hand.',
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Answer the gate',
          onPressed: controller.advance,
        ),
      ],
      requiresNumericText: true,
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
        if (_questionFeedback.isNotEmpty) ...[
          Text(
            _questionFeedback,
            style: LessonTypography.helper(context).copyWith(
              color: _questionCorrect
                  ? Colors.greenAccent
                  : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: lessonSpacingMedium),
        ],
        if (_questionCorrect)
          LessonActionButton(
            label: 'Acknowledge',
            onPressed: controller.advance,
          ),
      ],
      requiresNumericText: true,
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Great—you see how bets and calls feed the pot.',
      bodyBuilder: (_, __) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: _isCompleting ? 'Wrapping up…' : 'Finish',
          onPressed: _isCompleting ? null : _completeScenario,
        ),
      ],
      requiresNumericText: true,
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

  Widget _chipBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
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
