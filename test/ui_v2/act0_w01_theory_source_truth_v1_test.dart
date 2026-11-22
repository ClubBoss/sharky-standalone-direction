// SIMULATED source/teaching regression, not native or independent learning proof.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';

const _controls = [
  (
    lesson: 'blinds_action_order',
    task: 'blinds_theory',
    correct: 'bb',
    answer: '1 BB',
    meaning: '1 BB',
    oldChoice: 'bottom',
    oldFingerprint:
        'b10ea2093f254cae6df8d3a8702aed685bfd49de9a65724f76342fd6cd9ad46f',
    oldIds: ['top', 'bottom', 'random'],
  ),
  (
    lesson: 'cards_ranks_suits',
    task: 'cards_ranks_suits_theory',
    correct: 'rank_and_suit',
    answer: 'Rank and suit',
    meaning: 'rank',
    oldChoice: 'ace',
    oldFingerprint:
        'da18579f003d9a05d2feb9ba458ed793be8ab2fc5d98943e8daf13101533d6fd',
    oldIds: ['king', 'ace', 'suit'],
  ),
  (
    lesson: 'hand_rankings_table',
    task: 'hand_rankings_theory',
    correct: 'hand_strength',
    answer: 'Hand strength',
    meaning: 'stronger',
    oldChoice: 'pair',
    oldFingerprint:
        '9211311af696efd47e86e41bf2a670711541def3254083aa1b134903129bf43c',
    oldIds: ['pair', 'high_card'],
  ),
];

Act0LessonTaskV1 _task(String lesson, String id) => Act0ShellStateV1.sample
    .lessonById(lesson)
    .taskList
    .singleWhere((task) => task.taskId == id);

const _oldOrderFingerprints = <String, String>{
  "blinds_first_actor":
      "4c2405b1405492f1839dab890138d29ee388f1891e8b70a12bfd7e8aa191c24b",
  "blinds_last_actor":
      "4a72fb90b7a61c4af8c879c62984122fd8f94495519ce7b17387a9e594f77c09",
  "blinds_postflop_button":
      "09e11882af88bf22682470c92bc96cb9fed7c1e2a1ef301439b231156c153f93",
  "blinds_review":
      "1cfa7de67cb28034e39bb34f894a569e71371755cf23c9ac44a836a316882dea",
  "positions_utg":
      "1aa766a5a0cc3c63ba45b28067d24c924aa644e2611b5064d4c30a39da247285",
  "positions_late_seat":
      "36fd23bc2754aa5de6cba675a993f3ea8a577b8bff295f75a05a035298617fc2",
  "positions_early_late":
      "7ef6f54d57c33fac2f8a15ae3e3e6c53edcc95e5dcc26992e18fffa5fd817b67",
  "positions_review":
      "5f82d32f64c23407a3685a0870d1c062ed6fcb0cc0ac4b79236840c268547877",
};

void _explicitOrderFrameTests() {
  for (final entry in _oldOrderFingerprints.entries) {
    final lesson = entry.key.startsWith('blinds_')
        ? 'blinds_order_practice'
        : entry.key == 'positions_utg'
        ? 'blinds_action_order'
        : 'positions';
    test(
      '${entry.key} has a complete neutral new actor frame and no old proof',
      () {
        final task = _task(lesson, entry.key);
        final table = task.runner.table;
        final flop = [
          'blinds_postflop_button',
          'positions_late_seat',
          'positions_review',
        ].contains(entry.key);
        final matched = flop || entry.key == 'blinds_last_actor';
        expect(table.scope, Act0TableScopeV1.playedHand);
        expect(
          table.decisionSeatId,
          flop
              ? 'sb'
              : matched
              ? 'bb'
              : 'utg',
        );
        expect(table.activeSeatId, '');
        expect(
          table.seats.every(
            (s) =>
                !s.isActive &&
                !s.isTarget &&
                s.isOccupied &&
                s.isInHand &&
                !s.isFolded,
          ),
          isTrue,
        );
        expect(table.highlightedSeatIds, isEmpty);
        expect(table.streetLabel, flop ? 'Flop' : 'Preflop');
        expect(table.boardCards.length, flop ? 3 : 0);
        final hero = switch (entry.key) {
          'blinds_first_actor' ||
          'positions_utg' ||
          'positions_early_late' => 'hj',
          _ => 'co',
        };
        expect(table.heroSeatId, hero);
        expect(table.heroSeat.seatId, hero);
        expect(
          table.seats.singleWhere((seat) => seat.isDealerButton).seatId,
          'btn',
        );

        expect(table.potLabel, matched ? 'Pot 6 BB' : 'Pot 1.5 BB');
        expect(table.actionTrail.any((a) => a.label.contains('acts')), isFalse);
        expect(
          act0BettingRoundOrderProofForTableV1(table).truth,
          Act0BettingRoundOrderTruthV1.consistent,
        );

        for (final fault in ['all-in', 'folded', 'unknown-stack']) {
          final badSeats = [
            for (final seat in table.seats)
              if (seat.seatId != table.decisionSeatId)
                seat
              else
                Act0SeatStateV1(
                  seatId: seat.seatId,
                  seatLabel: seat.seatLabel,
                  displayName: seat.displayName,
                  isHero: seat.isHero,
                  isDealerButton: seat.isDealerButton,
                  isSmallBlind: seat.isSmallBlind,
                  isBigBlind: seat.isBigBlind,
                  blindAmountLabel: seat.blindAmountLabel,
                  isFolded: fault == 'folded',
                  isInHand: fault != 'folded',
                  isOccupied: true,
                  hasActed: seat.hasActed,
                  stackLabel: fault == 'unknown-stack'
                      ? null
                      : fault == 'all-in'
                      ? '0 BB'
                      : seat.stackLabel,
                  currentBetLabel: seat.currentBetLabel,
                  bet: seat.bet,
                  holeCards: seat.holeCards,
                  cardsVisibleMode: seat.cardsVisibleMode,
                ),
          ];
          expect(
            act0BettingRoundOrderProofForTableV1(
              table.copyWith(seats: badSeats),
            ).truth,
            isNot(Act0BettingRoundOrderTruthV1.consistent),
            reason:
                'A source decision actor cannot override $fault participation/eligibility facts.',
          );
        }
        final action = flop
            ? 'Flop: SB bets 1 BB'
            : matched
            ? 'BB raises to 2 BB'
            : 'UTG raises to 2 BB';
        expect(
          act0BettingRoundOrderProofForTableV1(
            table.copyWith(
              actionTrail: [
                ...table.actionTrail,
                Act0ActionTrailItemV1(label: action),
              ],
            ),
          ).truth,
          isNot(Act0BettingRoundOrderTruthV1.consistent),
          reason:
              'The old next actor cannot survive a new action/reopened response.',
        );
        if (entry.key == 'blinds_last_actor') {
          final sb = table.seats.singleWhere((s) => s.seatId == 'sb');
          expect(sb.bet!.kind, Act0SeatBetKindV1.call);
          expect(sb.bet!.label, 'Call');
          expect(sb.currentBetLabel, '1 BB');
        }
        final current = act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: 'world_1',
          lessonId: lesson,
          taskId: entry.key,
        )!;
        expect(current, isNot(entry.value));
        final correct = task.runner.options.singleWhere((o) => o.isCorrect);
        expect(
          correct.id,
          entry.key == 'positions_review'
              ? 'bottom'
              : flop
              ? 'btn'
              : matched
              ? 'bb'
              : 'utg',
        );
        if (flop) {
          expect(
            table.seats.every(
              (s) =>
                  s.stackLabel == '99 BB' &&
                  !s.hasActed &&
                  s.blindAmountLabel == null &&
                  s.currentBetLabel == null &&
                  s.bet == null,
            ),
            isTrue,
          );
          if (entry.key == 'positions_review') {
            expect(correct.label, '5 players');
            expect(table.selectableSeatIds, isEmpty);
          } else {
            expect(
              task.runner.options.where((o) => o.seatId == 'btn').single.label,
              'BTN',
            );
          }
        }
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic-old-${entry.key}',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: entry.key.startsWith('blinds_')
              ? 'blinds_action_order'
              : lesson,
          taskId: entry.key,
          sourceTaskId: entry.key,
          choiceId: correct.id,
          expectedChoiceId: correct.id,
          isCorrect: true,
          errorType: 'none',
          conceptFamilyId: 'table_position_read',
          repairFocusId: '',
          skillAtomId: 'table_position_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          assistanceKind: Act0DecisionAssistanceV1.none,
          authoredSourceFingerprint: entry.value,
        );
        final bytes = jsonEncode(old.toPayload());
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          jsonDecode(bytes),
        )!;
        expect(jsonEncode(restored.toPayload()), bytes);
        expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
        expect(
          table.copyWith(potLabel: table.potLabel).decisionSeatId,
          table.decisionSeatId,
        );
        for (final bad in [
          table.copyWith(decisionSeatId: ''),
          table.copyWith(decisionSeatId: 'missing'),
          table.copyWith(decisionSeatId: 'co'),
          table.copyWith(clearDecisionSeatId: true),
          table.copyWith(actionTrail: table.actionTrail.skip(2).toList()),
        ]) {
          expect(
            act0BettingRoundOrderProofForTableV1(bad).truth,
            isNot(Act0BettingRoundOrderTruthV1.consistent),
          );
        }
      },
    );

    _contextPremisesWidgetTest(lesson, entry.key, neutral: true);
  }
}

