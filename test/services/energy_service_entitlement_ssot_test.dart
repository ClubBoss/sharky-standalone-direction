import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/energy_service.dart';
import 'package:poker_analyzer/services/premium_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setInt('energy_current', 2);
    await prefs.setInt(
      'energy_last_refill',
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setBool('premium_is_active', false);
    await prefs.remove('trial_entitlement_v1');
  });

  test('energy bypasses consumption when premium flag is active', () async {
    await PremiumService().enablePremium();
    final service = EnergyService();

    final current = await service.getCurrentEnergy();
    expect(current, service.getMaxEnergy());

    final consumed = await service.useEnergy();
    expect(consumed, isTrue);
    final after = await service.getCurrentEnergy();
    expect(after, service.getMaxEnergy());
  });

  test(
    'energy bypasses consumption when trial entitlement is active',
    () async {
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trial_entitlement_v1',
        jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      );
      final service = EnergyService();

      final current = await service.getCurrentEnergy();
      expect(current, service.getMaxEnergy());

      final consumed = await service.useEnergy();
      expect(consumed, isTrue);
      final after = await service.getCurrentEnergy();
      expect(after, service.getMaxEnergy());
    },
  );

  test('energy consumes normally when no entitlement is active', () async {
    await PremiumService().disablePremium();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trial_entitlement_v1');
    final service = EnergyService();

    final current = await service.getCurrentEnergy();
    expect(current, 2);

    final consumed = await service.useEnergy();
    expect(consumed, isTrue);
    final after = await service.getCurrentEnergy();
    expect(after, 1);
  });
}
