import 'package:poker_analyzer/testing/test_shims.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/booster_refiner_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/hand_data.dart' as v2models;
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('refineAll updates booster packs', () async {
    final dir = await Directory.systemTemp.createTemp();
    final spot1 = TrainingPackSpot(id: 's1', hand: v2models.HandData());
    final spot2 = TrainingPackSpot(id: 's1', hand: v2models.HandData());
    final tpl = v2.TrainingPackTemplateV2(
      id: 'p1',
      name: 'B',
      trainingType: TrainingType.pushFold,
      gameType: GameType.tournament,
      tags: ['cbet'],
      spots: [spot1, spot2],
      spotCount: 2,
      created: DateTime.now(),
      positions: [],
      meta: {
        'type': 'booster',
        'tag': 'CBet',
        'generatedBy': 'BoosterSuggestionEngine v1',
      },
    );
    final file = File('${dir.path}/p1.yaml');
    await file.writeAsString(tpl.toYamlString());

    final count = await BoosterRefinerEngine().refineAll(dir: dir.path);
    final refined = v2.TrainingPackTemplateV2.fromYamlString(
      await file.readAsString(),
    );

    expect(count, 1);
    expect(refined.spots.length, 1);
    expect(
      refined.spots.first.explanation,
      'Рекомендовано для изучения темы: cbet',
    );
    expect(refined.meta['tag'], 'cbet');
    expect(refined.meta['version'], '1');
    expect(refined.meta['generatedBy'], 'BoosterSuggestionEngine v1');

    await dir.delete(recursive: true);
  });
}
