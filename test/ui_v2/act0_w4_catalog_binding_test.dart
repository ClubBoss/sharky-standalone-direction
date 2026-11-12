import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w4_authored_binding_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';

void main() {
  test(
    'six immutable authored bindings have unique semantic and record identities',
    () {
      expect(act0PrivateW4BindingsV1.length, 6);
      expect(
        act0PrivateW4BindingsV1.map((r) => r.fingerprint).toSet().length,
        6,
      );
      expect(
        act0PrivateW4BindingsV1
            .map((r) => '${r.record}/${r.version}')
            .toSet()
            .length,
        6,
      );
      for (final r in act0PrivateW4BindingsV1) {
        expect(r.decision, startsWith('${r.hand}:'));
        expect(r.recordHash.length, 64);
        expect(r.sourceManifest.length, 64);
        expect(r.bindingManifest.length, 64);
      }
    },
  );
  for (final row in act0PrivateW4BindingsV1) {
    test(
      'actual catalog ${row.task} matches exact reviewed source and fails corrupt active source',
      () {
        final task = Act0ShellStateV1.sample
            .worldById(row.world)
            .lessons
            .singleWhere((l) => l.lessonId == row.lesson)
            .taskList
            .singleWhere((t) => t.taskId == row.task);
        expect(task.runner.options.map((o) => o.id), ['call', 'fold']);
        expect(task.runner.options.where((o) => o.isCorrect).length, 1);
        expect(
          act0W4BindingForTaskV1(
            world: row.world,
            lesson: row.lesson,
            task: task,
            runner: task.runner,
          ),
          same(row),
        );
        expect(
          act0W4BindingForTaskV1(world: row.world, lesson: 'wrong', task: task),
          isNull,
        );
        expect(
          act0W4BindingForTaskV1(
            world: row.world,
            lesson: row.lesson,
            task: task,
            runner: task.runner.copyWith(
              table: task.runner.table.copyWith(potLabel: 'Pot 999 BB'),
            ),
          ),
          isNull,
        );
        final title = Act0ShellStateV1.sample.lessonById(row.lesson).title;
        final envelope = task.runner.copyWith(
          lessonId: row.lesson,
          lessonTitle: title,
        );
        expect(
          act0W4BindingForTaskV1(
            world: row.world,
            lesson: row.lesson,
            task: task,
            runner: envelope,
          ),
          isNull,
        );
        expect(
          act0W4BindingForTaskV1(
            world: row.world,
            lesson: row.lesson,
            task: task,
            runner: envelope,
            expectedRouteLessonTitle: title,
          ),
          same(row),
        );
        for (final bad in [
          envelope.copyWith(lessonId: 'unrelated'),
          envelope.copyWith(lessonTitle: 'unrelated'),
          envelope.copyWith(caption: 'changed premises'),
          envelope.copyWith(hint: 'changed hint'),
          envelope.copyWith(question: 'changed decision'),
          envelope.copyWith(options: const []),
          envelope.copyWith(
            table: envelope.table.copyWith(potLabel: 'Pot 999 BB'),
          ),
        ]) {
          expect(
            act0W4BindingForTaskV1(
              world: row.world,
              lesson: row.lesson,
              task: task,
              runner: bad,
              expectedRouteLessonTitle: title,
            ),
            isNull,
          );
        }
        final read = act0TablePriceV1(task.runner.table);
        expect(read.facts, isNotNull, reason: read.reason);
        const rewards = {
          'w4_good_price_call': 7,
          'w4_bad_price_fold': 8,
          'w4_cheap_price_marginal_call': 8,
          'w4_big_price_marginal_fold': 8,
          'w4_checkpoint_price': 10,
          'w4_checkpoint_table_price': 10,
        };
        expect(task.rewardXp, rewards[row.task]);
      },
    );
  }
}
