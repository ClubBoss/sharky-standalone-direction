import 'package:poker_analyzer/canonical/world1_topology_entry_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_entry_metadata_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/viral_proof_v1.dart';
import 'package:test/test.dart';

void main() {
  test('world1 module order is canonical regardless of loader order', () {
    final scrambled = <Map<String, dynamic>>[
      {'id': 'world1_spine_followup_v1_b1'},
      {'id': 'world1_act0_action_literacy'},
      {'id': 'world1_spine_campaign_v1'},
      {'id': 'world1_act0_street_flow'},
      {'id': 'world1_spine_followup_v1_b2'},
      {'id': 'world1_act0_table_literacy'},
      {'id': 'world1_spine_followup_v1_b0'},
    ];

    final ordered = orderWorld1Modules(scrambled);
    final orderedIds = ordered.map((e) => e['id']).toList();

    expect(orderedIds, kWorld1CanonicalModuleOrder);
  });

  test('unlock state is deterministic by previous level completion', () {
    final nodes = <Map<String, dynamic>>[
      {
        'id': 'world1_act0_table_literacy',
        'isCompleted': true,
        'isAvailable': true,
      },
      {'id': 'world1_act0_action_literacy', 'isCompleted': true},
      {'id': 'world1_act0_street_flow', 'isCompleted': false},
      {'id': 'world1_spine_campaign_v1', 'isCompleted': false},
    ];

    final unlocked = applyLinearUnlockByPreviousCompletion(nodes);
    final unlockedFlags = unlocked.map((e) => e['isUnlocked']).toList();

    expect(unlockedFlags, <bool>[true, true, true, false]);
  });

  test('missing canonical module is represented as unavailable and locked', () {
    final ordered = orderWorld1Modules(<Map<String, dynamic>>[
      {'id': 'world1_act0_table_literacy'},
      {'id': 'world1_act0_street_flow'},
    ]);

    final missingAct1 = ordered.firstWhere(
      (e) => e['id'] == 'world1_act0_action_literacy',
    );
    expect(missingAct1['isAvailable'], isFalse);

    final unlocked = applyLinearUnlockByPreviousCompletion(
      <Map<String, dynamic>>[
        {
          'id': 'world1_act0_table_literacy',
          'isCompleted': true,
          'isAvailable': true,
        },
        missingAct1,
        {
          'id': 'world1_act0_street_flow',
          'isCompleted': false,
          'isAvailable': true,
        },
      ],
    );
    expect(unlocked[1]['isUnlocked'], isFalse);
  });

  test(
    'world1 canonical entry pack picks earliest incomplete before fallback',
    () {
      final resolved = resolveWorld1CanonicalEntryPackIdV1(
        completedPackIds: <String>{
          'world1_act0_table_literacy',
          'world1_act0_action_literacy',
        },
        fallbackPackId: 'world2_spine_campaign_v1',
      );

      expect(resolved, 'world1_act0_street_flow');
    },
  );

  test(
    'early World 1 ordered modules use aligned learner-facing titles and descriptions',
    () {
      final ordered = orderWorld1Modules(<Map<String, dynamic>>[
        {
          'id': 'world1_act0_table_literacy',
          'title': 'Act 0: Table Literacy',
          'description': 'Fast seat anchors for your first clean table read.',
        },
        {
          'id': 'world1_act0_action_literacy',
          'title': 'Act 0: Action Literacy',
          'description': 'Fold, check, and call choices without shame.',
        },
        {
          'id': 'world1_act0_street_flow',
          'title': 'Act 0: Street Flow',
          'description': 'Learn the hand timeline from preflop to river.',
        },
      ]);

      expect(ordered[0]['title'], 'Table map');
      expect(
        ordered[0]['description'],
        'Lock Button, small blind, and big blind first.',
      );
      expect(ordered[1]['title'], 'First action choices');
      expect(
        ordered[1]['description'],
        'Raise, call, and fold from the right seat in order.',
      );
      expect(ordered[2]['title'], 'Street flow reads');
      expect(
        ordered[2]['description'],
        'Track flop, turn, and river without losing the table anchor.',
      );
    },
  );

  test(
    'recommended module titles stay aligned with early World 1 entry titles',
    () {
      expect(
        resolveWorld1FoundationsEntryMetadataV1(
          'world1_act0_table_literacy',
        )!.titleText,
        recommendedModuleTitleForId('world1_act0_table_literacy'),
      );
      expect(
        resolveWorld1FoundationsEntryMetadataV1(
          'world1_act0_action_literacy',
        )!.titleText,
        recommendedModuleTitleForId('world1_act0_action_literacy'),
      );
      expect(
        resolveWorld1FoundationsEntryMetadataV1(
          'world1_act0_street_flow',
        )!.titleText,
        recommendedModuleTitleForId('world1_act0_street_flow'),
      );
      expect(
        resolveWorld1FoundationsEntryMetadataV1(
          'world1_spine_campaign_v1',
        )!.titleText,
        recommendedModuleTitleForId('world1_spine_campaign_v1'),
      );
    },
  );
}