void _contextPremisesWidgetTest(
  String lesson,
  String taskId, {
  required bool neutral,
}) {
  testWidgets('$taskId exposes full source premises at EN14Pro', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final task = _task(lesson, taskId);
    final assistance = <Act0DecisionAssistanceV1>[];
    var decisions = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: RepaintBoundary(
            key: const Key('order-frame-capture'),
            child: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: task.runner.teachingSteps.length,
              ),
              worldNumber: 1,
              selectedWorldId: 'world_1',
              selectedLessonId: lesson,
              selectedTaskId: task.taskId,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {
                decisions++;
              },
              onChooseSeat: (_) {
                decisions++;
              },
              onContinueReview: () {},
              onChoiceAssistance: assistance.add,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    if (taskId == 'actions_call_drill') {
      expect(
        find.byKey(const Key('act0_shell_street_replay_here_marker')),
        findsNothing,
        reason: 'The current pot must not annotate earlier price snapshots.',
      );
    }
    final scenes = tester
        .widgetList<Act0TableSceneV1>(find.byType(Act0TableSceneV1))
        .toList();
    expect(scenes, isNotEmpty);
    if (neutral)
      for (final scene in scenes) {
        expect(scene.table.activeSeatId, '');
        expect(scene.table.seats.any((s) => s.isActive || s.isTarget), isFalse);
        expect(scene.table.highlightedSeatIds, isEmpty);
      }
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
        .where((t) => t.isNotEmpty)
        .toList();
    expect(
      texts.any(
        (t) =>
            t.contains('UTG acts next') ||
            t.contains('BB acts next') ||
            t.contains('SB acts next'),
      ),
      isFalse,
    );
    expect(find.text(task.runner.question), findsOneWidget);
    expect(
      find.textContaining(act0LearnerFacingPremisesV1(task.runner.caption)),
      findsOneWidget,
      reason: 'Full source premises must be available when answering.',
    );
    final support = find.byKey(
      const Key('act0_learning_scene_v3_model_support_scroll'),
    );
    expect(support, findsOneWidget);
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: support, matching: find.byType(Scrollable)),
    );

    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('order-frame-capture')),
      );
      final png = await boundary.toImage(pixelRatio: 1);
      final data = await png.toByteData(format: ui.ImageByteFormat.png);
      final out = Directory('output/w01-explicit-order-frames-20261117/frames')
        ..createSync(recursive: true);
      File(
        '${out.path}/$taskId.premises-start.png',
      ).writeAsBytesSync(data!.buffer.asUint8List());
      png.dispose();
    });
    if (scroll.position.maxScrollExtent > 0) {
      await tester.drag(support, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, greaterThan(0));
    }
    expect(scroll.position.extentAfter, lessThan(1));
    expect(decisions, 0);
    expect(assistance, isEmpty);
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('order-frame-capture')),
      );
      final png = await boundary.toImage(pixelRatio: 1);
      final bytes = await png.toByteData(format: ui.ImageByteFormat.png);
      final out = Directory('output/w01-explicit-order-frames-20261117/frames')
        ..createSync(recursive: true);
      File(
        '${out.path}/$taskId.png',
      ).writeAsBytesSync(bytes!.buffer.asUint8List());
      File(
        '${out.path}/$taskId.texts.json',
      ).writeAsStringSync(jsonEncode(texts));
      png.dispose();
    });
  });
}

