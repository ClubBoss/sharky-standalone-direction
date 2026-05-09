import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/content_integrity_validator_v2.dart';

void main() {
  test('v2 report is deterministic and layers mode-specific issues on top of v1', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'content_integrity_validator_v2_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeManifestV2(tempRoot);
    _writeFileV2(
      tempRoot,
      'content/worlds/world1/v1/sessions/w1.s01/drills/d.valid_seat.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_seat',
        'kind': 'seat_tap',
        'prompt': 'Tap the btn seat.',
        'expected': <String, Object?>{'role': 'btn'},
        'error_class': 'seat_role_confusion',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world1/v1/sessions/w1.s02/drills/d.invalid_seat.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_seat',
        'kind': 'seat_tap',
        'prompt': 'Tap the btn seat.',
        'expected': <String, Object?>{'role': 'sb'},
        'error_class': 'seat_role_confusion',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world1/v1/sessions/w1.s03/drills/d.invalid_hole.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_hole',
        'kind': 'hole_cards_tap',
        'prompt': 'Tap your left hole card.',
        'expected': <String, Object?>{'cardSlot': 'p1'},
        'error_class': 'hole_card_slot_confusion',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world2/v1/sessions/w2.s04/drills/d.invalid_texture.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_texture',
        'kind': 'board_texture_classifier_v1',
        'prompt': 'Choose the calmer board.',
        'board_texture_v1': 'dry',
        'board_texture_policy_shape_v1': 'pressure_level',
        'board_texture_policy_target_v1': 'calmer',
        'expected_action': 'raise',
        'error_class': 'expected_action_mismatch',
        'feedback_correct_v1': 'Correct.',
        'feedback_incorrect_v1': 'Incorrect.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s01/drills/d.valid_action.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_action',
        'kind': 'action_choice',
        'prompt': 'Choose raise.',
        'available_actions_v1': <String>['fold', 'call', 'raise'],
        'expected': <String, Object?>{'actionId': 'raise'},
        'error_class': 'expected_action_mismatch',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s02/drills/d.invalid_action_prompt.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_action_prompt',
        'kind': 'action_choice',
        'prompt': 'Choose call.',
        'available_actions_v1': <String>['fold', 'call', 'raise'],
        'expected': <String, Object?>{'actionId': 'raise'},
        'error_class': 'expected_action_mismatch',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world3/v1/sessions/w3.s03/drills/d.invalid_action_options.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_action_options',
        'kind': 'action_choice',
        'prompt': 'Choose raise.',
        'available_actions_v1': <String>['fold', 'jam'],
        'expected': <String, Object?>{'actionId': 'raise'},
        'error_class': 'expected_action_mismatch',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world4/v1/sessions/w4.s01/drills/d.valid_showdown.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_showdown',
        'kind': 'showdown_winner_choice_v1',
        'prompt': 'Showdown check: Hero has top pair. Who wins?',
        'street_v1': 'river',
        'hero_hole_cards_v1': <String>['Ah', 'Qd'],
        'villain_hole_cards_v1': <String>['7c', '7s'],
        'board_cards_v1': <String>['Ad', 'Kc', '9h', '4s', '2d'],
        'available_actions_v1': <String>['hero', 'villain', 'board_plays'],
        'expected': <String, Object?>{'actionId': 'hero'},
        'error_class': 'showdown_winner_choice_mismatch',
        'feedback_correct_v1': 'Correct. Hero wins with the stronger pair.',
        'feedback_incorrect_v1': 'Incorrect. Top pair beats an underpair here.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world4/v1/sessions/w4.s02/drills/d.invalid_showdown_payload.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_showdown_payload',
        'kind': 'showdown_winner_choice_v1',
        'prompt': 'Showdown check: Villain wins. Who wins?',
        'street_v1': 'turn',
        'hero_hole_cards_v1': <String>['Ah', 'Qd'],
        'available_actions_v1': <String>['hero', 'villain', 'board_plays'],
        'expected': <String, Object?>{'actionId': 'villain'},
        'error_class': 'showdown_winner_choice_mismatch',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world4/v1/sessions/w4.s03/drills/d.invalid_showdown_copy.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_showdown_copy',
        'kind': 'showdown_winner_choice_v1',
        'prompt': 'Showdown check: Hero wins with the stronger pair. Who wins?',
        'street_v1': 'river',
        'hero_hole_cards_v1': <String>['Ah', 'Qd'],
        'villain_hole_cards_v1': <String>['7c', '7s'],
        'board_cards_v1': <String>['Ad', 'Kc', '9h', '4s', '2d'],
        'available_actions_v1': <String>['hero', 'villain', 'board_plays'],
        'expected': <String, Object?>{'actionId': 'villain'},
        'error_class': 'showdown_winner_choice_mismatch',
        'feedback_correct_v1': 'Correct. Hero wins with the stronger pair.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world5/v1/sessions/w5.s01/drills/d.valid_bet_sizing.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_bet_sizing',
        'kind': 'bet_sizing_choice_v1',
        'prompt': 'Pick the smaller size that still keeps the price easy.',
        'expected': <String, Object?>{'presetId': 'one_third_pot'},
        'acceptable_preset_ids': <String>['half_pot'],
        'error_class': 'bet_sizing_selection',
        'why_v1': 'One third pot keeps the continue lighter than half pot.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world5/v1/sessions/w5.s02/drills/d.invalid_bet_sizing_prompt.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_bet_sizing_prompt',
        'kind': 'bet_sizing_choice_v1',
        'prompt':
            'Pick the smallest legal raise that reopens the action cleanly.',
        'expected': <String, Object?>{'presetId': 'half_pot'},
        'acceptable_preset_ids': <String>['one_third_pot'],
        'error_class': 'bet_sizing_selection',
        'why_v1': 'Min raise would keep the line controlled.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world5/v1/sessions/w5.s03/drills/d.invalid_bet_sizing_acceptable.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_bet_sizing_acceptable',
        'kind': 'bet_sizing_choice_v1',
        'prompt': 'Pick one third pot when a lighter price still works.',
        'expected': <String, Object?>{'presetId': 'one_third_pot'},
        'acceptable_preset_ids': <String>['one_third_pot'],
        'error_class': 'bet_sizing_selection',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world6/v1/sessions/w6.s01/drills/d.valid_classifier_texture.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_classifier_texture',
        'kind': 'board_texture_classifier_v1',
        'prompt': 'This texture is dry. Choose the best action.',
        'board_texture_v1': 'dry',
        'expected_action': 'raise',
        'error_class': 'expected_action_mismatch',
        'feedback_correct_v1':
            'Correct. Dry texture keeps the value edge clean.',
        'feedback_incorrect_v1': 'Incorrect. Start from the dry texture first.',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world6/v1/sessions/w6.s02/drills/d.invalid_classifier_texture.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_classifier_texture',
        'kind': 'board_texture_classifier_v1',
        'prompt': 'This texture is wet. Choose the best action.',
        'board_texture_v1': 'dry',
        'expected_action': 'call',
        'error_class': 'expected_action_mismatch',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world6/v1/sessions/w6.s03/drills/d.valid_classifier_bucket.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_classifier_bucket',
        'kind': 'range_bucket_classifier_v1',
        'prompt': 'Range bucket is strong in position. Choose action.',
        'range_bucket_v1': 'strong',
        'expected_action': 'raise',
        'error_class': 'expected_action_mismatch',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world6/v1/sessions/w6.s04/drills/d.invalid_classifier_bucket.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_classifier_bucket',
        'kind': 'range_bucket_classifier_v1',
        'prompt': 'Range bucket is missed. Choose action.',
        'range_bucket_v1': 'draw',
        'expected_action': 'fold',
        'error_class': 'expected_action_mismatch',
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world7/v1/sessions/w7.s01/drills/d.valid_chain.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_chain',
        'kind': 'hand_chain_v1',
        'chain_id': 'w7_valid_chain_v1',
        'prompt': 'Play this two-step anchor chain.',
        'expected': <String, Object?>{},
        'error_class': 'unused',
        'steps': <Object?>[
          <String, Object?>{
            'street': 'preflop',
            'prompt': 'Step 1: Choose the clean unopened action.',
            'expected_action': 'raise',
            'feedback_correct_v1': 'Correct.',
            'feedback_incorrect_v1': 'Incorrect.',
            'error_class': 'expected_action_mismatch',
          },
          <String, Object?>{
            'street': 'flop',
            'prompt': 'Flop: Choose the cleaner continue.',
            'expected_action': 'call',
            'feedback_correct_v1': 'Correct.',
            'feedback_incorrect_v1': 'Incorrect.',
            'error_class': 'expected_action_mismatch',
          },
        ],
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world7/v1/sessions/w7.s02/drills/d.invalid_chain_count.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_chain_count',
        'kind': 'hand_chain_v1',
        'chain_id': 'w7_invalid_chain_count_v1',
        'prompt': 'Play this three-step anchor chain.',
        'expected': <String, Object?>{},
        'error_class': 'unused',
        'steps': <Object?>[
          <String, Object?>{
            'street': 'preflop',
            'prompt': 'Step 1: Choose the clean unopened action.',
            'expected_action': 'raise',
            'feedback_correct_v1': 'Correct.',
            'feedback_incorrect_v1': 'Incorrect.',
            'error_class': 'expected_action_mismatch',
          },
          <String, Object?>{
            'street': 'flop',
            'prompt': 'Step 2: Keep the same frame and continue.',
            'expected_action': 'call',
            'feedback_correct_v1': 'Correct.',
            'feedback_incorrect_v1': 'Incorrect.',
            'error_class': 'expected_action_mismatch',
          },
        ],
      }),
    );
    _writeFileV2(
      tempRoot,
      'content/worlds/world7/v1/sessions/w7.s03/drills/d.invalid_chain_step_prompt.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_chain_step_prompt',
        'kind': 'hand_chain_v1',
        'chain_id': 'w7_invalid_chain_step_prompt_v1',
        'prompt': 'Play this two-step anchor chain.',
        'expected': <String, Object?>{},
        'error_class': 'unused',
        'steps': <Object?>[
          <String, Object?>{
            'street': 'preflop',
            'prompt': 'Step 2: Choose the clean unopened action.',
            'expected_action': 'raise',
            'feedback_correct_v1': 'Correct.',
            'feedback_incorrect_v1': 'Incorrect.',
            'error_class': 'expected_action_mismatch',
          },
          <String, Object?>{
            'street': 'turn',
            'prompt': 'Flop: Continue with the same line.',
            'expected_action': 'call',
            'feedback_correct_v1': 'Correct.',
            'feedback_incorrect_v1': 'Incorrect.',
            'error_class': 'expected_action_mismatch',
          },
        ],
      }),
    );

    final first = buildContentIntegrityReportV2(rootPath: tempRoot.path);
    final second = buildContentIntegrityReportV2(rootPath: tempRoot.path);

    expect(first.filesChecked, 21);
    expect(
      renderContentIntegrityReportV2(second),
      equals(renderContentIntegrityReportV2(first)),
    );
    expect(
      first.issues.map((item) => item.reason),
      containsAll(<String>[
        'missing_drill_file',
        'seat_tap_prompt_role_mismatch_v2',
        'hole_cards_tap_prompt_slot_mismatch_v2',
        'board_texture_policy_expected_action_mismatch_v2',
        'action_choice_prompt_action_mismatch_v2',
        'action_choice_available_actions_invalid_v2',
        'action_choice_available_actions_missing_expected_v2',
        'showdown_visible_payload_missing_v2',
        'showdown_copy_winner_mismatch_v2',
        'bet_sizing_prompt_preset_mismatch_v2',
        'bet_sizing_acceptable_presets_include_expected_v2',
        'board_texture_classifier_prompt_label_mismatch_v2',
        'range_bucket_classifier_prompt_label_mismatch_v2',
        'hand_chain_prompt_step_count_mismatch_v2',
        'hand_chain_step_number_mismatch_v2',
        'hand_chain_step_street_prefix_mismatch_v2',
      ]),
    );
  });

  test('v2 handles world10 track card_tap prompts on the canonical path', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'content_integrity_validator_v2_track_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeManifestV2(tempRoot, includeManifestDrills: false);
    _writeFileV2(
      tempRoot,
      'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.tap_hole_left_anchor.json',
      jsonEncode(<String, Object?>{
        'id': 'tap_hole_left_anchor',
        'kind': 'card_tap',
        'prompt': 'Tap hole_left before committing chips.',
        'expected': <String, Object?>{'cardSlot': 'hole_left'},
        'error_class': 'focus_anchor_mismatch',
      }),
    );

    final report = buildContentIntegrityReportV2(rootPath: tempRoot.path);

    expect(report.filesChecked, 1);
    expect(report.issues, isEmpty);
    expect(renderContentIntegrityReportV2(report), contains('STATUS\tOK'));
  });
}

