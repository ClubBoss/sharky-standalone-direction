import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('Home hero surface keeps design lift tokens', () {
    const path = 'lib/ui_v2/legacy/home_screen.dart';
    final src = File(path).readAsStringSync();
    final readyHeaderWithMaterial = RegExp(
      r"label: 'Ready modules header'[\s\S]*?child: Material\(",
      dotAll: true,
    );

    expect(
      src.contains('Semantics('),
      isTrue,
      reason: 'Hero header is semantics-wrapped',
    );
    expect(
      src.contains('Ready modules'),
      isTrue,
      reason: 'Header text remains',
    );
    expect(
      src.contains('Ready modules header'),
      isTrue,
      reason: 'Accessible label stays unchanged',
    );
    expect(
      readyHeaderWithMaterial.hasMatch(src),
      isTrue,
      reason: 'Material now sits inside the hero semantics block',
    );
    expect(
      src.contains('SharkyTokensV1.radiusLg'),
      isTrue,
      reason: 'Radius token used for hero card',
    );
    expect(
      src.contains('SharkyTokensV1.elevation2'),
      isTrue,
      reason: 'Header keeps an elevation token',
    );
    expect(
      src.contains('AppColors.surfaceVariant'),
      isTrue,
      reason: 'Surface color references stay',
    );
    expect(
      src.contains('AppColors.surface'),
      isTrue,
      reason: 'Surface color references stay',
    );
  });
}
