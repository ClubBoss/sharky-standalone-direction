import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_asm05_authored_decision_truth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

// SOURCE TEST CANDIDATE. NOT_RUN. These are not Runner callback or UI proofs.
// Independent mathematical expectations come from full best-five enumeration
// in the private review, not from static Act0RunnerOptionV1.isCorrect flags.
void main() {
  const cheap = Act0Asm05TurnSnapshotV1.call10();
  const expensive = Act0Asm05TurnSnapshotV1.call40();
  const winningRivers = {'3h', '4h', '5h', '6h', '8h', '9h', 'Th', 'Jh', 'Ah'};

  List<String> rivers(Act0Asm05TurnSnapshotV1 source) {
    final known = {
      ...source.heroCards,
      ...source.knownVillainCards,
      ...source.turnBoard,
    };
    return [
      for (final rank in '23456789TJQKA'.split(''))
        for (final suit in 'cdhs'.split(''))
          if (!known.contains('$rank$suit')) '$rank$suit',
    ];
  }

  test('new authoring declares the constrained information and EV model', () {
    expect(cheap.provenance, 'NEW_AUTHORING_2026_11_08');
    expect(cheap.availableActions, [
      Act0Asm05ActionV1.fold,
      Act0Asm05ActionV1.call,
    ]);
    expect(cheap.assumptions, contains('uniformly shuffled'));
    expect(cheap.assumptions, contains('independently of their cards'));
    expect(cheap.assumptions, contains('both players must check'));
    expect(cheap.assumptions, contains('incremental expected value'));
    expect(cheap.assumptions, contains('raises are outside'));
  });

  for (final source in [cheap, expensive]) {
    final price = source.turnBetBb;
    test('call $price: all ledger prefixes conserve six starting budgets', () {
      final committed = {for (final seat in source.seatIds) seat: 0};
      var pot = 0;
      for (final event in source.ledger) {
        committed[event.seatId] = committed[event.seatId]! + event.addedHalfBb;
        pot += event.addedHalfBb;
        expect(committed.values.every((v) => v >= 0 && v <= 200), isTrue);
        expect(
          committed.values.fold(0, (int total, v) => total + 200 - v) + pot,
          1200,
        );
      }
      expect(
        source.ledger
            .where((e) => e.street == 'preflop')
            .fold(0, (int sum, e) => sum + e.addedHalfBb),
        80,
      );
      expect(source.potAtDecisionBb, 40 + price);
      expect(source.potAfterCallBb, 40 + 2 * price);
      expect(source.remainingHalfBb('bb'), 160);
      expect(source.remainingHalfBb('sb'), 160 - 2 * price);
      expect(source.committedHalfBb('bb'), 40);
      expect(source.committedHalfBb('sb'), 40 + 2 * price);
      for (final seat in source.foldedSeatIds) {
        expect(source.committedHalfBb(seat), 0);
        expect(source.remainingHalfBb(seat), 200);
      }
      expect(source.ledger.last.street, 'turn');
      expect(source.ledger.last.seatId, 'sb');
      expect(source.ledger.last.action, 'bet');
    });

    test(
      'call $price: all 44 actual winners and grades independently expected',
      () {
        final allRivers = rivers(source);
        expect(allRivers, hasLength(44));
        var observedWins = 0;
        for (final river in allRivers) {
          final actual = Act0Asm05AuthoredExerciseV1(
            preDecision: source,
            realizedRiver: river,
          ).complete(Act0Asm05ActionV1.call);
          final shouldWin = winningRivers.contains(river);
          if (actual.outcome.winner == Act0Asm05WinnerV1.hero) observedWins++;
          expect(
            actual.outcome.winner,
            shouldWin ? Act0Asm05WinnerV1.hero : Act0Asm05WinnerV1.villain,
            reason: 'river=$river price=$price',
          );
          expect(actual.isCorrect, price == 10, reason: 'river=$river');
          expect(actual.truth.heroWins, 9);
          expect(actual.truth.ties, 0);
          expect(
            actual.outcome.heroFinalStackBb +
                actual.outcome.villainFinalStackBb +
                400,
            600,
          );
          expect(actual.outcome.uncalledReturnBb, 0);
          expect(actual.outcome.awardedPotBb, 40 + 2 * price);
          final winningStack = price == 10 ? 130 : 160;
          final losingStack = price == 10 ? 70 : 40;
          expect(
            actual.outcome.heroFinalStackBb,
            shouldWin ? winningStack : losingStack,
          );
          expect(
            actual.outcome.villainFinalStackBb,
            shouldWin ? losingStack : winningStack,
          );
        }
        expect(observedWins, 9);
      },
    );

    test(
      'call $price: real winner swap changes outcome but no decision input',
      () {
        final loss = Act0Asm05AuthoredExerciseV1(
          preDecision: source,
          realizedRiver: 'Td',
        );
        final win = Act0Asm05AuthoredExerciseV1(
          preDecision: source,
          realizedRiver: '5h',
        );
        final before = jsonEncode(loss.preDecision.toPredecisionJson());
        expect(jsonEncode(win.preDecision.toPredecisionJson()), before);
        final a = loss.complete(Act0Asm05ActionV1.call);
        final b = win.complete(Act0Asm05ActionV1.call);
        expect(a.outcome.winner, Act0Asm05WinnerV1.villain);
        expect(b.outcome.winner, Act0Asm05WinnerV1.hero);
        expect(a.isCorrect, b.isCorrect);
        expect(a.truth.callEvNumerator, b.truth.callEvNumerator);
        expect(a.truth.callEvDenominator, b.truth.callEvDenominator);
        expect(jsonEncode(source.toPredecisionJson()), before);
        expect(before, isNot(contains('Td')));
        expect(before, isNot(contains('5h')));
        for (final key in [
          'river',
          'winner',
          'isCorrect',
          'callEv',
          'preferredAction',
        ]) {
          expect(before, isNot(contains('"$key"')));
        }
      },
    );

    test('call $price: fold returns uncalled bet and creates no river', () {
      final result = Act0Asm05AuthoredExerciseV1(
        preDecision: source,
        realizedRiver: '5h',
      ).complete(Act0Asm05ActionV1.fold);
      expect(result.isCorrect, price == 40);
      expect(result.truth.foldIncrementalEvBb, 0);
      expect(result.outcome.river, isNull);
      expect(result.outcome.winner, Act0Asm05WinnerV1.villain);
      expect(result.outcome.uncalledReturnBb, price);
      expect(result.outcome.awardedPotBb, 40);
      expect(result.outcome.heroFinalStackBb, 80);
      expect(result.outcome.villainFinalStackBb, 120);
      expect(result.outcome.heroWholeHandProfitBb, -20);
    });
  }

  test(
    'exact positive incremental EV does not mean positive realized profit',
    () {
      final result = Act0Asm05AuthoredExerciseV1.goodCallLoses().complete(
        Act0Asm05ActionV1.call,
      );
      expect(result.truth.riverCount, 44);
      expect(result.truth.callEvNumerator, 200);
      expect(result.truth.callEvDenominator, 88);
      expect(result.truth.callIncrementalEvBb, closeTo(25 / 11, 1e-12));
      expect(result.isCorrect, isTrue);
      expect(result.outcome.river, 'Td');
      expect(result.outcome.heroFinalStackBb, 70);
      expect(result.outcome.heroWholeHandProfitBb, -30);
    },
  );

  test('exact negative incremental EV remains wrong after a realized win', () {
    final result = Act0Asm05AuthoredExerciseV1.badCallWins().complete(
      Act0Asm05ActionV1.call,
    );
    expect(result.truth.callEvNumerator, -1360);
    expect(result.truth.callEvDenominator, 88);
    expect(result.truth.callIncrementalEvBb, closeTo(-170 / 11, 1e-12));
    expect(result.isCorrect, isFalse);
    expect(result.outcome.river, '5h');
    expect(result.outcome.heroFinalStackBb, 160);
    expect(result.outcome.heroWholeHandProfitBb, 60);
  });

  test('invalid or duplicate runout fails closed before grading', () {
    for (final card in ['Kh', 'As', '2h', '3c', 'ZZ', '10d', '']) {
      expect(
        () => Act0Asm05AuthoredExerciseV1(
          preDecision: cheap,
          realizedRiver: card,
        ),
        throwsArgumentError,
      );
    }
  });

  test('predecision authored cards and ledger cannot be mutated', () {
    expect(() => cheap.heroCards.add('Ah'), throwsUnsupportedError);
    expect(() => cheap.knownVillainCards.clear(), throwsUnsupportedError);
    expect(() => cheap.turnBoard.add('5h'), throwsUnsupportedError);
    expect(() => cheap.seatIds.clear(), throwsUnsupportedError);
    expect(() => cheap.foldedSeatIds.clear(), throwsUnsupportedError);
    expect(() => cheap.availableActions.clear(), throwsUnsupportedError);
    expect(() => cheap.ledger.clear(), throwsUnsupportedError);
    expect(() => cheap.committedHalfBb('unknown'), throwsArgumentError);
    final projection = cheap.toPredecisionJson();
    projection['potBb'] = 999;
    (projection['seats'] as List).clear();
    (projection['ledger'] as List).clear();
    expect(cheap.potAtDecisionBb, 50);
    expect(cheap.toPredecisionJson()['potBb'], 50);
    expect(cheap.toPredecisionJson()['seats'] as List, hasLength(6));
    expect(cheap.toPredecisionJson()['ledger'] as List, hasLength(11));
  });

  test(
    'factory reuses one independent truth and emits compatible option outputs',
    () {
      for (final source in [cheap, expensive]) {
        final exercise = Act0Asm05AuthoredExerciseV1(
          preDecision: source,
          realizedRiver: 'Td',
        );
        final task = _task(exercise);
        final truth = exercise.decisionTruth;
        expect(
          identical(truth, exercise.complete(Act0Asm05ActionV1.call).truth),
          isTrue,
        );
        expect(
          identical(truth, exercise.complete(Act0Asm05ActionV1.fold).truth),
          isTrue,
        );
        expect(task.taskId, source.sourceId);
        expect(task.taskFamily, Act0TaskFamilyV1.decision);
        expect(task.runner.phase, Act0LessonPhaseV1.drill);
        expect(task.runner.selectedOptionId, isNull);
        expect(task.runner.options.map((o) => o.id), ['fold', 'call']);
        expect(task.runner.options.map((o) => o.label), ['Fold', 'Call']);
        expect(task.runner.options.map((o) => o.amountLabel), [
          '',
          '${source.additionalCallBb} BB',
        ]);
        for (final option in task.runner.options) {
          final correct = source.turnBetBb == 10
              ? option.id == 'call'
              : option.id == 'fold';
          expect(option.isCorrect, correct);
          expect(
            option.quality,
            correct
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
          );
          expect(
            option.preferredLabel,
            source.turnBetBb == 10 ? 'Call' : 'Fold',
          );
          final preferredOption = task.runner.options.singleWhere(
            (candidate) => candidate.label == option.preferredLabel,
          );
          expect(preferredOption.isCorrect, isTrue);
          expect(preferredOption.quality, Act0FeedbackQualityV1.correct);
        }
        expect(() => task.runner.options.clear(), throwsUnsupportedError);
      }
    },
  );

  test(
    'unadmitted EV signal does not masquerade as a price-reading skill receipt',
    () {
      final task = _task(Act0Asm05AuthoredExerciseV1.goodCallLoses());
      expect(task.runner.feedbackSignalId, 'asm05_known_holes_ev');
      for (final option in task.runner.options) {
        expect(
          act0FirstValueSkillReceiptForRunnerV1(
            runner: task.runner,
            option: option,
            taskFamily: task.taskFamily,
          ),
          isNull,
        );
      }
    },
  );

  for (final source in [cheap, expensive]) {
    test(
      'factory call ${source.turnBetBb}: actual payout swap, same choice surface',
      () {
        final loss = _task(
          Act0Asm05AuthoredExerciseV1(preDecision: source, realizedRiver: 'Td'),
        );
        final win = _task(
          Act0Asm05AuthoredExerciseV1(preDecision: source, realizedRiver: '5h'),
        );
        final before = jsonEncode(_prechoiceFields(loss.runner));
        expect(jsonEncode(_prechoiceFields(win.runner)), before);
        expect(before, isNot(contains('Td')));
        expect(before, isNot(contains('5h')));
        expect(before, isNot(contains('Call EV')));
        expect(loss.runner.table.boardCards.map((c) => c.label), [
          '2♥',
          '7♥',
          '9♠',
          '3♣',
        ]);
        expect(
          loss.runner.table.seats
              .firstWhere((s) => s.seatId == 'sb')
              .holeCards
              .map((c) => c.label),
          ['A♠', 'A♦'],
        );
        expect(
          loss.runner.table.seats
              .firstWhere((s) => s.seatId == 'bb')
              .currentBetLabel,
          '0 BB',
        );
        expect(loss.runner.table.centerLabel, 'Turn decision snapshot');
        final lossCall = loss.runner.options.singleWhere((o) => o.id == 'call');
        final winCall = win.runner.options.singleWhere((o) => o.id == 'call');
        expect(lossCall.isCorrect, winCall.isCorrect);
        expect(lossCall.quality, winCall.quality);
        expect(lossCall.preferredLabel, winCall.preferredLabel);
        final pot = source.turnBetBb == 10 ? 60 : 120;
        expect(
          lossCall.feedbackReason,
          contains('River Td: SB receives $pot BB.'),
        );
        expect(
          winCall.feedbackReason,
          contains('River 5h: You receive $pot BB.'),
        );
        final lossReview = loss.runner.copyWith(
          phase: Act0LessonPhaseV1.review,
          selectedOptionId: 'call',
        );
        final winReview = win.runner.copyWith(
          phase: Act0LessonPhaseV1.review,
          selectedOptionId: 'call',
        );
        expect(lossReview.reviewReason, lossCall.feedbackReason);
        expect(winReview.reviewReason, winCall.feedbackReason);
        expect(lossReview.reviewQuality, winReview.reviewQuality);
        final folded = win.runner.copyWith(
          phase: Act0LessonPhaseV1.review,
          selectedOptionId: 'fold',
        );
        expect(folded.reviewReason, contains('No river is played.'));
        expect(folded.reviewReason, isNot(contains('5h')));
        expect(folded.reviewReason, contains('takes 40 BB'));
      },
    );
  }
}