const _firstHandOldFingerprints = <String, String>{
  "your_first_hand_flop":
      "9303bf5618dfc8558e7e524eac6871f0c5a83a7cee5a1b8858c4c337b285959a",
  "your_first_hand_turn":
      "77057e6ee5fe53be4bae1f41443163833a8aee7ea876d84498bdb06be6307607",
  "your_first_hand_river":
      "cebc7bee377f4d2542f6036395de07c124b2cefc2858d23df42e73cc7848ca8c",
  "your_first_hand_action_trail":
      "ab7c65ac6c292960d9bf72648760115f973e1667350f0bc08d6ce270ed5bb714",
};

void _newFirstHandStackTests() {
  for (final entry in _firstHandOldFingerprints.entries) {
    _contextPremisesWidgetTest('your_first_hand', entry.key, neutral: false);
    test(
      '${entry.key} new complete stack context preserves the recorded hand',
      () {
        final task = _task('your_first_hand', entry.key);
        final t = task.runner.table;
        final street = entry.key == 'your_first_hand_turn'
            ? 'Turn'
            : entry.key == 'your_first_hand_river'
            ? 'River'
            : 'Flop';
        final correct = entry.key == 'your_first_hand_turn'
            ? 'four'
            : entry.key == 'your_first_hand_river'
            ? 'five'
            : entry.key == 'your_first_hand_action_trail'
            ? 'bb_check'
            : 'three';
        expect(task.runner.options.singleWhere((o) => o.isCorrect).id, correct);
        expect(task.rewardXp, 6);
        expect(t.streetLabel, street);
        expect(t.decisionSeatId, 'co');
        expect(t.activeSeatId, 'co');
        expect(t.heroCards.map((c) => c.label), ['As', 'Kd']);
        expect(t.potLabel, 'Pot 7.5 BB');
        expect(t.actionTrail.last.label, '$street: BB checks');
        expect(t.seats.where((s) => s.isInHand).map((s) => s.seatId).toSet(), {
          'bb',
          'co',
        });
        expect(
          {for (final a in t.seats) a.seatId: a.stackLabel},
          {
            'utg': '100 BB',
            'hj': '99 BB',
            'co': '97 BB',
            'btn': '100 BB',
            'sb': '99.5 BB',
            'bb': '97 BB',
          },
        );
        expect(
          t.seats.fold<double>(
            7.5,
            (n, a) => n + double.parse(a.stackLabel!.split(' ').first),
          ),
          600,
        );
        expect(
          act0BettingRoundOrderProofForTableV1(t).truth,
          Act0BettingRoundOrderTruthV1.consistent,
        );
        expect(
          task.runner.caption,
          entry.key == 'your_first_hand_action_trail'
              ? 'Read the action through the first check on the flop.'
              : 'The big blind checks on this ${t.streetLabel.toLowerCase()}.',
        );
        final fp = act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: 'world_1',
          lessonId: 'your_first_hand',
          taskId: entry.key,
        )!;
        expect(fp, isNot(entry.value));
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic_old_firsthand_${entry.key}',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: 'your_first_hand',
          taskId: entry.key,
          sourceTaskId: entry.key,
          choiceId: correct,
          expectedChoiceId: correct,
          isCorrect: true,
          errorType: 'none',
          conceptFamilyId: 'table_read',
          repairFocusId: '',
          skillAtomId: 'table_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          authoredSourceFingerprint: entry.value,
        );
        final bytes = jsonEncode(old.toPayload());
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          jsonDecode(bytes),
        )!;
        expect(jsonEncode(restored.toPayload()), bytes);
        expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
      },
    );
  }
}

