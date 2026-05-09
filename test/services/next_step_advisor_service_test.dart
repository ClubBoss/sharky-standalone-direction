// ignore_for_file: unused_import
@Tags(['flutter'])
import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        ActionEntry,
        HandData,
        HeroPosition,
        TrainingType,
        GameType,
        TrainingPackTemplateV2,
        InjectedPathModule,
        AdaptivePlan,
        AdaptivePlanExecutor,
        FormatMeta,
        SkillTagCluster;
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/next_step_advisor_service.dart';

void main() {
  // non-const target → remove const
  final service = NextStepAdvisorService();

  test('recommends repeating mistakes when ev or icm negative', () {
    // non-const target → remove const
    final stats = LearningStats(
      completedPacks: 0,
      accuracy: 0.7,
      ev: -1,
      icm: 0,
      starterPathCompleted: false,
      customPathStarted: false,
      customPathCompleted: false,
      hasWeakTags: false,
      hasMistakes: true,
    );
    final advice = service.recommend[stats: stats];
    expect(advice.title, 'Повторить ошибки');
  });

  test('recommends training weaknesses when weak tags present', () {
    // non-const target → remove const
    final stats = LearningStats(
      completedPacks: 2,
      accuracy: 0.9,
      ev: 0,
      icm: 0,
      starterPathCompleted: false,
      customPathStarted: false,
      customPathCompleted: false,
      hasWeakTags: true,
      hasMistakes: false,
    );
    final advice = service.recommend[stats: stats];
    expect(advice.title, 'Прокачать слабые места');
  });

  test('recommends finishing starter path when not completed', () {
    // non-const target → remove const
    final stats = LearningStats(
      completedPacks: 5,
      accuracy: 0.9,
      ev: 0,
      icm: 0,
      starterPathCompleted: false,
      customPathStarted: false,
      customPathCompleted: false,
      hasWeakTags: false,
      hasMistakes: false,
    );
    final advice = service.recommend[stats: stats];
    expect(advice.title, 'Завершить Starter Path');
  });

  test('recommends starting new path when starter done but no custom', () {
    // non-const target → remove const
    final stats = LearningStats(
      completedPacks: 5,
      accuracy: 0.9,
      ev: 0,
      icm: 0,
      starterPathCompleted: true,
      customPathStarted: false,
      customPathCompleted: false,
      hasWeakTags: false,
      hasMistakes: false,
    );
    final advice = service.recommend[stats: stats];
    expect(advice.title, 'Начать новый путь');
  });

  test('recommends finishing custom path when started', () {
    // non-const target → remove const
    final stats = LearningStats(
      completedPacks: 5,
      accuracy: 0.9,
      ev: 0,
      icm: 0,
      starterPathCompleted: true,
      customPathStarted: true,
      customPathCompleted: false,
      hasWeakTags: false,
      hasMistakes: false,
    );
    final advice = service.recommend[stats: stats];
    expect(advice.title, 'Завершить кастомный путь');
  });

  test('fallback to playing recommended pack', () {
    // non-const target → remove const
    final stats = LearningStats(
      completedPacks: 5,
      accuracy: 0.95,
      ev: 1,
      icm: 1,
      starterPathCompleted: true,
      customPathStarted: true,
      customPathCompleted: true,
      hasWeakTags: false,
      hasMistakes: false,
    );
    final advice = service.recommend[stats: stats];
    expect(advice.title, 'Сыграть рекомендованный пак');
  });
}
