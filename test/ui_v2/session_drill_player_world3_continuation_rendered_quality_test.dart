import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_action_area_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';

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
    fail('Timed out waiting for direct canonical hand-chain scene');
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

  void _expectLeftToRightOrder(
    WidgetTester tester,
    List<Key> keys,
  ) {
    double? previousLeft;
    for (final key in keys) {
      final finder = find.byKey(key);
      expect(finder, findsOneWidget);
      final currentLeft = tester.getRect(finder).left;
      if (previousLeft != null) {
        expect(currentLeft, greaterThan(previousLeft));
      }
      previousLeft = currentLeft;
    }
  }

  void _expectPreflopSourceStreetChip(WidgetTester tester) {
    final sourceStreetFinder = find.byKey(
      const Key('session_drill_player_hand_chain_source_street_v1'),
    );
    expect(sourceStreetFinder, findsOneWidget);
    expect(
      find.descendant(
        of: sourceStreetFinder,
        matching: find.text('Street: PREFLOP'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_hand_chain_source_board_v1')),
      findsNothing,
    );
  }

  testWidgets(
    'w3.s04-w3.s06 direct canonical path keeps continuation prompt, embedded table, and action surface readable on phone size',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final expectedPrompts = <String, String>{
        'w3.s04': 'cutoff with QQ',
        'w3.s05': 'button with 99',
        'w3.s06': 'button with ATo',
      };
      final drillSets = <String, List<SessionDrillItemV1>>{
        'w3.s04': <SessionDrillItemV1>[
          _loadHandChainDrillFromFile(
            'w3.s04',
            'd.chain_preflop_premium_strong_reps_v1.json',
          ),
        ],
        'w3.s05': <SessionDrillItemV1>[
          _loadHandChainDrillFromFile(
            'w3.s05',
            'd.chain_preflop_medium_weak_discipline_v1.json',
          ),
        ],
        'w3.s06': <SessionDrillItemV1>[
          _loadHandChainDrillFromFile(
            'w3.s06',
            'd.chain_preflop_mixed_context_checkpoint_v1.json',
          ),
        ],
      };

      for (final entry in expectedPrompts.entries) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        final drills = drillSets[entry.key]!;

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

        final promptFinder = find.byKey(
          const Key('session_drill_player_prompt'),
        );
        final headerFinder = find.byKey(
          const Key('session_drill_player_surfaced_header'),
        );
        final promptCapsuleFinder = find.byKey(
          const Key('session_drill_player_prompt_capsule_v1'),
        );
        final tableFinder = find.byKey(
          const Key('session_drill_player_hand_chain_table_v1'),
        );
        final actionBarFinder = find.byKey(
          const Key('session_drill_player_hand_chain_action_bar_v1'),
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
        expect(find.textContaining(entry.value), findsOneWidget);
        _expectPreflopSourceStreetChip(tester);

        final promptRect = tester.getRect(promptFinder);
        final headerRect = tester.getRect(headerFinder);
        final tableRect = tester.getRect(tableFinder);
        final actionBarRect = tester.getRect(actionBarFinder);
        final sourceStreetRect = tester.getRect(
          find.byKey(const Key('session_drill_player_hand_chain_source_street_v1')),
        );

        expect(promptRect.height, greaterThan(18));
        expect(headerRect.bottom, lessThan(tableRect.top));
        expect(promptRect.bottom, lessThan(tableRect.top));
        expect(actionBarRect.top, greaterThan(tableRect.bottom));
        expect(sourceStreetRect.bottom, lessThan(tableRect.top));
        final logicalScreenHeight =
            tester.view.physicalSize.height / tester.view.devicePixelRatio;
        expect(
          logicalScreenHeight - actionBarRect.bottom,
          greaterThanOrEqualTo(
            kCanonicalLearnerActionSafeAreaMinimumV1.bottom,
          ),
        );
        _expectLeftToRightOrder(tester, const <Key>[
          Key('session_drill_player_hand_chain_action_fold_v1'),
          Key('session_drill_player_hand_chain_action_call_v1'),
          Key('session_drill_player_hand_chain_action_raise_v1'),
        ]);
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.title, isNull);
        expect(appBar.toolbarHeight, equals(40));
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'w3.s06 direct canonical path completes into the first continuation result surface after the final step',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _loadHandChainDrillFromFile(
          'w3.s06',
          'd.chain_preflop_mixed_context_checkpoint_v1.json',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w3.s06',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilReady(tester);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pumpAndSettle();

      final completionFinder = find.byKey(
        const Key('session_drill_player_completion_surface_v1'),
      );
      final completionWhyFinder = find.byKey(
        const Key('session_drill_player_completion_why_v1'),
      );

      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
        findsNothing,
      );
      expect(completionFinder, findsOneWidget);
      expect(completionWhyFinder, findsOneWidget);
      final tableRect = tester.getRect(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      final completionRect = tester.getRect(completionFinder);
      expect(completionRect.top - tableRect.bottom, greaterThanOrEqualTo(8));
      expect(tester.takeException(), isNull);
    },
  );
}
