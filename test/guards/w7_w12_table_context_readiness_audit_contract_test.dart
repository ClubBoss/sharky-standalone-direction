import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w11_board_texture_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart';

void main() {
  test('W7-W12 active route specs have visible table context', () {
    final specs = _activeRouteSpecsV1();
    expect(specs, hasLength(24));

    for (final spec in specs) {
      final context = '${spec.worldId}/${spec.taskId}';
      expect(spec.worldId, matches(RegExp(r'^world_(7|8|9|10|11|12)$')));
      expect(spec.lessonId.trim(), isNotEmpty, reason: context);
      expect(spec.taskId.trim(), isNotEmpty, reason: context);
      expect(spec.sourceTaskId.trim(), isNotEmpty, reason: context);
      expect(spec.conceptFamilyId.trim(), isNotEmpty, reason: context);
      expect(spec.boardContext.trim(), isNotEmpty, reason: context);
      expect(spec.learningPurpose.trim(), isNotEmpty, reason: context);
      expect(spec.learnerPrompt.trim(), isNotEmpty, reason: context);
      expect(spec.choiceIds, contains(spec.expectedChoiceId), reason: context);
      final structurallyAdmitted = <String>{
        'world_10',
        'world_11',
        'world_12',
      }.contains(spec.worldId);
      expect(
        spec.practiceCtaAllowed,
        structurallyAdmitted ? isTrue : isFalse,
        reason: context,
      );
      if (structurallyAdmitted) {
        expect(spec.mapperNoTargetReason, isEmpty, reason: context);
      } else {
        expect(
          spec.mapperNoTargetReason,
          contains('route_locked_no_safe_practice_target_v1'),
          reason: context,
        );
      }

      for (final choiceId in spec.choiceIds) {
        expect(
          (spec.choiceLabels as Map<String, String>)[choiceId]?.trim(),
          isNotEmpty,
          reason: '$context/$choiceId',
        );
      }
    }
  });

  test('active route table context is source-backed and replay-safe', () {
    for (final spec in _activeRouteSpecsV1()) {
      final context = '${spec.worldId}/${spec.taskId}';
      final table = _activeRouteTableForSpecV1(spec);

      expect(table.streetLabel, 'Flop', reason: context);
      expect(table.boardCards, hasLength(3), reason: context);
      expect(table.heroSeatId, 'btn', reason: context);
      expect(table.activeSeatId, 'btn', reason: context);
      expect(table.heroSeat.seatLabel, 'BTN', reason: context);
      expect(table.potLabel, startsWith('Pot '), reason: context);
      expect(table.centerLabel, spec.boardContext, reason: context);
      expect(table.focusCalloutLabel, spec.learningPurpose, reason: context);

      if (spec.worldId == 'world_9') {
        expect(table.toCallLabel, 'Call 3 BB', reason: context);
      } else {
        expect(table.toCallLabel, isEmpty, reason: context);
      }

      final replay = act0StreetReplayFromTableV1(table);
      expect(replay, isNotNull, reason: context);
      expect(replay!.isConsumerSafe, isFalse, reason: context);
      expect(
        replay.completeness,
        Act0StreetReplayCompletenessV1.insufficient,
        reason: context,
      );
      expect(replay.steps, isEmpty, reason: context);
    }
  });

  test('active route table context keeps forbidden expansions out', () {
    final source = _activeRouteSpecsV1()
        .map(
          (spec) => <String>[
            spec.learnerPrompt as String,
            spec.boardContext as String,
            spec.learningPurpose as String,
            spec.feedbackReason as String,
            ...(spec.choiceLabels as Map<String, String>).values,
            ...(spec.incorrectFeedback as Map<String, String>).values,
          ].join(' '),
        )
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'solver',
      'gto',
      'world13',
      'w13',
      'mastered',
      'guaranteed',
      'every spot',
      'public',
      'launch',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}

List<dynamic> _activeRouteSpecsV1() => <dynamic>[
  ...const Act0W7VisibleAceHiddenRuntimeSessionOwnerV1().taskSpecs,
  ...const Act0W8StackDepthHiddenRuntimeSessionOwnerV1().taskSpecs,
  ...const Act0W9TournamentPressureHiddenRuntimeSessionOwnerV1().taskSpecs,
  ...const Act0W10BetPurposeHiddenRuntimeSessionOwnerV1().taskSpecs,
  ...const Act0W11BoardTextureHiddenRuntimeSessionOwnerV1().taskSpecs,
  ...const Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1().taskSpecs,
];

Act0TableStateV1 _activeRouteTableForSpecV1(dynamic spec) {
  return Act0TableStateV1(
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: const <Act0SeatStateV1>[
      Act0SeatStateV1(seatId: 'utg', seatLabel: 'UTG', displayName: 'UTG'),
      Act0SeatStateV1(seatId: 'hj', seatLabel: 'HJ', displayName: 'Hijack'),
      Act0SeatStateV1(seatId: 'co', seatLabel: 'CO', displayName: 'Cutoff'),
      Act0SeatStateV1(
        seatId: 'btn',
        seatLabel: 'BTN',
        displayName: 'Button',
        isHero: true,
        isDealerButton: true,
        isActive: true,
        cardsVisibleMode: Act0CardsVisibleModeV1.faceUp,
        holeCards: <Act0CardStateV1>[
          Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
          Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
        ],
      ),
      Act0SeatStateV1(
        seatId: 'sb',
        seatLabel: 'SB',
        displayName: 'Small blind',
        isSmallBlind: true,
        blindAmountLabel: '0.5 BB',
      ),
      Act0SeatStateV1(
        seatId: 'bb',
        seatLabel: 'BB',
        displayName: 'Big blind',
        isBigBlind: true,
        blindAmountLabel: '1 BB',
      ),
    ],
    heroCards: const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'A', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: 'Q', suit: 'h', tone: Act0CardToneV1.red),
    ],
    boardCards: _boardCardsForWorldV1(spec.worldId as String),
    streetLabel: 'Flop',
    potLabel: spec.worldId == 'world_9' ? 'Pot 18 BB' : 'Pot 12 BB',
    toCallLabel: spec.worldId == 'world_9' ? 'Call 3 BB' : '',
    centerLabel: spec.boardContext as String,
    focusCalloutLabel: spec.learningPurpose as String,
    actionTrail: <Act0ActionTrailItemV1>[
      Act0ActionTrailItemV1(label: spec.learningPurpose as String),
    ],
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: const <String>['btn'],
    highlightedCardIds: const <String>['board_0', 'board_1'],
  );
}

List<Act0CardStateV1> _boardCardsForWorldV1(String worldId) {
  return switch (worldId) {
    'world_8' => const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '8', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '3', suit: 'c'),
    ],
    'world_9' => const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'J', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '9', suit: 'c'),
      Act0CardStateV1(rank: '4', suit: 'd', tone: Act0CardToneV1.red),
    ],
    'world_10' => const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: '8', suit: 'd', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '2', suit: 'c'),
    ],
    'world_11' => const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'T', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '9', suit: 'h', tone: Act0CardToneV1.red),
      Act0CardStateV1(rank: '8', suit: 'c'),
    ],
    _ => const <Act0CardStateV1>[
      Act0CardStateV1(rank: 'K', suit: 's'),
      Act0CardStateV1(rank: 'Q', suit: 's'),
      Act0CardStateV1(rank: 'T', suit: 's'),
    ],
  };
}
