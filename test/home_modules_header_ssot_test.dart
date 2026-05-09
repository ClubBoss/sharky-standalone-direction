import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Home modules header keeps the hero language', () {
    final homePath = 'lib/ui_v2/legacy/home_screen.dart';
    final src = File(homePath).readAsStringSync();
    expect(
      src.contains('Ready modules'),
      isTrue,
      reason: 'header label must stay',
    );
    expect(
      src.contains('SharkyTokensV1.radiusLg'),
      isTrue,
      reason: 'radius token still used',
    );
    expect(
      src.contains('AppColors.surfaceVariant'),
      isTrue,
      reason: 'surface variant gradient still referenced',
    );
    expect(
      src.contains('UiGlassTapSurface'),
      isTrue,
      reason: 'tap surface still used for module list',
    );
    expect(
      src.contains('Material('),
      isTrue,
      reason: 'Material usage remains for surfaces',
    );
    expect(
      src.contains('label: title'),
      isTrue,
      reason: 'Semantics label now echoes module title',
    );
  });
}
