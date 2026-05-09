import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverCheckbackVsValueScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverCheckbackVsValueScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverCheckbackVsValueScenarioScreen> createState() =>
      _RiverCheckbackVsValueScenarioScreenState();
}

class _RiverCheckbackVsValueScenarioScreenState
    extends State<RiverCheckbackVsValueScenarioScreen> {
  static const _gate1Question =
      'On a dry river with thin value, do you bet or check?';
  static const _gate2Question =
      'If you miss draws and bluff line looks thin, what is the safe call?';

  String? _gate1Choice;
  String? _gate2Choice;
  bool _gate1Complete = false;
  bool _gate2Complete = false;
  bool _gate1Pulse = false;
  bool _gate2Pulse = false;

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _resetScenarioState() {
    setState(() {
      _gate1Choice = null;
      _gate2Choice = null;
      _gate1Complete = false;
      _gate2Complete = false;
      _gate1Pulse = false;
      _gate2Pulse = false;
    });
  }

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  void _selectGateChoice(
    String choice,
    LessonStepController controller, {
    required bool valueGate,
  }) {
    final correct = valueGate
        ? choice == 'Bet thin value'
        : choice == 'Check/back';
    setState(() {
      if (valueGate) {
        _gate1Choice = choice;
        _gate1Complete = correct;
      } else {
        _gate2Choice = choice;
        _gate2Complete = correct;
      }
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    if (valueGate && !_gate1Pulse) {
      _gate1Pulse = true;
      controller.showSuccessFeedback();
    }
    if (!valueGate && !_gate2Pulse) {
      _gate2Pulse = true;
      controller.showSuccessFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LessonStepSequence(
      lessonModuleId: widget.moduleId,
      tableArea: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.teal.shade900,
        ),
        child: const Center(child: Text('River board review')),
      ),
      legendChips: const [Text('River'), Text('Value')],
      steps: [
        LessonStep(
          metaLabel: 'Setup',
          title: 'River stories guide thin value.',
          bodyBuilder: (context, controller) {
            return [
              Text(
                'You barely have showdown value but the board is dry—lean on thin bets when you still block draws.',
                style: LessonTypography.body(context),
              ),
              const SizedBox(height: lessonSpacingMedium),
              LessonActionButton(
                label: 'Frame the river narrative',
                onPressed: controller.advance,
              ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Gate',
          title: _gate1Question,
          gateEngagementConfig: const GateEngagementConfig(
            comboEligible: true,
            hintText: 'Thin value still wins when the board has no new draws.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...['Bet thin value', 'Check back', 'Bluff wider'].map((choice) {
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
                        _selectGateChoice(choice, controller, valueGate: true),
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
              if (_gate1Complete)
                LessonActionButton(
                  label: 'Lock in thin value',
                  onPressed: controller.advance,
                ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Gate',
          title: _gate2Question,
          gateEngagementConfig: const GateEngagementConfig(
            comboEligible: true,
            hintText: 'With no outs left, solid check-backs preserve stack.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...['Check/back', 'Small bluff', 'Polarize big'].map((choice) {
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
                        _selectGateChoice(choice, controller, valueGate: false),
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
              if (_gate2Complete)
                LessonActionButton(
                  label: 'Finish the river lesson',
                  onPressed: controller.advance,
                ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Finish',
          title: 'River discipline locked',
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
                'Check-backs protect stack when draws miss; thin value bets keep you honest when still blocking draws.',
                style: LessonTypography.body(context),
              ),
            ];
          },
        ),
      ],
    );
  }
}
