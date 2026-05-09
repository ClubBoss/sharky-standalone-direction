import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/screens/training_session_summary_screen.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: disambiguate import
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/training_session.dart';
import 'package:poker_analyzer/services/training_session_service.dart';
import 'package:poker_analyzer/services/weak_spot_recommendation_service.dart';
import 'package:poker_analyzer/services/mistake_review_pack_service.dart';
import 'package:poker_analyzer/services/adaptive_training_service.dart';
import 'package:poker_analyzer/services/daily_tip_service.dart';
import 'package:poker_analyzer/services/next_step_engine.dart';
import 'package:poker_analyzer/services/training_pack_stats_service.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/saved_hand_storage_service.dart';
import 'package:poker_analyzer/services/saved_hand_manager_service.dart';
import 'package:poker_analyzer/services/player_style_service.dart';
import 'package:poker_analyzer/services/progress_forecast_service.dart';
import 'package:provider/provider.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('summary shows accuracy and deltas', (tester) async {
    final template = v2.TrainingPackTemplateV2(
      id: 'tpl',
      name: 'Test',
      trainingType: TrainingType.pushFold,
      spots: [
        TrainingPackSpot(id: 's1', hand: v2models.HandData()),
        TrainingPackSpot(id: 's2', hand: v2models.HandData()),
        TrainingPackSpot(id: 's3', hand: v2models.HandData()),
        TrainingPackSpot(id: 's4', hand: v2models.HandData()),
      ],
      meta: {'evCovered': 2, 'icmCovered': 3},
      created: DateTime.now(),
    );

    final session = TrainingSession(
      id: 'sess',
      templateId: template.id,
      completedAt: DateTime.now(),
      results: {'s1': true, 's2': true, 's3': true, 's4': false},
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AdaptiveTrainingService>(
            create: (_) => _FakeAdaptiveTrainingService(),
          ),
          ChangeNotifierProvider<MistakeReviewPackService>(
            create: (_) => _FakeMistakeReviewPackService(),
          ),
          ChangeNotifierProvider<WeakSpotRecommendationService>(
            create: (_) => _FakeWeakSpotRecommendationService(),
          ),
          ChangeNotifierProvider<DailyTipService>(
            create: (_) => _FakeDailyTipService(),
          ),
          ChangeNotifierProvider<TrainingSessionService>(
            create: (_) => _DummyTrainingSessionService(),
          ),
          ChangeNotifierProvider<NextStepEngine>(
            create: (_) => _FakeNextStepEngine(),
          ),
          ChangeNotifierProvider<SavedHandManagerService>(
            create: (_) =>
                SavedHandManagerService(storage: SavedHandStorageService()),
          ),
          ChangeNotifierProvider<PlayerStyleService>(
            create: (context) => PlayerStyleService(
              hands: context.read<SavedHandManagerService>(),
            ),
          ),
          ChangeNotifierProvider<ProgressForecastService>(
            create: (context) => ProgressForecastService(
              hands: context.read<SavedHandManagerService>(),
              style: context.read<PlayerStyleService>(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TrainingSessionSummaryScreen(
            session: session,
            template: template,
            preEvPct: 25,
            preIcmPct: 25,
            xpEarned: 10,
            xpMultiplier: 1.0,
            streakMultiplier: 1.0,
            tagDeltas: {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('75.0%'), findsOneWidget);
    expect(find.text('Прогресс EV +25.0%, ICM +50.0%'), findsOneWidget);
  });

  testWidgets('skill gains section shows deltas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TrainingSessionSummaryScreen(
          session: TrainingSession(
            id: 'id',
            templateId: 't',
            completedAt: null,
            results: {},
          ),
          template: v2.TrainingPackTemplateV2(
            id: 't',
            name: '',
            trainingType: TrainingType.pushFold,
            spots: [],
            created: DateTime(0),
          ),
          preEvPct: 0,
          preIcmPct: 0,
          xpEarned: 0,
          xpMultiplier: 1.0,
          streakMultiplier: 1.0,
          tagDeltas: {'a': 0.05},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Skill Gains'), findsOneWidget);
    expect(find.text('+5.00%'), findsOneWidget);
  });

  testWidgets('streak bonus text is displayed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TrainingSessionSummaryScreen(
          session: TrainingSession(
            id: 'id2',
            templateId: 't',
            completedAt: null,
            results: {},
          ),
          template: v2.TrainingPackTemplateV2(
            id: 't',
            name: '',
            trainingType: TrainingType.pushFold,
            spots: [],
            created: DateTime(0),
          ),
          preEvPct: 0,
          preIcmPct: 0,
          xpEarned: 10,
          xpMultiplier: 1.0,
          streakMultiplier: 1.15,
          tagDeltas: {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('🔥 Бонус за стрик: +15% XP'), findsOneWidget);
  });
}

class _DummyTrainingSessionService extends TrainingSessionService {}

class _FakeMistakeReviewPackService extends ChangeNotifier
    implements MistakeReviewPackService {
  @override
  bool hasMistakes() => false;
  @override
  Future<v2.TrainingPackTemplateV2?> buildPack(BuildContext context) async =>
      null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWeakSpotRecommendationService extends ChangeNotifier
    implements WeakSpotRecommendationService {
  @override
  WeakSpotRecommendation? get recommendation => null;
  @override
  List<WeakSpotRecommendation> get recommendations => [];
  @override
  Future<v2.TrainingPackTemplateV2?> buildPack([HeroPosition? pos]) async =>
      null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAdaptiveTrainingService extends ChangeNotifier
    implements AdaptiveTrainingService {
  @override
  final ValueNotifier<List<v2.TrainingPackTemplateV2>> recommendedNotifier =
      ValueNotifier(<v2.TrainingPackTemplateV2>[]);
  @override
  List<v2.TrainingPackTemplateV2> get recommended => [];
  @override
  TrainingPackStat? statFor(String id) => null;
  @override
  Future<void> refresh() async {}
  @override
  Future<v2.TrainingPackTemplateV2> buildAdaptivePack() async =>
      v2.TrainingPackTemplateV2(
        id: '',
        name: '',
        trainingType: TrainingType.pushFold,
        spots: [],
        created: DateTime.now(),
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDailyTipService extends ChangeNotifier implements DailyTipService {
  @override
  String get tip => '';
  @override
  Future<void> ensureTodayTip() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNextStepEngine extends ChangeNotifier implements NextStepEngine {
  @override
  NextStepSuggestion? get suggestion => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
