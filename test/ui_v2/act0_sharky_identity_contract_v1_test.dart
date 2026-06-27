import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_presence_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('Sharky companion moods use one character asset family', () {
    for (final mood in Act0SharkyMoodV1.values) {
      expect(
        act0SharkyCompanionAssetForMoodV1(mood),
        startsWith('assets/images/mascot/sharky_'),
      );
      expect(
        act0SharkyCompanionAssetForMoodV1(mood),
        isNot(contains('assets/brand/')),
      );
    }
  });

  test('Sharky brand mark remains separate from companion character', () {
    expect(act0SharkyLogoMarkAssetV1, 'assets/brand/logo.svg');
    expect(
      act0SharkyLogoMarkAssetV1,
      isNot(startsWith('assets/images/mascot/')),
    );
  });
}
