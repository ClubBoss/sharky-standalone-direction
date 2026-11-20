// SIMULATED mechanical source/widget/identity controls only. Existing strategic
// grading is preserved UNKNOWN; no optimality, learning, native or points proof.
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
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

const _old = <String, (String, String, List<String>)>{
  'actions_theory': (
    '6c3675f14448ded48ee7486f2c2ca8772955f2680b2e86e4d55eb407dce29191',
    'Nobody has entered the pot yet. Which action adds more chips?',
    ['raise', 'fold', 'call'],
  ),
  'actions_raise_drill': (
    '810cfb856a1b28d46498a9d6be4eb21dc7dc30bf1cc3b8780f54c685985bc17f',
    'Choose how to play your first action.',
    ['fold', 'call', 'raise'],
  ),
  'actions_review': (
    '49972ed99d92ac5fa3e7320eb2f22195f04e888a411696de90bb0bc5e621efda',
    'First in on the Button. What is cleaner than limping (just calling the big blind)?',
    ['raise', 'fold', 'call'],
  ),
};

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample
    .lessonById('fold_check_call_raise')
    .taskList
    .singleWhere((task) => task.taskId == id);

void main() {
  setUpAll(() async {
    final font = [
      File('/System/Library/Fonts/Supplemental/Arial.ttf'),
      File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'),
    ].firstWhere((file) => file.existsSync());
    final bytes = await font.readAsBytes();
    for (final name in ['Roboto', 'Ahem']) {
      await (FontLoader(
        name,
      )..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)))).load();
    }
  });

  for (final entry in _old.entries) {
    final id = entry.key;
    test(
      'folded-to-BTN $id has legal mechanics and preserves old raw data',
      // Only the live decision uses the revised mechanical question.
      () {
        final task = _task(id);
        final table = task.runner.table;
        expect(task.runner.question, switch (id) {
          'actions_theory' =>
            'Which action would make the next player match more than the big blind?',
          'actions_review' =>
            'Which action sets a higher price for the next player?',
          _ => 'Which action increases the price above the big blind?',
        });
        expect(task.rewardXp, 5);
        expect(task.runner.options.map((o) => o.id), entry.value.$3);
        expect(task.runner.options.singleWhere((o) => o.isCorrect).id, 'raise');
        // The exercise checks which action raises the price.
        expect(
          table.heroCards.map((card) => card.label),
          id == 'actions_raise_drill' ? ['Qs', 'Js'] : ['Ks', 'Ts'],
        );
        expect(table.boardCards, isEmpty);
        expect(table.playerCount, 6);
        expect(table.scope, Act0TableScopeV1.playedHand);
        expect(table.decisionSeatId, 'btn');
        expect(table.heroSeatId, 'btn');
        expect(table.actionTrail.map((action) => action.label), [
          'SB blind 0.5 BB',
          'BB blind 1 BB',
          'UTG folds',
          'HJ folds',
          'CO folds',
        ]);
        expect(
          table.seats.where((seat) => seat.isFolded).map((s) => s.seatId),
          ['utg', 'hj', 'co'],
        );
        expect(
          table.seats.where((seat) => seat.isInHand).map((s) => s.seatId),
          ['btn', 'sb', 'bb'],
        );
        expect(table.seats.every((seat) => seat.isOccupied), isTrue);
        final chips = table.seats.fold<double>(
          0,
          (sum, seat) => sum + double.parse(seat.stackLabel!.split(' ').first),
        );
        expect(chips + 1.5, 600);
        expect(table.potLabel, 'Pot 1.5 BB');
        expect(table.toCallLabel, 'To call 1 BB');
        for (final blind in [('sb', 'SB', '0.5 BB'), ('bb', 'BB', '1 BB')]) {
          final seat = table.seats.singleWhere((s) => s.seatId == blind.$1);
          expect(seat.bet?.kind, Act0SeatBetKindV1.post);
          expect(seat.bet?.label, blind.$2);
          expect(seat.bet?.amountLabel, blind.$3);
          expect(seat.currentBetLabel, blind.$3);
          expect(seat.blindAmountLabel, blind.$3);
        }
        expect(
          act0BettingRoundOrderProofForTableV1(table).truth,
          Act0BettingRoundOrderTruthV1.consistent,
        );
        final call = task.runner.options.singleWhere((o) => o.id == 'call');
        final raise = task.runner.options.singleWhere((o) => o.id == 'raise');
        expect(call.quality, Act0FeedbackQualityV1.wrong);
        final price = act0BettingPriceForOptionV1(table, call);
        expect(price.truth, Act0BettingPriceTruthV1.consistent);
        expect(price.actorCommittedBb, 0);
        expect(price.callCostBb, 1);
        expect(price.minimumRaiseToBb, 2);
        expect(price.amountToMatchBb, 1);
        final chosenTotal = double.parse(raise.amountLabel.split(' ').first);
        // BTN contributes 3 chips; the outstanding price rises by only 2.
        expect(chosenTotal - price.actorCommittedBb!, 3);
        expect(chosenTotal - price.amountToMatchBb!, 2);
        expect(
          act0BettingPriceForOptionV1(table, raise).truth,
          Act0BettingPriceTruthV1.consistent,
        );
        expect(
          act0BettingPriceForOptionV1(
            table,
            const Act0RunnerOptionV1(
              id: 'synthetic-check',
              label: 'Check',
              isCorrect: false,
              preferredLabel: 'Check',
              quality: Act0FeedbackQualityV1.wrong,
              feedbackTitle: 'SIMULATED',
              feedbackReason: 'Legality only.',
            ),
          ).truth,
          Act0BettingPriceTruthV1.unproved,
        );
        expect(
          act0BettingRoundOrderProofForTableV1(
            table.copyWith(
              actionTrail: table.actionTrail
                  .where((a) => a.label != 'UTG folds')
                  .toList(),
            ),
          ).truth,
          isNot(Act0BettingRoundOrderTruthV1.consistent),
        );
        final current = act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: id,
        )!;
        expect(current, isNot(entry.value.$1));
        final old = Act0LearningEvidenceRecordV1(
          recordId: 'SIMULATED-old-$id',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: id,
          sourceTaskId: id,
          choiceId: 'raise',
          expectedChoiceId: 'raise',
          isCorrect: true,
          errorType: 'none',
          conceptFamilyId: 'action_basics',
          repairFocusId: '',
          skillAtomId: 'action_basics',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          assistanceKind: Act0DecisionAssistanceV1.none,
          authoredSourceFingerprint: entry.value.$1,
        );
        final raw = jsonEncode(old.toPayload());
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          jsonDecode(raw),
        )!;
        expect(jsonEncode(restored.toPayload()), raw);
        expect(act0CurrentAuthoredSourceProofV1(restored), isNull);
        final freshIdentityOnly = Act0LearningEvidenceRecordV1.tryParse({
          ...old.toPayload(),
          'authoredSourceFingerprint': current,
        })!;
        // Positive identity control is not a subject-validated strategy answer.
        if (task.phase == Act0LessonPhaseV1.theory) {
          expect(act0CurrentAuthoredSourceProofV1(freshIdentityOnly), isNull);
        } else {
          expect(
            act0CurrentAuthoredSourceProofV1(freshIdentityOnly),
            isNotNull,
          );
        }
      },
    );

    testWidgets(
      'folded-to-BTN $id exposes complete source premises at EN14Pro',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final task = _task(id);
        var answers = 0;
        final assistance = <Object>[];
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Scaffold(
              body: RepaintBoundary(
                key: const Key('btn-context-capture'),
                child: Act0LessonRunnerShellV1(
                  runner: task.runner.copyWith(
                    // Direct answer-stage snapshot after existing teaching;
                    // not an executed ordinary-route progression claim.
                    phase: Act0LessonPhaseV1.drill,
                    teachingStepIndex: task.runner.teachingSteps.length,
                  ),
                  worldNumber: 1,
                  selectedWorldId: 'world_1',
                  selectedLessonId: 'fold_check_call_raise',
                  selectedTaskId: id,
                  selectedTaskTitle: task.title,
                  selectedTaskFamily: task.resolvedTaskFamily,
                  compositionFamily: task.resolvedCompositionFamily,
                  tablePresentation: task.tablePresentation,
                  onBack: () {},
                  onContinueTheory: () {},
                  onContinueReview: () {},
                  onChooseOption: (_) => answers++,
                  onChooseSeat: (_) => answers++,
                  onChoiceAssistance: assistance.add,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text(task.runner.question), findsOneWidget);
        final caption = find.textContaining(
          act0LearnerFacingPremisesV1(task.runner.caption),
        );
        expect(caption, findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(caption);
        expect(paragraph.didExceedMaxLines, isFalse);
        final support = find.byWidgetPredicate(
          (widget) =>
              widget.key ==
                  const Key('act0_learning_scene_v3_model_support_scroll') ||
              widget.key ==
                  const Key('act0_learning_scene_v3_theory_support_scroll'),
        );
        expect(support, findsOneWidget);
        final scroll = tester.state<ScrollableState>(
          find.descendant(of: support, matching: find.byType(Scrollable)),
        );
        Future<void> capture(String suffix) => tester.runAsync(() async {
          final out = Platform.environment['FOLDED_BTN_CAPTURE_DIR'];
          if (out == null) return;
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('btn-context-capture')),
          );
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('$out/$id.$suffix.png')
            ..parent.createSync(recursive: true);
          file.writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await capture('start');
        if (scroll.position.maxScrollExtent > 0) {
          await tester.drag(support, const Offset(0, -1000));
          await tester.pumpAndSettle();
        }
        expect(scroll.position.extentAfter, lessThan(1));
        expect(
          tester.getRect(caption).bottom,
          lessThanOrEqualTo(tester.getRect(support).bottom + 1),
        );
        expect(answers, 0);
        expect(assistance, isEmpty);
        await capture('end');
      },
    );
  }
}
