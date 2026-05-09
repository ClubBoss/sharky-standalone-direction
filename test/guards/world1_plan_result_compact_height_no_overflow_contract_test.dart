import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('today plan and result fit compact height without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      ProgressService.debugNowOverride = null;
    });

    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'intake_profile_v1': jsonEncode(<String, Object?>{
        'focusLabel': 'range',
        'errorClass': 'range_leak',
      }),
      'lesson_focus_label_v1': 'range',
      'free_roll_remaining_v1': 2,
      'training_bankroll_balance_v1': 100,
      'training_bankroll_last_regen_at_v1': DateTime.utc(
        2026,
        2,
        14,
        12,
      ).toIso8601String(),
    });
    ProgressService.debugNowOverride = () => DateTime.utc(2026, 2, 14, 12);

    await tester.pumpWidget(const AppRoot());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final startFinder = find.byKey(const Key('today_plan_start_cta'));
    expect(startFinder, findsOneWidget);
    final startTop = tester.getTopLeft(startFinder).dy;
    expect(startTop, lessThan(700));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: SessionResultScreen(
          moduleId: 'intro_welcome',
          correctCount: 2,
          totalCount: 3,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('session_result_whats_next_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_result_back_to_map_cta')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
