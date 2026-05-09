import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/world_intents_ssot_v1.dart';

void main() {
  test('world1 legacy intent family stays normalized to canonical allowed intents', () {
    final repoRoot = Directory.current.path;
    const admittedFiles = <String, String>{
      'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_half_pot_value.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_min_raise_reopen.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_one_third_pot_keep_price.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_pot_pressure.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_big_blind_continue_defend_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_button_open_clean_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s02/drills/d.choose_small_blind_release_caution_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_call_when_pressure_reaches_you_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_first_in_raise_after_folds_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s03/drills/d.choose_fold_when_multiway_pressure_stacks_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s04/drills/d.choose_big_blind_call_repeat_stability_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s04/drills/d.choose_button_open_repeat_stability_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s04/drills/d.choose_small_blind_fold_repeat_stability_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_button_call_playable_pressure_v1.json':
          'trash_hands',
      'content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_cutoff_raise_clean_start_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_small_blind_fold_weak_start_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_call_facing_open_checkpoint_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_fold_oop_pressure_checkpoint_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s06/drills/d.choose_raise_clean_first_in_checkpoint_v1.json':
          'dominated_aces',
      'content/worlds/world1/v1/sessions/w1.s07/drills/d.choose_button_fold_in_position_discipline_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s07/drills/d.choose_button_raise_in_position_focus_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s07/drills/d.choose_cutoff_call_in_position_pressure_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_big_blind_call_oop_defend_focus_v1.json':
          'dominated_aces',
      'content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_small_blind_fold_oop_focus_v1.json':
          'dominated_aces',
      'content/worlds/world1/v1/sessions/w1.s08/drills/d.choose_small_blind_raise_oop_clean_start_v1.json':
          'dominated_aces',
      'content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_call_when_open_reaches_you_focus_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_fold_when_pressure_and_position_fail_focus_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s09/drills/d.choose_raise_when_action_folds_to_you_focus_v1.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s10/drills/d.choose_call_focus.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s10/drills/d.choose_fold_focus.json':
          'hand_discipline_fold',
      'content/worlds/world1/v1/sessions/w1.s10/drills/d.choose_raise_focus.json':
          'hand_discipline_fold',
    };

    for (final entry in admittedFiles.entries) {
      final file = File('$repoRoot/${entry.key}');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final sessionId = RegExp(r'(w1\.s\d+)').firstMatch(entry.key)!.group(1)!;
      final intent = json['intent_v1'] as String?;

      expect(
        intent,
        entry.value,
        reason: '${entry.key} should keep the admitted normalized intent.',
      );
      expect(
        allowedIntentsV1ForSessionId(sessionId).contains(intent),
        isTrue,
        reason: '${entry.key} should use an allowed World 1 intent.',
      );
      expect(
        intent!.startsWith('world1_'),
        isFalse,
        reason:
            '${entry.key} should not keep the legacy session-specific intent label.',
      );
    }

    expect(admittedFiles.length, 31);
  });
}