void main() {
  _newCallPriceContextTests();
  _newFreeCheckContextTests();
  _newFirstHandStackTests();
  setUpAll(() async {
    final font = [
      File('/System/Library/Fonts/Supplemental/Arial.ttf'),
      File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'),
    ].firstWhere((f) => f.existsSync());
    final bytes = await font.readAsBytes();
    for (final name in ['Roboto', 'Ahem']) {
      await (FontLoader(
        name,
      )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
  });
  _explicitOrderFrameTests();
  test('W01 Button definition explains the marker for every choice', () {
    final task = _task('blinds_action_order', 'positions_theory');
    expect(task.phase, Act0LessonPhaseV1.theory);
    expect(task.runner.options.map((option) => option.id), <String>[
      'top',
      'random',
      'bottom',
    ]);
    expect(
      task.runner.options.where(act0RunnerOptionIsAuthoredCorrectV1).single.id,
      'bottom',
    );
    final expected = <String, String>{
      'top': 'UTG is an early position, not the dealer button.',
      'bottom': 'BTN marks the dealer button in this six-seat table.',
      'random': 'BB is the big blind, not the dealer button.',
    };
    for (final option in task.runner.options) {
      expect(option.feedbackReason, expected[option.id]);
    }
  });

  test('W01 position recap explains its stated postflop question', () {
    final task = _task('positions', 'positions_review');
    expect(task.phase, Act0LessonPhaseV1.review);
    expect(task.entryPhase, Act0LessonPhaseV1.drill);
    expect(
      task.runner.question,
      'How many players act before the Button on this first flop pass?',
    );
    expect(task.runner.options.map((option) => option.id), <String>[
      'top',
      'random',
      'bottom',
    ]);
    expect(
      task.runner.options.where(act0RunnerOptionIsAuthoredCorrectV1).single.id,
      'bottom',
    );
    final expected = <String, String>{
      'top':
          'Two is the number of blinds. UTG, HJ and CO also act before BTN on this flop.',
      'bottom':
          'SB, BB, UTG, HJ and CO are all still in. Those five seats act before BTN.',
      'random':
          'One would be a two-player hand. This flop still has six players, five of them before BTN.',
    };
    for (final option in task.runner.options) {
      expect(option.feedbackReason, expected[option.id]);
    }
  });

  testWidgets('W01 recap shows postflop feedback after the one-player choice', (
    tester,
  ) async {
    final task = _task('positions', 'positions_review');
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var runner = task.runner.copyWith(
      phase: task.entryPhase,
      teachingStepIndex: 0,
    );
    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) {
              return Act0LessonRunnerShellV1(
                runner: runner,
                worldNumber: 1,
                selectedWorldId: 'world_1',
                selectedLessonId: 'positions',
                selectedTaskId: task.taskId,
                selectedTaskTitle: task.title,
                selectedTaskFamily: task.resolvedTaskFamily,
                compositionFamily: task.resolvedCompositionFamily,
                tablePresentation: task.tablePresentation,
                onBack: () {},
                onContinueTheory: () => update(() {
                  runner = runner.copyWith(
                    teachingStepIndex: runner.teachingStepIndex + 1,
                  );
                }),
                onChooseOption: (option) => update(() {
                  chosen = option.id;
                  runner = runner.copyWith(
                    selectedOptionId: option.id,
                    phase: Act0LessonPhaseV1.review,
                  );
                }),
                onChooseSeat: (seatId) => update(() {
                  final option = runner.options.singleWhere(
                    (option) => option.seatId == seatId,
                  );
                  chosen = option.id;
                  runner = runner.copyWith(
                    selectedOptionId: option.id,
                    phase: Act0LessonPhaseV1.review,
                  );
                }),
                onContinueReview: () {},
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final choice = find.byKey(const Key('act0_shell_option_random'));
    // Follow the real teaching rail; do not force a recap into a drill or
    // bypass its authored explanation. This remains a widget consumer harness.
    for (var step = 0; step < 12 && runner.activeTeachingStep != null; step++) {
      await tester.pump(const Duration(milliseconds: 900));
      final next = find.byKey(const Key('act0_shell_continue_cta'));
      expect(next, findsOneWidget);
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(runner.activeTeachingStep, isNull);
    expect(choice, findsOneWidget);
    await tester.ensureVisible(choice);
    await tester.tap(choice);
    await tester.pumpAndSettle();
    expect(chosen, 'random');
    final rendered = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
        .where((text) => text.isNotEmpty)
        .toList();
    print('W01_POSITION_RENDER=${jsonEncode(rendered)}');
    expect(
      find.text(
        'One would be a two-player hand. This flop still has six players, five of them before BTN.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('one-BB teaching rehearses the same goal and requires the original miss', () {
    const lesson = 'blinds_action_order';
    final tasks = Act0ShellStateV1.sample.lessonById(lesson).taskList;
    final source = _task(lesson, 'blinds_theory');
    final target = _task(lesson, 'blinds_posts_drill');
    // The normal lesson path still advances from this theory to its drill.
    // That authored path does not itself validate a repair relation.
    expect(source.phase, Act0LessonPhaseV1.theory);
    expect(target.phase, Act0LessonPhaseV1.drill);
    expect(tasks[tasks.indexOf(source) + 1].taskId, target.taskId);
    expect(
      source.runner.question,
      'How many chips did BB post before anyone acted?',
    );
    expect(target.runner.question, 'Tap the blind that sets the 1 BB unit.');
    expect(target.runner.options.map((option) => option.id), <String>[
      'bb',
      'sb',
      'btn',
    ]);
    expect(
      target.runner.options
          .where(act0RunnerOptionIsAuthoredCorrectV1)
          .single
          .id,
      'bb',
    );
    final expectedReasons = <String, String>{
      'bb':
          'BB posts the full 1 BB blind, so later prices count from that 1 BB post.',
      'sb':
          'The 0.5 BB next to SB is half of the 1 BB used to measure this pot.',
      'btn':
          'BTN has not paid a blind in this hand. The 1 BB chips are in front of BB.',
    };
    for (final option in target.runner.options) {
      expect(option.feedbackReason, expectedReasons[option.id]);
      expect(
        option.quality,
        option.id == 'bb'
            ? Act0FeedbackQualityV1.correct
            : Act0FeedbackQualityV1.wrong,
      );
    }

    void expectFamiliarRepair(Act0RepairIntentV1 intent) {
      expect(intent.sourceWorldId, 'world_1');
      expect(intent.sourceLessonId, lesson);
      expect(intent.targetWorldId, intent.sourceWorldId);
      expect(intent.targetLessonId, lesson);
      expect(intent.targetTaskId, target.taskId);
      expect(
        intent.mappingType,
        intent.sourceTaskId == target.taskId ? 'intentional_exact' : 'repair',
      );
      expect(intent.goalId, 'big_blind_baseline');
      expect(intent.relationId, isNotEmpty);
      expect(intent.sourceFingerprint, isNotEmpty);
      expect(intent.targetFingerprint, isNotEmpty);
      final resolution = act0RepairGoalResolutionForIntentV1(
        intent,
        learningEvidence: const Act0LearningEvidenceHistoryV1(),
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );
      expect(resolution.reason, 'source_occurrence_unconfirmed');
      expect(resolution.isHeld, isTrue);
      expect(resolution.retainsObligation, isTrue);
      expect(resolution.canLaunch, isFalse);
      expect(resolution.canClaimIndependentApplication, isFalse);
      expect(resolution.canClaimMatchedRecheck, isFalse);
    }

    for (final option in source.runner.options) {
      final intent = buildAct0RepairIntentV1(
        sourceWorldId: 'world_1',
        sourceLessonId: lesson,
        sourceTaskId: source.taskId,
        runner: source.runner,
        selectedOption: option,
        mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );
      if (act0RunnerOptionIsAuthoredCorrectV1(option)) {
        expect(intent, isNull);
        continue;
      }
      expect(intent, isNotNull);
      expect(intent!.skillAtomId, 'table_read');
      expect(intent.missedSignalId, 'big_blind');
      expect(intent.sourceTaskId, source.taskId);
      expectFamiliarRepair(intent);
    }
    // Preserve the legacy mechanical mapper, without treating it as semantic
    // permission to launch a repair or claim independent learning evidence.
    final legacyMapping = act0FirstValueSameSignalRepMappingV1(
      nextRepId: 'repeat_table_read',
      skillAtomId: 'table_read',
      sourceSignalId: 'big_blind',
      sourceTaskId: source.taskId,
      receiptOutcome: 'repair_started',
    );
    expect(legacyMapping, isNotNull);
    expect(legacyMapping!.taskId, target.taskId);
    expect(legacyMapping.mappingType, 'repair');
    expect(
      act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'small_blind',
        sourceTaskId: source.taskId,
        receiptOutcome: 'repair_started',
      ),
      isNull,
    );
    final donorIntent = buildAct0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: lesson,
      sourceTaskId: target.taskId,
      runner: target.runner,
      selectedOption: target.runner.options.singleWhere((o) => o.id == 'sb'),
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
      currentFingerprintForIdentity:
          act0CurrentAuthoredSourceFingerprintForIdentityV1,
    )!;
    expect(donorIntent.sourceTaskId, target.taskId);
    expectFamiliarRepair(donorIntent);
  });

  for (final control in _controls) {
    // Finite meaning controls independent of source's isCorrect flag:
    // BB posts the full blind; a card has rank+suit; rankings compare strength.
    test(
      '${control.task} answers its own concept and explains each choice',
      () {
        final task = _task(control.lesson, control.task);
        final options = task.runner.options;
        expect(task.phase, Act0LessonPhaseV1.theory);
        expect(task.resolvedTaskFamily, Act0TaskFamilyV1.learn);
        final correct = options
            .where(act0RunnerOptionIsAuthoredCorrectV1)
            .single;
        expect(correct.id, control.correct);
        expect(correct.label, control.answer);
        expect(
          correct.feedbackReason.toLowerCase(),
          contains(control.meaning.toLowerCase()),
        );
        expect(
          task.runner.feedbackReason.toLowerCase(),
          contains(control.meaning.toLowerCase()),
        );
        expect(options.map((o) => o.id).toSet().length, options.length);
        for (final option in options) {
          expect(control.oldIds, isNot(contains(option.id)));
          expect(option.feedbackReason.trim(), isNotEmpty);
          expect(
            option.quality,
            option.id == control.correct
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
          );
        }
      },
    );

    test(
      '${control.task} preserves old teaching history without current proof',
      () {
        final fingerprint = act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: 'world_1',
          lessonId: control.lesson,
          taskId: control.task,
        )!;
        expect(fingerprint, isNot(control.oldFingerprint));
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic_old_theory|${control.task}|1',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: control.lesson,
          taskId: control.task,
          sourceTaskId: control.task,
          choiceId: control.oldChoice,
          expectedChoiceId: control.oldChoice,
          isCorrect: true,
          errorType: 'none',
          conceptFamilyId: 'table_read',
          repairFocusId: '',
          skillAtomId: 'table_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          assistanceKind: Act0DecisionAssistanceV1.none,
          authoredSourceFingerprint: control.oldFingerprint,
        );
        final bytes = jsonEncode(old.toPayload());
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          jsonDecode(bytes),
        )!;
        expect(act0RecordIsAuthoredTeachingV1(restored), isTrue);
        expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
        final currentTeaching = Act0LearningEvidenceRecordV1.tryParse(
          restored.toPayload()
            ..['recordId'] = 'synthetic_current_theory|${control.task}|2'
            ..['createdOrder'] = 2
            ..['choiceId'] = control.correct
            ..['expectedChoiceId'] = control.correct
            ..['authoredSourceFingerprint'] = fingerprint,
        )!;
        expect(act0RecordIsAuthoredTeachingV1(currentTeaching), isTrue);
        expect(act0CurrentAuthoredSourceProofV1(currentTeaching), isNull);
        expect(jsonEncode(restored.toPayload()), bytes);
      },
    );

    testWidgets('${control.task} remains teaching with reachable Continue', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final task = _task(control.lesson, control.task);
      final decisions = <Act0CompletedDecisionV1>[];
      var continued = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: 0,
              ),
              worldNumber: 1,
              selectedWorldId: 'world_1',
              selectedLessonId: control.lesson,
              selectedTaskId: control.task,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () => continued++,
              onChooseOption: (_) =>
                  fail('Teaching must not submit an assessment'),
              onContinueReview: () {},
              onCompletedDecision: decisions.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final option in task.runner.options) {
        expect(find.byKey(Key('act0_shell_option_${option.id}')), findsNothing);
      }
      // The real theory rail may show several Next segments before Continue.
      // Follow those controls; do not skip teaching or force a drill phase.
      for (var step = 0; step < 12 && continued == 0; step++) {
        await tester.pump(const Duration(milliseconds: 900));
        final next = find.byKey(const Key('act0_shell_continue_cta'));
        expect(next, findsOneWidget);
        await tester.ensureVisible(next);
        await tester.pumpAndSettle();
        expect(next.hitTestable(), findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(decisions, isEmpty);
        for (final option in task.runner.options) {
          expect(
            find.byKey(Key('act0_shell_option_${option.id}')),
            findsNothing,
          );
        }
      }
      expect(continued, 1);
      expect(decisions, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }
}

void _newCallPriceContextTests() {
  _contextPremisesWidgetTest(
    'fold_check_call_raise',
    'actions_call_drill',
    neutral: false,
  );
  test(
    'new Call context preserves matching objective and complete source arithmetic',
    () {
      final task = _task('fold_check_call_raise', 'actions_call_drill');
      final table = task.runner.table;
      expect(task.runner.question, 'Which action matches the 1 BB price?');
      expect(task.rewardXp, 5);
      expect(task.runner.options.map((o) => o.id), ['fold', 'raise', 'call']);
      expect(task.runner.options.singleWhere((o) => o.isCorrect).id, 'call');
      expect(table.heroCards.map((c) => c.label), ['9h', '9s']);
      expect(table.boardCards.map((c) => c.label), ['Ah', '7c', '2d']);
      expect(table.streetLabel, 'Flop');
      expect(table.potLabel, 'Pot 5 BB');
      expect(table.toCallLabel, 'To call 1 BB');
      expect(table.decisionSeatId, 'btn');
      expect(table.highlightedSeatIds, isEmpty);
      expect(
        table.seats.where((s) => s.isFolded).map((s) => s.seatId).toSet(),
        {'utg', 'co'},
      );
      expect(
        {for (final s in table.seats) s.seatId: s.stackLabel},
        {
          'utg': '100 BB',
          'hj': '98 BB',
          'co': '100 BB',
          'btn': '99 BB',
          'sb': '99 BB',
          'bb': '99 BB',
        },
      );
      expect(table.seats.every((s) => s.blindAmountLabel == null), isTrue);
      expect(table.seats.where((s) => s.bet != null).map((s) => s.seatId), [
        'hj',
      ]);
      expect(table.actionTrail.map((a) => a.label), [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG folds',
        'HJ calls 1 BB',
        'CO folds',
        'BTN calls 1 BB',
        'SB calls 0.5 BB more',
        'BB checks',
        'Flop: SB checks',
        'Flop: BB checks',
        'Flop: HJ bets 1 BB',
      ]);
      expect(
        table.seats.fold<double>(
          5,
          (sum, s) => sum + double.parse(s.stackLabel!.split(' ').first),
        ),
        600,
      );
      expect(
        act0BettingRoundOrderProofForTableV1(table).truth,
        Act0BettingRoundOrderTruthV1.consistent,
      );
      final call = task.runner.options.singleWhere((o) => o.id == 'call');
      final raise = task.runner.options.singleWhere((o) => o.id == 'raise');
      final feedback = act0FeedbackTableForRunnerV1(
        runner: task.runner.copyWith(selectedOptionId: 'call'),
        taskFamily: task.resolvedTaskFamily,
      );
      // Feedback explains the selected action on the source decision snapshot;
      // it does not manufacture an executed Call or deal the next street.
      expect(feedback.streetLabel, 'Flop');
      expect(feedback.boardCards.length, 3);
      expect(feedback.potLabel, 'Pot 5 BB');
      expect(
        feedback.actionTrail.map((a) => a.label),
        table.actionTrail.map((a) => a.label),
      );
      final price = act0BettingPriceForOptionV1(table, call);
      expect(price.truth, Act0BettingPriceTruthV1.consistent);
      expect(price.callCostBb, 1);
      expect(price.actorCommittedBb, 0);
      expect(price.minimumRaiseToBb, 2);
      expect(
        act0BettingPriceForOptionV1(table, raise).truth,
        Act0BettingPriceTruthV1.consistent,
      );
      expect(task.runner.caption, contains('4 BB total'));
      for (final bad in [
        table.copyWith(
          actionTrail: table.actionTrail
              .where((a) => a.label != 'BB checks')
              .toList(),
        ),
        table.copyWith(
          actionTrail: table.actionTrail
              .where((a) => a.label != 'CO folds')
              .toList(),
        ),
        table.copyWith(decisionSeatId: 'sb'),
      ]) {
        expect(
          act0BettingRoundOrderProofForTableV1(bad).truth,
          isNot(Act0BettingRoundOrderTruthV1.consistent),
        );
      }
      expect(
        act0BettingPriceForOptionV1(
          table,
          const Act0RunnerOptionV1(
            id: 'zero_call',
            label: 'Call',
            amountLabel: '0 BB',
            isCorrect: true,
            preferredLabel: 'Call',
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Synthetic negative',
            feedbackReason: 'A zero amount cannot match this one-BB price.',
          ),
        ).truth,
        isNot(Act0BettingPriceTruthV1.consistent),
      );
      for (final stack in <String?>['0 BB', '0.5 BB', null]) {
        final badStack = table.copyWith(
          seats: [
            for (final seat in table.seats)
              seat.seatId == 'btn'
                  ? _callSeatMutation(seat, stack: stack, afterCall: false)
                  : seat,
          ],
        );
        expect(
          act0BettingPriceForOptionV1(badStack, call).truth,
          isNot(Act0BettingPriceTruthV1.consistent),
        );
      }
      final after = table.copyWith(
        actionTrail: [
          ...table.actionTrail,
          const Act0ActionTrailItemV1(label: 'BTN calls 1 BB'),
        ],
        potLabel: 'Pot 6 BB',
        activeSeatId: '',
        decisionSeatId: 'sb',
        seats: [
          for (final seat in table.seats)
            _callSeatMutation(
              seat,
              stack: seat.seatId == 'btn' ? '98 BB' : seat.stackLabel!,
            ),
        ],
      );
      expect(
        after.seats.fold<double>(
          6,
          (sum, s) => sum + double.parse(s.stackLabel!.split(' ').first),
        ),
        600,
      );
      expect(
        act0BettingRoundOrderProofForTableV1(after).truth,
        Act0BettingRoundOrderTruthV1.consistent,
      );
      expect(
        act0BettingRoundOrderProofForTableV1(
          after.copyWith(decisionSeatId: 'btn'),
        ).truth,
        isNot(Act0BettingRoundOrderTruthV1.consistent),
      );
      expect(
        act0BettingRoundOrderProofForTableV1(
          after.copyWith(
            streetLabel: 'Turn',
            boardCards: [
              ...after.boardCards,
              const Act0CardStateV1(rank: 'J', suit: 'c'),
            ],
            actionTrail: [
              ...after.actionTrail,
              const Act0ActionTrailItemV1(label: 'Turn: SB checks'),
            ],
          ),
        ).truth,
        isNot(Act0BettingRoundOrderTruthV1.consistent),
      );
      final fp = act0CurrentAuthoredSourceFingerprintForIdentityV1(
        worldId: 'world_1',
        lessonId: 'fold_check_call_raise',
        taskId: task.taskId,
      )!;
      const oldFp =
          '4b9b2245ed4b0cae6eb9c6eb49164b3ef4011f6e1c3ceb0e4cbbbcc0fee88643';
      expect(fp, isNot(oldFp));
      final old = Act0LearningEvidenceRecordV1(
        recordId: 'synthetic_old_call',
        createdOrder: 1,
        worldId: 'world_1',
        lessonId: 'fold_check_call_raise',
        taskId: task.taskId,
        sourceTaskId: task.taskId,
        choiceId: 'call',
        expectedChoiceId: 'call',
        isCorrect: true,
        errorType: 'none',
        conceptFamilyId: 'action_read',
        repairFocusId: 'pot_to_call',
        skillAtomId: 'action_read',
        decisionTimeBucket: '3_to_10s',
        resultKind: 'correct',
        authoredSourceFingerprint: oldFp,
      );
      final bytes = jsonEncode(old.toPayload());
      final restored = Act0LearningEvidenceRecordV1.tryParse(
        jsonDecode(bytes),
      )!;
      expect(jsonEncode(restored.toPayload()), bytes);
      expect(restored.authoredSourceFingerprint, oldFp);
      expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
    },
  );
}

Act0SeatStateV1 _callSeatMutation(
  Act0SeatStateV1 s, {
  required String? stack,
  bool afterCall = true,
}) => Act0SeatStateV1(
  seatId: s.seatId,
  seatLabel: s.seatLabel,
  displayName: s.displayName,
  isHero: s.isHero,
  isDealerButton: s.isDealerButton,
  isSmallBlind: s.isSmallBlind,
  isBigBlind: s.isBigBlind,
  isInHand: s.isInHand,
  isFolded: s.isFolded,
  isOccupied: s.isOccupied,
  stackLabel: stack,
  holeCards: s.holeCards,
  cardsVisibleMode: s.cardsVisibleMode,
  currentBetLabel: afterCall && s.seatId == 'btn' ? '1 BB' : s.currentBetLabel,
  bet: afterCall && s.seatId == 'btn'
      ? const Act0SeatBetStateV1(
          kind: Act0SeatBetKindV1.call,
          label: 'Call',
          amountLabel: '1 BB',
        )
      : s.bet,
);

// New declared facts, not a reconstruction of the rejected old AK scene.
void _newFreeCheckContextTests() {
  const sources = <String, (String, String)>{
    'actions_legal_context': (
      'No bet faces you. Which action keeps you in the hand without adding chips?',
      'd889c669abcb49a96b62c12447888f10e8e262e3a2f663b8d2e700010686cad4',
    ),
    'actions_check_drill': (
      'What action keeps playing for free?',
      '45f862c2af3aa0be312896d02a20391e432d349fd42a074228b3a32205905205',
    ),
  };
  for (final entry in sources.entries) {
    final id = entry.key;
    _contextPremisesWidgetTest('fold_check_call_raise', id, neutral: false);
    test(
      'new mechanical Check $id retains its goal and all declared table facts',
      () {
        final task = _task('fold_check_call_raise', id);
        final hero = id == 'actions_legal_context' ? 'co' : 'btn';
        final foldedLateSeat = hero == 'co' ? 'btn' : 'co';
        final table = task.runner.table;
        expect(task.runner.question, entry.value.$1);
        expect(task.rewardXp, 5);
        expect(task.runner.options.map((o) => o.id), ['fold', 'check', 'call']);
        expect(task.runner.options.map((o) => o.isCorrect), [
          false,
          true,
          false,
        ]);
        expect(task.runner.options.map((o) => o.quality.name), [
          'wrong',
          'correct',
          'wrong',
        ]);
        expect(task.runner.options.map((o) => o.feedbackReason), [
          'Folding gives up the hand. Checking is free here.',
          'BB checked and there is no bet, so checking keeps you in for free. Folding takes you out of the hand.',
          'BB has put in no bet on this street. Trying to call misses the free check that keeps you in.',
        ]);
        expect(table.scope, Act0TableScopeV1.playedHand);
        expect(table.playerCount, 6);
        const expectedCards = ['9c', '8d'];
        expect(table.heroCards.map((c) => c.label), expectedCards);
        expect(table.heroCards.last.tone, Act0CardToneV1.red);
        final expectedBoard = [
          id == 'actions_legal_context' ? 'Kh' : 'Ah',
          '7c',
          '2d',
        ];
        expect(table.boardCards.map((c) => c.label), expectedBoard);
        expect(
          {...table.heroCards, ...table.boardCards}.map((c) => c.label).toSet(),
          hasLength(5),
        );
        expect(table.heroSeat.holeCards.map((c) => c.label), expectedCards);
        expect(table.streetLabel, 'Flop');
        expect(table.potLabel, 'Pot 4.5 BB');
        expect(table.toCallLabel, isEmpty);
        expect(table.heroSeatId, hero);
        expect(table.decisionSeatId, hero);
        expect(table.activeSeatId, hero);
        expect(
          table.seats.where((s) => s.isInHand).map((s) => s.seatId).toSet(),
          {hero, 'bb'},
        );
        expect(
          table.seats.where((s) => s.isFolded).map((s) => s.seatId).toSet(),
          {'utg', 'hj', foldedLateSeat, 'sb'},
        );
        expect(table.seats.singleWhere((s) => s.isSmallBlind).seatId, 'sb');
        expect(table.seats.singleWhere((s) => s.isBigBlind).seatId, 'bb');
        expect(table.seats.singleWhere((s) => s.isDealerButton).seatId, 'btn');
        expect(
          {for (final s in table.seats) s.seatId: s.stackLabel},
          {
            'utg': '100 BB',
            'hj': '100 BB',
            hero: '98 BB',
            foldedLateSeat: '100 BB',
            'sb': '99.5 BB',
            'bb': '98 BB',
          },
        );
        expect(_freeCheckTotal(table), 600);
        expect(
          table.seats.every(
            (s) =>
                s.blindAmountLabel == null &&
                s.currentBetLabel == null &&
                s.bet == null &&
                !s.isLastAggressor,
          ),
          isTrue,
        );
        expect(table.highlightedSeatIds, isEmpty);
        expect(table.highlightedCardIds, isEmpty);
        expect(table.actionTrail.map((a) => a.label), [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG folds',
          'HJ folds',
          if (hero == 'btn') 'CO folds',
          '${hero.toUpperCase()} raises 2 BB',
          if (hero == 'co') 'BTN folds',
          'SB folds',
          'BB calls 1 BB more',
          'Flop: BB checks',
        ]);
        expect(
          task.runner.caption,
          'BB checks on the flop. It is your turn and there is no bet to match.',
        );
        expect(table.actionTrail[7].learnerLabel, 'BB calls 1 more, 2 total');
        final proof = act0BettingRoundOrderProofForTableV1(table);
        expect(proof.truth, Act0BettingRoundOrderTruthV1.consistent);
        expect(proof.reason, 'consistent_current_decision');
        final feedback = act0FeedbackTableForRunnerV1(
          runner: task.runner.copyWith(selectedOptionId: 'check'),
          taskFamily: task.resolvedTaskFamily,
        );
        expect(feedback.streetLabel, 'Flop');
        expect(feedback.boardCards.map((c) => c.label), expectedBoard);
        expect(feedback.potLabel, 'Pot 4.5 BB');
        expect(
          feedback.actionTrail.map((a) => a.label),
          table.actionTrail.map((a) => a.label),
        );
      },
    );
    test('new mechanical Check $id rejects missing facts and paid Call', () {
      final table = _task('fold_check_call_raise', id).runner.table;
      Act0RunnerOptionV1 wager(String action, String amount) =>
          Act0RunnerOptionV1(
            id: 'synthetic_${action}_$amount',
            label: action,
            amountLabel: amount,
            isCorrect: false,
            preferredLabel: 'Check',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Synthetic numeric control',
            feedbackReason: 'Mechanical price only.',
          );
      final call = act0BettingPriceForOptionV1(table, wager('Call', '1 BB'));
      expect(call.truth, Act0BettingPriceTruthV1.contradiction);
      expect(call.reason, 'call_without_price');
      expect(call.amountToMatchBb, 0);
      expect(call.actorCommittedBb, 0);
      expect(
        act0BettingPriceForOptionV1(table, wager('Call', '0 BB')).truth,
        Act0BettingPriceTruthV1.contradiction,
      );
      // A legal numeric bet is only a rule control, not a recommended choice.
      expect(
        act0BettingPriceForOptionV1(table, wager('Bet', '1 BB')).truth,
        Act0BettingPriceTruthV1.consistent,
      );
      expect(
        act0BettingPriceForOptionV1(table, wager('Raise', '1 BB')).truth,
        Act0BettingPriceTruthV1.contradiction,
      );
      for (final label in [
        'SB blind 0.5 BB',
        'BB calls 1 BB more',
        'Flop: BB checks',
      ]) {
        final bad = table.copyWith(
          actionTrail: table.actionTrail
              .where((a) => a.label != label)
              .toList(),
        );
        expect(
          act0BettingRoundOrderProofForTableV1(bad).truth,
          isNot(Act0BettingRoundOrderTruthV1.consistent),
          reason: label,
        );
      }
      final hero = id == 'actions_legal_context' ? 'co' : 'btn';
      final heroLabel = hero.toUpperCase();
      expect(table.heroSeatId, hero);
      for (final raise in [
        '$heroLabel raises 1.5 BB',
        '$heroLabel raises 3 BB',
      ]) {
        final bad = table.copyWith(
          actionTrail: [
            for (final a in table.actionTrail)
              a.label == '$heroLabel raises 2 BB'
                  ? Act0ActionTrailItemV1(label: raise)
                  : a,
          ],
        );
        expect(
          act0BettingPriceForOptionV1(bad, wager('Bet', '1 BB')).truth,
          isNot(Act0BettingPriceTruthV1.consistent),
        );
      }
      for (final wrongActor in ['bb', 'sb', 'missing']) {
        expect(
          act0BettingRoundOrderProofForTableV1(
            table.copyWith(decisionSeatId: wrongActor),
          ).truth,
          isNot(Act0BettingRoundOrderTruthV1.consistent),
        );
      }
      for (final wrongPot in ['Pot 4 BB', 'Pot 3 BB', 'Pot 5.5 BB']) {
        // Independent snapshot conservation; no claim that generic D2 is admitted.
        expect(_freeCheckTotal(table.copyWith(potLabel: wrongPot)), isNot(600));
      }
      for (final stack in <String?>['0 BB', null]) {
        final bad = table.copyWith(
          seats: [
            for (final s in table.seats)
              s.seatId == hero ? _freeCheckSeatMutation(s, stack: stack) : s,
          ],
        );
        expect(
          act0BettingRoundOrderProofForTableV1(bad).truth,
          isNot(Act0BettingRoundOrderTruthV1.consistent),
        );
      }
      // Synthetic rule boundary only: two live checks close this flop.
      final closed = table.copyWith(
        clearDecisionSeatId: true,
        activeSeatId: '',
        seats: [
          for (final s in table.seats)
            _freeCheckSeatMutation(s, stack: s.stackLabel, active: false),
        ],
        actionTrail: [
          ...table.actionTrail,
          Act0ActionTrailItemV1(label: 'Flop: $heroLabel checks'),
        ],
      );
      final closedProof = act0BettingRoundOrderProofForTableV1(closed);
      expect(closedProof.truth, Act0BettingRoundOrderTruthV1.consistent);
      expect(closedProof.reason, 'consistent_closed_history');
      expect(_freeCheckTotal(closed), 600);
      expect(closed.streetLabel, 'Flop');
      expect(closed.boardCards.length, 3);
      expect(
        act0BettingRoundOrderProofForTableV1(
          closed.copyWith(decisionSeatId: hero),
        ).truth,
        Act0BettingRoundOrderTruthV1.contradiction,
      );
    });
    test(
      'new mechanical Check $id retains old raw history without new proof',
      () {
        final fp = act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: id,
        )!;
        expect(fp, isNot(entry.value.$2));
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic_old_$id',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: id,
          sourceTaskId: id,
          choiceId: 'check',
          expectedChoiceId: 'check',
          isCorrect: true,
          errorType: 'none',
          conceptFamilyId: 'action_read',
          repairFocusId: 'action_read',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          authoredSourceFingerprint: entry.value.$2,
        );
        final bytes = jsonEncode(old.toPayload());
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          jsonDecode(bytes),
        )!;
        expect(jsonEncode(restored.toPayload()), bytes);
        expect(restored.authoredSourceFingerprint, entry.value.$2);
        expect(restored.choiceId, 'check');
        expect(restored.isCorrect, isTrue);
        expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
      },
    );
  }
}

double _freeCheckTotal(Act0TableStateV1 table) => table.seats.fold<double>(
  double.parse(table.potLabel.split(' ')[1]),
  (sum, s) => sum + double.parse(s.stackLabel!.split(' ').first),
);

Act0SeatStateV1 _freeCheckSeatMutation(
  Act0SeatStateV1 s, {
  required String? stack,
  bool? active,
}) => Act0SeatStateV1(
  seatId: s.seatId,
  seatLabel: s.seatLabel,
  displayName: s.displayName,
  isHero: s.isHero,
  isDealerButton: s.isDealerButton,
  isSmallBlind: s.isSmallBlind,
  isBigBlind: s.isBigBlind,
  isActive: active ?? s.isActive,
  isInHand: s.isInHand,
  isFolded: s.isFolded,
  isOccupied: s.isOccupied,
  hasActed: s.hasActed,
  isLastAggressor: s.isLastAggressor,
  stackLabel: stack,
  holeCards: s.holeCards,
  cardsVisibleMode: s.cardsVisibleMode,
  currentBetLabel: s.currentBetLabel,
  bet: s.bet,
  blindAmountLabel: s.blindAmountLabel,
);