void _writeManifestV2(Directory root, {bool includeManifestDrills = true}) {
  _writeFileV2(
    root,
    'content/_meta/world_drills_manifest_v1.json',
    jsonEncode(<String, Object?>{
      'version': 1,
      'worlds': <Object?>[
        <String, Object?>{
          'world': 1,
          'sessions': includeManifestDrills
              ? <Object?>[
                  <String, Object?>{
                    'id': 'w1.s01',
                    'path': 'content/worlds/world1/v1/sessions/w1.s01/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'valid_seat',
                        'path':
                            'content/worlds/world1/v1/sessions/w1.s01/drills/d.valid_seat.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w1.s02',
                    'path': 'content/worlds/world1/v1/sessions/w1.s02/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_seat',
                        'path':
                            'content/worlds/world1/v1/sessions/w1.s02/drills/d.invalid_seat.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w1.s03',
                    'path': 'content/worlds/world1/v1/sessions/w1.s03/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_hole',
                        'path':
                            'content/worlds/world1/v1/sessions/w1.s03/drills/d.invalid_hole.json',
                      },
                    ],
                  },
                ]
              : const <Object?>[],
        },
        <String, Object?>{
          'world': 2,
          'sessions': includeManifestDrills
              ? <Object?>[
                  <String, Object?>{
                    'id': 'w2.s04',
                    'path': 'content/worlds/world2/v1/sessions/w2.s04/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_texture',
                        'path':
                            'content/worlds/world2/v1/sessions/w2.s04/drills/d.invalid_texture.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w2.s05',
                    'path': 'content/worlds/world2/v1/sessions/w2.s05/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'missing_drill',
                        'path':
                            'content/worlds/world2/v1/sessions/w2.s05/drills/d.missing_drill.json',
                      },
                    ],
                  },
                ]
              : const <Object?>[],
        },
        <String, Object?>{
          'world': 3,
          'sessions': includeManifestDrills
              ? <Object?>[
                  <String, Object?>{
                    'id': 'w3.s01',
                    'path': 'content/worlds/world3/v1/sessions/w3.s01/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'valid_action',
                        'path':
                            'content/worlds/world3/v1/sessions/w3.s01/drills/d.valid_action.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w3.s02',
                    'path': 'content/worlds/world3/v1/sessions/w3.s02/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_action_prompt',
                        'path':
                            'content/worlds/world3/v1/sessions/w3.s02/drills/d.invalid_action_prompt.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w3.s03',
                    'path': 'content/worlds/world3/v1/sessions/w3.s03/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_action_options',
                        'path':
                            'content/worlds/world3/v1/sessions/w3.s03/drills/d.invalid_action_options.json',
                      },
                    ],
                  },
                ]
              : const <Object?>[],
        },
        <String, Object?>{
          'world': 4,
          'sessions': includeManifestDrills
              ? <Object?>[
                  <String, Object?>{
                    'id': 'w4.s01',
                    'path': 'content/worlds/world4/v1/sessions/w4.s01/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'valid_showdown',
                        'path':
                            'content/worlds/world4/v1/sessions/w4.s01/drills/d.valid_showdown.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w4.s02',
                    'path': 'content/worlds/world4/v1/sessions/w4.s02/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_showdown_payload',
                        'path':
                            'content/worlds/world4/v1/sessions/w4.s02/drills/d.invalid_showdown_payload.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w4.s03',
                    'path': 'content/worlds/world4/v1/sessions/w4.s03/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_showdown_copy',
                        'path':
                            'content/worlds/world4/v1/sessions/w4.s03/drills/d.invalid_showdown_copy.json',
                      },
                    ],
                  },
                ]
              : const <Object?>[],
        },
        <String, Object?>{
          'world': 5,
          'sessions': includeManifestDrills
              ? <Object?>[
                  <String, Object?>{
                    'id': 'w5.s01',
                    'path': 'content/worlds/world5/v1/sessions/w5.s01/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'valid_bet_sizing',
                        'path':
                            'content/worlds/world5/v1/sessions/w5.s01/drills/d.valid_bet_sizing.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w5.s02',
                    'path': 'content/worlds/world5/v1/sessions/w5.s02/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_bet_sizing_prompt',
                        'path':
                            'content/worlds/world5/v1/sessions/w5.s02/drills/d.invalid_bet_sizing_prompt.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w5.s03',
                    'path': 'content/worlds/world5/v1/sessions/w5.s03/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_bet_sizing_acceptable',
                        'path':
                            'content/worlds/world5/v1/sessions/w5.s03/drills/d.invalid_bet_sizing_acceptable.json',
                      },
                    ],
                  },
                ]
              : const <Object?>[],
        },
        <String, Object?>{
          'world': 6,
          'sessions': includeManifestDrills
              ? <Object?>[
                  <String, Object?>{
                    'id': 'w6.s01',
                    'path': 'content/worlds/world6/v1/sessions/w6.s01/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'valid_classifier_texture',
                        'path':
                            'content/worlds/world6/v1/sessions/w6.s01/drills/d.valid_classifier_texture.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w6.s02',
                    'path': 'content/worlds/world6/v1/sessions/w6.s02/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_classifier_texture',
                        'path':
                            'content/worlds/world6/v1/sessions/w6.s02/drills/d.invalid_classifier_texture.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w6.s03',
                    'path': 'content/worlds/world6/v1/sessions/w6.s03/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'valid_classifier_bucket',
                        'path':
                            'content/worlds/world6/v1/sessions/w6.s03/drills/d.valid_classifier_bucket.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w6.s04',
                    'path': 'content/worlds/world6/v1/sessions/w6.s04/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_classifier_bucket',
                        'path':
                            'content/worlds/world6/v1/sessions/w6.s04/drills/d.invalid_classifier_bucket.json',
                      },
                    ],
                  },
                ]
              : const <Object?>[],
        },
        <String, Object?>{
          'world': 7,
          'sessions': includeManifestDrills
              ? <Object?>[
                  <String, Object?>{
                    'id': 'w7.s01',
                    'path': 'content/worlds/world7/v1/sessions/w7.s01/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'valid_chain',
                        'path':
                            'content/worlds/world7/v1/sessions/w7.s01/drills/d.valid_chain.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w7.s02',
                    'path': 'content/worlds/world7/v1/sessions/w7.s02/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_chain_count',
                        'path':
                            'content/worlds/world7/v1/sessions/w7.s02/drills/d.invalid_chain_count.json',
                      },
                    ],
                  },
                  <String, Object?>{
                    'id': 'w7.s03',
                    'path': 'content/worlds/world7/v1/sessions/w7.s03/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_chain_step_prompt',
                        'path':
                            'content/worlds/world7/v1/sessions/w7.s03/drills/d.invalid_chain_step_prompt.json',
                      },
                    ],
                  },
                ]
              : const <Object?>[],
        },
      ],
    }),
  );
}

void _writeFileV2(Directory root, String relativePath, String content) {
  final file = File('${root.path}/$relativePath')..createSync(recursive: true);
  file.writeAsStringSync(content);
}
