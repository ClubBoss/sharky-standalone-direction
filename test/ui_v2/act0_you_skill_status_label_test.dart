import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'act0_review_v4_test.dart' as review_fixtures;

void main() {
  testWidgets(
    'locked skill sheet states its status instead of "Later"',
    (t) async {
      SharedPreferences.setMockInitialValues(
        review_fixtures.reviewV4Fixture('fresh'),
      );
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPadding);
      await t.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.profile,
            showPlacementOnStart: false,
            clock: Act0FixedUtcClockV1(review_fixtures.reviewV4Now),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('Learning details'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Table sense'));
      await t.pumpAndSettle();
      await t.tap(find.text('Table sense'));
      await t.pumpAndSettle();
      expect(find.text('Later'), findsNothing);
      expect(find.text('Not practiced yet'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
    skip: !kAct0YouV23Preview,
  );
}
