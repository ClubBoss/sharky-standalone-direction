import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _miss = Act0MistakeCardV1(
  taskId: 'actions_check_drill',
  lessonId: 'fold_check_call_raise',
  title: 'No bet yet',
  weaknessLabel: 'Action read',
  selectedOptionId: 'bet',
  selectedLabel: 'Bet',
  betterLabel: 'Check',
  reason: 'No prior bet meant checking was allowed.',
  attempts: 1,
);

const _reviewBase = Act0ReviewStateV1(
  title: 'Review',
  subtitle: 'Saved mistakes',
  weaknessLabel: 'Action read',
  reason: '',
  stats: <Act0ReviewStatV1>[],
  chosenLabel: 'Bet',
  betterLabel: 'Check',
);

Widget _localeHost(Locale locale, Widget child) => MaterialApp(
  locale: locale,
  supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: Scaffold(body: child),
);

Widget _review(
  Locale locale, {
  Act0ReviewStateV1 state = _reviewBase,
  List<Act0DueReviewItemV1> due = const <Act0DueReviewItemV1>[],
  ValueChanged<Act0DueReviewItemV1>? onDue,
  VoidCallback? onOpenLearn,
}) => _localeHost(
  locale,
  Act0ReviewShellV1(
    review: state,
    selected: null,
    onSelected: (_) {},
    onFixMistake: (_) {},
    dueReviewItems: due,
    onStartDueReview: onDue,
    onOpenLearn: onOpenLearn,
  ),
);

void main() {
  testWidgets(
    'RU Practice explicitly means voluntary training, not Review debt',
    (tester) async {
      await tester.pumpWidget(
        _localeHost(
          const Locale('ru'),
          Act0PlayShellV1(
            groups: const <Act0PracticeGroupV1>[],
            recommendedGroupId: 'daily',
            recommendedTitle: '',
            recommendedSubtitle: '',
            recommendedReasonLabel: '',
            recommendedOutcome: '',
            recommendedOutcomeLead: '',
            masteryLabel: '',
            onStartGroup: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_play_ru_voluntary_explanation')),
        findsOneWidget,
      );
      expect(
        find.textContaining('Практика — тренировка по вашему выбору'),
        findsOneWidget,
      );
      expect(find.textContaining('сохраняются в «Разборе»'), findsOneWidget);
    },
  );

  testWidgets(
    'RU active saved mistake and independently eligible due both actionable',
    (tester) async {
      final due = Act0DueReviewItemV1(
        conceptFamilyId: 'action_read',
        worldId: 'world_1',
        lessonId: 'fold_check_call_raise',
        taskId: 'actions_check_drill',
        nextDueAtUtc: DateTime.utc(2026, 10, 11),
        repeatedMissCount: 1,
        lapseCount: 0,
      );
      Act0DueReviewItemV1? launched;
      await tester.pumpWidget(
        _review(
          const Locale('ru'),
          state: const Act0ReviewStateV1(
            title: 'Review',
            subtitle: 'Saved mistakes',
            weaknessLabel: 'Action read',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: 'Bet',
            betterLabel: 'Check',
            mistakes: <Act0MistakeCardV1>[_miss],
          ),
          due: <Act0DueReviewItemV1>[due],
          onDue: (item) => launched = item,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_review_repair_coach_card')),
        findsOneWidget,
      );
      expect(find.text('СОХРАНЁННАЯ ОШИБКА'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_review_due_spaced_item')),
        findsOneWidget,
      );
      expect(find.text('Пора повторить'), findsOneWidget);
      expect(
        find.textContaining('Срок повторения исправленной ошибки наступил'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      expect(launched, same(due));
    },
  );

  testWidgets(
    'RU saved history without due avoids claiming that a repeat is due',
    (tester) async {
      await tester.pumpWidget(
        _review(
          const Locale('ru'),
          state: const Act0ReviewStateV1(
            title: 'Review',
            subtitle: '',
            weaknessLabel: '',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: '',
            betterLabel: '',
            fixedMistakes: <Act0MistakeCardV1>[_miss],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Нет повторов, срок которых наступил'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_due_spaced_item')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_review_empty_repair_card')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'RU fully empty Review gives an honest Learn exit, not a fake due task',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        _review(const Locale('ru'), onOpenLearn: () => opened = true),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_review_empty_repair_card')),
        findsOneWidget,
      );
      expect(
        find.text('Здесь пока нет сохранённых ошибок для исправления.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_due_spaced_item')),
        findsNothing,
      );
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_empty_open_learn_cta')),
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_review_empty_open_learn_cta')),
      );
      expect(opened, isTrue);
    },
  );

  testWidgets('EN due and empty copy are unchanged by RU leaf projection', (
    tester,
  ) async {
    final due = Act0DueReviewItemV1(
      conceptFamilyId: 'action_read',
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_check_drill',
      nextDueAtUtc: DateTime.utc(2026, 10, 11),
      repeatedMissCount: 1,
      lapseCount: 0,
    );
    await tester.pumpWidget(
      _review(
        const Locale('en'),
        due: <Act0DueReviewItemV1>[due],
        onDue: (_) {},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready to recheck'), findsOneWidget);
    expect(
      find.text('A repaired clue is due for a spaced review.'),
      findsOneWidget,
    );
    expect(find.text('Review now'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_review_ru_route_explanation')),
      findsNothing,
    );
    await tester.pumpWidget(_review(const Locale('en')));
    await tester.pumpAndSettle();
    expect(
      find.text('Misses from lessons will appear here after you try a spot.'),
      findsOneWidget,
    );
  });
}
