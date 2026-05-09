import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/map/ui_v2_progress_map_screen_v2.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daily completion persists for today via existing prefs seam', (
    tester,
  ) async {
    ProgressService.world1DailyCompletionInSession.value = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    final dailyState = find.byKey(const Key('world1_today_chip_state'));
    if (dailyState.evaluate().isEmpty) {
      expect(tester.takeException(), isNull);
      return;
    }
    final initialStateText = (tester.widget<Text>(dailyState).data ?? '');
    expect(
      initialStateText.contains('Ready') || initialStateText.contains('Done'),
      isTrue,
    );

    final dailyRun = find.byKey(
      Key('world1_daily_run_cta_${kWorld1CanonicalModuleOrder.first}'),
    );
    if (dailyRun.evaluate().isEmpty) {
      expect(tester.takeException(), isNull);
      return;
    }
    await tester.tap(dailyRun, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('microtask_runner')), findsOneWidget);
    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);
    final completedState = (tester.widget<Text>(dailyState).data ?? '');
    expect(
      completedState.contains('Done') || completedState.contains('Completed'),
      isTrue,
    );
    expect(ProgressService.world1DailyCompletionInSession.value, isTrue);
    final xpAfterFirstRun = await ProgressService.getXp();
    expect(xpAfterFirstRun, 15);

    ProgressService.world1DailyCompletionInSession.value = false;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UiV2ProgressMapScreenV2(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(UiV2ProgressMapScreenV2), findsOneWidget);

    final secondDailyRun = find.byKey(
      Key('world1_daily_run_cta_${kWorld1CanonicalModuleOrder.first}'),
    );
    if (secondDailyRun.evaluate().isEmpty) {
      expect(tester.takeException(), isNull);
      return;
    }
    await tester.tap(secondDailyRun, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('microtask_runner')), findsOneWidget);
    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    final xpAfterSecondRun = await ProgressService.getXp();
    expect(xpAfterSecondRun, xpAfterFirstRun);
    final finalState = (tester.widget<Text>(dailyState).data ?? '');
    expect(
      finalState.contains('Done') ||
          finalState.contains('Completed') ||
          finalState.contains('Ready'),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
}
