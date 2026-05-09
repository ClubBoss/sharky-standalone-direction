import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverBluffSelectionScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverBluffSelectionScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverBluffSelectionScenarioScreen> createState() =>
      _RiverBluffSelectionScenarioScreenState();
}

class _RiverBluffSelectionScenarioScreenState
    extends State<RiverBluffSelectionScenarioScreen> {
  static const _gate1Question =
      'Do you bluff when you block the nuts but lack showdown value?';
  static const _gate2Question =
      'If opponent vacates the pot on the river, what line keeps you honest?';

  String? _gate1Choice;
  String? _gate2Choice;
  bool _gate1Complete = false;
  bool _gate2Complete = false;
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
      _gate1Complete = false;
      _gate2Complete = false;
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
        ? choice == 'Bluff selectively'
        : choice == 'Lean on value';
    setState(() {
      if (gateOne) {
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
          color: Colors.indigo.shade900,
        ),
        child: const Center(child: Text('Blockers guide the bluff')),
      ),
      legendChips: const [Text('River'), Text('Bluff')],
      steps: [
        LessonStep(
          metaLabel: 'Lead-in',
          title: 'River blockers shape bluff frequency.',
          bodyBuilder: (context, controller) {
            return [
              Text(
                'When you block the nuts, bluffing is profitable if the board is quiet. Otherwise lean on thin value.',
                style: LessonTypography.body(context),
              ),
              const SizedBox(height: lessonSpacingMedium),
              LessonActionButton(
                label: 'Frame the river story',
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
                'Blocking the nuts gives confidence to bluff selectively.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...['Bluff selectively', 'Check the nuts', 'Jam all-in'].map((
                choice,
              ) {
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
              if (_gate1Complete)
                LessonActionButton(
                  label: 'Continue with blockers',
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
            hintText: 'Weak-showdown river stories favor cautious lines.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...['Lean on value', 'Over-bluff', 'Overbet nuts'].map((choice) {
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
              if (_gate2Complete)
                LessonActionButton(
                  label: 'Wrap the bluff story',
                  onPressed: controller.advance,
                ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Finish',
          title: 'Bluff selection sealed.',
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
                'Blockers and lack of draws tell you whether to bluff or stick to thin value.',
                style: LessonTypography.body(context),
              ),
            ];
          },
        ),
      ],
    );
  }
}
