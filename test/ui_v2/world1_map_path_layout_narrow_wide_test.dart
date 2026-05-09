import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

Widget _hostWithWidth(double width) {
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

  testWidgets('world1 path layout builds for narrow and wide widths', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(_hostWithWidth(640));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(
      find.byKey(
        ValueKey<String>('world1_node_${kWorld1CanonicalModuleOrder.first}'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_hostWithWidth(1280));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(
      find.byKey(
        ValueKey<String>('world1_node_${kWorld1CanonicalModuleOrder.first}'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
