import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  test('dynamicParams handGroupTags expand into handGroup', () {
    final tpl = TrainingPackTemplate(
      id: 'id',
      name: 'name',
      trainingType: TrainingType.pushFold,
      meta: {
        'dynamicParams': {
          'handGroupTags': ['pockets'],
          'count': 1,
        },
      },
    );
    final spots = tpl.generateDynamicSpotSamples();
    expect(spots.length, 1);
  });
}
