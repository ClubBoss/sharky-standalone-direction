// SIMULATED source/teaching regression, not native or independent learning proof.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

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
    answer: 'BB',
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
        expect(table.heroSeatId, flop ? 'co' : 'btn');
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
          expect(
            task.runner.options.where((o) => o.seatId == 'btn').single.label,
            'BTN',
          );
        }
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic-old-${entry.key}',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: lesson,
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
      find.textContaining(task.runner.caption),
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
    if (neutral) expect(scroll.position.maxScrollExtent, greaterThan(0));

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
        expect(t.decisionSeatId, 'btn');
        expect(t.activeSeatId, 'btn');
        expect(t.heroCards.map((c) => c.label), ['As', 'Kd']);
        expect(t.potLabel, 'Pot 7.5 BB');
        expect(t.actionTrail.last.label, '$street: BB checks');
        expect(t.seats.where((s) => s.isInHand).map((s) => s.seatId).toSet(), {
          'bb',
          'btn',
        });
        expect(
          {for (final a in t.seats) a.seatId: a.stackLabel},
          {
            'utg': '100 BB',
            'hj': '100 BB',
            'co': '99 BB',
            'btn': '97 BB',
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
          contains('before posting the 0.5/1 BB blinds'),
        );
        expect(task.runner.caption, contains('100 BB'));
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
    final task = _task('positions', 'positions_theory');
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
    expect(task.runner.question, 'Which seat is latest after the flop here?');
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
      'top': 'UTG acts before BTN after the flop in this six-seat hand.',
      'bottom': 'BTN acts last after the flop in this six-seat hand.',
      'random': 'BB acts before BTN after the flop in this six-seat hand.',
    };
    for (final option in task.runner.options) {
      expect(option.feedbackReason, expected[option.id]);
    }
  });

  testWidgets('W01 recap shows postflop feedback after the BB choice', (
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
    final choice = find.byKey(const Key('act0_shell_seat_tap_bb'));
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
      find.text('BB acts before BTN after the flop in this six-seat hand.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('one-BB teaching keeps its normal drill and unconfirmed repairs held', () {
    const lesson = 'blinds_action_order';
    final tasks = Act0ShellStateV1.sample.lessonById(lesson).taskList;
    final source = _task(lesson, 'blinds_theory');
    final target = _task(lesson, 'blinds_posts_drill');
    // The normal lesson path still advances from this theory to its drill.
    // That authored path does not itself validate a repair relation.
    expect(source.phase, Act0LessonPhaseV1.theory);
    expect(target.phase, Act0LessonPhaseV1.drill);
    expect(tasks[tasks.indexOf(source) + 1].taskId, target.taskId);
    expect(source.runner.question, 'Which blind posts 1 BB?');
    expect(
      target.runner.question,
      'Tap the blind that sets the 1 BB baseline.',
    );
    expect(target.runner.options.map((option) => option.id), <String>[
      'bb',
      'sb',
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
          'BB posts the full 1 BB blind, so later prices count from that baseline.',
      'sb':
          'SB posts only 0.5 BB. BB is the full 1 BB post players count from.',
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

    void expectHeld(Act0RepairIntentV1 intent) {
      expect(intent.sourceWorldId, 'world_1');
      expect(intent.sourceLessonId, lesson);
      expect(intent.targetWorldId, intent.sourceWorldId);
      expect(intent.targetLessonId, intent.sourceLessonId);
      expect(intent.targetTaskId, intent.sourceTaskId);
      expect(intent.mappingType, 'unresolved_product_gap');
      expect(intent.goalId, isEmpty);
      expect(intent.relationId, isEmpty);
      expect(intent.relationRevision, 0);
      expect(intent.sourceFingerprint, isEmpty);
      expect(intent.targetFingerprint, isEmpty);
      final resolution = act0RepairGoalResolutionForIntentV1(
        intent,
        learningEvidence: const Act0LearningEvidenceHistoryV1(),
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );
      expect(resolution.reason, 'relation_unconfirmed');
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
      expectHeld(intent);
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
    expectHeld(donorIntent);
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
