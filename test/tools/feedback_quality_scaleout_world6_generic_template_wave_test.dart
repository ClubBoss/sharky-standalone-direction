import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('scale-out generic-template corrective feedback stays poker-reasoned', () {
    final repoRoot = Directory.current.path;
    final sessionExpectations = <String, Map<String, List<String>>>{
      'w6.s01': <String, List<String>>{
        'd.classify_missed_fold.json': <String>[
          'missed bucket',
          'fold',
          'too little clean equity',
        ],
        'd.classify_strong_raise.json': <String>[
          'strong bucket',
          'raise',
          'build the pot',
        ],
        'd.find_btn.json': <String>['button', 'acting last', 'positional edge'],
        'd.find_co_range.json': <String>[
          'cutoff',
          'earlier late-position seat',
          'applying pressure',
        ],
        'd.tap_flop_mid.json': <String>[
          'middle flop card',
          'texture anchor',
          'range story',
        ],
        'd.tap_hole_left_as.json': <String>[
          'ace of spades',
          'left hole card',
          'blocker cue',
        ],
        'd.tap_turn_range.json': <String>[
          'turn',
          'second board change',
          'range pressure',
        ],
      },
      'w6.s02': <String, List<String>>{
        'd.choose_call_realize.json': <String>[
          'realize equity',
          'medium-strength continue',
          'unnecessary raise',
        ],
        'd.choose_raise_blocker.json': <String>[
          'blocker',
          'fold equity',
          'aggression',
        ],
        'd.find_bb.json': <String>[
          'big blind',
          'closes the action',
          'positional pressure',
        ],
        'd.find_btn_realize.json': <String>[
          'button',
          'acts last',
          'positional edge',
        ],
        'd.tap_flop_realize.json': <String>['flop', 'texture', 'draw pressure'],
        'd.tap_hole_right_ks.json': <String>[
          'king of spades',
          'blocker',
          'strong hands are reduced',
        ],
        'd.tap_river_trap.json': <String>[
          'river',
          'show down',
          'finished equity picture',
        ],
        'd.tap_turn.json': <String>[
          'turn',
          'adds or removes draws',
          'realizes its equity',
        ],
      },
      'w6.s03': <String, List<String>>{
        'd.choose_call_realize.json': <String>[
          'live equity',
          'controlled continue',
          'forced aggression',
        ],
        'd.choose_fold_trap.json': <String>[
          'full range picture',
          'preserving chips',
          'pressure story',
        ],
        'd.choose_raise_range.json': <String>[
          'range owns the cleaner advantage',
          'pressure',
          'passive line',
        ],
        'd.find_bb_advantage.json': <String>[
          'big blind',
          'forced seat',
          'range-advantage read',
        ],
        'd.find_sb.json': <String>[
          'small blind',
          'pressured in-between seat',
          'positional context',
        ],
        'd.tap_flop_left.json': <String>[
          'left flop card',
          'board favors your range',
          'texture read',
        ],
        'd.tap_hole_left.json': <String>[
          'left hole card',
          'blocker or showdown value',
          'hand advantage',
        ],
        'd.tap_turn_advantage.json': <String>[
          'turn',
          'pressure edge',
          'range advantage',
        ],
      },
      'w6.s04': <String, List<String>>{
        'd.choose_call_turn_compress.json': <String>[
          'turn compresses both ranges',
          'controlled line',
          'realizes equity',
        ],
        'd.choose_raise_turn_edge.json': <String>[
          'clearer pressure edge',
          'compressed board',
          'capped hands',
        ],
        'd.find_btn_turn_compress.json': <String>[
          'button',
          'last word',
          'full information',
        ],
        'd.find_hj_turn_compress.json': <String>[
          'hijack',
          'earlier-position range',
          'compressed board',
        ],
        'd.tap_flop_reference.json': <String>[
          'flop',
          'original texture',
          'compressing both ranges',
        ],
        'd.tap_hole_left_turn.json': <String>[
          'left hole card',
          'blocker or pair component',
          'pressure or should stay controlled',
        ],
        'd.tap_river_turn_compress.json': <String>[
          'river',
          'narrowed ranges',
          'final card',
        ],
        'd.tap_turn_compress.json': <String>[
          'turn',
          'compresses the range interaction',
          'aggression or control',
        ],
      },
      'w6.s05': <String, List<String>>{
        'd.choose_fold_merged.json': <String>[
          'river stays merged',
          'real edge',
          'thin continue',
        ],
        'd.choose_raise_polar.json': <String>[
          'clearly polarized',
          'bluff catchers',
          'passive finish',
        ],
        'd.find_bb_river_polar.json': <String>[
          'big blind',
          'forced defender',
          'final bet',
        ],
        'd.find_sb_river_polar.json': <String>[
          'small blind',
          'earlier defending range',
          'polarized line',
        ],
        'd.tap_flop_river_polar.json': <String>[
          'flop',
          'board story started',
          'final pressure line',
        ],
        'd.tap_hole_right_polar.json': <String>[
          'right hole card',
          'blocker or value card',
          'credibly polarize',
        ],
        'd.tap_river_polar.json': <String>[
          'river',
          'merged or polarized ending',
          'last card',
        ],
        'd.tap_turn_reference.json': <String>[
          'turn',
          'one street earlier',
          'compressed, merged, or truly polarized',
        ],
      },
      'w6.s08': <String, List<String>>{
        'd.choose_raise_blocker_edge.json': <String>[
          'Raise',
          'blocker',
          'capped continues',
        ],
        'd.find_btn_blocker_context.json': <String>[
          'button',
          'acting last',
          'most information',
        ],
        'd.find_co_blocker_context.json': <String>[
          'cutoff',
          'earlier late-position seat',
          'blocker changes the line',
        ],
        'd.tap_flop_blocker_context.json': <String>[
          'middle flop card',
          'blocker-adjusted texture read',
          'between both ranges',
        ],
        'd.tap_hole_left_blocker.json': <String>[
          'ace of spades',
          'left hole card',
          'strong continuing hands',
        ],
        'd.tap_river_blocker_context.json': <String>[
          'river',
          'final card',
          'controlled finish',
        ],
        'd.tap_turn_blocker_context.json': <String>[
          'turn',
          'second board change',
          'loses value',
        ],
      },
      'w6.s09': <String, List<String>>{
        'd.choose_call_flop_transition.json': <String>[
          'both ranges live',
          'controlled continue',
          'thin raise too early',
        ],
        'd.choose_raise_river_transition.json': <String>[
          'river transition',
          'clearer edge',
          'capped continues',
        ],
        'd.find_bb_transition.json': <String>[
          'big blind',
          'forced defender',
          'carries the pressure differently',
        ],
        'd.find_btn_transition.json': <String>[
          'button',
          'acting last',
          'positional edge',
        ],
        'd.tap_flop_transition.json': <String>[
          'flop',
          'original board texture',
          'range edge is strong or still marginal',
        ],
        'd.tap_hole_right_transition.json': <String>[
          'second card',
          'playability',
          'blocker story',
        ],
        'd.tap_river_transition.json': <String>[
          'river',
          'final card',
          'thin value remains',
        ],
        'd.tap_turn_transition.json': <String>[
          'turn',
          'second board change',
          'draw pressure and range leverage',
        ],
      },
      'w6.s10': <String, List<String>>{
        'd.choose_call_synthesis.json': <String>[
          'synthesis picture stays mixed',
          'controlled continue',
          'range edge is strong enough to force aggression',
        ],
        'd.choose_raise_synthesis.json': <String>[
          'whole synthesis read aligns',
          'real pressure edge',
          'marginal continue',
        ],
        'd.find_btn_synthesis.json': <String>[
          'button',
          'acting last',
          'positional leverage',
        ],
        'd.find_co_synthesis.json': <String>[
          'cutoff',
          'earlier late-position seat',
          'anchor the wrong player',
        ],
        'd.tap_flop_synthesis.json': <String>[
          'flop',
          'original board texture',
          'stable, pressured, or still too mixed',
        ],
        'd.tap_hole_left_synthesis.json': <String>[
          'ace of spades',
          'blocker',
          'sharpen or soften your pressure edge',
        ],
        'd.tap_river_synthesis.json': <String>[
          'river',
          'final card',
          'thin value remains',
        ],
        'd.tap_turn_synthesis.json': <String>[
          'turn',
          'second board change',
          'align or break the range story',
        ],
      },
    };

    final world7SessionExpectations = <String, Map<String, List<String>>>{
      'w7.s02': <String, List<String>>{
        'd.choose_call_deep.json': <String>[
          'deep stacks',
          'controlled continue',
          'marginal edge',
        ],
        'd.choose_raise_spr.json': <String>[
          'stack-to-pot ratio',
          'pressure leverage',
          'capped continues',
        ],
        'd.find_btn.json': <String>['button', 'acting last', 'positional edge'],
        'd.find_co_spr.json': <String>[
          'cutoff',
          'earlier late-position seat',
          'anchor the wrong player',
        ],
        'd.tap_flop_spr.json': <String>[
          'flop',
          'original board texture',
          'deep-stack pressure',
        ],
        'd.tap_hole_left_as.json': <String>[
          'ace of spades',
          'blocker',
          'playability',
        ],
        'd.tap_river_trap.json': <String>[
          'river',
          'final card',
          'thin value, a bluff, or a disciplined release',
        ],
        'd.tap_turn.json': <String>[
          'turn',
          'second board change',
          'grow or shrink SPR pressure',
        ],
      },
      'w7.s03': <String, List<String>>{
        'd.choose_call_deep.json': <String>[
          'deep stacks',
          'controlled continue',
          'marginal',
        ],
        'd.choose_fold_trap.json': <String>[
          'shallow-stack pressure',
          'Preserving chips',
          'enough leverage',
        ],
        'd.choose_raise_pressure.json': <String>[
          'shallow-stack pressure',
          'leverage',
          'support aggression',
        ],
        'd.find_bb.json': <String>[
          'big blind',
          'forced defender',
          'shallow-stack pressure',
        ],
        'd.find_btn_medium.json': <String>[
          'button',
          'acts last',
          'positional edge',
        ],
        'd.tap_flop_right.json': <String>[
          'right flop card',
          'first board read',
          'stack pressure or caution',
        ],
        'd.tap_hole_right.json': <String>[
          'right hole card',
          'playability',
          'blocker value',
        ],
        'd.tap_turn_medium.json': <String>[
          'turn',
          'second board change',
          'medium-stack pressure picture',
        ],
      },
      'w7.s01': <String, List<String>>{
        'd.choose_fold_trap.json': <String>[
          'Fold is better',
          'shallow-stack pressure',
          'preserving chips',
        ],
        'd.choose_raise_shallow.json': <String>[
          'Raise is better',
          'shallow-stack pressure',
          'leverage',
        ],
        'd.find_btn_depth.json': <String>[
          'button',
          'acting last',
          'depth-adjusted positional edge',
        ],
        'd.find_sb.json': <String>[
          'small blind',
          'partly committed',
          'shallow-stack decision',
        ],
        'd.tap_flop_left.json': <String>[
          'left flop card',
          'original texture cue',
          'stack-to-pot picture',
        ],
        'd.tap_turn_depth.json': <String>[
          'turn',
          'second board change',
          'depth-adjusted pressure line',
        ],
        'd.tap_hole_right_ks.json': <String>[
          'king of spades',
          'right-hole-card cue',
          'deep-playability detail',
        ],
      },
      'w7.s04': <String, List<String>>{
        'd.choose_raise_deep_leverage.json': <String>[
          'Raise is better',
          'deep-stack leverage',
          'capped continues',
        ],
        'd.find_btn_deep.json': <String>[
          'button',
          'acting last',
          'deep-stack leverage edge',
        ],
        'd.find_hj_deep.json': <String>[
          'hijack',
          'earlier late-position seat',
          'deep-stack leverage decision',
        ],
        'd.tap_flop_mid_deep.json': <String>[
          'middle flop card',
          'original deep-stack texture cue',
          'leverage read',
        ],
        'd.tap_river_deep.json': <String>[
          'river',
          'final card',
          'deep-stack leverage story',
        ],
        'd.tap_turn_deep.json': <String>[
          'turn',
          'second board change',
          'deep-stack pressure line',
        ],
        'd.tap_hole_left_deep.json': <String>[
          'left hole card',
          'deep-stack playability read',
          'actual hand',
        ],
      },
      'w7.s09': <String, List<String>>{
        'd.choose_call_river_depth.json': <String>[
          'Call is better',
          'river-depth threshold',
          'controlling risk',
        ],
        'd.choose_raise_river_depth.json': <String>[
          'Raise is better',
          'river-depth threshold',
          'leverage edge alive',
        ],
        'd.find_btn_river_depth.json': <String>[
          'button',
          'acting last',
          'river-closure leverage read',
        ],
        'd.find_co_river_depth.json': <String>[
          'cutoff',
          'earlier late-position seat',
          'river-depth closure choice',
        ],
        'd.tap_flop_river_depth.json': <String>[
          'right flop card',
          'original board texture',
          'river-depth closeout',
        ],
        'd.tap_river_depth_close.json': <String>[
          'river',
          'final card',
          'depth-conditioned closeout decision',
        ],
        'd.tap_turn_river_reference.json': <String>[
          'turn',
          'second board change',
          'before river closure',
        ],
        'd.tap_hole_right_river_depth.json': <String>[
          'right hole card',
          'final river-depth action',
          'real hand cue',
        ],
      },
      'w7.s05': <String, List<String>>{
        'd.choose_call_after_shift.json': <String>[
          'realize equity',
          'controlled continue',
          'too thin',
        ],
        'd.choose_fold_after_shift.json': <String>[
          'depth shift',
          'preserving chips',
          'stop supporting leverage',
        ],
        'd.find_bb_shift_turn.json': <String>[
          'big blind',
          'forced defender',
          'turn depth shift',
        ],
        'd.find_sb_shift_turn.json': <String>[
          'small blind',
          'partly committed',
          'out of position',
        ],
        'd.tap_flop_reference_shift.json': <String>[
          'left flop card',
          'original board story',
          'turn depth shift',
        ],
        'd.tap_hole_right_shift.json': <String>[
          'right hole card',
          'blocker or playability card',
          'supports pressure',
        ],
        'd.tap_river_depth_shift.json': <String>[
          'river',
          'final card',
          'depth-shift story',
        ],
        'd.tap_turn_depth_shift.json': <String>[
          'turn',
          'effective depth shift',
          'pressure picture',
        ],
      },
      'w7.s06': <String, List<String>>{
        'd.choose_call_ip_depth.json': <String>[
          'realize equity',
          'controlled continue',
          'flexible',
        ],
        'd.choose_raise_ip_depth.json': <String>[
          'in-position depth setup',
          'leverage',
          'capped continues',
        ],
        'd.find_btn_ip_depth.json': <String>[
          'button',
          'acting last',
          'informational edge',
        ],
        'd.find_co_ip_depth.json': <String>[
          'cutoff',
          'earlier late-position seat',
          'in-position range',
        ],
        'd.tap_flop_ip_depth.json': <String>[
          'right flop card',
          'full flop texture',
          'in-position pressure',
        ],
        'd.tap_hole_left_ip_depth.json': <String>[
          'left hole card',
          'blocker value or playability',
          'real hand quality',
        ],
        'd.tap_river_ip_depth.json': <String>[
          'river',
          'final card',
          'value, pressure, or a check-back',
        ],
        'd.tap_turn_ip_depth.json': <String>[
          'turn',
          'second board change',
          'growing or flattening',
        ],
      },
      'w7.s07': <String, List<String>>{
        'd.choose_call_oop_depth.json': <String>[
          'realize equity',
          'controlled continue',
          'edge is not clean enough',
        ],
        'd.choose_fold_oop_depth.json': <String>[
          'high exposure out of position',
          'Preserving chips',
          'act first without enough real edge',
        ],
        'd.find_bb_oop_depth.json': <String>[
          'big blind',
          'forced defender',
          'widest, most pressured range',
        ],
        'd.find_sb_oop_depth.json': <String>[
          'small blind',
          'out of position',
          'act first',
        ],
        'd.tap_flop_oop_depth.json': <String>[
          'left flop card',
          'initial texture anchor',
          'enough coverage',
        ],
        'd.tap_hole_right_oop_depth.json': <String>[
          'right hole card',
          'blocker or playability card',
          'survive acting first',
        ],
        'd.tap_river_oop_depth.json': <String>[
          'river',
          'final card',
          'bluff catcher, or a fold',
        ],
        'd.tap_turn_oop_depth.json': <String>[
          'turn',
          'second board change',
          'stabilizing or becoming too vulnerable',
        ],
      },
      'w7.s08': <String, List<String>>{
        'd.choose_call_blocker_depth.json': <String>[
          'blocker',
          'controlled continue',
          'too thin',
        ],
        'd.choose_raise_blocker_depth.json': <String>[
          'blocker and the stack depth align',
          'fold equity',
          'aggression',
        ],
        'd.find_btn_blocker_depth.json': <String>[
          'button',
          'acting last',
          'most information',
        ],
        'd.find_sb_blocker_depth.json': <String>[
          'small blind',
          'partly committed',
          'most sensitive to blocker pressure',
        ],
        'd.tap_flop_blocker_depth.json': <String>[
          'middle flop card',
          'full flop picture',
          'board support',
        ],
        'd.tap_hole_left_blocker_depth.json': <String>[
          'ace of spades',
          'removes strong continuing hands',
          'real blocker value',
        ],
        'd.tap_river_blocker_depth.json': <String>[
          'river',
          'final card',
          'showdown value',
        ],
        'd.tap_turn_blocker_depth.json': <String>[
          'turn',
          'second board change',
          'gaining leverage or losing value',
        ],
      },
      'w7.s10': <String, List<String>>{
        'd.choose_call_depth_synth.json': <String>[
          'stack depth',
          'controlled continue',
          'forced aggression',
        ],
        'd.choose_fold_depth_synth.json': <String>[
          'removes your leverage',
          'future pressure is gone',
          'preserving chips',
        ],
        'd.choose_raise_depth_synth.json': <String>[
          'depth, price, and playability',
          'pressure edge',
          'capped continues',
        ],
        'd.find_btn_depth_synth.json': <String>[
          'button',
          'acts last',
          'informational edge',
        ],
        'd.find_co_depth_synth.json': <String>[
          'cutoff',
          'earlier late-position range',
          'leverage',
        ],
        'd.tap_flop_depth_synth.json': <String>[
          'flop',
          'original board texture',
          'leverage should grow or shrink',
        ],
        'd.tap_hole_left_depth_synth.json': <String>[
          'ace',
          'blocker',
          'partially removed',
        ],
        'd.tap_hole_right_depth_synth.json': <String>[
          'king',
          'full hand structure',
          'real playability',
        ],
        'd.tap_river_depth_synth.json': <String>[
          'river',
          'finished leverage picture',
          'final anchor',
        ],
        'd.tap_turn_depth_synth.json': <String>[
          'turn',
          'building, flattening, or disappearing',
          'second board change',
        ],
      },
    };

    final world8SessionExpectations = <String, Map<String, List<String>>>{
      'w8.s02': <String, List<String>>{
        'd.choose_call_risk_premium.json': <String>[
          'risk premium',
          'controlled continue',
          'realizes enough equity',
        ],
        'd.choose_fold_icm.json': <String>[
          'ICM pressure',
          'risk premium',
          'preserving tournament life',
        ],
        'd.choose_raise_trap.json': <String>[
          'ICM pressure',
          'fold equity',
          'stack context',
        ],
        'd.find_bb_risk_premium.json': <String>[
          'big blind',
          'forced defender',
          'widest range',
        ],
        'd.find_sb.json': <String>[
          'small blind',
          'partly committed',
          'out of position',
        ],
        'd.tap_hole_right.json': <String>[
          'right hole card',
          'playability',
          'blocker or equity detail',
        ],
        'd.tap_river.json': <String>[
          'river',
          'payout-ladder story',
          'final tournament-pressure read',
        ],
        'd.tap_turn_risk_premium.json': <String>[
          'turn',
          'second board change',
          'risk premium',
        ],
      },
      'w8.s01': <String, List<String>>{
        'd.choose_call_survival.json': <String>[
          'survival pressure',
          'controlled continue',
          'realize equity',
        ],
        'd.choose_fold_bubble.json': <String>[
          'bubble pressure',
          'risk premium',
          'preserving tournament life',
        ],
        'd.choose_raise_trap.json': <String>[
          'bubble pressure',
          'fold equity',
          'stack context',
        ],
        'd.find_bb.json': <String>[
          'big blind',
          'forced defender',
          'widest range',
        ],
        'd.find_btn_bubble.json': <String>[
          'button',
          'acting last',
          'information edge',
        ],
        'd.tap_flop_bubble.json': <String>[
          'middle flop card',
          'first board read',
          'texture',
        ],
        'd.tap_hole_left_as.json': <String>[
          'ace of spades',
          'blocker',
          'risk premium',
        ],
        'd.tap_turn.json': <String>[
          'turn',
          'second board change',
          'survival pressure',
        ],
      },
      'w8.s10': <String, List<String>>{
        'd.choose_call_icm_synth.json': <String>[
          'room to maneuver',
          'controlled continue',
          'playability',
        ],
        'd.choose_fold_icm_synth.json': <String>[
          'survival pressure',
          'risk premium',
          'thin edge',
        ],
        'd.choose_raise_icm_synth.json': <String>[
          'pressure edge',
          'covering leverage',
          'fold equity',
        ],
        'd.find_btn_icm_synth.json': <String>[
          'button',
          'acts last',
          'late-position edge',
        ],
        'd.find_sb_icm_synth.json': <String>[
          'small blind',
          'partly committed',
          'tournament pressure earlier',
        ],
        'd.tap_flop_icm_synth.json': <String>[
          'flop',
          'original board texture',
          'stay controlled or grow',
        ],
        'd.tap_hole_left_icm_synth.json': <String>[
          'ace of spades',
          'blocker',
          'strong continue hands are partly removed',
        ],
        'd.tap_hole_right_icm_synth.json': <String>[
          'king of spades',
          'tournament-pressure balance',
          'playability',
        ],
        'd.tap_river_icm_synth.json': <String>[
          'river',
          'finalizes the ICM picture',
          'value, pressure, or survival',
        ],
        'd.tap_turn_icm_synth.json': <String>[
          'turn',
          'add or remove pressure',
          'control risk or press harder',
        ],
      },
    };

    final world9SessionExpectations = <String, List<String>>{
      'd.choose_call_exploit_synth.json': <String>[
        'exploit read is still useful',
        'controlled extraction',
        'marginal edge',
      ],
      'd.choose_fold_exploit_synth.json': <String>[
        'exploit synthesis read turns against you',
        'pressure pattern',
        'profitable margin',
      ],
      'd.choose_raise_exploit_synth.json': <String>[
        'exploit edge is clean',
        'positional leverage',
        'fold equity',
      ],
      'd.find_btn_exploit_synth.json': <String>[
        'button',
        'acting last',
        'positional leverage',
      ],
      'd.find_seat_s3_exploit_synth.json': <String>[
        'seat S3',
        'correct opponent',
        'wrong player profile',
      ],
      'd.tap_flop_exploit_synth.json': <String>[
        'flop',
        'original board texture',
        'controlled value line or a stronger pressure line',
      ],
      'd.tap_hole_left_exploit_synth.json': <String>[
        'ace of spades',
        'blocker',
        'pressure line more credible',
      ],
      'd.tap_hole_right_exploit_synth.json': <String>[
        'king of spades',
        'playability',
        'keep extracting or back off',
      ],
      'd.tap_river_exploit_synth.json': <String>[
        'river',
        'final card',
        'thin value remains or the pressure line should stop',
      ],
      'd.tap_turn_exploit_synth.json': <String>[
        'turn',
        'second board change',
        'exploit read before the river decision',
      ],
    };

    const bannedPhrases = <String>{
      'This spot expects a different action.',
      'This missed bucket spot expects fold.',
      'This strong bucket spot expects raise.',
      'This step expects the target seat anchor.',
      'This step expects the target board card.',
      'This step expects the target hole card.',
    };

    for (final sessionEntry in sessionExpectations.entries) {
      for (final fileEntry in sessionEntry.value.entries) {
        final file = File(
          '$repoRoot/content/worlds/world6/v1/sessions/${sessionEntry.key}/drills/${fileEntry.key}',
        );
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_incorrect_v1'] as String;

        for (final snippet in fileEntry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${sessionEntry.key}/${fileEntry.key} should teach the poker reason explicitly.',
          );
        }

        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${sessionEntry.key}/${fileEntry.key} should not regress to generic template wording.',
          );
        }
      }
    }

    for (final sessionEntry in world7SessionExpectations.entries) {
      for (final fileEntry in sessionEntry.value.entries) {
        final file = File(
          '$repoRoot/content/worlds/world7/v1/sessions/${sessionEntry.key}/drills/${fileEntry.key}',
        );
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_incorrect_v1'] as String;

        for (final snippet in fileEntry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${sessionEntry.key}/${fileEntry.key} should teach the poker reason explicitly.',
          );
        }

        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${sessionEntry.key}/${fileEntry.key} should not regress to generic template wording.',
          );
        }
      }
    }

    for (final sessionEntry in world8SessionExpectations.entries) {
      for (final fileEntry in sessionEntry.value.entries) {
        final file = File(
          '$repoRoot/content/worlds/world8/v1/sessions/${sessionEntry.key}/drills/${fileEntry.key}',
        );
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final feedback = json['feedback_incorrect_v1'] as String;

        for (final snippet in fileEntry.value) {
          expect(
            feedback,
            contains(snippet),
            reason:
                '${sessionEntry.key}/${fileEntry.key} should teach the poker reason explicitly.',
          );
        }

        for (final banned in bannedPhrases) {
          expect(
            feedback,
            isNot(contains(banned)),
            reason:
                '${sessionEntry.key}/${fileEntry.key} should not regress to generic template wording.',
          );
        }
      }
    }

    for (final fileEntry in world9SessionExpectations.entries) {
      final file = File(
        '$repoRoot/content/worlds/world9/v1/sessions/w9.s10/drills/${fileEntry.key}',
      );
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final feedback = json['feedback_incorrect_v1'] as String;

      for (final snippet in fileEntry.value) {
        expect(
          feedback,
          contains(snippet),
          reason:
              'w9.s10/${fileEntry.key} should teach the poker reason explicitly.',
        );
      }

      for (final banned in bannedPhrases) {
        expect(
          feedback,
          isNot(contains(banned)),
          reason:
              'w9.s10/${fileEntry.key} should not regress to generic template wording.',
        );
      }
    }
  });
}
