import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';
import 'package:poker_analyzer/services/pack_augmentation_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  test('augment increases pack count and marks generated', () {
    final spot = TrainingPackSpot(
      id: 's1',
      hand: HandData.fromSimpleInput('AhAs', HeroPosition.sb, 10),
    );
    final pack = TrainingPackTemplate(
      id: 'p1',
      name: 'Test',
      trainingType: TrainingType.pushFold,
      spots: [spot],
    );
    const engine = PackAugmentationEngine();
    final res = engine.augment[[pack]];
    expect(res.length, 2);
    final generated = res.last;
    expect(generated.name.contains('Extended'), true);
    expect(generated.isGeneratedPack, true);
    expect(generated.spots.every((s) => s.meta['variation'] == true), true);
  });
}
