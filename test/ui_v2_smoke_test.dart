import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/league/ui_v2_league_dashboard_screen.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('UiV2ProgressMapScreenV2 renders without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: buildThemeV2(), home: const UiV2ProgressMapScreenV2()),
    );

    for (var i = 0; i < 20; i++) {
      final hasReadySurface = find
          .byKey(const Key('world_campaign_section'))
          .evaluate()
          .isNotEmpty;
      final hasLoadingSurface = find.text('Loading...').evaluate().isNotEmpty;
      if (hasReadySurface || hasLoadingSurface) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(
      find.byKey(const Key('world_campaign_section')).evaluate().isNotEmpty ||
          find.text('Loading...').evaluate().isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('UiV2LeagueDashboardScreen renders without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildThemeV2(),
        home: const UiV2LeagueDashboardScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('League Dashboard'), findsOneWidget);
    expect(find.text('XP Progress'), findsOneWidget);
  });
}
