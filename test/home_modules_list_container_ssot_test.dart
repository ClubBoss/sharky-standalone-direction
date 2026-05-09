import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Home modules container keeps surface polish', () {
    const homePath = 'lib/ui_v2/legacy/home_screen.dart';
    final src = File(homePath).readAsStringSync();

    expect(
      src.contains('Container('),
      isTrue,
      reason: 'Container wrapper still present',
    );
    expect(
      src.contains('AppColors.surface'),
      isTrue,
      reason: 'Surface color usage remains',
    );
    expect(
      src.contains('SharkyTokensV1.radiusLg'),
      isTrue,
      reason: 'radius token still drives container',
    );
    expect(
      src.contains('SharkyTokensV1.elevation2'),
      isTrue,
      reason: 'Elevation token still used',
    );
    expect(
      src.contains('PreflopTrainerScreen'),
      isFalse,
      reason: 'Launcher should not reference PreflopTrainerScreen',
    );
  });
}
