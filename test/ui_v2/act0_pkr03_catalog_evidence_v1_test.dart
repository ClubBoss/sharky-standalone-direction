// PKR-03 inventory, not a declaration that an unproved hand is valid.
// Captures the full catalog and real consumer projections for poker review.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

void main() {
  test(
    'all authored tasks and consumer variants retain explicit proof status',
    () {
      final inventory = <Map<String, Object?>>[];
      for (final world in Act0ShellStateV1.sample.worlds) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final runner = task.runner;
            final states = <String, Act0TableStateV1>{
              'authored': runner.table,
              for (var i = 0; i < runner.teachingSteps.length; i++)
                'teaching/$i/raw':
                    runner.teachingSteps[i].table ?? runner.table,
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
                  taskFamily: task.resolvedTaskFamily,
                ),
              for (final option in runner.options)
                'repair/${option.id}': act0RepairTableForRunnerV1(
                  runner.table,
                  option,
                ),
            };
            final plan = act0TableChoreographyPlanForTableV1(runner.table);
            if (plan != null) {
              for (var i = -1; i < plan.beats.length; i++) {
                states['choreography/$i'] = act0TableForChoreographyFrameV1(
                  runner.table,
                  act0TableChoreographyFrameAfterBeatV1(plan, i),
                );
              }
            }
            final rows = <Map<String, Object?>>[];
            for (final entry in states.entries) {
              final table = entry.value;
              final truth = act0BettingRoundOrderTruthForTableV1(table);
              final replay = act0StreetReplayFromTableV1(table);
              final choreography = act0TableChoreographyPlanForTableV1(table);
              if (truth == Act0BettingRoundOrderTruthV1.contradiction) {
                expect(
                  replay?.isConsumerSafe ?? false,
                  isFalse,
                  reason: '${task.taskId}/${entry.key}',
                );
                expect(
                  choreography,
                  isNull,
                  reason: '${task.taskId}/${entry.key}',
                );
              }
              rows.add({
                'variant': entry.key,
                'scope': table.scope.name,
                'order_proof': truth.name,
                'replay_safe': replay?.isConsumerSafe ?? false,
                'choreography_available': choreography != null,
                'street': table.streetLabel,
                'actor': table.activeSeatId,
                'trail': [
                  for (final a in table.actionTrail)
                    {'kind': a.kind.name, 'label': a.label},
                ],
              });
            }
            inventory.add({
              'world': world.worldId,
              'lesson': lesson.lessonId,
              'task': task.taskId,
              'caption': runner.caption,
              'question': runner.question,
              'options': [
                for (final o in runner.options)
                  {'id': o.id, 'label': o.label, 'correct': o.isCorrect},
              ],
              'applicability': runner.table.scope == Act0TableScopeV1.playedHand
                  ? 'PLAYED_HAND_REQUIRES_SOURCE_POKER_REVIEW'
                  : 'CONCEPTUAL_SCOPE_REVIEW_PROMPT_SEPARATELY',
              'variants': rows,
            });
          }
        }
      }
      expect(inventory.map((r) => r['task']).toSet().length, inventory.length);
      final directory = Directory(
        Platform.environment['PKR03_OUTPUT'] ?? 'output/pkr03-full',
      );
      directory.createSync(recursive: true);
      File('${directory.path}/catalog-proof-status.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(inventory),
      );
      print(
        'PKR03 task_records=${inventory.length} '
        'variant_records=${inventory.fold<int>(0, (n, r) => n + (r['variants'] as List).length)} '
        'accepted_denominator=UNRESOLVED',
      );
    },
  );
}
