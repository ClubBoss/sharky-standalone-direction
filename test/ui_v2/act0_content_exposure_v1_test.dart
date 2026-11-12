import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_exposure_v1.dart';

void main() {
  test('unanswered presentation remains seen after storage roundtrip', () {
    final shown = const Act0ContentExposureV1().present('task_a');
    final restored = Act0ContentExposureV1.restore(
      jsonDecode(jsonEncode(shown.toPayload())),
    );
    expect(restored.wasPresented('task_a'), isTrue);
    expect(restored.hasCompleteLineage, isTrue);
    expect(
      Act0UnshownTaskPoolV1.resolve(
        availableAssessmentTaskIds: ['task_a'],
        exposure: restored,
      ).status,
      Act0UnshownAvailabilityV1.exhausted,
    );
  });

  test('presentation is idempotent and never mutates previous snapshot', () {
    const first = Act0ContentExposureV1();
    final next = first.present('a');
    expect(first.presentedTaskIds, isEmpty);
    expect(identical(next.present('a'), next), isTrue);
    expect(identical(next.present(' '), next), isTrue);
    expect(() => next.presentedTaskIds.add('b'), throwsUnsupportedError);
  });

  test('source revision changes do not erase stable task exposure', () {
    final shown = const Act0ContentExposureV1().present('stable_task');
    final pool = Act0UnshownTaskPoolV1.resolve(
      availableAssessmentTaskIds: ['stable_task'],
      exposure: shown,
    );
    expect(pool.taskIds, isEmpty);
    expect(pool.status, Act0UnshownAvailabilityV1.exhausted);
  });

  test('missing legacy and malformed histories never become fresh lineage', () {
    for (final raw in [
      null,
      {},
      {'schemaVersion': 2},
      {
        'schemaVersion': 1,
        'hasCompleteLineage': true,
        'presentedTaskIds': ['seen', 7],
      },
      {
        'schemaVersion': 1,
        'hasCompleteLineage': true,
        'presentedTaskIds': ['seen', 'seen'],
      },
    ]) {
      final restored = Act0ContentExposureV1.restore(raw);
      expect(restored.hasCompleteLineage, isFalse);
      expect(restored.present('new').hasCompleteLineage, isFalse);
      expect(
        Act0UnshownTaskPoolV1.resolve(
          availableAssessmentTaskIds: ['new'],
          exposure: restored,
        ).status,
        Act0UnshownAvailabilityV1.unverified,
      );
    }
  });

  test('exposure anchors are not evicted at the decision-history limit', () {
    var history = const Act0ContentExposureV1();
    for (var i = 0; i < 450; i++) history = history.present('task_$i');
    final restored = Act0ContentExposureV1.restore(history.toPayload());
    expect(restored.presentedTaskIds, hasLength(450));
    expect(restored.wasPresented('task_0'), isTrue);
  });

  test(
    'only supplied unlocked candidates contribute; all seen has no fallback',
    () {
      final pool = Act0UnshownTaskPoolV1.resolve(
        availableAssessmentTaskIds: ['available'],
        exposure: const Act0ContentExposureV1().present('available'),
      );
      expect(pool.status, Act0UnshownAvailabilityV1.exhausted);
      expect(pool.taskIds, isEmpty);
      final empty = Act0UnshownTaskPoolV1.resolve(
        availableAssessmentTaskIds: [],
        exposure: const Act0ContentExposureV1(),
      );
      expect(empty.explanation, isNot(contains('You have seen all')));
      expect(pool.title, 'No new checks available');
      expect(pool.explanation, contains('will not count as an unseen check'));
      final fresh = Act0UnshownTaskPoolV1.resolve(
        availableAssessmentTaskIds: ['available'],
        exposure: const Act0ContentExposureV1(),
      );
      expect(fresh.taskIds, ['available']);
      expect(fresh.taskIds, isNot(contains('locked_world_task')));
    },
  );

  test('completed and assisted exposures are excluded independently', () {
    final pool = Act0UnshownTaskPoolV1.resolve(
      availableAssessmentTaskIds: ['answered', 'help', 'new'],
      exposure: const Act0ContentExposureV1(),
      decisionTaskIds: {'answered'},
      assistanceExposedTaskIds: {'help'},
    );
    expect(pool.taskIds, ['new']);
    expect(pool.explanation, contains('alone does not prove transfer'));
  });

  test('malformed decision and assistance exclusions fail closed', () {
    for (final id in [' padded ', '']) {
      for (final assisted in [false, true]) {
        expect(
          Act0UnshownTaskPoolV1.resolve(
            availableAssessmentTaskIds: ['padded'],
            exposure: const Act0ContentExposureV1(),
            decisionTaskIds: assisted ? {} : {id},
            assistanceExposedTaskIds: assisted ? {id} : {},
          ).status,
          Act0UnshownAvailabilityV1.unverified,
        );
      }
    }
  });

  test('collision and incomplete decision lineage fail closed', () {
    for (final ids in [
      ['same', 'same'],
      [''],
      [' padded '],
    ]) {
      expect(
        Act0UnshownTaskPoolV1.resolve(
          availableAssessmentTaskIds: ids,
          exposure: const Act0ContentExposureV1(),
        ).status,
        Act0UnshownAvailabilityV1.unverified,
      );
    }
    expect(
      Act0UnshownTaskPoolV1.resolve(
        availableAssessmentTaskIds: ['new'],
        exposure: const Act0ContentExposureV1(),
        hasCompleteDecisionLineage: false,
      ).status,
      Act0UnshownAvailabilityV1.unverified,
    );
  });
}
