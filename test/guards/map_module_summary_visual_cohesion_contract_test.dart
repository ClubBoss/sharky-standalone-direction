import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('map and module summary cohort expose premium cohesion surfaces', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(640, 900)),
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const UiV2ProgressMapScreenV2(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byKey(const Key('map_top_bar_surface_v1')), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: ModuleSummaryScreen(
          moduleData: <String, dynamic>{
            'id': 'intro_welcome',
            'title': 'Welcome to Poker',
            'description': 'Why poker is a game of skill.',
            'tier': 'Free',
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('module_summary_hero_card_v1')), findsOneWidget);
    expect(find.byKey(const Key('module_summary_tier_pill_v1')), findsOneWidget);
    expect(find.byKey(const Key('module_summary_metadata_v1')), findsOneWidget);
  });
}
