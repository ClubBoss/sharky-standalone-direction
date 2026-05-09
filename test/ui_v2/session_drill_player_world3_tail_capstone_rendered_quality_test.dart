import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _pumpUntilReady(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 120,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (find
              .byKey(const Key('session_drill_player_hand_chain_table_v1'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('session_drill_player_load_error'))
              .evaluate()
              .isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for direct canonical late World 3 tail scene');
  }

  SessionDrillItemV1 _loadHandChainDrillFromFile(
    String sessionId,
    String filename,
  ) {
    final path =
        'content/worlds/world3/v1/sessions/$sessionId/drills/$filename';
    final json = File(path).readAsStringSync();
    final spec = DrillSpecV1.fromJsonString(json);
    return SessionDrillItemV1(drillId: spec.id, spec: spec);
  }

  testWidgets(
    'w3.s11-w3.s14 direct canonical path keeps late tail capstone prompts, table, and action surface readable through the first advancement',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final lateCapstoneStepTwoBestActions = <String, String>{
        'w3.s11': 'raise',
        'w3.s12': 'call',
        'w3.s13': 'raise',
        'w3.s14': 'raise',
      };
      final drillFilenames = <String, String>{
        'w3.s11': 'd.chain_position_open_call_v1.json',
        'w3.s12': 'd.chain_position_continue_fold_v1.json',
        'w3.s13': 'd.chain_position_open_fold_v1.json',
        'w3.s14': 'd.chain_position_sensitive_open_fold_v1.json',
      };
      final lateCapstoneStepTwoLegalActions = <String, List<String>>{
        'w3.s11': const <String>['fold', 'call', 'raise'],
        'w3.s12': const <String>['fold', 'call'],
        'w3.s13': const <String>['fold', 'call', 'raise'],
        'w3.s14': const <String>['fold', 'call', 'raise'],
      };

      for (final entry in lateCapstoneStepTwoBestActions.entries) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        final drills = <SessionDrillItemV1>[
          _loadHandChainDrillFromFile(entry.key, drillFilenames[entry.key]!),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
              sessionId: entry.key,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await _pumpUntilReady(tester);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('session_drill_player_load_error')),
          findsNothing,
        );

        final headerFinder = find.byKey(
          const Key('session_drill_player_surfaced_header'),
        );
        final promptCapsuleFinder = find.byKey(
          const Key('session_drill_player_prompt_capsule_v1'),
        );
        final promptFinder = find.byKey(
          const Key('session_drill_player_prompt'),
        );
        final tableFinder = find.byKey(
          const Key('session_drill_player_hand_chain_table_v1'),
        );
        final actionBarFinder = find.byKey(
          const Key('session_drill_player_hand_chain_action_bar_v1'),
        );
        final heroActionFinder = find.byKey(
          const Key('session_drill_player_hand_chain_action_hero_v1'),
        );
        final villainActionFinder = find.byKey(
          const Key('session_drill_player_hand_chain_action_villain_v1'),
        );

        expect(headerFinder, findsOneWidget);
        expect(promptCapsuleFinder, findsOneWidget);
        expect(promptFinder, findsOneWidget);
        expect(
          find.byKey(const Key('session_drill_player_status_header')),
          findsNothing,
        );
        expect(tableFinder, findsOneWidget);
        expect(actionBarFinder, findsOneWidget);
        expect(heroActionFinder, findsOneWidget);
        expect(villainActionFinder, findsOneWidget);

        final promptRect = tester.getRect(promptFinder);
        final headerRect = tester.getRect(headerFinder);
        final tableRect = tester.getRect(tableFinder);
        final actionBarRect = tester.getRect(actionBarFinder);

        expect(headerRect.bottom, lessThan(tableRect.top));
        expect(promptRect.bottom, lessThan(tableRect.top));
        expect(actionBarRect.top, greaterThan(tableRect.bottom));

        final initialTable = tester.widget<ModernTableScreenV1>(tableFinder);
        expect(initialTable.scenarioSpec, isNotNull);
        expect(
          initialTable.scenarioSpec!.decisionNodeV1.street,
          Street.preflop,
        );
        expect(
          initialTable.scenarioSpec!.decisionNodeV1.legalActions,
          equals(const <String>['hero', 'villain']),
        );

        await tester.tap(heroActionFinder);
        await tester.pumpAndSettle();

        final advancedTable = tester.widget<ModernTableScreenV1>(tableFinder);
        expect(advancedTable.scenarioSpec, isNotNull);
        expect(
          advancedTable.scenarioSpec!.decisionNodeV1.street,
          Street.preflop,
        );
        expect(
          advancedTable.scenarioSpec!.decisionNodeV1.legalActions,
          equals(lateCapstoneStepTwoLegalActions[entry.key]),
        );
        expect(
          advancedTable.scenarioSpec!.decisionNodeV1.solutionBestAction,
          entry.value,
        );
        expect(actionBarFinder, findsOneWidget);

        final advancedPromptRect = tester.getRect(promptFinder);
        final advancedTableRect = tester.getRect(tableFinder);
        final advancedActionBarRect = tester.getRect(actionBarFinder);
        expect(advancedPromptRect.bottom, lessThan(advancedTableRect.top));
        expect(
          advancedActionBarRect.top,
          greaterThan(advancedTableRect.bottom),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'w3.s14 direct canonical path completes the late capstone tail into the first completion surface',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _loadHandChainDrillFromFile(
          'w3.s14',
          'd.chain_position_sensitive_open_fold_v1.json',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w3.s14',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilReady(tester);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pumpAndSettle();

      final tableFinder = find.byKey(
        const Key('session_drill_player_hand_chain_table_v1'),
      );
      final completionFinder = find.byKey(
        const Key('session_drill_player_completion_surface_v1'),
      );
      final completionWhyFinder = find.byKey(
        const Key('session_drill_player_completion_why_v1'),
      );

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
        findsNothing,
      );
      expect(completionFinder, findsOneWidget);
      expect(completionWhyFinder, findsOneWidget);

      final tableRect = tester.getRect(tableFinder);
      final completionRect = tester.getRect(completionFinder);
      expect(completionRect.top, greaterThan(tableRect.bottom));
      expect(tester.takeException(), isNull);
    },
  );
}
