import 'dart:convert' show jsonEncode;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/engine_v2/model/money_state_v1.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/widgets/playing_card_widget.dart';

class _OverrideInstructionSourceV1 implements RunnerInstructionSourceV1 {
  const _OverrideInstructionSourceV1();

  @override
  RunnerInstructionContentV1? getIntroInstruction({
    required String moduleId,
    required String moduleTitle,
    required int railIndex,
    required int railTotal,
    required RunnerInstructionContentV1 fallback,
  }) {
    return const RunnerInstructionContentV1(
      title: 'OVR_INTRO_V1',
      subtitle: 'OVR_INTRO_SUB_V1',
    );
  }

  @override
  RunnerInstructionContentV1? getOutcomeInstruction({
    required String moduleId,
    required bool handLoopMode,
    required bool isCorrect,
    required RunnerInstructionContentV1 fallback,
  }) {
    return const RunnerInstructionContentV1(title: 'OVR_OUTCOME_V1');
  }

  @override
  RunnerInstructionContentV1? getStepInstruction({
    required String moduleId,
    required bool handLoopMode,
    required RunnerInstructionContentV1 fallback,
  }) {
    return const RunnerInstructionContentV1(
      title: 'OVR_STEP_V1',
      subtitle: 'OVR_STEP_SUB_V1',
    );
  }
}

class _LongCompactPromptInstructionSourceV1
    implements RunnerInstructionSourceV1 {
  const _LongCompactPromptInstructionSourceV1();

  static const String stepTitle =
      'From Button, read the open and choose the best action before you tap a chip.';

  @override
  RunnerInstructionContentV1? getIntroInstruction({
    required String moduleId,
    required String moduleTitle,
    required int railIndex,
    required int railTotal,
    required RunnerInstructionContentV1 fallback,
  }) => null;

  @override
  RunnerInstructionContentV1? getOutcomeInstruction({
    required String moduleId,
    required bool handLoopMode,
    required bool isCorrect,
    required RunnerInstructionContentV1 fallback,
  }) => null;

  @override
  RunnerInstructionContentV1? getStepInstruction({
    required String moduleId,
    required bool handLoopMode,
    required RunnerInstructionContentV1 fallback,
  }) => const RunnerInstructionContentV1(title: stepTitle);
}

class _SeatQuickRowV1 {
  const _SeatQuickRowV1({
    required this.seatId,
    required this.state,
    required this.committed,
  });

