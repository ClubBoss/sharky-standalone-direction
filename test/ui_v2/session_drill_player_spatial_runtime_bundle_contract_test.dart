import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_table_topology_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 60,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description}');
  }

  SessionDrillItemV1 _syntheticSpatialItem({
    required String id,
    required String prompt,
    required String heroSeat,
    required String villainSeat,
    required List<String> activeSeats,
    String? smallBlindSeat,
    String? bigBlindSeat,
    int? smallBlindAmount,
    int? bigBlindAmount,
    int? anteAmount,
  }) {
    final spec = DrillSpecV1.fromJsonString(
      jsonEncode(<String, Object?>{
        'id': id,
        'kind': 'seat_tap',
        'prompt': prompt,
        'expected': <String, Object?>{'role': heroSeat},
        'error_class': 'anchor_order_mismatch',
        'feedback_correct_v1': 'Correct.',
        'feedback_incorrect_v1': 'Incorrect.',
        'player_count_v1': activeSeats.length,
        'hero_seat_v1': heroSeat,
        'villain_seat_v1': villainSeat,
        'active_seats_v1': activeSeats,
        if (smallBlindSeat != null) 'small_blind_seat_v1': smallBlindSeat,
        if (bigBlindSeat != null) 'big_blind_seat_v1': bigBlindSeat,
        if (smallBlindAmount != null) 'small_blind_amount_v1': smallBlindAmount,
        if (bigBlindAmount != null) 'big_blind_amount_v1': bigBlindAmount,
        if (anteAmount != null) 'ante_amount_v1': anteAmount,
      }),
    );
    return SessionDrillItemV1(drillId: spec.id, spec: spec);
  }

  testWidgets(
    'representative W6-W10 spatial sessions render projected tables from hydrated runtime drills',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      for (final sessionId in <String>[
        'w6.s03',
        'w7.s04',
        'w8.s02',
        'w9.s03',
        'cash.s01',
        'tournament.s05',
        'mixed.s10',
      ]) {
        final drills = (await tester.runAsync(
          () => const DrillRuntimeAdapterV1().loadSessionDrills(sessionId),
        ))!;

        expect(
          drills.first.spec.scenarioTableContextV1,
          isNotNull,
          reason: 'hydrated scenario table context was missing for $sessionId',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SessionDrillPlayerV1Screen(
              sessionId: sessionId,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await _pumpUntilFound(
          tester,
          find.byKey(const Key('session_drill_player_prompt')),
        );

        expect(
          find.byKey(const Key('session_drill_player_load_error')),
          findsNothing,
          reason: 'runtime load error surfaced for $sessionId',
        );
        expect(
          find.byType(ModernTableScreenV1),
          findsOneWidget,
          reason: 'projected table was missing for $sessionId',
        );
        expect(
          find.byKey(const Key('session_drill_player_spatial_table_v1')),
          findsOneWidget,
          reason: 'spatial table key was missing for $sessionId',
        );
        expect(
          find.byKey(const Key('session_drill_player_prompt')),
          findsOneWidget,
          reason: 'prompt was missing for $sessionId',
        );
      }
    },
  );

  testWidgets(
    'canonical path surfaces synthetic tournament blind and ante payload end to end',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_tournament_blind_anchor',
          prompt: 'Tap UTG+1 as the tournament position anchor before acting.',
          heroSeat: 'utg1',
          villainSeat: 'bb',
          activeSeats: const <String>[
            'btn',
            'co',
            'hj',
            'lj',
            'utg',
            'utg1',
            'mp1',
            'mp',
            'sb',
            'bb',
          ],
          smallBlindSeat: 'sb',
          bigBlindSeat: 'bb',
          smallBlindAmount: 50,
          bigBlindAmount: 100,
          anteAmount: 10,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'tournament.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_8')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_9')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_8')),
          matching: find.text('POST 50'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_9')),
          matching: find.text('POST 100'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_ante_indicator')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_ante_indicator')),
          matching: find.text('ANTE 10'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'canonical path consumes synthetic 2 max authored order on the heads-up topology path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_two_max_anchor',
          prompt: 'Tap SB as the heads-up position anchor before acting.',
          heroSeat: 'sb',
          villainSeat: 'bb',
          activeSeats: const <String>['sb', 'bb'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 2);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.headsUp2Max,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_1')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_2')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(find.text('BTN'), findsNothing);
      expect(find.text('CO'), findsNothing);
      expect(find.text('HJ'), findsNothing);
    },
  );

  testWidgets(
    'canonical path consumes synthetic 3 max authored order on the derived topology path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_three_max_anchor',
          prompt: 'Tap BTN as the 3-max position anchor before acting.',
          heroSeat: 'btn',
          villainSeat: 'bb',
          activeSeats: const <String>['btn', 'sb', 'bb'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 3);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.transitionalDerived,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_2')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_3')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_2')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(find.text('CO'), findsNothing);
      expect(find.text('HJ'), findsNothing);
    },
  );

  testWidgets(
    'canonical path consumes synthetic 4 max authored order on the derived topology path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_four_max_anchor',
          prompt: 'Tap CO as the 4-max position anchor before acting.',
          heroSeat: 'co',
          villainSeat: 'bb',
          activeSeats: const <String>['btn', 'co', 'sb', 'bb'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 4);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.transitionalDerived,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_1')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_3')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_4')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_2')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(find.text('CO'), findsNothing);
      expect(find.text('HJ'), findsNothing);
    },
  );

  testWidgets(
    'canonical path consumes synthetic 5 max authored order on the derived topology path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_five_max_anchor',
          prompt: 'Tap HJ as the 5-max position anchor before acting.',
          heroSeat: 'hj',
          villainSeat: 'bb',
          activeSeats: const <String>['btn', 'co', 'hj', 'sb', 'bb'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 5);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.transitionalDerived,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_2')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_4')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_5')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(find.text('CO'), findsNothing);
      expect(find.text('HJ'), findsNothing);
    },
  );

  testWidgets(
    'canonical path consumes synthetic 6 max authored order on the short-handed topology path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_six_max_anchor',
          prompt: 'Tap SB as the 6-max position anchor before acting.',
          heroSeat: 'sb',
          villainSeat: 'bb',
          activeSeats: const <String>['btn', 'co', 'hj', 'sb', 'bb', 'utg'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 6);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.shortHanded6Max,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_3')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_5')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_6')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_0')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
      expect(find.text('CO'), findsNothing);
      expect(find.text('HJ'), findsNothing);
      expect(find.text('UTG+1'), findsNothing);
    },
  );

  testWidgets(
    'world6 sessions surface live off-button hero seating on the canonical 7 max path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w6.s07'),
      ))!;

      expect(drills.first.spec.playerCountV1, 7);
      expect(drills.first.spec.heroSeatV1, 'utg');
      expect(drills.first.spec.villainSeatV1, 'btn');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s07',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_4')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('UTG'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('CO'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_2')),
          matching: find.text('HJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('LJ'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'world7 sessions surface live off-button hero seating on the canonical 7 max path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w7.s07'),
      ))!;

      expect(drills.first.spec.playerCountV1, 7);
      expect(drills.first.spec.heroSeatV1, 'utg');
      expect(drills.first.spec.villainSeatV1, 'btn');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w7.s07',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_4')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('UTG'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('CO'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_2')),
          matching: find.text('HJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('LJ'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'world8 sessions surface live 8 max hero seating on the canonical path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w8.s02'),
      ))!;

      expect(drills.first.spec.playerCountV1, 8);
      expect(drills.first.spec.heroSeatV1, 'utg1');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'utg1',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w8.s02',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('CO'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_2')),
          matching: find.text('HJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('LJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('UTG'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'world9 sessions surface live 8 max hero seating on the canonical path',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s03'),
      ))!;

      expect(drills.first.spec.playerCountV1, 8);
      expect(drills.first.spec.heroSeatV1, 'utg1');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'utg1',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w9.s03',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('UTG'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('CO'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_2')),
          matching: find.text('HJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('LJ'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'world10 cash sessions surface live 10 max markers and live off-button hero seating',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('cash.s01'),
      ))!;

      expect(drills.first.spec.playerCountV1, 10);
      expect(drills.first.spec.heroSeatV1, 'utg1');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'utg1',
        'mp1',
        'mp',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'cash.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 10);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.fullRing10Max,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_1')),
          matching: find.text('CO'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_2')),
          matching: find.text('HJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_3')),
          matching: find.text('LJ'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('UTG'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_6')),
          matching: find.text('MP+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_7')),
          matching: find.text('MP'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_9')), findsOneWidget);
    },
  );

  testWidgets(
    'canonical path consumes live 7 max authored order on the worlds 6-9 seam',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w6.s07'),
      ))!;

      expect(drills.first.spec.playerCountV1, 7);
      expect(drills.first.spec.heroSeatV1, 'utg');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s07',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 7);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.transitionalSevenMax,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_4')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_6')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_7')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_4')),
          matching: find.text('UTG'),
        ),
        findsOneWidget,
      );
      expect(find.text('UTG+1'), findsNothing);
    },
  );

  testWidgets(
    'world10 tournament sessions surface live 10 max markers and live off-button hero seating',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('tournament.s01'),
      ))!;

      expect(drills.first.spec.playerCountV1, 10);
      expect(drills.first.spec.heroSeatV1, 'utg1');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'utg1',
        'mp1',
        'mp',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'tournament.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 10);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.fullRing10Max,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_6')),
          matching: find.text('MP+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_7')),
          matching: find.text('MP'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_8')),
          matching: find.text('POST 50'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_9')),
          matching: find.text('POST 100'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_ante_indicator')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_ante_indicator')),
          matching: find.text('ANTE 10'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_9')), findsOneWidget);
    },
  );

  testWidgets(
    'world10 mixed sessions surface live 10 max markers and live non-button hero seating',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('mixed.s01'),
      ))!;

      expect(drills.first.spec.playerCountV1, 10);
      expect(drills.first.spec.heroSeatV1, 'utg1');
      expect(drills.first.spec.activeSeatsV1, const <String>[
        'btn',
        'co',
        'hj',
        'lj',
        'utg',
        'utg1',
        'mp1',
        'mp',
        'sb',
        'bb',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'mixed.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 10);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.fullRing10Max,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_0')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_6')),
          matching: find.text('MP+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_7')),
          matching: find.text('MP'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_8')),
          matching: find.text('POST 50'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_forced_bet_9')),
          matching: find.text('POST 100'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_ante_indicator')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_ante_indicator')),
          matching: find.text('ANTE 10'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_9')), findsOneWidget);
    },
  );

  testWidgets(
    'canonical path consumes synthetic 8 max authored order end to end',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_eight_max_anchor',
          prompt: 'Tap UTG+1 as the position anchor before acting.',
          heroSeat: 'utg1',
          villainSeat: 'bb',
          activeSeats: const <String>[
            'btn',
            'co',
            'hj',
            'lj',
            'utg',
            'utg1',
            'sb',
            'bb',
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w8.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 8);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.transitionalEightMax,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_7')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_8')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_6')),
          matching: find.text('SB'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_7')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'canonical path keeps non-button hero seating deterministic on 9 max spatial sessions',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_off_button_hero_anchor',
          prompt: 'Tap UTG+1 as the off-button hero anchor before acting.',
          heroSeat: 'utg1',
          villainSeat: 'bb',
          activeSeats: const <String>[
            'btn',
            'co',
            'hj',
            'lj',
            'utg',
            'utg1',
            'mp',
            'sb',
            'bb',
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'cash.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(table.scenarioSpec, isNotNull);
      expect(table.scenarioSpec!.seatCount, 9);
      expect(
        canonicalTableTopologyProfileForSeatCountV1(
          table.scenarioSpec!.seatCount,
        ).id,
        CanonicalTableTopologyProfileIdV1.fullRing9Max,
      );
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_8')), findsOneWidget);
      expect(find.byKey(const Key('modern_table_seat_9')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_6')),
          matching: find.text('MP'),
        ),
        findsOneWidget,
      );

      final shiftedHeroCenter = tester.getCenter(
        find.byKey(const Key('modern_table_seat_5')),
      );
      final buttonSeatCenter = tester.getCenter(
        find.byKey(const Key('modern_table_seat_0')),
      );

      expect(
        shiftedHeroCenter.dy,
        greaterThan(buttonSeatCenter.dy),
        reason: 'non-button hero seat should inherit the anchored hero slot',
      );
    },
  );

  testWidgets(
    'canonical path consumes synthetic 10 max authored order end to end',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(1290, 3000);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _syntheticSpatialItem(
          id: 'find_ten_max_anchor',
          prompt: 'Tap MP+1 as the position anchor before acting.',
          heroSeat: 'utg1',
          villainSeat: 'bb',
          activeSeats: const <String>[
            'btn',
            'co',
            'hj',
            'lj',
            'utg',
            'utg1',
            'mp1',
            'mp',
            'sb',
            'bb',
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'cash.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_prompt')),
      );

      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_seat_hero_ring_5')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('modern_table_seat_9')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_5')),
          matching: find.text('UTG+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_6')),
          matching: find.text('MP+1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_7')),
          matching: find.text('MP'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_seat_marker_9')),
          matching: find.text('BB'),
        ),
        findsOneWidget,
      );
    },
  );
}
