import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/coins_service.dart';
import 'package:poker_analyzer/services/gift_drop_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    CoinsService();
    await CoinsService.instance.load();
  });

  test('deterministic amount is stable for same inputs', () {
    const installSeed = 1700000000000;
    const dayKey = 20000;
    final first = GiftDropService.debugDeterministicAmountV1(
      installSeed: installSeed,
      dayKey: dayKey,
    );
    final second = GiftDropService.debugDeterministicAmountV1(
      installSeed: installSeed,
      dayKey: dayKey,
    );
    expect(first, second);
    expect(first, inInclusiveRange(20, 50));
  });

  testWidgets('gift drop uses deterministic day amount and no RNG cadence', (
    tester,
  ) async {
    const installSeed = 1700000000000;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'gift_drop_install_seed_v1': installSeed,
    });
    CoinsService();
    await CoinsService.instance.load();
    final prefs = await SharedPreferences.getInstance();
    final service = GiftDropService();

    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    final day1 = DateTime.utc(2026, 3, 1, 12);
    await service.checkAndDropGift(
      context: capturedContext,
      nowOverride: day1,
      prefsOverride: prefs,
    );
    final day1Key = day1.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
    final day1Amount = GiftDropService.debugDeterministicAmountV1(
      installSeed: installSeed,
      dayKey: day1Key,
    );
    expect(prefs.getInt('user_coins'), day1Amount);

    await service.checkAndDropGift(
      context: capturedContext,
      nowOverride: day1.add(const Duration(hours: 1)),
      prefsOverride: prefs,
    );
    expect(prefs.getInt('user_coins'), day1Amount);

    final day2 = day1.add(const Duration(hours: 25));
    await service.checkAndDropGift(
      context: capturedContext,
      nowOverride: day2,
      prefsOverride: prefs,
    );
    final day2Key = day2.millisecondsSinceEpoch ~/ (24 * 60 * 60 * 1000);
    final day2Amount = GiftDropService.debugDeterministicAmountV1(
      installSeed: installSeed,
      dayKey: day2Key,
    );
    expect(prefs.getInt('user_coins'), day1Amount + day2Amount);
  });
}
