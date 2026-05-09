import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'Worlds 1-3 gold-spine chain feedback stays scenario-first and poker-reasoned',
    () {
      final repoRoot = Directory.current.path;
      final expectations = <String, Map<int, List<String>>>{
        'content/worlds/world1/v1/sessions/w1.s01/drills/d.chain_world1_first_bridge_v1.json': <int, List<String>>{
          0: <String>['QJs', 'button', 'calling keeps position'],
          1: <String>['T6o', 'small blind', 'out of position'],
          2: <String>['One-third pot', 'price cheap'],
          3: <String>['Half pot', 'value size'],
        },
        'content/worlds/world1/v1/sessions/w1.s03/drills/d.chain_world1_action_order_checkpoint_v1.json': <int, List<String>>{
          0: <String>['AQs', 'small blind', 'pot is still unopened'],
          1: <String>['KQs', 'button', 'calling uses position'],
          2: <String>['T7o', 'multiway pressure', 'out of position'],
        },
        'content/worlds/world2/v1/sessions/w2.s07/drills/d.chain_position_then_initiative_v1.json': <int, List<String>>{
          0: <String>['Button versus big blind', 'acts last after the flop', 'position'],
          1: <String>['last aggressive action', 'initiative stays with hero'],
        },
        'content/worlds/world2/v1/sessions/w2.s09/drills/d.chain_position_initiative_texture_v1.json': <int, List<String>>{
          0: <String>['button', 'acts last after the flop', 'in-position edge'],
          1: <String>['opened preflop', 'last aggressor', 'initiative'],
          2: <String>['Jh Th 9c', 'straight and flush pressure', 'pressure-building action'],
        },
        'content/worlds/world2/v1/sessions/w2.s12/drills/d.chain_world2_capstone_v1.json': <int, List<String>>{
          0: <String>['button', 'acts last after the flop', 'in-position advantage'],
          1: <String>['raised preflop', 'keeps initiative'],
          2: <String>['Jh Th 9c', 'dynamic and draw-heavy'],
          3: <String>['Qh8h', 'strong draw', 'fold equity'],
        },
        'content/worlds/world3/v1/sessions/w3.s01/drills/d.chain_preflop_framework_intro_v1.json': <int, List<String>>{
          0: <String>['AKo', 'premium hand', 'value and initiative'],
          1: <String>['QJs', 'button', 'calling keeps a playable hand in position'],
          2: <String>['T6o', 'out of position', 'folding is cleaner'],
        },
        'content/worlds/world3/v1/sessions/w3.s02/drills/d.chain_preflop_category_reuse_v1.json': <int, List<String>>{
          0: <String>['KJs', 'button', 'late position'],
          1: <String>['KJs', 'calling is cleaner', 'unopened-pot raise'],
          2: <String>['A8o', 'weak offsuit', 'button position'],
        },
        'content/worlds/world3/v1/sessions/w3.s03/drills/d.chain_preflop_checkpoint_v1.json': <int, List<String>>{
          0: <String>['AQs', 'unopened pot', 'profitable first action'],
          1: <String>['KQo', 'calling uses position', 'still unopened'],
          2: <String>['J7o', 'too weak', 'framework disciplined'],
        },
        'content/worlds/world3/v1/sessions/w3.s06/drills/d.chain_preflop_mixed_context_checkpoint_v1.json': <int, List<String>>{
          0: <String>['ATo', 'late-position open', 'takes initiative'],
          1: <String>['KTs', 'calling keeps position', 'medium-strength hand'],
          2: <String>['J8o', 'not strong enough', 'out of position'],
        },
        'content/worlds/world3/v1/sessions/w3.s07/drills/d.chain_preflop_open_fold_position_v1.json': <int, List<String>>{
          0: <String>['KJo', 'late-position value', 'blinds act'],
          1: <String>['KJo', 'more players remain behind', 'earlier position'],
          2: <String>['86o', 'weak offsuit hand', 'profitable open'],
        },
        'content/worlds/world3/v1/sessions/w3.s08/drills/d.chain_preflop_continue_fold_discipline_v1.json': <int, List<String>>{
          0: <String>['QTs', 'playable in-position continue', 'giving up too much equity'],
          1: <String>['K9o', 'big blind', 'dominated strength'],
          2: <String>['AJs', 'continue against a cutoff open', 'needlessly inflating the pot'],
        },
        'content/worlds/world3/v1/sessions/w3.s10/drills/d.chain_preflop_final_checkpoint_v1.json': <int, List<String>>{
          0: <String>['KQs', 'taking initiative', 'cleanest value'],
          1: <String>['QJs', 'continues well in position', 'unopened raise'],
          2: <String>['J8o', 'players behind', 'disciplined choice'],
        },
      };
      final bannedPhrases = <String>{
        'This bridge step is about',
        'This bridge step still rewards',
        'This preview step is asking for',
        'This preview step expects',
        'Folded action leaves a clean open here.',
        'The action order changed',
        'The button keeps position because',
        'This spot still expects a clean unopened raise here.',
        'This facing-open spot wants',
        'This hand does not earn a continue in this frame.',
      };

      for (final fileEntry in expectations.entries) {
        final file = File('$repoRoot/${fileEntry.key}');
        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final steps = json['steps'] as List<dynamic>;

        for (final stepEntry in fileEntry.value.entries) {
          final feedback =
              (steps[stepEntry.key] as Map<String, dynamic>)['feedback_incorrect_v1']
                  as String;

          for (final snippet in stepEntry.value) {
            expect(
              feedback,
              contains(snippet),
              reason: '${fileEntry.key} step ${stepEntry.key + 1} should teach the poker reason explicitly.',
            );
          }
          for (final banned in bannedPhrases) {
            expect(
              feedback,
              isNot(contains(banned)),
              reason: '${fileEntry.key} step ${stepEntry.key + 1} should not regress to abstract template wording.',
            );
          }
        }
      }
    },
  );
}
