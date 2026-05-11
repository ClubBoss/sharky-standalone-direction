import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('recommendation widget cluster keeps legacy launcher ownership explicit', () {
    final recommenderBanner = File(
      'lib/widgets/training_recommender_banner.dart',
    ).readAsStringSync();
    final nextPackCard = File(
      'lib/widgets/recommended_next_pack_card.dart',
    ).readAsStringSync();
    final drillTile = File(
      'lib/widgets/recommended_drill_tile.dart',
    ).readAsStringSync();

    expect(
      recommenderBanner.contains(
        'await TrainingSessionLauncher().launch(pack);',
      ),
      isTrue,
      reason:
          'Training recommender banner should remain an explicit non-canonical launcher entrypoint.',
    );
    expect(
      nextPackCard.contains('await TrainingSessionLauncher().launch(pack);'),
      isTrue,
      reason:
          'Recommended next pack card should remain an explicit non-canonical launcher entrypoint.',
    );
    expect(
      drillTile.contains(
        'await TrainingSessionLauncher().launch(pack, startIndex: start);',
      ),
      isTrue,
      reason:
          'Recommended drill tile should remain an explicit non-canonical launcher entrypoint with resume support.',
    );

    expect(
      recommenderBanner.contains('pushWorld1FoundationsRunnerV1'),
      isFalse,
      reason:
          'Recommendation widgets should not directly own canonical runner launching in this seam.',
    );
    expect(
      nextPackCard.contains('pushWorld1FoundationsRunnerV1'),
      isFalse,
      reason:
          'Recommended next pack card should not directly own canonical runner launching in this seam.',
    );
    expect(
      drillTile.contains('pushWorld1FoundationsRunnerV1'),
      isFalse,
      reason:
          'Recommended drill tile should not directly own canonical runner launching in this seam.',
    );

    expect(
      recommenderBanner.contains(
        'world1_foundations_microtask_runner_screen.dart',
      ),
      isFalse,
      reason:
          'Training recommender banner should not import canonical runner implementation directly.',
    );
    expect(
      nextPackCard.contains('world1_foundations_microtask_runner_screen.dart'),
      isFalse,
      reason:
          'Recommended next pack card should not import canonical runner implementation directly.',
    );
    expect(
      drillTile.contains('world1_foundations_microtask_runner_screen.dart'),
      isFalse,
      reason:
          'Recommended drill tile should not import canonical runner implementation directly.',
    );
  });
}
