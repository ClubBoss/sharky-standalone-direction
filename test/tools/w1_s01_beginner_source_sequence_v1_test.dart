import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('active W1.s01 parses and keeps beginner terms teach-before-test', () {
    final sessionPath = 'content/worlds/world1/v1/sessions/w1.s01/session.md';
    final chainPath =
        'content/worlds/world1/v1/sessions/w1.s01/drills/'
        'd.chain_world1_first_bridge_v1.json';
    final session = File(sessionPath).readAsStringSync();
    final chain =
        jsonDecode(File(chainPath).readAsStringSync()) as Map<String, dynamic>;

    final requiredTeaching = <String>[
      'Hero means you, and Villain means the opponent in the spot.',
      'The dealer button is the seat marked BTN/button.',
      'CO/cutoff is the seat just before BTN/button.',
      'SB/small blind and BB/big blind are the blind seats',
      'Preflop means before any board cards are dealt',
      'postflop means after board cards appear',
      'The board is the shared community-card area.',
      'The pot is the chips in the middle.',
      'Sizing means the size label on a bet button',
      'Range means the set of hands a player could reasonably have',
    ];
    for (final teaching in requiredTeaching) {
      expect(session, contains(teaching));
    }

    final steps = (chain['steps'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(steps, hasLength(4));
    expect(steps[0]['expected_action'], 'call');
    expect(steps[1]['expected_action'], 'fold');
    expect(steps[2]['expected_preset_id'], 'one_third_pot');
    expect(steps[3]['expected_preset_id'], 'half_pot');

    final firstTwoPrompts = '${steps[0]['prompt']} ${steps[1]['prompt']}';
    expect(firstTwoPrompts, contains('CO/cutoff opened'));
    expect(firstTwoPrompts, contains('Hero is on BTN/button'));
    expect(firstTwoPrompts, contains('BTN/button opened'));
    expect(firstTwoPrompts, contains('Hero is in SB/small blind'));
    expect(firstTwoPrompts, contains('BB/big blind is still behind'));

    final feedback = steps
        .expand(
          (step) => <Object?>[
            step['feedback_correct_v1'],
            step['feedback_incorrect_v1'],
            step['why_v1'],
          ],
        )
        .whereType<String>()
        .join(' ');
    expect(feedback, contains('clue'));
    expect(feedback, contains('Hero on BTN/button'));
    expect(feedback, contains('SB/small blind'));
    expect(feedback.toLowerCase(), isNot(contains('solver')));
    expect(feedback.toLowerCase(), isNot(contains('gto')));
  });

  test('active W1.s01 source rows parse without expected-answer drift', () {
    final expectedById = <String, String>{
      'choose_call': 'call',
      'choose_fold': 'fold',
      'choose_half_pot_value': 'half_pot',
      'choose_one_third_pot_keep_price': 'one_third_pot',
      'choose_pot_pressure': 'pot',
      'choose_min_raise_reopen': 'min_raise',
    };

    for (final entry in expectedById.entries) {
      final path =
          'content/worlds/world1/v1/sessions/w1.s01/drills/d.${entry.key}.json';
      final decoded =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      final expected = decoded['expected'] as Map<String, dynamic>;
      final actual =
          expected['actionId'] as String? ?? expected['presetId'] as String?;
      expect(actual, entry.value, reason: path);
    }
  });
}
