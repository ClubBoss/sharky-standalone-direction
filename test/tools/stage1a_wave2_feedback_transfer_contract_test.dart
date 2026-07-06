import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

String? _expectedAction(Map<String, dynamic> drill) {
  final expected = drill['expected'];
  if (expected is Map<String, dynamic>) {
    final action = expected['actionId'];
    if (action is String) return action;
  }
  final expectedAction = drill['expected_action'];
  return expectedAction is String ? expectedAction : null;
}

Iterable<File> _drillFiles(String world) {
  return Directory('content/worlds/$world/v1/sessions')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'));
}

void main() {
  test(
    'W2 true alternate-action drills all have authored acceptable feedback',
    () {
      final alternateDrills = <String>[];
      final expectedOnlyDrills = <String>[];
      final missingFeedback = <String>[];

      for (final file in _drillFiles('world2')) {
        final drill = _json(file);
        final acceptable = drill['acceptable_actions'];
        if (acceptable is! List) continue;

        final expected = _expectedAction(drill);
        final alternates = acceptable.whereType<String>().where(
          (action) => action != expected,
        );
        if (alternates.isEmpty) {
          expectedOnlyDrills.add(file.path);
          continue;
        }

        alternateDrills.add(file.path);
        final feedback = drill['feedback_acceptable_v1'];
        if (feedback is! String || feedback.trim().isEmpty) {
          missingFeedback.add(file.path);
        }
      }

      expect(alternateDrills, hasLength(14));
      expect(expectedOnlyDrills, hasLength(25));
      expect(missingFeedback, isEmpty);
    },
  );

  test('selected W1 action-choice family no longer uses bare Correct.', () {
    final actionChoices = <String>[];
    final genericCorrect = <String>[];

    for (final file in _drillFiles('world1')) {
      final drill = _json(file);
      if (drill['kind'] != 'action_choice' ||
          !drill.containsKey('feedback_correct_v1')) {
        continue;
      }
      actionChoices.add(file.path);
      if (drill['feedback_correct_v1'] == 'Correct.') {
        genericCorrect.add(file.path);
      }
    }

    expect(actionChoices, hasLength(27));
    expect(genericCorrect, isEmpty);
  });

  test('targeted W1 feedback corrections avoid premature first-in wording', () {
    const targetedIds = <String>{
      'choose_button_open_repeat_stability_v1',
      'choose_cutoff_raise_clean_start_v1',
      'choose_small_blind_raise_oop_clean_start_v1',
    };
    final seen = <String>{};

    for (final file in _drillFiles('world1')) {
      final drill = _json(file);
      final id = drill['id'];
      if (id is! String || !targetedIds.contains(id)) continue;
      seen.add(id);
      final joined = jsonEncode(drill).toLowerCase();
      expect(joined, isNot(contains('first-in')));
      expect(joined, isNot(contains('first in')));
    }

    expect(seen, targetedIds);
  });

  test('W2 flop denial acceptable feedback avoids advanced equity jargon', () {
    final drill = _json(
      File(
        'content/worlds/world2/v1/sessions/w2.s04/drills/d.choose_raise_flop_denial.json',
      ),
    );
    final joined = jsonEncode(drill).toLowerCase();

    expect(joined, isNot(contains('equity')));
    expect(drill['feedback_acceptable_v1'], contains('Acceptable.'));
    expect(
      drill['feedback_acceptable_v1'],
      contains('keeps weaker overcards from catching up for free'),
    );
    expect(_expectedAction(drill), 'raise');
    expect(drill['acceptable_actions'], contains('call'));
  });

  test(
    'W3 has exactly three new standalone independent transfer decisions',
    () {
      final actionChoices = <String, Map<String, dynamic>>{};
      var acceptableActionCount = 0;

      for (final file in _drillFiles('world3')) {
        final drill = _json(file);
        if (drill['kind'] == 'action_choice') {
          actionChoices[drill['id'] as String] = drill;
          if (drill.containsKey('acceptable_actions')) acceptableActionCount++;
        }
      }

      expect(actionChoices, hasLength(7));
      expect(acceptableActionCount, 0);

      const expectedNewIds = <String>{
        'choose_raise_btn_clean_transfer_v1',
        'choose_call_btn_facing_open_transfer_v1',
        'choose_fold_bb_weak_facing_open_transfer_v1',
      };
      expect(actionChoices.keys.toSet(), containsAll(expectedNewIds));

      for (final id in expectedNewIds) {
        final drill = actionChoices[id]!;
        expect(drill['prompt'], isA<String>());
        expect((drill['prompt'] as String).trim(), isNotEmpty);
        expect(drill['available_actions_v1'], ['fold', 'call', 'raise']);
        expect(_expectedAction(drill), isIn(<String>{'fold', 'call', 'raise'}));
        expect(drill['feedback_correct_v1'], isA<String>());
        expect(
          (drill['feedback_correct_v1'] as String),
          allOf(contains('Correct.'), isNot(equals('Correct.'))),
        );
        expect(drill['feedback_incorrect_v1'], isA<String>());
        expect(
          (drill['feedback_incorrect_v1'] as String),
          contains('Incorrect.'),
        );
        expect(drill['why_v1'], isA<String>());
        expect((drill['why_v1'] as String).trim(), isNotEmpty);
      }
    },
  );

  test('two W3 transfer drills differ from nearest chain-step surfaces', () {
    final transferRaise = _json(
      File(
        'content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_raise_btn_clean_transfer_v1.json',
      ),
    );
    final transferCall = _json(
      File(
        'content/worlds/world3/v1/sessions/w3.s10/drills/d.choose_call_btn_facing_open_transfer_v1.json',
      ),
    );
    final chain = _json(
      File(
        'content/worlds/world3/v1/sessions/w3.s10/drills/d.chain_preflop_final_checkpoint_v1.json',
      ),
    );
    final steps = (chain['steps'] as List).cast<Map<String, dynamic>>();
    final raiseStep = steps[0];
    final callStep = steps[1];

    expect(_expectedAction(transferRaise), raiseStep['expected_action']);
    expect(_expectedAction(transferCall), callStep['expected_action']);
    expect(transferRaise['prompt'], contains('AJs'));
    expect(transferRaise['prompt'], isNot(contains('KQs')));
    expect(raiseStep['prompt'], contains('KQs'));
    expect(transferCall['prompt'], contains('KQs'));
    expect(transferCall['prompt'], isNot(contains('QJs')));
    expect(callStep['prompt'], contains('QJs'));
    expect(transferRaise.containsKey('acceptable_actions'), isFalse);
    expect(transferCall.containsKey('acceptable_actions'), isFalse);
  });
}
