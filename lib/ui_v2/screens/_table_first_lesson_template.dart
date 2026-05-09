import 'package:flutter/material.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/components/lesson_overlay_helpers.dart';

/// Copy and rename this template when adding new table-first lessons.
class TableFirstLessonTemplateScreen extends StatelessWidget {
  const TableFirstLessonTemplateScreen({
    super.key,
    required this.moduleId,
    this.moduleTitle = 'Template Lesson',
  });

  final String moduleId;
  final String moduleTitle;

  void _resetScenarioState() {
    // TODO: reset pot, hero history, or any lesson-specific state here.
  }

  @override
  Widget build(BuildContext context) {
    return LessonStepSequence(
      lessonModuleId: moduleId,
      tableArea: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: AppColors.surfaceVariant,
        ),
        child: Center(
          child: Text(
            moduleTitle,
            style: LessonTypography.body(
              context,
            ).copyWith(color: Colors.white60),
          ),
        ),
      ),
      legendChips: const [Text('Hero'), Text('Position')],
      steps: [
        LessonStep(
          metaLabel: 'Overview',
          title: 'Template info',
          bodyBuilder: (context, controller) {
            return [
              Text(
                'Use LessonNumericText for numeric displays: ',
                style: LessonTypography.body(context),
              ),
              LessonNumericText('00', style: LessonTypography.title(context)),
            ];
          },
          onEnter: _resetScenarioState,
        ),
        LessonStep(
          metaLabel: 'Gate',
          title: 'Sample gate',
          gateEngagementConfig: const GateEngagementConfig(
            comboEligible: true,
            hintText: 'Half-pot is pot/2',
            showSuccessPulse: true,
          ),
          countsAsGate: true,
          bodyBuilder: (context, controller) {
            return [
              ElevatedButton(
                onPressed: controller.registerWrongAnswerHint,
                child: const Text('Wrong answer'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.advance,
                child: const Text('Correct'),
              ),
            ];
          },
        ),
        LessonStep(
          metaLabel: 'Finish',
          title: 'Template complete',
          showSessionSummary: true,
          completionActions: CompletionActions(
            showReplay: true,
            showNext: true,
            onReplay: _resetScenarioState,
            onNext: () {},
          ),
          bodyBuilder: (context, controller) {
            return [
              Text(
                'Lesson complete!',
                style: LessonTypography.subtitle(context),
              ),
            ];
          },
        ),
      ],
    );
  }
}
