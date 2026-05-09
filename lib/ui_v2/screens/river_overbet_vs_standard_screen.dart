import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverOverbetVsStandardScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverOverbetVsStandardScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverOverbetVsStandardScenarioScreen> createState() =>
      _RiverOverbetVsStandardScenarioScreenState();
}

class _RiverOverbetVsStandardScenarioScreenState
    extends State<RiverOverbetVsStandardScenarioScreen> {
  static const _gate1Question =
      'Does a micro overbet on the river polarize or cap value?';
  static const _gate2Question =
      'When the opponent bets small, do you raise big or keep it standard?';

  String? _gate1Choice;
  String? _gate2Choice;
  bool _gate1Solved = false;
  bool _gate2Solved = false;
  bool _gate1Pulse = false;
  bool _gate2Pulse = false;

  String? get _nextModuleId => nextTableFirstLessonId(widget.moduleId);

  void _goToNextLesson() {
    final nextId = _nextModuleId;
    if (nextId == null) return;
    navigateToTheorySession(context, nextId);
  }

  void _resetScenarioState() {
    setState(() {
      _gate1Choice = null;
      _gate2Choice = null;
      _gate1Solved = false;
      _gate2Solved = false;
      _gate1Pulse = false;
      _gate2Pulse = false;
    });
  }

  void _selectGateChoice(
    String choice,
    LessonStepController controller, {
    required bool firstGate,
  }) {
    final correct = firstGate
        ? choice == 'Polarize with overbet'
        : choice == 'Keep value standard';
    setState(() {
      if (firstGate) {
        _gate1Choice = choice;
        _gate1Solved = correct;
      } else {
        _gate2Choice = choice;
        _gate2Solved = correct;
      }
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    if (firstGate && !_gate1Pulse) {
      _gate1Pulse = true;
      controller.showSuccessFeedback();
    }
    if (!firstGate && !_gate2Pulse) {
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
          color: Colors.deepPurple.shade800,
        ),
        child: const Center(child: Text('Overbet vs standard')),
      ),
      legendChips: const [Text('River'), Text('Polarize')],
      steps: [
        LessonStep(
          metaLabel: 'Setup',
          title: 'Choose polarization with care.',
          bodyBuilder: (context, controller) {
            return [
              Text(
                'Overbets polarize your range; keep sizing standard when you need compact value.',
                style: LessonTypography.body(context),
              ),
              const SizedBox(height: lessonSpacingMedium),
              LessonActionButton(
                label: 'Consider your sizing',
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
            hintText:
                'Overbets polarize when you block draws, so use them sparingly.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            final choices = [
              'Polarize with overbet',
              'Value bet standard',
              'Check/call',
            ];
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...choices.map((choice) {
                final selected = _gate1Choice == choice;
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
                        _selectGateChoice(choice, controller, firstGate: true),
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
              if (_gate1Solved)
                LessonActionButton(
                  label: 'Cap your value line',
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
            hintText:
                'When the opponent bets small, stick to compact value unless you have blockers.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            final choices = [
              'Keep value standard',
              'Raise big polarize',
              'Fold immediately',
            ];
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...choices.map((choice) {
                final selected = _gate2Choice == choice;
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
                        _selectGateChoice(choice, controller, firstGate: false),
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
              if (_gate2Solved)
                LessonActionButton(
                  label: 'Close the sizing loop',
                  onPressed: controller.advance,
                ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Finish',
          title: 'Polarize only when it earns value.',
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
                'Overbets polarize; standard sizing locks in thin value and keeps the line believable.',
                style: LessonTypography.body(context),
              ),
            ];
          },
        ),
      ],
    );
  }
}
