import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import 'package:poker_analyzer/services/return_loop_service_v1.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ReturnLoopServiceV1.instance.resetForTesting();
  });

  test('daily hand index stays within pool and is deterministic', () {
    final indexA = ReturnLoopServiceV1.instance.dailyHandIndexFor('20240215');
    final indexB = ReturnLoopServiceV1.instance.dailyHandIndexFor('20240215');
    expect(indexA, equals(indexB));
    expect(indexA, inInclusiveRange(0, 29));
  });

  test('update increments streak after consecutive days', () async {
    final service = ReturnLoopServiceV1.instance;
    service.overrideClock(() => DateTime(2024, 1, 1));
    await service.updateOnAppOpenOrProgressMapShown();
    expect(service.currentStreak, equals(1));

    service.overrideClock(() => DateTime(2024, 1, 2));
    await service.updateOnAppOpenOrProgressMapShown();
    expect(service.currentStreak, equals(2));
    expect(service.todayDailyHandIndex, isNotNull);
  });
}
