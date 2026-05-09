import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/training_pack_variant.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/training_pack_play_service.dart';

void main() {
  test('loadSpots caches result and reloads on force', () async {
    final tpl = v2.TrainingPackTemplateV2(
      id: 't',
      name: 'Test',
      trainingType: TrainingType.custom,
      spotCount: 2,
      bb: 10,
      spots: const [],
      positions: const ['sb'],
      meta: {
        'playerStacksBb': const [10, 10],
        'heroRange': const ['AA', 'KK'],
        'bbCallPct': 20,
        'anteBb': 0,
      },
    );
    const variant = TrainingPackVariant(
      position: HeroPosition.sb,
      gameType: GameType.tournament,
    );
    final service = TrainingPackPlayService();
    final list1 = await service.loadSpots(tpl, variant);
    final list2 = await service.loadSpots(tpl, variant);
    expect(identical(list1, list2), isTrue);
    final list3 = await service.loadSpots(tpl, variant, forceReload: true);
    expect(identical(list2, list3), isFalse);
  });
}
