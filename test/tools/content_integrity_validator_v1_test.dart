import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/content_integrity_validator_v1.dart';

void main() {
  test('report is deterministic on a focused synthetic fixture', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'content_integrity_validator_v1_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeManifestV1(tempRoot);
    _writeFileV1(
      tempRoot,
      'content/worlds/world1/v1/sessions/w1.s01/drills/d.valid_action.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_action',
        'kind': 'action_choice',
        'prompt': 'Choose call.',
        'expected': <String, Object?>{'actionId': 'call'},
        'error_class': 'action_selection',
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world2/v1/sessions/w2.s03/drills/d.invalid_initiative.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_initiative',
        'kind': 'initiative_aggressor_choice_v1',
        'prompt': 'Who has initiative?',
        'street_v1': 'flop',
        'player_count_v1': 2,
        'hero_seat_v1': 'btn',
        'villain_seat_v1': 'bb',
        'active_seats_v1': <String>['btn', 'bb'],
        'last_aggressor_v1': 'hero',
        'initiative_owner_v1': 'hero',
        'available_actions_v1': <String>['hero', 'villain'],
        'expected': <String, Object?>{'actionId': 'hero'},
        'error_class': 'initiative_aggressor_choice_mismatch',
        'feedback_incorrect_v1': 'Incorrect.',
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world2/v1/sessions/w2.s04/drills/d.invalid_texture.json',
      jsonEncode(<String, Object?>{
        'id': 'invalid_texture',
        'kind': 'board_texture_classifier_v1',
        'prompt': 'Pick the calmer board.',
        'expected_action': 'raise',
        'error_class': 'expected_action_mismatch',
        'feedback_correct_v1': 'Correct.',
        'feedback_incorrect_v1': 'Incorrect.',
      }),
    );

    final first = buildContentIntegrityReportV1(rootPath: tempRoot.path);
    final second = buildContentIntegrityReportV1(rootPath: tempRoot.path);

    expect(first.filesChecked, 4);
    expect(
      renderContentIntegrityReportV1(second),
      equals(renderContentIntegrityReportV1(first)),
    );
    expect(
      first.issues.map((item) => item.reason),
      containsAll(<String>[
        'missing_feedback_correct_v1',
        'invalid_drill_contract',
        'missing_drill_file',
      ]),
    );
  });

  test('world10 track sessions are included in the validator scope', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'content_integrity_validator_v1_track_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeManifestV1(tempRoot, includeManifestDrills: false);
    _writeFileV1(
      tempRoot,
      'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.valid_track.json',
      jsonEncode(<String, Object?>{
        'id': 'valid_track',
        'kind': 'action_choice',
        'prompt': 'Choose raise.',
        'expected': <String, Object?>{'actionId': 'raise'},
        'error_class': 'action_selection',
      }),
    );

    final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

    expect(report.filesChecked, 1);
    expect(report.issues, isEmpty);
    expect(renderContentIntegrityReportV1(report), contains('STATUS\tOK'));
  });

  test('world10 topology authoring readiness catches defaults and role drift', () {
    final tempRoot = Directory.systemTemp.createTempSync(
      'content_integrity_validator_v1_topology_',
    );
    addTearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    _writeManifestV1(tempRoot, includeManifestDrills: false);
    _writeFileV1(
      tempRoot,
      'content/worlds/world10/v1/tracks/tournament/sessions/spatial_projection_defaults_v1.json',
      jsonEncode(<String, Object?>{
        'version': 1,
        'sessions': <String, Object?>{
          'tournament.s01': <String, Object?>{
            'drill_ids': <String>['*'],
            'shared': <String, Object?>{
              'player_count_v1': 9,
              'hero_seat_v1': 'btn',
              'villain_seat_v1': 'bb',
              'active_seats_v1': <String>[
                'btn',
                'co',
                'hj',
                'lj',
                'utg',
                'sb',
                'bb',
              ],
            },
          },
          'tournament.s02': <String, Object?>{
            'drill_ids': <String>['*'],
            'shared': <String, Object?>{
              'player_count_v1': 9,
              'hero_seat_v1': 'btn',
              'villain_seat_v1': 'bb',
              'active_seats_v1': <String>[
                'btn',
                'co',
                'hj',
                'lj',
                'utg',
                'utg1',
                'mp',
                'sb',
                'bb',
              ],
            },
          },
        },
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world10/v1/tracks/tournament/sessions/tournament.s01/drills/d.find_role_anchor.json',
      jsonEncode(<String, Object?>{
        'id': 'find_role_anchor',
        'kind': 'seat_tap',
        'prompt': 'Tap UTG+1 as the position anchor before acting.',
        'expected': <String, Object?>{'role': 'utg1'},
        'error_class': 'anchor_order_mismatch',
      }),
    );
    _writeFileV1(
      tempRoot,
      'content/worlds/world10/v1/tracks/tournament/sessions/tournament.s02/drills/d.find_role_anchor.json',
      jsonEncode(<String, Object?>{
        'id': 'find_role_anchor',
        'kind': 'seat_tap',
        'prompt': 'Tap UTG+1 as the position anchor before acting.',
        'expected': <String, Object?>{'role': 'utg1'},
        'error_class': 'anchor_order_mismatch',
      }),
    );

    final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);
    final reasons = report.issues.map((item) => item.reason).toList();

    expect(
      reasons,
      containsAll(<String>[
        'player_count_active_seat_count_mismatch_v1',
        'seat_tap_expected_role_not_in_active_seats_v1',
      ]),
    );
    expect(
      report.issues.where((item) => item.sessionId == 'tournament.s02'),
      isEmpty,
    );
  });

  test(
    'world6 to world9 spatial topology readiness catches seven max drift',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_world9_topology_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world9/v1/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'w9.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 7,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'sb',
                  'bb',
                ],
              },
            },
            'w9.s02': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 7,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'hj',
                  'co',
                  'lj',
                  'utg',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world9/v1/sessions/w9.s01/drills/d.find_btn.json',
        jsonEncode(<String, Object?>{
          'id': 'find_btn',
          'kind': 'seat_tap',
          'prompt': 'Range thinking setup: tap BTN.',
          'expected': <String, Object?>{'role': 'btn'},
          'error_class': 'anchor_order_mismatch',
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world9/v1/sessions/w9.s02/drills/d.find_mp1.json',
        jsonEncode(<String, Object?>{
          'id': 'find_mp1',
          'kind': 'seat_tap',
          'prompt': 'Tap MP+1 before acting.',
          'expected': <String, Object?>{'role': 'mp1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);
      final reasons = report.issues.map((item) => item.reason).toList();

      expect(
        reasons,
        containsAll(<String>[
          'seven_max_active_seat_order_mismatch_v1',
          'seat_tap_expected_role_not_in_active_seats_v1',
        ]),
      );
      expect(
        report.issues.where((item) => item.sessionId == 'w9.s01'),
        isEmpty,
      );
    },
  );

  test(
    'world6 to world9 spatial topology readiness accepts canonical seven max order',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_world9_topology_ok_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world9/v1/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'w9.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 7,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world9/v1/sessions/w9.s01/drills/d.find_btn.json',
        jsonEncode(<String, Object?>{
          'id': 'find_btn',
          'kind': 'seat_tap',
          'prompt': 'Range thinking setup: tap BTN.',
          'expected': <String, Object?>{'role': 'btn'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(report.issues, isEmpty);
    },
  );

  test(
    'world6 to world9 spatial topology readiness catches eight max drift',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_world8_topology_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world8/v1/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'w8.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 8,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'sb',
                  'bb',
                ],
              },
            },
            'w8.s02': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 8,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg1',
                  'utg',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world8/v1/sessions/w8.s01/drills/d.find_utg1.json',
        jsonEncode(<String, Object?>{
          'id': 'find_utg1',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world8/v1/sessions/w8.s02/drills/d.find_utg1.json',
        jsonEncode(<String, Object?>{
          'id': 'find_utg1',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(
        report.issues.map((item) => item.reason),
        contains('eight_max_active_seat_order_mismatch_v1'),
      );
      expect(
        report.issues.where((item) => item.sessionId == 'w8.s01'),
        isEmpty,
      );
    },
  );

  test(
    'world6 to world9 spatial topology readiness accepts canonical eight max order',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_world8_topology_ok_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world8/v1/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'w8.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 8,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world8/v1/sessions/w8.s01/drills/d.find_utg1.json',
        jsonEncode(<String, Object?>{
          'id': 'find_utg1',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(report.issues, isEmpty);
    },
  );

  test(
    'world6 to world9 canonical eight max acceptance stays isolated from other validator paths',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_world8_topology_isolated_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world8/v1/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'w8.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 8,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world8/v1/sessions/w8.s01/drills/d.find_utg1.json',
        jsonEncode(<String, Object?>{
          'id': 'find_utg1',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);
      final reasons = report.issues.map((item) => item.reason).toList();

      expect(
        reasons,
        isNot(contains('eight_max_active_seat_order_mismatch_v1')),
      );
      expect(
        reasons,
        isNot(contains('seat_tap_expected_role_not_in_active_seats_v1')),
      );
      expect(
        reasons,
        isNot(
          contains('seat_tap_role_anchor_collides_with_non_button_hero_v1'),
        ),
      );
    },
  );

  test('real authored world8 eight max family is accepted cleanly', () {
    final report = buildContentIntegrityReportV1(
      rootPath: Directory.current.path,
    );
    final world8Issues = report.issues
        .where((item) => item.sessionId.startsWith('w8.s'))
        .toList();

    expect(world8Issues, isEmpty);
  });

  test('real authored world9 eight max family is accepted cleanly', () {
    final report = buildContentIntegrityReportV1(
      rootPath: Directory.current.path,
    );
    final world9Issues = report.issues
        .where((item) => item.sessionId.startsWith('w9.s'))
        .toList();

    expect(world9Issues, isEmpty);
  });

  test(
    'world10 topology authoring readiness catches non-button hero role-anchor collisions',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_alt_hero_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 9,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp',
                  'sb',
                  'bb',
                ],
              },
            },
            'cash.s02': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 9,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s02/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap CO as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'co'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(
        report.issues.map((item) => item.reason),
        contains('seat_tap_role_anchor_collides_with_non_button_hero_v1'),
      );
      expect(
        report.issues.where((item) => item.sessionId == 'cash.s02'),
        isEmpty,
      );
    },
  );

  test(
    'world10 9 max role-anchor collision stays isolated from seat-order guard',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_9max_collision_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 9,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);
      final reasons = report.issues.map((item) => item.reason).toList();

      expect(
        reasons,
        contains('seat_tap_role_anchor_collides_with_non_button_hero_v1'),
      );
      expect(
        reasons,
        isNot(contains('nine_max_active_seat_order_mismatch_v1')),
      );
    },
  );

  test(
    'world10 topology authoring readiness catches incomplete blind-level payload',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_blind_level_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/tournament/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'tournament.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 10,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp1',
                  'mp',
                  'sb',
                  'bb',
                ],
                'small_blind_seat_v1': 'sb',
                'big_blind_seat_v1': 'bb',
                'small_blind_amount_v1': 50,
                'big_blind_amount_v1': 100,
                'ante_amount_v1': 10,
              },
            },
            'tournament.s02': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 10,
                'hero_seat_v1': 'utg1',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp1',
                  'mp',
                  'sb',
                  'bb',
                ],
                'small_blind_seat_v1': 'sb',
                'big_blind_seat_v1': 'bb',
                'ante_amount_v1': 10,
              },
            },
          },
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(
        report.issues.map((item) => item.reason),
        contains('blind_level_pair_incomplete_v1'),
      );
      expect(
        report.issues.where((item) => item.sessionId == 'tournament.s01'),
        isEmpty,
      );
    },
  );

  test(
    'world10 topology authoring readiness accepts explicit 10 max token contract',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_10max_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/tournament/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'tournament.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 10,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp1',
                  'mp',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/tournament/sessions/tournament.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap MP+1 as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'mp1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(report.issues, isEmpty);
    },
  );

  test(
    'world10 topology authoring readiness rejects malformed 10 max seat order',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_10max_order_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/tournament/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'tournament.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 10,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp',
                  'mp1',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/tournament/sessions/tournament.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap MP+1 as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'mp1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(
        report.issues.map((item) => item.reason),
        contains('ten_max_active_seat_order_mismatch_v1'),
      );
    },
  );

  test(
    'world10 topology authoring readiness rejects malformed 9 max seat order',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_9max_order_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 9,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'mp',
                  'utg1',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(
        report.issues.map((item) => item.reason),
        contains('nine_max_active_seat_order_mismatch_v1'),
      );
    },
  );

  test(
    'world10 topology authoring readiness accepts explicit 9 max token contract',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_9max_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 9,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'lj',
                  'utg',
                  'utg1',
                  'mp',
                  'sb',
                  'bb',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap UTG+1 as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'utg1'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(report.issues, isEmpty);
    },
  );

  test(
    'world10 topology authoring readiness accepts explicit 6 max token contract',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_6max_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 6,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'hj',
                  'sb',
                  'bb',
                  'utg',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap HJ as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'hj'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(report.issues, isEmpty);
    },
  );

  test(
    'world10 topology authoring readiness rejects malformed 6 max seat order',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_6max_order_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 6,
                'hero_seat_v1': 'btn',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>[
                  'btn',
                  'co',
                  'utg',
                  'sb',
                  'bb',
                  'hj',
                ],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_role_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_role_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap HJ as the position anchor before acting.',
          'expected': <String, Object?>{'role': 'hj'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(
        report.issues.map((item) => item.reason),
        contains('six_max_active_seat_order_mismatch_v1'),
      );
    },
  );

  test(
    'world10 topology authoring readiness accepts explicit 2 max token contract',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_2max_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 2,
                'hero_seat_v1': 'sb',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>['sb', 'bb'],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_villain_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_villain_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap BB as the heads-up opponent before acting.',
          'expected': <String, Object?>{'role': 'bb'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(report.issues, isEmpty);
    },
  );

  test(
    'world10 topology authoring readiness rejects malformed 2 max seat order',
    () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'content_integrity_validator_v1_2max_order_',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      _writeManifestV1(tempRoot, includeManifestDrills: false);
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/spatial_projection_defaults_v1.json',
        jsonEncode(<String, Object?>{
          'version': 1,
          'sessions': <String, Object?>{
            'cash.s01': <String, Object?>{
              'drill_ids': <String>['*'],
              'shared': <String, Object?>{
                'player_count_v1': 2,
                'hero_seat_v1': 'sb',
                'villain_seat_v1': 'bb',
                'active_seats_v1': <String>['bb', 'sb'],
              },
            },
          },
        }),
      );
      _writeFileV1(
        tempRoot,
        'content/worlds/world10/v1/tracks/cash/sessions/cash.s01/drills/d.find_villain_anchor.json',
        jsonEncode(<String, Object?>{
          'id': 'find_villain_anchor',
          'kind': 'seat_tap',
          'prompt': 'Tap BB as the heads-up opponent before acting.',
          'expected': <String, Object?>{'role': 'bb'},
          'error_class': 'anchor_order_mismatch',
        }),
      );

      final report = buildContentIntegrityReportV1(rootPath: tempRoot.path);

      expect(
        report.issues.map((item) => item.reason),
        contains('two_max_active_seat_order_mismatch_v1'),
      );
    },
  );
}

void _writeManifestV1(Directory root, {bool includeManifestDrills = true}) {
  _writeFileV1(
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
                        'id': 'valid_action',
                        'path':
                            'content/worlds/world1/v1/sessions/w1.s01/drills/d.valid_action.json',
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
                    'id': 'w2.s03',
                    'path': 'content/worlds/world2/v1/sessions/w2.s03/',
                    'drills': <Object?>[
                      <String, Object?>{
                        'id': 'invalid_initiative',
                        'path':
                            'content/worlds/world2/v1/sessions/w2.s03/drills/d.invalid_initiative.json',
                      },
                    ],
                  },
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
      ],
    }),
  );
}

void _writeFileV1(Directory root, String relativePath, String content) {
  final file = File('${root.path}/$relativePath')..createSync(recursive: true);
  file.writeAsStringSync(content);
}
