import 'package:test/test.dart';
// ignore: unused_import
import 'package:poker_analyzer/ui/flutter_stub_test.dart'
    if (dart.library.ui) 'package:flutter/material.dart';
import 'package:poker_analyzer/ui/training_type_engine_test_api.dart'
    if (dart.library.ui) 'package:poker_analyzer/ui/training_type_engine_test_api_flutter.dart';
import 'package:poker_analyzer/models/game_type.dart';
import 'package:poker_analyzer/ui/training_pack_template_v2_test_api.dart'
    if (dart.library.ui) 'package:poker_analyzer/ui/training_pack_template_v2_test_api_flutter.dart';
import 'package:poker_analyzer/ui/learning_path_booster_engine_test_api.dart'
    if (dart.library.ui) 'package:poker_analyzer/ui/learning_path_booster_engine_test_api_flutter.dart';

class _FakeTagMasteryService implements TagMasteryService {
  @override
  Future<Map<String, double>> computeMastery({bool force = false}) async => {
    'push fold': 0.2,
    'icm': 0.6,
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('LearningPathBoosterEngine', () {
    test('returns boosters for weak tags', () async {
      final engine = LearningPathBoosterEngine(
        library: [
          TrainingPackTemplateV2(
            id: 'pack_a',
            name: 'ICM Pack',
            tags: const ['ICM'],
            trainingType: TrainingType.pushFold,
            meta: const {'rankScore': 1.0},
            gameType: GameType.tournament,
          ),
          TrainingPackTemplateV2(
            id: 'pack_b',
            name: 'Push/Fold Pack',
            tags: const ['Push Fold'],
            trainingType: TrainingType.pushFold,
            meta: const {'rankScore': 2.0},
            gameType: GameType.tournament,
          ),
        ],
      );

      final boosters = await engine.getBoosterPacks(
        mastery: _FakeTagMasteryService(),
        maxPacks: 2,
      );

      expect(boosters, isNotEmpty);
      expect(
        boosters.first.id,
        equals('pack_b'),
        reason: 'Pack with the weakest tag should be preferred.',
      );
    });
  });
}
