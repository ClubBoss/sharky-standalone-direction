import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('W1 RU identity question matches graded BTN position, not person', (
    tester,
  ) async {
    late String question;
    late String wrongReason;
    late String assistedReason;
    late String hint;
    late String repair;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            const taskId = 'what_poker_is_find_hero';
            question = act0AcademyW1InstructionV1(
              context,
              taskId,
              'Which label could change next hand while the player is still you?',
            );
            wrongReason = act0AcademyW1InstructionV1(
              context,
              taskId,
              'You identifies the player, not the changing seat role.',
            );
            assistedReason = act0AcademyW1InstructionV1(
              context,
              taskId,
              'BTN is a position. The same learner can have another position next hand.',
            );
            hint = act0AcademyW1InstructionV1(
              context,
              taskId,
              "You is the learner. BTN is this hand's position label.",
            );
            repair = act0AcademyW1CtaV1(context, 'Try same clue');
            return const SizedBox();
          },
        ),
      ),
    );
    expect(question, contains('\u043F\u043E\u0437\u0438\u0446\u0438'));
    expect(wrongReason, contains('\u0438\u0433\u0440\u043E\u043A\u0430'));
    expect(assistedReason, contains('BTN'));
    expect(assistedReason, contains('\u043F\u043E\u0437\u0438\u0446\u0438'));
    expect(hint, contains('BTN'));
    expect(
      repair,
      '\u041F\u043E\u0432\u0442\u043E\u0440\u0438\u0442\u044C \u0442\u0443 \u0436\u0435 \u043F\u043E\u0434\u0441\u043A\u0430\u0437\u043A\u0443',
    );
    final lesson = Act0ShellStateV1.sample.worlds
        .firstWhere((w) => w.worldId == 'world_1')
        .lessons
        .firstWhere((l) => l.lessonId == 'what_poker_is');
    final task = lesson.taskList.firstWhere(
      (t) => t.taskId == 'what_poker_is_find_hero',
    );
    expect(
      task.runner.options.singleWhere((o) => o.id == 'bottom').isCorrect,
      true,
    );
    expect(
      task.runner.options.singleWhere((o) => o.id == 'top').isCorrect,
      false,
    );
  });

  testWidgets(
    'W1 RU numeric question, options and reasons retain 2/3/6 flop semantics',
    (tester) async {
      late String question;
      late String right;
      late String wrong;
      late String reason;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              const taskId = 'what_poker_is_table_read_transfer';
              question = act0AcademyW1InstructionV1(
                context,
                taskId,
                'What is the clean first table read?',
              );
              right = act0AcademyW1OptionLabelV1(
                context,
                '2 private cards, 3 board cards, 6 BB in the pot',
              );
              wrong = act0AcademyW1OptionLabelV1(
                context,
                '5 board cards are already out',
              );
              reason = act0AcademyW1InstructionV1(
                context,
                taskId,
                'The flop has only three shared cards. Five board cards appear only by the river.',
              );
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        question,
        '\u041A\u0430\u043A\u043E\u0435 \u043E\u043F\u0438\u0441\u0430\u043D\u0438\u0435 \u0442\u0435\u043A\u0443\u0449\u0435\u0433\u043E \u0441\u0442\u043E\u043B\u0430 \u0432\u0435\u0440\u043D\u043E?',
      );
      expect(right, contains('2 \u043B\u0438\u0447\u043D\u044B\u0435'));
      expect(right, contains('3 \u043E\u0431\u0449\u0438\u0435'));
      expect(right, contains('6 BB'));
      expect(wrong, contains('5 \u043E\u0431\u0449\u0438\u0445'));
      expect(
        reason,
        contains('\u0444\u043B\u043E\u043F\u0435 \u0442\u0440\u0438'),
      );
      expect(reason, contains('\u0440\u0438\u0432\u0435\u0440\u0443'));
      final lesson = Act0ShellStateV1.sample.worlds
          .firstWhere((w) => w.worldId == 'world_1')
          .lessons
          .firstWhere((l) => l.lessonId == 'what_poker_is');
      final task = lesson.taskList.firstWhere(
        (t) => t.taskId == 'what_poker_is_table_read_transfer',
      );
      expect(
        task.runner.options
            .singleWhere((o) => o.id == 'two_three_six')
            .isCorrect,
        true,
      );
      expect(
        task.runner.options
            .singleWhere((o) => o.id == 'five_board_now')
            .isCorrect,
        false,
      );
      expect(
        task.runner.options
            .singleWhere((o) => o.id == 'hand_first_only')
            .isCorrect,
        false,
      );
    },
  );

  testWidgets('W1 EN remains source-copy with identical navigation and options', (
    tester,
  ) async {
    late String question;
    late String hint;
    late String cta;
    late String answer;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            question = act0AcademyW1InstructionV1(
              context,
              'what_poker_is_find_hero',
              'Which label could change next hand while the player is still you?',
            );
            hint = act0AcademyW1InstructionV1(
              context,
              'what_poker_is_find_hero',
              "You is the learner. BTN is this hand's position label.",
            );
            cta = act0AcademyW1CtaV1(context, 'Try same clue');
            answer = act0AcademyW1OptionLabelV1(context, 'Your private cards');
            return const SizedBox();
          },
        ),
      ),
    );
    expect(
      question,
      'Which label could change next hand while the player is still you?',
    );
    expect(hint, "You is the learner. BTN is this hand's position label.");
    expect(cta, 'Try same clue');
    expect(answer, 'Your private cards');
  });
}