  final String seatId;
  final String state;
  final int committed;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDisableRunnerMicroAnimationsV1 = true;
    debugDisableRunnerSessionStartEmotionHooksV1 = true;
  });

  tearDown(() {
    debugDisableRunnerMicroAnimationsV1 = false;
    debugDisableRunnerSessionStartEmotionHooksV1 = false;
  });

  test('world1 spine why v2 maps bet with toCall>0 deterministically', () {
    final why = world1SpineOutcomeWhyLineV2(
      toCall: 4,
      selectedActionKind: ActionKindV1.bet,
      errorType: 'logic',
      street: MicroTaskStreetV1.turn,
      allowedActions: const <String>['fold', 'call', 'raise_to'],
    );
    expect(why, 'Why: There is a bet to call. You must call, fold, or raise.');
  });

  test(
    'act0 seat-quiz fallback guidance title is purposeful and deterministic',
    () {
      expect(
        kAct0SeatQuizFallbackGuidanceTitleV1,
        'Seat drill: identify the highlighted position.',
      );
      expect(
        kAct0SeatQuizFallbackGuidanceTitleV1,
        isNot('Tap the highlighted seat.'),
      );
    },
  );

  test('world1 spine why v2 maps fold with toCall==0 deterministically', () {
    final why = world1SpineOutcomeWhyLineV2(
      toCall: 0,
      selectedActionKind: ActionKindV1.fold,
      errorType: 'range',
      street: MicroTaskStreetV1.flop,
      allowedActions: const <String>['check', 'bet'],
    );
    expect(why, 'Why: Folding for free gives up equity.');
  });

  test('world1 spine why v2 maps unavailable raise deterministically', () {
    final why = world1SpineOutcomeWhyLineV2(
      toCall: 6,
      selectedActionKind: ActionKindV1.raise,
      errorType: 'logic',
      street: MicroTaskStreetV1.turn,
      allowedActions: const <String>['fold', 'call'],
    );
    expect(why, 'Why: This raise is not available in this spot.');
  });

  test(
    'world1 spine why v3 maps range fold with toCall>0 deterministically',
    () {
      final why = world1SpineOutcomeWhyLineV2(
        toCall: 4,
        selectedActionKind: ActionKindV1.fold,
        errorType: 'range',
        street: MicroTaskStreetV1.turn,
        allowedActions: const <String>['fold', 'call', 'raise_to'],
      );
      expect(why, 'Why: Folding gives up your equity share.');
    },
  );

  test(
    'world1 spine why v3 maps range check with toCall==0 and bet available',
    () {
      final why = world1SpineOutcomeWhyLineV2(
        toCall: 0,
        selectedActionKind: ActionKindV1.check,
        errorType: 'range',
        street: MicroTaskStreetV1.flop,
        allowedActions: const <String>['check', 'bet'],
      );
      expect(why, 'Why: Betting is the higher-EV play here.');
    },
  );

  test(
    'world1 spine why v3 maps range call with raise_to available deterministically',
    () {
      final why = world1SpineOutcomeWhyLineV2(
        toCall: 6,
        selectedActionKind: ActionKindV1.call,
        errorType: 'range',
        street: MicroTaskStreetV1.turn,
        allowedActions: const <String>['fold', 'call', 'raise_to'],
      );
      expect(why, 'Why: This spot rewards aggression more than calling.');
    },
  );

  test(
    'world1 spine facing-bet why line stays in call-or-raise family when expected check source is illegal',
    () {
      final why = world1SpineOutcomeWhyLineV2(
        toCall: 8,
        selectedActionKind: ActionKindV1.call,
        errorType: 'range',
        street: MicroTaskStreetV1.river,
        allowedActions: const <String>['fold', 'call', 'raise_to'],
      );
      expect(why, 'Why: This spot rewards aggression more than calling.');
      expect(why, isNot(contains('Check is free')));
      expect(why, isNot(contains('There is nothing to call')));
    },
  );

  test(
    'world1 spine why fallback uses recommended-play wording without solver/optimal',
    () {
      final why = world1SpineOutcomeWhyLineV2(
        toCall: 2,
        selectedActionKind: null,
        errorType: 'logic',
        street: MicroTaskStreetV1.turn,
        allowedActions: const <String>[],
      );
      expect(why, contains('recommended play'));
      expect(why.toLowerCase(), isNot(contains('optimal')));
      expect(why.toLowerCase(), isNot(contains('solver')));
    },
  );

  test('world1 spine correct line maps check with toCall==0', () {
    final line = world1SpineOutcomeCorrectLineV1(
      toCall: 0,
      selectedActionKind: ActionKindV1.check,
      street: MicroTaskStreetV1.flop,
    );
    expect(line, 'Correct: Check is free.');
  });

  test('world1 spine correct line maps call with toCall>0', () {
    final line = world1SpineOutcomeCorrectLineV1(
      toCall: 6,
      selectedActionKind: ActionKindV1.call,
      street: MicroTaskStreetV1.river,
    );
    expect(line, 'Correct: Call matches the bet.');
  });

  test(
    'world1 spine preferred raise label resolves deterministically from allowed actions',
    () {
      expect(
        world1SpinePreferredRaiseLabelV1(const <String>[
          'fold',
          'call',
          'raise_to',
        ]),
        'RAISE TO',
      );
      expect(
        world1SpinePreferredRaiseLabelV1(const <String>[
          'fold',
          'call',
          'raise_min',
        ]),
        'RAISE MIN',
      );
      expect(
        world1SpinePreferredRaiseLabelV1(const <String>['raise']),
        'RAISE',
      );
      expect(world1SpinePreferredRaiseLabelV1(const <String>[]), 'RAISE');
    },
  );

  test(
    'world1 spine correct line aligns raise wording with available affordance',
    () {
      final raiseTo = world1SpineOutcomeCorrectLineV1(
        toCall: 8,
        selectedActionKind: ActionKindV1.raise,
        street: MicroTaskStreetV1.turn,
        allowedActions: const <String>['fold', 'call', 'raise_to'],
      );
      final raiseMin = world1SpineOutcomeCorrectLineV1(
        toCall: 8,
        selectedActionKind: ActionKindV1.raise,
        street: MicroTaskStreetV1.turn,
        allowedActions: const <String>['fold', 'call', 'raise_min'],
      );
      expect(raiseTo, 'Correct: RAISE TO applies pressure.');
      expect(raiseMin, 'Correct: RAISE MIN applies pressure.');
    },
  );

  test('world1 spine expected action resolver is deterministic per step', () {
    final raiseStep = MicroTaskStep(
      prompt: 'River spot',
      hint: 'Use legal actions only.',
      expectedSeatIds: const <String>['co'],
      toCall: 6,
      allowedActions: const <String>['fold', 'call', 'raise_to'],
    );
    final betStep = MicroTaskStep(
      prompt: 'Preflop big blind spot',
      hint: 'Use legal actions only.',
      expectedSeatIds: const <String>['bb'],
      toCall: 0,
      allowedActions: const <String>['check', 'raise'],
      expectedActionKind: 'bet',
    );
    final explicitOverrideStep = MicroTaskStep(
      prompt: 'River explicit call',
      hint: 'Use legal actions only.',
      expectedSeatIds: const <String>['co'],
      toCall: 6,
      allowedActions: const <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'call',
    );
    final illegalFacingBetExpectedCheck = MicroTaskStep(
      prompt: 'Facing bet but expected check in source',
      hint: 'Use legal actions only.',
      expectedSeatIds: const <String>['co'],
      toCall: 6,
      allowedActions: const <String>['fold', 'call', 'raise_to'],
      expectedActionKind: 'check',
    );
    expect(world1SpineExpectedActionKindV1(raiseStep), ActionKindV1.raise);
    expect(world1SpineExpectedActionKindV1(betStep), ActionKindV1.raise);
    expect(
      world1SpineExpectedActionKindV1(explicitOverrideStep),
      ActionKindV1.call,
    );
    expect(
      world1SpineExpectedActionKindV1(illegalFacingBetExpectedCheck),
      ActionKindV1.raise,
    );
  });

  test(
    'world1 spine mismatch expected action normalizes facing-bet explicit check in authoritative mismatch branch',
    () {
      const step = MicroTaskStep(
        prompt: 'Facing bet mismatch branch normalization',
        hint: 'Use legal actions only.',
        expectedSeatIds: <String>['co'],
        toCall: 8,
        allowedActions: <String>['fold', 'call', 'raise_to'],
        expectedActionKind: 'check',
      );
      const firstHeroActionOverride = ActionV1(
        actorId: PlayerIdV1('hero'),
        kind: ActionKindV1.fold,
      );
      final expectedKind = world1SpineMismatchExpectedActionKindV1(
        step: step,
        useSpineExplicitExpectedAction: true,
        firstHeroActionOverride: firstHeroActionOverride,
        heroActions: const <ActionV1>[
          ActionV1(actorId: PlayerIdV1('hero'), kind: ActionKindV1.raise),
        ],
      );
      expect(expectedKind, ActionKindV1.raise);
    },
  );

  test(
    'world1 spine expected line normalizes raise label to visible affordance deterministically',
    () {
      final raiseToStep = MicroTaskStep(
        prompt: 'Facing bet in cutoff.',
        hint: 'Use legal actions only.',
        expectedSeatIds: const <String>['co'],
        toCall: 8,
        allowedActions: const <String>['fold', 'call', 'raise_to'],
        expectedActionKind: 'raise',
      );
      final raiseMinStep = MicroTaskStep(
        prompt: 'Short-stack reraising spot.',
        hint: 'Use legal actions only.',
        expectedSeatIds: const <String>['bb'],
        toCall: 6,
        allowedActions: const <String>['fold', 'call', 'raise_min'],
      );
      expect(
        world1SpineOutcomeExpectedLineV1(raiseToStep),
        'Expected: RAISE TO',
      );
      expect(
        world1SpineOutcomeExpectedLineV1(raiseMinStep),
        'Expected: RAISE MIN',
      );
      expect(
        world1SpineOutcomeExpectedLineV1(
          const MicroTaskStep(
            prompt: 'Preflop big blind',
            hint: 'Use legal actions only.',
            expectedSeatIds: <String>['bb'],
            toCall: 0,
            allowedActions: <String>['check', 'raise'],
            expectedActionKind: 'bet',
          ),
        ),
        'Expected: RAISE',
      );
    },
  );

  test(
    'world1 spine facing-bet explicit check cannot render Expected: CHECK',
    () {
      final illegalFacingBetExpectedCheck = MicroTaskStep(
        prompt: 'Facing bet but expected check in source',
        hint: 'Use legal actions only.',
        expectedSeatIds: const <String>['co'],
        toCall: 8,
        allowedActions: const <String>['fold', 'call', 'raise_to'],
        expectedActionKind: 'check',
      );
      expect(
        world1SpineOutcomeExpectedLineV1(illegalFacingBetExpectedCheck),
        'Expected: RAISE TO',
      );
    },
  );

  test(
    'world1 spine contract marks CALL as incorrect when expected is raise',
    () {
      final step = MicroTaskStep(
        prompt: 'River pressure spot',
        hint: 'Use legal actions only.',
        expectedSeatIds: const <String>['co'],
        toCall: 8,
        allowedActions: const <String>['fold', 'call', 'raise_to'],
      );
      expect(
        world1SpineIsExpectedActionV1(
          step: step,
          selectedActionKind: ActionKindV1.call,
        ),
        isFalse,
      );
    },
  );

  test(
    'world1 spine contract canonicalizes preflop zero-price bet into raise family',
    () {
      final step = MicroTaskStep(
        prompt: 'Preflop free action spot',
        hint: 'Use legal actions only.',
        expectedSeatIds: const <String>['bb'],
        toCall: 0,
        allowedActions: const <String>['check', 'raise'],
      );
      expect(
        world1SpineIsExpectedActionV1(
          step: step,
          selectedActionKind: ActionKindV1.bet,
        ),
        isTrue,
      );
      expect(
        world1SpineOutcomeCorrectLineV1(
          toCall: 0,
          selectedActionKind: ActionKindV1.bet,
          street: null,
          allowedActions: const <String>['check', 'raise'],
        ),
        'Correct: Raise is the price-setting action preflop.',
      );
    },
  );

  test(
    'active world1 preflop zero-price steps use raise semantics instead of bet',
    () {
      const activePackIds = <String>[
        'world1_spine_campaign_v1',
        'world1_spine_followup_v1_b0',
        'world1_spine_followup_v1_b1',
        'world1_spine_followup_v1_b2',
      ];
      for (final packId in activePackIds) {
        final pack = kCampaignPacksV1[packId];
        expect(pack, isNotNull, reason: 'Missing active pack $packId');
        for (final step in pack!) {
          final isZeroPricePreflop =
              step.street == null && (step.toCall ?? 0) == 0;
          if (!isZeroPricePreflop) {
            continue;
          }
          final allowed = (step.allowedActions ?? const <String>[])
              .map((value) => value.trim().toLowerCase().replaceAll('-', '_'))
              .toSet();
          expect(
            allowed.contains('bet'),
            isFalse,
            reason: 'pack=$packId raw bet leaked into preflop zero-price step',
          );
          expect(
            world1SpineExpectedActionKindV1(step),
            ActionKindV1.raise,
            reason:
                'pack=$packId preflop zero-price step must resolve to raise family',
          );
          expect(
            world1SpineOutcomeExpectedLineV1(step),
            'Expected: RAISE',
            reason:
                'pack=$packId preflop zero-price step must surface raise copy',
          );
          final joinedCopy = <String>[
            step.prompt,
            step.hint,
            if (step.insightText != null) step.insightText!,
          ].join(' ').toLowerCase();
          expect(
            joinedCopy.contains('check or bet'),
            isFalse,
            reason:
                'pack=$packId preflop zero-price step still teaches check-or-bet',
          );
        }
      }
    },
  );

  Future<void> _pumpAtSize(
    WidgetTester tester,
    Size size, {
    required Widget child,
  }) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pump();
  }

  Future<void> _pumpUntil(
    WidgetTester tester,
    Finder finder, {
    int maxTicks = 120,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(step);
    }
  }

  Future<void> _tapFirstEnabledCampaignAction(WidgetTester tester) async {
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    expect(actionBar, findsOneWidget);
    final actionButtons = find.descendant(
      of: actionBar,
      matching: find.byType(OutlinedButton),
    );
    for (final buttonElement in actionButtons.evaluate()) {
      final button = buttonElement.widget as OutlinedButton;
      if (button.onPressed != null) {
        await tester.tap(find.byWidget(button), warnIfMissed: false);
        await tester.pump();
        return;
      }
    }
    fail('No enabled campaign action chip found.');
  }

  Future<void> _openRunnerDetailsSheetV1(WidgetTester tester) async {
    final detailsHeader = find.byKey(const Key('details_debug_header_v1'));

    Future<bool> tapAndWait(Finder trigger) async {
      if (trigger.evaluate().isEmpty) return false;
      await tester.tap(trigger.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await _pumpUntil(tester, detailsHeader, maxTicks: 120);
      return detailsHeader.evaluate().isNotEmpty;
    }

    await _pumpUntil(
      tester,
      find.byIcon(Icons.info_outline_rounded),
      maxTicks: 240,
    );
    final opened =
        await tapAndWait(find.byIcon(Icons.info_outline_rounded)) ||
        await tapAndWait(find.widgetWithText(TextButton, 'Details')) ||
        await tapAndWait(find.text('Details'));
    expect(opened, isTrue, reason: 'Unable to open runner details sheet.');
  }

  Future<void> _closeRunnerDetailsSheetV1(WidgetTester tester) async {
    final closeIcon = find.byIcon(Icons.close_rounded);
    expect(closeIcon, findsAtLeastNWidgets(1));
    await tester.tap(closeIcon.first, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  String _detailsLineTextByKeyV1(WidgetTester tester, String key) {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget);
    return (tester.widget<Text>(finder).data ?? '').trim();
  }

  int _intFromDetailsLineV1(String line, String prefix) {
    expect(line.startsWith(prefix), isTrue, reason: 'line="$line"');
    final raw = line.substring(prefix.length).trim();
    return int.parse(raw);
  }

  int? _nullableIntFromDetailsLineV1(String line, String prefix) {
    expect(line.startsWith(prefix), isTrue, reason: 'line="$line"');
    final raw = line.substring(prefix.length).trim();
    if (raw == 'n/a' || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  List<_SeatQuickRowV1> _parseSeatQuickRowsV1(String line) {
    const prefix = 'seats: ';
    expect(line.startsWith(prefix), isTrue, reason: 'line="$line"');
    final payload = line.substring(prefix.length).trim();
    if (payload.isEmpty) return const <_SeatQuickRowV1>[];
    return payload
        .split('|')
        .map((chunk) => chunk.trim())
        .where((chunk) => chunk.isNotEmpty)
        .map((chunk) {
          final match = RegExp(
            r'^([a-z0-9_]+):(in|folded|out)/c(-?\d+)$',
          ).firstMatch(chunk);
          expect(match, isNotNull, reason: 'chunk="$chunk"');
          return _SeatQuickRowV1(
            seatId: match!.group(1)!,
            state: match.group(2)!,
            committed: int.parse(match.group(3)!),
          );
        })
        .toList(growable: false);
  }

  Future<void> _tapExpectedCampaignActionForPackV1(
    WidgetTester tester, {
    required String packId,
  }) async {
    final stepIndexTextFinder = find.byKey(
      const Key('spine_contract_hand_index'),
      skipOffstage: false,
    );
    await _pumpUntil(tester, stepIndexTextFinder, maxTicks: 240);
    final handIndexLabel =
        tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
    final handIndexMatch = RegExp(r'^i=(\d+)$').firstMatch(handIndexLabel);
    final handIndex = int.tryParse(handIndexMatch?.group(1) ?? '');
    expect(handIndex, isNotNull);

    final pack = kCampaignPacksV1[packId];
    expect(pack, isNotNull, reason: 'Missing pack=$packId');
    final step = pack12(pack!)[handIndex!];
    final expectedKind = world1SpineExpectedActionKindV1(step);
    expect(expectedKind, isNotNull, reason: 'Missing expected action for step');

    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    await _pumpUntil(tester, actionBar, maxTicks: 240);
    Finder actionFinder;
    switch (expectedKind!) {
      case ActionKindV1.fold:
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.text('FOLD'),
        );
      case ActionKindV1.check:
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.text('CHECK'),
        );
      case ActionKindV1.call:
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.text('CALL'),
        );
      case ActionKindV1.bet:
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.data != null &&
                (widget.data!.startsWith('BET') ||
                    widget.data!.startsWith('RAISE')),
          ),
        );
      case ActionKindV1.raise:
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.data != null &&
                widget.data!.startsWith('RAISE'),
          ),
        );
    }
    await _pumpUntil(tester, actionFinder, maxTicks: 240);
    final visibleActionLabels = find
        .descendant(of: actionBar, matching: find.byType(Text))
        .evaluate()
        .map((element) => element.widget)
        .whereType<Text>()
        .map((text) => (text.data ?? '').trim())
        .where((text) => text.isNotEmpty)
        .toList(growable: false);
    expect(
      actionFinder.evaluate().isNotEmpty,
      isTrue,
      reason:
          'No matching expected action chip found for pack=$packId index=$handIndex expected=$expectedKind toCall=${step.toCall} allowed=${step.allowedActions} visible=$visibleActionLabels',
    );
    await tester.tap(actionFinder.first, warnIfMissed: false);
    await tester.pump();
  }

  ActionKindV1? _actionKindFromAllowedTokenV1(String token) {
    switch (token.trim().toLowerCase()) {
      case 'fold':
        return ActionKindV1.fold;
      case 'check':
        return ActionKindV1.check;
      case 'call':
        return ActionKindV1.call;
      case 'bet':
        return ActionKindV1.bet;
      case 'raise':
      case 'raise_to':
      case 'raise_min':
        return ActionKindV1.raise;
      default:
        return null;
    }
  }

  int _firstActionableStepIndexForPackV1(
    String packId, {
    bool requireAlternativeAction = false,
  }) {
    final pack = kCampaignPacksV1[packId];
    expect(pack, isNotNull, reason: 'Missing pack=$packId');
    final steps = pack12(pack!);
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final actions = (step.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      final expectedKind = world1SpineExpectedActionKindV1(step);
      if (expectedKind == null || actions.isEmpty) {
        continue;
      }
      if (!requireAlternativeAction) {
        return i;
      }
      final hasAlternative = actions.any(
        (token) => _actionKindFromAllowedTokenV1(token) != expectedKind,
      );
      if (hasAlternative) {
        return i;
      }
    }
    fail('No actionable step found for pack=$packId');
  }

  int _firstActionableFollowupStepIndexV1(
    String packId, {
    bool requireAlternativeAction = false,
  }) {
    return _firstActionableStepIndexForPackV1(
      packId,
      requireAlternativeAction: requireAlternativeAction,
    );
  }

  String _firstNonExpectedActionTokenV1(MicroTaskStep step) {
    final expectedKind = world1SpineExpectedActionKindV1(step);
    final actions = (step.allowedActions ?? const <String>[])
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    for (final token in actions) {
      if (_actionKindFromAllowedTokenV1(token) != expectedKind) {
        return token;
      }
    }
    fail('No alternative action token found for deterministic incorrect test');
  }

  Future<void> _tapCampaignActionTokenV1(
    WidgetTester tester, {
    required String actionToken,
  }) async {
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    await _pumpUntil(tester, actionBar, maxTicks: 240);
    final normalized = actionToken.trim().toLowerCase();
    Finder actionFinder;
    switch (normalized) {
      case 'fold':
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.text('FOLD'),
        );
      case 'check':
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.text('CHECK'),
        );
      case 'call':
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.text('CALL'),
        );
      case 'bet':
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.data != null &&
                widget.data!.startsWith('BET'),
          ),
        );
      case 'raise':
      case 'raise_to':
      case 'raise_min':
        actionFinder = find.descendant(
          of: actionBar,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                widget.data != null &&
                widget.data!.startsWith('RAISE'),
          ),
        );
      default:
        fail('Unsupported action token for tap: $actionToken');
    }
    await _pumpUntil(tester, actionFinder, maxTicks: 240);
    await tester.tap(actionFinder.first, warnIfMissed: false);
    await tester.pump();
  }

  Future<void> _advanceToCampaignActionBarV1(WidgetTester tester) async {
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    final seatFallbacks = <Finder>[
      find.byKey(const Key('microtask_seat_btn')),
      find.byKey(const Key('microtask_seat_sb')),
      find.byKey(const Key('microtask_seat_bb')),
      find.byKey(const Key('microtask_seat_utg')),
      find.byKey(const Key('microtask_seat_hj')),
      find.byKey(const Key('microtask_seat_co')),
    ];

    Future<bool> tapIfEnabled(Key key) async {
      final finder = find.byKey(key);
      if (finder.evaluate().isEmpty) return false;
      final target = finder.first;
      final widget = tester.widget<Widget>(target);
      final enabled = switch (widget) {
        ElevatedButton button => button.onPressed != null,
        FilledButton button => button.onPressed != null,
        OutlinedButton button => button.onPressed != null,
        TextButton button => button.onPressed != null,
        _ => true,
      };
      if (!enabled) return false;
      await tester.tap(target, warnIfMissed: false);
      await tester.pump();
      return true;
    }

    Finder? seatFromPrompt() {
      final promptFinder = find.byKey(const Key('microtask_step_prompt'));
      if (promptFinder.evaluate().isEmpty) return null;
      final widget = tester.widget<Widget>(promptFinder.first);
      if (widget is! Text) return null;
      final text = (widget.data ?? '').toLowerCase();
      if (text.contains('button'))
        return find.byKey(const Key('microtask_seat_btn'));
      if (text.contains('small blind'))
        return find.byKey(const Key('microtask_seat_sb'));
      if (text.contains('big blind'))
        return find.byKey(const Key('microtask_seat_bb'));
      if (text.contains('hijack'))
        return find.byKey(const Key('microtask_seat_hj'));
      if (text.contains('cutoff') || text.contains('cut off')) {
        return find.byKey(const Key('microtask_seat_co'));
      }
      if (text.contains('utg'))
        return find.byKey(const Key('microtask_seat_utg'));
      return null;
    }

    for (var i = 0; i < 260; i++) {
      if (actionBar.evaluate().isNotEmpty) {
        return;
      }
      if (await tapIfEnabled(const Key('microtask_prelude_continue_cta_v1'))) {
        continue;
      }
      if (await tapIfEnabled(const Key('microtask_intro_continue_cta_v1'))) {
        continue;
      }
      if (await tapIfEnabled(const Key('microtask_continue_cta'))) {
        continue;
      }
      final seatFinder =
          seatFromPrompt() ?? seatFallbacks[i % seatFallbacks.length];
      if (seatFinder.evaluate().isNotEmpty) {
        await tester.tap(seatFinder, warnIfMissed: false);
        await tester.pump();
      }
      await tapIfEnabled(const Key('microtask_check_cta'));
      await tester.pump(const Duration(milliseconds: 60));
    }
    fail('Unable to reach campaign action bar deterministically.');
  }

  Finder? _seatFinderFromPromptV1(WidgetTester tester) {
    Finder? modernSeatFinderForRole(String label) {
      for (var i = 0; i < 9; i++) {
        final roleFinder = find.byKey(Key('modern_table_seat_role_$i'));
        if (roleFinder.evaluate().isEmpty) continue;
        final matchingRoleText = find.descendant(
          of: roleFinder,
          matching: find.textContaining(label),
        );
        if (matchingRoleText.evaluate().isNotEmpty) {
          return find.byKey(Key('modern_table_seat_$i'));
        }
      }
      return null;
    }

    final promptFinder = find.byKey(const Key('microtask_step_prompt'));
    if (promptFinder.evaluate().isEmpty) return null;
    final widget = tester.widget<Widget>(promptFinder);
    if (widget is! Text) return null;
    final text = (widget.data ?? '').toLowerCase();
    if (text.contains('button')) {
      final legacyFinder = find.byKey(const Key('microtask_seat_btn'));
      return legacyFinder.evaluate().isNotEmpty
          ? legacyFinder
          : modernSeatFinderForRole('BTN');
    }
    if (text.contains('small blind')) {
      final legacyFinder = find.byKey(const Key('microtask_seat_sb'));
      return legacyFinder.evaluate().isNotEmpty
          ? legacyFinder
          : modernSeatFinderForRole('SB');
    }
    if (text.contains('big blind')) {
      final legacyFinder = find.byKey(const Key('microtask_seat_bb'));
      return legacyFinder.evaluate().isNotEmpty
          ? legacyFinder
          : modernSeatFinderForRole('BB');
    }
    if (text.contains('hijack')) {
      final legacyFinder = find.byKey(const Key('microtask_seat_hj'));
      return legacyFinder.evaluate().isNotEmpty
          ? legacyFinder
          : modernSeatFinderForRole('HJ');
    }
    if (text.contains('cutoff') || text.contains('cut off')) {
      final legacyFinder = find.byKey(const Key('microtask_seat_co'));
      return legacyFinder.evaluate().isNotEmpty
          ? legacyFinder
          : modernSeatFinderForRole('CO');
    }
    if (text.contains('utg')) {
      final legacyFinder = find.byKey(const Key('microtask_seat_utg'));
      return legacyFinder.evaluate().isNotEmpty
          ? legacyFinder
          : modernSeatFinderForRole('UTG');
    }
    return null;
  }

  Future<bool> _tapIfEnabledButtonByKeyV1(WidgetTester tester, Key key) async {
    final finder = find.byKey(key);
    if (finder.evaluate().isEmpty) return false;
    final widget = tester.widget<Widget>(finder);
    final enabled = switch (widget) {
      ElevatedButton button => button.onPressed != null,
      FilledButton button => button.onPressed != null,
      OutlinedButton button => button.onPressed != null,
      TextButton button => button.onPressed != null,
      _ => true,
    };
    if (!enabled) return false;
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump();
    return true;
  }

  Future<void> _completeIntroSequenceV1(WidgetTester tester) async {
    final introSequenceFinder = find.byKey(
      const Key('microtask_intro_sequence_v1'),
    );
    await tester.pump();
    if (introSequenceFinder.evaluate().isEmpty) {
      return;
    }
    await _pumpUntil(tester, introSequenceFinder, maxTicks: 240);
    final introContinueFinder = find.byKey(
      const Key('microtask_intro_continue_cta_v1'),
    );

    Future<bool> tryContinueIfEnabled() async {
      if (introContinueFinder.evaluate().isEmpty) return false;
      final continueButton = tester.widget<FilledButton>(introContinueFinder);
      if (continueButton.onPressed == null) return false;
      await tester.tap(introContinueFinder, warnIfMissed: false);
      await tester.pump();
      return true;
    }

    if (await tryContinueIfEnabled()) {
      if (find
          .byKey(const Key('microtask_intro_sequence_v1'))
          .evaluate()
          .isEmpty) {
        return;
      }
    }

    Future<void> completeTapStep({required String seatId}) async {
      await tester.tap(
        find.byKey(Key('microtask_seat_$seatId')),
        warnIfMissed: false,
      );
      await tester.pump();
      final continueButton = tester.widget<FilledButton>(introContinueFinder);
      expect(continueButton.onPressed, isNotNull);
      await tester.tap(introContinueFinder, warnIfMissed: false);
      await tester.pump();
    }

    await completeTapStep(seatId: 'btn');
    await completeTapStep(seatId: 'sb');
    await completeTapStep(seatId: 'bb');
  }

  testWidgets('microtask runner builds in narrow and wide layouts', (
    tester,
  ) async {
    await _pumpAtSize(
      tester,
      const Size(390, 844),
      child: const World1FoundationsMicroTaskRunnerScreen(
        moduleId: 'intro_welcome',
        moduleTitle: 'Welcome to Poker',
      ),
    );
    expect(find.byKey(const Key('microtask_runner')), findsOneWidget);
    expect(find.byKey(const Key('microtask_step_header')), findsOneWidget);
    expect(find.byKey(const Key('microtask_progress')), findsOneWidget);
    expect(find.byKey(const Key('microtask_table')), findsOneWidget);
    expect(find.byKey(const Key('microtask_check_cta')), findsOneWidget);
    expect(find.text('0.5'), findsWidgets);
    expect(tester.takeException(), isNull);

    await _pumpAtSize(
      tester,
      const Size(1280, 800),
      child: const World1FoundationsMicroTaskRunnerScreen(
        moduleId: 'intro_welcome',
        moduleTitle: 'Welcome to Poker',
      ),
    );
    expect(find.byKey(const Key('microtask_runner')), findsOneWidget);
    expect(find.byKey(const Key('microtask_table')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('campaign pack registry wiring loads all campaign packs', () {
    expect(kCampaignPackIdsV1, isNotEmpty);

    for (final packId in kCampaignPackIdsV1) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'Missing campaign pack: $packId');
      expect(pack, isNotEmpty, reason: 'Empty campaign pack: $packId');

      for (var i = 0; i < pack!.length; i++) {
        final step = pack[i];
        expect(
          step.prompt.trim(),
          isNotEmpty,
          reason: 'Empty prompt in $packId step $i',
        );
        expect(
          step.hint.trim(),
          isNotEmpty,
          reason: 'Empty hint in $packId step $i',
        );
        expect(
          step.expectedSeatIds,
          isNotEmpty,
          reason: 'Empty expectedSeatIds in $packId step $i',
        );
        expect(
          step.expectedSeatIds.where((id) => id.trim().isNotEmpty),
          hasLength(step.expectedSeatIds.length),
          reason: 'Blank expectedSeatId in $packId step $i',
        );
      }
    }
  });

  test(
    'world1 first-entry intro prelude explains the training loop before seat taps',
    () {
      final contract = resolveWorld1FirstPackTransitionPacingContractV1(
        'world1_act0_table_literacy',
      );

      expect(contract, isNotNull);
      expect(contract!.usesBlockingIntroOverlay, isTrue);
      expect(
        contract.embeddedPreludeCardKey,
        'concept_first_seat_prelude_card_v1',
      );
    },
  );

  testWidgets(
    'world1 action-literacy skips blocking continuity intro and goes straight to the real host',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'global_training_intro_seen_v1': true,
        'world1_intro_seen_v1': true,
        'world1_action_intro_seen_v1': false,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_action_literacy',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final actionPrelude = find.byKey(
        const Key('microtask_world1_action_intro_prelude_v1'),
      );
      await tester.pump(const Duration(milliseconds: 240));
      expect(actionPrelude, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 hand-loop action branch uses canonical shell prompt ownership on the real host',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'global_training_intro_seen_v1': true,
        'world1_intro_seen_v1': true,
        'world1_action_intro_seen_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_action_literacy',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();
      await _advanceToCampaignActionBarV1(tester);

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final promptCapsule = find.byKey(
        const Key('microtask_runner_prompt_capsule_v1'),
      );
      final progressionStatus = find.byKey(
        const Key('microtask_runner_progression_status_v1'),
      );
      final liveBoardStateBand = find.byKey(
        const Key('microtask_live_scene_board_state_band_v1'),
      );
      final liveBoardStateText = find.byKey(
        const Key('microtask_live_scene_board_state_text_v1'),
      );
      final livePriceBadge = find.byKey(
        const Key('microtask_live_scene_price_badge_v1'),
      );
      final livePotBadge = find.byKey(
        const Key('microtask_live_scene_pot_badge_v1'),
      );
      final liveSceneInstruction = find.byKey(
        const Key('microtask_live_scene_instruction_v1'),
      );
      final embeddedScene = find.byKey(const Key('modern_table_scene'));
      final feltOval = find.byKey(const Key('modern_table_oval'));
      final tableHost = find.byKey(const Key('microtask_table'));
      final stepHeader = find.byKey(const Key('microtask_step_header'));
      final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
      final scenePrompt = find.byKey(const Key('modern_table_scene_prompt'));
      final sceneStateLane = find.byKey(
        const Key('modern_table_scene_state_lane'),
      );
      final forcedBetBadges = find.byWidgetPredicate(
        (widget) =>
            widget.key is Key &&
            (widget.key as Key).toString().contains(
              'modern_table_seat_forced_bet_',
            ),
      );
      final actingBadges = find.byWidgetPredicate(
        (widget) =>
            widget.key is Key &&
            (widget.key as Key).toString().contains(
              'modern_table_seat_action_marker_',
            ),
      );

      await _pumpUntil(tester, actionBar, maxTicks: 120);
      await _pumpUntil(tester, stepHeader, maxTicks: 120);
      await _pumpUntil(tester, liveBoardStateBand, maxTicks: 120);
      await _pumpUntil(tester, liveSceneInstruction, maxTicks: 120);

      expect(actionBar, findsOneWidget);
      expect(promptCapsule, findsNothing);
      expect(progressionStatus, findsOneWidget);
      expect(liveBoardStateBand, findsOneWidget);
      expect(liveBoardStateText, findsOneWidget);
      expect(livePriceBadge, findsOneWidget);
      expect(livePotBadge, findsOneWidget);
      expect(liveSceneInstruction, findsOneWidget);
      expect(embeddedScene, findsOneWidget);
      expect(feltOval, findsOneWidget);
      expect(tableHost, findsOneWidget);
      expect(stepHeader, findsOneWidget);
      expect(stepPrompt, findsNothing);
      expect(sceneStateLane, findsNothing);
      expect(scenePrompt, findsOneWidget);
      expect(forcedBetBadges, findsNothing);
      expect(actingBadges, findsNothing);

      final modernTable = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(
        modernTable.sceneLanePromptProfileV1,
        ModernTableSceneLanePromptProfileV1.standard,
      );

      final promptText = tester.widget<Text>(scenePrompt);
      expect((promptText.data ?? '').trim(), isNotEmpty);
      expect(promptText.maxLines, 5);
      expect(promptText.softWrap, isTrue);
      expect(promptText.overflow, TextOverflow.clip);

      final progressionStatusRect = tester.getRect(progressionStatus);
      final liveBoardStateBandRect = tester.getRect(liveBoardStateBand);
      final liveSceneInstructionRect = tester.getRect(liveSceneInstruction);
      final scenePromptRect = tester.getRect(scenePrompt);
      final embeddedSceneRect = tester.getRect(embeddedScene);
      final feltOvalRect = tester.getRect(feltOval);
      final tableHostRect = tester.getRect(tableHost);
      final actionBarRect = tester.getRect(actionBar);
      final viewportHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final topStackHeight = feltOvalRect.top - progressionStatusRect.top;
      final topStackShare = topStackHeight / viewportHeight;
      final feltShare = feltOvalRect.height / viewportHeight;
      final laneToInstructionGap =
          scenePromptRect.top - liveBoardStateBandRect.bottom;
      final instructionToFeltGap = feltOvalRect.top - scenePromptRect.bottom;
      final seatSurfaceFinders = find.byWidgetPredicate(
        (widget) =>
            widget.key is Key &&
            (widget.key as Key).toString().contains(
              'modern_table_seat_surface_',
            ),
      );
      final seatSurfaceRects = seatSurfaceFinders
          .evaluate()
          .map((element) => tester.getRect(find.byWidget(element.widget)))
          .toList(growable: false);
      final topSeatRect = seatSurfaceRects.reduce(
        (a, b) => a.top <= b.top ? a : b,
      );
      final markerRects = find
          .byWidgetPredicate(
            (widget) =>
                widget.key is Key &&
                (widget.key as Key).toString().contains(
                  'modern_table_seat_marker_',
                ),
          )
          .evaluate()
          .map((element) => tester.getRect(find.byWidget(element.widget)))
          .toList(growable: false);
      final heroRingFinder = find.byWidgetPredicate(
        (widget) =>
            widget.key is Key &&
            (widget.key as Key).toString().contains(
              'modern_table_seat_hero_ring_',
            ),
      );
      expect(
        liveBoardStateBandRect.bottom <= scenePromptRect.top,
        isTrue,
        reason:
            'Top band must remain lightweight context above the scene-owned instruction.',
      );
      expect(
        topStackShare <= 0.18,
        isTrue,
        reason:
            'Live top stack must stay materially reduced so the table remains the dominant vertical scene.',
      );
      expect(
        feltShare >= 0.60,
        isTrue,
        reason:
            'Live felt mass must recover a dominant share of the portrait viewport.',
      );
      expect(
        embeddedSceneRect.left - tableHostRect.left <= 8,
        isTrue,
        reason:
            'Live table scene should use near-screen-owned left gutter, not a nested boxed inset.',
      );
      expect(
        tableHostRect.right - embeddedSceneRect.right <= 8,
        isTrue,
        reason:
            'Live table scene should use near-screen-owned right gutter, not a nested boxed inset.',
      );
      expect(
        embeddedSceneRect.width / tableHostRect.width >= 0.95,
        isTrue,
        reason:
            'Embedded scene must remain the dominant scene mass on the live runner.',
      );
      expect(
        laneToInstructionGap >= -4 && laneToInstructionGap <= 180,
        isTrue,
        reason:
            'Scene instruction should sit just below the board-state context, not far away in a separate layer.',
      );
      expect(
        instructionToFeltGap >= -120 && instructionToFeltGap <= 120,
        isTrue,
        reason:
            'Primary instruction should sit inside the top scene region, above the felt.',
      );
      expect(
        topSeatRect.width <= 43.0,
        isTrue,
        reason:
            'Learner-embedded non-hero seat surface should stay visually slim.',
      );
      for (final markerRect in markerRects) {
        final nearestSeatRect = seatSurfaceRects.reduce(
          (a, b) =>
              (a.center - markerRect.center).distance <=
                  (b.center - markerRect.center).distance
              ? a
              : b,
        );
        expect(
          markerRect.center.dx >= nearestSeatRect.left - 6 &&
              markerRect.center.dx <= nearestSeatRect.right + 6,
          isTrue,
          reason:
              'Seat marker should stay horizontally attached to its nearest seat surface.',
        );
        expect(
          markerRect.center.dy >= nearestSeatRect.top - 8 &&
              markerRect.center.dy <= nearestSeatRect.bottom + 12,
          isTrue,
          reason:
              'Seat marker should stay vertically integrated with its nearest seat surface.',
        );
      }
      expect(heroRingFinder, findsOneWidget);
      final heroRing = tester.widget<Container>(heroRingFinder);
      final heroRingDecoration = heroRing.decoration! as BoxDecoration;
      expect(heroRingDecoration.border, isNotNull);
      expect(heroRingDecoration.border!.top.width <= 1.3, isTrue);
      expect(heroRingDecoration.boxShadow, isNotNull);
      expect(heroRingDecoration.boxShadow!.first.blurRadius <= 5.5, isTrue);
      final heroRingRect = tester.getRect(heroRingFinder);
      expect(
        actionBarRect.top - heroRingRect.bottom >= 36,
        isTrue,
        reason:
            'CTA footer safety must remain preserved after increasing felt dominance.',
      );
      expect(
        (actionBarRect.left - embeddedSceneRect.left).abs() <= 28,
        isTrue,
        reason:
            'Action bar should align to the same horizontal scene envelope as the table.',
      );
      expect(
        (actionBarRect.right - embeddedSceneRect.right).abs() <= 28,
        isTrue,
        reason:
            'Action bar should align to the same horizontal scene envelope as the table.',
      );

      final boardStateText = tester.widget<Text>(liveBoardStateText);
      expect(boardStateText.style?.fontWeight, FontWeight.w600);
      expect(tester.getRect(livePriceBadge).height <= 28.0, isTrue);
      expect(tester.getRect(livePotBadge).height <= 30.0, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 hand-loop live scene keeps table-dominant cohesion on compact phone',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 640);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'global_training_intro_seen_v1': true,
        'world1_intro_seen_v1': true,
        'world1_action_intro_seen_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_action_literacy',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();
      await _advanceToCampaignActionBarV1(tester);

      final promptCapsule = find.byKey(
        const Key('microtask_runner_prompt_capsule_v1'),
      );
      final progressionStatus = find.byKey(
        const Key('microtask_runner_progression_status_v1'),
      );
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final liveBoardStateBand = find.byKey(
        const Key('microtask_live_scene_board_state_band_v1'),
      );
      final liveSceneInstruction = find.byKey(
        const Key('microtask_live_scene_instruction_v1'),
      );
      final embeddedScene = find.byKey(const Key('modern_table_scene'));
      final feltOval = find.byKey(const Key('modern_table_oval'));
      final tableHost = find.byKey(const Key('microtask_table'));
      final sceneStateLane = find.byKey(
        const Key('modern_table_scene_state_lane'),
      );
      final heroRingFinder = find.byWidgetPredicate(
        (widget) =>
            widget.key is Key &&
            (widget.key as Key).toString().contains(
              'modern_table_seat_hero_ring_',
            ),
      );
      final scenePrompt = find.byKey(const Key('modern_table_scene_prompt'));

      await _pumpUntil(tester, actionBar, maxTicks: 180);
      await _pumpUntil(tester, embeddedScene, maxTicks: 180);
      await _pumpUntil(tester, liveBoardStateBand, maxTicks: 180);
      await _pumpUntil(tester, liveSceneInstruction, maxTicks: 180);

      expect(promptCapsule, findsNothing);
      expect(progressionStatus, findsOneWidget);
      expect(liveBoardStateBand, findsOneWidget);
      expect(liveSceneInstruction, findsOneWidget);
      expect(actionBar, findsOneWidget);
      expect(embeddedScene, findsOneWidget);
      expect(feltOval, findsOneWidget);
      expect(tableHost, findsOneWidget);
      expect(sceneStateLane, findsNothing);
      expect(scenePrompt, findsOneWidget);
      expect(heroRingFinder, findsOneWidget);

      final progressionStatusRect = tester.getRect(progressionStatus);
      final liveBoardStateBandRect = tester.getRect(liveBoardStateBand);
      final liveSceneInstructionRect = tester.getRect(liveSceneInstruction);
      final scenePromptRect = tester.getRect(scenePrompt);
      final embeddedSceneRect = tester.getRect(embeddedScene);
      final feltOvalRect = tester.getRect(feltOval);
      final tableHostRect = tester.getRect(tableHost);
      final actionBarRect = tester.getRect(actionBar);
      final heroRingRect = tester.getRect(heroRingFinder);
      final viewportHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final topStackHeight = feltOvalRect.top - progressionStatusRect.top;
      final topStackShare = topStackHeight / viewportHeight;
      final feltShare = feltOvalRect.height / viewportHeight;
      final laneToInstructionGap =
          scenePromptRect.top - liveBoardStateBandRect.bottom;
      final instructionToFeltGap =
          feltOvalRect.top - liveSceneInstructionRect.bottom;

      expect(
        liveBoardStateBandRect.bottom <= scenePromptRect.top,
        isTrue,
        reason:
            'Compact phone should still keep the primary instruction in the scene under the context band.',
      );
      expect(embeddedSceneRect.left - tableHostRect.left <= 8, isTrue);
      expect(tableHostRect.right - embeddedSceneRect.right <= 8, isTrue);
      expect(embeddedSceneRect.width / tableHostRect.width >= 0.95, isTrue);
      expect(topStackShare <= 0.20, isTrue);
      expect(feltShare >= 0.54, isTrue);
      expect(laneToInstructionGap >= -20 && laneToInstructionGap <= 60, isTrue);
      expect(
        liveSceneInstructionRect.center.dy < feltOvalRect.center.dy,
        isTrue,
      );
      expect(actionBarRect.top - heroRingRect.bottom >= 16, isTrue);
      expect((actionBarRect.left - embeddedSceneRect.left).abs() <= 28, isTrue);
      expect(
        (actionBarRect.right - embeddedSceneRect.right).abs() <= 28,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compact portrait header prompt keeps long learner task readable without prompt-capsule truncation',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'global_training_intro_seen_v1': true,
        'world1_intro_seen_v1': true,
        'world1_action_intro_seen_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.15)),
            child: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_act0_action_literacy',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
              debugHandLoopFeltCaptionOverrideV1:
                  _LongCompactPromptInstructionSourceV1.stepTitle,
            ),
          ),
        ),
      );
      await tester.pump();

      final promptCapsule = find.byKey(
        const Key('microtask_runner_prompt_capsule_v1'),
      );
      final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
      final scenePrompt = find.byKey(const Key('modern_table_scene_prompt'));
      final liveSceneInstruction = find.byKey(
        const Key('microtask_live_scene_instruction_v1'),
      );
      final stepHeader = find.byKey(const Key('microtask_step_header'));
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final liveBoardStateBand = find.byKey(
        const Key('microtask_live_scene_board_state_band_v1'),
      );

      await _pumpUntil(tester, liveSceneInstruction, maxTicks: 180);
      await _pumpUntil(tester, scenePrompt, maxTicks: 180);
      await _pumpUntil(tester, actionBar, maxTicks: 180);
      await _pumpUntil(tester, liveBoardStateBand, maxTicks: 180);

      expect(promptCapsule, findsNothing);
      expect(stepHeader, findsOneWidget);
      expect(stepPrompt, findsNothing);
      expect(liveSceneInstruction, findsOneWidget);
      expect(actionBar, findsOneWidget);
      expect(scenePrompt, findsOneWidget);

      final promptText = tester.widget<Text>(scenePrompt);
      expect(promptText.data, _LongCompactPromptInstructionSourceV1.stepTitle);
      expect(promptText.maxLines, 5);
      expect(promptText.softWrap, isTrue);
      expect(promptText.overflow, TextOverflow.clip);

      final promptRenderObject = tester.renderObject<RenderParagraph>(
        scenePrompt,
      );
      expect(
        promptRenderObject.didExceedMaxLines,
        isFalse,
        reason:
            'Compact portrait prompt capsule must not truncate learner-critical task text.',
      );

      final liveSceneInstructionRect = tester.getRect(liveSceneInstruction);
      final promptTextRect = tester.getRect(scenePrompt);
      final headerRect = tester.getRect(stepHeader);
      final liveBoardStateBandRect = tester.getRect(liveBoardStateBand);
      final actionBarRect = tester.getRect(actionBar);
      final scenePromptRect = tester.getRect(scenePrompt);

      expect(
        liveSceneInstructionRect.top >= headerRect.bottom - 1,
        isTrue,
        reason:
            'Scene-owned instruction must stay below the compact runner header headline.',
      );
      expect(
        liveBoardStateBandRect.bottom <= scenePromptRect.top,
        isTrue,
        reason:
            'Board-state context must stay above the scene-owned learner instruction.',
      );
      expect(
        liveSceneInstructionRect.bottom <= actionBarRect.top,
        isTrue,
        reason:
            'Scene-owned instruction must remain clear of the action controls on compact portrait.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'review queue and campaign seat-quiz share canonical shell primitives',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      Future<void> pumpSeatQuizShell(String mode) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'app_settings_engine_v2_backend_enabled_v1': true,
          'app_settings_checkpoint_mode_override_v1': true,
        });
        await tester.pumpWidget(
          MaterialApp(
            home: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_act0_table_literacy',
              moduleTitle: mode == kWorld1RunnerModeReviewQueue
                  ? 'Review Missed'
                  : 'World 1',
              mode: mode,
              startHandIndex: 1,
            ),
          ),
        );
        await tester.pump();

        final preludeContinue = find.byKey(
          const Key('microtask_prelude_continue_cta_v1'),
        );
        if (preludeContinue.evaluate().isNotEmpty) {
          await tester.tap(preludeContinue.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 120));
        }

        await _pumpUntil(
          tester,
          find.byType(ModernTableScreenV1),
          maxTicks: 120,
        );
        await _pumpUntil(
          tester,
          find.byKey(const Key('microtask_step_header')),
          maxTicks: 120,
        );
        await _pumpUntil(
          tester,
          find.byKey(const Key('microtask_runner_prompt_capsule_v1')),
          maxTicks: 120,
        );
      }

      Future<void> expectCanonicalSeatQuizShell({
        String? expectedHeadline,
      }) async {
        expect(find.byKey(const Key('microtask_runner')), findsOneWidget);
        expect(find.byType(ModernTableScreenV1), findsOneWidget);
        expect(find.byKey(const Key('microtask_step_header')), findsOneWidget);
        expect(
          find.byKey(const Key('microtask_runner_prompt_capsule_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('microtask_seat_quiz_table_instruction_v1')),
          findsNothing,
        );
        expect(find.byKey(const Key('microtask_seat_btn')), findsNothing);
        expect(find.byKey(const Key('microtask_check_cta')), findsOneWidget);
        final headline = tester.widget<Text>(
          find.byKey(const Key('microtask_step_header')),
        );
        expect((headline.data ?? '').trim(), isNotEmpty);
        if (expectedHeadline != null) {
          expect(find.text(expectedHeadline), findsOneWidget);
        }

        final modernTable = tester.widget<ModernTableScreenV1>(
          find.byType(ModernTableScreenV1),
        );
        expect(modernTable.onSeatTapV1, isNotNull);
      }

      await pumpSeatQuizShell(kWorld1RunnerModeReviewQueue);
      await expectCanonicalSeatQuizShell(expectedHeadline: 'Foundations check');
      expect(
        find.byKey(const Key('microtask_runner_progression_status_v1')),
        findsOneWidget,
      );

      await pumpSeatQuizShell(kWorld1RunnerModeCampaignSpine);
      await expectCanonicalSeatQuizShell();
      expect(
        find.byKey(const Key('microtask_runner_progression_status_v1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 street-flow early steps keep smart-learning framing on the real host',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'global_training_intro_seen_v1': true,
        'world1_intro_seen_v1': true,
        'world1_action_intro_seen_v1': true,
        'world1_street_flow_intro_seen_v1': true,
      });

      Future<void> advanceToInteractiveStep() async {
        for (var i = 0; i < 220; i++) {
          final outcome = find.byKey(const Key('microtask_outcome_surface'));
          final continueCta = find.byKey(const Key('microtask_continue_cta'));
          if (outcome.evaluate().isNotEmpty &&
              continueCta.evaluate().isNotEmpty) {
            await tester.tap(continueCta.first, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 140));
            continue;
          }
          final check = find.byKey(const Key('microtask_check_cta'));
          final card = find.byKey(const Key('street_flow_prelude_card_v1'));
          if (check.evaluate().isNotEmpty &&
              card.evaluate().isNotEmpty &&
              outcome.evaluate().isEmpty) {
            return;
          }
          await tester.pump(const Duration(milliseconds: 80));
        }
        fail('Did not reach street-flow interactive step deterministically.');
      }

      Future<void> completeSeatStep(String seatId) async {
        final seat = find.byKey(Key('microtask_seat_$seatId'));
        expect(seat, findsOneWidget);
        await tester.tap(seat.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 80));
        final check = find.byKey(const Key('microtask_check_cta'));
        expect(check, findsWidgets);
        await tester.tap(check.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 220));
        await tester.pump(const Duration(milliseconds: 220));
      }

      Future<void> expectStreetFlowSmartLearningVisible() async {
        final instructionSurface = find.byKey(
          const Key('microtask_seat_quiz_table_instruction_v1'),
        );
        final card = find.byKey(const Key('street_flow_prelude_card_v1'));
        await _pumpUntil(tester, instructionSurface, maxTicks: 120);
        expect(instructionSurface, findsOneWidget);
        expect(card, findsOneWidget);
        expect(
          find.descendant(
            of: instructionSurface,
            matching: find.textContaining('Why it matters:'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: instructionSurface,
            matching: find.textContaining('Notice:'),
          ),
          findsOneWidget,
        );
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_street_flow',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();
      await advanceToInteractiveStep();

      await expectStreetFlowSmartLearningVisible();

      await completeSeatStep('btn');
      await advanceToInteractiveStep();
      await expectStreetFlowSmartLearningVisible();

      await completeSeatStep('bb');
      await advanceToInteractiveStep();
      await expectStreetFlowSmartLearningVisible();

      await completeSeatStep('hj');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 street-flow skips blocking continuity intro and goes straight to the real host',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'global_training_intro_seen_v1': true,
        'world1_intro_seen_v1': true,
        'world1_action_intro_seen_v1': true,
        'world1_street_flow_intro_seen_v1': false,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_street_flow',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final streetFlowPrelude = find.byKey(
        const Key('microtask_world1_street_flow_intro_prelude_v1'),
      );
      await tester.pump(const Duration(milliseconds: 240));
      expect(streetFlowPrelude, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('correct seat auto-advances without CONTINUE', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Step 1 of 3'), findsOneWidget);
    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump();

    await _pumpUntil(tester, find.text('Step 2 of 3'));
    expect(find.byKey(const Key('microtask_outcome_surface')), findsNothing);
    expect(find.byKey(const Key('microtask_continue_cta')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong seat then check shows deterministic hint state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('microtask_seat_sb')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump();

    expect(find.byKey(const Key('microtask_hint_bubble')), findsOneWidget);
    expect(find.text('Incorrect seat.'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('UTG seat is selectable in seat quiz flow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('microtask_seat_utg')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump();

    expect(find.byKey(const Key('microtask_hint_bubble')), findsOneWidget);
    expect(find.text('Incorrect seat.'), findsOneWidget);
    expect(find.text('Select a seat first.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap highlighted seat is correct in seat quiz flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pump();

    const highlightedSeatId = 'btn';
    final highlightedRing = find.byKey(
      const Key('microtask_seat_quiz_target_ring_btn_v1'),
    );
    await _pumpUntil(tester, highlightedRing, maxTicks: 120);
    expect(
      highlightedRing,
      findsOneWidget,
      reason:
          'Expected deterministic highlighted seat ring for $highlightedSeatId',
    );
    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump();

    await _pumpUntil(tester, find.text('Step 2 of 3'));
    expect(find.text('Incorrect seat.'), findsNothing);
    expect(find.byKey(const Key('microtask_outcome_surface')), findsNothing);
    expect(find.byKey(const Key('microtask_continue_cta')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seat-quiz instruction label matches highlighted target seat', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.0)),
          child: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_table_literacy',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      ),
    );
    await tester.pump();

    final highlightedRing = find.byKey(
      const Key('microtask_seat_quiz_target_ring_btn_v1'),
    );
    await _pumpUntil(tester, highlightedRing, maxTicks: 120);
    expect(highlightedRing, findsOneWidget);

    final tableInstruction = find.byKey(
      const Key('microtask_seat_quiz_table_instruction_v1'),
    );
    final headerInstruction = find.byKey(
      const Key('microtask_seat_quiz_header_instruction_v1'),
    );
    final conceptPrelude = find.byKey(
      const Key('concept_first_seat_prelude_card_v1'),
    );
    final instructionSurface = tableInstruction.evaluate().isNotEmpty
        ? tableInstruction
        : (headerInstruction.evaluate().isNotEmpty
              ? headerInstruction
              : conceptPrelude);
    expect(instructionSurface, findsOneWidget);

    final embeddedConceptPrelude = find.descendant(
      of: instructionSurface,
      matching: conceptPrelude,
    );

    if (instructionSurface == conceptPrelude ||
        embeddedConceptPrelude.evaluate().isNotEmpty) {
      expect(
        find.descendant(
          of: instructionSurface,
          matching: find.textContaining('Why it matters:'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: instructionSurface,
          matching: find.textContaining('Notice:'),
        ),
        findsOneWidget,
      );
      if (instructionSurface == conceptPrelude) {
        expect(tableInstruction, findsNothing);
        expect(headerInstruction, findsNothing);
      } else {
        expect(tableInstruction, findsOneWidget);
      }
    } else {
      final promptFinder = find.descendant(
        of: instructionSurface,
        matching: find.byKey(const Key('microtask_step_prompt')),
      );
      expect(promptFinder, findsOneWidget);
      final promptTextWidget = tester.widget<Text>(promptFinder);
      final promptText = (promptTextWidget.data ?? '').trim();
      expect(promptText, contains('Button'));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'seat quiz incorrect outcome keeps expected/chosen line visible on surface',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.15)),
            child: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'intro_welcome',
              moduleTitle: 'Welcome to Poker',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('microtask_seat_sb')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('microtask_check_cta')));
      await tester.pump();

      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_surface')),
      );
      final state =
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen))
              as dynamic;
      final outcomeLines = List<String>.from(
        state.debugOutcomeLinesV1() as List<dynamic>,
      );
      expect(outcomeLines.first, startsWith('Better answer:'));
      expect(
        outcomeLines.any((line) => line.trim().startsWith('Next time:')),
        isTrue,
      );
      expect(find.textContaining('Expected:'), findsNothing);
      expect(find.textContaining('You chose:'), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world2 seat quiz follows authored seat loop and inserted action beat',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'world2_intro_seen_v1': true,
      });

      const openingSeatLoop = <String>['utg', 'hj', 'co', 'btn'];
      const closingBlindLoop = <String>['sb', 'bb'];
      const expectedLabels = <String, String>{
        'utg': 'Under the Gun',
        'hj': 'Hijack',
        'co': 'Cutoff',
        'btn': 'Button',
        'sb': 'Small Blind',
        'bb': 'Big Blind',
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.0)),
            child: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world2_spine_campaign_v1',
              moduleTitle: 'World 2',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      for (var i = 0; i < openingSeatLoop.length; i++) {
        final seatId = openingSeatLoop[i];
        final highlightedRing = find.byKey(
          Key('microtask_seat_quiz_target_ring_${seatId}_v1'),
        );
        await _pumpUntil(tester, highlightedRing, maxTicks: 240);
        expect(
          highlightedRing,
          findsOneWidget,
          reason: 'Expected highlighted ring for $seatId at loop index $i',
        );

        final tableInstruction = find.byKey(
          const Key('microtask_seat_quiz_table_instruction_v1'),
        );
        final headerInstruction = find.byKey(
          const Key('microtask_seat_quiz_header_instruction_v1'),
        );
        final instructionSurface = tableInstruction.evaluate().isNotEmpty
            ? tableInstruction
            : headerInstruction;
        expect(instructionSurface, findsOneWidget);

        final promptFinder = find.descendant(
          of: instructionSurface,
          matching: find.byKey(const Key('microtask_step_prompt')),
        );
        expect(promptFinder, findsOneWidget);
        final promptText = (tester.widget<Text>(promptFinder.first).data ?? '')
            .trim();
        expect(
          promptText,
          contains(expectedLabels[seatId]!),
          reason:
              'Instruction must match highlighted seat id=$seatId (text="$promptText")',
        );

        await tester.tap(find.byKey(Key('microtask_seat_$seatId')));
        await tester.pump();
        expect(
          find.byKey(const Key('microtask_continue_cta')),
          findsNothing,
          reason: 'Correct seat tap must not require Continue.',
        );
      }

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      await _pumpUntil(tester, actionBar, maxTicks: 240);
      expect(
        actionBar,
        findsOneWidget,
        reason:
            'World2 authored pack inserts the HJ facing-open action beat here.',
      );
      await _tapExpectedCampaignActionForPackV1(
        tester,
        packId: 'world2_spine_campaign_v1',
      );
      await _tapIfEnabledButtonByKeyV1(
        tester,
        const Key('microtask_continue_cta'),
      );

      for (var i = 0; i < closingBlindLoop.length; i++) {
        final seatId = closingBlindLoop[i];
        final highlightedRing = find.byKey(
          Key('microtask_seat_quiz_target_ring_${seatId}_v1'),
        );
        await _pumpUntil(tester, highlightedRing, maxTicks: 240);
        expect(
          highlightedRing,
          findsOneWidget,
          reason:
              'Expected highlighted ring for $seatId after inserted action beat',
        );

        final tableInstruction = find.byKey(
          const Key('microtask_seat_quiz_table_instruction_v1'),
        );
        final headerInstruction = find.byKey(
          const Key('microtask_seat_quiz_header_instruction_v1'),
        );
        final instructionSurface = tableInstruction.evaluate().isNotEmpty
            ? tableInstruction
            : headerInstruction;
        expect(instructionSurface, findsOneWidget);

        final promptFinder = find.descendant(
          of: instructionSurface,
          matching: find.byKey(const Key('microtask_step_prompt')),
        );
        expect(promptFinder, findsOneWidget);
        final promptText = (tester.widget<Text>(promptFinder.first).data ?? '')
            .trim();
        expect(
          promptText,
          contains(expectedLabels[seatId]!),
          reason:
              'Instruction must match highlighted seat id=$seatId (text="$promptText")',
        );

        await tester.tap(find.byKey(Key('microtask_seat_$seatId')));
        await tester.pump();
        expect(
          find.byKey(const Key('microtask_continue_cta')),
          findsNothing,
          reason: 'Correct seat tap must not require Continue.',
        );
      }

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world2 incorrect seat shows expected/chosen and requires continue without auto-advance',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'world2_intro_seen_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.0)),
            child: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world2_spine_campaign_v1',
              moduleTitle: 'World 2',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      final indexFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      await _pumpUntil(tester, indexFinder, maxTicks: 240);
      final indexBefore = (tester.widget<Text>(indexFinder.first).data ?? '')
          .trim();
      expect(indexBefore, 'i=0');

      await tester.tap(find.byKey(const Key('microtask_seat_btn')));
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_surface')),
        maxTicks: 240,
      );

      final state =
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen))
              as dynamic;
      final outcomeLines = List<String>.from(
        state.debugOutcomeLinesV1() as List<dynamic>,
      );
      expect(outcomeLines.first, startsWith('Better answer:'));
      expect(
        outcomeLines.any((line) => line.trim().startsWith('Next time:')),
        isTrue,
      );
      expect(find.textContaining('Expected:'), findsNothing);
      expect(find.textContaining('You chose:'), findsNothing);
      expect(find.byKey(const Key('microtask_continue_cta')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1200));
      final indexAfter = (tester.widget<Text>(indexFinder.first).data ?? '')
          .trim();
      expect(
        indexAfter,
        indexBefore,
        reason: 'Incorrect seat must not auto-advance without Continue tap.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world2 campaign reaches action slice with facing-bet CALL and visible flop board',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'world2_intro_seen_v1': true,
      });

      const seatLoop = <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.0)),
            child: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world2_spine_campaign_v1',
              moduleTitle: 'World 2',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();

      for (final seatId in seatLoop) {
        await _pumpUntil(
          tester,
          find.byKey(Key('microtask_seat_quiz_target_ring_${seatId}_v1')),
          maxTicks: 240,
        );
        await tester.tap(find.byKey(Key('microtask_seat_$seatId')));
        await tester.pump();
      }

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      await _pumpUntil(tester, actionBar, maxTicks: 240);
      expect(
        find.descendant(of: actionBar, matching: find.text('CALL')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: actionBar, matching: find.text('CHECK')),
        findsNothing,
      );

      await _tapExpectedCampaignActionForPackV1(
        tester,
        packId: 'world2_spine_campaign_v1',
      );
      await _tapIfEnabledButtonByKeyV1(
        tester,
        const Key('microtask_continue_cta'),
      );

      await _pumpUntil(
        tester,
        find.textContaining('Flop decision'),
        maxTicks: 240,
      );
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      await _pumpUntil(tester, boardStrip, maxTicks: 240);
      final boardCards = find.descendant(
        of: boardStrip,
        matching: find.byType(PlayingCardWidget),
      );
      expect(boardCards, findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'campaign runner keeps critical table/action UI visible on small portrait',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();
      await _advanceToCampaignActionBarV1(tester);

      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_campaign_action_bar')),
        maxTicks: 240,
      );
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_engine_board_strip')),
        maxTicks: 120,
      );
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_engine_hero_hole_cards')),
        maxTicks: 120,
      );

      expect(
        find.byKey(const Key('microtask_engine_board_strip')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_engine_hero_hole_cards')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('microtask_campaign_action_bar')),
        findsOneWidget,
      );

      final actionBarRect = tester.getRect(
        find.byKey(const Key('microtask_campaign_action_bar')),
      );
      final logicalHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(actionBarRect.bottom <= logicalHeight, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'demo multistreet pack renders board hero cards and action context',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'season1_demo_multistreet_v1',
            moduleTitle: 'Demo Multi Street',
            mode: kWorld1RunnerModeDemoHandLoopV1,
          ),
        ),
      );
      await tester.pump();

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final heroCards = find.byKey(
        const Key('microtask_engine_hero_hole_cards'),
      );
      final feltPrompt = find.byKey(const Key('microtask_step_prompt'));
      final seatFallbacks = <Finder>[
        find.byKey(const Key('microtask_seat_btn')),
        find.byKey(const Key('microtask_seat_sb')),
        find.byKey(const Key('microtask_seat_bb')),
        find.byKey(const Key('microtask_seat_utg')),
        find.byKey(const Key('microtask_seat_hj')),
        find.byKey(const Key('microtask_seat_co')),
      ];
      final seenKeys = <String>{};
      var sawAll = false;
      for (var i = 0; i < 120; i++) {
        if (actionBar.evaluate().isNotEmpty) seenKeys.add('action');
        if (boardStrip.evaluate().isNotEmpty) seenKeys.add('board');
        if (heroCards.evaluate().isNotEmpty) seenKeys.add('hero');
        if (feltPrompt.evaluate().isNotEmpty) seenKeys.add('prompt');
        if (actionBar.evaluate().isNotEmpty &&
            boardStrip.evaluate().isNotEmpty &&
            heroCards.evaluate().isNotEmpty &&
            feltPrompt.evaluate().isNotEmpty) {
          sawAll = true;
          break;
        }
        if (boardStrip.evaluate().isNotEmpty &&
            heroCards.evaluate().isNotEmpty) {
          await tester.pump(const Duration(milliseconds: 120));
          continue;
        }
        if (await _tapIfEnabledButtonByKeyV1(
          tester,
          const Key('microtask_continue_cta'),
        )) {
          continue;
        }
        final seatFinder =
            _seatFinderFromPromptV1(tester) ??
            seatFallbacks[i % seatFallbacks.length];
        if (seatFinder.evaluate().isNotEmpty) {
          await tester.tap(seatFinder, warnIfMissed: false);
          await tester.pump();
        }
        await _tapIfEnabledButtonByKeyV1(
          tester,
          const Key('microtask_check_cta'),
        );
        await tester.pump(const Duration(milliseconds: 60));
      }

      expect(sawAll, isTrue, reason: 'Seen keys: ${seenKeys.toList()..sort()}');

      expect(boardStrip, findsOneWidget);
      expect(heroCards, findsOneWidget);
      expect(actionBar, findsOneWidget);
      expect(find.byKey(const Key('microtask_step_prompt')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'demo multistreet hero badge reflects CO SB and BB debug states',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      Future<void> pumpAndExpectHeroLabel(
        RunnerDebugBootstrapStateV1? bootstrap,
        String expectedLabel,
        List<String> expectedKeys,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: KeyedSubtree(
              key: ValueKey<String>('hero-badge-${bootstrap?.name ?? 'co'}'),
              child: World1FoundationsMicroTaskRunnerScreen(
                moduleId: 'season1_demo_multistreet_v1',
                moduleTitle: 'Demo Multi Street',
                mode: kWorld1RunnerModeDemoHandLoopV1,
                debugBootstrapStateV1: bootstrap,
              ),
            ),
          ),
        );
        await tester.pump();
        await _pumpUntil(
          tester,
          find.byKey(const Key('microtask_hero_position_badge_v1')),
          maxTicks: 120,
        );
        expect(
          find.byKey(const Key('microtask_seat_state_badge_hero_v1')),
          findsOneWidget,
        );
        final badge = find.byKey(const Key('microtask_hero_position_badge_v1'));
        expect(badge, findsOneWidget);
        String? badgeText = tester.widget<Text>(badge).data;
        for (var i = 0; i < 120 && badgeText != expectedLabel; i++) {
          await tester.pump(const Duration(milliseconds: 50));
          badgeText = tester.widget<Text>(badge).data;
        }
        expect(badgeText, expectedLabel);
        for (final key in expectedKeys) {
          expect(find.byKey(Key(key)), findsOneWidget);
        }
        final prompt = find.byKey(const Key('microtask_demo_prompt_box_v1'));
        final heroCards = find.byKey(
          const Key('microtask_demo_hero_cards_box_v1'),
        );
        final tokenRow = find.byKey(const Key('microtask_demo_token_row_v1'));
        expect(prompt, findsOneWidget);
        expect(heroCards, findsOneWidget);
        expect(tokenRow, findsOneWidget);
        final promptRect = tester.getRect(prompt);
        final heroCardsRect = tester.getRect(heroCards);
        final tokenRowRect = tester.getRect(tokenRow);
        final tableRect = tester.getRect(
          find.byKey(const Key('microtask_table')),
        );
        final allSeatRects = <Rect>[
          tester.getRect(
            find.byKey(const Key('microtask_seat_display_btn_v1')),
          ),
          tester.getRect(find.byKey(const Key('microtask_seat_display_sb_v1'))),
          tester.getRect(find.byKey(const Key('microtask_seat_display_bb_v1'))),
          tester.getRect(
            find.byKey(const Key('microtask_seat_display_utg_v1')),
          ),
          tester.getRect(find.byKey(const Key('microtask_seat_display_hj_v1'))),
          tester.getRect(find.byKey(const Key('microtask_seat_display_co_v1'))),
        ]..sort((a, b) => a.center.dy.compareTo(b.center.dy));
        final topSeatBandBottom = allSeatRects
            .take(3)
            .map((rect) => rect.bottom)
            .reduce(math.max);
        final minVerticalGap = expectedLabel == 'CO' ? 8.0 : 10.0;
        final maxPromptWidthFactor = expectedLabel == 'CO' ? 0.62 : 0.58;
        expect(
          promptRect.width,
          lessThan(tableRect.width * maxPromptWidthFactor),
          reason: 'Demo felt caption must stay bounded inside the seat band',
        );
        expect(
          promptRect.overlaps(heroCardsRect),
          isFalse,
          reason: 'Demo prompt must not overlap hero cards',
        );
        expect(
          promptRect.top,
          greaterThanOrEqualTo(topSeatBandBottom + minVerticalGap),
          reason: 'Demo prompt must stay below the top seat band',
        );
        expect(
          promptRect.bottom + minVerticalGap,
          lessThanOrEqualTo(heroCardsRect.top),
          reason: 'Demo prompt must keep a stable gap above hero cards',
        );
        expect(
          heroCardsRect.bottom + minVerticalGap,
          lessThanOrEqualTo(tokenRowRect.top),
          reason: 'Demo token row must stay below hero cards',
        );
      }

      await pumpAndExpectHeroLabel(null, 'CO', <String>[
        'microtask_hero_display_btn_v1',
        'microtask_seat_display_btn_v1',
        'microtask_pot_center_v1',
      ]);
      await pumpAndExpectHeroLabel(
        RunnerDebugBootstrapStateV1.demoDecisionHeroSb,
        'SB',
        <String>[
          'microtask_hero_display_btn_v1',
          'microtask_blind_sb_display_btn_v1',
          'microtask_blind_bb_display_sb_v1',
          'microtask_pot_center_v1',
        ],
      );
      await pumpAndExpectHeroLabel(
        RunnerDebugBootstrapStateV1.demoDecisionHeroBb,
        'BB',
        <String>[
          'microtask_hero_display_btn_v1',
          'microtask_blind_bb_display_btn_v1',
          'microtask_pot_center_v1',
        ],
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'portrait table viewport stays stable between seat-quiz and hand-loop modes',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      Future<({Size canvas, Size stadium, bool conceptPreludeVisible})>
      measureSeatQuizCanvasSize() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_act0_table_literacy',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        );
        await tester.pump();

        final tableCanvas = find.byKey(const Key('microtask_table_canvas'));
        await _pumpUntil(tester, tableCanvas, maxTicks: 240);

        final preludeContinue = find.byKey(
          const Key('microtask_prelude_continue_cta_v1'),
        );
        if (preludeContinue.evaluate().isNotEmpty) {
          await tester.tap(preludeContinue, warnIfMissed: false);
          await tester.pump();
        }
        await _completeIntroSequenceV1(tester);
        await tester.pump(const Duration(milliseconds: 80));
        final stadiumShell = find.byKey(
          const Key('microtask_table_stadium_shell_v1'),
        );
        expect(
          stadiumShell,
          findsOneWidget,
          reason: 'Seat-quiz mode must expose the stadium shell key',
        );
        return (
          canvas: tester.getRect(tableCanvas).size,
          stadium: tester.getRect(stadiumShell).size,
          conceptPreludeVisible: find
              .byKey(const Key('concept_first_seat_prelude_card_v1'))
              .evaluate()
              .isNotEmpty,
        );
      }

      Future<({Size canvas, Size stadium})> measureHandLoopCanvasSize() async {
        await tester.pumpWidget(
          const MaterialApp(
            home: World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_spine_campaign_v1',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        );
        await tester.pump();
        await _pumpUntil(
          tester,
          find.byKey(const Key('microtask_campaign_action_bar')),
          maxTicks: 240,
        );
        expect(
          find.byKey(const Key('microtask_engine_board_strip')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('microtask_engine_hero_hole_cards')),
          findsOneWidget,
        );
        final stadiumShell = find.byKey(
          const Key('microtask_table_stadium_shell_v1'),
        );
        expect(
          stadiumShell,
          findsOneWidget,
          reason: 'Hand-loop mode must expose the stadium shell key',
        );
        return (
          canvas: tester
              .getRect(find.byKey(const Key('microtask_table_canvas')))
              .size,
          stadium: tester.getRect(stadiumShell).size,
        );
      }

      final seatQuizSize = await measureSeatQuizCanvasSize();
      final handLoopSize = await measureHandLoopCanvasSize();

      final logicalHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final seatQuizHeightRatio = seatQuizSize.canvas.height / logicalHeight;
      final handLoopHeightRatio = handLoopSize.canvas.height / logicalHeight;
      final relativeHeightDelta =
          (seatQuizSize.canvas.height - handLoopSize.canvas.height).abs() /
          math.max(seatQuizSize.canvas.height, handLoopSize.canvas.height);
      final relativeWidthDelta =
          (seatQuizSize.canvas.width - handLoopSize.canvas.width).abs() /
          math.max(seatQuizSize.canvas.width, handLoopSize.canvas.width);
      final seatQuizStadiumAspect =
          seatQuizSize.stadium.height / seatQuizSize.stadium.width;
      final handLoopStadiumAspect =
          handLoopSize.stadium.height / handLoopSize.stadium.width;
      final stadiumAspectDelta = (seatQuizStadiumAspect - handLoopStadiumAspect)
          .abs();

      expect(seatQuizHeightRatio >= 0.50, isTrue);
      expect(handLoopHeightRatio >= 0.50, isTrue);
      expect(
        relativeHeightDelta <=
            (seatQuizSize.conceptPreludeVisible ? 0.14 : 0.04),
        isTrue,
        reason:
            'Covered concept-first portrait steps intentionally reserve more top-panel height so the visible prelude fits on screen.',
      );
      expect(relativeWidthDelta <= 0.02, isTrue);
      expect(
        seatQuizStadiumAspect >=
            (seatQuizSize.conceptPreludeVisible ? 1.05 : 1.20),
        isTrue,
        reason: 'seatQuizStadiumAspect=$seatQuizStadiumAspect',
      );
      expect(
        handLoopStadiumAspect >= 1.20,
        isTrue,
        reason: 'handLoopStadiumAspect=$handLoopStadiumAspect',
      );
      expect(seatQuizStadiumAspect <= 1.55, isTrue);
      expect(handLoopStadiumAspect <= 1.55, isTrue);
      expect(
        stadiumAspectDelta <=
            (seatQuizSize.conceptPreludeVisible ? 0.24 : 0.06),
        isTrue,
        reason:
            'Covered concept-first portrait steps intentionally trade some seat-quiz stadium height for a visible smart-learning prelude.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'portrait seat-quiz mode keeps instruction on table center lane',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'intro_welcome',
            moduleTitle: 'Welcome to Poker',
          ),
        ),
      );
      await tester.pump();

      final stepHeader = find.byKey(const Key('microtask_step_header'));
      final tableCanvas = find.byKey(const Key('microtask_table_canvas'));
      final tablePromptFinder = find.byKey(
        const Key('microtask_seat_quiz_table_instruction_v1'),
      );
      final headerPromptFinder = find.byKey(
        const Key('microtask_seat_quiz_header_instruction_v1'),
      );

      await _pumpUntil(tester, stepHeader, maxTicks: 120);
      await _pumpUntil(tester, tableCanvas, maxTicks: 120);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 120));

      expect(stepHeader, findsOneWidget);
      expect(tableCanvas, findsOneWidget);
      final promptFinder = tablePromptFinder.evaluate().isNotEmpty
          ? tablePromptFinder
          : headerPromptFinder;
      expect(promptFinder, findsOneWidget);
      expect(tablePromptFinder, findsOneWidget);
      expect(
        find.byKey(const Key('microtask_felt_caption_container_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('microtask_seat_quiz_caption_v1')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      final promptTextFinder = find.descendant(
        of: promptFinder,
        matching: find.byType(Text),
      );
      expect(promptTextFinder, findsAtLeastNWidgets(1));
      final promptText =
          (tester.widget<Text>(promptTextFinder.first).data ?? '').trim();
      expect(promptText, isNotEmpty);

      final headerRect = tester.getRect(stepHeader);
      final tableRect = tester.getRect(tableCanvas);
      final promptRect = tester.getRect(promptFinder);

      expect(promptRect.top > headerRect.bottom, isTrue);
      expect(promptRect.bottom <= tableRect.bottom, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('lock in stays disabled until a seat is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pump();

    final lockInButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('microtask_check_cta')),
    );
    expect(lockInButton.onPressed, isNull);
    expect(
      find.textContaining('Seat drill: identify the highlighted'),
      findsAtLeastNWidgets(1),
    );
    expect(find.textContaining('then confirm.'), findsOneWidget);
    expect(find.textContaining('This is the '), findsNothing);
    expect(find.text('Select a seat.'), findsNothing);
    expect(find.byKey(const Key('microtask_outcome_surface')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('spine seat-intro keeps instruction on felt only', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'world1_spine_campaign_v1',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
    await tester.pump();

    await _pumpUntil(
      tester,
      find.byKey(const Key('microtask_step_prompt')),
      maxTicks: 240,
    );
    final promptWidgets = find
        .byKey(const Key('microtask_step_prompt'))
        .evaluate()
        .map((element) => element.widget)
        .whereType<Text>()
        .toList(growable: false);
    expect(promptWidgets, isNotEmpty);
    expect(
      promptWidgets.any((text) => (text.data ?? '').trim().isNotEmpty),
      isTrue,
    );
    expect(find.text('Select a seat.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('campaign outcome shows CONTINUE CTA and keeps it on-screen', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'world1_spine_campaign_v1',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
    await tester.pump();

    await _pumpUntil(
      tester,
      find.byKey(const Key('microtask_campaign_action_bar')),
      maxTicks: 240,
    );
    await _tapFirstEnabledCampaignAction(tester);

    await _pumpUntil(
      tester,
      find.byKey(const Key('microtask_outcome_surface')),
    );
    final continueText = find.descendant(
      of: find.byKey(const Key('microtask_continue_cta')),
      matching: find.text('CONTINUE'),
    );
    expect(continueText, findsOneWidget);

    final continueRect = tester.getRect(
      find.byKey(const Key('microtask_continue_cta')),
    );
    final logicalHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(continueRect.top >= 0, isTrue);
    expect(continueRect.bottom <= logicalHeight, isTrue);
    expect(tester.takeException(), isNull);
  });

  test(
    'world1 spine/followup have deterministic wrong allowed action that evaluates incorrect',
    () {
      const packIds = <String>[
        'world1_spine_campaign_v1',
        'world1_spine_followup_v1_b0',
      ];
      for (final packId in packIds) {
        final startIndex = _firstActionableStepIndexForPackV1(
          packId,
          requireAlternativeAction: true,
        );
        final pack = kCampaignPacksV1[packId];
        expect(pack, isNotNull, reason: 'Missing pack=$packId');
        final step = pack12(pack!)[startIndex];
        final expectedKind = world1SpineExpectedActionKindV1(step);
        expect(expectedKind, isNotNull, reason: 'Missing expected action');
        final wrongToken = _firstNonExpectedActionTokenV1(step);
        final wrongKind = _actionKindFromAllowedTokenV1(wrongToken);
        expect(wrongKind, isNotNull, reason: 'No wrong action kind');
        expect(
          world1SpineIsExpectedActionV1(
            step: step,
            selectedActionKind: wrongKind!,
          ),
          isFalse,
          reason: 'pack=$packId wrong token=$wrongToken should be incorrect',
        );
        expect(
          world1SpineIsExpectedActionV1(
            step: step,
            selectedActionKind: expectedKind!,
          ),
          isTrue,
          reason: 'pack=$packId expected action should be correct',
        );
      }
    },
  );

  test('world1 demo parity packs keep actionable prompts non-placeholder', () {
    const packIds = <String>[
      'world1_spine_campaign_v1',
      'world1_spine_followup_v1_b0',
      'world1_spine_followup_v1_b1',
      'world1_spine_followup_v1_b2',
    ];
    const blockedPromptPhrases = <String>{
      'choose the best action for this spot.',
      'select a seat.',
      'use the table prompt, then confirm.',
    };
    for (final packId in packIds) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'Missing pack=$packId');
      final steps = pack12(pack!);
      for (var stepIndex = 0; stepIndex < steps.length; stepIndex++) {
        final step = steps[stepIndex];
        final actions = (step.allowedActions ?? const <String>[])
            .map((value) => value.trim().toLowerCase())
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
        if (actions.isEmpty) {
          continue;
        }
        final prompt = step.prompt.trim();
        expect(
          prompt,
          isNotEmpty,
          reason:
              'Actionable step must have non-empty prompt ($packId#$stepIndex)',
        );
        final normalizedPrompt = prompt.toLowerCase();
        expect(
          blockedPromptPhrases.contains(normalizedPrompt),
          isFalse,
          reason:
              'Actionable prompt must not be placeholder text ($packId#$stepIndex "$prompt")',
        );
        final expectedKind = world1SpineExpectedActionKindV1(step);
        expect(
          expectedKind,
          isNotNull,
          reason:
              'Missing expected action for actionable step $packId#$stepIndex',
        );
      }
    }
  });

  testWidgets(
    'world1 spine incorrect outcome uses factual copy with visible why',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
            debugBootstrapStateV1:
                RunnerDebugBootstrapStateV1.outcomeIncorrectRange,
          ),
        ),
      );
      await tester.pump();

      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_surface')),
        maxTicks: 240,
      );
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      expect(stepIndexTextFinder, findsOneWidget);
      final handIndexLabel =
          tester.widget<Text>(stepIndexTextFinder).data ?? '';
      final handIndexMatch = RegExp(r'^i=(\d+)$').firstMatch(handIndexLabel);
      final handIndex = int.tryParse(handIndexMatch?.group(1) ?? '');
      expect(handIndex, isNotNull);
      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final step = pack12(pack!)[handIndex!];
      final expectedLine = world1SpineOutcomeExpectedLineV1(step);
      expect(expectedLine, isNotNull);
      final state =
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen))
              as dynamic;
      final outcomeLines = List<String>.from(
        state.debugOutcomeLinesV1() as List<dynamic>,
      );

      expect(outcomeLines.first, startsWith('Better line:'));
      expect(
        outcomeLines.first,
        contains(expectedLine!.replaceFirst('Expected: ', '')),
      );
      expect(
        outcomeLines.any((line) => line.trim().startsWith('Notice:')),
        isTrue,
      );
      expect(find.textContaining('Focus:'), findsNothing);
      expect(find.textContaining('optimal', findRichText: true), findsNothing);
      expect(find.textContaining('solver', findRichText: true), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 followup incorrect outcome keeps stronger-line headline and notice without Focus',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      const packId = 'world1_spine_followup_v1_b0';
      final startIndex = _firstActionableFollowupStepIndexV1(
        packId,
        requireAlternativeAction: true,
      );
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
      final step = pack12(pack!)[startIndex];
      final expectedLine = world1SpineOutcomeExpectedLineV1(step);
      expect(expectedLine, isNotNull);
      await tester.pumpWidget(
        MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1 Followup',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: startIndex,
          ),
        ),
      );
      await tester.pump();

      await _advanceToCampaignActionBarV1(tester);

      final nonExpectedToken = _firstNonExpectedActionTokenV1(step);
      await _tapCampaignActionTokenV1(tester, actionToken: nonExpectedToken);
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_surface')),
        maxTicks: 260,
      );
      final state =
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen))
              as dynamic;
      final outcomeLines = List<String>.from(
        state.debugOutcomeLinesV1() as List<dynamic>,
      );
      expect(outcomeLines.first, startsWith('Better line:'));
      expect(
        outcomeLines.first,
        contains(expectedLine!.replaceFirst('Expected: ', '')),
      );
      expect(
        outcomeLines.any((line) => line.trim().startsWith('Notice:')),
        isTrue,
      );
      expect(find.textContaining('Focus:'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 spine incorrect action outcome aligns raise label with action affordance',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      const packId = 'world1_spine_campaign_v1';
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
      final step = pack12(pack!)[0];
      expect(step.expectedActionKind, 'raise');

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: 0,
          ),
        ),
      );
      await tester.pump();
      await _advanceToCampaignActionBarV1(tester);
      await _tapCampaignActionTokenV1(tester, actionToken: 'call');
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_surface')),
        maxTicks: 280,
      );

      final state =
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen))
              as dynamic;
      final outcomeLines = List<String>.from(
        state.debugOutcomeLinesV1() as List<dynamic>,
      );
      expect(outcomeLines.first, contains('Better line:'));
      expect(outcomeLines.first, contains('RAISE.'));
      expect(
        outcomeLines.any((line) => line.trim().startsWith('Notice:')),
        isTrue,
      );
      expect(find.textContaining('RAISE TO'), findsNothing);
      expect(find.textContaining('Focus:'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 spine correct outcome aligns raise wording with action affordance',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      const packId = 'world1_spine_campaign_v1';
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
      final step = pack12(pack!)[0];
      expect(step.expectedActionKind, 'raise');

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: 0,
          ),
        ),
      );
      await tester.pump();
      await _advanceToCampaignActionBarV1(tester);
      await _tapCampaignActionTokenV1(tester, actionToken: 'raise_to');
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_surface')),
        maxTicks: 280,
      );

      expect(
        find.textContaining('Correct: RAISE TO applies pressure.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Correct: Raise increases the bet.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('world1 followup correct outcome shows deterministic Correct', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });

    const packId = 'world1_spine_followup_v1_b0';
    final startIndex = _firstActionableFollowupStepIndexV1(packId);
    await tester.pumpWidget(
      MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: packId,
          moduleTitle: 'World 1 Followup',
          mode: kWorld1RunnerModeCampaignSpine,
          startHandIndex: startIndex,
        ),
      ),
    );
    await tester.pump();

    await _advanceToCampaignActionBarV1(tester);
    await _tapExpectedCampaignActionForPackV1(tester, packId: packId);
    await _pumpUntil(
      tester,
      find.byKey(const Key('microtask_outcome_surface')),
      maxTicks: 260,
    );
    expect(find.textContaining('Correct:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'world1 compact wrong-action status box preserves why and next hierarchy without pipe-joined collapse',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(932, 560);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      const packId = 'world1_spine_followup_v1_b0';
      final startIndex = _firstActionableFollowupStepIndexV1(
        packId,
        requireAlternativeAction: true,
      );
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
      final step = pack12(pack!)[startIndex];
      final nonExpectedToken = _firstNonExpectedActionTokenV1(step);

      await tester.pumpWidget(
        MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1 Followup',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: startIndex,
          ),
        ),
      );
      await tester.pump();

      await _advanceToCampaignActionBarV1(tester);
      await _tapCampaignActionTokenV1(tester, actionToken: nonExpectedToken);
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_status_box_v1')),
        maxTicks: 260,
      );

      final statusBox = find.byKey(
        const Key('microtask_outcome_status_box_v1'),
      );
      expect(statusBox, findsOneWidget);
      final statusContainer = tester.widget<Container>(statusBox);
      final statusDecoration = statusContainer.decoration! as BoxDecoration;
      final statusBorder = statusDecoration.border! as Border;
      final state =
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen))
              as dynamic;
      final outcomeLines = List<String>.from(
        state.debugOutcomeLinesV1() as List<dynamic>,
      );
      expect(
        outcomeLines.any((line) => line.trim().startsWith('Notice:')),
        isTrue,
      );
      expect(
        outcomeLines.any((line) => line.trim().startsWith('Better line:')),
        isTrue,
      );
      expect(
        find.descendant(of: statusBox, matching: find.textContaining('|')),
        findsNothing,
      );
      expect(
        statusDecoration.color!.opacity,
        lessThan(SharkyTokensV1.surfaceElevated.withOpacity(0.78).opacity),
      );
      expect(statusBorder.top.color.opacity, lessThan(0.44));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 outcome perf metrics keep deterministic ordering and bounded budget',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      const packId = 'world1_spine_followup_v1_b0';
      final startIndex = _firstActionableFollowupStepIndexV1(
        packId,
        requireAlternativeAction: true,
      );
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
      final step = pack12(pack!)[startIndex];
      final nonExpectedToken = _firstNonExpectedActionTokenV1(step);

      await tester.pumpWidget(
        MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1 Followup',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: startIndex,
          ),
        ),
      );
      await tester.pump();

      await _advanceToCampaignActionBarV1(tester);
      await _tapCampaignActionTokenV1(tester, actionToken: nonExpectedToken);
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_outcome_surface')),
        maxTicks: 260,
      );

      await _openRunnerDetailsSheetV1(tester);

      final engineStartUs = _nullableIntFromDetailsLineV1(
        _detailsLineTextByKeyV1(tester, 'details_debug_engine_start_us_v1'),
        'engine_start_us:',
      );
      final engineDoneUs = _nullableIntFromDetailsLineV1(
        _detailsLineTextByKeyV1(tester, 'details_debug_engine_done_us_v1'),
        'engine_done_us:',
      );
      final outcomeSetStateUs = _nullableIntFromDetailsLineV1(
        _detailsLineTextByKeyV1(tester, 'details_debug_outcome_setstate_us_v1'),
        'outcome_setstate_us:',
      );
      final outcomeFirstFrameUs = _nullableIntFromDetailsLineV1(
        _detailsLineTextByKeyV1(
          tester,
          'details_debug_outcome_first_frame_us_v1',
        ),
        'outcome_first_frame_us:',
      );
      final totalMs = _nullableIntFromDetailsLineV1(
        _detailsLineTextByKeyV1(tester, 'details_debug_total_ms_v1'),
        'total_ms:',
      );

      expect(engineStartUs, isNotNull);
      expect(engineDoneUs, isNotNull);
      expect(outcomeSetStateUs, isNotNull);
      expect(outcomeFirstFrameUs, isNotNull);
      expect(totalMs, isNotNull);

      expect(engineStartUs! <= engineDoneUs!, isTrue);
      expect(engineDoneUs <= outcomeSetStateUs!, isTrue);
      expect(outcomeSetStateUs <= outcomeFirstFrameUs!, isTrue);

      expect(totalMs! >= 0, isTrue);
      expect(
        totalMs <= 2000,
        isTrue,
        reason:
            'Outcome total latency must stay within conservative CI budget.',
      );

      final segmentMs = <int?>[
        _nullableIntFromDetailsLineV1(
          _detailsLineTextByKeyV1(tester, 'details_debug_delta_engine_ms_v1'),
          'delta_engine_ms:',
        ),
        _nullableIntFromDetailsLineV1(
          _detailsLineTextByKeyV1(tester, 'details_debug_delta_commit_ms_v1'),
          'delta_commit_ms:',
        ),
        _nullableIntFromDetailsLineV1(
          _detailsLineTextByKeyV1(tester, 'details_debug_show_call_ms_v1'),
          'show_call_ms:',
        ),
        _nullableIntFromDetailsLineV1(
          _detailsLineTextByKeyV1(
            tester,
            'details_debug_show_pre_setstate_ms_v1',
          ),
          'show_pre_setstate_ms:',
        ),
        _nullableIntFromDetailsLineV1(
          _detailsLineTextByKeyV1(tester, 'details_debug_show_setstate_ms_v1'),
          'show_setstate_ms:',
        ),
        _nullableIntFromDetailsLineV1(
          _detailsLineTextByKeyV1(tester, 'details_debug_delta_frame_ms_v1'),
          'delta_frame_ms:',
        ),
      ].whereType<int>().toList(growable: false);

      expect(segmentMs, isNotEmpty);
      for (final segment in segmentMs) {
        expect(segment >= 0, isTrue);
        expect(
          segment <= 500,
          isTrue,
          reason: 'No single measured perf segment should exceed 500ms.',
        );
      }

      await _closeRunnerDetailsSheetV1(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'campaign seat-quiz first wrong answer queues review ref immediately',
    (tester) async {
      const packId = 'world1_act0_table_literacy';
      const startIndex = 1;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      Finder? visibleSeatFinderForId(String seatId) {
        final legacy = find.byKey(Key('microtask_seat_$seatId'));
        if (legacy.evaluate().isNotEmpty) return legacy;

        final roleLabel = switch (seatId) {
          'btn' => 'BTN',
          'sb' => 'SB',
          'bb' => 'BB',
          'utg' => 'UTG',
          'hj' => 'HJ',
          'co' => 'CO',
          _ => null,
        };
        if (roleLabel == null) return null;

        for (var i = 0; i < 9; i++) {
          final roleFinder = find.byKey(Key('modern_table_seat_role_$i'));
          if (roleFinder.evaluate().isEmpty) continue;
          final matchingRoleText = find.descendant(
            of: roleFinder,
            matching: find.textContaining(roleLabel),
          );
          if (matchingRoleText.evaluate().isNotEmpty) {
            final seatFinder = find.byKey(Key('modern_table_seat_$i'));
            if (seatFinder.evaluate().isNotEmpty) return seatFinder;
          }
        }
        return null;
      }

      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
        final expectedSeatId =
          pack![startIndex].expectedSeatIds.first.toLowerCase();

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: startIndex,
          ),
        ),
      );
      await tester.pump();

      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      if (preludeContinue.evaluate().isNotEmpty) {
        await tester.tap(preludeContinue.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 120));
      }

      await _pumpUntil(tester, find.byType(ModernTableScreenV1), maxTicks: 120);
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_step_prompt')),
        maxTicks: 120,
      );

      Finder? wrongSeatFinder;
      for (final seatId in const <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co']) {
        if (seatId == expectedSeatId) continue;
        final candidate = visibleSeatFinderForId(seatId);
        if (candidate == null || candidate.evaluate().isEmpty) continue;
        wrongSeatFinder = candidate;
        break;
      }

      expect(
        wrongSeatFinder,
        isNotNull,
        reason: 'Test must locate a visible wrong seat candidate.',
      );

      await tester.tap(wrongSeatFinder!.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
      await _tapIfEnabledButtonByKeyV1(
        tester,
        const Key('microtask_check_cta'),
      );
      await tester.pump(const Duration(milliseconds: 120));

      var queueNow = await ProgressService.getReviewQueueForPackV1(packId);
      for (var i = 0; i < 40 && queueNow.isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        queueNow = await ProgressService.getReviewQueueForPackV1(packId);
      }
      expect(queueNow, isNotEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'campaign hand-loop first wrong action queues review ref immediately',
    (tester) async {
      const packId = 'world1_spine_campaign_v1';
      final startIndex = _firstActionableStepIndexForPackV1(
        packId,
        requireAlternativeAction: true,
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
      final step = pack12(pack!)[startIndex];
      final wrongToken = _firstNonExpectedActionTokenV1(step);

      await tester.pumpWidget(
        MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: startIndex,
          ),
        ),
      );
      await tester.pump();

      await _tapCampaignActionTokenV1(tester, actionToken: wrongToken);
      await tester.pump(const Duration(milliseconds: 120));

      var queueNow = await ProgressService.getReviewQueueForPackV1(packId);
      for (var i = 0; i < 40 && queueNow.isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 30));
        queueNow = await ProgressService.getReviewQueueForPackV1(packId);
      }
      expect(queueNow, isNotEmpty);
      expect(
        queueNow.any((ref) => ref.stepIndex == startIndex),
        isTrue,
        reason: 'Wrong action step must be queued for end-of-lesson review.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'review queue non-empty boots non-empty session and consumes queue deterministically',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      const packId = 'world1_spine_campaign_v1';
      final queuedStepIndex = _firstActionableStepIndexForPackV1(packId);
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'review_queue_v1::$packId': jsonEncode(<Map<String, Object>>[
          <String, Object>{'packId': packId, 'stepIndex': queuedStepIndex},
        ]),
      });

      final queueBefore = await ProgressService.getReviewQueueForPackV1(packId);
      expect(queueBefore, isNotEmpty);

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeReviewQueue,
          ),
        ),
      );
      await tester.pump();

      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull);
      final step = pack12(pack!)[queuedStepIndex];
      final expectedKind = world1SpineExpectedActionKindV1(step);
      expect(expectedKind, isNotNull);
      final expectedActionToken = (step.allowedActions ?? const <String>[])
          .map((value) => value.trim().toLowerCase())
          .firstWhere(
            (token) => _actionKindFromAllowedTokenV1(token) == expectedKind,
            orElse: () => '',
          );
      expect(expectedActionToken, isNotEmpty);

      Future<bool> tapIfVisible(Finder finder) async {
        if (finder.evaluate().isEmpty) return false;
        await tester.tap(finder.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 90));
        return true;
      }

      Finder fallbackSeatFinderForTick(int tick) {
        final legacyFallbacks = <Finder>[
          find.byKey(const Key('microtask_seat_btn')),
          find.byKey(const Key('microtask_seat_sb')),
          find.byKey(const Key('microtask_seat_bb')),
          find.byKey(const Key('microtask_seat_utg')),
          find.byKey(const Key('microtask_seat_hj')),
          find.byKey(const Key('microtask_seat_co')),
        ];
        final modernFallback = find.byKey(Key('modern_table_seat_${tick % 9}'));
        if (modernFallback.evaluate().isNotEmpty) {
          return modernFallback;
        }
        return legacyFallbacks[tick % legacyFallbacks.length];
      }

      var sawReviewInteractionSurface = false;
      final seatKeys = <Key>[
        const Key('microtask_seat_btn'),
        const Key('microtask_seat_sb'),
        const Key('microtask_seat_bb'),
        const Key('microtask_seat_utg'),
        const Key('microtask_seat_hj'),
        const Key('microtask_seat_co'),
      ];
      for (var i = 0; i < 260; i++) {
        final queueNow = await ProgressService.getReviewQueueForPackV1(packId);
        if (queueNow.isEmpty) break;
        final hasInteraction =
            find
                .byKey(const Key('microtask_campaign_action_bar'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('microtask_check_cta'))
                .evaluate()
                .isNotEmpty ||
            find
                .byKey(const Key('microtask_continue_cta'))
                .evaluate()
                .isNotEmpty ||
            seatKeys.any((key) => find.byKey(key).evaluate().isNotEmpty);
        if (hasInteraction) {
          sawReviewInteractionSurface = true;
        }

        if (await tapIfVisible(find.byKey(const Key('microtask_continue_cta')))) {
          continue;
        }
        if (await _tapIfEnabledButtonByKeyV1(
          tester,
          const Key('microtask_prelude_continue_cta_v1'),
        )) {
          continue;
        }
        if (await _tapIfEnabledButtonByKeyV1(
          tester,
          const Key('microtask_intro_continue_cta_v1'),
        )) {
          continue;
        }
        if (find.byKey(const Key('microtask_campaign_action_bar')).evaluate().isNotEmpty) {
          await _tapCampaignActionTokenV1(
            tester,
            actionToken: expectedActionToken,
          );
          await tester.pump(const Duration(milliseconds: 90));
          continue;
        }
        final seatFinder =
            _seatFinderFromPromptV1(tester) ?? fallbackSeatFinderForTick(i);
        if (seatFinder.evaluate().isNotEmpty) {
          await tester.tap(seatFinder.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 90));
        }
        await _tapIfEnabledButtonByKeyV1(
          tester,
          const Key('microtask_check_cta'),
        );
        await tester.pump(const Duration(milliseconds: 90));
      }

      final queueAfter = await ProgressService.getReviewQueueForPackV1(packId);
      expect(
        sawReviewInteractionSurface,
        isTrue,
        reason:
            'Non-empty queue must boot a non-empty interactive review session',
      );
      expect(queueAfter, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('review queue back abort returns safely and keeps queue intact', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    const packId = 'world1_spine_campaign_v1';
    final queuedStepIndex = _firstActionableStepIndexForPackV1(packId);
    final queuedStep = pack12(kCampaignPacksV1[packId]!)[queuedStepIndex];
    final expectedActionKind = world1SpineExpectedActionKindV1(queuedStep);
    expect(expectedActionKind, isNotNull);
    final expectedActionToken =
        (queuedStep.allowedActions ?? const <String>[])
            .map((value) => value.trim().toLowerCase())
            .firstWhere(
              (token) =>
                  _actionKindFromAllowedTokenV1(token) == expectedActionKind,
              orElse: () => '',
            );
    expect(expectedActionToken, isNotEmpty);
    final seededQueueJson = jsonEncode(<Map<String, Object>>[
      <String, Object>{'packId': packId, 'stepIndex': queuedStepIndex},
    ]);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
      'review_queue_v1::$packId': seededQueueJson,
    });

    final queueBefore = await ProgressService.getReviewQueueForPackV1(packId);
    expect(queueBefore, isNotEmpty);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                key: const Key('test_open_review_runner_v1'),
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const World1FoundationsMicroTaskRunnerScreen(
                            moduleId: packId,
                            moduleTitle: 'World 1',
                            mode: kWorld1RunnerModeReviewQueue,
                          ),
                    ),
                  );
                },
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const Key('test_open_review_runner_v1')),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 180));
    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsOneWidget);

    var interacted = false;
    Finder fallbackSeatFinderForTick(int tick) {
      final legacyFallbacks = <Finder>[
        find.byKey(const Key('microtask_seat_btn')),
        find.byKey(const Key('microtask_seat_sb')),
        find.byKey(const Key('microtask_seat_bb')),
        find.byKey(const Key('microtask_seat_utg')),
        find.byKey(const Key('microtask_seat_hj')),
        find.byKey(const Key('microtask_seat_co')),
      ];
      final modernFallback = find.byKey(Key('modern_table_seat_${tick % 9}'));
      if (modernFallback.evaluate().isNotEmpty) {
        return modernFallback;
      }
      return legacyFallbacks[tick % legacyFallbacks.length];
    }
    for (var i = 0; i < 180; i++) {
      if (await _tapIfEnabledButtonByKeyV1(
        tester,
        const Key('microtask_prelude_continue_cta_v1'),
      )) {
        interacted = true;
        continue;
      }
      if (await _tapIfEnabledButtonByKeyV1(
        tester,
        const Key('microtask_intro_continue_cta_v1'),
      )) {
        interacted = true;
        continue;
      }
      if (await _tapIfEnabledButtonByKeyV1(
        tester,
        const Key('microtask_continue_cta'),
      )) {
        interacted = true;
        continue;
      }
      if (find.byKey(const Key('microtask_campaign_action_bar')).evaluate().isNotEmpty) {
        await _tapCampaignActionTokenV1(
          tester,
          actionToken: expectedActionToken,
        );
        await tester.pump(const Duration(milliseconds: 80));
        interacted = true;
        break;
      }
        final seatFinder =
          _seatFinderFromPromptV1(tester) ?? fallbackSeatFinderForTick(i);
      if (seatFinder.evaluate().isNotEmpty) {
        await tester.tap(seatFinder.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 80));
        interacted = true;
        break;
      }
      if (await _tapIfEnabledButtonByKeyV1(
        tester,
        const Key('microtask_check_cta'),
      )) {
        interacted = true;
        break;
      }
      await tester.pump(const Duration(milliseconds: 60));
    }
    expect(interacted, isTrue, reason: 'Review session should be interactive');

    final backButton = find.byTooltip('Back');
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 180));
    } else {
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(milliseconds: 180));
    }

    expect(find.byType(World1FoundationsMicroTaskRunnerScreen), findsNothing);
    expect(find.byKey(const Key('test_open_review_runner_v1')), findsOneWidget);

    final queueAfter = await ProgressService.getReviewQueueForPackV1(packId);
    expect(queueAfter, isNotEmpty);
    expect(
      queueAfter.first.stepIndex,
      queueBefore.first.stepIndex,
      reason: 'Abort/back must not corrupt pending review queue state',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'campaign non-demo board reveal never exposes all 5 cards before river step',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });
      await ProgressService.setSpineNextHandIndexV1(0);

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final feltCaption = find.byKey(
        const Key('microtask_felt_caption_container_v1'),
      );
      final feltCaptionText = find.byKey(const Key('microtask_step_prompt'));
      final topSeatLabel = find.byKey(
        const Key('microtask_seat_display_utg_v1'),
      );
      final blindMarkers = find.byWidgetPredicate((widget) {
        final key = widget.key;
        if (key is! ValueKey<String>) {
          return false;
        }
        return key.value.startsWith('microtask_blind_sb_display_') ||
            key.value.startsWith('microtask_blind_bb_display_');
      });
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_campaign_action_bar')),
        maxTicks: 240,
      );
      await _pumpUntil(tester, boardStrip, maxTicks: 120);
      await _pumpUntil(tester, feltCaptionText, maxTicks: 120);
      await _pumpUntil(tester, blindMarkers, maxTicks: 120);

      if (boardStrip.evaluate().isEmpty) {
        expect(tester.takeException(), isNull);
        return;
      }

      final visibleBoardCards = find.descendant(
        of: boardStrip,
        matching: find.byType(PlayingCardWidget),
      );
      expect(feltCaptionText, findsOneWidget);
      final captionSurface = feltCaption.evaluate().isNotEmpty
          ? feltCaption
          : feltCaptionText;
      final usesFeltCaption = feltCaption.evaluate().isNotEmpty;
      final captionRect = tester.getRect(captionSurface);
      final boardRect = tester.getRect(boardStrip);
      if (usesFeltCaption) {
        expect(
          boardRect.top >= captionRect.bottom,
          isTrue,
          reason: 'Board strip must stay below felt instruction caption',
        );
      }
      expect(
        captionRect.overlaps(boardRect),
        isFalse,
        reason: 'Caption and board strip must not overlap',
      );
      if (topSeatLabel.evaluate().isNotEmpty) {
        final topSeatRect = tester.getRect(topSeatLabel);
        expect(
          captionRect.overlaps(topSeatRect),
          isFalse,
          reason: 'Caption must not overlap top seat label',
        );
        expect(
          boardRect.overlaps(topSeatRect),
          isFalse,
          reason: 'Board strip must not overlap top seat label',
        );
      }
      for (final markerElement in blindMarkers.evaluate()) {
        final markerRect = tester.getRect(find.byWidget(markerElement.widget));
        expect(
          captionRect.overlaps(markerRect),
          isFalse,
          reason: 'Caption must not overlap blind marker',
        );
        expect(
          boardRect.overlaps(markerRect),
          isFalse,
          reason: 'Board strip must not overlap blind marker',
        );
      }
      expect(visibleBoardCards.evaluate().length < 5, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'campaign felt caption long-text variants stay overflow-safe and non-overlapping',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });
      await ProgressService.setSpineNextHandIndexV1(0);
      const packIdV1 = 'world1_spine_campaign_v1';
      final firstActionableIndex = _firstActionableStepIndexForPackV1(packIdV1);
      final pack = kCampaignPacksV1[packIdV1];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      var boardActionStartIndex = firstActionableIndex;
      for (var i = 0; i < steps.length; i++) {
        final step = steps[i];
        final boardCount = step.boardCards?.length ?? 0;
        final actions = (step.allowedActions ?? const <String>[])
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty);
        if (boardCount >= 3 &&
            world1SpineExpectedActionKindV1(step) != null &&
            actions.isNotEmpty) {
          boardActionStartIndex = i;
          break;
        }
      }

      const longCaptionV1 =
          'Task: flop spot with deep stack pressure and multiple legal responses. '
          'Use pot, toCall, and board texture to pick the highest EV action '
          'without sacrificing range protection or price discipline.';
      final variants =
          <
            ({
              String name,
              String mode,
              bool forceHandLoopSurface,
              int? seatMaxPlayers,
            })
          >[
            (
              name: 'spine_baseline_6max',
              mode: kWorld1RunnerModeCampaignSpine,
              forceHandLoopSurface: false,
              seatMaxPlayers: 6,
            ),
            (
              name: 'spine_baseline_9max',
              mode: kWorld1RunnerModeCampaignSpine,
              forceHandLoopSurface: false,
              seatMaxPlayers: 9,
            ),
            (
              name: 'review_queue_6max_forced_surface',
              mode: kWorld1RunnerModeReviewQueue,
              forceHandLoopSurface: true,
              seatMaxPlayers: 6,
            ),
            (
              name: 'review_queue_9max_forced_surface',
              mode: kWorld1RunnerModeReviewQueue,
              forceHandLoopSurface: true,
              seatMaxPlayers: 9,
            ),
          ];
      final textScales = <double>[1.0, 1.15];
      final deviceSizes = <({String name, Size size})>[
        (name: 'size_s_375x812', size: const Size(375, 812)),
        (name: 'size_l_390x844', size: const Size(390, 844)),
      ];
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1.0;

      for (final device in deviceSizes) {
        tester.view.physicalSize = device.size;
        for (final variant in variants) {
          for (final textScale in textScales) {
            final variantName =
                '${device.name}_${variant.name}_scale_$textScale';
            final originalOnError = FlutterError.onError;
            final flutterErrors = <FlutterErrorDetails>[];
            FlutterError.onError = (details) {
              flutterErrors.add(details);
              originalOnError?.call(details);
            };
            try {
              if (variant.mode == kWorld1RunnerModeCampaignSpine) {
                await ProgressService.setSpineNextHandIndexV1(
                  boardActionStartIndex,
                );
              }
              await tester.pumpWidget(
                MaterialApp(
                  home: MediaQuery(
                    data: MediaQueryData(
                      textScaler: TextScaler.linear(textScale),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey<String>('caption-long-$variantName'),
                      child: World1FoundationsMicroTaskRunnerScreen(
                        moduleId: packIdV1,
                        moduleTitle: 'World 1',
                        mode: variant.mode,
                        startHandIndex: boardActionStartIndex,
                        debugSeatLayoutMaxPlayersV1: variant.seatMaxPlayers,
                        debugHandLoopFeltCaptionOverrideV1: longCaptionV1,
                        debugForceHandLoopSurfaceV1:
                            variant.forceHandLoopSurface,
                      ),
                    ),
                  ),
                ),
              );
              await tester.pump();
              final actionBar = find.byKey(
                const Key('microtask_campaign_action_bar'),
              );
              await _pumpUntil(tester, actionBar, maxTicks: 240);
              final boardStrip = find.byKey(
                const Key('microtask_engine_board_strip'),
              );
              final feltCaption = find.byKey(
                const Key('microtask_felt_caption_container_v1'),
              );
              final feltCaptionTextAny = find.byKey(
                const Key('microtask_step_prompt'),
              );
              final potValue = find.byKey(
                const Key('microtask_pot_value_v1'),
                skipOffstage: false,
              );
              final visiblePotValue = find.byKey(
                const Key('microtask_pot_value_v1'),
              );
              final topSeatLabel = find.byKey(
                const Key('microtask_seat_display_utg_v1'),
              );
              final blindMarkers = find.byWidgetPredicate((widget) {
                final key = widget.key;
                if (key is! ValueKey<String>) {
                  return false;
                }
                return key.value.startsWith('microtask_blind_sb_display_') ||
                    key.value.startsWith('microtask_blind_bb_display_');
              });

              await _pumpUntil(tester, actionBar, maxTicks: 240);
              await _pumpUntil(tester, boardStrip, maxTicks: 120);
              await _pumpUntil(tester, feltCaption, maxTicks: 120);
              await _pumpUntil(tester, potValue, maxTicks: 120);
              await _pumpUntil(tester, blindMarkers, maxTicks: 120);
              await tester.pump(const Duration(milliseconds: 120));

              expect(
                actionBar,
                findsOneWidget,
                reason: '[$variantName] Action bar must be visible',
              );
              expect(
                boardStrip,
                findsOneWidget,
                reason: '[$variantName] Board strip must be visible',
              );
              final captionTextFinder = feltCaption.evaluate().isNotEmpty
                  ? find.descendant(
                      of: feltCaption,
                      matching: find.byType(Text),
                    )
                  : feltCaptionTextAny;
              expect(
                captionTextFinder,
                findsWidgets,
                reason: '[$variantName] Caption text must be present',
              );
              expect(
                potValue,
                findsOneWidget,
                reason: '[$variantName] Pot value contract key must be present',
              );

              final captionSurface = feltCaption.evaluate().isNotEmpty
                  ? feltCaption
                  : find.byWidget(captionTextFinder.evaluate().first.widget);
              final captionRect = tester.getRect(captionSurface);
              final captionTextRect = tester.getRect(captionTextFinder.first);
              final boardRect = tester.getRect(boardStrip);
              const minInsetPx = 4.0;
              final screenWidth = device.size.width;
              final screenHeight = device.size.height;

              void expectRectWithinScreenInset(Rect rect, String elementLabel) {
                expect(
                  rect.left >= minInsetPx,
                  isTrue,
                  reason:
                      '[$variantName] $elementLabel left inset violated: '
                      'left=${rect.left}, min=$minInsetPx',
                );
                expect(
                  rect.top >= minInsetPx,
                  isTrue,
                  reason:
                      '[$variantName] $elementLabel top inset violated: '
                      'top=${rect.top}, min=$minInsetPx',
                );
                expect(
                  rect.right <= (screenWidth - minInsetPx),
                  isTrue,
                  reason:
                      '[$variantName] $elementLabel right inset violated: '
                      'right=${rect.right}, max=${screenWidth - minInsetPx}',
                );
                expect(
                  rect.bottom <= (screenHeight - minInsetPx),
                  isTrue,
                  reason:
                      '[$variantName] $elementLabel bottom inset violated: '
                      'bottom=${rect.bottom}, max=${screenHeight - minInsetPx}',
                );
              }

              expect(captionRect.height > 0, isTrue);
              expect(captionRect.width > 0, isTrue);
              expect(captionTextRect.top >= captionRect.top, isTrue);
              expect(captionTextRect.bottom <= captionRect.bottom, isTrue);
              expectRectWithinScreenInset(captionRect, 'caption');
              expectRectWithinScreenInset(boardRect, 'board');
              expect(
                captionRect.overlaps(boardRect),
                isFalse,
                reason:
                    '[$variantName] Caption must not overlap board '
                    '(caption=$captionRect, board=$boardRect)',
              );
              if (visiblePotValue.evaluate().isNotEmpty) {
                final potRect = tester.getRect(visiblePotValue);
                expectRectWithinScreenInset(potRect, 'pot_value');
                expect(
                  captionRect.overlaps(potRect),
                  isFalse,
                  reason: '[$variantName] Caption must not overlap pot value',
                );
                expect(
                  boardRect.overlaps(potRect),
                  isFalse,
                  reason: '[$variantName] Board must not overlap pot value',
                );
              }
              if (topSeatLabel.evaluate().isNotEmpty) {
                final topSeatRect = tester.getRect(topSeatLabel);
                expectRectWithinScreenInset(topSeatRect, 'seat_utg');
                expect(
                  captionRect.overlaps(topSeatRect),
                  isFalse,
                  reason:
                      '[$variantName] Caption must not overlap UTG label '
                      '(caption=$captionRect, utg=$topSeatRect)',
                );
                if (visiblePotValue.evaluate().isNotEmpty) {
                  final potRect = tester.getRect(visiblePotValue);
                  expect(
                    potRect.overlaps(topSeatRect),
                    isFalse,
                    reason:
                        '[$variantName] Pot value must not overlap UTG label',
                  );
                }
              }
              for (final markerElement in blindMarkers.evaluate()) {
                final markerKey = markerElement.widget.key;
                final markerRect = tester.getRect(
                  find.byWidget(markerElement.widget),
                );
                expectRectWithinScreenInset(
                  markerRect,
                  'blind_marker_$markerKey',
                );
                expect(
                  captionRect.overlaps(markerRect),
                  isFalse,
                  reason:
                      '[$variantName] Caption must not overlap blind marker '
                      '(marker=$markerKey, caption=$captionRect, markerRect=$markerRect)',
                );
                if (visiblePotValue.evaluate().isNotEmpty) {
                  final potRect = tester.getRect(visiblePotValue);
                  expect(
                    potRect.overlaps(markerRect),
                    isFalse,
                    reason:
                        '[$variantName] Pot value must not overlap blind marker',
                  );
                }
              }
              final overflowErrors = flutterErrors.where((details) {
                final text = details.exceptionAsString();
                return text.contains('A RenderFlex overflowed') ||
                    text.contains('A RenderParagraph overflowed') ||
                    text.contains('overflowed by');
              });
              expect(
                overflowErrors,
                isEmpty,
                reason: '[$variantName] No render overflow errors expected',
              );
              expect(tester.takeException(), isNull);
            } finally {
              FlutterError.onError = originalOnError;
            }
          }
        }
      }
    },
  );
  testWidgets(
    'world1 spine pot value keeps invariant baseline over legacy step hints',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });
      await ProgressService.setSpineNextHandIndexV1(0);

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final potValue = find.byKey(
        const Key('microtask_pot_value_v1'),
        skipOffstage: false,
      );
      final handIndexFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );

      await _pumpUntil(tester, actionBar, maxTicks: 240);
      await _pumpUntil(tester, potValue, maxTicks: 240);
      await _pumpUntil(tester, handIndexFinder, maxTicks: 240);

      final handIndexText =
          (tester.widget<Text>(handIndexFinder.first).data ?? '').trim();
      final handIndexMatch = RegExp(r'^i=(\d+)$').firstMatch(handIndexText);
      final handIndex = int.tryParse(handIndexMatch?.group(1) ?? '');
      expect(handIndex, isNotNull);

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final step = pack12(pack!)[handIndex!];
      final expectedPot = step.pot ?? 0;
      final expectedToCallHint = step.toCall ?? 0;

      final potText = (tester.widget<Text>(potValue.first).data ?? '').trim();
      final parsedPot = int.tryParse(potText);
      expect(parsedPot, isNotNull, reason: 'Pot text must be an integer');
      expect(
        parsedPot! >= expectedPot,
        isTrue,
        reason:
            'Displayed pot must stay >= spine step.pot hint for index=$handIndex text="$potText"',
      );
      expect(
        parsedPot >= expectedToCallHint,
        isTrue,
        reason:
            'Displayed pot must stay >= spine step.toCall hint for index=$handIndex text="$potText"',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 spine street reveal coherence keeps board counts 0/3/4/5',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final preflopIndex = steps.indexWhere((step) => step.street == null);
      final flopIndex = steps.indexWhere(
        (step) => step.street == MicroTaskStreetV1.flop,
      );
      final turnIndex = steps.indexWhere(
        (step) => step.street == MicroTaskStreetV1.turn,
      );
      final riverIndex = steps.indexWhere(
        (step) => step.street == MicroTaskStreetV1.river,
      );
      expect(preflopIndex, greaterThanOrEqualTo(0));
      expect(flopIndex, greaterThanOrEqualTo(0));
      expect(turnIndex, greaterThanOrEqualTo(0));
      expect(riverIndex, greaterThanOrEqualTo(0));

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
      final stepIndexTextFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      await _pumpUntil(tester, actionBar, maxTicks: 320);
      await _pumpUntil(tester, boardStrip, maxTicks: 320);

      int currentStepIndex() {
        if (stepIndexTextFinder.evaluate().isEmpty) return -1;
        final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      int visibleBoardCount() {
        return find
            .descendant(
              of: boardStrip,
              matching: find.byType(PlayingCardWidget),
            )
            .evaluate()
            .length;
      }

      String currentPromptText() {
        for (final element in stepPrompt.evaluate()) {
          final widget = element.widget;
          if (widget is Text) {
            final text = (widget.data ?? '').trim();
            if (text.isNotEmpty) {
              return text;
            }
          }
        }
        return '';
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
          await _tapFirstEnabledCampaignAction(tester);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      Future<void> settleAtStep(int targetIndex) async {
        for (var i = 0; i < 420; i++) {
          if (currentStepIndex() == targetIndex &&
              actionBar.evaluate().isNotEmpty &&
              checkCta.evaluate().isNotEmpty &&
              outcomeSurface.evaluate().isEmpty) {
            return;
          }
          await progressOneStep();
        }
        fail('Failed to settle on target spine step index=$targetIndex');
      }

      await settleAtStep(preflopIndex);
      expect(visibleBoardCount(), 0);

      await settleAtStep(flopIndex);
      expect(visibleBoardCount(), 3);
      expect(currentPromptText(), isNotEmpty);

      await settleAtStep(turnIndex);
      expect(visibleBoardCount(), 4);
      expect(currentPromptText(), isNotEmpty);

      await settleAtStep(riverIndex);
      expect(visibleBoardCount(), 5);
      expect(currentPromptText(), isNotEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 spine flop action decision renders exactly 3 board cards',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      final flopActionIndex = steps.indexWhere(
        (step) =>
            step.street == MicroTaskStreetV1.flop &&
            (step.allowedActions?.isNotEmpty ?? false),
      );
      expect(flopActionIndex, greaterThanOrEqualTo(0));

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final handIndexFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );
      await _pumpUntil(tester, actionBar, maxTicks: 320);

      int currentStepIndex() {
        if (handIndexFinder.evaluate().isEmpty) return -1;
        final label = tester.widget<Text>(handIndexFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(label.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (actionBar.evaluate().isNotEmpty) {
          await _tapFirstEnabledCampaignAction(tester);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      for (var i = 0; i < 420; i++) {
        if (currentStepIndex() == flopActionIndex &&
            actionBar.evaluate().isNotEmpty &&
            outcomeSurface.evaluate().isEmpty) {
          break;
        }
        await progressOneStep();
      }

      expect(currentStepIndex(), equals(flopActionIndex));
      expect(boardStrip, findsOneWidget);
      final renderedBoardCards = find
          .descendant(of: boardStrip, matching: find.byType(PlayingCardWidget))
          .evaluate()
          .length;
      expect(renderedBoardCards, equals(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 spine multi-street progression advances exactly one step per commit',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });
      await ProgressService.setSpineNextHandIndexV1(0);

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
      expect(pack, isNotNull);
      final steps = pack12(pack!);
      int sequenceStartIndex = -1;
      for (var start = 0; start <= steps.length - 4; start++) {
        final window = steps.sublist(start, start + 4);
        final allActionable = window.every((step) {
          final expected = world1SpineExpectedActionKindV1(step);
          final actions = step.allowedActions ?? const <String>[];
          return expected != null && actions.isNotEmpty;
        });
        if (!allActionable) continue;
        final streetKinds = window
            .map((step) => step.street?.name ?? 'preflop')
            .toSet();
        if (streetKinds.length >= 2) {
          sequenceStartIndex = start;
          break;
        }
      }
      expect(
        sequenceStartIndex,
        greaterThanOrEqualTo(0),
        reason:
            'Need a deterministic 4-step actionable sequence spanning multiple streets.',
      );

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
      final handIndexFinder = find.byKey(
        const Key('spine_contract_hand_index'),
        skipOffstage: false,
      );

      int currentStepIndex() {
        if (handIndexFinder.evaluate().isEmpty) return -1;
        final label = tester.widget<Text>(handIndexFinder.first).data ?? '';
        final match = RegExp(r'^i=(\d+)$').firstMatch(label.trim());
        return int.tryParse(match?.group(1) ?? '') ?? -1;
      }

      int renderedBoardCount() {
        if (boardStrip.evaluate().isEmpty) return 0;
        return find
            .descendant(
              of: boardStrip,
              matching: find.byType(PlayingCardWidget),
            )
            .evaluate()
            .length;
      }

      int expectedBoardCountForStreet(MicroTaskStreetV1? street) {
        return switch (street) {
          null => 0,
          MicroTaskStreetV1.flop => 3,
          MicroTaskStreetV1.turn => 4,
          MicroTaskStreetV1.river => 5,
        };
      }

      Future<void> settleAtActionableStep(int targetIndex) async {
        for (var i = 0; i < 480; i++) {
          final currentIndex = currentStepIndex();
          if (currentIndex > targetIndex) {
            fail(
              'Unexpected step skip while settling: current=$currentIndex target=$targetIndex',
            );
          }
          if (currentIndex == targetIndex &&
              actionBar.evaluate().isNotEmpty &&
              checkCta.evaluate().isNotEmpty &&
              outcomeSurface.evaluate().isEmpty) {
            return;
          }
          if (await _tapIfEnabledButtonByKeyV1(
            tester,
            const Key('microtask_prelude_continue_cta_v1'),
          )) {
            continue;
          }
          if (find
              .byKey(const Key('microtask_intro_sequence_v1'))
              .evaluate()
              .isNotEmpty) {
            await _completeIntroSequenceV1(tester);
            continue;
          }
          if (await _tapIfEnabledButtonByKeyV1(
            tester,
            const Key('microtask_intro_continue_cta_v1'),
          )) {
            continue;
          }
          if (continueCta.evaluate().isNotEmpty) {
            await tester.tap(continueCta.first, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 140));
            continue;
          }
          if (checkCta.evaluate().isNotEmpty &&
              actionBar.evaluate().isNotEmpty &&
              currentIndex < targetIndex) {
            await _tapExpectedCampaignActionForPackV1(
              tester,
              packId: 'world1_spine_campaign_v1',
            );
            await tester.pump(const Duration(milliseconds: 140));
            continue;
          }
          await tester.pump(const Duration(milliseconds: 40));
        }
        fail('Failed to settle on actionable step index=$targetIndex');
      }

      await settleAtActionableStep(sequenceStartIndex);

      for (var offset = 0; offset <= 3; offset++) {
        final expectedStepIndex = sequenceStartIndex + offset;
        final expectedStep = steps[expectedStepIndex];
        expect(
          currentStepIndex(),
          expectedStepIndex,
          reason: 'Runner must stay aligned with sequence index',
        );
        expect(
          renderedBoardCount(),
          expectedBoardCountForStreet(expectedStep.street),
          reason:
              'Rendered board count must match scenario street at index=$expectedStepIndex',
        );
        if (expectedBoardCountForStreet(expectedStep.street) > 0) {
          expect(
            boardStrip,
            findsOneWidget,
            reason:
                'Board strip must be visible on actionable ${expectedStep.street?.name ?? 'preflop'} step index=$expectedStepIndex',
          );
        }

        await tester.pump(const Duration(milliseconds: 320));
        expect(
          currentStepIndex(),
          expectedStepIndex,
          reason: 'Step must not auto-advance without explicit user input',
        );

        if (offset == 3) {
          continue;
        }

        await _tapExpectedCampaignActionForPackV1(
          tester,
          packId: 'world1_spine_campaign_v1',
        );
        await tester.pump(const Duration(milliseconds: 140));
        await settleAtActionableStep(expectedStepIndex + 1);
        expect(
          currentStepIndex(),
          expectedStepIndex + 1,
          reason: 'Each expected-action commit must advance exactly one step',
        );
      }

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 preflop action-state truth invariants hold for pot/currentBet/toCall',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      await _pumpUntil(tester, actionBar, maxTicks: 320);

      Finder labelInActionBar(String label) =>
          find.descendant(of: actionBar, matching: find.text(label));

      bool preflopFacingBetVisible() =>
          labelInActionBar('FOLD').evaluate().isNotEmpty &&
          labelInActionBar('CALL').evaluate().isNotEmpty &&
          labelInActionBar('RAISE TO').evaluate().isNotEmpty &&
          labelInActionBar('BET').evaluate().isEmpty &&
          labelInActionBar('CHECK').evaluate().isEmpty;

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
          await _tapFirstEnabledCampaignAction(tester);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      for (var i = 0; i < 420; i++) {
        if (preflopFacingBetVisible() &&
            actionBar.evaluate().isNotEmpty &&
            checkCta.evaluate().isNotEmpty &&
            outcomeSurface.evaluate().isEmpty) {
          break;
        }
        await progressOneStep();
      }
      expect(preflopFacingBetVisible(), isTrue);

      await _openRunnerDetailsSheetV1(tester);

      final potTotal = _intFromDetailsLineV1(
        _detailsLineTextByKeyV1(
          tester,
          'details_debug_action_state_pot_total_v1',
        ),
        'actionState.potTotal:',
      );
      final sumCommittedFromLine = _intFromDetailsLineV1(
        _detailsLineTextByKeyV1(
          tester,
          'details_debug_action_state_sum_committed_v1',
        ),
        'actionState.sumCommitted:',
      );
      final currentBet = _intFromDetailsLineV1(
        _detailsLineTextByKeyV1(
          tester,
          'details_debug_action_state_current_bet_v1',
        ),
        'actionState.currentBet:',
      );
      final actingSeatToCall = _intFromDetailsLineV1(
        _detailsLineTextByKeyV1(
          tester,
          'details_debug_action_state_to_call_v1',
        ),
        'actionState.toCall(acting):',
      );
      final actingSeatId = _detailsLineTextByKeyV1(
        tester,
        'details_debug_acting_seat_v1',
      ).split(':').last.trim();
      final seatQuickRows = _parseSeatQuickRowsV1(
        _detailsLineTextByKeyV1(tester, 'details_debug_seat_quick_v1'),
      );

      final committedBySeatId = <String, int>{
        for (final row in seatQuickRows) row.seatId: row.committed,
      };
      final sumCommittedFromMap = committedBySeatId.values.fold(
        0,
        (sum, value) => sum + value,
      );
      final maxCommitted = committedBySeatId.values.fold<int>(
        0,
        (best, value) => value > best ? value : best,
      );

      expect(potTotal, equals(sumCommittedFromLine));
      expect(potTotal, equals(sumCommittedFromMap));
      expect(currentBet, equals(maxCommitted));

      for (final entry in committedBySeatId.entries) {
        final derivedToCall = math.max(0, currentBet - entry.value);
        expect(derivedToCall >= 0, isTrue);
      }
      final actingCommitted = committedBySeatId[actingSeatId] ?? 0;
      final actingDerivedToCall = math.max(0, currentBet - actingCommitted);
      expect(actingSeatToCall, equals(actingDerivedToCall));

      await _closeRunnerDetailsSheetV1(tester);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('world1 spine prompt is informative and varies across streets', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'world1_spine_campaign_v1',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
    await tester.pump();

    final pack = kCampaignPacksV1['world1_spine_campaign_v1'];
    expect(pack, isNotNull);
    final steps = pack12(pack!);
    final flopIndex = steps.indexWhere(
      (step) => step.street == MicroTaskStreetV1.flop,
    );
    final riverIndex = steps.indexWhere(
      (step) => step.street == MicroTaskStreetV1.river,
    );
    expect(flopIndex, greaterThanOrEqualTo(0));
    expect(riverIndex, greaterThanOrEqualTo(0));
    expect(riverIndex > flopIndex, isTrue);

    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    final checkCta = find.byKey(const Key('microtask_check_cta'));
    final continueCta = find.byKey(const Key('microtask_continue_cta'));
    final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
    final stepPrompt = find.byKey(const Key('microtask_step_prompt'));
    final stepIndexTextFinder = find.byKey(
      const Key('spine_contract_hand_index'),
      skipOffstage: false,
    );
    await _pumpUntil(tester, actionBar, maxTicks: 280);

    int currentStepIndex() {
      if (stepIndexTextFinder.evaluate().isEmpty) return -1;
      final value = tester.widget<Text>(stepIndexTextFinder.first).data ?? '';
      final match = RegExp(r'^i=(\d+)$').firstMatch(value.trim());
      return int.tryParse(match?.group(1) ?? '') ?? -1;
    }

    Future<void> progressOneStep() async {
      if (continueCta.evaluate().isNotEmpty) {
        await tester.tap(continueCta.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 140));
        return;
      }
      if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
        await _tapFirstEnabledCampaignAction(tester);
        await tester.pump(const Duration(milliseconds: 140));
        return;
      }
      await tester.pump(const Duration(milliseconds: 30));
    }

    Future<void> settleAtStep(int targetIndex) async {
      for (var i = 0; i < 360; i++) {
        if (currentStepIndex() == targetIndex &&
            actionBar.evaluate().isNotEmpty &&
            checkCta.evaluate().isNotEmpty &&
            outcomeSurface.evaluate().isEmpty) {
          return;
        }
        await progressOneStep();
      }
      fail('Failed to settle on target spine step index=$targetIndex');
    }

    String currentPromptText() {
      expect(stepPrompt, findsWidgets);
      for (final element in stepPrompt.evaluate()) {
        final widget = element.widget;
        if (widget is Text) {
          final text = (widget.data ?? '').trim();
          if (text.isNotEmpty) {
            return text;
          }
        }
      }
      return '';
    }

    await settleAtStep(flopIndex);
    final flopPrompt = currentPromptText();

    await settleAtStep(riverIndex);
    final riverPrompt = currentPromptText();

    expect(flopPrompt, isNotEmpty);
    expect(riverPrompt, isNotEmpty);
    expect(flopPrompt, startsWith('Practice: Flop decision.'));
    expect(riverPrompt, startsWith('Practice: River decision.'));
    expect(flopPrompt, contains('Choose the best action.'));
    expect(riverPrompt, contains('Choose the best action.'));
    expect(flopPrompt.contains('Focus:'), isFalse);
    expect(riverPrompt.contains('Focus:'), isFalse);
  });

  testWidgets(
    'world1 hand-loop keeps seat taps disabled to avoid seat/action mode mixing',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_campaign_action_bar')),
        maxTicks: 280,
      );

      final selectedSeatValue = find.byKey(
        const Key('microtask_selected_seat_value'),
        skipOffstage: false,
      );
      expect(selectedSeatValue, findsOneWidget);
      expect(tester.widget<Text>(selectedSeatValue).data, isEmpty);

      await tester.tap(find.byKey(const Key('microtask_seat_btn')).first);
      await tester.pump(const Duration(milliseconds: 120));

      expect(
        tester.widget<Text>(selectedSeatValue).data,
        isEmpty,
        reason:
            'Action steps must ignore seat taps to keep one deterministic interaction contract.',
      );
    },
  );

  testWidgets('world1 preflop blinds stay in-hand (sb/bb not OUT)', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'world1_spine_campaign_v1',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
    await tester.pump();

    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    final checkCta = find.byKey(const Key('microtask_check_cta'));
    final continueCta = find.byKey(const Key('microtask_continue_cta'));
    final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
    await _pumpUntil(tester, actionBar, maxTicks: 320);

    Future<void> progressOneStep() async {
      if (continueCta.evaluate().isNotEmpty) {
        await tester.tap(continueCta.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 140));
        return;
      }
      if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
        await _tapFirstEnabledCampaignAction(tester);
        await tester.pump(const Duration(milliseconds: 140));
        return;
      }
      await tester.pump(const Duration(milliseconds: 24));
    }

    Finder labelInActionBar(String label) =>
        find.descendant(of: actionBar, matching: find.text(label));

    bool callFoldRaiseVisible() =>
        labelInActionBar('FOLD').evaluate().isNotEmpty &&
        labelInActionBar('CALL').evaluate().isNotEmpty &&
        labelInActionBar('RAISE TO').evaluate().isNotEmpty &&
        labelInActionBar('CHECK').evaluate().isEmpty;

    for (var i = 0; i < 420; i++) {
      if (callFoldRaiseVisible() &&
          actionBar.evaluate().isNotEmpty &&
          checkCta.evaluate().isNotEmpty &&
          outcomeSurface.evaluate().isEmpty) {
        break;
      }
      await progressOneStep();
    }

    expect(callFoldRaiseVisible(), isTrue);

    expect(
      find.byKey(const Key('microtask_seat_state_badge_out_sb')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('microtask_seat_state_badge_out_bb')),
      findsNothing,
    );
    for (final seatId in const <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb']) {
      final hasFoldBadge = find
          .byKey(Key('microtask_seat_state_badge_folded_$seatId'))
          .evaluate()
          .isNotEmpty;
      final hasOutBadge = find
          .byKey(Key('microtask_seat_state_badge_out_$seatId'))
          .evaluate()
          .isNotEmpty;
      expect(
        hasFoldBadge && hasOutBadge,
        isFalse,
        reason: 'Seat $seatId cannot be folded and out-of-hand at once.',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'world1 spine action bar renders exact allowedActions set deterministically',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      await _pumpUntil(tester, actionBar, maxTicks: 320);

      Future<void> progressOneStep() async {
        if (continueCta.evaluate().isNotEmpty) {
          await tester.tap(continueCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        if (checkCta.evaluate().isNotEmpty && actionBar.evaluate().isNotEmpty) {
          await _tapFirstEnabledCampaignAction(tester);
          await tester.pump(const Duration(milliseconds: 140));
          return;
        }
        await tester.pump(const Duration(milliseconds: 24));
      }

      Finder labelInActionBar(String label) =>
          find.descendant(of: actionBar, matching: find.text(label));

      bool callFoldRaiseVisible() =>
          labelInActionBar('FOLD').evaluate().isNotEmpty &&
          labelInActionBar('CALL').evaluate().isNotEmpty &&
          labelInActionBar('RAISE TO').evaluate().isNotEmpty &&
          labelInActionBar('CHECK').evaluate().isEmpty;

      Future<void> settleForActionSet(bool Function() predicate) async {
        for (var i = 0; i < 420; i++) {
          if (predicate() &&
              actionBar.evaluate().isNotEmpty &&
              checkCta.evaluate().isNotEmpty &&
              outcomeSurface.evaluate().isEmpty) {
            return;
          }
          await progressOneStep();
        }
        fail('Failed to settle on target action set');
      }

      await settleForActionSet(callFoldRaiseVisible);
      expect(labelInActionBar('FOLD'), findsOneWidget);
      expect(labelInActionBar('CALL'), findsOneWidget);
      expect(labelInActionBar('RAISE TO'), findsOneWidget);
      expect(labelInActionBar('BET'), findsNothing);
      expect(labelInActionBar('CHECK'), findsNothing);
      final bbSuffixTexts = tester
          .widgetList<Text>(
            find.descendant(of: actionBar, matching: find.byType(Text)),
          )
          .map((widget) => (widget.data ?? '').trim())
          .where((text) => text.isNotEmpty && text.endsWith(' BB'))
          .toList(growable: false);
      expect(bbSuffixTexts, unorderedEquals(const <String>['3 BB', '6 BB']));
      expect(
        bbSuffixTexts.every((text) => RegExp(r'^\d+(\.5)? BB$').hasMatch(text)),
        isTrue,
        reason:
            'CALL and RAISE TO suffixes must render deterministic BB format.',
      );
    },
  );

  testWidgets(
    'coach layer shows one mode at a time with no competing primary CTA',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      dynamic state() =>
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen));

      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_table_canvas')),
        maxTicks: 240,
      );
      expect(
        <String>['intro', 'action'].contains(state().debugCoachModeNameV1()),
        isTrue,
      );
      if (state().debugCoachModeNameV1() == 'intro') {
        final tableInstruction = find.byKey(
          const Key('microtask_seat_quiz_table_instruction_v1'),
        );
        final headerInstruction = find.byKey(
          const Key('microtask_seat_quiz_header_instruction_v1'),
        );
        expect(
          tableInstruction.evaluate().isNotEmpty ||
              headerInstruction.evaluate().isNotEmpty,
          isTrue,
        );
        expect(find.textContaining('Task:'), findsNothing);
      } else {
        expect(
          find.byKey(const Key('microtask_felt_caption_container_v1')),
          findsOneWidget,
        );
      }
      expect(find.byKey(const Key('microtask_coach_strip_v1')), findsNothing);
      expect(find.text('Use the table prompt, then confirm.'), findsNothing);
      expect(find.byKey(const Key('microtask_continue_cta')), findsNothing);

      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      if (preludeContinue.evaluate().isNotEmpty) {
        await tester.tap(preludeContinue, warnIfMissed: false);
        await tester.pump();
        await _completeIntroSequenceV1(tester);
      }
      final introContinue = find.byKey(
        const Key('microtask_intro_continue_cta_v1'),
      );
      if (introContinue.evaluate().isNotEmpty) {
        await tester.tap(introContinue, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
      }

      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_campaign_action_bar')),
        maxTicks: 240,
      );
      expect(
        <String>['action', 'demo'].contains(state().debugCoachModeNameV1()),
        isTrue,
      );
      expect(
        find.byKey(const Key('microtask_felt_caption_container_v1')),
        findsOneWidget,
      );
      expect(find.textContaining('Choose the best action.'), findsWidgets);
      expect(find.byKey(const Key('microtask_coach_strip_v1')), findsNothing);
      expect(
        find.byKey(const Key('microtask_campaign_action_bar')),
        findsOneWidget,
      );
      expect(find.textContaining('toCall', findRichText: true), findsNothing);
      expect(find.text('Select a seat.'), findsNothing);
      expect(find.byKey(const Key('microtask_continue_cta')), findsNothing);

      await _tapFirstEnabledCampaignAction(tester);
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_continue_cta')),
        maxTicks: 240,
      );
      expect(state().debugCoachModeNameV1(), 'outcome');
      expect(find.byKey(const Key('microtask_coach_strip_v1')), findsOneWidget);
      expect(find.byKey(const Key('microtask_continue_cta')), findsOneWidget);
      expect(
        find.byKey(const Key('microtask_campaign_action_bar')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'world1 followup action-state shows polished line without duplicate instruction',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      const packId = 'world1_spine_followup_v1_b0';
      final startIndex = _firstActionableFollowupStepIndexV1(packId);
      await tester.pumpWidget(
        MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: packId,
            moduleTitle: 'World 1 Followup',
            mode: kWorld1RunnerModeCampaignSpine,
            startHandIndex: startIndex,
          ),
        ),
      );
      await tester.pump();

      await _advanceToCampaignActionBarV1(tester);
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_campaign_action_bar')),
        maxTicks: 260,
      );
      final promptWidgets = find
          .byKey(const Key('microtask_step_prompt'))
          .evaluate()
          .map((element) => element.widget)
          .whereType<Text>()
          .toList(growable: false);
      expect(promptWidgets, isNotEmpty);
      expect(
        promptWidgets.any(
          (text) =>
              (text.data ?? '').trim().startsWith('Practice:') &&
              (text.data ?? '').trim().contains('Choose the best action.'),
        ),
        isTrue,
      );
      expect(find.text('Use the table prompt, then confirm.'), findsNothing);
      expect(find.text('Select a seat.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'runner instruction source overrides intro step and outcome text',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
            instructionSourceV1: _OverrideInstructionSourceV1(),
          ),
        ),
      );
      await tester.pump();
      dynamic state() =>
          tester.state(find.byType(World1FoundationsMicroTaskRunnerScreen));
      state().debugForceCoachIntroStateForTestV1();
      await tester.pump();

      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      await _pumpUntil(tester, preludeContinue, maxTicks: 120);
      if (preludeContinue.evaluate().isNotEmpty) {
        await tester.tap(preludeContinue, warnIfMissed: false);
        await tester.pump();
      }
      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_coach_strip_v1')),
        maxTicks: 240,
      );
      final coachModeAtStart = state().debugCoachModeNameV1();
      if (coachModeAtStart == 'intro') {
        expect(find.text('OVR_INTRO_V1'), findsOneWidget);
        expect(find.byKey(const Key('microtask_check_cta')), findsNothing);
        expect(find.byKey(const Key('microtask_continue_cta')), findsNothing);
      }

      if (find
          .byKey(const Key('microtask_intro_sequence_v1'))
          .evaluate()
          .isNotEmpty) {
        await _completeIntroSequenceV1(tester);
      }
      final introContinue = find.byKey(
        const Key('microtask_intro_continue_cta_v1'),
      );
      if (introContinue.evaluate().isNotEmpty) {
        await tester.tap(introContinue, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
      }

      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_check_cta')),
        maxTicks: 240,
      );
      expect(
        find.byKey(const Key('microtask_felt_caption_container_v1')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('microtask_coach_strip_v1')), findsNothing);
      expect(find.textContaining('toCall', findRichText: true), findsNothing);
      expect(
        find.textContaining('Choose the best action.'),
        findsAtLeastNWidgets(1),
      );
      expect(find.byKey(const Key('microtask_continue_cta')), findsNothing);

      state().debugForceCoachOutcomeStateForTestV1();
      await tester.pump();

      await _pumpUntil(
        tester,
        find.byKey(const Key('microtask_continue_cta')),
        maxTicks: 240,
      );
      expect(find.byKey(const Key('microtask_coach_strip_v1')), findsOneWidget);
      expect(find.text('OVR_OUTCOME_V1'), findsOneWidget);
      expect(
        find.byKey(const Key('microtask_campaign_action_bar')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('seat quiz layout keeps canonical ring order and no overlap', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
        ),
      ),
    );
    await tester.pump();

    const seatIds = <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
    final seatFinders = <String, Finder>{
      for (final id in seatIds) id: find.byKey(Key('microtask_seat_$id')),
    };

    for (final finder in seatFinders.values) {
      expect(finder, findsOneWidget);
    }

    final rects = <String, Rect>{
      for (final entry in seatFinders.entries)
        entry.key: tester.getRect(entry.value),
    };

    final seatRects = rects.entries.toList(growable: false);
    for (var i = 0; i < seatRects.length; i++) {
      for (var j = i + 1; j < seatRects.length; j++) {
        final a = seatRects[i].value.deflate(1.0);
        final b = seatRects[j].value.deflate(1.0);
        expect(
          a.overlaps(b),
          isFalse,
          reason: 'Seat overlap: ${seatRects[i].key} vs ${seatRects[j].key}',
        );
      }
    }

    final tableCenter = tester
        .getRect(find.byKey(const Key('microtask_table')))
        .center;
    final btnCenter = rects['btn']!.center;
    final sbCenter = rects['sb']!.center;
    expect(
      sbCenter.dx,
      lessThan(btnCenter.dx),
      reason: 'Small Blind must be visually left of Button',
    );
    final seatAngle = <String, double>{
      for (final entry in rects.entries)
        entry.key: (() {
          final dx = entry.value.center.dx - tableCenter.dx;
          final dy = tableCenter.dy - entry.value.center.dy;
          final angle = math.atan2(dy, dx);
          return angle < 0 ? angle + (math.pi * 2.0) : angle;
        })(),
    };

    // Cartesian clockwise traversal (y-axis inverted above) from BTN.
    final clockwise = seatAngle.keys.toList(growable: false)
      ..sort((a, b) => seatAngle[b]!.compareTo(seatAngle[a]!));
    final startIndex = clockwise.indexOf('btn');
    expect(startIndex, isNot(-1));
    final rotated = <String>[
      ...clockwise.sublist(startIndex),
      ...clockwise.sublist(0, startIndex),
    ];
    expect(rotated, <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co']);

    expect(tester.takeException(), isNull);
  });

  testWidgets('seat quiz caption stays in a safe zone and never overlaps seat labels', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.devicePixelRatio = 1.0;

    final variants = <({Size size, double textScale})>[
      (size: const Size(360, 640), textScale: 1.0),
      (size: const Size(390, 844), textScale: 1.15),
    ];
    const seatIds = <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
    var validatedSeatQuizVariants = 0;

    for (final variant in variants) {
      tester.view.physicalSize = variant.size;
      final variantName =
          'size_${variant.size.width.toInt()}x${variant.size.height.toInt()}_scale_${variant.textScale}';
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              textScaler: TextScaler.linear(variant.textScale),
            ),
            child: const World1FoundationsMicroTaskRunnerScreen(
              moduleId: 'world1_act0_table_literacy',
              moduleTitle: 'World 1',
              mode: kWorld1RunnerModeCampaignSpine,
            ),
          ),
        ),
      );
      await tester.pump();
      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      if (preludeContinue.evaluate().isNotEmpty) {
        await tester.tap(preludeContinue, warnIfMissed: false);
        await tester.pump();
      }
      final tableInstruction = find.byKey(
        const Key('microtask_seat_quiz_table_instruction_v1'),
      );
      final headerInstruction = find.byKey(
        const Key('microtask_seat_quiz_header_instruction_v1'),
      );
      final conceptPrelude = find.byKey(
        const Key('concept_first_seat_prelude_card_v1'),
      );
      var hasInstructionSurface =
          tableInstruction.evaluate().isNotEmpty ||
          headerInstruction.evaluate().isNotEmpty ||
          conceptPrelude.evaluate().isNotEmpty;
      for (var i = 0; i < 120 && !hasInstructionSurface; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        hasInstructionSurface =
            tableInstruction.evaluate().isNotEmpty ||
            headerInstruction.evaluate().isNotEmpty ||
            conceptPrelude.evaluate().isNotEmpty;
      }
      final captionSurface = tableInstruction.evaluate().isNotEmpty
          ? tableInstruction
          : (headerInstruction.evaluate().isNotEmpty
                ? headerInstruction
                : conceptPrelude);
      if (captionSurface.evaluate().isEmpty) {
        continue;
      }
      validatedSeatQuizVariants += 1;
      expect(
        captionSurface,
        findsOneWidget,
        reason:
            '[$variantName] Expected seat-quiz instruction or concept surface',
      );
      final conceptPreludeActive = conceptPrelude.evaluate().isNotEmpty;
      if (captionSurface == conceptPrelude || conceptPreludeActive) {
        expect(find.textContaining('Why it matters:'), findsAtLeastNWidgets(1));
        expect(find.textContaining('Notice:'), findsAtLeastNWidgets(1));
        final conceptRect = tester.getRect(captionSurface);
        expect(
          conceptRect.left >= 4,
          isTrue,
          reason:
              '[$variantName] Covered smart-learning fallback must stay visible in viewport.',
        );
        expect(
          conceptRect.top >= 4,
          isTrue,
          reason:
              '[$variantName] Covered smart-learning fallback must stay visible in viewport.',
        );
        continue;
      }

      final captionRect = tester.getRect(captionSurface);
      for (final seatId in seatIds) {
        final seatFinder = find.byKey(Key('microtask_seat_$seatId'));
        expect(
          seatFinder,
          findsOneWidget,
          reason: '[$variantName] Missing seat key microtask_seat_$seatId',
        );
        final seatRect = tester.getRect(seatFinder).deflate(1.0);
        expect(
          captionRect.overlaps(seatRect),
          isFalse,
          reason:
              '[$variantName] Caption must not overlap seat label ring ($seatId) '
              '(caption=$captionRect, seat=$seatRect)',
        );
      }
    }
    expect(validatedSeatQuizVariants, greaterThan(0));

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'runner placement matrix keeps seat quiz, decision, and outcome surfaces stable',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.devicePixelRatio = 1.0;

      final sizes = <Size>[
        const Size(360, 640),
        const Size(390, 844),
        const Size(430, 932),
      ];
      const textScales = <double>[1.0, 1.15];
      const minInset = 4.0;
      const seatIds = <String>['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
      var validatedSeatQuizVariants = 0;

      for (final size in sizes) {
        tester.view.physicalSize = size;
        for (final textScale in textScales) {
          final variantName =
              'size_${size.width.toInt()}x${size.height.toInt()}_scale_$textScale';

          void expectRectWithinScreenInset(Rect rect, String label) {
            expect(
              rect.left >= minInset,
              isTrue,
              reason:
                  '[$variantName] $label left inset violated: ${rect.left} < $minInset',
            );
            expect(
              rect.top >= minInset,
              isTrue,
              reason:
                  '[$variantName] $label top inset violated: ${rect.top} < $minInset',
            );
            expect(
              rect.right <= size.width - minInset,
              isTrue,
              reason:
                  '[$variantName] $label right inset violated: ${rect.right} > ${size.width - minInset}',
            );
            expect(
              rect.bottom <= size.height - minInset,
              isTrue,
              reason:
                  '[$variantName] $label bottom inset violated: ${rect.bottom} > ${size.height - minInset}',
            );
          }

          // S1: Seat-quiz caption vs seat-label ring.
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: const World1FoundationsMicroTaskRunnerScreen(
                  moduleId: 'world1_act0_table_literacy',
                  moduleTitle: 'World 1',
                  mode: kWorld1RunnerModeCampaignSpine,
                ),
              ),
            ),
          );
          await tester.pump();
          final preludeContinue = find.byKey(
            const Key('microtask_prelude_continue_cta_v1'),
          );
          if (preludeContinue.evaluate().isNotEmpty) {
            await tester.tap(preludeContinue, warnIfMissed: false);
            await tester.pump();
          }

          final tableInstruction = find.byKey(
            const Key('microtask_seat_quiz_table_instruction_v1'),
          );
          final headerInstruction = find.byKey(
            const Key('microtask_seat_quiz_header_instruction_v1'),
          );
          final conceptPrelude = find.byKey(
            const Key('concept_first_seat_prelude_card_v1'),
          );
          var hasInstructionSurface =
              tableInstruction.evaluate().isNotEmpty ||
              headerInstruction.evaluate().isNotEmpty ||
              conceptPrelude.evaluate().isNotEmpty;
          for (var i = 0; i < 120 && !hasInstructionSurface; i++) {
            await tester.pump(const Duration(milliseconds: 16));
            hasInstructionSurface =
                tableInstruction.evaluate().isNotEmpty ||
                headerInstruction.evaluate().isNotEmpty ||
                conceptPrelude.evaluate().isNotEmpty;
          }
          final seatQuizCaptionSurface = tableInstruction.evaluate().isNotEmpty
              ? tableInstruction
              : (headerInstruction.evaluate().isNotEmpty
                    ? headerInstruction
                    : conceptPrelude);
          if (seatQuizCaptionSurface.evaluate().isEmpty) {
            continue;
          }
          validatedSeatQuizVariants += 1;
          expect(
            seatQuizCaptionSurface,
            findsOneWidget,
            reason:
                '[$variantName] Expected seat-quiz instruction or concept surface',
          );
          final conceptPreludeActive = conceptPrelude.evaluate().isNotEmpty;
          if (seatQuizCaptionSurface == conceptPrelude ||
              conceptPreludeActive) {
            expect(
              find.textContaining('Why it matters:'),
              findsAtLeastNWidgets(1),
            );
            expect(find.textContaining('Notice:'), findsAtLeastNWidgets(1));
          } else {
            final seatQuizCaptionRect = tester.getRect(seatQuizCaptionSurface);
            expectRectWithinScreenInset(
              seatQuizCaptionRect,
              'seat_quiz_caption',
            );
            for (final seatId in seatIds) {
              final seatFinder = find.byKey(Key('microtask_seat_$seatId'));
              expect(seatFinder, findsOneWidget);
              final seatRect = tester.getRect(seatFinder).deflate(1.0);
              expect(
                seatQuizCaptionRect.overlaps(seatRect),
                isFalse,
                reason:
                    '[$variantName] Seat-quiz caption overlaps seat $seatId '
                    '(caption=$seatQuizCaptionRect, seat=$seatRect)',
              );
            }
          }

          // S2/S3: Decision state then outcome state.
          await ProgressService.setSpineNextHandIndexV1(0);
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: const World1FoundationsMicroTaskRunnerScreen(
                  moduleId: 'world1_spine_campaign_v1',
                  moduleTitle: 'World 1',
                  mode: kWorld1RunnerModeCampaignSpine,
                ),
              ),
            ),
          );
          await tester.pump();

          final actionBar = find.byKey(
            const Key('microtask_campaign_action_bar'),
          );
          final boardStrip = find.byKey(
            const Key('microtask_engine_board_strip'),
          );
          final potValue = find.byKey(
            const Key('microtask_pot_value_v1'),
            skipOffstage: false,
          );
          final tableShell = find.byKey(
            const Key('microtask_table_stadium_shell_v1'),
          );
          await _pumpUntil(tester, actionBar, maxTicks: 120);
          await _pumpUntil(tester, boardStrip, maxTicks: 120);
          await _pumpUntil(tester, potValue, maxTicks: 120);
          await _pumpUntil(tester, tableShell, maxTicks: 120);

          expect(actionBar, findsOneWidget);
          expect(boardStrip, findsOneWidget);
          expect(tableShell, findsOneWidget);
          final actionBarRect = tester.getRect(actionBar);
          final boardRect = tester.getRect(boardStrip);
          final tableRect = tester.getRect(tableShell);
          final visiblePot = find.byKey(const Key('microtask_pot_value_v1'));
          expect(visiblePot, findsOneWidget);
          final potRect = tester.getRect(visiblePot);

          expectRectWithinScreenInset(actionBarRect, 'decision_action_bar');
          expectRectWithinScreenInset(boardRect, 'decision_board');
          expectRectWithinScreenInset(potRect, 'decision_pot');
          expectRectWithinScreenInset(tableRect, 'decision_table_shell');

          expect(
            actionBarRect.top >= tableRect.bottom - 1,
            isTrue,
            reason:
                '[$variantName] Decision action bar must stay below table shell '
                '(actionBar=$actionBarRect, table=$tableRect)',
          );
          expect(boardRect.top >= tableRect.top - 1, isTrue);
          expect(boardRect.bottom <= tableRect.bottom + 1, isTrue);
          expect(potRect.top >= tableRect.top - 1, isTrue);
          expect(potRect.bottom <= tableRect.bottom + 1, isTrue);

          await _tapFirstEnabledCampaignAction(tester);
          final outcomeSurface = find.byKey(
            const Key('microtask_outcome_surface'),
          );
          final continueCta = find.byKey(const Key('microtask_continue_cta'));
          await _pumpUntil(tester, outcomeSurface, maxTicks: 120);
          await _pumpUntil(tester, continueCta, maxTicks: 120);

          expect(outcomeSurface, findsOneWidget);
          expect(continueCta, findsOneWidget);
          final outcomeRect = tester.getRect(outcomeSurface);
          final continueRect = tester.getRect(continueCta);
          expectRectWithinScreenInset(outcomeRect, 'outcome_surface');
          expectRectWithinScreenInset(continueRect, 'outcome_continue_cta');
          expect(
            actionBar.evaluate().isEmpty ||
                !outcomeRect.overlaps(tester.getRect(actionBar)),
            isTrue,
            reason:
                '[$variantName] Outcome surface must not overlap visible action bar',
          );
          expect(
            outcomeRect.contains(continueRect.topLeft) &&
                outcomeRect.contains(continueRect.bottomRight),
            isTrue,
            reason:
                '[$variantName] Continue CTA must stay inside outcome surface '
                '(outcome=$outcomeRect, continue=$continueRect)',
          );
        }
      }
      expect(validatedSeatQuizVariants, greaterThan(0));

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'seat-quiz start has no prelude CONTINUE gate and remains deterministic',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_table_literacy',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      expect(preludeContinue, findsNothing);

      await _completeIntroSequenceV1(tester);

      final introContinue = find.byKey(
        const Key('microtask_intro_continue_cta_v1'),
      );
      if (introContinue.evaluate().isNotEmpty) {
        final introContinueButton = tester.widget<FilledButton>(introContinue);
        expect(introContinueButton.onPressed, isNotNull);
        await tester.tap(introContinue, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
      }
      expect(
        find.byKey(const Key('microtask_intro_sequence_v1')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'table canvas size stays stable from prelude/intro to seat interaction',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_table_literacy',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();

      final tableCanvas = find.byKey(const Key('microtask_table_canvas'));
      await _pumpUntil(tester, tableCanvas, maxTicks: 240);
      final preludeSize = tester.getRect(tableCanvas).size;

      final preludeContinue = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      if (preludeContinue.evaluate().isNotEmpty) {
        await _pumpUntil(tester, preludeContinue, maxTicks: 240);
        await tester.tap(preludeContinue, warnIfMissed: false);
        await tester.pump();
      }
      await _completeIntroSequenceV1(tester);
      final introContinue = find.byKey(
        const Key('microtask_intro_continue_cta_v1'),
      );
      if (introContinue.evaluate().isNotEmpty) {
        await tester.tap(introContinue, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));
      }

      final postIntroSize = tester.getRect(tableCanvas).size;
      final widthDelta = (preludeSize.width - postIntroSize.width).abs();
      final heightDelta = (preludeSize.height - postIntroSize.height).abs();
      expect(
        widthDelta <= 1.0,
        isTrue,
        reason:
            'table canvas width changed too much: prelude=${preludeSize.width} postIntro=${postIntroSize.width}',
      );
      expect(
        heightDelta <= 1.0,
        isTrue,
        reason:
            'table canvas height changed too much: prelude=${preludeSize.height} postIntro=${postIntroSize.height}',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
