import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:test/test.dart';

void main() {
  const evaluator = DrillEvaluatorV1();

  test('seat_tap match and mismatch are deterministic', () {
    final spec = DrillSpecV1.fromJsonString(
      '{"id":"find_sb","kind":"seat_tap","prompt":"Tap SB","expected":{"role":"sb"},"error_class":"seat_role_confusion"}',
    );

    final pass = evaluator.evaluate(
      spec,
      DrillUserEventV1.seatTap(seatId: 'S1', role: 'sb'),
    );
    final fail = evaluator.evaluate(
      spec,
      DrillUserEventV1.seatTap(seatId: 'S2', role: 'bb'),
    );

    expect(pass.isPass, isTrue);
    expect(pass.errorClass, isNull);
    expect(fail.isPass, isFalse);
    expect(fail.errorClass, 'seat_role_confusion');
  });

  test('action_choice match and mismatch are deterministic', () {
    final spec = DrillSpecV1.fromJsonString(
      '{"id":"choose_fold","kind":"action_choice","prompt":"Choose fold","expected":{"actionId":"fold"},"error_class":"action_selection"}',
    );

    final pass = evaluator.evaluate(
      spec,
      DrillUserEventV1.actionChoice('fold'),
    );
    final fail = evaluator.evaluate(
      spec,
      DrillUserEventV1.actionChoice('call'),
    );

    expect(pass.isPass, isTrue);
    expect(fail.isPass, isFalse);
    expect(fail.errorClass, 'action_selection');
  });

  test(
    'action_choice parsing preserves feedback_acceptable_v1 while acceptable_actions still soft-pass',
    () {
      final spec = DrillSpecV1.fromJsonString(
        '{"id":"choose_call_price_ok","kind":"action_choice","prompt":"Choose response","expected":{"actionId":"call"},"acceptable_actions":["fold"],"error_class":"tocall_legality_mismatch","feedback_acceptable_v1":"Acceptable. Folding avoids a bigger mistake, but calling keeps more value in play."}',
      );

      final pass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('call'),
      );
      final softPass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('fold'),
      );
      final fail = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('raise'),
      );

      expect(
        spec.feedbackAcceptableV1,
        'Acceptable. Folding avoids a bigger mistake, but calling keeps more value in play.',
      );
      expect(
        spec.scenarioCoreV1.feedbackAcceptableV1,
        'Acceptable. Folding avoids a bigger mistake, but calling keeps more value in play.',
      );
      expect(pass.isPass, isTrue);
      expect(pass.isSoftPass, isFalse);
      expect(softPass.isPass, isTrue);
      expect(softPass.isSoftPass, isTrue);
      expect(fail.isPass, isFalse);
      expect(fail.errorClass, 'tocall_legality_mismatch');
    },
  );

  test(
    'action_choice parsing preserves feedback_incorrect_by_action_v1 while wrong actions still hard-fail',
    () {
      final spec = DrillSpecV1.fromJsonString(
        '{"id":"choose_call_showdown","kind":"action_choice","prompt":"Choose response","expected":{"actionId":"call"},"error_class":"value_bluff_confusion","feedback_incorrect_by_action_v1":{"fold":"Incorrect. Folding gives up showdown value too cheaply.","raise":"Incorrect. Raising turns showdown value into a thin bluff."},"feedback_incorrect_v1":"Incorrect. Generic fallback."}',
      );

      final foldFail = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('fold'),
      );
      final raiseFail = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('raise'),
      );

      expect(
        spec.feedbackIncorrectByActionV1,
        const <String, String>{
          'fold': 'Incorrect. Folding gives up showdown value too cheaply.',
          'raise': 'Incorrect. Raising turns showdown value into a thin bluff.',
        },
      );
      expect(
        spec.scenarioCoreV1.feedbackIncorrectByActionV1,
        const <String, String>{
          'fold': 'Incorrect. Folding gives up showdown value too cheaply.',
          'raise': 'Incorrect. Raising turns showdown value into a thin bluff.',
        },
      );
      expect(foldFail.isPass, isFalse);
      expect(raiseFail.isPass, isFalse);
      expect(foldFail.isSoftPass, isFalse);
      expect(raiseFail.isSoftPass, isFalse);
      expect(foldFail.errorClass, 'value_bluff_confusion');
      expect(raiseFail.errorClass, 'value_bluff_confusion');
    },
  );

  test('board_tap match and mismatch are deterministic', () {
    final spec = DrillSpecV1.fromJsonString(
      '{"id":"tap_flop_left","kind":"board_tap","prompt":"Tap left flop","expected":{"boardSlot":"flop_left"},"error_class":"board_slot_confusion"}',
    );

    final pass = evaluator.evaluate(
      spec,
      DrillUserEventV1.boardTap('flop_left'),
    );
    final fail = evaluator.evaluate(spec, DrillUserEventV1.boardTap('turn'));

    expect(pass.isPass, isTrue);
    expect(fail.isPass, isFalse);
    expect(fail.errorClass, 'board_slot_confusion');
  });

  test('hole_cards_tap match and mismatch are deterministic', () {
    final spec = DrillSpecV1.fromJsonString(
      '{"id":"tap_hole_left","kind":"hole_cards_tap","prompt":"Tap left hole card","expected":{"cardSlot":"p0"},"error_class":"hole_card_slot_confusion"}',
    );

    final pass = evaluator.evaluate(
      spec,
      DrillUserEventV1.holeCardsTap(cardSlot: 'p0'),
    );
    final fail = evaluator.evaluate(
      spec,
      DrillUserEventV1.holeCardsTap(cardSlot: 'p1'),
    );

    expect(pass.isPass, isTrue);
    expect(fail.isPass, isFalse);
    expect(fail.errorClass, 'hole_card_slot_confusion');
  });

  test('hole_cards_tap supports optional cardId deterministically', () {
    final slotOnly = DrillSpecV1.fromJsonString(
      '{"id":"tap_hole_left","kind":"hole_cards_tap","prompt":"Tap left hole card","expected":{"cardSlot":"p0"},"error_class":"hole_card_slot_confusion"}',
    );
    final withCardId = DrillSpecV1.fromJsonString(
      '{"id":"tap_ace_spades","kind":"hole_cards_tap","prompt":"Tap As","expected":{"cardSlot":"p0","cardId":"As"},"error_class":"hole_card_identity_confusion"}',
    );

    expect(
      evaluator
          .evaluate(slotOnly, DrillUserEventV1.holeCardsTap(cardSlot: 'p0'))
          .isPass,
      isTrue,
    );
    expect(
      evaluator
          .evaluate(withCardId, DrillUserEventV1.holeCardsTap(cardSlot: 'p0'))
          .isPass,
      isFalse,
    );
    expect(
      evaluator
          .evaluate(
            withCardId,
            DrillUserEventV1.holeCardsTap(cardSlot: 'p0', cardId: 'As'),
          )
          .isPass,
      isTrue,
    );
    expect(
      evaluator
          .evaluate(
            withCardId,
            DrillUserEventV1.holeCardsTap(cardSlot: 'p0', cardId: 'Ks'),
          )
          .isPass,
      isFalse,
    );
  });

  test('drill json parsing validates required fields deterministically', () {
    final ok = DrillSpecV1.fromJsonString(
      '{"id":"a","kind":"action_choice","prompt":"p","expected":{"actionId":"fold"},"error_class":"e"}',
    );
    expect(ok.id, 'a');
    expect(ok.kind, DrillKindV1.actionChoice);

    expect(
      () => DrillSpecV1.fromJsonString(
        '{"id":"a","kind":"unknown_kind","prompt":"p","expected":{"actionId":"fold"},"error_class":"e"}',
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => DrillSpecV1.fromJsonString(
        '{"id":"a","kind":"action_choice","prompt":"p","expected":{},"error_class":"e"}',
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => DrillSpecV1.fromJsonString(
        '{"id":"a","kind":"hole_cards_tap","prompt":"p","expected":{},"error_class":"e"}',
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => DrillSpecV1.fromJsonString(
        '{"id":"a","kind":"hole_cards_tap","prompt":"p","expected":{"cardSlot":"p0","cardId":"ACE_SPADES"},"error_class":"e"}',
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          'expected.cardId must match card id format [AKQJT98765432][shdc]',
        ),
      ),
    );
  });

  test('action matching is normalized while board matching remains case-sensitive', () {
    final actionSpec = DrillSpecV1.fromJsonString(
      '{"id":"choose_fold","kind":"action_choice","prompt":"Choose fold","expected":{"actionId":"fold"},"error_class":"action_selection"}',
    );
    final boardSpec = DrillSpecV1.fromJsonString(
      '{"id":"tap_flop_left","kind":"board_tap","prompt":"Tap left flop","expected":{"boardSlot":"flop_left"},"error_class":"board_slot_confusion"}',
    );

    expect(
      evaluator
          .evaluate(actionSpec, DrillUserEventV1.actionChoice('FOLD'))
          .isPass,
      isTrue,
    );
    expect(
      evaluator
          .evaluate(boardSpec, DrillUserEventV1.boardTap('FLOP_LEFT'))
          .isPass,
      isFalse,
    );
  });

  test(
    'bet_sizing_choice_v1 parsing/evaluation supports expected and soft-pass presets',
    () {
      final spec = DrillSpecV1.fromJsonString(
        '{"id":"size_flop","kind":"bet_sizing_choice_v1","prompt":"Choose size","expected":{"presetId":"half_pot"},"acceptable_preset_ids":["min_raise","pot"],"error_class":"sizing_selection"}',
      );

      final pass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('half_pot'),
      );
      final softPass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('pot'),
      );
      final fail = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('one_third_pot'),
      );

      expect(spec.kind, DrillKindV1.betSizingChoice);
      expect(pass.isPass, isTrue);
      expect(pass.isSoftPass, isFalse);
      expect(softPass.isPass, isTrue);
      expect(softPass.isSoftPass, isTrue);
      expect(fail.isPass, isFalse);
      expect(fail.errorClass, 'sizing_selection');
    },
  );

  test('acceptable_preset_ids are deterministically deduped and sorted', () {
    final spec = DrillSpecV1.fromJsonString(
      '{"id":"size_turn","kind":"bet_sizing_choice_v1","prompt":"Choose size","expected":{"presetId":"pot"},"acceptable_preset_ids":["pot","half_pot","pot","min_raise"],"error_class":"sizing_selection"}',
    );
    expect(
      spec.acceptablePresetIds,
      equals(<String>['half_pot', 'min_raise', 'pot']),
    );
  });

  test(
    'board_texture_classifier_v1 parsing/evaluation supports expected and soft-pass actions',
    () {
      final spec = DrillSpecV1.fromJsonString(
        '{"id":"texture_flop","kind":"board_texture_classifier_v1","prompt":"Classify and act.","board_texture_v1":"wet","expected_action":"raise","acceptable_actions":["call"],"error_class":"expected_action_mismatch"}',
      );

      final pass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('raise'),
      );
      final softPass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('call'),
      );
      final fail = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('fold'),
      );

      expect(spec.kind, DrillKindV1.boardTextureClassifier);
      expect(spec.boardTextureV1, 'wet');
      expect(spec.expectedActionV1, 'raise');
      expect(spec.acceptableActions, equals(<String>['call']));
      expect(pass.isPass, isTrue);
      expect(pass.isSoftPass, isFalse);
      expect(softPass.isPass, isTrue);
      expect(softPass.isSoftPass, isTrue);
      expect(fail.isPass, isFalse);
      expect(fail.errorClass, 'expected_action_mismatch');
    },
  );

  test(
    'range_bucket_classifier_v1 parsing/evaluation supports expected and soft-pass actions',
    () {
      final spec = DrillSpecV1.fromJsonString(
        '{"id":"range_flop","kind":"range_bucket_classifier_v1","prompt":"Bucket and act.","range_bucket_v1":"draw","expected_action":"raise","acceptable_actions":["call"],"error_class":"expected_action_mismatch"}',
      );

      final pass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('raise'),
      );
      final softPass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('call'),
      );
      final fail = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('fold'),
      );

      expect(spec.kind, DrillKindV1.rangeBucketClassifier);
      expect(spec.rangeBucketV1, 'draw');
      expect(spec.expectedActionV1, 'raise');
      expect(spec.acceptableActions, equals(<String>['call']));
      expect(pass.isPass, isTrue);
      expect(pass.isSoftPass, isFalse);
      expect(softPass.isPass, isTrue);
      expect(softPass.isSoftPass, isTrue);
      expect(fail.isPass, isFalse);
      expect(fail.errorClass, 'expected_action_mismatch');
    },
  );

  test(
    'hand_chain_v1 parsing/evaluation supports deterministic 2-step action flow',
    () {
      final spec = DrillSpecV1.fromJsonString(
        '{"id":"chain_a","kind":"hand_chain_v1","chain_id":"chain_demo","prompt":"Play 2-step chain.","expected":{},"error_class":"unused","steps":[{"street":"preflop","prompt":"Step 1 choose call.","expected_action":"call","acceptable_actions":["fold"],"why_v1":"Call keeps weaker hands in.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"},{"street":"flop","prompt":"Step 2 choose raise.","expected_action":"raise","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch"}]}',
      );

      final step0Pass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('call', chainStepIndex: 0),
      );
      final step0Soft = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('fold', chainStepIndex: 0),
      );
      final step0Fail = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('raise', chainStepIndex: 0),
      );
      final step1Pass = evaluator.evaluate(
        spec,
        DrillUserEventV1.actionChoice('raise', chainStepIndex: 1),
      );

      expect(spec.kind, DrillKindV1.handChain);
      expect(spec.chainIdV1, 'chain_demo');
      expect(spec.chainStepsV1?.length, 2);
      expect(step0Pass.isPass, isTrue);
      expect(step0Pass.isSoftPass, isFalse);
      expect(step0Soft.isPass, isTrue);
      expect(step0Soft.isSoftPass, isTrue);
      expect(step0Fail.isPass, isFalse);
      expect(step0Fail.errorClass, 'expected_action_mismatch');
      expect(step1Pass.isPass, isTrue);
    },
  );

  test('parseDrillIdsFromIndexV1 preserves listed order deterministically', () {
    const index = '''
# Drills
- z_last: board_tap TODO
- a_first: seat_tap TODO
- m_mid: action_choice TODO
''';
    expect(
      parseDrillIdsFromIndexV1(index),
      equals(<String>['z_last', 'a_first', 'm_mid']),
    );
  });

  test('hasListedDrillsInIndexV1 returns false for empty drill index', () {
    expect(hasListedDrillsInIndexV1('# Drills\n'), isFalse);
    expect(hasListedDrillsInIndexV1('# Drills\n- one: x\n'), isTrue);
  });
}