Act0LessonTaskV1 _task(Act0Asm05AuthoredExerciseV1 exercise) =>
    act0Asm05AuthoredDecisionTaskV1(
      exercise: exercise,
      lessonId: 'asm05_private_known_cards',
      lessonTitle: 'Decision and outcome',
      beatIndex: 0,
      beatCount: 1,
      rewardXp: 0,
      returnTarget: 'learn',
      nextLessonId: null,
    );

// Actual factory outputs intended for choice UI, not the complete internal
// option records whose feedback is review-only. UI/semantics still NOT_RUN.
Map<String, Object?> _prechoiceFields(Act0RunnerStateV1 runner) => {
  'caption': runner.caption,
  'hint': runner.hint,
  'question': runner.question,
  'fallbackFeedbackTitle': runner.feedbackTitle,
  'fallbackFeedbackReason': runner.feedbackReason,
  'feedbackSignalId': runner.feedbackSignalId,
  'options': [
    for (final o in runner.options)
      {'id': o.id, 'label': o.label, 'amount': o.amountLabel},
  ],
  'street': runner.table.streetLabel,
  'pot': runner.table.potLabel,
  'toCall': runner.table.toCallLabel,
  'center': runner.table.centerLabel,
  'board': runner.table.boardCards.map((c) => c.label).toList(),
  'hero': runner.table.heroCards.map((c) => c.label).toList(),
  'seats': [
    for (final s in runner.table.seats)
      {
        'seat': s.seatId,
        'stack': s.stackLabel,
        'bet': s.currentBetLabel,
        'folded': s.isFolded,
        'cards': s.holeCards.map((c) => c.label).toList(),
      },
  ],
  'trail': runner.table.actionTrail.map((e) => e.label).toList(),
  'highlightedSeats': runner.table.highlightedSeatIds,
  'highlightedCards': runner.table.highlightedCardIds,
};
