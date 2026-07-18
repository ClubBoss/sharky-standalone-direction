import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  test('release builds do not admit the Act0 dev-menu owner', () {
    expect(act0DevMenuEnabledV1(isReleaseMode: true), isFalse);
    expect(act0DevMenuEnabledV1(isReleaseMode: false), isTrue);
  });
}
