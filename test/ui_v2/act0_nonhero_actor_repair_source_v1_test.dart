import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const nonHeroActorRepairSourceIdsV1 = [
  'blinds_first_actor',
  'blinds_last_actor',
  'blinds_review',
  'positions_utg',
];

void main() {
  test(
    'four mechanical repair inputs preserve goals and exact authored HJ contrast',
    () {
      final records = <String, Object?>{};
      for (final id in nonHeroActorRepairSourceIdsV1) {
        final matches = [
          for (final world in Act0ShellStateV1.sample.worlds)
            for (final lesson in world.lessons)
              for (final task in lesson.taskList)
                if (task.taskId == id)
                  (world: world, lesson: lesson, task: task),
        ];
        expect(matches, hasLength(1));
        final source = matches.single;
        final task = source.task;
        final correct = task.runner.options
            .where((option) => option.isCorrect)
            .single;
        final (originalWrongId, newWrongId) = switch (id) {
          'blinds_first_actor' => ('btn', 'bb'),
          'blinds_last_actor' => ('sb', 'btn'),
          'blinds_review' => ('btn', 'sb'),
          'positions_utg' => ('hj', 'sb'),
          _ => throw StateError('Missing wrong options for $id'),
        };
        final wrongOptions = task.runner.options.where(
          (option) => !option.isCorrect,
        );
        expect(wrongOptions.map((option) => option.id), [
          originalWrongId,
          newWrongId,
        ]);
        final wrong = wrongOptions.singleWhere(
          (option) => option.id == originalWrongId,
        );
        expect(correct.seatId, id == 'blinds_last_actor' ? 'bb' : 'utg');
        if (id == 'positions_utg') {
          expect(task.runner.question, 'Tap UTG.');
          expect(wrong.id, 'hj');
          expect(wrong.label, 'HJ');
          // The task-local context adapter must retain its donor's own contrast,
          // rather than assume every non-UTG option names BTN.
          expect(wrong.feedbackReason, 'HJ is after UTG in this order.');
          expect(wrong.feedbackReason, isNot(contains('BTN')));
        }
        final fingerprint = act0AuthoredSourceFingerprintV1(
          worldId: source.world.worldId,
          lessonId: source.lesson.lessonId,
          task: task,
        );
        expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(fingerprint ?? ''), isTrue);
        records[id] = {
          'world_id': source.world.worldId,
          'lesson_id': source.lesson.lessonId,
          'task_id': id,
          'fingerprint': fingerprint,
          'question': task.runner.question,
          'correct_choice_id': correct.id,
          'wrong_choice_id': wrong.id,
          'wrong_choice_label': wrong.label,
          'wrong_choice_reason': wrong.feedbackReason,
          'choice_ids': [for (final option in task.runner.options) option.id],
        };
      }
      final output = Platform.environment['PKR03_OUTPUT'];
      if (output != null) {
        Directory(output).createSync(recursive: true);
        File('$output/nonhero-source-bindings.json').writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert({
            'scope':
                'Production Dart source/fingerprint only, not repair launch or learner evidence',
            'records': records,
          }),
        );
      }
    },
  );
}
