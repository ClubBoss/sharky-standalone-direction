import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

Widget _host(double width) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 900)),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const UiV2ProgressMapScreenV2(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('checkpoint markers render and stay non-tappable', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    for (final width in <double>[390, 820]) {
      await tester.pumpWidget(_host(width));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 260));

      final cp3 = find.byKey(const Key('world1_checkpoint_3'));
      final cp6 = find.byKey(const Key('world1_checkpoint_6'));
      expect(cp3, findsOneWidget);
      expect(cp6, findsOneWidget);

      await tester.tap(cp3, warnIfMissed: false);
      await tester.tap(cp6, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('microtask_runner')), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
}
