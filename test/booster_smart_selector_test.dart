import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/booster_smart_selector.dart';
import 'package:poker_analyzer/services/booster_cluster_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

TrainingPackSpot _spot(String id, String cards, HeroPosition pos) {
  final hand = HandData.fromSimpleInput(cards, pos, 10);
  return TrainingPackSpot(id: id, hand: hand);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('selectBest picks diverse spots', () {
    final s1 = _spot['a', 'AhKh', HeroPosition.btn];
    final s2 = _spot['b', 'AhKh', HeroPosition.btn];
    final s3 = _spot['c', '9c8c', HeroPosition.sb];

    final pack = TrainingPackTemplate(
      id: 'p1',
      name: 'Test',
      trainingType: TrainingType.pushFold,
      spots: [s1, s2, s3],
      spotCount: 3,
    );

    final clusters = BoosterClusterEngine().analyzePack[pack];
    final selector = BoosterSmartSelector();
    final res = selector.selectBest(pack, clusters, maxSpots: 2);

    expect(res.spots.length, 2);
    final ids = res.spots.map((e) => e.id).toList();
    expect(ids.contains('c'), true);
  });
}
