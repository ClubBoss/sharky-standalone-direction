import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
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
  ValueChanged<Act0MistakeCardV1>? onFix,
  VoidCallback? onOpenLearn,
}) => _localeHost(
  locale,
  Act0ReviewShellV1(
    review: state,
    selected: null,
    onSelected: (_) {},
    onFixMistake: onFix ?? (_) {},
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

  // Source-consistent snapshot: independent recovery -> due -> wrong/lapse
  // -> 24h lapse interval -> due again while task remains an active mistake.
  // A fixed source UTC instant is NOT real elapsed native evidence.
  final lapseRecordedAtUtc = DateTime.utc(2026, 10, 11, 10);
  final lapseNextDueAtUtc = lapseRecordedAtUtc.add(
    Act0DurableLearningTimingV1.lapseToReview,
  );
  final lapsedHistory = Act0DurableRetentionHistoryV1(
    families: <Act0DurableRetentionFamilyV1>[
      Act0DurableRetentionFamilyV1(
        conceptFamilyId: 'action_read',
        worldId: 'world_1',
        sourceLessonId: 'fold_check_call_raise',
        sourceTaskId: 'actions_check_drill',
        retentionState: Act0RetentionStateV1.lapsed,
        nextDueAtUtc: lapseNextDueAtUtc,
        lastSpacedReviewAtUtc: null,
        spacedSuccessStage: 0,
        lapseCount: 1,
        incorrectCount: 2,
        correctCount: 1,
        lastRecordedAtUtc: lapseRecordedAtUtc,
        lastCreatedOrder: 3,
        lastSessionId: 'w1_lapsed_recheck',
        lastReviewKind: Act0ReviewKindV1.spacedReview,
        hasLegacyUnspacedEvidence: false,
      ),
    ],
  );

  testWidgets(
    'RU same-task lapsed due keeps guided repair and independent recheck distinct',
    (tester) async {
      expect(
        lapsedHistory.dueItemsAt(
          lapseNextDueAtUtc.subtract(const Duration(seconds: 1)),
        ),
        isEmpty,
      );
      final sourceDue = lapsedHistory.dueItemsAt(lapseNextDueAtUtc);
      expect(sourceDue, hasLength(1));
      final due = sourceDue.single;
      expect(due.lapseCount, greaterThanOrEqualTo(1));
      expect(due.taskId, _miss.taskId);
      final invoked = <String>[];
      Act0DueReviewItemV1? launchedDue;
      Act0MistakeCardV1? repairedMistake;
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
          due: sourceDue,
          onDue: (item) {
            invoked.add('due');
            launchedDue = item;
          },
          onFix: (item) {
            invoked.add('repair');
            repairedMistake = item;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_review_repair_coach_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_due_spaced_item')),
        findsOneWidget,
      );
      expect(
        find.text('Повтор по расписанию · ошибка ещё открыта'),
        findsOneWidget,
      );
      expect(find.textContaining('Она ещё не исправлена'), findsOneWidget);
      expect(find.text('Разобрать с подсказкой'), findsOneWidget);
      expect(find.text('Проверить самостоятельно'), findsOneWidget);
      expect(
        find.textContaining('Срок повторения исправленной ошибки наступил'),
        findsNothing,
      );
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      expect(invoked, <String>['due']);
      expect(launchedDue, same(due));
      expect(repairedMistake, isNull);
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_practice_cta')),
      );
      await tester.tap(find.byKey(const Key('act0_shell_review_practice_cta')));
      expect(invoked, <String>['due', 'repair']);
      expect(repairedMistake, same(_miss));
      expect(launchedDue, same(due));
    },
  );

  testWidgets(
    'EN same-task lapsed due keeps separate callbacks and truthfully labels open error',
    (tester) async {
      final sourceDue = lapsedHistory.dueItemsAt(lapseNextDueAtUtc);
      final invoked = <String>[];
      await tester.pumpWidget(
        _review(
          const Locale('en'),
          state: const Act0ReviewStateV1(
            title: 'Review',
            subtitle: '',
            weaknessLabel: '',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: '',
            betterLabel: '',
            mistakes: <Act0MistakeCardV1>[_miss],
          ),
          due: sourceDue,
          onDue: (item) {
            expect(item, same(sourceDue.single));
            invoked.add('due');
          },
          onFix: (item) {
            expect(item, same(_miss));
            invoked.add('repair');
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Scheduled recheck · mistake still open'),
        findsOneWidget,
      );
      expect(find.textContaining('The mistake is still open'), findsOneWidget);
      expect(find.text('Repair with guidance'), findsOneWidget);
      expect(find.text('Check independently now'), findsOneWidget);
      expect(
        find.text('A repaired clue is due for a spaced review.'),
        findsNothing,
      );
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_practice_cta')),
      );
      await tester.tap(find.byKey(const Key('act0_shell_review_practice_cta')));
      expect(invoked, <String>['repair']);
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      expect(invoked, <String>['repair', 'due']);
    },
  );

  testWidgets(
    'RU different-task scheduled review stays distinct from an open mistake',
    (tester) async {
      final otherDue = Act0DueReviewItemV1(
        conceptFamilyId: 'table_read',
        worldId: 'world_1',
        lessonId: 'what_poker_is',
        taskId: 'what_poker_is_table_read_transfer',
        nextDueAtUtc: lapseNextDueAtUtc,
        repeatedMissCount: 1,
        lapseCount: 1,
      );
      final invoked = <String>[];
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
            mistakes: <Act0MistakeCardV1>[_miss],
          ),
          due: <Act0DueReviewItemV1>[otherDue],
          onDue: (item) {
            expect(item, same(otherDue));
            invoked.add('due');
          },
          onFix: (item) {
            expect(item, same(_miss));
            invoked.add('repair');
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Для другого задания наступил срок'),
        findsOneWidget,
      );
      expect(find.text('Повторить сейчас'), findsOneWidget);
      expect(find.text('Проверить самостоятельно'), findsNothing);
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_practice_cta')),
      );
      await tester.tap(find.byKey(const Key('act0_shell_review_practice_cta')));
      expect(invoked, <String>['repair']);
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      await tester.tap(
        find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
      );
      expect(invoked, <String>['repair', 'due']);
    },
  );

  testWidgets(
    'Same-task due without launch callback exposes repair only, not an invented due CTA',
    (tester) async {
      final sourceDue = lapsedHistory.dueItemsAt(lapseNextDueAtUtc);
      var repaired = false;
      await tester.pumpWidget(
        _review(
          const Locale('en'),
          state: const Act0ReviewStateV1(
            title: 'Review',
            subtitle: '',
            weaknessLabel: '',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: '',
            betterLabel: '',
            mistakes: <Act0MistakeCardV1>[_miss],
          ),
          due: sourceDue,
          onFix: (item) {
            expect(item, same(_miss));
            repaired = true;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_review_due_spaced_item')),
        findsNothing,
      );
      expect(find.text('Repair with guidance'), findsNothing);
      await tester.ensureVisible(
        find.byKey(const Key('act0_shell_review_practice_cta')),
      );
      await tester.tap(find.byKey(const Key('act0_shell_review_practice_cta')));
      expect(repaired, isTrue);
    },
  );

  testWidgets(
    'Same-task pending miss with zero recorded lapses is never called repaired',
    (tester) async {
      final due = Act0DueReviewItemV1(
        conceptFamilyId: 'action_read',
        worldId: 'world_1',
        lessonId: 'fold_check_call_raise',
        taskId: 'actions_check_drill',
        nextDueAtUtc: lapseNextDueAtUtc,
        repeatedMissCount: 1,
        lapseCount: 0,
      );
      await tester.pumpWidget(
        _review(
          const Locale('en'),
          state: const Act0ReviewStateV1(
            title: 'Review',
            subtitle: '',
            weaknessLabel: '',
            reason: '',
            stats: <Act0ReviewStatV1>[],
            chosenLabel: '',
            betterLabel: '',
            mistakes: <Act0MistakeCardV1>[_miss],
          ),
          due: <Act0DueReviewItemV1>[due],
          onDue: (_) {},
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('This task also has an open mistake'),
        findsOneWidget,
      );
      expect(
        find.text('A repaired clue is due for a spaced review.'),
        findsNothing,
      );
      expect(find.text('Check independently now'), findsOneWidget);
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
