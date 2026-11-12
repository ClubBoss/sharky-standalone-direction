// NEW authored theory source, not recovered history. No production edits.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_reference_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_source_price_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import '../support/w4_theory_source_projection.dart';

Widget _reference({
  required String lessonId,
  required String taskId,
  Act0LessonTaskV1? sourceTask,
  bool scored = false,
}) => MaterialApp(
  locale: const Locale('en'),
  home: Scaffold(
    body: SafeArea(
      child: Act0Hlp02ReferenceButtonV1(
        key: const Key('hlp02_tools_route_reference'),
        lessonId: lessonId,
        taskId: taskId,
        isTheory: true,
        isLearnStep: true,
        isSelectable: true,
        isEnglish: true,
        hasActiveScoredChoice: scored,
        sourceTask: sourceTask,
      ),
    ),
  ),
);

void _useReferencePhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _openReference(WidgetTester tester) async {
  final open = find.byKey(const Key('act0_hlp02_open_theory_reference'));
  expect(open.hitTestable(), findsOneWidget);
  // Await the panel's actual asset request in the zone which initiated it.
  await tester.runAsync(() async {
    await tester.tap(open);
    await tester.pump();
    final loader = find.descendant(
      of: find.byKey(const Key('act0_hlp02_inline_reference_region')),
      matching: find.byType(FutureBuilder<Act0Hlp02ReferenceCatalogV1>),
    );
    expect(loader, findsOneWidget);
    final future = tester
        .widget<FutureBuilder<Act0Hlp02ReferenceCatalogV1>>(loader)
        .future;
    expect(future, isNotNull);
    final catalog = await future!;
    expect(catalog.contextByLesson, isNotEmpty);
  });
  await tester.pumpAndSettle();
  expect(
    find.byKey(const Key('act0_hlp02_theory_reference_panel')),
    findsOneWidget,
  );
  expect(find.text('Reference unavailable'), findsNothing);
}

Future<Finder> _reveal(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  if (finder.evaluate().isEmpty) {
    // Large text can leave a lazy ListView child unbuilt. Scroll the actual
    // reference viewport; never enlarge it or substitute a direct widget.
    final verticalPanel = find.descendant(
      of: find.byKey(const Key('act0_hlp02_theory_reference_panel')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
        description: 'vertical HLP reference scrollable',
      ),
    );
    expect(verticalPanel, findsOneWidget);
    await tester.scrollUntilVisible(
      finder,
      160,
      scrollable: verticalPanel,
      maxScrolls: 24,
    );
    await tester.pumpAndSettle();
  }
  expect(finder, findsOneWidget, reason: 'missing $key');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget, reason: 'unreachable $key');
  return finder;
}

