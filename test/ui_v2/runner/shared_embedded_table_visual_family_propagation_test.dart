import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_embedded_table_visual_family_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 80),
  int maxTicks = 120,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for ${finder.description}');
}

Future<void> _advanceToCampaignActionBarV1(WidgetTester tester) async {
  final actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
  final seatFallbacks = <Finder>[
    find.byKey(const Key('microtask_seat_btn')),
    find.byKey(const Key('microtask_seat_sb')),
    find.byKey(const Key('microtask_seat_bb')),
    find.byKey(const Key('microtask_seat_utg')),
    find.byKey(const Key('microtask_seat_hj')),
    find.byKey(const Key('microtask_seat_co')),
  ];

  Future<bool> tapIfEnabled(Key key) async {
    final finder = find.byKey(key);
    if (finder.evaluate().isEmpty) return false;
    final target = finder.first;
    final widget = tester.widget<Widget>(target);
    final enabled = switch (widget) {
      ElevatedButton button => button.onPressed != null,
      FilledButton button => button.onPressed != null,
      OutlinedButton button => button.onPressed != null,
      TextButton button => button.onPressed != null,
      _ => true,
    };
    if (!enabled) return false;
    await tester.tap(target, warnIfMissed: false);
    await tester.pump();
    return true;
  }

  Finder? seatFromPrompt() {
    final promptFinder = find.byKey(const Key('microtask_step_prompt'));
    if (promptFinder.evaluate().isEmpty) return null;
    final widget = tester.widget<Widget>(promptFinder.first);
    if (widget is! Text) return null;
    final text = (widget.data ?? '').toLowerCase();
    if (text.contains('button'))
      return find.byKey(const Key('microtask_seat_btn'));
    if (text.contains('small blind'))
      return find.byKey(const Key('microtask_seat_sb'));
    if (text.contains('big blind'))
      return find.byKey(const Key('microtask_seat_bb'));
    if (text.contains('hijack'))
      return find.byKey(const Key('microtask_seat_hj'));
    if (text.contains('cutoff') || text.contains('cut off')) {
      return find.byKey(const Key('microtask_seat_co'));
    }
    if (text.contains('utg'))
      return find.byKey(const Key('microtask_seat_utg'));
    return null;
  }

  for (var i = 0; i < 260; i++) {
    if (actionBar.evaluate().isNotEmpty) return;
    if (await tapIfEnabled(const Key('microtask_prelude_continue_cta_v1'))) {
      continue;
    }
    if (await tapIfEnabled(const Key('microtask_intro_continue_cta_v1'))) {
      continue;
    }
    if (await tapIfEnabled(const Key('microtask_continue_cta'))) {
      continue;
    }
    final seatFinder =
        seatFromPrompt() ?? seatFallbacks[i % seatFallbacks.length];
    if (seatFinder.evaluate().isNotEmpty) {
      await tester.tap(seatFinder, warnIfMissed: false);
      await tester.pump();
    }
    await tapIfEnabled(const Key('microtask_check_cta'));
    await tester.pump(const Duration(milliseconds: 60));
  }
  fail('Unable to reach campaign action bar deterministically.');
}

SessionDrillItemV1 _world2BoardTextureItem() {
  return SessionDrillItemV1(
    drillId: 'world2_visual_family_contract_v1',
    spec: DrillSpecV1.fromJsonString(
      '{"id":"world2_visual_family_contract_v1","kind":"board_texture_classifier_v1","prompt":"Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.","intro_v1":"Read the real board first. Dry flops usually keep pressure lower because fewer turn cards change the picture fast.","street_v1":"flop","board_cards_v1":["As","7d","2c"],"board_texture_v1":"dry","board_texture_policy_shape_v1":"pressure_level","board_texture_policy_target_v1":"calmer","available_actions_v1":["call","raise"],"expected_action":"call","error_class":"expected_action_mismatch","why_v1":"A-7-2 rainbow is dry, so fewer draws and turn shifts build pressure right away.","feedback_correct_v1":"Correct. This flop stays calmer because it does not create many immediate draw paths.","feedback_incorrect_v1":"Incorrect. This flop is the calmer board because the texture stays dry and stable."}',
    ),
  );
}

