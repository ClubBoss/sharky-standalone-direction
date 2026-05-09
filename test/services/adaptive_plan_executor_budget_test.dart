import 'package:poker_analyzer/testing/test_shims.dart';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart' as v2;
import 'package:poker_analyzer/services/adaptive_plan_executor.dart';
import 'package:poker_analyzer/services/learning_path_store.dart';
import 'package:poker_analyzer/services/targeted_pack_booster_engine.dart';
import 'package:poker_analyzer/services/auto_format_selector.dart';
import 'package:poker_analyzer/services/pack_quality_gatekeeper_service.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';

class _FakeBoosterEngine extends TargetedPackBoosterEngine {
  @override
  Future<List<TrainingPackTemplate>> generateClusterBoosterPacks({
    required List<SkillTagCluster> clusters,
    String triggerReason = 'cluster',
  }) async {
    List<TrainingPackTemplate> build(String id, List<String> tags] => [
      TrainingPackTemplate(
        id: id,
        name: id,
        trainingType: TrainingType.booster,
        tags: tags,
        spots: [
          TrainingPackSpot(id: '${id}s', tags: tags, board: ['Ah']),
        ],
        spotCount: 10,
        meta: {'qualityScore': 1.0},
      ),
    ];
    return [
      build('b1', ['a']].first,
      build('b2', ['b']].first,
      build('b3', ['a', 'b']].first,
    ];
  }
}

class _FakeFormatSelector extends AutoFormatSelector {
  @override
  FormatMeta effectiveFormat({String? audience}) =>
      FormatMeta(spotsPerPack: 10, streets: 1, theoryRatio: 0.5);
}

class _PassGatekeeper extends PackQualityGatekeeperService {
  _PassGatekeeper();
  @override
  bool isQualityAcceptable(pack, {double minScore = 0.7, seedIssues = {}}) {
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late LearningPathStore store;
  late AdaptivePlanExecutor exec;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'planner.budgetPaddingMins': 0});
    tempDir = await Directory.systemTemp.createTemp('plan');
    store = LearningPathStore(rootDir: tempDir.path);
    exec = AdaptivePlanExecutor(
      boosterEngine: _FakeBoosterEngine(),
      formatSelector: _FakeFormatSelector(),
      gatekeeper: _PassGatekeeper(),
      store: store,
    );
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('honors budget and drops lowest-EV booster first', () async {
    final cluster = SkillTagCluster(
      tags: ['a', 'b'],
      clusterId: 'c1',
      themeName: 'T',
    );
    final plan = AdaptivePlan(
      clusters: [cluster],
      estMins: 0,
      tagWeights: {'a': 2.0, 'b': 1.0},
      mix: {'theory': 0, 'booster': 2, 'assessment': 1},
    );
    final modules = await exec.execute(
      userId: 'u1',
      plan: plan,
      budgetMinutes: 14,
      sig: 'sig',
    );
    expect(modules, hasLength(1));
    final m = modules.first;
    expect(m.boosterPackIds, ['b3']);
    expect(m.itemsDurations?['boosterMins'], 6);
    expect(m.itemsDurations?['assessmentMins'], 3);
  });
}

