import 'package:poker_analyzer/testing/test_shims.dart'
    hide
        TrainingSessionService,
        TrainingPackTemplate,
        TrainingPackTemplateV2; // fix: hide shim
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart'
    as v2; // fix: v2 alias
import 'package:poker_analyzer/services/training_session_service.dart';
import 'package:poker_analyzer/services/smart_review_service.dart';
import 'package:poker_analyzer/services/learning_path_progress_service.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('basic session flow', () async {
    SharedPreferences.setMockInitialValues({});
    await SmartReviewService.instance.load();
    final s1 = TrainingPackSpot(id: 'a');
    final s2 = TrainingPackSpot(id: 'b');
    final spots = <TrainingPackSpot>[s1, s2];
    final tpl = v2.TrainingPackTemplateV2(
      id: 't',
      name: 't',
      trainingType: TrainingType.quiz,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>[],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final service = TrainingSessionService();
    await service.startSession(tpl, persist: false);
    expect(service.currentSpot?.id, 'a');
    service.nextSpot();
    expect(service.currentSpot?.id, 'b');
    service.prevSpot();
    expect(service.currentSpot?.id, 'a');
    service.submitResult('a', 'fold', true);
    expect(service.results['a'], true);
    expect(service.correctCount, 1);
  });

  test('custom path session marks started flag', () async {
    SharedPreferences.setMockInitialValues({});
    await SmartReviewService.instance.load();
    LearningPathProgressService.instance.mock = true;
    await LearningPathProgressService.instance.resetProgress();
    await LearningPathProgressService.instance.resetCustomPath();
    final spot = TrainingPackSpot(id: 'c');
    final spots = <TrainingPackSpot>[spot];
    final tpl = v2.TrainingPackTemplateV2(
      id: 'c',
      name: 'c',
      trainingType: TrainingType.quiz,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>['customPath'],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final service = TrainingSessionService();
    await service.startSession(tpl, persist: false);
    final started = await LearningPathProgressService.instance
        .isCustomPathStarted();
    expect(started, isTrue);
  });

  test('custom path completion marked after finish', () async {
    SharedPreferences.setMockInitialValues({});
    await SmartReviewService.instance.load();
    LearningPathProgressService.instance.mock = true;
    await LearningPathProgressService.instance.resetProgress();
    await LearningPathProgressService.instance.resetCustomPath();
    final spot = TrainingPackSpot(id: 'd');
    final spots = <TrainingPackSpot>[spot];
    final tpl = v2.TrainingPackTemplateV2(
      id: 'd',
      name: 'd',
      trainingType: TrainingType.quiz,
      spots: spots,
      spotCount: spots.length,
      tags: const <String>['customPath'],
      positions: const <String>[],
      meta: const <String, Object?>{},
      created: DateTime.now(),
    ); // fix: v2 ctor/collections/types
    final service = TrainingSessionService();
    await service.startSession(tpl, persist: false);
    service.nextSpot();
    final done = await LearningPathProgressService.instance
        .isCustomPathCompleted();
    expect(done, isTrue);
  });
}
