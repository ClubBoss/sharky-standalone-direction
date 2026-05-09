import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> _decodeManifest(String raw) =>
      jsonDecode(raw) as Map<String, dynamic>;

  List<Map<String, dynamic>> _sessionEntriesForWorld(
    Map<String, dynamic> manifest,
    int world,
  ) {
    final worlds = (manifest['worlds'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>();
    final entry = worlds.firstWhere((candidate) => candidate['world'] == world);
    return (entry['sessions'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map(
          (session) =>
              session.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList(growable: false);
  }

  List<String> _drillIdsForSession(
    List<Map<String, dynamic>> sessions,
    String sessionId,
  ) {
    final session = sessions.firstWhere(
      (candidate) => candidate['id'] == sessionId,
    );
    return (session['drills'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .map((drill) => drill['id']! as String)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _bundledDrillManifest() async => _decodeManifest(
    await rootBundle.loadString('content/_meta/world_drills_manifest_v1.json'),
  );

  Map<String, dynamic> _sourceDrillManifest() => _decodeManifest(
    File('content/_meta/world_drills_manifest_v1.json').readAsStringSync(),
  );

  Map<String, dynamic>? _optionalRuntimeBundleManifest() {
    const candidates = <String>[
      'build/flutter_assets/content/_meta/world_drills_manifest_v1.json',
      'build/ios/Debug-iphonesimulator/App.framework/flutter_assets/content/_meta/world_drills_manifest_v1.json',
      'build/ios/iphonesimulator/Runner.app/Frameworks/App.framework/flutter_assets/content/_meta/world_drills_manifest_v1.json',
    ];
    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) {
        return _decodeManifest(file.readAsStringSync());
      }
    }
    return null;
  }

  List<String> _optionalRuntimeBundleRoots() {
    const candidates = <String>['build/flutter_assets'];
    return candidates
        .where((path) => Directory(path).existsSync())
        .toList(growable: false);
  }

  Future<void> _expectBundledAssetsForSessions(
    Map<String, dynamic> assetManifest,
    List<String> sessionIds,
  ) async {
    for (final sessionId in sessionIds) {
      final sessionAsset =
          'content/worlds/world${sessionId[1]}/v1/sessions/$sessionId/session.md';
      final drillIndexAsset =
          'content/worlds/world${sessionId[1]}/v1/sessions/$sessionId/drills/index.md';

      expect(
        assetManifest.containsKey(sessionAsset),
        isTrue,
        reason: 'Missing bundled session asset: $sessionAsset',
      );
      expect(
        assetManifest.containsKey(drillIndexAsset),
        isTrue,
        reason: 'Missing bundled drill index asset: $drillIndexAsset',
      );

      expect(await rootBundle.loadString(sessionAsset), isNotEmpty);
      expect(await rootBundle.loadString(drillIndexAsset), isNotEmpty);
    }
  }

  Future<void> _expectBundledDrillAssets(
    Map<String, dynamic> assetManifest,
    Map<String, List<String>> expectedDrillsBySession,
  ) async {
    for (final entry in expectedDrillsBySession.entries) {
      final sessionId = entry.key;
      final world = RegExp(r'^w([0-9]+)\.').firstMatch(sessionId)!.group(1)!;
      for (final drillId in entry.value) {
        final drillAsset =
            'content/worlds/world$world/v1/sessions/$sessionId/drills/d.$drillId.json';
        expect(
          assetManifest.containsKey(drillAsset),
          isTrue,
          reason: 'Missing bundled drill asset: $drillAsset',
        );
        expect(
          await rootBundle.loadString(drillAsset),
          isNotEmpty,
          reason: 'Empty bundled drill asset: $drillAsset',
        );
      }
    }
  }

  void _expectRuntimeBundleFileParity(
    List<String> bundleRoots,
    List<String> sessionIds,
    Map<String, List<String>> expectedDrillsBySession,
  ) {
    for (final root in bundleRoots) {
      for (final sessionId in sessionIds) {
        final world = RegExp(r'^w([0-9]+)\.').firstMatch(sessionId)!.group(1)!;
        final sessionAsset =
            'content/worlds/world$world/v1/sessions/$sessionId/session.md';
        final drillIndexAsset =
            'content/worlds/world$world/v1/sessions/$sessionId/drills/index.md';
        for (final relativePath in <String>[sessionAsset, drillIndexAsset]) {
          final file = File('$root/$relativePath');
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Missing runtime bundle asset: $root/$relativePath',
          );
          expect(
            file.readAsStringSync(),
            isNotEmpty,
            reason: 'Empty runtime bundle asset: $root/$relativePath',
          );
        }
      }
      for (final entry in expectedDrillsBySession.entries) {
        final sessionId = entry.key;
        final world = RegExp(r'^w([0-9]+)\.').firstMatch(sessionId)!.group(1)!;
        for (final drillId in entry.value) {
          final relativePath =
              'content/worlds/world$world/v1/sessions/$sessionId/drills/d.$drillId.json';
          final file = File('$root/$relativePath');
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Missing runtime bundle drill asset: $root/$relativePath',
          );
          expect(
            file.readAsStringSync(),
            isNotEmpty,
            reason: 'Empty runtime bundle drill asset: $root/$relativePath',
          );
        }
      }
    }
  }

  test('world2 surfaced live-session class is bundled end-to-end', () async {
    final manifestRaw = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
    final drillManifestRaw = await rootBundle.loadString(
      'content/_meta/world_drills_manifest_v1.json',
    );
    final drillManifest = jsonDecode(drillManifestRaw) as Map<String, dynamic>;
    final world2 = (drillManifest['worlds'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .firstWhere((world) => world['world'] == 2);
    final sessions = (world2['sessions'] as List<dynamic>)
        .cast<Map<dynamic, dynamic>>()
        .where((session) {
          final id = session['id'];
          return id is String && RegExp(r'^w2\.s(0[1-9]|1[0-4])$').hasMatch(id);
        })
        .toList(growable: false);

    expect(sessions, isNotEmpty);

    for (final session in sessions) {
      final sessionId = session['id']! as String;
      final sessionAsset =
          'content/worlds/world2/v1/sessions/$sessionId/session.md';
      final drillIndexAsset =
          'content/worlds/world2/v1/sessions/$sessionId/drills/index.md';
      final drills = (session['drills'] as List<dynamic>)
          .cast<Map<dynamic, dynamic>>()
          .map((drill) => drill['id']! as String)
          .toList(growable: false);

      expect(
        manifest.containsKey(sessionAsset),
        isTrue,
        reason: 'Missing bundled session asset: $sessionAsset',
      );
      expect(
        manifest.containsKey(drillIndexAsset),
        isTrue,
        reason: 'Missing bundled drill index asset: $drillIndexAsset',
      );

      final sessionRaw = await rootBundle.loadString(sessionAsset);
      expect(
        sessionRaw,
        isNotEmpty,
        reason: 'Empty bundled session asset: $sessionAsset',
      );
      final drillIndexRaw = await rootBundle.loadString(drillIndexAsset);
      expect(
        drillIndexRaw,
        isNotEmpty,
        reason: 'Empty bundled drill index asset: $drillIndexAsset',
      );

      for (final drillId in drills) {
        final drillAsset =
            'content/worlds/world2/v1/sessions/$sessionId/drills/d.$drillId.json';
        expect(
          manifest.containsKey(drillAsset),
          isTrue,
          reason: 'Missing bundled drill asset: $drillAsset',
        );
        expect(
          manifest.containsKey(drillAsset),
          isTrue,
          reason: 'AssetManifest missing drill asset: $drillAsset',
        );
        final raw = await rootBundle.loadString(drillAsset);
        expect(
          raw,
          isNotEmpty,
          reason: 'Empty bundled drill asset: $drillAsset',
        );
      }
    }
  });

  test(
    'world1 w1.s01 pilot family stays in bounded source/bundle parity',
    () async {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final assetManifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      final sourceManifest = _sourceDrillManifest();
      final bundledManifest = await _bundledDrillManifest();
      final runtimeBundleManifest = _optionalRuntimeBundleManifest();
      final runtimeBundleRoots = _optionalRuntimeBundleRoots();

      const sessionId = 'w1.s01';
      const expectedDrillsBySession = <String, List<String>>{
        'w1.s01': <String>[
          'choose_call',
          'choose_fold',
          'choose_half_pot_value',
          'choose_min_raise_reopen',
          'choose_one_third_pot_keep_price',
          'choose_pot_pressure',
          'find_btn',
          'find_seat_s3',
          'tap_flop_right',
          'tap_hole_left',
        ],
      };

      final sourceSessions = _sessionEntriesForWorld(sourceManifest, 1);
      final bundledSessions = _sessionEntriesForWorld(bundledManifest, 1);
      final runtimeSessions = runtimeBundleManifest == null
          ? null
          : _sessionEntriesForWorld(runtimeBundleManifest, 1);

      expect(
        _drillIdsForSession(sourceSessions, sessionId),
        unorderedEquals(expectedDrillsBySession[sessionId]!),
      );
      expect(
        _drillIdsForSession(bundledSessions, sessionId),
        unorderedEquals(expectedDrillsBySession[sessionId]!),
      );
      if (runtimeSessions != null) {
        expect(
          _drillIdsForSession(runtimeSessions, sessionId),
          unorderedEquals(expectedDrillsBySession[sessionId]!),
          reason: 'Runtime bundle manifest drift remains for $sessionId',
        );
      }

      await _expectBundledAssetsForSessions(assetManifest, const <String>[
        sessionId,
      ]);
      await _expectBundledDrillAssets(assetManifest, expectedDrillsBySession);
      _expectRuntimeBundleFileParity(runtimeBundleRoots, const <String>[
        sessionId,
      ], expectedDrillsBySession);
    },
  );

  test(
    'world1 w1.s02-w1.s03 expansion cluster stays in bounded source/bundle parity',
    () async {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final assetManifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      final sourceManifest = _sourceDrillManifest();
      final bundledManifest = await _bundledDrillManifest();
      final runtimeBundleManifest = _optionalRuntimeBundleManifest();
      final runtimeBundleRoots = _optionalRuntimeBundleRoots();

      const sessionIds = <String>['w1.s02', 'w1.s03'];
      const expectedDrillsBySession = <String, List<String>>{
        'w1.s02': <String>[
          'choose_button_open_clean_v1',
          'choose_small_blind_release_caution_v1',
          'choose_big_blind_continue_defend_v1',
        ],
        'w1.s03': <String>[
          'choose_first_in_raise_after_folds_v1',
          'choose_call_when_pressure_reaches_you_v1',
          'choose_fold_when_multiway_pressure_stacks_v1',
        ],
      };

      final sourceSessions = _sessionEntriesForWorld(sourceManifest, 1);
      final bundledSessions = _sessionEntriesForWorld(bundledManifest, 1);
      final runtimeSessions = runtimeBundleManifest == null
          ? null
          : _sessionEntriesForWorld(runtimeBundleManifest, 1);

      for (final sessionId in sessionIds) {
        expect(
          _drillIdsForSession(sourceSessions, sessionId),
          unorderedEquals(expectedDrillsBySession[sessionId]!),
        );
        expect(
          _drillIdsForSession(bundledSessions, sessionId),
          unorderedEquals(expectedDrillsBySession[sessionId]!),
        );
        if (runtimeSessions != null) {
          expect(
            _drillIdsForSession(runtimeSessions, sessionId),
            unorderedEquals(expectedDrillsBySession[sessionId]!),
            reason: 'Runtime bundle manifest drift remains for $sessionId',
          );
        }
      }

      await _expectBundledAssetsForSessions(assetManifest, sessionIds);
      await _expectBundledDrillAssets(assetManifest, expectedDrillsBySession);
      _expectRuntimeBundleFileParity(
        runtimeBundleRoots,
        sessionIds,
        expectedDrillsBySession,
      );
    },
  );

  test(
    'world1 w1.s04-w1.s06 continuation cluster stays in bounded source/bundle parity',
    () async {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final assetManifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      final sourceManifest = _sourceDrillManifest();
      final bundledManifest = await _bundledDrillManifest();
      final runtimeBundleManifest = _optionalRuntimeBundleManifest();
      final runtimeBundleRoots = _optionalRuntimeBundleRoots();

      const sessionIds = <String>['w1.s04', 'w1.s05', 'w1.s06'];
      const expectedDrillsBySession = <String, List<String>>{
        'w1.s04': <String>[
          'choose_button_open_repeat_stability_v1',
          'choose_small_blind_fold_repeat_stability_v1',
          'choose_big_blind_call_repeat_stability_v1',
        ],
        'w1.s05': <String>[
          'choose_cutoff_raise_clean_start_v1',
          'choose_small_blind_fold_weak_start_v1',
          'choose_button_call_playable_pressure_v1',
        ],
        'w1.s06': <String>[
          'choose_raise_clean_first_in_checkpoint_v1',
          'choose_call_facing_open_checkpoint_v1',
          'choose_fold_oop_pressure_checkpoint_v1',
        ],
      };

      final sourceSessions = _sessionEntriesForWorld(sourceManifest, 1);
      final bundledSessions = _sessionEntriesForWorld(bundledManifest, 1);
      final runtimeSessions = runtimeBundleManifest == null
          ? null
          : _sessionEntriesForWorld(runtimeBundleManifest, 1);

      for (final sessionId in sessionIds) {
        expect(
          _drillIdsForSession(sourceSessions, sessionId),
          unorderedEquals(expectedDrillsBySession[sessionId]!),
        );
        expect(
          _drillIdsForSession(bundledSessions, sessionId),
          unorderedEquals(expectedDrillsBySession[sessionId]!),
        );
        if (runtimeSessions != null) {
          expect(
            _drillIdsForSession(runtimeSessions, sessionId),
            unorderedEquals(expectedDrillsBySession[sessionId]!),
            reason: 'Runtime bundle manifest drift remains for $sessionId',
          );
        }
      }

      await _expectBundledAssetsForSessions(assetManifest, sessionIds);
      await _expectBundledDrillAssets(assetManifest, expectedDrillsBySession);
      _expectRuntimeBundleFileParity(
        runtimeBundleRoots,
        sessionIds,
        expectedDrillsBySession,
      );
    },
  );

  test(
    'world1 w1.s07-w1.s10 focused tail and final checkpoint stay in bounded source/bundle parity',
    () async {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final assetManifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      final sourceManifest = _sourceDrillManifest();
      final bundledManifest = await _bundledDrillManifest();
      final runtimeBundleManifest = _optionalRuntimeBundleManifest();
      final runtimeBundleRoots = _optionalRuntimeBundleRoots();

      const sessionIds = <String>['w1.s07', 'w1.s08', 'w1.s09', 'w1.s10'];
      const expectedDrillsBySession = <String, List<String>>{
        'w1.s07': <String>[
          'choose_button_raise_in_position_focus_v1',
          'choose_cutoff_call_in_position_pressure_v1',
          'choose_button_fold_in_position_discipline_v1',
        ],
        'w1.s08': <String>[
          'choose_small_blind_fold_oop_focus_v1',
          'choose_big_blind_call_oop_defend_focus_v1',
          'choose_small_blind_raise_oop_clean_start_v1',
        ],
        'w1.s09': <String>[
          'choose_raise_when_action_folds_to_you_focus_v1',
          'choose_call_when_open_reaches_you_focus_v1',
          'choose_fold_when_pressure_and_position_fail_focus_v1',
        ],
        'w1.s10': <String>[
          'choose_raise_focus',
          'choose_call_focus',
          'choose_fold_focus',
        ],
      };

      final sourceSessions = _sessionEntriesForWorld(sourceManifest, 1);
      final bundledSessions = _sessionEntriesForWorld(bundledManifest, 1);
      final runtimeSessions = runtimeBundleManifest == null
          ? null
          : _sessionEntriesForWorld(runtimeBundleManifest, 1);

      for (final sessionId in sessionIds) {
        expect(
          _drillIdsForSession(sourceSessions, sessionId),
          unorderedEquals(expectedDrillsBySession[sessionId]!),
        );
        expect(
          _drillIdsForSession(bundledSessions, sessionId),
          unorderedEquals(expectedDrillsBySession[sessionId]!),
        );
        if (runtimeSessions != null) {
          expect(
            _drillIdsForSession(runtimeSessions, sessionId),
            unorderedEquals(expectedDrillsBySession[sessionId]!),
            reason: 'Runtime bundle manifest drift remains for $sessionId',
          );
        }
      }

      await _expectBundledAssetsForSessions(assetManifest, sessionIds);
      await _expectBundledDrillAssets(assetManifest, expectedDrillsBySession);
      _expectRuntimeBundleFileParity(
        runtimeBundleRoots,
        sessionIds,
        expectedDrillsBySession,
      );
    },
  );

  test(
    'spatial projection defaults are bundled and hydrate representative W6-W10 live sessions',
    () async {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final assetManifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      const defaultsAssets = <String>[
        'content/worlds/world4/v1/sessions/spatial_projection_defaults_v1.json',
        'content/worlds/world6/v1/sessions/spatial_projection_defaults_v1.json',
        'content/worlds/world7/v1/sessions/spatial_projection_defaults_v1.json',
        'content/worlds/world8/v1/sessions/spatial_projection_defaults_v1.json',
        'content/worlds/world9/v1/sessions/spatial_projection_defaults_v1.json',
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        'content/worlds/world10/v1/tracks/tournament/sessions/spatial_projection_defaults_v1.json',
        'content/worlds/world10/v1/tracks/mixed/sessions/spatial_projection_defaults_v1.json',
      ];
      for (final asset in defaultsAssets) {
        expect(
          assetManifest.containsKey(asset),
          isTrue,
          reason: 'Missing bundled spatial defaults asset: $asset',
        );
        expect(
          await rootBundle.loadString(asset),
          isNotEmpty,
          reason: 'Empty bundled spatial defaults asset: $asset',
        );
      }

      final adapter = const DrillRuntimeAdapterV1();
      final representativeSessions = <String, String>{
        'w6.s03': 'find_sb',
        'w7.s04': 'find_btn_deep',
        'w8.s02': 'find_sb',
        'w9.s03': 'find_btn',
        'cash.s01': 'find_role_anchor',
        'tournament.s05': 'find_role_anchor',
        'mixed.s10': 'find_role_anchor',
      };
      for (final entry in representativeSessions.entries) {
        final drills = await adapter.loadSessionDrills(entry.key);
        final drill = drills.firstWhere((item) => item.drillId == entry.value);
        expect(
          drill.spec.kind,
          DrillKindV1.seatTap,
          reason: 'Expected representative seatTap for ${entry.key}',
        );
        expect(
          drill.spec.scenarioTableContextV1,
          isNotNull,
          reason:
              'Defaults were not applied on the bundled runtime path for ${entry.key}',
        );
      }
    },
  );

  test(
    'repaired world3 and world5 manifest truth stays in parity across source, test bundle, and runtime bundle',
    () async {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final assetManifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      final sourceManifest = _sourceDrillManifest();
      final bundledManifest = await _bundledDrillManifest();
      final runtimeBundleManifest = _optionalRuntimeBundleManifest();
      final runtimeBundleRoots = _optionalRuntimeBundleRoots();

      const expectedWorld5DrillsBySession = <String, List<String>>{
        'w5.s01': <String>[
          'classify_texture_intro_dry_raise_v1',
          'classify_texture_intro_wet_call_v1',
          'classify_texture_intro_paired_fold_v1',
        ],
        'w5.s02': <String>[
          'classify_dry_discipline_high_card_raise_v1',
          'classify_dry_discipline_paired_call_v1',
          'classify_dry_discipline_trap_fold_v1',
        ],
        'w5.s03': <String>[
          'classify_wet_protection_connected_call_v1',
          'classify_wet_protection_wet_fold_v1',
          'classify_wet_protection_connected_raise_v1',
        ],
        'w5.s04': <String>[
          'classify_turn_shift_connected_raise_v1',
          'classify_turn_shift_wet_call_v1',
          'classify_turn_shift_paired_fold_v1',
        ],
        'w5.s05': <String>[
          'classify_river_closure_wet_raise_v1',
          'classify_river_closure_connected_call_v1',
          'classify_river_closure_dry_fold_v1',
        ],
        'w5.s06': <String>[
          'classify_in_position_dry_raise_v1',
          'classify_in_position_wet_call_v1',
          'classify_in_position_connected_raise_v1',
        ],
        'w5.s07': <String>[
          'classify_oop_dry_call_v1',
          'classify_oop_wet_fold_v1',
          'classify_oop_connected_call_v1',
        ],
        'w5.s08': <String>[
          'classify_draw_completion_wet_raise_v1',
          'classify_draw_completion_connected_call_v1',
          'classify_draw_completion_dry_fold_v1',
        ],
        'w5.s09': <String>[
          'classify_blocker_context_connected_raise_v1',
          'classify_blocker_context_paired_call_v1',
          'classify_blocker_context_high_card_fold_v1',
        ],
        'w5.s10': <String>[
          'classify_texture_synthesis_dry_raise_v1',
          'classify_texture_synthesis_connected_call_v1',
          'classify_texture_synthesis_wet_fold_v1',
        ],
      };

      const expectedWorld3DrillsBySession = <String, List<String>>{
        'w3.s01': <String>['chain_preflop_framework_intro_v1'],
        'w3.s02': <String>['chain_preflop_category_reuse_v1'],
        'w3.s03': <String>['chain_preflop_checkpoint_v1'],
        'w3.s04': <String>['chain_preflop_premium_strong_reps_v1'],
        'w3.s05': <String>['chain_preflop_medium_weak_discipline_v1'],
        'w3.s06': <String>['chain_preflop_mixed_context_checkpoint_v1'],
        'w3.s07': <String>['chain_preflop_open_fold_position_v1'],
        'w3.s08': <String>['chain_preflop_continue_fold_discipline_v1'],
        'w3.s09': <String>['chain_preflop_same_hand_different_action_v1'],
        'w3.s10': <String>['chain_preflop_final_checkpoint_v1'],
      };

      const forbiddenLegacyIds = <String>{
        'find_sb_closure',
        'find_btn_checkpoint',
        'find_btn_blocker',
        'find_btn_ip',
        'find_btn_shift',
        'choose_call_checkpoint',
        'choose_raise_checkpoint',
        'tap_flop_checkpoint',
        'tap_hole_right_checkpoint',
        'tap_river_checkpoint',
      };

      Future<void> expectParityForFamily(
        int world,
        Map<String, List<String>> expectedDrillsBySession,
      ) async {
        final sourceSessions = _sessionEntriesForWorld(sourceManifest, world);
        final bundledSessions = _sessionEntriesForWorld(bundledManifest, world);
        final runtimeSessions = runtimeBundleManifest == null
            ? null
            : _sessionEntriesForWorld(runtimeBundleManifest, world);

        for (final sessionId in expectedDrillsBySession.keys) {
          final expectedDrills = expectedDrillsBySession[sessionId]!;
          expect(
            _drillIdsForSession(sourceSessions, sessionId),
            unorderedEquals(expectedDrills),
          );
          expect(
            _drillIdsForSession(bundledSessions, sessionId),
            unorderedEquals(expectedDrills),
          );
          if (runtimeSessions != null) {
            expect(
              _drillIdsForSession(runtimeSessions, sessionId),
              unorderedEquals(expectedDrills),
              reason:
                  'Stale runtime bundle manifest drift remains for $sessionId',
            );
          }
          expect(
            expectedDrills.any(forbiddenLegacyIds.contains),
            isFalse,
            reason:
                'Retired ids remain in expected repaired truth for $sessionId',
          );
        }
      }

      for (final forbiddenId in forbiddenLegacyIds) {
        final sourceRaw = jsonEncode(sourceManifest);
        final bundledRaw = jsonEncode(bundledManifest);
        expect(
          sourceRaw.contains('"id":"$forbiddenId"'),
          isFalse,
          reason: 'Retired id remains in source manifest: $forbiddenId',
        );
        expect(
          bundledRaw.contains('"id":"$forbiddenId"'),
          isFalse,
          reason: 'Retired id remains in bundled manifest: $forbiddenId',
        );
        if (runtimeBundleManifest != null) {
          expect(
            jsonEncode(runtimeBundleManifest).contains('"id":"$forbiddenId"'),
            isFalse,
            reason:
                'Retired id remains in runtime bundle manifest: $forbiddenId',
          );
        }
      }

      await expectParityForFamily(3, expectedWorld3DrillsBySession);
      await expectParityForFamily(5, expectedWorld5DrillsBySession);

      await _expectBundledAssetsForSessions(
        assetManifest,
        expectedWorld3DrillsBySession.keys.toList(growable: false),
      );
      await _expectBundledDrillAssets(
        assetManifest,
        expectedWorld3DrillsBySession,
      );
      _expectRuntimeBundleFileParity(
        runtimeBundleRoots,
        expectedWorld3DrillsBySession.keys.toList(growable: false),
        expectedWorld3DrillsBySession,
      );
      await _expectBundledAssetsForSessions(
        assetManifest,
        expectedWorld5DrillsBySession.keys.toList(growable: false),
      );
      await _expectBundledDrillAssets(
        assetManifest,
        expectedWorld5DrillsBySession,
      );
      _expectRuntimeBundleFileParity(
        runtimeBundleRoots,
        expectedWorld5DrillsBySession.keys.toList(growable: false),
        expectedWorld5DrillsBySession,
      );
    },
  );
}
