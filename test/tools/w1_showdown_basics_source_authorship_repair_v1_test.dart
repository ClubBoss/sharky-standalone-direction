import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  const fixturePath =
      'test/fixtures/content_factory_mvp/'
      'w1_showdown_basics_source_authorship_repair_v1.json';

  test('W1 showdown authorship stays outside the runtime session index', () {
    final sessionIndex = File(
      'content/worlds/world1/v1/sessions/index.md',
    ).readAsStringSync();
    expect(sessionIndex, isNot(contains('w1.s11')));
    expect(
      Directory(
        'content/worlds/world1/v1/source_repairs/showdown_basics_v1',
      ).existsSync(),
      true,
    );
  });

  test('W1 showdown basics fixture covers the bounded beginner contract', () {
    final file = File(fixturePath);
    expect(
      file.existsSync(),
      true,
      reason: 'showdown fixture must be generated',
    );

    final fixture = (jsonDecode(file.readAsStringSync()) as Map)
        .cast<String, Object?>();
    final tasks = (fixture['tasks']! as List).cast<Map<String, Object?>>();

    expect(tasks, hasLength(6));
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'showdown_basics',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w1.showdown_basics.best_five_comparison',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'best_five_before_showdown_winner',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'hand_rank_order_v1',
      'best_five_selection_v1',
      'showdown_winner_v1',
      'kicker_tiebreak_v1',
      'board_plays_tie_v1',
    });
    expect(tasks.every((task) => task['route_world_id'] == 'world_1'), true);
    expect(
      tasks.every((task) => task['content_owner_world_id'] == 'world_1'),
      true,
    );
    expect(
      tasks.every((task) => task['launch_coverage_claimed'] == false),
      true,
    );
  });

  test('W1 showdown source owns all four required beginner concepts', () {
    const sourceDir =
        'content/worlds/world1/v1/source_repairs/showdown_basics_v1';
    final sourceCopy = <String>[
      File('$sourceDir/source.md').readAsStringSync(),
      for (final file
          in Directory('$sourceDir/drills').listSync().whereType<File>().where(
            (file) => file.path.endsWith('.json'),
          ))
        file.readAsStringSync(),
    ].join('\n').toLowerCase();

    expect(sourceCopy, contains('straight'));
    expect(sourceCopy, contains('flush'));
    expect(sourceCopy, contains('best five'));
    expect(sourceCopy, contains('showdown'));
    expect(sourceCopy, contains('kicker'));
    expect(sourceCopy, contains('tie'));
  });

  test('W1 showdown copy excludes advanced and cross-world scope', () {
    final fixtureCopy = File(fixturePath).readAsStringSync().toLowerCase();
    const forbidden = [
      'solver',
      'gto',
      'range',
      'equity',
      'pot odds',
      'tournament',
      'stack depth',
      'icm',
      'exploit',
    ];

    for (final term in forbidden) {
      expect(fixtureCopy, isNot(contains(term)));
    }
  });
}
