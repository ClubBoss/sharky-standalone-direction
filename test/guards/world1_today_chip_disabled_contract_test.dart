import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

Widget _host() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const UiV2ProgressMapScreenV2(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugHasWorld1MicroTaskPackOverride = null;
  });

  tearDown(() {
    debugHasWorld1MicroTaskPackOverride = null;
  });

  testWidgets('today chip is disabled when current module has no pack', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    debugHasWorld1MicroTaskPackOverride = (_) => false;

    await tester.pumpWidget(_host());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(
      find.byKey(
        Key('world1_today_chip_disabled_${kWorld1CanonicalModuleOrder.first}'),
      ),
      findsOneWidget,
    );
    final disabledEntry = find.byKey(
      Key(
        'world1_foundations_entry_disabled_${kWorld1CanonicalModuleOrder.first}',
      ),
    );
    expect(disabledEntry, findsOneWidget);

    await tester.tap(disabledEntry, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('microtask_runner')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
