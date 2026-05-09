import 'package:test/test.dart';
import 'package:poker_analyzer/services/session_start_timing_service_v1.dart';

void main() {
  test(
    'startOnce retains the first call and stays within the budget',
    () async {
      var now = DateTime(2025, 1, 1, 12, 0);
      final recorded = <int>[];
      final service = SessionStartTimingServiceV1(
        clock: () => now,
        sink: (elapsedMs, {String? source}) async {
          recorded.add(elapsedMs);
        },
      );

      service.start(source: 'unit-test');
      now = now.add(const Duration(milliseconds: 100));
      service.start(source: 'ignored');
      now = now.add(const Duration(milliseconds: 300));
      service.markFirstFrameRendered();
      service.markFirstFrameRendered();

      expect(
        recorded,
        [400],
        reason: 'the first start must win even when start is called twice',
      );
      expect(
        recorded.first,
        lessThan(SessionStartTimingServiceV1.sessionStartBudgetMs),
        reason: 'Session Start should stay below the 0.5s budget.',
      );
      expect(
        service.lastElapsedMs,
        recorded.first,
        reason: 'lastElapsedMs should match the emitted duration',
      );
    },
  );

  test(
    'markFirstFrameRendered emits once per start and allows the next run',
    () async {
      var now = DateTime(2025, 1, 1, 12, 0);
      final recorded = <int>[];
      final service = SessionStartTimingServiceV1(
        clock: () => now,
        sink: (elapsedMs, {String? source}) async {
          recorded.add(elapsedMs);
        },
      );

      service.start();
      now = now.add(const Duration(milliseconds: 150));
      service.markFirstFrameRendered();
      now = now.add(const Duration(milliseconds: 50));
      service.markFirstFrameRendered();

      expect(
        recorded,
        [150],
        reason:
            'subsequent frame callbacks must not emit again for the same start',
      );
      expect(
        service.lastElapsedMs,
        150,
        reason: 'lastElapsedMs should stay in sync with the only emission',
      );

      service.start(source: 'second-pass');
      now = now.add(const Duration(milliseconds: 350));
      service.markFirstFrameRendered();

      expect(
        recorded,
        [150, 350],
        reason:
            'a new start should allow a second emission after the first run',
      );
      expect(
        service.lastElapsedMs,
        350,
        reason: 'lastElapsedMs should reflect the latest emission',
      );
    },
  );
}
