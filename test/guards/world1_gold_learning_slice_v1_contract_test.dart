import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const coveredStepIndexes = <int>[0, 1, 2];

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_settings_engine_v2_backend_enabled_v1': true,
      'app_settings_checkpoint_mode_override_v1': true,
    });
  });

  Future<void> _pumpRunner(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          key: UniqueKey(),
          moduleId: 'world1_spine_campaign_v1',
          moduleTitle: 'World 1',
          mode: kWorld1RunnerModeCampaignSpine,
        ),
      ),
    );
  }

  int? _currentStepIndexV1(WidgetTester tester) {
    final stepHeader = find.byKey(const Key('microtask_step_header'));
    if (stepHeader.evaluate().isEmpty) return null;
    final raw = (tester.widget<Text>(stepHeader.first).data ?? '').trim();
    final match = RegExp(r'^Step\s+(\d+)\s+of\s+\d+$').firstMatch(raw);
    final parsed = match == null ? null : int.tryParse(match.group(1)!);
    if (parsed == null || parsed <= 0) return null;
    return parsed - 1;
  }

  Future<void> _pumpToActionStepIndex(
    WidgetTester tester, {
    required int targetStepIndex,
  }) async {
    String _expectedLabelForStep(int stepIndex) {
      final step = kCampaignPacksV1['world1_spine_campaign_v1']![stepIndex];
      final expected = world1SpineExpectedActionKindV1(step);
      expect(expected, isNotNull);
      switch (expected!) {
        case ActionKindV1.fold:
          return 'FOLD';
        case ActionKindV1.check:
          return 'CHECK';
        case ActionKindV1.call:
          return 'CALL';
        case ActionKindV1.bet:
          return 'BET';
        case ActionKindV1.raise:
          return world1SpinePreferredRaiseLabelV1(step.allowedActions);
      }
    }

    for (var i = 0; i < 520; i++) {
      final prelude = find.byKey(
        const Key('microtask_prelude_continue_cta_v1'),
      );
      if (prelude.evaluate().isNotEmpty) {
        await tester.tap(prelude.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
        continue;
      }

      final intro = find.byKey(const Key('microtask_intro_continue_cta_v1'));
      if (intro.evaluate().isNotEmpty) {
        await tester.tap(intro.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
        continue;
      }

      final requiresContinue = find.byKey(
        const Key('spine_contract_requires_continue'),
        skipOffstage: false,
      );
      final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      if (requiresContinue.evaluate().isNotEmpty &&
          actionBar.evaluate().isEmpty) {
        final raw = tester.widget<Text>(requiresContinue.first).data ?? '';
        if (raw.trim() == 'continue=1') {
          final continueTarget = find.byKey(
            const Key('spine_contract_target_continue'),
          );
          if (continueTarget.evaluate().isNotEmpty) {
            await tester.tap(continueTarget.first, warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 100));
            continue;
          }
        }
      }

      final outcomeSurface = find.byKey(const Key('microtask_outcome_surface'));
      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      if (outcomeSurface.evaluate().isNotEmpty &&
          continueCta.evaluate().isNotEmpty) {
        await tester.tap(continueCta.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 140));
        await tester.pump(const Duration(milliseconds: 180));
        continue;
      }

      final checkCta = find.byKey(const Key('microtask_check_cta'));
      final stepIndex = _currentStepIndexV1(tester);
      if (actionBar.evaluate().isNotEmpty &&
          checkCta.evaluate().isNotEmpty &&
          outcomeSurface.evaluate().isEmpty) {
        if (stepIndex == targetStepIndex) return;
        if (stepIndex != null && stepIndex > targetStepIndex) {
          fail(
            'Reached step $stepIndex before target $targetStepIndex for gold cluster contract.',
          );
        }
        if (stepIndex != null && stepIndex < targetStepIndex) {
          final action = find.descendant(
            of: actionBar,
            matching: find.text(_expectedLabelForStep(stepIndex)),
          );
          expect(action, findsAtLeastNWidgets(1));
          await tester.tap(action.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(checkCta.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 220));
          await tester.pump(const Duration(milliseconds: 220));
          continue;
        }
      }
      await tester.pump(const Duration(milliseconds: 80));
    }

    fail(
      'Did not reach actionable step $targetStepIndex within deterministic budget.',
    );
  }

  Finder _actionButtonsInBar() {
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    expect(actionBar, findsOneWidget);
    return find.descendant(
      of: actionBar,
      matching: find.byType(OutlinedButton),
    );
  }

  Future<void> _tapActionIndexAndCheck(WidgetTester tester, int index) async {
    final actions = _actionButtonsInBar();
    expect(actions, findsAtLeastNWidgets(index + 1));
    await tester.tap(actions.at(index), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));

    final check = find.byKey(const Key('microtask_check_cta'));
    expect(check, findsOneWidget);
    await tester.tap(check.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 220));
  }

  Future<void> _tapActionByPrefixAndCheck(
    WidgetTester tester, {
    required String actionPrefix,
  }) async {
    final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
    expect(actionBar, findsOneWidget);
    final action = find.descendant(
      of: actionBar,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data ?? '').trim().toUpperCase().startsWith(
              actionPrefix.toUpperCase(),
            ),
      ),
    );
    expect(action, findsAtLeastNWidgets(1));
    await tester.tap(action.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    final check = find.byKey(const Key('microtask_check_cta'));
    expect(check, findsOneWidget);
    await tester.tap(check.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 220));
    await tester.pump(const Duration(milliseconds: 220));
  }

  Future<void> _submitUntilIncorrect(WidgetTester tester) async {
    final actions = _actionButtonsInBar();
    final count = actions.evaluate().length;
    for (var i = 0; i < count; i++) {
      await _tapActionIndexAndCheck(tester, i);
      if (find.textContaining('Why:').evaluate().isNotEmpty) {
        return;
      }
      final retry = find.byKey(const Key('microtask_retry_cta'));
      if (retry.evaluate().isNotEmpty) {
        await tester.tap(retry.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 120));
        continue;
      }
      fail('Could not force an incorrect path for gold cluster contract.');
    }
    fail('No incorrect path found in available actions.');
  }

  testWidgets('gold cluster keeps setup+focus on covered steps', (
    tester,
  ) async {
    await _pumpRunner(tester);

    for (final stepIndex in coveredStepIndexes) {
      await _pumpToActionStepIndex(tester, targetStepIndex: stepIndex);
      expect(
        find.byKey(const Key('gold_learning_slice_prelude_card_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('gold_learning_slice_setup_v1')),
        findsOneWidget,
      );
      final focus = find.byKey(const Key('gold_learning_slice_focus_v1'));
      expect(focus, findsOneWidget);
      final focusText = (tester.widget<Text>(focus).data ?? '').trim();
      expect(focusText.startsWith('Notice:'), isTrue);
      final literacyWhy = find.byKey(
        const Key('gold_learning_slice_literacy_why_v1'),
      );
      if (stepIndex == 0 || stepIndex == 1) {
        expect(literacyWhy, findsOneWidget);
        final literacyText = (tester.widget<Text>(literacyWhy).data ?? '')
            .trim();
        expect(literacyText.startsWith('Why it matters:'), isTrue);
      } else {
        expect(literacyWhy, findsNothing);
      }
      expect(find.byKey(const Key('microtask_step_prompt')), findsOneWidget);
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('gold cluster wrong path keeps factual why', (tester) async {
    await _pumpRunner(tester);
    await _pumpToActionStepIndex(tester, targetStepIndex: 1);
    await _submitUntilIncorrect(tester);

    expect(find.byKey(const Key('microtask_outcome_surface')), findsOneWidget);
    expect(find.textContaining('Why:'), findsOneWidget);
    expect(find.textContaining('Expected:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'gold cluster keeps selective compact reinforcement on expected correct paths',
    (tester) async {
      Future<void> expectReinforceOnSomeCorrectPath(int stepIndex) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'app_settings_engine_v2_backend_enabled_v1': true,
          'app_settings_checkpoint_mode_override_v1': true,
        });
        await _pumpRunner(tester);
        await _pumpToActionStepIndex(tester, targetStepIndex: stepIndex);
        final actionCount = _actionButtonsInBar().evaluate().length;
        var found = false;
        for (var actionIndex = 0; actionIndex < actionCount; actionIndex++) {
          SharedPreferences.setMockInitialValues(<String, Object>{
            'app_settings_engine_v2_backend_enabled_v1': true,
            'app_settings_checkpoint_mode_override_v1': true,
          });
          await _pumpRunner(tester);
          await _pumpToActionStepIndex(tester, targetStepIndex: stepIndex);
          await _tapActionIndexAndCheck(tester, actionIndex);
          if (find.textContaining('Reinforce:').evaluate().isNotEmpty) {
            found = true;
            break;
          }
        }
        expect(found, isTrue);
      }

      await expectReinforceOnSomeCorrectPath(0);

      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
      });
      await _pumpRunner(tester);
      await _pumpToActionStepIndex(tester, targetStepIndex: 1);
      await _tapActionByPrefixAndCheck(tester, actionPrefix: 'CALL');
      expect(find.textContaining('Why:'), findsNothing);
      expect(find.textContaining('Reinforce:'), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );
}
