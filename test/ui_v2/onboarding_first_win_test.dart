import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/main.dart' show navigatorKey;
import 'package:poker_analyzer/models/v2/spot_template.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
import 'package:poker_analyzer/onboarding/onboarding_flow_manager.dart';
import 'package:poker_analyzer/screens/training_session_screen.dart';
import 'package:poker_analyzer/screens/v2/training_pack_play_screen.dart';
import 'package:poker_analyzer/services/pack_library_service.dart';
import 'package:poker_analyzer/services/player_style_service.dart';
import 'package:poker_analyzer/services/progress_forecast_service.dart';
import 'package:poker_analyzer/services/saved_hand_manager_service.dart';
import 'package:poker_analyzer/services/saved_hand_storage_service.dart';
import 'package:poker_analyzer/services/smart_review_service.dart';
import 'package:poker_analyzer/services/training_stats_service.dart';

void main() {
  testWidgets(
    'onboarding starter pack reaches pack-play host, not legacy training session',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await SmartReviewService.instance.clearMistakes();
      tester.view.physicalSize = const Size(1600, 4000);
      tester.view.devicePixelRatio = 1.0;

      final storage = SavedHandStorageService();
      final stats = TrainingStatsService();
      final hands = SavedHandManagerService(storage: storage, stats: stats);
      final style = PlayerStyleService(hands: hands);
      final forecast = ProgressForecastService(hands: hands, style: style);

      final starterPack = TrainingPackTemplateV2(
        id: 'onboarding-test-pack',
        name: 'Onboarding Test Pack',
        description: 'Test pack',
        goal: 'Learn onboarding',
        category: 'test',
        trainingType: TrainingType.pushFold,
        spots: <SpotTemplate>[SpotTemplate(id: 'starter_spot')],
        tags: const <String>['starter'],
      );
      PackLibraryService.overrideRecommendedStarter(() async => starterPack);

      addTearDown(() {
        PackLibraryService.overrideRecommendedStarter(null);
      });
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      addTearDown(() async {
        await SmartReviewService.instance.clearMistakes();
      });

      var started = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ProgressForecastService>.value(
              value: forecast,
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                if (!started) {
                  started = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    OnboardingFlowManager.instance.maybeStart(context);
                  });
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TrainingPackPlayScreen), findsOneWidget);
      expect(find.byType(TrainingSessionScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
