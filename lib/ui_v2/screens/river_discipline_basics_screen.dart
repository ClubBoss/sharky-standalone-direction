import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';
import 'package:poker_analyzer/ui_v2/screens/table_first_navigation.dart';
import 'package:poker_analyzer/training/lesson_module_ids.dart';

class RiverDisciplineBasicsScenarioScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const RiverDisciplineBasicsScenarioScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  State<RiverDisciplineBasicsScenarioScreen> createState() =>
      _RiverDisciplineBasicsScenarioScreenState();
}

class _RiverDisciplineBasicsScenarioScreenState
    extends State<RiverDisciplineBasicsScenarioScreen> {
  static const _gate1Question =
      'When your river hand still has thin value, do you bet or bluff?';
  static const _gate2Question =
      'After missing draws with weak showdown, what is the default move?';
  final List<String> _valueChoices = const ['Value thin', 'Bluff it'];
  final List<String> _bluffChoices = const ['Check more', 'Fire a bluff'];

  String? _gate1Choice;
  String? _gate2Choice;
  bool _gate1Correct = false;
  bool _gate2Correct = false;
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
      _gate1Correct = false;
      _gate2Correct = false;
      _gate1Pulse = false;
      _gate2Pulse = false;
    });
  }

  void _selectGateChoice(
    String choice,
    LessonStepController controller, {
    required bool isValueQuestion,
  }) {
    final correct = isValueQuestion
        ? choice == 'Value thin'
        : choice == 'Check more';
    setState(() {
      if (isValueQuestion) {
        _gate1Choice = choice;
        _gate1Correct = correct;
      } else {
        _gate2Choice = choice;
        _gate2Correct = correct;
      }
    });
    if (!correct) {
      controller.registerWrongAnswerHint();
      return;
    }
    controller.clearWrongAnswerHint();
    if (isValueQuestion && !_gate1Pulse) {
      _gate1Pulse = true;
      controller.showSuccessFeedback();
    }
    if (!isValueQuestion && !_gate2Pulse) {
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
          color: Colors.deepPurple.shade700,
        ),
        child: const Center(child: Text('River discipline table')),
      ),
      legendChips: const [Text('River'), Text('Hero')],
      steps: [
        LessonStep(
          metaLabel: 'Focus',
          title: 'River discipline keeps thin value in check.',
          bodyBuilder: (context, controller) {
            return [
              Text(
                'River planning keeps your bets precise and your bluffs clear.',
                style: LessonTypography.body(context),
              ),
              const SizedBox(height: lessonSpacingMedium),
              LessonActionButton(
                label: 'Start the river plan',
                onPressed: controller.advance,
              ),
            ];
          },
          onEnter: _resetScenarioState,
        ),
        LessonStep(
          metaLabel: 'Gate',
          title: _gate1Question,
          gateEngagementConfig: const GateEngagementConfig(
            comboEligible: true,
            hintText:
                'Thin value keeps you betting when you still block draws.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ..._valueChoices.map((choice) {
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
                    onPressed: () => _selectGateChoice(
                      choice,
                      controller,
                      isValueQuestion: true,
                    ),
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
              if (_gate1Correct)
                LessonActionButton(
                  label: 'Continue',
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
            hintText: 'Missing showdown value means you slow down.',
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              const SizedBox(height: lessonSpacingSmall),
              ..._bluffChoices.map((choice) {
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
                    onPressed: () => _selectGateChoice(
                      choice,
                      controller,
                      isValueQuestion: false,
                    ),
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
              if (_gate2Correct)
                LessonActionButton(
                  label: 'Wrap river discipline',
                  onPressed: controller.advance,
                ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Complete',
          title: 'River discipline locked in.',
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
                'River discipline only penalizes bluffs when showdown value is thin.',
                style: LessonTypography.body(context),
              ),
            ];
          },
        ),
      ],
    );
  }
}
