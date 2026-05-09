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
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';

class ForcedBetsEtalonScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const ForcedBetsEtalonScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<ForcedBetsEtalonScenarioScreen> createState() =>
      _ForcedBetsEtalonScenarioScreenState();
}

class _ForcedBetsEtalonScenarioScreenState
    extends State<ForcedBetsEtalonScenarioScreen> {
  static const _smallBlindSeat = 1;
  static const _bigBlindSeat = 2;

  int _currentStepIndex = 0;
  double _potBb = 0;
  bool _sbPosted = false;
  bool _sbAnimationScheduled = false;
  bool _bbPosted = false;
  bool _isCompleting = false;

  String _questionText = 'Why is the pot 1.5 BB?';
  String _correctAnswer = 'Because SB + BB posted forced bets';
  String _questionFeedback = '';
  String _explanation = '';
  List<String> _answerChoices = const [
    'Because SB + BB posted forced bets',
    'Because the flop already resolved',
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
        'content/forced_bets_etalon/v1/drills.jsonl',
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
      // Fall back to defaults if assets fail.
    }
  }

  void _handleStepEnter(int index) {
    setState(() {
      _currentStepIndex = index;
    });
    if (index == 1 && !_sbAnimationScheduled) {
      _sbAnimationScheduled = true;
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted || _currentStepIndex != 1) return;
        setState(() {
          _sbPosted = true;
          _potBb = 0.5;
        });
      });
    }
  }

  void _postBigBlind() {
    setState(() {
      _bbPosted = true;
      _potBb = 1.5;
    });
  }

  void _selectAnswer(String choice) {
    setState(() {
      _selectedChoice = choice;
      _questionCorrect = choice == _correctAnswer;
      _questionFeedback = _questionCorrect
          ? 'Correct · $_explanation'
          : 'Try again · the blinds seeded the pot.';
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
      _sbPosted = false;
      _sbAnimationScheduled = false;
      _bbPosted = false;
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
      final isHero = index == _bigBlindSeat;
      final isSb = index == _smallBlindSeat;
      return SeatVisualState(
        seatIndex: index,
        isActive: isHero,
        isFolded: false,
        isActed:
            (isSb && _sbPosted) ||
            (isHero && (_bbPosted || _currentStepIndex == 2)),
        isAllIn: false,
      );
    });
  }

  List<Widget> _legendChips() {
    return const [
      _LegendChip(label: 'Button', color: Color(0xFFE6B800)),
      _LegendChip(label: 'Small Blind', color: Color(0xFF4DB0FF)),
      _LegendChip(label: 'Big Blind (You)', color: Color(0xFF4CAF50)),
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
              if (seatPositions.length > _bigBlindSeat)
                Positioned(
                  left: seatPositions[_bigBlindSeat].dx - 48,
                  top: seatPositions[_bigBlindSeat].dy + 8,
                  child: _SeatLabel(
                    label: 'You • BB',
                    style: LessonTypography.subtitle(context),
                  ),
                ),
              if (seatPositions.length > _smallBlindSeat)
                Positioned(
                  left: seatPositions[_smallBlindSeat].dx - 48,
                  top: seatPositions[_smallBlindSeat].dy + 8,
                  child: _SeatLabel(
                    label: 'Small Blind',
                    style: LessonTypography.subtitle(context),
                  ),
                ),
              if (seatPositions.length > _smallBlindSeat)
                Positioned(
                  left: seatPositions[_smallBlindSeat].dx - 22,
                  top: seatPositions[_smallBlindSeat].dy - 38,
                  child: LessonChipMoveTransition(
                    active: _sbPosted,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '0.5 BB',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: layout.boardPosition.dx - 50,
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
                  child: Text(
                    'Pot: ${_potBb.toStringAsFixed(1)} BB',
                    style: LessonTypography.subtitle(context),
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
      title: 'You are seated as the Big Blind at a 6-max table.',
      bodyBuilder: (context, controller) => [
        Text(
          'The button sits directly to your right, ready to initiate action.',
          style: LessonTypography.body(context),
        ),
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Show the forced bets',
          onPressed: controller.advance,
        ),
      ],
      onEnter: () => _handleStepEnter(0),
    ),
    LessonStep(
      metaLabel: 'Step 1',
      title: 'Small Blind posts 0.5 BB to seed the pot.',
      bodyBuilder: (context, controller) {
        final isReady = _sbPosted;
        return [
          Text(
            'Pot is now ${_potBb.toStringAsFixed(1)} BB.',
            style: LessonTypography.body(context),
          ),
          const SizedBox(height: lessonSpacingMedium),
          LessonActionButton(
            label: 'Continue',
            enabled: isReady,
            helperText: isReady ? null : 'Wait for SB to finish posting.',
            onPressed: controller.advance,
          ),
        ];
      },
      onEnter: () => _handleStepEnter(1),
    ),
    LessonStep(
      metaLabel: 'Step 2',
      title: 'Post your 1.0 BB so the blinds are covered.',
      bodyBuilder: (context, controller) {
        return [
          LessonActionButton(
            label: _bbPosted ? 'Big Blind posted' : 'Post 1.0 BB',
            enabled: !_bbPosted,
            onPressed: _bbPosted ? null : _postBigBlind,
          ),
          if (_bbPosted) ...[
            const SizedBox(height: lessonSpacingMedium),
            Text(
              'Pot is now ${_potBb.toStringAsFixed(1)} BB.',
              style: LessonTypography.body(context),
            ),
            const SizedBox(height: lessonSpacingMedium),
            LessonActionButton(
              label: 'Ask the pot question',
              onPressed: controller.advance,
            ),
          ],
        ];
      },
      onEnter: () => _handleStepEnter(2),
    ),
    LessonStep(
      metaLabel: 'Gate',
      title: 'Pot now equals ${_potBb.toStringAsFixed(1)} BB.',
      gateEngagementConfig: const GateEngagementConfig(),
      countsAsGate: true,
      bodyBuilder: (context, controller) => [
        Text(_questionText, style: LessonTypography.subtitle(context)),
        const SizedBox(height: lessonSpacingMedium),
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
        }),
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
      onEnter: () => _handleStepEnter(3),
    ),
    LessonStep(
      metaLabel: 'Purpose',
      title:
          'Forced bets keep action flowing and reward players who cover the blinds.',
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: 'Finish explanation',
          onPressed: controller.advance,
        ),
      ],
      onEnter: () => _handleStepEnter(4),
    ),
    LessonStep(
      metaLabel: 'Completion',
      title: 'Nice work. The table is reset and you are ready for drills.',
      bodyBuilder: (context, controller) => [
        const SizedBox(height: lessonSpacingMedium),
        LessonActionButton(
          label: _isCompleting ? 'Wrapping up…' : 'Finish',
          onPressed: _isCompleting ? null : _completeScenario,
        ),
      ],
      onEnter: () => _handleStepEnter(5),
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
