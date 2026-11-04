import 'package:flutter/foundation.dart';

import 'act0_lesson_runner_shell_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_table_choreography_contract_v1.dart';

/// Read-only inventory for one task/attempt. The existing Runner owns every
/// projection. This adapter never supplies cards, actors, amounts or grades.
@immutable
class Act0F7SceneSourceV1 {
  Act0F7SceneSourceV1({
    required this.scenarioKey,
    required Map<String, Act0TableStateV1> tables,
  }) : tables = Map.unmodifiable(tables);

  factory Act0F7SceneSourceV1.fromTask(
    Act0LessonTaskV1 task, {
    required String scenarioKey,
  }) => Act0F7SceneSourceV1.fromRunner(
    runner: task.runner,
    taskFamily: task.resolvedTaskFamily,
    scenarioKey: scenarioKey,
  );

  /// Use the actual runtime owner for generated Placement/replay runners too;
  /// never recover runtime inputs by looking up a task in the sample catalog.
  factory Act0F7SceneSourceV1.fromRunner({
    required Act0RunnerStateV1 runner,
    required Act0TaskFamilyV1? taskFamily,
    required String scenarioKey,
  }) {
    final tables = <String, Act0TableStateV1>{
      'authored': runner.table,
      for (var i = 0; i < runner.teachingSteps.length; i++)
        'teaching/$i/raw': runner.teachingSteps[i].table ?? runner.table,
      for (var i = 0; i < runner.teachingSteps.length; i++)
        'teaching/$i/projected': act0TeachingTableForRunnerV1(
          runner.table,
          runner.teachingSteps[i],
        ),
      for (final option in runner.options)
        'feedback/${option.id}': act0FeedbackTableForRunnerV1(
          runner: runner.copyWith(
            phase: Act0LessonPhaseV1.review,
            selectedOptionId: option.id,
            teachingStepIndex: runner.teachingSteps.length,
          ),
          taskFamily: taskFamily,
        ),
      'review': act0FeedbackTableForRunnerV1(
        runner: runner.copyWith(phase: Act0LessonPhaseV1.review),
        taskFamily: taskFamily,
      ),
    };
    final plan = act0TableChoreographyPlanForTableV1(runner.table);
    if (plan != null) {
      for (var i = 0; i < plan.beats.length; i++) {
        tables['choreography/$i'] = act0TableForChoreographyFrameV1(
          runner.table,
          act0TableChoreographyFrameAfterBeatV1(plan, i),
        );
      }
    }
    return Act0F7SceneSourceV1(scenarioKey: scenarioKey, tables: tables);
  }

  /// Include stable task identity and a real attempt/replay generation. A task
  /// transition starts a new scene lease; feedback and assistance do not.
  final String scenarioKey;
  final Map<String, Act0TableStateV1> tables;
}
