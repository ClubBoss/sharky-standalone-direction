import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/theme/theme_v2.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('map keeps focus marker on current node after return refresh', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      '${ProgressService.completedPrefix}intro_welcome': false,
      '${ProgressService.completedPrefix}intro_game_types': false,
      '${ProgressService.completedPrefix}intro_actions': false,
      '${ProgressService.completedPrefix}intro_hand_rankings': false,
      '${ProgressService.completedPrefix}intro_how_to_win': false,
      '${ProgressService.completedPrefix}core_rules_and_setup': false,
      '${ProgressService.completedPrefix}tier_1_checkpoint': false,
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

    expect(
      find.byKey(const ValueKey<String>('world1_state_current')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('world1_focus_current_node')), findsOneWidget);

    await ProgressService.markModuleCompleted('intro_welcome');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('world1_state_current')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('world1_focus_current_node')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
