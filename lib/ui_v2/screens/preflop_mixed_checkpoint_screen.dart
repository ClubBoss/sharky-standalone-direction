import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';

class PreflopMixedCheckpointScenarioScreen extends StatefulWidget {
  const PreflopMixedCheckpointScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  final String moduleId;
  final String moduleTitle;

  @override
  State<PreflopMixedCheckpointScenarioScreen> createState() =>
      _PreflopMixedCheckpointScenarioScreenState();
}

class _PreflopGate {
  const _PreflopGate({
    required this.title,
    required this.options,
    required this.correctAnswer,
    required this.hint,
  });

  final String title;
  final List<String> options;
  final String correctAnswer;
  final String hint;
}

class _PreflopMixedCheckpointScenarioScreenState
    extends State<PreflopMixedCheckpointScenarioScreen> {
  static final _gates = [
    _PreflopGate(
      title: 'Gate 1 · Forced bets protect the blinds.',
      options: [
        'Bring the pot to life with a smaller than usual sized raise.',
        'Open to 2x BB and fold if punished.',
        'Fold from the blinds and wait for position.',
      ],
      correctAnswer: 'Open to 2x BB and fold if punished.',
      hint: 'SB/BB forced bets punish limp-heavy plans.',
    ),
    _PreflopGate(
      title: 'Gate 2 · BTN closing the action matters.',
      options: [
        'Btn should open after BTN opponents only.',
        'Button last to act should cut pot by 3-betting frequently.',
        'When you are BTN, maximize opening range since you see all action.',
      ],
      correctAnswer:
          'When you are BTN, maximize opening range since you see all action.',
      hint: 'Action order offers leverage in position.',
    ),
    _PreflopGate(
      title: 'Gate 3 · IP vs OOP alters aggression.',
      options: [
        'In position, bet to build pots; out of position, defend narrowly.',
        'Out of position, expand to 3-bet often to seize initiative.',
        'IP means you should defend by checking most hands.',
      ],
      correctAnswer:
          'In position, bet to build pots; out of position, defend narrowly.',
      hint: 'Position gives control; OOP demands selectivity.',
    ),
    _PreflopGate(
      title: 'Gate 4 · Open sizing should match threat.',
      options: [
        'Squeeze-sized opens keep odds the same regardless of texture.',
        'Size opens bigger from tighter ranges, smaller from bluff-heavy ranges.',
        'Always open 2.75x from every seat.',
      ],
      correctAnswer:
          'Size opens bigger from tighter ranges, smaller from bluff-heavy ranges.',
      hint: 'Range quality should dictate the raise size.',
    ),
    _PreflopGate(
      title: 'Gate 5 · Call vs 3-bet defense.',
      options: [
        'Call light when you have position; fold the rest.',
        'Call with balanced hands and raise w/ blockers when 3-bet is wide.',
        'Always 4-bet to deny fold equity.',
      ],
      correctAnswer:
          'Call with balanced hands and raise w/ blockers when 3-bet is wide.',
      hint: '3-bets need plan post-flop.',
    ),
    _PreflopGate(
      title: 'Gate 6 · 3-bet sizing perception.',
      options: [
        '3-bet blocker hands small to keep opponents guessing.',
        'Use huge 3-bets only when deep-stacked.',
        '3-bet only when your range is nuts-heavy.',
      ],
      correctAnswer: '3-bet blocker hands small to keep opponents guessing.',
      hint: 'Sizing influences opponent fold odds.',
    ),
    _PreflopGate(
      title: 'Gate 7 · Fold thresholds keep ranges honest.',
      options: [
        'Fold wide to avoid over-commitment.',
        'Fold tighter when opponents pick up aggression.',
        'Never fold to 3-bets; just take it down post-flop.',
      ],
      correctAnswer: 'Fold tighter when opponents pick up aggression.',
      hint: 'Adjust to opponent frequency quickly.',
    ),
    _PreflopGate(
      title: 'Gate 8 · Squeeze awareness.',
      options: [
        'Fold to squeezes if you lack blockers.',
        'Squeeze bluff when you have blockers and initiative.',
        'Squeeze the exact same hands from every seat.',
      ],
      correctAnswer: 'Squeeze bluff when you have blockers and initiative.',
      hint: 'Blocked combos and initiative make the squeeze credible.',
    ),
  ];

  final Map<int, String> _choices = {};
  final Map<int, bool> _solved = {};

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  void _resetScenarioState() {
    setState(() {
      _choices.clear();
      _solved.clear();
    });
  }

  void _selectGateChoice(
    int gateIndex,
    String choice,
    LessonStepController controller,
  ) {
    final gate = _gates[gateIndex];
    final correct = gate.correctAnswer == choice;
    setState(() {
      _choices[gateIndex] = choice;
      if (correct) {
        _solved[gateIndex] = true;
      }
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    controller.showSuccessFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return LessonStepSequence(
      lessonModuleId: widget.moduleId,
      tableArea: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [AppColors.surfaceVariant, AppColors.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(child: Text('Preflop mixed checkpoint')),
      ),
      legendChips: const [Text('Preflop'), Text('Checkpoint')],
      steps: [
        for (var index = 0; index < _gates.length; index++)
          LessonStep(
            metaLabel: 'Gate',
            title: _gates[index].title,
            gateEngagementConfig: GateEngagementConfig(
              hintText: _gates[index].hint,
            ),
            countsAsGate: true,
            bodyBuilder: (context, controller) {
              final options = _gates[index].options;
              return [
                const SizedBox(height: lessonSpacingSmall),
                ...options.map((choice) {
                  final selected = _choices[index] == choice;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: lessonSpacingSmall),
                    child: OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selected
                            ? Colors.white.withOpacity(0.08)
                            : null,
                        foregroundColor: selected ? Colors.white : null,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          _selectGateChoice(index, choice, controller),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          choice,
                          style: LessonTypography.body(context),
                        ),
                      ),
                    ),
                  );
                }),
                if (_solved[index] == true)
                  LessonActionButton(
                    label: 'Lock in this plan',
                    onPressed: controller.advance,
                  ),
              ];
            },
          ),
        LessonStep(
          metaLabel: 'Finish',
          title: 'Preflop mixed checkpoint complete',
          showSessionSummary: true,
          completionActions: CompletionActions(
            showReplay: true,
            showNext: true,
            onReplay: _resetScenarioState,
            onNext: _goToNextLesson,
          ),
          bodyBuilder: (context, controller) => [
            Text(
              'You stayed honest with opens, defenses, and squeezes—well timed preflop work.',
              style: LessonTypography.body(context),
            ),
          ],
        ),
      ],
    );
  }
}
