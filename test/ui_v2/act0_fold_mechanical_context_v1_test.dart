// SIMULATED/source/widget evidence only. Existing strategic grades are UNKNOWN.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_instruction_content_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

const _oldFp =
    '9cc8d7cc9f9a99577b0d7a8d6df1390bed01ef67d5f6fec85789a9f0d395a665';
Act0LessonTaskV1 get _task => Act0ShellStateV1.sample
    .lessonById('fold_check_call_raise')
    .taskList
    .singleWhere((t) => t.taskId == 'actions_fold_drill');

Act0SeatStateV1 _postFoldSeat(Act0SeatStateV1 s) => Act0SeatStateV1(
  seatId: s.seatId,
  seatLabel: s.seatLabel,
  displayName: s.displayName,
  isHero: s.isHero,
  isDealerButton: s.isDealerButton,
  isSmallBlind: s.isSmallBlind,
  isBigBlind: s.isBigBlind,
  blindAmountLabel: s.blindAmountLabel,
  isActive: s.seatId == 'sb',
  isTarget: s.isTarget,
  isInHand: s.seatId == 'btn' ? false : s.isInHand,
  isFolded: s.seatId == 'btn' ? true : s.isFolded,
  hasActed: s.seatId == 'btn' ? true : s.hasActed,
  isLastAggressor: s.isLastAggressor,
  isOccupied: s.isOccupied,
  stackLabel: s.stackLabel,
  holeCards: s.holeCards,
  cardsVisibleMode: s.cardsVisibleMode,
  currentBetLabel: s.currentBetLabel,
  bet: s.bet,
);