Future<void> _expand(WidgetTester tester, String section) async {
  final tile = await _reveal(tester, 'hlp02_tool_$section');
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'frozen theory JSON projects canonical price, identities and unchanged reward',
    () {
      final record = readTheoryRecord();
      final task = projectTheorySource();
      final table = task.runner.table;
      expect(record['record_id'], 'w4_new_price_theory_v1');
      expect(record['record_version'], '1.0.0-proposal.2');
      expect(task.taskId, 'w4_price_intro');
      expect(task.phase, Act0LessonPhaseV1.theory);
      expect(task.runner.phase, task.phase);
      expect(task.runner.options, isEmpty);
      expect(task.rewardXp, 5);
      final original = Act0ShellStateV1.sample
          .lessonById('call_price')
          .taskList
          .singleWhere((t) => t.taskId == task.taskId);
      expect(task.rewardXp, original.rewardXp);
      expect(task.stepKind, original.stepKind);
      expect(task.runner.nextLessonId, original.runner.nextLessonId);
      expect(task.runner.returnTarget, original.runner.returnTarget);
      expect(
        table.actionTrail.map((e) => e.label).toList(),
        record['canonical_projection_literals']['actionTrail'],
      );
      expect(table.seats.length, 6);
      expect(table.heroSeatId, 'btn');
      expect(table.activeSeatId, 'btn');
      expect(table.boardCards.length, 4);
      expect(table.heroCards.length, 2);
      for (var i = 0; i < 6; i++) {
        final s = table.seats[i];
        final j = record['participants'][i];
        expect(s.seatId, j['seat_id']);
        expect(s.stackLabel, '${j['remaining_stack_bb']} BB');
        expect(s.isFolded, j['status'] == 'folded');
        expect(s.isInHand, j['status'] == 'live');
        expect(s.holeCards.isEmpty, s.seatId != 'btn');
      }
      expect(
        task.runner.teachingSteps
            .map((s) => {'title': s.title, 'body': s.body})
            .toList(),
        record['theory']['steps'],
      );
      expect(task.runner.primaryCtaLabel, original.runner.primaryCtaLabel);
      expect(task.taskFamily, original.taskFamily);
      expect(task.tablePresentation, original.tablePresentation);
      expect(task.runner.feedbackTitle, isEmpty);
      expect(task.runner.feedbackReason, isEmpty);
      expect(task.runner.selectedOptionId, isNull);
      void checkCards(List<Act0CardStateV1> actual, List<String> expected) {
        expect(actual.length, expected.length);
        for (var i = 0; i < expected.length; i++) {
          final c = expected[i];
          expect(actual[i].rank, c.substring(0, c.length - 1));
          expect(actual[i].suit, c.substring(c.length - 1));
          expect(
            actual[i].tone,
            'hd'.contains(c.substring(c.length - 1))
                ? Act0CardToneV1.red
                : Act0CardToneV1.dark,
          );
        }
      }

      checkCards(
        table.heroCards,
        (record['cards']['hero_hole'] as List).cast<String>(),
      );
      checkCards(table.boardCards, [
        ...(record['cards']['flop'] as List).cast<String>(),
        record['cards']['turn'] as String,
      ]);
      for (var i = 0; i < 6; i++) {
        final s = table.seats[i];
        final j = record['participants'][i];
        final actor = record['source_point']['active_actor'];
        expect(s.isHero, j['is_hero']);
        expect(s.isDealerButton, j['is_button']);
        expect(s.isSmallBlind, j['is_small_blind']);
        expect(s.isBigBlind, j['is_big_blind']);
        expect(s.isActive, s.seatId == actor);
        expect(
          s.cardsVisibleMode,
          j['is_hero'] == true
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.none,
        );
        checkCards(
          s.holeCards,
          j['is_hero'] == true
              ? (record['cards']['hero_hole'] as List).cast<String>()
              : <String>[],
        );
        // Fixed record: only SB has acted on Turn; folded seats acted earlier.
        expect(
          s.hasActed,
          s.isFolded || s.seatId == record['events'].last['actor'],
        );
        expect(s.isLastAggressor, s.seatId == record['events'].last['actor']);
        if (j['current_street_contribution_bb'] == '0') {
          expect(s.currentBetLabel, isEmpty);
          expect(s.bet, isNull);
        } else {
          expect(
            s.currentBetLabel,
            '${j['current_street_contribution_bb']} BB',
          );
          expect(s.bet, isNotNull);
          expect(s.bet!.kind, Act0SeatBetKindV1.bet);
          expect(s.bet!.label, j['position']);
          expect(s.bet!.amountLabel, s.currentBetLabel);
        }
      }
      final read = act0TablePriceV1(table);
      expect(read.facts, isNotNull, reason: read.reason);
      expect(read.facts!.potBeforeActionBb, 8);
      expect(read.facts!.callCostBb, 2);
      expect(read.facts!.hasRecordedAllIn, isFalse);
      final price = hlp02SourcePriceReadV1(
        sourceTask: task,
        taskId: task.taskId,
      );
      expect(price.status, Hlp02SourcePriceStatusV1.verified);
      expect(price.price!.potAfterCallChips, 10);
      expect(price.price!.requiredWinRatePercent, 20);
    },
  );
  test(
    'contradictory pot and wrong identity cannot establish source price',
    () {
      final task = projectTheorySource();
      expect(
        act0TablePriceV1(
          task.runner.table.copyWith(potLabel: 'Pot 999 BB'),
        ).facts,
        isNull,
      );
      expect(
        hlp02SourcePriceReadV1(sourceTask: task, taskId: 'different').price,
        isNull,
      );
    },
  );
  testWidgets(
    'actual theory reference opens and remounts with no options or source mutation',
    (t) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final initialPreferences = {
        for (final k in prefs.getKeys()) k: prefs.get(k),
      };
      _useReferencePhone(t);
      final task = projectTheorySource();
      final before = jsonEncode(readTheoryRecord());
      for (var replay = 0; replay < 2; replay++) {
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        await t.pumpWidget(
          _reference(
            lessonId: 'call_price',
            taskId: task.taskId,
            sourceTask: task,
          ),
        );
        await _openReference(t);
        await _expand(t, 'price');
        final result = await _reveal(t, 'hlp02_source_result');
        expect(
          t.widget<Text>(result).data,
          'Before: 8 BB\nCall: 2 BB\nAfter: 10 BB\nBreak-even threshold: 20.00%',
        );
        final bar = await _reveal(t, 'hlp02_price_bar_source');
        expect(t.widget<LinearProgressIndicator>(bar).value, .2);
        expect(task.runner.options, isEmpty);
        expect(task.runner.selectedOptionId, isNull);
        expect(task.rewardXp, 5);
        expect(jsonEncode(readTheoryRecord()), before);
        expect(
          {for (final k in prefs.getKeys()) k: prefs.get(k)},
          initialPreferences,
          reason:
              'Reference display/replay must not write persisted progress or evidence.',
        );
      }
      await t.pumpWidget(
        _reference(
          lessonId: 'call_price',
          taskId: task.taskId,
          sourceTask: task,
          scored: true,
        ),
      );
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_hlp02_open_theory_reference')),
        findsNothing,
      );
    },
  );
}
