import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });
  });

  Future<void> _pumpToConceptSeatStepV1(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'world1_act0_table_literacy',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );

    for (var i = 0; i < 260; i++) {
      final prelude = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      if (prelude.evaluate().isNotEmpty) {
        await tester.tap(prelude.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 90));
        continue;
      }
      final intro = find.byKey(const Key('microtask_intro_continue_cta_v1'));
      if (intro.evaluate().isNotEmpty) {
        await tester.tap(intro.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 90));
        continue;
      }
      final outcome = find.byKey(const Key('microtask_outcome_surface'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      if (outcome.evaluate().isNotEmpty && continueCta.evaluate().isNotEmpty) {
        await tester.tap(continueCta.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 140));
        continue;
      }
      final conceptCard = find.byKey(
        const Key('concept_first_seat_prelude_card_v1'),
      );
      final check = find.byKey(const Key('microtask_check_cta'));
      if (conceptCard.evaluate().isNotEmpty && check.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 80));
    }

    fail('Did not reach concept-first seat micro-slice deterministically.');
  }

  Future<void> _completeSeatStepByIdV1(
    WidgetTester tester,
    String seatId,
  ) async {
    final seat = find.byKey(Key('microtask_seat_$seatId'));
    expect(seat, findsOneWidget);
    await tester.tap(seat.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 80));
    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
    } else {
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
    }
  }

  Future<void> _waitForSeatQuizInteractiveV1(WidgetTester tester) async {
    for (var i = 0; i < 220; i++) {
      final prelude = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      if (prelude.evaluate().isNotEmpty) {
        await tester.tap(prelude.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 90));
        continue;
      }
      final intro = find.byKey(const Key('microtask_intro_continue_cta_v1'));
      if (intro.evaluate().isNotEmpty) {
        await tester.tap(intro.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 90));
        continue;
      }
      final outcome = find.byKey(const Key('microtask_outcome_surface'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      if (outcome.evaluate().isNotEmpty && continueCta.evaluate().isNotEmpty) {
        await tester.tap(continueCta.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 140));
        continue;
      }
      final check = find.byKey(const Key('microtask_check_cta'));
      if (check.evaluate().isNotEmpty &&
          find
              .byKey(const Key('microtask_outcome_surface'))
              .evaluate()
              .isEmpty) {
        return;
      }
      await tester.pump(const Duration(milliseconds: 80));
    }
    fail('Did not reach a seat-quiz interactive step deterministically.');
  }

  void _expectConceptPreludeVisibleInInstructionSurfaceV1(WidgetTester tester) {
    final tableCanvas = find.byKey(const Key('microtask_table_canvas'));
    final stadium = find.byKey(const Key('microtask_table_stadium_shell_v1'));
    final instructionSurface = find.byKey(
      const Key('microtask_seat_quiz_table_instruction_v1'),
    );
    final card = find.byKey(const Key('concept_first_seat_prelude_card_v1'));
    final setup = find.byKey(const Key('concept_first_seat_setup_v1'));
    final supportSurface = find.byKey(
      const Key('concept_first_seat_support_surface_v1'),
    );
    final support = find.byKey(const Key('concept_first_seat_support_v1'));
    expect(tableCanvas, findsOneWidget);
    expect(stadium, findsOneWidget);
    expect(instructionSurface, findsOneWidget);
    expect(card, findsOneWidget);
    expect(setup, findsOneWidget);
    expect(supportSurface, findsOneWidget);
    expect(support, findsOneWidget);
    expect(
      find.byKey(const Key('concept_first_seat_support_why_v1')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('concept_first_seat_support_notice_v1')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('concept_first_seat_table_overlay_v1')),
      findsNothing,
      reason:
          'Covered steps should reuse the central instruction lane instead of the old in-canvas overlay.',
    );

    final tableRect = tester.getRect(tableCanvas);
    final stadiumRect = tester.getRect(stadium);
    final instructionRect = tester.getRect(instructionSurface);
    final cardRect = tester.getRect(card);
    final supportRect = tester.getRect(supportSurface);
    expect(
      instructionRect.top >= tableRect.top,
      isTrue,
      reason:
          'The smart-learning surface must stay inside the visible table canvas.',
    );
    expect(
      instructionRect.bottom <= tableRect.bottom,
      isTrue,
      reason:
          'The smart-learning surface must remain fully visible on portrait devices.',
    );
    expect(
      instructionRect.left >= stadiumRect.left,
      isTrue,
      reason:
          'The instruction surface should stay centered over the felt lane.',
    );
    expect(
      instructionRect.right <= stadiumRect.right,
      isTrue,
      reason:
          'The instruction surface should stay centered over the felt lane.',
    );
    expect(
      (instructionRect.center.dx - stadiumRect.center.dx).abs() <= 12,
      isTrue,
      reason:
          'The smart-learning surface should use the calm central instruction zone, not drift toward seat markers.',
    );
    expect(
      cardRect.top >= instructionRect.top,
      isTrue,
      reason:
          'The smart-learning card must render inside the instruction surface.',
    );
    expect(
      cardRect.bottom <= instructionRect.bottom,
      isTrue,
      reason:
          'The smart-learning card must render inside the instruction surface.',
    );
    expect(
      cardRect.left >= instructionRect.left,
      isTrue,
      reason:
          'The smart-learning card must render inside the instruction surface.',
    );
    expect(
      cardRect.right <= instructionRect.right,
      isTrue,
      reason:
          'The smart-learning card must render inside the instruction surface.',
    );
    expect(
      cardRect.width <= stadiumRect.width * 0.76,
      isTrue,
      reason:
          'The smart-learning card should stay proportionate to the felt lane instead of reading like a wide banner.',
    );
    expect(
      supportRect.top >= cardRect.top,
      isTrue,
      reason:
          'The secondary support block must stay inside the smart-learning card.',
    );
    expect(
      supportRect.bottom <= cardRect.bottom,
      isTrue,
      reason:
          'The secondary support block must stay inside the smart-learning card.',
    );
    expect(
      instructionRect.bottom > stadiumRect.top,
      isTrue,
      reason:
          'The instruction surface should stay close to the felt instead of floating back into header chrome.',
    );
    expect(
      instructionRect.top < stadiumRect.center.dy,
      isTrue,
      reason:
          'The instruction surface should keep the table visually primary by staying in the upper center lane.',
    );
    expect(
      instructionRect.top >= stadiumRect.top + (stadiumRect.height * 0.32),
      isTrue,
      reason:
          'The instruction surface should sit slightly lower in the calm lane after scene stabilization instead of hugging the upper edge.',
    );
  }

  String _textDataV1(WidgetTester tester, Key key) {
    return tester.widget<Text>(find.byKey(key)).data ?? '';
  }

  test(
    'instruction rect resolver keeps a visible fallback when seat avoidance blocks every candidate',
    () {
      const stadiumRect = Rect.fromLTWH(40, 120, 310, 260);
      final expectedLaneTop = stadiumRect.top + (stadiumRect.height * 0.3);
      final fallbackRect = resolveSeatQuizTableInstructionRectV1(
        stadiumRect: stadiumRect,
        preferredWidth: 280,
        containerHeight: 104,
        avoidRects: <Rect>[const Rect.fromLTWH(30, 180, 330, 140)],
        laneTopFactor: 0.3,
        laneBottomFactor: 0.5,
      );

      expect(fallbackRect.left >= stadiumRect.left, isTrue);
      expect(fallbackRect.right <= stadiumRect.right, isTrue);
      expect(fallbackRect.top >= stadiumRect.top, isTrue);
      expect(fallbackRect.bottom <= stadiumRect.bottom, isTrue);
      expect(
        fallbackRect.top >= expectedLaneTop,
        isTrue,
        reason:
            'Covered-step fallback should stay in the intended upper instruction lane instead of disappearing.',
      );
    },
  );

  testWidgets(
    'concept-first cluster extends through big blind with visible low-density framing',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pumpToConceptSeatStepV1(tester);

      _expectConceptPreludeVisibleInInstructionSurfaceV1(tester);
      final tableRect = tester.getRect(
        find.byKey(const Key('microtask_table_canvas')),
      );
      final stadiumRect = tester.getRect(
        find.byKey(const Key('microtask_table_stadium_shell_v1')),
      );
      final bottomReserve = tableRect.bottom - stadiumRect.bottom;
      expect(
        stadiumRect.height / tableRect.height >= 0.62,
        isTrue,
        reason:
            'Portrait felt should occupy more of the visible table canvas instead of leaving excess dead space above and below.',
      );
      expect(
        stadiumRect.height - stadiumRect.width >= 12.0,
        isTrue,
        reason:
            'Portrait felt should keep a real stadium/oval poker shape instead of collapsing toward a circle.',
      );
      expect(
        bottomReserve >= 28.0,
        isTrue,
        reason:
            'Portrait seat-quiz should preserve a lower reserve for future action controls instead of spending the entire lower scene.',
      );
      final setup = find.byKey(const Key('concept_first_seat_setup_v1'));
      final support = find.byKey(const Key('concept_first_seat_support_v1'));
      expect(setup, findsOneWidget);
      expect(support, findsOneWidget);
      expect(
        find.byKey(const Key('concept_first_seat_support_why_v1')),
        findsNothing,
        reason:
            'Covered steps should keep one unified secondary support block, not split columns.',
      );
      expect(
        find.byKey(const Key('concept_first_seat_support_notice_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('concept_first_seat_why_v1')),
        findsNothing,
        reason:
            'Covered steps should use the unified support block instead of three equal text rows.',
      );
      expect(
        find.byKey(const Key('concept_first_seat_focus_v1')),
        findsNothing,
      );
      expect(
        _textDataV1(tester, const Key('concept_first_seat_setup_v1')),
        contains('dealer seat'),
      );
      expect(
        _textDataV1(tester, const Key('concept_first_seat_support_v1')),
        contains('dealer anchor sets table order'),
      );
      expect(
        _textDataV1(tester, const Key('concept_first_seat_support_v1')),
        contains('dealer button'),
      );
      final supportText = tester.widget<Text>(support);
      expect(
        supportText.maxLines,
        isNull,
        reason:
            'The unified secondary support block should wrap instead of silently clipping meaningful text.',
      );

      final check = find.byKey(const Key('microtask_check_cta'));
      expect(check, findsAtLeastNWidgets(1));

      await _completeSeatStepByIdV1(tester, 'btn');
      await _waitForSeatQuizInteractiveV1(tester);
      _expectConceptPreludeVisibleInInstructionSurfaceV1(tester);

      expect(
        _textDataV1(tester, const Key('concept_first_seat_support_v1')),
        contains('left of Button'),
      );

      await _completeSeatStepByIdV1(tester, 'sb');
      await _waitForSeatQuizInteractiveV1(tester);
      _expectConceptPreludeVisibleInInstructionSurfaceV1(tester);
      expect(
        _textDataV1(tester, const Key('concept_first_seat_setup_v1')),
        contains('second blind seat'),
      );
      expect(
        _textDataV1(tester, const Key('concept_first_seat_support_v1')),
        contains('Blind order must stay clear'),
      );
      expect(
        _textDataV1(tester, const Key('concept_first_seat_support_v1')),
        contains('next to Small Blind'),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'portrait campaign path keeps smart-learning framing dominant on covered steps only',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pumpToConceptSeatStepV1(tester);

      _expectConceptPreludeVisibleInInstructionSurfaceV1(tester);
      expect(find.textContaining('Why it matters:'), findsOneWidget);
      expect(find.textContaining('Notice:'), findsOneWidget);
      expect(
        find.byKey(const Key('microtask_seat_quiz_table_instruction_v1')),
        findsOneWidget,
        reason:
            'Covered concept-first steps should reuse the central instruction surface instead of hiding it.',
      );

      await _completeSeatStepByIdV1(tester, 'btn');
      await _waitForSeatQuizInteractiveV1(tester);
      _expectConceptPreludeVisibleInInstructionSurfaceV1(tester);
      expect(
        find.byKey(const Key('microtask_seat_quiz_table_instruction_v1')),
        findsOneWidget,
      );

      await _completeSeatStepByIdV1(tester, 'sb');
      await _waitForSeatQuizInteractiveV1(tester);
      _expectConceptPreludeVisibleInInstructionSurfaceV1(tester);
      expect(
        find.byKey(const Key('microtask_seat_quiz_table_instruction_v1')),
        findsOneWidget,
        reason:
            'The covered first-user segment should remain visually dominant through the Big Blind completion step.',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'concept-first big-blind step keeps compact reinforce on correct',
    (tester) async {
      await _pumpToConceptSeatStepV1(tester);

      await _completeSeatStepByIdV1(tester, 'btn');
      await _waitForSeatQuizInteractiveV1(tester);
      await _completeSeatStepByIdV1(tester, 'sb');
      await _waitForSeatQuizInteractiveV1(tester);
      final seat = find.byKey(const Key('microtask_seat_bb'));
      await tester.tap(seat.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 80));
      final check = find.byKey(const Key('microtask_check_cta'));
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.textContaining('Reinforce:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('concept-first micro-slice incorrect path keeps factual why', (
    tester,
  ) async {
    await _pumpToConceptSeatStepV1(tester);

    final wrongSeat = find.byKey(const Key('microtask_seat_sb'));
    expect(wrongSeat, findsOneWidget);
    await tester.tap(wrongSeat.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 80));

    final check = find.byKey(const Key('microtask_check_cta'));
    if (check.evaluate().isNotEmpty) {
      await tester.tap(check.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
    } else {
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pump(const Duration(milliseconds: 220));
    }

    expect(find.byKey(const Key('microtask_outcome_surface')), findsOneWidget);
    expect(find.textContaining('Incorrect seat.'), findsOneWidget);
    expect(
      find.textContaining('Why:'),
      findsOneWidget,
      reason: 'Concept-first slice must keep factual why on incorrect.',
    );
    expect(
      find.byKey(const Key('microtask_seat_quiz_expected_chosen_v1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
