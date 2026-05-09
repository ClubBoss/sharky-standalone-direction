import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverMixedCheckpointScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverMixedCheckpointScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverMixedCheckpointScenarioScreen> createState() =>
      _RiverMixedCheckpointScenarioScreenState();
}

class _RiverMixedCheckpointScenarioScreenState
    extends State<RiverMixedCheckpointScenarioScreen> {
  final _gateKeys = <String, bool>{};
  final _gatePulses = <String, bool>{};

  final _gates = <_CheckpointGate>[..._CheckpointGate.all];

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  void _resetScenarioState() {
    setState(() {
      _gateKeys.clear();
      _gatePulses.clear();
    });
  }

  void _selectGateChoice(
    _CheckpointGate gate,
    String choice,
    LessonStepController controller,
  ) {
    final correct = choice == gate.correct;
    setState(() {
      _gateKeys[gate.id] = correct;
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    if (_gatePulses[gate.id] != true) {
      _gatePulses[gate.id] = true;
      controller.showSuccessFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = <LessonStep>[
      LessonStep(
        metaLabel: 'Checkpoint',
        title: 'Mixed river assessment',
        bodyBuilder: (context, controller) {
          return [
            Text(
              'Blend blocker jams, thin value, bluffcatch, and sizing logic into one river checkpoint.',
              style: LessonTypography.body(context),
            ),
            const SizedBox(height: lessonSpacingMedium),
            LessonNumericText(
              'River spots covered: ${_gates.length}',
              style: LessonTypography.subtitle(context),
            ),
            const SizedBox(height: lessonSpacingMedium),
            LessonActionButton(
              label: 'Launch the mixed gates',
              onPressed: controller.advance,
            ),
          ];
        },
      ),
    ];

    for (final gate in _gates) {
      steps.add(
        LessonStep(
          metaLabel: gate.metaLabel,
          title: gate.title,
          gateEngagementConfig: GateEngagementConfig(
            comboEligible: true,
            hintText: gate.hint,
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) => [
            const SizedBox(height: lessonSpacingSmall),
            ...gate.choices.map((choice) {
              final selected =
                  _gateKeys[gate.id] == true && gate.correct == choice;
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
                  onPressed: () => _selectGateChoice(gate, choice, controller),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(choice, style: LessonTypography.body(context)),
                  ),
                ),
              );
            }),
            if (_gateKeys[gate.id] == true)
              LessonActionButton(
                label: gate.continueLabel,
                onPressed: controller.advance,
              ),
          ],
        ),
      );
    }

    steps.add(
      LessonStep(
        metaLabel: 'Finish',
        title: 'River mixed checkpoint complete',
        showSessionSummary: true,
        completionActions: CompletionActions(
          showReplay: true,
          showNext: true,
          onReplay: _resetScenarioState,
          onNext: _goToNextLesson,
        ),
        bodyBuilder: (context, controller) {
          return [
            Text(
              'Solid river instincts keep thin value, bluffcatch, and blocker jams in harmony.',
              style: LessonTypography.body(context),
            ),
          ];
        },
      ),
    );

    return LessonStepSequence(
      lessonModuleId: widget.moduleId,
      tableArea: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.green.shade900,
        ),
        child: Center(
          child: Text(
            widget.moduleTitle,
            style: LessonTypography.body(context),
          ),
        ),
      ),
      legendChips: const [Text('River'), Text('Checkpoint')],
      steps: steps,
    );
  }
}

class _CheckpointGate {
  const _CheckpointGate({
    required this.id,
    required this.metaLabel,
    required this.title,
    required this.choices,
    required this.correct,
    required this.hint,
    required this.continueLabel,
  });

  final String id;
  final String metaLabel;
  final String title;
  final List<String> choices;
  final String correct;
  final String hint;
  final String continueLabel;

  static const all = [
    _CheckpointGate(
      id: 'value_vs_bluff',
      metaLabel: 'Value vs Bluff',
      title: 'Thin value or bluff on a dry river?',
      choices: ['Bet thin value', 'Bluff wide', 'Check back'],
      correct: 'Bet thin value',
      hint: 'Dry rivers with blockers favor thin value bets.',
      continueLabel: 'Keep thin value',
    ),
    _CheckpointGate(
      id: 'checkback',
      metaLabel: 'Check-back',
      title: 'Check-back when thin value still shines?',
      choices: ['Check back', 'Polarize', 'Fold'],
      correct: 'Check back',
      hint: 'Check-backs preserve pot control when showdown value is limited.',
      continueLabel: 'Control the pot',
    ),
    _CheckpointGate(
      id: 'bluff_selection',
      metaLabel: 'Bluff selection',
      title: 'Bluff when blockers help?',
      choices: ['Bluff selectively', 'Value bet small', 'Check-fold'],
      correct: 'Bluff selectively',
      hint: 'Blockers legitimize selective bluffs.',
      continueLabel: 'Apply the bluff',
    ),
    _CheckpointGate(
      id: 'bluffcatch',
      metaLabel: 'Bluffcatch',
      title: 'Call with blockers and pot odds?',
      choices: ['Call with blockers', 'Raise polarized', 'Fold'],
      correct: 'Call with blockers',
      hint: 'Blockers reduce combos and improve pot odds.',
      continueLabel: 'Lean on blockers',
    ),
    _CheckpointGate(
      id: 'overbet',
      metaLabel: 'Overbet',
      title: 'Overbet or stay standard?',
      choices: ['Overbet', 'Standard bet', 'Check-call'],
      correct: 'Overbet',
      hint: 'Overbets polarize when you block draws.',
      continueLabel: 'Polarize the pot',
    ),
    _CheckpointGate(
      id: 'standard',
      metaLabel: 'Standard sizing',
      title: 'Opponent bets small—standard response?',
      choices: ['Standard size', 'Raise big', 'Fold'],
      correct: 'Standard size',
      hint:
          'Small bets often beg for standard sizing to keep the story honest.',
      continueLabel: 'Stick to standard',
    ),
    _CheckpointGate(
      id: 'jam_blocker',
      metaLabel: 'Jam vs blocker',
      title: 'Jam river when you block the nuts?',
      choices: ['Jam with blockers', 'Check-call', 'Fold'],
      correct: 'Jam with blockers',
      hint: 'Blockers let you pack a polarizing jam.',
      continueLabel: 'Jam confidently',
    ),
    _CheckpointGate(
      id: 'jam_without',
      metaLabel: 'Jam without blockers',
      title: 'No blockers—fold or call?',
      choices: ['Fold tight', 'Call light', 'Raise'],
      correct: 'Fold tight',
      hint: 'Without blockers, protect stack and fold to pressure.',
      continueLabel: 'Preserve the stack',
    ),
  ];
}
