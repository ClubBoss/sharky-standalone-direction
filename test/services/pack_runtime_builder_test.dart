import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/pack_runtime_builder.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/models/v2/training_pack_variant.dart';
import 'package:poker_analyzer/models/v2/hero_position.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

void main() {
  test('buildIfNeeded returns cached list', () async {
    final tpl = v2.TrainingPackTemplateV2(
      id: 't',
      name: 'Test',
      trainingType: TrainingType.custom,
      spotCount: 2,
      bb: 10,
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
    final builder = PackRuntimeBuilder();
    final list1 = await builder.buildIfNeeded(tpl, variant);
    await Future.delayed(Duration.zero);
    final list2 = await builder.buildIfNeeded(tpl, variant);
    expect(identical(list1, list2), isTrue);
  });
}
