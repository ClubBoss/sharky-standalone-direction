import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_launch_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_club_night_tokens_v1.dart';

void main() {
  testWidgets('launch view is the wall colour with Sharky and no spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Act0ClubNightLaunchViewV1()),
    );
    final scaffold = tester.widget<Scaffold>(
      find.byKey(const Key('act0_club_night_launch')),
    );
    expect(scaffold.backgroundColor, Act0ClubNightTokensV1.wall);
    expect(find.text('Sharky'), findsOneWidget);
    expect(find.text('POKER COACH'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test('native launch screen uses the same wall colour', () {
    final storyboard = File(
      'ios/Runner/Base.lproj/LaunchScreen.storyboard',
    ).readAsStringSync();
    // #0E1311 as sRGB components.
    expect(
      storyboard,
      contains('red="0.054902" green="0.074510" blue="0.066667"'),
    );
  });
}
