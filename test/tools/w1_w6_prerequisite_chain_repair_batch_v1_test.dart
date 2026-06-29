import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('pins repaired beginner prerequisite definitions across W1-W6', () {
    final w1BetSize = _fixtureText(
      'test/fixtures/content_factory_mvp/'
      'w1_bet_size_vocabulary_preview_migration_pr3_v1.json',
    );
    expect(w1BetSize, contains('The pot is the chips already in the middle.'));
    expect(
      w1BetSize,
      contains(
        'Half pot means betting half the chips currently in the middle.',
      ),
    );

    final w1StartingHand = _fixtureText(
      'test/fixtures/content_factory_mvp/'
      'w1_starting_hand_discipline_migration_batch1_v1.json',
    );
    expect(
      w1StartingHand,
      contains(
        'Calling from the big blind with a playable broadway is a defend',
      ),
    );

    final w3Position = _fixtureText(
      'test/fixtures/content_factory_mvp/w3_canonical_certification_pilot_v1.json',
    );
    expect(
      w3Position,
      contains('In position means acting after your opponent.'),
    );
    expect(
      w3Position,
      contains('Out of position means acting before your opponent.'),
    );

    final w4Purpose = _fixtureText(
      'test/fixtures/content_factory_mvp/'
      'w4_intent_action_discipline_canonical_pr2_v1.json',
    );
    expect(w4Purpose, contains('Equity means chance to win the hand.'));
    expect(
      w4Purpose,
      contains(
        'Protection means betting so drawing hands pay more to continue',
      ),
    );

    final w5Texture = _fixtureText(
      'test/fixtures/content_factory_mvp/'
      'w5_board_texture_classification_canonical_pilot_v1.json',
    );
    expect(
      w5Texture,
      contains(
        'A draw is an incomplete hand that can become strong if the right card comes.',
      ),
    );

    final w6Bucket = _fixtureText(
      'test/fixtures/content_factory_mvp/'
      'w6_range_bucket_by_board_fit_canonical_pilot_v1.json',
    );
    final w6Width = _fixtureText(
      'test/fixtures/content_factory_mvp/'
      'w6_range_width_awareness_canonical_pr2_v1.json',
    );
    expect(w6Bucket, contains(_rangeDefinition));
    expect(w6Width, contains(_rangeDefinition));
  });

  test('W5 basic outs repair stays narrow and count-only', () {
    final fixture = _fixture(
      'test/fixtures/content_factory_mvp/'
      'w5_basic_outs_awareness_canonical_prerequisite_repair_v1.json',
    );
    final tasks = (fixture['tasks']! as List).cast<Map<String, Object?>>();

    expect(tasks, hasLength(6));
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'basic_outs_awareness',
    });
    expect(tasks.map((task) => task['correct_action']).toSet(), {
      'nine_outs',
      'eight_outs',
      'four_outs',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'flush_draw_outs_v1',
      'open_ended_straight_draw_outs_v1',
      'gutshot_outs_v1',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'draw_count_before_action',
    });
    expect(
      tasks.every((task) => task['launch_coverage_claimed'] == false),
      true,
    );

    final lowerText = jsonEncode(fixture).toLowerCase();
    for (final forbidden in _forbiddenStrategyTerms) {
      expect(lowerText, isNot(contains(forbidden)));
    }
  });

  test('changed W4-W6 prerequisite copy avoids forbidden strategy terms', () {
    final changedCopy = [
      _feedbackText(
        'test/fixtures/content_factory_mvp/'
        'w4_intent_action_discipline_canonical_pr2_v1.json',
      ),
      _feedbackText(
        'test/fixtures/content_factory_mvp/'
        'w5_board_texture_classification_canonical_pilot_v1.json',
      ),
      _feedbackText(
        'test/fixtures/content_factory_mvp/'
        'w5_basic_outs_awareness_canonical_prerequisite_repair_v1.json',
      ),
      _feedbackText(
        'test/fixtures/content_factory_mvp/'
        'w6_range_bucket_by_board_fit_canonical_pilot_v1.json',
      ),
      _feedbackText(
        'test/fixtures/content_factory_mvp/'
        'w6_range_width_awareness_canonical_pr2_v1.json',
      ),
      _sourceText('content/worlds/world5/v1/sessions/w5.s11/session.md'),
      _sourceText('content/worlds/world5/v1/sessions/w5.s11/notes.md'),
      _sourceText(
        'content/worlds/world5/v1/sessions/w5.s11/drills/'
        'd.count_flush_draw_nine_outs_v1.json',
      ),
      _sourceText(
        'content/worlds/world5/v1/sessions/w5.s11/drills/'
        'd.count_open_ended_straight_draw_eight_outs_v1.json',
      ),
      _sourceText(
        'content/worlds/world5/v1/sessions/w5.s11/drills/'
        'd.count_gutshot_four_outs_v1.json',
      ),
    ].join('\n').toLowerCase();

    for (final forbidden in _forbiddenStrategyTerms) {
      expect(changedCopy, isNot(contains(forbidden)));
    }
  });
}

const String _rangeDefinition =
    'A range is the set of hands an opponent could have here, not one exact hand.';

const List<String> _forbiddenStrategyTerms = [
  'solver',
  'gto',
  'frequency',
  'frequencies',
  'combo',
  'combos',
  'blocker',
  'blockers',
  'polarization',
  'fold equity',
  'semi-bluff',
  'implied odds',
];

Map<String, Object?> _fixture(String path) {
  return (jsonDecode(File(path).readAsStringSync()) as Map)
      .cast<String, Object?>();
}

String _fixtureText(String path) => File(path).readAsStringSync();

String _sourceText(String path) => File(path).readAsStringSync();

String _feedbackText(String path) {
  final tasks = (_fixture(path)['tasks']! as List).cast<Map<String, Object?>>();
  return tasks.map((task) => task['feedback_reason']).join('\n');
}
