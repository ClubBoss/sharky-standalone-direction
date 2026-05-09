import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class TurnMixedCheckpointScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const TurnMixedCheckpointScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<TurnMixedCheckpointScenarioScreen> createState() =>
      _TurnMixedCheckpointScenarioScreenState();
}

class _TurnMixedCheckpointScenarioScreenState
    extends State<TurnMixedCheckpointScenarioScreen> {
  final _gates = <_TurnGate>[..._TurnGate.all];
  final _passed = <String, bool>{};
  final _pulses = <String, bool>{};

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _recordChoice(
    _TurnGate gate,
    String choice,
    LessonStepController controller,
  ) {
    final correct = choice == gate.correct;
    setState(() {
      _passed[gate.id] = correct;
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    if (_pulses[gate.id] != true) {
      _pulses[gate.id] = true;
      controller.showSuccessFeedback();
    }
  }

  void _reset() {
    setState(() {
      _passed.clear();
      _pulses.clear();
    });
  }

  void _nextLesson() {
    final next = _nextModuleId;
    if (next == null) return;
    navigateToTheorySession(context, next);
  }

  @override
  Widget build(BuildContext context) {
    final steps = <LessonStep>[
      LessonStep(
        metaLabel: 'Checkpoint',
        title: 'Turn mixed checkpoint',
        bodyBuilder: (context, controller) {
          return [
            Text(
              'Blend barrels, sizing, blockers, plan tweaks and value targeting into one turn summary.',
              style: LessonTypography.body(context),
            ),
            const SizedBox(height: lessonSpacingMedium),
            LessonNumericText(
              'Turn spots: ${_gates.length}',
              style: LessonTypography.subtitle(context),
            ),
            const SizedBox(height: lessonSpacingMedium),
            LessonActionButton(
              label: 'Charge the turn gates',
              onPressed: controller.advance,
            ),
          ];
        },
      ),
    ];

    for (final gate in _gates) {
      steps.add(
        LessonStep(
          metaLabel: gate.meta,
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
                  _passed[gate.id] == true && gate.correct == choice;
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
                  onPressed: () => _recordChoice(gate, choice, controller),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(choice, style: LessonTypography.body(context)),
                  ),
                ),
              );
            }),
            if (_passed[gate.id] == true)
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
        metaLabel: 'Complete',
        title: 'Turn mixed checkpoint complete',
        showSessionSummary: true,
        completionActions: CompletionActions(
          showReplay: true,
          showNext: true,
          onReplay: _reset,
          onNext: _nextLesson,
        ),
        bodyBuilder: (context, controller) {
          return [
            Text(
              'Turn instincts stay sharp when you combine barrel vs check, blockers, sizing, and exploitation.',
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
          color: Colors.teal.shade900,
        ),
        child: Center(
          child: Text(
            widget.moduleTitle,
            style: LessonTypography.body(context),
          ),
        ),
      ),
      legendChips: const [Text('Turn'), Text('Checkpoint')],
      steps: steps,
    );
  }
}

class _TurnGate {
  const _TurnGate({
    required this.id,
    required this.meta,
    required this.title,
    required this.choices,
    required this.correct,
    required this.hint,
    required this.continueLabel,
  });

  final String id;
  final String meta;
  final String title;
  final List<String> choices;
  final String correct;
  final String hint;
  final String continueLabel;

  static const all = [
    _TurnGate(
      id: 'barrel_vs_check',
      meta: 'Barrel vs Check',
      title: 'Barrel or check on the turn?',
      choices: ['Barrel small', 'Check back', 'Pot-control bet'],
      correct: 'Barrel small',
      hint: 'Barrels keep pressure if the opponent folds too often.',
      continueLabel: 'Press the barrel',
    ),
    _TurnGate(
      id: 'sizing_texture',
      meta: 'Sizing vs Texture',
      title: 'Adjust sizing to texture?',
      choices: ['Size big', 'Size standard', 'Check'],
      correct: 'Size big',
      hint:
          'Wet textures ask for bigger sizing, dry textures thrive on standard.',
      continueLabel: 'Size appropriately',
    ),
    _TurnGate(
      id: 'blocker_value',
      meta: 'Blocker Value',
      title: 'Blockers let you polarize?',
      choices: ['Polarize with blockers', 'Value bet small', 'Check'],
      correct: 'Polarize with blockers',
      hint:
          'Blockers allow polarized bets when the opponent cannot hold combos.',
      continueLabel: 'Polarize confidently',
    ),
    _TurnGate(
      id: 'plan_building',
      meta: 'Plan',
      title: 'Stick to the plan builder line?',
      choices: ['Stick to plan', 'Change line', 'Fold'],
      correct: 'Stick to plan',
      hint: 'Plans keep sizing coherent across streets.',
      continueLabel: 'Hold the plan',
    ),
    _TurnGate(
      id: 'exploit_adjust',
      meta: 'Exploit Adjust',
      title: 'Exploit opponent overfolding?',
      choices: ['Increase bet freq', 'Check back', 'Fold'],
      correct: 'Increase bet freq',
      hint: 'Exploit folding tendencies with more bets.',
      continueLabel: 'Exploit the fold',
    ),
    _TurnGate(
      id: 'value_target',
      meta: 'Value Target',
      title: 'Value-target thin opponents?',
      choices: ['Value thin', 'Bluff', 'Check'],
      correct: 'Value thin',
      hint: 'Target opponents who call light.',
      continueLabel: 'Target value',
    ),
    _TurnGate(
      id: 'bluffcatch_threshold',
      meta: 'Bluffcatch',
      title: 'Call when block combos are few?',
      choices: ['Call', 'Raise', 'Fold'],
      correct: 'Call',
      hint: 'Few combos favor calls with blockers.',
      continueLabel: 'Call smart',
    ),
    _TurnGate(
      id: 'alternate_line',
      meta: 'Alt Line',
      title: 'Finish with a subtle value line?',
      choices: ['Lean value', 'Jam', 'Check-fold'],
      correct: 'Lean value',
      hint: 'Subtle value lines lock down thin cards.',
      continueLabel: 'Lean value',
    ),
  ];
}