void main() {
  setUpAll(() async {
    final file = [
      File('/System/Library/Fonts/Supplemental/Arial.ttf'),
      File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'),
    ].firstWhere((f) => f.existsSync());
    final bytes = await file.readAsBytes();
    for (final name in ['Roboto', 'Ahem']) {
      await (FontLoader(
        name,
      )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
    for (final icon in [
      (
        'MaterialIcons',
        'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
      ),
      (
        'CupertinoIcons',
        'build/unit_test_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
      ),
    ]) {
      final file = File(icon.$2);
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      await (FontLoader(
        icon.$1,
      )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
  });

  test(
    'new Fold context preserves quiz and uses existing total-call consumers',
    () {
      final task = _task;
      final runner = task.runner;
      final table = runner.table;
      expect(
        act0BuildInstructionBlocksV1(
          text: runner.teachingSteps.last.body,
          compact: true,
        ),
        hasLength(3),
      );
      expect(
        act0AuditInstructionBlockV1(
          scope: 'actions_fold_drill/new-context',
          text: runner.teachingSteps.last.body,
          compact: true,
        ),
        isEmpty,
      );
      expect(task.title, 'Fold to exit');
      expect(task.rewardXp, 5);
      expect(
        runner.caption,
        'HJ bets 2 BB on an ace-high flop. You hold two queens.',
      );
      expect(
        runner.hint,
        'Folding saves chips when continuing is not worth it.',
      );
      expect(runner.question, 'Which action gives up the hand?');
      expect(runner.options.map((o) => o.id), ['fold', 'call', 'raise']);
      expect(runner.options.map((o) => o.amountLabel), ['', '2 BB', '6 BB']);
      expect(runner.options.map((o) => o.isCorrect), [true, false, false]);
      // Literal grades are preserved; no strategic weakness/optimality proof.
      expect(table.heroCards.map((c) => c.label), ['Qh', 'Qs']);
      expect(table.boardCards.map((c) => c.label), ['Ah', '7c', '2d']);
      expect(table.decisionSeatId, 'btn');
      expect(table.activeSeatId, 'btn');
      expect(table.heroSeatId, 'btn');
      expect(table.actionTrail.where((a) => !a.isNote).map((a) => a.label), [
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG calls 1 BB',
        'HJ calls 1 BB',
        'CO folds',
        'BTN calls 1 BB',
        'SB calls 1 BB',
        'BB checks',
        'Flop: SB checks',
        'BB checks',
        'UTG checks',
        'HJ bets 2 BB',
      ]);
      expect(table.actionTrail.last.isNote, isTrue);
      expect(table.actionTrail.last.label, 'Hero acts');
      expect(table.seats.where((s) => s.isInHand).length, 5);
      expect(table.seats.singleWhere((s) => s.isFolded).seatId, 'co');
      expect(table.seats.where((s) => s.bet != null).map((s) => s.seatId), [
        'hj',
      ]);
      expect(
        table.seats
            .where((s) => s.isSmallBlind || s.isBigBlind)
            .every(
              (s) =>
                  s.currentBetLabel == '0 BB' &&
                  s.bet == null &&
                  s.blindAmountLabel == null,
            ),
        isTrue,
      );
      expect(
        table.seats.fold<double>(
              0,
              (n, s) => n + double.parse(s.stackLabel!.split(' ').first),
            ) +
            7,
        600,
      );
      final bbCheck = table.actionTrail.indexWhere(
        (a) => a.label == 'BB checks',
      );
      expect(act0CalcTableTrailPotV1(table, bbCheck).potBb, 5);
      expect(
        act0CalcTableTrailPotV1(table, table.actionTrail.length - 1).potBb,
        7,
      );
      expect(
        act0BettingRoundOrderProofForTableV1(table).truth,
        Act0BettingRoundOrderTruthV1.consistent,
      );
      final call = runner.options.singleWhere((o) => o.id == 'call');
      final price = act0BettingPriceForOptionV1(table, call);
      expect(price.truth, Act0BettingPriceTruthV1.consistent);
      expect(price.callCostBb, 2);
      expect(price.actorCommittedBb, 0);
      expect(price.amountToMatchBb, 2);
      expect(price.minimumRaiseToBb, 4);
      expect(
        act0BettingPriceForOptionV1(
          table,
          runner.options.singleWhere((o) => o.id == 'raise'),
        ).truth,
        Act0BettingPriceTruthV1.consistent,
      );
      final sbMore = table.copyWith(
        actionTrail: [
          for (final a in table.actionTrail)
            if (a.label == 'SB calls 1 BB')
              const Act0ActionTrailItemV1(label: 'SB calls 0.5 BB more')
            else
              a,
        ],
      );
      expect(
        act0BettingPriceForOptionV1(sbMore, call).truth,
        Act0BettingPriceTruthV1.consistent,
      );
      expect(
        act0CalcTableTrailPotV1(sbMore, sbMore.actionTrail.length - 1).potBb,
        7,
      );
      final overpay = table.copyWith(
        actionTrail: [
          for (final a in table.actionTrail)
            if (a.label == 'SB calls 1 BB')
              const Act0ActionTrailItemV1(label: 'SB calls 1 BB more')
            else
              a,
        ],
      );
      expect(
        act0BettingPriceForOptionV1(overpay, call).truth,
        isNot(Act0BettingPriceTruthV1.consistent),
      );
    },
  );

  test('SIMULATED Fold prefix leaves four opponents and next responder SB', () {
    final before = _task.runner.table;
    final after = before.copyWith(
      seats: before.seats.map(_postFoldSeat).toList(),
      decisionSeatId: 'sb',
      activeSeatId: 'sb',
      actionTrail: [
        ...before.actionTrail.where((a) => a.label != 'Hero acts'),
        const Act0ActionTrailItemV1(label: 'BTN folds'),
      ],
    );
    expect(after.seats.where((s) => s.isInHand).map((s) => s.seatId), [
      'utg',
      'hj',
      'sb',
      'bb',
    ]);
    expect(
      act0CalcTableTrailPotV1(after, after.actionTrail.length - 1).potBb,
      7,
    );
    expect(
      act0BettingRoundOrderProofForTableV1(after).truth,
      Act0BettingRoundOrderTruthV1.consistent,
    );
    expect(
      act0BettingRoundOrderProofForTableV1(
        after.copyWith(decisionSeatId: 'hj', activeSeatId: 'hj'),
      ).truth,
      isNot(Act0BettingRoundOrderTruthV1.consistent),
    );
    // This exercises the existing order consumer on a prescribed branch.
    // It is not an executed app hand transition, payout, or new engine.
  });

  test('old raw history survives but cannot prove the revised Fold context', () {
    final old = Act0LearningEvidenceRecordV1(
      recordId: 'SIMULATED-old-fold',
      createdOrder: 1,
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_fold_drill',
      sourceTaskId: 'actions_fold_drill',
      choiceId: 'fold',
      expectedChoiceId: 'fold',
      isCorrect: true,
      errorType: 'none',
      conceptFamilyId: 'action_basics',
      repairFocusId: '',
      skillAtomId: 'action_basics',
      decisionTimeBucket: '3_to_10s',
      resultKind: 'correct',
      assistanceKind: Act0DecisionAssistanceV1.none,
      authoredSourceFingerprint: _oldFp,
    );
    final raw = jsonEncode(old.toPayload());
    final restored = Act0LearningEvidenceRecordV1.tryParse(jsonDecode(raw))!;
    expect(jsonEncode(restored.toPayload()), raw);
    expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
    final current = act0CurrentAuthoredSourceFingerprintForIdentityV1(
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_fold_drill',
    )!;
    expect(current, isNot(_oldFp));
    final identityOnly = Act0LearningEvidenceRecordV1.tryParse({
      ...old.toPayload(),
      'authoredSourceFingerprint': current,
    })!;
    expect(act0CurrentAuthoredSourceProofV1(identityOnly), isNotNull);
    // Synthetic positive identity is not a real attempt or strategy acceptance.
  });

  testWidgets('Fold source at EN14Pro delivers one answer and real feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final task = _task;
    var answers = 0;
    final decisions = <Act0CompletedDecisionV1>[];
    Future<void> mount(Act0RunnerStateV1 runner) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: Scaffold(
            body: RepaintBoundary(
              key: const Key('fold-capture'),
              child: Act0LessonRunnerShellV1(
                runner: runner,
                worldNumber: 1,
                selectedWorldId: 'world_1',
                selectedLessonId: 'fold_check_call_raise',
                selectedTaskId: 'actions_fold_drill',
                selectedTaskTitle: task.title,
                selectedTaskFamily: task.resolvedTaskFamily,
                compositionFamily: task.resolvedCompositionFamily,
                tablePresentation: task.tablePresentation,
                onBack: () {},
                onContinueTheory: () {},
                onContinueReview: () {},
                onChooseOption: (_) => answers++,
                onChooseSeat: (_) {},
                onCompletedDecision: decisions.add,
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull);
    }

    Future<void> capture(String name) => tester.runAsync(() async {
      final out = Platform.environment['FOLD_CONTEXT_CAPTURE_DIR'];
      if (out == null) return;
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('fold-capture')),
      );
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory(out)..createSync(recursive: true);
      File(
        '${dir.path}/$name.png',
      ).writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });

    // Direct snapshot of the appended, pre-answer context explanation.
    await mount(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingStepIndex: task.runner.teachingSteps.length - 1,
      ),
    );
    final contextBody = find.text(task.runner.teachingSteps.last.body);
    expect(contextBody, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(contextBody);
    expect(paragraph.didExceedMaxLines, isFalse);
    await capture('context-start');
    final support = find.byWidgetPredicate(
      (w) =>
          w.key == const Key('act0_learning_scene_v3_model_support_scroll') ||
          w.key == const Key('act0_learning_scene_v3_theory_support_scroll'),
    );
    expect(support, findsOneWidget);
    final scroll = tester.state<ScrollableState>(
      find.descendant(of: support, matching: find.byType(Scrollable)),
    );
    if (scroll.position.maxScrollExtent > 0) {
      await tester.drag(support, const Offset(0, -1000));
      await tester.pumpAndSettle();
    }
    expect(scroll.position.extentAfter, lessThan(1));
    expect(
      tester.getRect(contextBody).bottom,
      lessThanOrEqualTo(tester.getRect(support).bottom + 1),
    );
    await capture('context-end');
    expect(answers, 0);
    final answerStage = task.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingStepIndex: task.runner.teachingSteps.length,
    );
    await mount(answerStage);
    expect(find.text('Which action gives up the hand?'), findsWidgets);
    await capture('question');
    final fold = find.byKey(const Key('act0_shell_option_fold'));
    expect(fold, findsOneWidget);
    await tester.tap(fold);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(fold);
    expect(answers, 1);
    expect(decisions, hasLength(1));
    expect(decisions.single.sourceTaskId, 'actions_fold_drill');
    expect(decisions.single.selectedId, 'fold');
    await mount(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.review,
        selectedOptionId: 'fold',
      ),
    );
    await capture('feedback');
    expect(
      find.textContaining(
        task.runner.options.first.feedbackReason,
        findRichText: true,
      ),
      findsWidgets,
    );
    expect(find.textContaining('Fold', findRichText: true), findsWidgets);
    // Direct source snapshots/callback only: not ordinary route or persistence.
  });
}
