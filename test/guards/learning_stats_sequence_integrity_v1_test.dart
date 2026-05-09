import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/learning_stats_v1_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('accuracy floor and focus ordering are deterministic', () {
    const lowSample = LearningStatsSnapshotV1(
      totalDecisions: 4,
      correctDecisions: 4,
      rangeErrors: 0,
      sizingErrors: 0,
      timingErrors: 0,
      logicErrors: 0,
      updatedAtMs: null,
    );
    expect(lowSample.accuracyPercent, isNull);

    const stableFocus = LearningStatsSnapshotV1(
      totalDecisions: 8,
      correctDecisions: 5,
      rangeErrors: 2,
      sizingErrors: 2,
      timingErrors: 1,
      logicErrors: 0,
      updatedAtMs: null,
    );
    expect(stableFocus.accuracyPercent, 63);
    final top = stableFocus.topErrorBuckets(limit: 2);
    expect(top, hasLength(2));
    expect(top[0].key, 'Range');
    expect(top[1].key, 'Sizing');
  });

  test('three correct outcomes are counted exactly once each', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = LearningStatsV1Service.instance;

    for (var i = 0; i < 3; i++) {
      await service.recordDecision(isCorrect: true, errorBucket: 'none');
      final snapshot = await service.load();
      expect(snapshot.totalDecisions, i + 1);
      expect(snapshot.correctDecisions, i + 1);
      expect(snapshot.rangeErrors, 0);
      expect(snapshot.sizingErrors, 0);
      expect(snapshot.timingErrors, 0);
      expect(snapshot.logicErrors, 0);
    }
  });

  test('three incorrect outcomes are counted exactly once each', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = LearningStatsV1Service.instance;

    for (var i = 0; i < 3; i++) {
      await service.recordDecision(isCorrect: false, errorBucket: 'incorrect');
      final snapshot = await service.load();
      expect(snapshot.totalDecisions, i + 1);
      expect(snapshot.correctDecisions, 0);
      expect(snapshot.logicErrors, i + 1);
    }
  });

  test('alternating outcomes remain deterministic and stable', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final service = LearningStatsV1Service.instance;
    final sequence = <({bool isCorrect, String bucket})>[
      (isCorrect: true, bucket: 'none'),
      (isCorrect: false, bucket: 'range'),
      (isCorrect: true, bucket: 'none'),
      (isCorrect: false, bucket: 'timing'),
      (isCorrect: true, bucket: 'none'),
    ];

    for (final item in sequence) {
      await service.recordDecision(
        isCorrect: item.isCorrect,
        errorBucket: item.bucket,
      );
    }

    final snapshot = await service.load();
    expect(snapshot.totalDecisions, sequence.length);
    expect(snapshot.correctDecisions, 3);
    expect(snapshot.rangeErrors, 1);
    expect(snapshot.timingErrors, 1);
    expect(snapshot.sizingErrors, 0);
    expect(snapshot.logicErrors, 0);
  });
}
