import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/skill_recovery_pack_engine.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/training_tag_performance_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  TrainingPackTemplate tpl({
    required String id,
    required List<String> tags,
    bool suggested = false,
    double pop = 0,
  }) {
    return TrainingPackTemplate(
      id: id,
      name: id,
      trainingType: TrainingType.pushFold,
      tags: tags,
      meta: {'popularity': pop, if (suggested) 'suggested': true},
    );
  }

  test('returns pack matching dormant tag', () async {
    final library = [
      tpl(id: 'a', tags: ['cbet'], suggested: true),
    ];
    final dormant = [
      TagPerformance(
        tag: 'cbet',
        totalAttempts: 0,
        correct: 0,
        accuracy: 0,
        lastTrained: null,
      ),
    ];
    final result = await SkillRecoveryPackEngine.suggestRecoveryPack(
      library: library,
      detectDormantTags: () async => dormant,
    );
    expect(result?.id, 'a');
  });

  test('respects excluded ids', () async {
    final library = [
      tpl(id: 'a', tags: ['cbet'], suggested: true),
      tpl(id: 'b', tags: ['cbet']),
    ];
    final dormant = [
      TagPerformance(
        tag: 'cbet',
        totalAttempts: 0,
        correct: 0,
        accuracy: 0,
        lastTrained: null,
      ),
    ];
    final result = await SkillRecoveryPackEngine.suggestRecoveryPack(
      library: library,
      detectDormantTags: () async => dormant,
      excludedPackIds: {'a'},
    );
    expect(result?.id, 'b');
  });

  test('falls back when no match', () async {
    final library = [
      tpl(id: 'f', tags: ['fundamentals']),
      tpl(id: 's', tags: ['starter'], pop: 5),
    ];
    final result = await SkillRecoveryPackEngine.suggestRecoveryPack(
      library: library,
      detectDormantTags: () async => [],
    );
    expect(result?.id, 'f');
  });
}
