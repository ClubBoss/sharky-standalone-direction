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

  testWidgets('world1 map remains stable on extreme widths', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    for (final width in <double>[390, 820, 1600]) {
      await tester.pumpWidget(_hostWithWidth(width));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));

      for (final moduleId in kWorld1CanonicalModuleOrder) {
        expect(
          find.byKey(ValueKey<String>('world1_node_$moduleId')),
          findsOneWidget,
          reason: 'Expected canonical node for width=$width',
        );
      }
      expect(
        find.byKey(const ValueKey<String>('world1_state_current')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
