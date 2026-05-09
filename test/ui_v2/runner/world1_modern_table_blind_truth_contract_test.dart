import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _formatUnitsToBbDisplayV1(int units) {
  final negative = units < 0;
  final absUnits = units.abs();
  final whole = absUnits ~/ 2;
  final hasHalf = absUnits.isOdd;
  final bb = hasHalf ? '$whole.5' : '$whole';
  return negative ? '-$bb' : bb;
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 120,
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(step);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'world1 embedded modern table surfaces blind tokens, contribution math, and BB-based state semantics',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('modern_table_scene_state_lane')),
      );
      await tester.pumpAndSettle();

      final modernTable = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(
        modernTable.seatStateVisualProfileV1,
        ModernTableSeatStateVisualProfileV1.learnerEmbedded,
      );
      expect(
        modernTable.sceneLanePromptProfileV1,
        ModernTableSceneLanePromptProfileV1.compactStateOnly,
      );
      final markerLabels = modernTable.debugSeatMarkerLabels ?? <int, String>{};
      final roleLabels = modernTable.debugSeatRoleLabels ?? <int, String>{};
      final contributionAmounts =
          modernTable.debugSeatContributionAmountsV1 ?? <int, int>{};
      final priceSetterIndex = modernTable.debugPriceSetterSeatIndexV1;
      final sbIndex = markerLabels.entries
          .firstWhere((entry) => entry.value == 'SB')
          .key;
      final bbIndex = markerLabels.entries
          .firstWhere((entry) => entry.value == 'BB')
          .key;

      expect(
        find.byKey(const Key('modern_table_scene_state_lane')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_scene_prompt')), findsNothing);
      expect(markerLabels.containsValue('D'), isTrue);
      expect(roleLabels[sbIndex], 'SB');
      expect(roleLabels[bbIndex], 'BB');
      expect(contributionAmounts, isNotEmpty);
      expect(priceSetterIndex, isNotNull);
      expect(modernTable.debugPriceSetterCueLabelV1, isNotNull);
      expect(modernTable.debugPriceSetterCueLabelV1, isNot('PRICE'));
      expect(modernTable.debugPotDisplayLabelV1, isNotNull);
      final headerPromptFinder = find.descendant(
        of: find.byKey(const Key('microtask_runner_prompt_capsule_v1')),
        matching: find.byWidgetPredicate((widget) {
          if (widget is! Text) {
            return false;
          }
          final data = widget.data ?? '';
          return data.contains('Choose the best action.');
        }),
      );
      expect(headerPromptFinder, findsOneWidget);
      final headerPromptText = tester.widget<Text>(headerPromptFinder);
      expect(headerPromptText.data, modernTable.debugScenePromptLabel);
      expect(headerPromptText.maxLines, 2);
      expect(headerPromptText.softWrap, isTrue);
      expect(headerPromptText.overflow, TextOverflow.clip);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('modern_table_pot_amount')))
            .data,
        modernTable.debugPotDisplayLabelV1,
      );
      if (modernTable.debugScenePriceLabelV1 != null) {
        expect(
          find.byKey(const Key('modern_table_scene_price_badge')),
          findsOneWidget,
        );
        expect(find.text(modernTable.debugScenePriceLabelV1!), findsOneWidget);
      }

      expect(
        find.byKey(Key('modern_table_seat_marker_$sbIndex')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(Key('modern_table_seat_marker_$sbIndex')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('modern_table_seat_marker_$bbIndex')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(Key('modern_table_seat_marker_$bbIndex')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: find.byKey(Key('modern_table_seat_forced_bet_$sbIndex')),
          matching: find.text('POST SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('modern_table_seat_posted_blind_token_$sbIndex')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(Key('modern_table_seat_forced_bet_$bbIndex')),
          matching: find.text('POST BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('modern_table_seat_posted_blind_token_$bbIndex')),
        findsOneWidget,
      );
      expect(find.byKey(Key('modern_table_seat_live_$sbIndex')), findsNothing);
      expect(find.byKey(Key('modern_table_seat_live_$bbIndex')), findsNothing);
      expect(find.byKey(Key('modern_table_seat_role_$sbIndex')), findsNothing);
      expect(find.byKey(Key('modern_table_seat_role_$bbIndex')), findsNothing);
      expect(find.text('LIVE'), findsNothing);
      for (var i = 0; i < modernTable.scenarioSpec!.seatCount; i++) {
        expect(find.text('P${i + 1}'), findsNothing);
      }
      for (final entry in contributionAmounts.entries) {
        final tokenKey =
            markerLabels[entry.key] == 'SB' || markerLabels[entry.key] == 'BB'
            ? Key('modern_table_seat_posted_blind_token_${entry.key}')
            : Key('modern_table_seat_contribution_token_${entry.key}');
        expect(find.byKey(tokenKey), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(tokenKey),
            matching: find.text(_formatUnitsToBbDisplayV1(entry.value)),
          ),
          findsOneWidget,
        );
      }
      if (priceSetterIndex != null) {
        final priceSetterMarker = markerLabels[priceSetterIndex];
        final priceSetterTokenKey =
            priceSetterMarker == 'SB' || priceSetterMarker == 'BB'
            ? Key('modern_table_seat_posted_blind_token_$priceSetterIndex')
            : Key('modern_table_seat_contribution_token_$priceSetterIndex');
        expect(contributionAmounts[priceSetterIndex], isNotNull);
        expect(find.byKey(priceSetterTokenKey), findsOneWidget);
        expect(
          find.byKey(Key('modern_table_seat_price_setter_$priceSetterIndex')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(
              Key('modern_table_seat_price_setter_$priceSetterIndex'),
            ),
            matching: find.text(modernTable.debugPriceSetterCueLabelV1!),
          ),
          findsOneWidget,
        );
        expect(
          modernTable.debugPriceSetterCueLabelV1 == 'OPEN' ||
              modernTable.debugPriceSetterCueLabelV1 == 'BET' ||
              modernTable.debugPriceSetterCueLabelV1 == 'RAISE',
          isTrue,
        );
        if (modernTable.scenarioSpec?.decisionNodeV1.street ==
            Street.preflop) {
          expect(modernTable.debugPriceSetterCueLabelV1, isNot('BET'));
        }
      }

      final headerRect = tester.getRect(
        find.byKey(const Key('microtask_runner')),
      );
      final promptRect = tester.getRect(
        find.byKey(const Key('microtask_runner_prompt_capsule_v1')),
      );
      final supportRect = tester.getRect(
        find.byKey(const Key('microtask_scene_support_lane_v1')),
      );
      final tableRect = tester.getRect(
        find.byKey(const Key('modern_table_oval')),
      );
      expect(headerRect.height, lessThanOrEqualTo(92));
      expect(promptRect.height, lessThanOrEqualTo(46));
      expect(promptRect.bottom, lessThan(tableRect.top));
      expect(tableRect.height, greaterThan(headerRect.height * 4.7));
      expect(supportRect.top, greaterThan(tableRect.bottom));
      expect(supportRect.height, lessThanOrEqualTo(88));
      expect(
        find.byKey(const Key('microtask_campaign_action_bar')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('microtask_campaign_action_bar')),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                (widget.data ?? '').trim().toUpperCase().startsWith('RAISE'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('microtask_campaign_action_bar')),
          matching: find.textContaining('BB'),
        ),
        findsWidgets,
      );
      final foldLabelRect = tester.getRect(
        find.descendant(
          of: find.byKey(const Key('microtask_campaign_action_bar')),
          matching: find.text('FOLD'),
        ),
      );
      final callLabelRect = tester.getRect(
        find.descendant(
          of: find.byKey(const Key('microtask_campaign_action_bar')),
          matching: find.text('CALL'),
        ),
      );
      final raiseLabelRect = tester.getRect(
        find.descendant(
          of: find.byKey(const Key('microtask_campaign_action_bar')),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                (widget.data ?? '').trim().toUpperCase().startsWith('RAISE'),
          ),
        ),
      );
      expect(foldLabelRect.left, lessThan(callLabelRect.left));
      expect(callLabelRect.left, lessThan(raiseLabelRect.left));
      final logicalScreenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final actionBarRect = tester.getRect(
        find.byKey(const Key('microtask_campaign_action_bar')),
      );
      expect(logicalScreenHeight - actionBarRect.bottom, greaterThanOrEqualTo(8));

      final tableCenter = tester
          .getRect(find.byKey(const Key('modern_table_oval')))
          .center;
      final sbSeatCenter = tester
          .getRect(find.byKey(Key('modern_table_seat_$sbIndex')))
          .center;
      final bbSeatCenter = tester
          .getRect(find.byKey(Key('modern_table_seat_$bbIndex')))
          .center;
      final sbTokenCenter = tester
          .getRect(
            find.byKey(Key('modern_table_seat_posted_blind_token_$sbIndex')),
          )
          .center;
      final bbTokenCenter = tester
          .getRect(
            find.byKey(Key('modern_table_seat_posted_blind_token_$bbIndex')),
          )
          .center;
      expect(
        (sbTokenCenter - tableCenter).distance,
        lessThan((sbSeatCenter - tableCenter).distance),
      );
      expect(
        (bbTokenCenter - tableCenter).distance,
        lessThan((bbSeatCenter - tableCenter).distance),
      );

      expect(tester.takeException(), isNull);
    },
  );
}
