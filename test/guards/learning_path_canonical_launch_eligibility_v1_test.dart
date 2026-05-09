import 'package:poker_analyzer/canonical/learning_path_canonical_launch_eligibility_v1.dart';
import 'package:test/test.dart';

void main() {
  test('verified beginner learning-path pack maps to canonical World1 spine', () {
    expect(
      canonicalRunnerModuleIdForLearningPathPracticePackIdV1(
        'open_fold_early_mtt',
      ),
      'world1_spine_campaign_v1',
    );
    expect(
      canonicalModuleIdForLearningPathPracticePackIdV1('open_fold_early_mtt'),
      'world1_spine_campaign_v1',
    );
  });
}
