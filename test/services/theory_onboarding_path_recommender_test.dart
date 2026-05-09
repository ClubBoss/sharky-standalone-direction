import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/player_profile.dart';
import 'package:poker_analyzer/models/theory_cluster_summary.dart';
import 'package:poker_analyzer/services/theory_onboarding_path_recommender.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('recommendEntryLesson chooses cluster matching profile tags', () {
    final clusters = [
      TheoryClusterSummary(
        size: 5,
        entryPointIds: ['a'],
        sharedTags: {'pushfold', 'icm'},
      ),
      TheoryClusterSummary(size: 3, entryPointIds: ['b'], sharedTags: {'cbet'}),
    ];
    final profile = PlayerProfile(tags: {'pushfold'});
    const recommender = TheoryOnboardingPathRecommender();

    final lesson = recommender.recommendEntryLesson(clusters, profile);

    expect(lesson, 'a');
  });

  test('prefers smaller cluster when multiple match', () {
    final clusters = [
      TheoryClusterSummary(
        size: 4,
        entryPointIds: ['l1'],
        sharedTags: {'pushfold'},
      ),
      TheoryClusterSummary(
        size: 2,
        entryPointIds: ['l2'],
        sharedTags: {'pushfold'},
      ),
    ];
    final profile = PlayerProfile(tags: {'pushfold'});
    const recommender = TheoryOnboardingPathRecommender();

    final lesson = recommender.recommendEntryLesson(clusters, profile);

    expect(lesson, 'l2');
  });

  test('recommendEntryLesson falls back to any cluster when no tags match', () {
    final clusters = [
      TheoryClusterSummary(size: 2, entryPointIds: ['x'], sharedTags: {'icm'}),
      TheoryClusterSummary(size: 1, entryPointIds: ['y'], sharedTags: {'cbet'}),
    ];
    final profile = PlayerProfile(tags: {'other'});
    const recommender = TheoryOnboardingPathRecommender();

    final lesson = recommender.recommendEntryLesson(clusters, profile);

    expect(['x', 'y'], contains(lesson));
  });
}