void _expectTableMatchesContract(
  ModernTableScreenV1 table,
  SharedEmbeddedTableVisualFamilyContractV1 contract,
) {
  expect(
    table.embeddedSceneGeometryProfileV1,
    contract.embeddedSceneGeometryProfileV1,
  );
  expect(table.seatStateVisualProfileV1, contract.seatStateVisualProfileV1);
  expect(table.sceneLanePromptProfileV1, contract.sceneLanePromptProfileV1);
  expect(
    table.useReferenceParityLiveProfileV1,
    contract.useReferenceParityLiveProfileV1,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'shared live-compatible visual family baseline propagates to world1 and surfaced presets',
    () {
      final world1 = resolveSharedEmbeddedTableVisualFamilyV1(
        preset: SharedEmbeddedTableVisualFamilyPresetV1.world1LiveSceneOwned,
      );
      final surfaced = resolveSharedEmbeddedTableVisualFamilyV1(
        preset: SharedEmbeddedTableVisualFamilyPresetV1.surfacedLiveCompatible,
      );

      expect(
        world1.embeddedSceneGeometryProfileV1,
        surfaced.embeddedSceneGeometryProfileV1,
      );
      expect(
        world1.seatStateVisualProfileV1,
        surfaced.seatStateVisualProfileV1,
      );
      expect(
        world1.sceneLanePromptProfileV1,
        surfaced.sceneLanePromptProfileV1,
      );
      expect(world1.useReferenceParityLiveProfileV1, isTrue);
      expect(world1.useSceneOwnedInstructionV1, isTrue);
      expect(surfaced.useReferenceParityLiveProfileV1, isFalse);
      expect(surfaced.useSceneOwnedInstructionV1, isFalse);
    },
  );

  testWidgets(
    'world1 live hand-loop consumes the shared embedded table visual family contract',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings_engine_v2_backend_enabled_v1': true,
        'app_settings_checkpoint_mode_override_v1': true,
        'global_training_intro_seen_v1': true,
        'world1_intro_seen_v1': true,
        'world1_action_intro_seen_v1': true,
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_act0_action_literacy',
            moduleTitle: 'World 1',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pump();
      await _advanceToCampaignActionBarV1(tester);
      await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));

      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      final contract = resolveSharedEmbeddedTableVisualFamilyV1(
        preset: SharedEmbeddedTableVisualFamilyPresetV1.world1LiveSceneOwned,
      );
      _expectTableMatchesContract(table, contract);
      expect(
        find.byKey(const Key('modern_table_scene_prompt')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'surfaced World2 portrait table consumes the shared live-compatible visual family contract',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s04',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _world2BoardTextureItem(),
            ],
          ),
        ),
      );
      await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));

      final table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      final contract = resolveSharedEmbeddedTableVisualFamilyV1(
        preset: SharedEmbeddedTableVisualFamilyPresetV1.surfacedLiveCompatible,
      );
      _expectTableMatchesContract(table, contract);
      expect(
        find.byKey(const Key('modern_table_scene_state_lane')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_scene_board_state')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'surfaced World3 portrait continuation table consumes the shared live-compatible visual family contract',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s04'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w3.s04',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );

      final table = tester.widget<ModernTableScreenV1>(
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );
      final contract = resolveSharedEmbeddedTableVisualFamilyV1(
        preset: SharedEmbeddedTableVisualFamilyPresetV1.surfacedLiveCompatible,
      );
      _expectTableMatchesContract(table, contract);
      expect(
        find.byKey(const Key('modern_table_scene_state_lane')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_scene_board_state')),
        findsOneWidget,
      );
    },
  );
}
