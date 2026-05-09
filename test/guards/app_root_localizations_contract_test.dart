import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('AppRoot wires localization delegates and locales', () {
    final file = File('lib/ui_v2/app_root.dart');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'Missing file: lib/ui_v2/app_root.dart',
    );
    final content = file.readAsStringSync();

    final hasDelegates = RegExp(
      r'localizationsDelegates\s*:\s*AppLocalizations\.localizationsDelegates',
    ).hasMatch(content);
    final hasLocales = RegExp(
      r'supportedLocales\s*:\s*AppLocalizations\.supportedLocales',
    ).hasMatch(content);

    expect(
      hasDelegates,
      isTrue,
      reason:
          'AppRoot must include localizationsDelegates: AppLocalizations.localizationsDelegates',
    );
    expect(
      hasLocales,
      isTrue,
      reason:
          'AppRoot must include supportedLocales: AppLocalizations.supportedLocales',
    );
  });
}
