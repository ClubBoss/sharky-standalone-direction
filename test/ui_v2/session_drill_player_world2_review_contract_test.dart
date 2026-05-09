import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 40,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description}');
  }

  testWidgets('w2.s05 exposes the compact World 2 review connector', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(1290, 3000);
    tester.view.devicePixelRatio = 1.0;

    final drills = (await tester.runAsync(
      () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s05'),
    ))!;
    expect(
      drills.map((item) => item.drillId).toList(),
      equals(const <String>[
        'bridge_review_dry_cheap_continue_v1',
        'bridge_review_wet_expensive_release_v1',
        'bridge_review_paired_fair_price_continue_v1',
        'bridge_review_connected_future_street_release_v1',
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w2.s05',
          debugDrillsOverrideV1: drills,
        ),
      ),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('session_drill_player_world2_review_intro_card_v1')),
    );

    expect(
      find.byKey(const Key('session_drill_player_world2_review_intro_card_v1')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const Key('session_drill_player_world2_review_intro_line_1_v1'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_fold_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_call_v1')),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_fold_v1')),
    );
    await _pumpUntilFound(
      tester,
      find.byKey(const Key('session_drill_player_world2_review_recap_card_v1')),
    );

    expect(
      find.byKey(const Key('session_drill_player_complete')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_world2_review_recap_card_v1')),
      findsOneWidget,
    );
  });
}
