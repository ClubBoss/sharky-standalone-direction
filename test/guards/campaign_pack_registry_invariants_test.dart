import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/world1_foundations_microtask_runner_screen.dart';

const _world1ActionablePackIdsV1 = <String>[
  'world1_spine_campaign_v1',
  'world1_spine_followup_v1_b0',
  'world1_spine_followup_v1_b1',
  'world1_spine_followup_v1_b2',
];

void main() {
  test('world2..world10 campaign packs satisfy registry invariants', () {
    final campaignIds =
        kCampaignPacksV1.keys
            .where(
              (id) =>
                  RegExp(r'^world([2-9]|10)_spine_campaign_v1$').hasMatch(id),
            )
            .toList()
          ..sort();

    expect(campaignIds.length, 9);

    for (final packId in campaignIds) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'Missing pack: $packId');
      final steps = pack12(pack!);

      expect(
        campaignHandCountForPackIdV1(packId),
        12,
        reason: 'Campaign pack hand count drift: $packId',
      );
      expect(
        hasPositiveAndNegativeConsequenceDeltas(steps),
        isTrue,
        reason: 'Missing +/- deltas in consequence text: $packId',
      );
      expect(
        distinctConsequenceTextCount(steps),
        greaterThanOrEqualTo(6),
        reason: 'Consequence variety too low: $packId',
      );
    }
  });

  test('world1 campaign pack keeps stronger consequence variety', () {
    final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
    expect(pack, isNotNull, reason: 'Missing pack: world1_spine_campaign_v1');
    final steps = pack12(pack!);

    expect(
      campaignHandCountForPackIdV1('world1_spine_campaign_v1'),
      12,
      reason: 'Campaign pack hand count drift: world1_spine_campaign_v1',
    );
    expect(
      hasPositiveAndNegativeConsequenceDeltas(steps),
      isTrue,
      reason:
          'Missing +/- deltas in consequence text: world1_spine_campaign_v1',
    );
    expect(
      distinctConsequenceTextCount(steps),
      greaterThanOrEqualTo(8),
      reason: 'Consequence variety too low: world1_spine_campaign_v1',
    );
  });

  test('world1 spine campaign keeps poker legality invariants', () {
    final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
    expect(pack, isNotNull, reason: 'Missing pack: world1_spine_campaign_v1');
    final steps = pack12(pack!);

    int _expectedVisibleCount(MicroTaskStep step) {
      switch (step.street) {
        case null:
          return 0;
        case MicroTaskStreetV1.flop:
          return 3;
        case MicroTaskStreetV1.turn:
          return 4;
        case MicroTaskStreetV1.river:
          return 5;
      }
    }

    bool _hasAction(List<String> actions, String action) {
      return actions.any((value) => value.trim().toLowerCase() == action);
    }

    bool _hasRaiseAction(List<String> actions) {
      return actions.any(
        (value) => value.trim().toLowerCase().startsWith('raise'),
      );
    }

    final preflopToCalls = steps
        .where((step) => step.street == null)
        .map((step) => step.toCall)
        .whereType<int>()
        .where((value) => value > 0)
        .toList(growable: false);
    final impliedBigBlind = preflopToCalls.fold<int>(
      0,
      (maxValue, value) => value > maxValue ? value : maxValue,
    );
    final impliedSmallBlind = preflopToCalls.fold<int>(
      impliedBigBlind,
      (minValue, value) => value < minValue ? value : minValue,
    );
    final impliedBlindPotFloor = impliedSmallBlind + impliedBigBlind;
    expect(impliedBlindPotFloor, greaterThan(0));

    var previousVisibleCount = 0;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final boardVisibleCount = step.boardCards?.length ?? 0;
      final expectedVisibleCount = _expectedVisibleCount(step);

      expect(
        boardVisibleCount,
        expectedVisibleCount,
        reason:
            'Street/board mismatch at step $i: street=${step.street}, board=${step.boardCards}',
      );

      if (boardVisibleCount < previousVisibleCount) {
        expect(
          expectedVisibleCount,
          0,
          reason: 'Board visibility decreased without preflop reset at step $i',
        );
      }
      previousVisibleCount = boardVisibleCount;

      final actions = (step.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      if (actions.isNotEmpty) {
        expect(
          step.toCall,
          isNotNull,
          reason: 'Actionable step missing toCall at step $i',
        );
        final toCall = step.toCall!;
        if (toCall == 0) {
          expect(
            _hasAction(actions, 'check'),
            isTrue,
            reason: 'toCall==0 must include CHECK at step $i',
          );
          expect(
            _hasAction(actions, 'call'),
            isFalse,
            reason: 'toCall==0 must not include CALL at step $i',
          );
        } else {
          expect(
            _hasAction(actions, 'call'),
            isTrue,
            reason: 'toCall>0 must include CALL at step $i',
          );
          expect(
            _hasAction(actions, 'fold'),
            isTrue,
            reason: 'toCall>0 must include FOLD at step $i',
          );
          expect(
            _hasAction(actions, 'check'),
            isFalse,
            reason: 'toCall>0 must not include CHECK at step $i',
          );
        }
        if (_hasRaiseAction(actions)) {
          expect(
            toCall,
            greaterThanOrEqualTo(0),
            reason: 'RAISE action requires a non-negative toCall at step $i',
          );
        }
      }

      if (step.street == null) {
        expect(
          step.pot,
          isNotNull,
          reason: 'Preflop step missing pot at step $i',
        );
        expect(
          step.pot!,
          greaterThanOrEqualTo(impliedBlindPotFloor),
          reason:
              'Preflop pot below implied blind floor ($impliedBlindPotFloor) at step $i',
        );
      }
    }
  });

  test('world1 spine campaign keeps preflop blinds-only pot sanity', () {
    const packId = 'world1_spine_campaign_v1';
    final pack = kCampaignPacksV1[packId];
    expect(pack, isNotNull, reason: 'Missing pack: $packId');
    final steps = pack12(pack!);

    final preflopSteps = <({int index, MicroTaskStep step})>[
      for (var i = 0; i < steps.length; i++)
        if (steps[i].street == null && (steps[i].boardCards?.isEmpty ?? true))
          (index: i, step: steps[i]),
    ];
    expect(
      preflopSteps,
      isNotEmpty,
      reason: 'pack=$packId has no preflop steps to validate',
    );

    final impliedBbCandidates = preflopSteps
        .where((entry) => (entry.step.heroSeatId ?? '').toUpperCase() != 'SB')
        .map((entry) => entry.step.toCall)
        .whereType<int>()
        .where((value) => value > 0)
        .toList(growable: false);
    expect(
      impliedBbCandidates,
      isNotEmpty,
      reason:
          'pack=$packId cannot derive impliedBB from non-SB preflop toCall values',
    );
    final impliedBb = impliedBbCandidates.reduce((a, b) => a < b ? a : b);
    expect(
      impliedBb % 2,
      0,
      reason:
          'pack=$packId impliedBB must be divisible by 2 for integer SB, got impliedBB=$impliedBb',
    );
    final impliedSb = impliedBb ~/ 2;
    final expectedBlindsPot = impliedSb + impliedBb;

    bool isBlindsOnlyPreflopStep(MicroTaskStep step) {
      if (step.street != null) return false;
      if (!(step.boardCards?.isEmpty ?? true)) return false;
      final toCall = step.toCall ?? -1;
      if (toCall != impliedBb) return false;
      final pot = step.pot ?? -1;
      return pot <= expectedBlindsPot + impliedBb;
    }

    final blindsOnlySteps = preflopSteps
        .where((entry) => isBlindsOnlyPreflopStep(entry.step))
        .toList(growable: false);
    expect(
      blindsOnlySteps,
      isNotEmpty,
      reason:
          'pack=$packId has no blinds-only preflop steps (street=null, board empty, toCall=$impliedBb)',
    );

    for (final entry in blindsOnlySteps) {
      final step = entry.step;
      expect(
        step.pot,
        expectedBlindsPot,
        reason:
            'pack=$packId step=${entry.index} blinds-only preflop pot mismatch: pot=${step.pot} toCall=${step.toCall} expected=$expectedBlindsPot',
      );
    }
  });

  test('world1 spine campaign keeps actionable-step contract invariants', () {
    const packId = 'world1_spine_campaign_v1';
    final pack = kCampaignPacksV1[packId];
    expect(pack, isNotNull, reason: 'Missing pack: $packId');
    final steps = pack12(pack!);

    const allowedActionDomain = <String>{
      'fold',
      'call',
      'check',
      'bet',
      'raise',
      'raise_to',
      'raise_min',
    };

    bool _hasAction(List<String> actions, String action) =>
        actions.contains(action);

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final actions = (step.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);

      expect(
        actions,
        isNotEmpty,
        reason: 'pack=$packId step=$i missing allowedActions',
      );
      for (final action in actions) {
        expect(
          allowedActionDomain.contains(action),
          isTrue,
          reason: 'pack=$packId step=$i unknown allowedAction=$action',
        );
      }

      expect(step.pot, isNotNull, reason: 'pack=$packId step=$i missing pot');
      expect(
        step.pot!,
        greaterThan(0),
        reason: 'pack=$packId step=$i pot must be > 0',
      );

      expect(
        step.toCall,
        isNotNull,
        reason: 'pack=$packId step=$i missing toCall',
      );
      expect(
        step.toCall!,
        greaterThanOrEqualTo(0),
        reason: 'pack=$packId step=$i toCall must be >= 0',
      );

      expect(
        step.heroCards,
        isNotNull,
        reason: 'pack=$packId step=$i missing heroCards',
      );
      expect(
        step.heroCards!.length,
        2,
        reason: 'pack=$packId step=$i heroCards must contain 2 cards',
      );

      final boardCount = step.boardCards?.length ?? 0;
      if (boardCount > 0) {
        expect(
          step.street,
          isNotNull,
          reason: 'pack=$packId step=$i boardCards present but street is null',
        );
      }

      final toCall = step.toCall!;
      if (toCall == 0) {
        expect(
          _hasAction(actions, 'fold'),
          isFalse,
          reason: 'pack=$packId step=$i fold must be absent when toCall==0',
        );
        expect(
          _hasAction(actions, 'call'),
          isFalse,
          reason: 'pack=$packId step=$i call must be absent when toCall==0',
        );
        expect(
          _hasAction(actions, 'check') || _hasAction(actions, 'bet'),
          isTrue,
          reason:
              'pack=$packId step=$i toCall==0 must include at least check or bet',
        );
      } else {
        expect(
          _hasAction(actions, 'check'),
          isFalse,
          reason: 'pack=$packId step=$i check must be absent when toCall>0',
        );
        expect(
          _hasAction(actions, 'call') || _hasAction(actions, 'fold'),
          isTrue,
          reason:
              'pack=$packId step=$i toCall>0 must include at least call or fold',
        );
      }
    }
  });

  test('world1 spine campaign keeps action variety invariants', () {
    const packId = 'world1_spine_campaign_v1';
    final pack = kCampaignPacksV1[packId];
    expect(pack, isNotNull, reason: 'Missing pack: $packId');
    final steps = pack12(pack!);

    int? zeroToCallBetStepIndex;
    int? positiveToCallRaiseToStepIndex;

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final toCall = step.toCall ?? -1;
      final actions = (step.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty)
          .toSet();
      if (toCall == 0 && actions.contains('bet')) {
        zeroToCallBetStepIndex ??= i;
      }
      if (toCall > 0 && actions.contains('raise_to')) {
        positiveToCallRaiseToStepIndex ??= i;
      }
    }

    expect(
      zeroToCallBetStepIndex,
      isNotNull,
      reason:
          'pack=$packId missing action variety: no toCall==0 step includes BET',
    );
    expect(
      positiveToCallRaiseToStepIndex,
      isNotNull,
      reason:
          'pack=$packId missing action variety: no toCall>0 step includes RAISE_TO',
    );
  });

  test(
    'world1 spine campaign actionable steps expose deterministic expected action',
    () {
      const packId = 'world1_spine_campaign_v1';
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'Missing pack: $packId');
      final steps = pack12(pack!);

      bool includesExpectedAction(
        Set<String> actions,
        ActionKindV1 expectedAction,
      ) {
        return switch (expectedAction) {
          ActionKindV1.fold => actions.contains('fold'),
          ActionKindV1.check => actions.contains('check'),
          ActionKindV1.call => actions.contains('call'),
          ActionKindV1.bet => actions.contains('bet'),
          ActionKindV1.raise =>
            actions.contains('raise') ||
                actions.contains('raise_to') ||
                actions.contains('raise_min'),
        };
      }

      var sawExpectedBet = false;
      var sawExpectedRaiseTo = false;

      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        final actions = (step.allowedActions ?? const <String>[])
            .map((value) => value.trim().toLowerCase().replaceAll('-', '_'))
            .where((value) => value.isNotEmpty)
            .toSet();
        if (actions.isEmpty) {
          continue;
        }

        final explicitExpected = step.expectedActionKind
            ?.trim()
            .toLowerCase()
            .replaceAll('-', '_');
        expect(
          explicitExpected,
          isNotNull,
          reason: 'pack=$packId step=$i missing explicit expectedActionKind',
        );
        expect(
          explicitExpected!.isNotEmpty,
          isTrue,
          reason: 'pack=$packId step=$i has empty expectedActionKind',
        );
        expect(
          actions.contains(explicitExpected),
          isTrue,
          reason:
              'pack=$packId step=$i expectedActionKind=$explicitExpected must be in allowedActions=$actions',
        );
        if (explicitExpected == 'bet' && (step.toCall ?? -1) == 0) {
          sawExpectedBet = true;
        }
        if (explicitExpected == 'raise_to' && (step.toCall ?? 0) > 0) {
          sawExpectedRaiseTo = true;
        }

        final expectedAction = world1SpineExpectedActionKindV1(step);
        expect(
          expectedAction,
          isNotNull,
          reason: 'pack=$packId step=$i missing deterministic expected action',
        );
        expect(
          includesExpectedAction(actions, expectedAction!),
          isTrue,
          reason:
              'pack=$packId step=$i expected action $expectedAction not in allowedActions=$actions',
        );
      }

      expect(
        sawExpectedBet,
        isTrue,
        reason:
            'pack=$packId must include at least one explicit expectedActionKind=bet with toCall==0',
      );
      expect(
        sawExpectedRaiseTo,
        isTrue,
        reason:
            'pack=$packId must include at least one explicit expectedActionKind=raise_to with toCall>0',
      );
    },
  );

  test('world1 actionable packs keep followup poker legality invariants', () {
    const allowedActionDomain = <String>{
      'fold',
      'call',
      'check',
      'bet',
      'raise',
      'raise_to',
      'raise_min',
    };

    bool isValidCardToken(String token) {
      final normalized = token.trim().toUpperCase();
      if (normalized.length < 2 || normalized.length > 3) {
        return false;
      }
      final rank = normalized.substring(0, normalized.length - 1);
      final suit = normalized.substring(normalized.length - 1);
      const validRanks = <String>{
        'A',
        'K',
        'Q',
        'J',
        'T',
        '10',
        '9',
        '8',
        '7',
        '6',
        '5',
        '4',
        '3',
        '2',
      };
      const validSuits = <String>{'S', 'H', 'D', 'C'};
      return validRanks.contains(rank) && validSuits.contains(suit);
    }

    String normalizeCardToken(String token) => token.trim().toUpperCase();

    int expectedBoardCountForStreet(MicroTaskStreetV1? street) {
      switch (street) {
        case null:
          return 0;
        case MicroTaskStreetV1.flop:
          return 3;
        case MicroTaskStreetV1.turn:
          return 4;
        case MicroTaskStreetV1.river:
          return 5;
      }
    }

    for (final packId in _world1ActionablePackIdsV1) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'Missing pack: $packId');
      final steps = pack12(pack!);

      var sawExpectedBetAtZeroToCall = false;
      var sawExpectedRaiseToAtPositiveToCall = false;
      var sawCallFoldSpotAtPositiveToCall = false;

      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        final actions = (step.allowedActions ?? const <String>[])
            .map((value) => value.trim().toLowerCase().replaceAll('-', '_'))
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
        expect(
          actions,
          isNotEmpty,
          reason: 'pack=$packId step=$i missing allowedActions',
        );
        for (final action in actions) {
          expect(
            allowedActionDomain.contains(action),
            isTrue,
            reason: 'pack=$packId step=$i unknown allowedAction=$action',
          );
        }

        expect(step.pot, isNotNull, reason: 'pack=$packId step=$i missing pot');
        expect(
          step.pot!,
          greaterThan(0),
          reason: 'pack=$packId step=$i pot must be > 0',
        );

        expect(
          step.toCall,
          isNotNull,
          reason: 'pack=$packId step=$i missing toCall',
        );
        expect(
          step.toCall!,
          greaterThanOrEqualTo(0),
          reason: 'pack=$packId step=$i toCall must be >= 0',
        );
        final toCall = step.toCall!;

        expect(
          step.heroCards,
          isNotNull,
          reason: 'pack=$packId step=$i missing heroCards',
        );
        expect(
          step.heroCards!.length,
          2,
          reason: 'pack=$packId step=$i heroCards must contain 2 cards',
        );

        final boardCards = step.boardCards ?? const <String>[];
        final expectedBoardCount = expectedBoardCountForStreet(step.street);
        expect(
          boardCards.length,
          expectedBoardCount,
          reason:
              'pack=$packId step=$i board count mismatch for street=${step.street}',
        );
        if (boardCards.isNotEmpty) {
          expect(
            step.street,
            isNotNull,
            reason:
                'pack=$packId step=$i boardCards present but street is null',
          );
        }

        final normalizedHero = (step.heroCards ?? const <String>[])
            .map(normalizeCardToken)
            .toList(growable: false);
        final normalizedBoard = boardCards
            .map(normalizeCardToken)
            .toList(growable: false);
        for (final card in normalizedHero) {
          expect(
            isValidCardToken(card),
            isTrue,
            reason: 'pack=$packId step=$i invalid hero card token: $card',
          );
        }
        for (final card in normalizedBoard) {
          expect(
            isValidCardToken(card),
            isTrue,
            reason: 'pack=$packId step=$i invalid board card token: $card',
          );
        }
        expect(
          normalizedHero.toSet().length,
          normalizedHero.length,
          reason: 'pack=$packId step=$i duplicate hero cards: $normalizedHero',
        );
        expect(
          normalizedBoard.toSet().length,
          normalizedBoard.length,
          reason:
              'pack=$packId step=$i duplicate board cards: $normalizedBoard',
        );
        final overlap = normalizedHero.toSet().intersection(
          normalizedBoard.toSet(),
        );
        expect(
          overlap,
          isEmpty,
          reason: 'pack=$packId step=$i hero-board overlap must be empty',
        );

        if (toCall == 0) {
          expect(
            actions.contains('fold'),
            isFalse,
            reason: 'pack=$packId step=$i fold must be absent when toCall==0',
          );
          expect(
            actions.contains('call'),
            isFalse,
            reason: 'pack=$packId step=$i call must be absent when toCall==0',
          );
          expect(
            actions.contains('check') || actions.contains('bet'),
            isTrue,
            reason:
                'pack=$packId step=$i toCall==0 must include at least check or bet',
          );
        } else {
          expect(
            actions.contains('check'),
            isFalse,
            reason: 'pack=$packId step=$i check must be absent when toCall>0',
          );
          expect(
            actions.contains('call'),
            isTrue,
            reason: 'pack=$packId step=$i toCall>0 must include CALL',
          );
          expect(
            actions.contains('fold'),
            isTrue,
            reason: 'pack=$packId step=$i toCall>0 must include FOLD',
          );
          sawCallFoldSpotAtPositiveToCall = true;
        }

        final explicitExpected = step.expectedActionKind
            ?.trim()
            .toLowerCase()
            .replaceAll('-', '_');
        expect(
          explicitExpected,
          isNotNull,
          reason: 'pack=$packId step=$i missing explicit expectedActionKind',
        );
        expect(
          explicitExpected!.isNotEmpty,
          isTrue,
          reason: 'pack=$packId step=$i has empty expectedActionKind',
        );
        expect(
          actions.contains(explicitExpected),
          isTrue,
          reason:
              'pack=$packId step=$i expectedActionKind=$explicitExpected must be in allowedActions=$actions',
        );

        if (toCall == 0 && explicitExpected == 'bet') {
          sawExpectedBetAtZeroToCall = true;
        }
        if (toCall > 0 && explicitExpected == 'raise_to') {
          sawExpectedRaiseToAtPositiveToCall = true;
        }
      }

      expect(
        sawExpectedBetAtZeroToCall,
        isTrue,
        reason:
            'pack=$packId must include at least one toCall==0 step with expectedActionKind=bet',
      );
      expect(
        sawExpectedRaiseToAtPositiveToCall,
        isTrue,
        reason:
            'pack=$packId must include at least one toCall>0 step with expectedActionKind=raise_to',
      );
      expect(
        sawCallFoldSpotAtPositiveToCall,
        isTrue,
        reason:
            'pack=$packId must include at least one toCall>0 step with CALL+FOLD actions',
      );
    }
  });

  test('world1 spine campaign keeps card-set correctness invariants', () {
    const packId = 'world1_spine_campaign_v1';
    final pack = kCampaignPacksV1[packId];
    expect(pack, isNotNull, reason: 'Missing pack: $packId');
    final steps = pack12(pack!);

    int _expectedVisibleCount(MicroTaskStep step) {
      switch (step.street) {
        case null:
          return 0;
        case MicroTaskStreetV1.flop:
          return 3;
        case MicroTaskStreetV1.turn:
          return 4;
        case MicroTaskStreetV1.river:
          return 5;
      }
    }

    bool _isValidCardToken(String token) {
      final normalized = token.trim().toUpperCase();
      if (normalized.length < 2 || normalized.length > 3) {
        return false;
      }
      final rank = normalized.substring(0, normalized.length - 1);
      final suit = normalized.substring(normalized.length - 1);
      const validRanks = <String>{
        'A',
        'K',
        'Q',
        'J',
        'T',
        '10',
        '9',
        '8',
        '7',
        '6',
        '5',
        '4',
        '3',
        '2',
      };
      const validSuits = <String>{'S', 'H', 'D', 'C'};
      return validRanks.contains(rank) && validSuits.contains(suit);
    }

    String _normalizeCardToken(String token) => token.trim().toUpperCase();

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final heroCards = step.heroCards ?? const <String>[];
      final boardCards = step.boardCards ?? const <String>[];
      final expectedVisibleCount = _expectedVisibleCount(step);

      if (heroCards.isNotEmpty) {
        expect(
          heroCards.length,
          2,
          reason: 'pack=$packId step=$i hero cards must contain exactly 2',
        );
      }
      expect(
        boardCards.length,
        expectedVisibleCount,
        reason:
            'pack=$packId step=$i board count mismatch for street=${step.street}',
      );

      final normalizedHero = heroCards
          .map(_normalizeCardToken)
          .toList(growable: false);
      final normalizedBoard = boardCards
          .map(_normalizeCardToken)
          .toList(growable: false);

      for (final card in normalizedHero) {
        expect(
          _isValidCardToken(card),
          isTrue,
          reason: 'pack=$packId step=$i invalid hero card token: $card',
        );
      }
      for (final card in normalizedBoard) {
        expect(
          _isValidCardToken(card),
          isTrue,
          reason: 'pack=$packId step=$i invalid board card token: $card',
        );
      }

      expect(
        normalizedHero.toSet().length,
        normalizedHero.length,
        reason: 'pack=$packId step=$i duplicate hero cards: $normalizedHero',
      );
      expect(
        normalizedBoard.toSet().length,
        normalizedBoard.length,
        reason: 'pack=$packId step=$i duplicate board cards: $normalizedBoard',
      );

      final heroBoardOverlap = normalizedHero.toSet().intersection(
        normalizedBoard.toSet(),
      );
      expect(
        heroBoardOverlap,
        isEmpty,
        reason:
            'pack=$packId step=$i hero-board overlap must be empty: $heroBoardOverlap',
      );
    }
  });

  test('world1 spine campaign keeps street progression invariants', () {
    const packId = 'world1_spine_campaign_v1';
    final pack = kCampaignPacksV1[packId];
    expect(pack, isNotNull, reason: 'Missing pack: $packId');
    final steps = pack12(pack!);

    int _streetStage(MicroTaskStreetV1? street) {
      switch (street) {
        case null:
          return 0;
        case MicroTaskStreetV1.flop:
          return 1;
        case MicroTaskStreetV1.turn:
          return 2;
        case MicroTaskStreetV1.river:
          return 3;
      }
    }

    var sawFlop = false;
    var sawTurn = false;
    var sawRiver = false;
    int? firstFlopIndex;
    int? firstTurnIndex;
    int? firstRiverIndex;

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final street = step.street;

      if (street == MicroTaskStreetV1.turn && !sawFlop) {
        fail(
          'pack=$packId step=$i turn appears before any flop step: street=$street',
        );
      }
      if (street == MicroTaskStreetV1.river && !sawTurn) {
        fail(
          'pack=$packId step=$i river appears before any turn step: street=$street',
        );
      }

      if (street == MicroTaskStreetV1.flop) {
        sawFlop = true;
        firstFlopIndex ??= i;
      }
      if (street == MicroTaskStreetV1.turn) {
        sawTurn = true;
        firstTurnIndex ??= i;
      }
      if (street == MicroTaskStreetV1.river) {
        sawRiver = true;
        firstRiverIndex ??= i;
      }
    }

    expect(sawFlop, isTrue, reason: 'pack=$packId missing required flop step');
    expect(sawTurn, isTrue, reason: 'pack=$packId missing required turn step');
    expect(
      sawRiver,
      isTrue,
      reason: 'pack=$packId missing required river step',
    );

    expect(
      firstFlopIndex,
      isNotNull,
      reason: 'pack=$packId missing first flop index',
    );
    expect(
      firstTurnIndex,
      isNotNull,
      reason: 'pack=$packId missing first turn index',
    );
    expect(
      firstRiverIndex,
      isNotNull,
      reason: 'pack=$packId missing first river index',
    );
    expect(
      firstFlopIndex!,
      lessThan(firstTurnIndex!),
      reason:
          'pack=$packId invalid first-street order: firstFlop=$firstFlopIndex firstTurn=$firstTurnIndex',
    );
    expect(
      firstTurnIndex,
      lessThan(firstRiverIndex!),
      reason:
          'pack=$packId invalid first-street order: firstTurn=$firstTurnIndex firstRiver=$firstRiverIndex',
    );
  });

  test('world2 campaign pack keeps Golden Hour consequence variety', () {
    final pack = kCampaignPacksV1['world2_spine_campaign_v1'];
    expect(pack, isNotNull, reason: 'Missing pack: world2_spine_campaign_v1');
    final steps = pack12(pack!);

    expect(
      campaignHandCountForPackIdV1('world2_spine_campaign_v1'),
      12,
      reason: 'Campaign pack hand count drift: world2_spine_campaign_v1',
    );
    expect(
      hasPositiveAndNegativeConsequenceDeltas(steps),
      isTrue,
      reason:
          'Missing +/- deltas in consequence text: world2_spine_campaign_v1',
    );
    expect(
      distinctConsequenceTextCount(steps),
      greaterThanOrEqualTo(8),
      reason: 'Consequence variety too low: world2_spine_campaign_v1',
    );
  });

  test('world1 fairness shield clamps correct negative delta to zero only', () {
    expect(
      applyWorld1FairnessShieldDeltaV1(
        packId: 'world1_spine_campaign_v1',
        isCorrect: true,
        rawDelta: -6,
      ),
      0,
    );
    expect(
      applyWorld1FairnessShieldDeltaV1(
        packId: 'world1_spine_campaign_v1',
        isCorrect: true,
        rawDelta: 8,
      ),
      8,
    );
    expect(
      applyWorld1FairnessShieldDeltaV1(
        packId: 'world2_spine_campaign_v1',
        isCorrect: true,
        rawDelta: -6,
      ),
      -6,
    );
    expect(
      applyWorld1FairnessShieldDeltaV1(
        packId: 'world1_spine_campaign_v1',
        isCorrect: false,
        rawDelta: -6,
      ),
      -6,
    );
  });
}
