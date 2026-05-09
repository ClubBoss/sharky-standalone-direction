import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Home module tiles keep surface + semantics language', () {
    const homePath = 'lib/ui_v2/legacy/home_screen.dart';
    final src = File(homePath).readAsStringSync();
    expect(
      src.contains('UiGlassTapSurface'),
      isTrue,
      reason: 'Tiles still use UiGlassTapSurface',
    );
    expect(
      src.contains('Material('),
      isTrue,
      reason: 'Material wrapper remains for ripples',
    );
    expect(
      src.contains('Semantics('),
      isTrue,
      reason: 'Tiles remain semantics-marked',
    );
    expect(
      src.contains('label: title'),
      isTrue,
      reason: 'Semantics label still references existing title text',
    );
    expect(
      src.contains('PreflopTrainerScreen'),
      isFalse,
      reason: 'Home should not mention PreflopTrainerScreen',
    );
  });
}
