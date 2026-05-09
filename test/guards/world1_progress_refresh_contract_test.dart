import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('map refreshes current marker after module completion signal', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      '${ProgressService.completedPrefix}${kWorld1CanonicalModuleOrder.first}':
          false,
      '${ProgressService.completedPrefix}${kWorld1CanonicalModuleOrder[1]}':
          false,
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildThemeV2(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );

    await tester.pumpAndSettle();

    final l1Node = find.byKey(
      ValueKey<String>('world1_node_${kWorld1CanonicalModuleOrder.first}'),
    );
    final l2Node = find.byKey(
      ValueKey<String>('world1_node_${kWorld1CanonicalModuleOrder[1]}'),
    );
    expect(l1Node, findsOneWidget);
    expect(l2Node, findsOneWidget);
    expect(
      find.descendant(of: l1Node, matching: find.text('Current')),
      findsOneWidget,
    );

    await ProgressService.markModuleCompleted(
      kWorld1CanonicalModuleOrder.first,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: l1Node, matching: find.text('Completed')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: l2Node, matching: find.text('Current')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
