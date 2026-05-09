import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/personalization/phase1_error_to_focus_map_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/screens/module_summary_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'reviewDue path stays review-first and non-review can route to core',
    () {
      expect(
        recommendedModuleIdForFocus(
          focusLabel: 'initiative',
          reviewDue: true,
          skillBand: 'advanced',
          placementScore: 3,
        ),
        'world1_act0_action_literacy',
      );

      expect(
        recommendedModuleIdForFocus(focusLabel: 'initiative', reviewDue: false),
        'core_positions_and_initiative',
      );
      expect(
        recommendedModuleIdForFocus(focusLabel: 'pot_odds', reviewDue: false),
        'core_pot_odds_equity',
      );
      expect(
        recommendedModuleIdForFocus(focusLabel: 'river', reviewDue: false),
        'core_river_fundamentals',
      );
    },
  );

  test('today plan supported ids include required routed core modules', () {
    const requiredCoreIds = <String>{
      'core_positions_and_initiative',
      'core_starting_hands',
      'core_pot_odds_equity',
      'core_board_textures',
      'core_flop_fundamentals',
      'core_equity_realization',
      'core_turn_fundamentals',
      'core_river_fundamentals',
      'core_bankroll_management',
    };

    for (final moduleId in requiredCoreIds) {
      expect(kTodayPlanSupportedModuleIds.contains(moduleId), isTrue);
    }
  });

  test('focus mapper maps representative phase1 signals to router labels', () {
    expect(
      focusLabelForPhase1Signal(errorType: 'incorrect_seat'),
      'action_order',
    );
    expect(focusLabelForPhase1Signal(category: 'pot_odds_miss'), 'pot_odds');
    expect(
      focusLabelForPhase1Signal(subreason: 'river_bluffcatch_confusion'),
      'river',
    );
  });

  test('mapped focus labels route to expected core modules', () {
    final initiativeFocus = focusLabelForPhase1Signal(
      errorType: 'incorrect_seat',
    );
    expect(
      recommendedModuleIdForFocus(
        focusLabel: initiativeFocus,
        reviewDue: false,
      ),
      'core_positions_and_initiative',
    );

    final potOddsFocus = focusLabelForPhase1Signal(category: 'pot_odds_miss');
    expect(
      recommendedModuleIdForFocus(focusLabel: potOddsFocus, reviewDue: false),
      'core_pot_odds_equity',
    );
  });

  testWidgets(
    'session result copies skill card and duel code drives local launch',
    (tester) async {
      tester.view.physicalSize = const Size(1366, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        ProgressService.debugNowOverride = null;
        Telemetry.overrideLogHandler(null);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      final t0 = DateTime.utc(2026, 1, 2, 9, 0, 0);
      ProgressService.debugNowOverride = () => t0;
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await ProgressService.setLessonFocusLabel('range');
      await ProgressService.scheduleFocusReviewIn24h('range');
      ProgressService.debugNowOverride = () =>
          t0.add(const Duration(hours: 25));

      final telemetryNames = <String>[];
      Telemetry.overrideLogHandler((name, payload) async {
        telemetryNames.add(name);
      });

      String clipboardText = '';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              final args = (call.arguments as Map?)?.cast<String, dynamic>();
              clipboardText = (args?['text'] as String?) ?? '';
              return null;
            }
            if (call.method == 'Clipboard.getData') {
              return <String, dynamic>{'text': clipboardText};
            }
            return null;
          });

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 3,
            totalCount: 4,
            moduleId: 'intro_welcome',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final detailsToggle = find.byKey(
        const Key('session_result_share_toggle_v1'),
      );
      expect(detailsToggle, findsOneWidget);
      await tester.ensureVisible(detailsToggle);
      await tester.tap(detailsToggle, warnIfMissed: false);
      await tester.pumpAndSettle();

      final copySkillCard = find.byKey(
        const Key('session_result_copy_skill_card_cta'),
      );
      expect(copySkillCard, findsOneWidget);
      final copySkillCardButton = tester.widget<OutlinedButton>(copySkillCard);
      copySkillCardButton.onPressed?.call();
      await tester.pump();

      expect(clipboardText, contains('Poker Analyzer Skill Card'));
      expect(clipboardText, contains('focus_label: range'));
      expect(clipboardText, contains('review_due: yes'));

      final copyDuelCode = find.byKey(
        const Key('session_result_copy_duel_code_cta'),
      );
      expect(copyDuelCode, findsOneWidget);
      final copyDuelCodeButton = tester.widget<OutlinedButton>(copyDuelCode);
      copyDuelCodeButton.onPressed?.call();
      await tester.pump();

      final duelCode = clipboardText;
      expect(duelCode.startsWith('DUEL1|'), isTrue);

      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'completedAt': t0.toIso8601String(),
        'steps': 7,
        'wrongAttempts': 1,
        'errorClass': 'wrong_action',
        'focusLabel': 'range',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ModuleSummaryScreen(
            moduleData: <String, dynamic>{
              'id': (duelCode.split('|').length >= 5)
                  ? duelCode.split('|')[4]
                  : 'world1_act0_table_literacy',
              'title': 'Duel target',
              'description': 'Resolved from duel code',
              'tier': 'Free',
              'isAvailable': true,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ModuleSummaryScreen), findsOneWidget);
      expect(telemetryNames, contains('skill_card_copied'));
      expect(telemetryNames, contains('duel_code_copied'));
      expect(tester.takeException(), isNull);
    },
  );
}
