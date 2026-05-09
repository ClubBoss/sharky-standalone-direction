import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverBluffcatchThresholdsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverBluffcatchThresholdsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverBluffcatchThresholdsScenarioScreen> createState() =>
      _RiverBluffcatchThresholdsScenarioScreenState();
}

class _RiverBluffcatchThresholdsScenarioScreenState
    extends State<RiverBluffcatchThresholdsScenarioScreen> {
  static const _gate1Question =
      'Do you call a river bet when your blockers limit combos?';
  static const _gate2Question =
      'If facing a second barrel, do you fold, call, or raise?';

  String? _gate1Choice;
  String? _gate2Choice;
  bool _gate1Success = false;
  bool _gate2Success = false;
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
      _gate1Success = false;
      _gate2Success = false;
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
        ? choice == 'Call the blocker bet'
        : choice == 'Fold to second barrel';
    setState(() {
      if (firstGate) {
        _gate1Choice = choice;
        _gate1Success = correct;
      } else {
        _gate2Choice = choice;
        _gate2Success = correct;
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
          color: Colors.blueGrey.shade900,
        ),
        child: const Center(child: Text('Bluffcatch thresholds')),
      ),
      legendChips: const [Text('River'), Text('Bluffcatch')],
      steps: [
        LessonStep(
          metaLabel: 'Intro',
          title: 'Bluffcatch thresholds guard stack risk.',
          bodyBuilder: (context, controller) {
            return [
              Text(
                'River blockers and pot odds guide whether to call a lone barrel or fold to aggression.',
                style: LessonTypography.body(context),
              ),
              const SizedBox(height: lessonSpacingMedium),
              LessonActionButton(
                label: 'Survey the river sizing',
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
                'Blockers reduce combos, so a call is safer when odds are decent.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...['Call the blocker bet', 'Fold to size', 'Raise lefty'].map((
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
              if (_gate1Success)
                LessonActionButton(
                  label: 'Secure pot odds',
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
                'Second barrels demand tighter thresholds; folding protects thin equity.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ...[
                'Fold to second barrel',
                'Call with blocker',
                'Raise & polarize',
              ].map((choice) {
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
              if (_gate2Success)
                LessonActionButton(
                  label: 'End bluffcatch puzzle',
                  onPressed: controller.advance,
                ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Finish',
          title: 'Thresholds respected.',
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
                'Call or fold based on blockers, pot odds, and opponent sizing when bluffcatching.',
                style: LessonTypography.body(context),
              ),
            ];
          },
        ),
      ],
    );
  }
}
