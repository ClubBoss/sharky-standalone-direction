import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('task-scoped runner drill parsing retains only complete selectors', () {
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=what_poker_is&task=what_poker_is_table_read_transfer',
      ),
    );

    expect(entry, isNotNull);
    expect(entry!.surface, Act0ControlledDemoCaptureSurfaceV1.runnerDrill);
    expect(entry.worldId, 'world_1');
    expect(entry.lessonId, 'what_poker_is');
    expect(entry.taskId, 'what_poker_is_table_read_transfer');
    expect(
      parseAct0ControlledDemoHarnessEntryV1(
        Uri.parse(
          'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1',
        ),
      ),
      isNull,
    );
    expect(
      parseAct0ControlledDemoHarnessEntryV1(
        Uri.parse(
          'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=what_poker_is',
        ),
      ),
      isNull,
    );
    expect(parseAct0ControlledDemoHarnessEntryV1(Uri()), isNull);
  });

  testWidgets('task-scoped runner drill opens the selected table task', (
    tester,
  ) async {
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=what_poker_is&task=what_poker_is_table_read_transfer',
      ),
    );
    await _pump(tester, entry!);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'what_poker_is_table_read_transfer',
    );
    expect(
      find.byKey(const Key('act0_shell_option_five_board_now')),
      findsOneWidget,
    );
    expect(find.textContaining('Theory page'), findsNothing);
    expect(find.text('Which marker identifies you?'), findsNothing);
  });

  testWidgets('published World 3 selector resolves to a live table runner', (
    tester,
  ) async {
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_3&lesson=button_advantage&task=button_advantage_button_vs_cutoff',
      ),
    );
    await _pump(tester, entry!);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_seat_tap_prompt')), findsOneWidget);
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'button_advantage_button_vs_cutoff',
    );
    expect(find.byKey(const Key('act0_shell_home_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
    expect(find.textContaining('Today'), findsNothing);
  });

  testWidgets('canonical seat task uses the stable envelope and residual table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=positions&task=positions_early_late',
      ),
    );
    await _pump(tester, entry!);

    final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
    final tableZone = tester.getRect(
      find.byKey(const Key('act0_shell_shared_runner_table_zone')),
    );
    final seam = tester.getRect(
      find.byKey(const Key('act0_shell_shared_runner_seam')),
    );
    final dock = tester.getRect(
      find.byKey(const Key('act0_shell_runner_action_dock')),
    );
    final prompt = tester.getRect(
      find.byKey(const Key('act0_shell_seat_tap_prompt')),
    );
    final question = tester.getRect(
      find.byKey(const Key('act0_shell_action_question')),
    );
    final action = tester.getRect(
      find.byKey(const Key('act0_shell_seat_tap_prompt_text')),
    );
    final seat = tester.getRect(
      find.byKey(const Key('act0_shell_seat_node_bb')),
    );
    final seatTap = tester.getRect(
      find.byKey(const Key('act0_shell_seat_tap_bb')),
    );

    expect(prompt.height, inInclusiveRange(104, 160));
    expect(action.top - question.bottom, inInclusiveRange(0, 24));
    expect(tableZone.contains(table.topLeft), isTrue);
    expect(tableZone.contains(table.bottomRight), isTrue);
    expect(tableZone.bottom, closeTo(seam.top, 0.5));
    expect(seam.height, closeTo(12, 0.5));
    expect(seam.bottom, closeTo(dock.top, 0.5));
    expect(prompt.top - table.bottom, lessThanOrEqualTo(36));
    expect(
      table.height / (dock.bottom - tableZone.top),
      greaterThanOrEqualTo(0.58),
    );
    expect(seatTap.center, seat.center);
    expect(seatTap.contains(seat.topLeft), isTrue);
    expect(
      seatTap.contains(seat.bottomRight - const Offset(0.01, 0.01)),
      isTrue,
    );
    expect(action.bottom, lessThanOrEqualTo(874));
    expect(dock.bottom, closeTo(874, 1));
    expect(find.byKey(const Key('act0_shell_runner_scroll')), findsOneWidget);
  });

  testWidgets('large phone spends residual height on a larger complete table', (
    tester,
  ) async {
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=positions&task=positions_early_late',
      ),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(402, 874);
    await _pump(tester, entry!);
    final canonicalTable = tester.getRect(
      find.byKey(const Key('act0_shell_table')),
    );

    tester.view.physicalSize = const Size(430, 956);
    await _pump(tester, entry);
    final largeTable = tester.getRect(
      find.byKey(const Key('act0_shell_table')),
    );
    final largeZone = tester.getRect(
      find.byKey(const Key('act0_shell_shared_runner_table_zone')),
    );

    expect(largeTable.height, greaterThan(canonicalTable.height + 24));
    expect(largeTable.width, greaterThan(canonicalTable.width + 12));
    expect(largeZone.contains(largeTable.topLeft), isTrue);
    expect(largeZone.contains(largeTable.bottomRight), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'VRT-02 decision and feedback keep one table, seam, envelope, and hit map',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const queryPrefix =
          'http://127.0.0.1:7357/?world=world_1&lesson=positions&task=positions_early_late';
      final entries = <Act0ShellDebugHarnessEntryV1>[
        parseAct0ControlledDemoHarnessEntryV1(
          Uri.parse('$queryPrefix&act0_capture=runner_drill'),
        )!,
        parseAct0ControlledDemoHarnessEntryV1(
          Uri.parse('$queryPrefix&act0_capture=runner_feedback'),
        )!,
        parseAct0ControlledDemoHarnessEntryV1(
          Uri.parse(
            '$queryPrefix&act0_capture=runner_feedback&feedback=correct',
          ),
        )!,
      ];

      Rect? baselineTable;
      Rect? baselineZone;
      Rect? baselineSeam;
      Rect? baselineEnvelope;
      final baselineSeats = <String, Rect>{};
      final baselineHits = <String, Rect>{};
      final feedbackCtaY = <double>[];
      for (final entry in entries) {
        await _pump(tester, entry);
        final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
        final zone = tester.getRect(
          find.byKey(const Key('act0_shell_shared_runner_table_zone')),
        );
        final seam = tester.getRect(
          find.byKey(const Key('act0_shell_shared_runner_seam')),
        );
        final envelope = tester.getRect(
          find.byKey(const Key('act0_shell_shared_runner_cycle_envelope')),
        );
        baselineTable ??= table;
        baselineZone ??= zone;
        baselineSeam ??= seam;
        baselineEnvelope ??= envelope;
        _expectRectClose(table, baselineTable!);
        _expectRectClose(zone, baselineZone!);
        _expectRectClose(seam, baselineSeam!);
        _expectRectClose(envelope, baselineEnvelope!);

        for (final seatId in <String>['btn', 'sb', 'bb']) {
          final seat = tester.getRect(
            find.byKey(Key('act0_shell_seat_node_$seatId')),
          );
          final hit = tester.getRect(
            find.byKey(Key('act0_shell_seat_tap_$seatId')),
          );
          baselineSeats.putIfAbsent(seatId, () => seat);
          baselineHits.putIfAbsent(seatId, () => hit);
          _expectRectClose(seat, baselineSeats[seatId]!);
          _expectRectClose(hit, baselineHits[seatId]!);
          expect(hit.width, greaterThanOrEqualTo(44));
          expect(hit.height, greaterThanOrEqualTo(44));
        }
        final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
        if (cta.evaluate().isNotEmpty) {
          feedbackCtaY.add(tester.getRect(cta).top);
        }
        expect(
          find.byKey(const Key('act0_shell_wave1_dealer_marker')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      }

      expect(feedbackCtaY, hasLength(2));
      expect(feedbackCtaY[0], closeTo(feedbackCtaY[1], 0.05));
    },
  );

  testWidgets('1.4x keeps on-felt annotations separate and seat taps aligned', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=positions&task=positions_early_late',
      ),
    );
    await _pump(tester, entry!, textScale: 1.4);

    for (final seatId in <String>['bb', 'sb']) {
      final seat = tester.getRect(
        find.byKey(Key('act0_shell_seat_node_$seatId')),
      );
      final chip = tester.getRect(
        find.byKey(Key('act0_shell_bet_chip_owner_$seatId')),
      );
      final tap = tester.getRect(
        find.byKey(Key('act0_shell_seat_tap_$seatId')),
      );
      expect(chip.overlaps(seat), isFalse, reason: '$seatId: $chip / $seat');
      expect(tap.center, seat.center);
      expect(tap.contains(seat.topLeft), isTrue);
      expect(tap.contains(seat.bottomRight - const Offset(0.01, 0.01)), isTrue);
    }
    expect(
      tester
          .getRect(find.byKey(const Key('act0_shell_seat_tap_prompt')))
          .bottom,
      lessThanOrEqualTo(874),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion leaves stable geometry unchanged', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=positions&task=positions_early_late',
      ),
    )!;
    await _pump(tester, entry);
    final normalTable = tester.getRect(
      find.byKey(const Key('act0_shell_table')),
    );
    final normalEnvelope = tester.getRect(
      find.byKey(const Key('act0_shell_shared_runner_cycle_envelope')),
    );

    await _pump(tester, entry, disableAnimations: true);
    _expectRectClose(
      tester.getRect(find.byKey(const Key('act0_shell_table'))),
      normalTable,
    );
    _expectRectClose(
      tester.getRect(
        find.byKey(const Key('act0_shell_shared_runner_cycle_envelope')),
      ),
      normalEnvelope,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback dock is bottom anchored and table subtree is uncropped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_feedback&world=world_1&lesson=positions&task=positions_early_late',
      ),
    );
    await _pump(tester, entry!);

    final table = find.byKey(const Key('act0_shell_table'));
    final tableRect = tester.getRect(table);
    final tableZone = tester.getRect(
      find.byKey(const Key('act0_shell_shared_runner_table_zone')),
    );
    final dock = tester.getRect(
      find.byKey(const Key('act0_shell_runner_action_dock')),
    );
    final cta = tester.getRect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
    );
    final explanationScroll = find.byKey(
      const Key('act0_shell_feedback_explanation_scroll'),
    );
    expect(explanationScroll, findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const Key('act0_shell_feedback_reason')),
        matching: explanationScroll,
      ),
      findsOneWidget,
    );
    for (final fixedKey in <Key>[
      const Key('act0_shell_feedback_primary_result_block'),
      const Key('act0_shell_feedback_next_clue'),
      const Key('act0_shell_feedback_continue_cta'),
    ]) {
      final fixed = find.byKey(fixedKey);
      if (fixed.evaluate().isNotEmpty) {
        expect(
          find.ancestor(of: fixed, matching: explanationScroll),
          findsNothing,
        );
      }
    }
    expect(tableZone.contains(tableRect.topLeft), isTrue);
    expect(tableRect.bottom, lessThanOrEqualTo(tableZone.bottom + 0.5));
    expect(tableRect.right, lessThanOrEqualTo(tableZone.right + 0.5));
    final tableOwnedGeometry = find.descendant(
      of: table,
      matching: find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            (key.value.startsWith('act0_shell_seat_node_') ||
                key.value.startsWith('act0_shell_bet_chip_owner_'));
      }),
    );
    for (final element in tableOwnedGeometry.evaluate()) {
      final rect = tester.getRect(find.byElementPredicate((e) => e == element));
      expect(
        rect.left >= tableZone.left - 0.5 &&
            rect.top >= tableZone.top - 0.5 &&
            rect.right <= tableZone.right + 0.5 &&
            rect.bottom <= tableZone.bottom + 0.5,
        isTrue,
        reason: '${element.widget.key}: $rect outside $tableZone',
      );
    }
    expect(cta.bottom, lessThanOrEqualTo(dock.bottom));
    expect(dock.bottom - cta.bottom, inInclusiveRange(0, 48));
    expect(dock.bottom, closeTo(874, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('long feedback scrolls only its explanation', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 264,
              child: Act0FeedbackShellV1(
                title: 'Review the clue',
                reason: List<String>.filled(
                  12,
                  'Position changes which hands can continue profitably.',
                ).join(' '),
                nextClueLine: 'Clue: name the seat before choosing.',
                quality: Act0FeedbackQualityV1.wrong,
                sharkyLine: 'Use the table clue.',
                sharkyMood: Act0SharkyMoodV1.thinking,
                selectedLabel: 'Early position',
                preferredLabel: 'Late position',
                betterLabel: 'Late position',
                refined: true,
                cycleStableEnvelope: true,
                onContinue: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final explanation = find.byKey(
      const Key('act0_shell_feedback_explanation_scroll'),
    );
    final scrollable = find.descendant(
      of: explanation,
      matching: find.byType(Scrollable),
    );
    expect(explanation, findsOneWidget);
    expect(scrollable, findsOneWidget);
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      greaterThan(0),
    );
    for (final fixedKey in <Key>[
      const Key('act0_shell_feedback_primary_result_block'),
      const Key('act0_shell_feedback_next_clue'),
      const Key('act0_shell_feedback_continue_cta'),
    ]) {
      expect(
        find.ancestor(of: find.byKey(fixedKey), matching: explanation),
        findsNothing,
      );
    }
    expect(
      tester
          .getRect(find.byKey(const Key('act0_shell_feedback_continue_cta')))
          .bottom,
      lessThanOrEqualTo(874),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid task-scoped drill selector fails closed to Home', (
    tester,
  ) async {
    await _pump(
      tester,
      const Act0ShellDebugHarnessEntryV1(
        mode: Act0ControlledDemoCaptureModeV1.directState,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
        worldId: 'world_missing',
        lessonId: 'what_poker_is',
        taskId: 'what_poker_is_table_read_transfer',
      ),
    );

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);

    await _pump(
      tester,
      const Act0ShellDebugHarnessEntryV1(
        mode: Act0ControlledDemoCaptureModeV1.directState,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
        worldId: 'world_1',
        lessonId: 'what_poker_is',
        taskId: 'missing_task',
      ),
    );

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
  });
}

void _expectRectClose(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, 0.05));
  expect(actual.top, closeTo(expected.top, 0.05));
  expect(actual.right, closeTo(expected.right, 0.05));
  expect(actual.bottom, closeTo(expected.bottom, 0.05));
}

Future<void> _pump(
  WidgetTester tester,
  Act0ShellDebugHarnessEntryV1 entry, {
  double? textScale,
  bool disableAnimations = false,
}) async {
  final preview = Act0ShellPreviewScreenV1(
    initialTab: Act0ShellTabV1.play,
    initialPhase: Act0LessonPhaseV1.drill,
    showPlacementOnStart: false,
    state: Act0ShellStateV1.sample,
    debugHarnessEntry: entry,
  );
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      home: textScale == null && !disableAnimations
          ? preview
          : MediaQuery(
              data: MediaQueryData.fromView(tester.view).copyWith(
                textScaler: textScale == null
                    ? null
                    : TextScaler.linear(textScale),
                disableAnimations: disableAnimations,
              ),
              child: preview,
            ),
    ),
  );
  await tester.pumpAndSettle();
}
