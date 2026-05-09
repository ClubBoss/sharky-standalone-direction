import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/validate_training_content.dart' as boundary;
import '../../tools/world_intents_ssot_v1.dart';

void main() {
  const expectedIntentByFile = <String, String>{
    'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_board_plays_showdown.json':
        'world2_showdown_bridge',
    'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_hero_top_pair_showdown.json':
        'world2_showdown_bridge',
    'content/worlds/world2/v1/sessions/w2.s01/drills/d.choose_villain_straight_showdown.json':
        'world2_showdown_bridge',
    'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_in_position_btn_vs_bb.json':
        'position_ip_advantage',
    'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_hero_out_of_position_bb_vs_btn.json':
        'position_oop_pain',
    'content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_villain_acts_later_co_vs_btn.json':
        'position_btn_vs_early',
    'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_has_initiative_open_vs_call.json':
        'world2_initiative_bridge',
    'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_hero_more_likely_to_continue_pressure.json':
        'world2_initiative_bridge',
    'content/worlds/world2/v1/sessions/w2.s03/drills/d.choose_villain_last_aggressor_open_vs_call.json':
        'world2_initiative_bridge',
    'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_dry_ace_seven_deuce_rainbow.json':
        'texture_pressure_building',
    'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_paired_king_king_three_rainbow.json':
        'texture_pressure_building',
    'content/worlds/world2/v1/sessions/w2.s04/drills/d.classify_coordinated_jack_ten_nine_two_tone.json':
        'texture_pressure_building',
    'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_showdown_hero_top_pair.json':
        'world2_showdown_bridge',
    'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_initiative_hero_keeps_pressure.json':
        'world2_initiative_bridge',
    'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_flush_draw_nine_outs.json':
        'world2_outs_bridge',
    'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_open_ended_straight_draw_eight_outs.json':
        'world2_outs_bridge',
    'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_gutshot_four_outs.json':
        'world2_outs_bridge',
    'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json':
        'world2_authored_bridge',
    'content/worlds/world2/v1/sessions/w2.s08/drills/d.chain_texture_then_outs_v1.json':
        'world2_authored_bridge',
    'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json':
        'world2_authored_bridge',
    'content/worlds/world2/v1/sessions/w2.s10/drills/d.chain_texture_outs_action_v1.json':
        'world2_authored_bridge',
    'content/worlds/world2/v1/sessions/w2.s11/drills/d.chain_position_initiative_action_v1.json':
        'world2_authored_bridge',
    'content/worlds/world2/v1/sessions/w2.s12/drills/d.chain_world2_capstone_v1.json':
        'world2_authored_bridge',
    'content/worlds/world2/v1/sessions/w2.s13/drills/d.chain_texture_outs_continue_v1.json':
        'world2_authored_bridge',
    'content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json':
        'world2_authored_bridge',
  };

  const tailSessions = <String>{'w2.s11', 'w2.s12', 'w2.s13', 'w2.s14'};

  Map<String, dynamic> _readJson(String path) {
    return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  }

  test(
    'World 2 bridge and mixed hand-chain arc converges validator metadata',
    () {
      for (final entry in expectedIntentByFile.entries) {
        final json = _readJson(entry.key);
        final sessionId = RegExp(
          r'content/worlds/world2/v1/sessions/(w2\.s\d{2})/',
        ).firstMatch(entry.key)!.group(1)!;

        expect(json['intent_v1'], entry.value, reason: entry.key);
        expect(
          allowedIntentsV1ForSessionId(sessionId).contains(json['intent_v1']),
          isTrue,
          reason: entry.key,
        );
      }

      for (final sessionId in tailSessions) {
        final notesPath =
            'content/worlds/world2/v1/sessions/$sessionId/notes.md';
        final notes = File(notesPath).readAsStringSync();
        expect(
          boundary.validateSharedCoreFormatBoundaryTextV1(
            filePath: notesPath,
            content: notes,
          ),
          isEmpty,
          reason: notesPath,
        );
      }
    },
  );

  test('validator no longer reports World 2 content-path failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('validate_world_content_v1: content/worlds/world2/'),
      isFalse,
      reason: combined,
    );
  });
}
