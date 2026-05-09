import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverJamVsBlockerScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverJamVsBlockerScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverJamVsBlockerScenarioScreen> createState() =>
      _RiverJamVsBlockerScenarioScreenState();
}

class _RiverJamVsBlockerScenarioScreenState
    extends State<RiverJamVsBlockerScenarioScreen> {
  static const _gate1Question =
      'Do you jam river with blockers when the opponent bets small?';
  static const _gate2Question =
      'When you lack blockers and the opponent jams, do you fold or call?';

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
    required bool gateOne,
  }) {
    final correct = gateOne
        ? choice == 'Jam with blockers'
        : choice == 'Fold tight';
    setState(() {
      if (gateOne) {
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
    if (gateOne && !_gate1Pulse) {
      _gate1Pulse = true;
      controller.showSuccessFeedback();
    }
    if (!gateOne && !_gate2Pulse) {
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
          color: Colors.deepOrange.shade900,
        ),
        child: const Center(child: Text('Jam vs blocker')),
      ),
      legendChips: const [Text('River'), Text('Jam vs blocker')],
      steps: [
        LessonStep(
          metaLabel: 'Setup',
          title: 'Blockers guide river jams.',
          bodyBuilder: (context, controller) {
            return [
              Text(
                'When you block the nuts and the opponent bets small, you can polarize with a jam. Without blockers, you tighten the line.',
                style: LessonTypography.body(context),
              ),
              const SizedBox(height: lessonSpacingMedium),
              LessonActionButton(
                label: 'Size up the river story',
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
            hintText: 'Blockers let you jam even when odds are thin.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            final options = [
              'Jam with blockers',
              'Value bet small',
              'Check-call',
            ];
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...options.map((choice) {
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
                        _selectGateChoice(choice, controller, gateOne: true),
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
                  label: 'Polarize with confidence',
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
            hintText: 'Without blockers, folding keeps you from overbluffing.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            final options = ['Fold tight', 'Call light', 'Raise polarized'];
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...options.map((choice) {
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
                        _selectGateChoice(choice, controller, gateOne: false),
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
                  label: 'Close the blocker line',
                  onPressed: controller.advance,
                ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Finish',
          title: 'Jam when blockers lead.',
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
                'Jam with blockers, fold without them—polarization depends on the blocker story.',
                style: LessonTypography.body(context),
              ),
            ];
          },
        ),
      ],
    );
  }
}
