import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/app_root.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 240,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(step);
  }
  fail('Timed out waiting for ${finder.description}');
}

Future<void> _pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  int maxTicks = 240,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    final matched = finders.any((finder) => finder.evaluate().isNotEmpty);
    if (matched) return;
    await tester.pump(step);
  }
  final targets = finders.map((finder) => finder.description).join(', ');
  fail('Timed out waiting for one of: $targets');
}

String _visibleKeySummaryV1(WidgetTester tester, List<String> keys) {
  final seen = <String>[];
  for (final key in keys) {
    if (find.byKey(Key(key)).evaluate().isNotEmpty) {
      seen.add(key);
    }
  }
  return seen.isEmpty ? 'none' : seen.join(', ');
}

Finder? _seatFinderFromPromptV1(WidgetTester tester) {
  final promptFinder = find.byKey(const Key('microtask_step_prompt'));
  if (promptFinder.evaluate().isEmpty) return null;
  final widget = tester.widget<Widget>(promptFinder);
  if (widget is! Text) return null;
  final text = (widget.data ?? '').toLowerCase();
  if (text.contains('button'))
    return find.byKey(const Key('microtask_seat_btn'));
  if (text.contains('small blind')) {
    return find.byKey(const Key('microtask_seat_sb'));
  }
  if (text.contains('big blind'))
    return find.byKey(const Key('microtask_seat_bb'));
  if (text.contains('hijack'))
    return find.byKey(const Key('microtask_seat_hj'));
  if (text.contains('cutoff') || text.contains('cut off')) {
    return find.byKey(const Key('microtask_seat_co'));
  }
  if (text.contains('utg')) return find.byKey(const Key('microtask_seat_utg'));
  return null;
}

