import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('active W5 content truth is s01-s10 with w5.s11 preserved only as source', () {
    const activeW5Sessions = <String>[
      'w5.s01',
      'w5.s02',
      'w5.s03',
      'w5.s04',
      'w5.s05',
      'w5.s06',
      'w5.s07',
      'w5.s08',
      'w5.s09',
      'w5.s10',
    ];

    final indexText = File(
      'content/worlds/world5/v1/sessions/index.md',
    ).readAsStringSync();
    final indexSessions = RegExp(
      r'^- (w5\.s\d+):',
      multiLine: true,
    ).allMatches(indexText).map((match) => match.group(1)!).toList();
    expect(indexSessions, activeW5Sessions);
    expect(indexText, isNot(contains('w5.s11:')));

    final drillManifest =
        jsonDecode(
              File(
                'content/_meta/world_drills_manifest_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final drillManifestWorlds = drillManifest['worlds'] as List<dynamic>;
    final drillManifestWorld5 = drillManifestWorlds
        .cast<Map<String, dynamic>>()
        .singleWhere((world) => world['world'] == 5);
    final drillManifestSessions =
        (drillManifestWorld5['sessions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((session) => session['id'] as String)
            .toList();
    expect(drillManifestSessions, activeW5Sessions);
    expect(
      drillManifestSessions,
      isNot(contains('w5.s11')),
      reason:
          'W5.s11 authored source is preserved but must not be active drill-manifest truth.',
    );

    final sessionManifest =
        jsonDecode(
              File(
                'content/_meta/world_sessions_manifest_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final sessionManifestWorlds = sessionManifest['worlds'] as List<dynamic>;
    final sessionManifestWorld5 = sessionManifestWorlds
        .cast<Map<String, dynamic>>()
        .singleWhere((world) => world['world'] == 5);
    final sessionManifestSessions =
        (sessionManifestWorld5['sessions'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map((session) => session['id'] as String)
            .toList();
    expect(sessionManifestSessions, activeW5Sessions);
    expect(
      sessionManifestSessions,
      isNot(contains('w5.s11')),
      reason:
          'W5.s11 authored source is preserved but must not be active session-manifest truth.',
    );

    expect(
      File('content/worlds/world5/v1/sessions/w5.s11/session.md').existsSync(),
      isTrue,
      reason:
          'Owner decision preserves W5.s11 as noncanonical/deferred source.',
    );

    final topIndexText = File(
      'content/worlds/world5/v1/index.md',
    ).readAsStringSync();
    final topIndexSessions = RegExp(
      r'^- (w5\.s\d+):',
      multiLine: true,
    ).allMatches(topIndexText).map((match) => match.group(1)!).toList();
    expect(
      topIndexSessions,
      activeW5Sessions,
      reason:
          'Top-level W5 index must not list w5.s11 as an active session row.',
    );
    expect(
      topIndexText,
      contains('w5.s11'),
      reason:
          'Top-level W5 index must still name w5.s11 as preserved-only source.',
    );
    expect(
      topIndexText,
      contains('inactive'),
      reason:
          'Top-level W5 index must state w5.s11 is inactive, not just absent.',
    );
  });

  test('w5.s01-w5.s10 use board-texture classifier runtime truth', () async {
    final adapter = const DrillRuntimeAdapterV1();

    final w5s01 = await adapter.loadSessionDrills('w5.s01');
    expect(w5s01.map((item) => item.drillId).toList(), <String>[
      'classify_texture_intro_dry_raise_v1',
      'classify_texture_intro_dry_call_control_v1',
      'classify_texture_intro_wet_call_v1',
      'classify_texture_intro_wet_fold_pressure_v1',
      'classify_texture_intro_paired_fold_v1',
      'classify_texture_intro_paired_call_control_v1',
    ]);
    expect(
      w5s01.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s01.first.spec.boardTextureV1, 'dry');
    expect(w5s01.first.spec.expectedActionV1, 'raise');
    expect(w5s01[1].spec.boardTextureV1, 'dry');
    expect(w5s01[1].spec.expectedActionV1, 'call');
    expect(w5s01[2].spec.boardTextureV1, 'wet');
    expect(w5s01[2].spec.expectedActionV1, 'call');
    expect(w5s01[3].spec.boardTextureV1, 'wet');
    expect(w5s01[3].spec.expectedActionV1, 'fold');
    expect(w5s01[4].spec.boardTextureV1, 'paired');
    expect(w5s01[4].spec.expectedActionV1, 'fold');
    expect(w5s01.last.spec.boardTextureV1, 'paired');
    expect(w5s01.last.spec.expectedActionV1, 'call');

    final w5s02 = await adapter.loadSessionDrills('w5.s02');
    expect(w5s02.map((item) => item.drillId).toList(), <String>[
      'classify_dry_discipline_high_card_raise_v1',
      'classify_dry_discipline_paired_call_v1',
      'classify_dry_discipline_trap_fold_v1',
    ]);
    expect(
      w5s02.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s02.first.spec.boardTextureV1, 'high_card');
    expect(w5s02.first.spec.expectedActionV1, 'raise');
    expect(w5s02[1].spec.boardTextureV1, 'paired');
    expect(w5s02[1].spec.expectedActionV1, 'call');
    expect(w5s02.last.spec.boardTextureV1, 'dry');
    expect(w5s02.last.spec.expectedActionV1, 'fold');

    final w5s03 = await adapter.loadSessionDrills('w5.s03');
    expect(w5s03.map((item) => item.drillId).toList(), <String>[
      'classify_wet_protection_connected_call_v1',
      'classify_wet_protection_wet_fold_v1',
      'classify_wet_protection_connected_raise_v1',
    ]);
    expect(
      w5s03.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s03.first.spec.boardTextureV1, 'connected');
    expect(w5s03.first.spec.expectedActionV1, 'call');
    expect(w5s03[1].spec.boardTextureV1, 'wet');
    expect(w5s03[1].spec.expectedActionV1, 'fold');
    expect(w5s03.last.spec.boardTextureV1, 'connected');
    expect(w5s03.last.spec.expectedActionV1, 'raise');

    final w5s04 = await adapter.loadSessionDrills('w5.s04');
    expect(w5s04.map((item) => item.drillId).toList(), <String>[
      'classify_turn_shift_connected_raise_v1',
      'classify_turn_shift_wet_call_v1',
      'classify_turn_shift_paired_fold_v1',
    ]);
    expect(
      w5s04.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s04.first.spec.boardTextureV1, 'connected');
    expect(w5s04.first.spec.expectedActionV1, 'raise');
    expect(w5s04[1].spec.boardTextureV1, 'wet');
    expect(w5s04[1].spec.expectedActionV1, 'call');
    expect(w5s04.last.spec.boardTextureV1, 'paired');
    expect(w5s04.last.spec.expectedActionV1, 'fold');

    final w5s05 = await adapter.loadSessionDrills('w5.s05');
    expect(w5s05.map((item) => item.drillId).toList(), <String>[
      'classify_river_closure_wet_raise_v1',
      'classify_river_closure_connected_call_v1',
      'classify_river_closure_dry_fold_v1',
    ]);
    expect(
      w5s05.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s05.first.spec.boardTextureV1, 'wet');
    expect(w5s05.first.spec.expectedActionV1, 'raise');
    expect(w5s05[1].spec.boardTextureV1, 'connected');
    expect(w5s05[1].spec.expectedActionV1, 'call');
    expect(w5s05.last.spec.boardTextureV1, 'dry');
    expect(w5s05.last.spec.expectedActionV1, 'fold');

    final w5s06 = await adapter.loadSessionDrills('w5.s06');
    expect(w5s06.map((item) => item.drillId).toList(), <String>[
      'classify_in_position_dry_raise_v1',
      'classify_in_position_wet_call_v1',
      'classify_in_position_connected_raise_v1',
    ]);
    expect(
      w5s06.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s06.first.spec.boardTextureV1, 'dry');
    expect(w5s06.first.spec.expectedActionV1, 'raise');
    expect(w5s06[1].spec.boardTextureV1, 'wet');
    expect(w5s06[1].spec.expectedActionV1, 'call');
    expect(w5s06.last.spec.boardTextureV1, 'connected');
    expect(w5s06.last.spec.expectedActionV1, 'raise');

    final w5s07 = await adapter.loadSessionDrills('w5.s07');
    expect(w5s07.map((item) => item.drillId).toList(), <String>[
      'classify_oop_dry_call_v1',
      'classify_oop_wet_fold_v1',
      'classify_oop_connected_call_v1',
    ]);
    expect(
      w5s07.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s07.first.spec.boardTextureV1, 'dry');
    expect(w5s07.first.spec.expectedActionV1, 'call');
    expect(w5s07[1].spec.boardTextureV1, 'wet');
    expect(w5s07[1].spec.expectedActionV1, 'fold');
    expect(w5s07.last.spec.boardTextureV1, 'connected');
    expect(w5s07.last.spec.expectedActionV1, 'call');

    final w5s08 = await adapter.loadSessionDrills('w5.s08');
    expect(w5s08.map((item) => item.drillId).toList(), <String>[
      'classify_draw_completion_wet_raise_v1',
      'classify_draw_completion_connected_call_v1',
      'classify_draw_completion_dry_fold_v1',
    ]);
    expect(
      w5s08.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s08.first.spec.boardTextureV1, 'wet');
    expect(w5s08.first.spec.expectedActionV1, 'raise');
    expect(w5s08[1].spec.boardTextureV1, 'connected');
    expect(w5s08[1].spec.expectedActionV1, 'call');
    expect(w5s08.last.spec.boardTextureV1, 'dry');
    expect(w5s08.last.spec.expectedActionV1, 'fold');

    final w5s09 = await adapter.loadSessionDrills('w5.s09');
    expect(w5s09.map((item) => item.drillId).toList(), <String>[
      'classify_blocker_context_connected_raise_v1',
      'classify_blocker_context_paired_call_v1',
      'classify_blocker_context_high_card_fold_v1',
    ]);
    expect(
      w5s09.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s09.first.spec.boardTextureV1, 'connected');
    expect(w5s09.first.spec.expectedActionV1, 'raise');
    expect(w5s09[1].spec.boardTextureV1, 'paired');
    expect(w5s09[1].spec.expectedActionV1, 'call');
    expect(w5s09.last.spec.boardTextureV1, 'high_card');
    expect(w5s09.last.spec.expectedActionV1, 'fold');

    final w5s10 = await adapter.loadSessionDrills('w5.s10');
    expect(w5s10.map((item) => item.drillId).toList(), <String>[
      'classify_texture_synthesis_dry_raise_v1',
      'classify_texture_synthesis_connected_call_v1',
      'classify_texture_synthesis_wet_fold_v1',
    ]);
    expect(
      w5s10.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s10.first.spec.boardTextureV1, 'dry');
    expect(w5s10.first.spec.expectedActionV1, 'raise');
    expect(w5s10[1].spec.boardTextureV1, 'connected');
    expect(w5s10[1].spec.expectedActionV1, 'call');
    expect(w5s10.last.spec.boardTextureV1, 'wet');
    expect(w5s10.last.spec.expectedActionV1, 'fold');
  });

  test('active W5 board-texture rows expose authored visible board state', () async {
    final adapter = const DrillRuntimeAdapterV1();
    final expectedStreetBySession = <String, String>{
      for (final sessionId in <String>[
        'w5.s01',
        'w5.s02',
        'w5.s03',
        'w5.s06',
        'w5.s07',
        'w5.s09',
        'w5.s10',
      ])
        sessionId: 'flop',
      'w5.s04': 'turn',
      'w5.s05': 'river',
      'w5.s08': 'river',
    };

    for (final entry in expectedStreetBySession.entries) {
      final sessionId = entry.key;
      final expectedStreet = entry.value;
      final drills = await adapter.loadSessionDrills(sessionId);
      final boardTextureRows = drills.where(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      );

      for (final item in boardTextureRows) {
        final spec = item.spec;
        final context = spec.scenarioBoardTextureContextV1;
        expect(
          context,
          isNotNull,
          reason:
              '$sessionId/${item.drillId} must author street_v1 and board_cards_v1; W5 table context must not be inferred from prompt text.',
        );
        expect(
          context!.streetV1,
          expectedStreet,
          reason:
              '$sessionId/${item.drillId} visible street must match active session ownership.',
        );
        expect(
          context.boardCardsV1.length,
          switch (expectedStreet) {
            'flop' => 3,
            'turn' => 4,
            'river' => 5,
            _ => throw StateError('Unexpected W5 street $expectedStreet'),
          },
          reason:
              '$sessionId/${item.drillId} must expose exactly the visible cards for $expectedStreet.',
        );
        expect(
          context.boardTextureV1,
          spec.boardTextureV1,
          reason:
              '$sessionId/${item.drillId} prompt/table texture source must remain aligned.',
        );
        expect(
          context.availableActionsV1,
          spec.availableActionsV1,
          reason:
              '$sessionId/${item.drillId} structured context must preserve legal action source.',
        );
        expect(
          context.expectedActionIdV1,
          spec.expectedActionV1,
          reason:
              '$sessionId/${item.drillId} structured context must preserve expected-action source.',
        );
      }
    }
  });
}