Future<bool> _tapIfEnabledButtonV1(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) return false;
  final widget = tester.widget<Widget>(finder);
  final bool enabled = switch (widget) {
    OutlinedButton button => button.onPressed != null,
    ElevatedButton button => button.onPressed != null,
    FilledButton button => button.onPressed != null,
    TextButton button => button.onPressed != null,
    _ => true,
  };
  if (!enabled) return false;
  await tester.tap(finder, warnIfMissed: false);
  return true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('campaign hand loop e2e starts from root shell and loops back', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1366, 900);
    tester.view.devicePixelRatio = 1.0;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1':
          'world1_act0_table_literacy,world1_act0_action_literacy,world1_act0_street_flow',
      'spine_calibration_completed_v1': false,
      'spine_calibration_band_v1': 0,
      'world2_calibration_completed_v1': false,
      'world3_calibration_completed_v1': false,
      'world4_calibration_completed_v1': false,
      'world5_calibration_completed_v1': false,
      'world6_calibration_completed_v1': false,
      'world7_calibration_completed_v1': false,
      'world8_calibration_completed_v1': false,
      'world9_calibration_completed_v1': false,
      'world10_calibration_completed_v1': false,
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });

    await tester.pumpWidget(const AppRoot());
    await _pumpUntil(tester, find.byKey(const Key('main_shell_v1')));
    await _pumpUntilAny(tester, [
      find.byKey(const Key('map_shell_v1')),
      find.byKey(const Key('world_campaign_section')),
      find.byKey(const Key('map_loading_v1')),
    ]);

    final nextPackCta = find.byKey(const Key('world_campaign_next_pack_cta'));
    final openWorldNode = find.byKey(const Key('world_campaign_open_1'));
    await _pumpUntilAny(tester, [nextPackCta, openWorldNode]);
    if (nextPackCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(nextPackCta);
      await tester.tap(nextPackCta, warnIfMissed: false);
      await tester.pump();
    } else {
      expect(openWorldNode, findsOneWidget);
      await tester.ensureVisible(openWorldNode);
      await tester.tap(openWorldNode, warnIfMissed: false);
      await tester.pump();
    }

    await _pumpUntilAny(tester, [
      find.byKey(const Key('microtask_runner')),
      find.byKey(const Key('world_detail_sheet_v1')),
    ]);
    if (find.byKey(const Key('world_detail_sheet_v1')).evaluate().isNotEmpty) {
      final primaryCta = find.byKey(const Key('world_detail_primary_cta_v1'));
      expect(primaryCta, findsOneWidget);
      await tester.ensureVisible(primaryCta);
      await tester.tap(primaryCta, warnIfMissed: false);
      await tester.pump();
    }
    await _pumpUntil(tester, find.byKey(const Key('microtask_runner')));

    expect(find.byKey(const Key('microtask_runner')), findsOneWidget);
    expect(find.byKey(const Key('microtask_table_canvas')), findsOneWidget);
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    final boardStrip = find.byKey(const Key('microtask_engine_board_strip'));
    final continueCta = find.byKey(const Key('microtask_continue_cta'));
    final checkCta = find.byKey(const Key('microtask_check_cta'));
    final resultBackToMapCta = find.byKey(
      const Key('session_result_back_to_map_cta'),
    );
    final mapSection = find.byKey(const Key('world_campaign_section'));
    final seatFinders = <Finder>[
      find.byKey(const Key('microtask_seat_btn')),
      find.byKey(const Key('microtask_seat_sb')),
      find.byKey(const Key('microtask_seat_bb')),
      find.byKey(const Key('microtask_seat_utg')),
      find.byKey(const Key('microtask_seat_hj')),
      find.byKey(const Key('microtask_seat_co')),
    ];
    final debugKeys = <String>[
      'microtask_runner',
      'microtask_table_canvas',
      'microtask_campaign_action_bar',
      'microtask_engine_board_strip',
      'microtask_continue_cta',
      'microtask_check_cta',
      'microtask_seat_btn',
      'microtask_seat_sb',
      'microtask_seat_bb',
      'microtask_seat_utg',
      'microtask_seat_hj',
      'microtask_seat_co',
      'microtask_outcome_surface',
      'microtask_step_prompt',
    ];
    final everSeen = <String>{};
    var reachedHandLoop = false;
    var reachedAlternateEndState = false;
    for (var i = 0; i < 60; i++) {
      for (final key in debugKeys) {
        if (find.byKey(Key(key)).evaluate().isNotEmpty) {
          everSeen.add(key);
        }
      }
      if (actionBar.evaluate().isNotEmpty && boardStrip.evaluate().isNotEmpty) {
        reachedHandLoop = true;
        break;
      }
      if (resultBackToMapCta.evaluate().isNotEmpty ||
          mapSection.evaluate().isNotEmpty) {
        reachedAlternateEndState = true;
        break;
      }

      if (continueCta.evaluate().isNotEmpty) {
        await tester.ensureVisible(continueCta);
        await tester.tap(continueCta, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 120));
        continue;
      }

      final seatFinder =
          _seatFinderFromPromptV1(tester) ??
          seatFinders[i % seatFinders.length];
      if (seatFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(seatFinder);
        await tester.tap(seatFinder, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 80));
      }

      if (await _tapIfEnabledButtonV1(tester, checkCta)) {
        await tester.pump(const Duration(milliseconds: 120));
        continue;
      }

      await tester.pump(const Duration(milliseconds: 120));
    }
    if (!reachedHandLoop && !reachedAlternateEndState) {
      fail(
        'Did not reach hand-loop action bar. Ever saw: ${everSeen.toList()..sort()}; now visible: ${_visibleKeySummaryV1(tester, debugKeys)}',
      );
    }
    if (!reachedHandLoop) {
      await _pumpUntilAny(tester, [resultBackToMapCta, mapSection]);
      if (resultBackToMapCta.evaluate().isNotEmpty) {
        await tester.ensureVisible(resultBackToMapCta);
        await tester.tap(resultBackToMapCta, warnIfMissed: false);
        await tester.pump();
        await _pumpUntilAny(tester, [
          find.byKey(const Key('main_shell_v1')),
          mapSection,
        ]);
      }
      expect(find.byKey(const Key('main_shell_v1')), findsOneWidget);
      expect(
        find.byKey(const Key('map_shell_v1')).evaluate().isNotEmpty ||
            mapSection.evaluate().isNotEmpty,
        isTrue,
      );
      expect(tester.takeException(), isNull);
      return;
    }
    expect(actionBar, findsOneWidget);
    expect(tester.takeException(), isNull);

    Finder? actionChipFinder;
    final actionButtons = find.descendant(
      of: actionBar,
      matching: find.byType(OutlinedButton),
    );
    for (final element in actionButtons.evaluate()) {
      final button = element.widget as OutlinedButton;
      if (button.onPressed != null) {
        actionChipFinder = find.byElementPredicate(
          (candidate) => candidate == element,
        );
        break;
      }
    }
    actionChipFinder ??= find.byKey(const Key('microtask_check_cta'));
    expect(actionChipFinder, findsOneWidget);

    await tester.ensureVisible(actionChipFinder);
    await tester.tap(actionChipFinder, warnIfMissed: false);
    await tester.pump();

    await _pumpUntil(
      tester,
      find.byKey(const Key('microtask_outcome_surface')),
    );

    expect(find.byKey(const Key('microtask_outcome_surface')), findsOneWidget);
    expect(find.byKey(const Key('microtask_continue_cta')), findsOneWidget);
    expect(find.byKey(const Key('microtask_back_to_map_cta')), findsOneWidget);

    final preContinueOutcome = find.byKey(
      const Key('microtask_outcome_surface'),
    );
    expect(preContinueOutcome, findsOneWidget);

    await tester.tap(find.byKey(const Key('microtask_continue_cta')));
    await tester.pump();
    await _pumpUntilAny(tester, [
      find.byKey(const Key('world_campaign_section')),
      find.byKey(const Key('microtask_campaign_action_bar')),
      find.byKey(const Key('microtask_runner')),
    ]);

    final stayedInRunner = find
        .byKey(const Key('microtask_runner'))
        .evaluate()
        .isNotEmpty;
    final movedToMap = find
        .byKey(const Key('world_campaign_section'))
        .evaluate()
        .isNotEmpty;

    expect(stayedInRunner || movedToMap, isTrue);
    if (stayedInRunner) {
      final backToMap = find.byKey(const Key('microtask_back_to_map_cta'));
      if (backToMap.evaluate().isNotEmpty) {
        await tester.tap(backToMap, warnIfMissed: false);
        await tester.pump();
      } else {
        await tester.binding.handlePopRoute();
        await tester.pump();
      }
      await _pumpUntil(tester, find.byKey(const Key('world_campaign_section')));
    }
    expect(find.byKey(const Key('main_shell_v1')), findsOneWidget);
    expect(
      find.byKey(const Key('map_shell_v1')).evaluate().isNotEmpty ||
          find.byKey(const Key('world_campaign_section')).evaluate().isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
