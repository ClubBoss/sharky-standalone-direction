import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Stage 1B Wave B W4 correct feedback is reason-bearing', () {
    for (final target in _w4Targets) {
      final data = _readJson(target.path);

      expect(data['id'], target.id);
      expect(data['expected'], target.expectedAction);
      expect(data['acceptable_actions'], target.acceptableActions);
      expect(data['why_v1'], target.whyV1);

      final feedback = data['feedback_correct_v1'] as String? ?? '';
      expect(feedback, isNot(matches(_labelOnlyTemplatePattern)));
      expect(
        _hasReasonBearingCue(feedback),
        isTrue,
        reason: '${target.path} correct feedback must carry its own cue.',
      );
    }
  });

  test('Stage 1B Wave B W5 wet/dry accepted alternates are explained', () {
    for (final target in _w5Targets) {
      final data = _readJson(target.path);

      expect(data['id'], target.id);
      expect(data['expected_action'], target.expectedAction);
      expect(data['acceptable_actions'], target.acceptableActions);

      final feedback = data['feedback_acceptable_v1'] as String? ?? '';
      expect(feedback.trim(), isNotEmpty, reason: target.path);
      expect(
        feedback.toLowerCase(),
        contains(target.textureCue),
        reason: '${target.path} acceptable feedback must name texture cue.',
      );
      expect(
        _mentionsPreferredAction(feedback, target.expectedAction),
        isTrue,
        reason: '${target.path} acceptable feedback must explain preference.',
      );

      final combined = <String>[
        data['prompt'] as String? ?? '',
        data['feedback_correct_v1'] as String? ?? '',
        data['feedback_incorrect_v1'] as String? ?? '',
        data['feedback_acceptable_v1'] as String? ?? '',
        data['why_v1'] as String? ?? '',
      ].join(' ').toLowerCase();
      for (final forbidden in _falseTextureAbsolutes) {
        expect(
          combined,
          isNot(contains(forbidden)),
          reason: '${target.path} must avoid false texture absolute.',
        );
      }
    }
  });

  test('Stage 1B Wave B does not reintroduce W5.s11 active truth', () {
    final activeW5Sessions = <String>[
      'w5.s01',
      'w5.s02',
      'w5.s03',
      'w5.s04',
      'w5.s05',
      'w5.s06',
      'w5.s07',
      'w5.s08',
      'w5.s09',
      'w5.s10',
    ];

    for (final path in <String>[
      'content/_meta/world_drills_manifest_v1.json',
      'content/_meta/world_sessions_manifest_v1.json',
    ]) {
      final manifest = _readJson(path);
      final worlds = manifest['worlds'] as List<dynamic>;
      final world5 = worlds.cast<Map<String, dynamic>>().singleWhere(
        (world) => world['world'] == 5,
      );
      final sessions = (world5['sessions'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((session) => session['id'] as String)
          .toList();
      expect(sessions, activeW5Sessions);
    }
  });
}

final _labelOnlyTemplatePattern = RegExp(
  r'^Correct\. (Call|Fold|Raise) (is expected|matches|fits)\b',
);

const _falseTextureAbsolutes = <String>[
  'wet means call',
  'wet always',
  'dry means raise',
  'dry always',
  'paired means fold',
  'paired always',
];

bool _hasReasonBearingCue(String feedback) {
  final lower = feedback.toLowerCase();
  return lower.contains('because') ||
      lower.contains('when') ||
      lower.contains('keeps') ||
      lower.contains('charges') ||
      lower.contains('denies') ||
      lower.contains('controls') ||
      lower.contains('pressures') ||
      lower.contains('protects') ||
      lower.contains('releases') ||
      lower.contains('captures') ||
      lower.contains('avoids') ||
      lower.contains('make ') ||
      lower.contains('makes ') ||
      lower.contains('favor ') ||
      lower.contains('favors ');
}

bool _mentionsPreferredAction(String feedback, String expectedAction) {
  final lower = feedback.toLowerCase();
  return lower.contains('$expectedAction is preferred') ||
      lower.contains('$expectedAction stays preferred') ||
      lower.contains('preferred $expectedAction');
}

Map<String, dynamic> _readJson(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

class _W4Target {
  const _W4Target(this.session, this.id, this.expectedAction, this.whyV1);

  final String session;
  final String id;
  final Map<String, dynamic> expectedAction;
  final String whyV1;

  String get path =>
      'content/worlds/world4/v1/sessions/$session/drills/d.$id.json';

  List<dynamic>? get acceptableActions => null;
}

class _W5Target {
  const _W5Target(
    this.session,
    this.id,
    this.expectedAction,
    this.acceptableActions,
    this.textureCue,
  );

  final String session;
  final String id;
  final String expectedAction;
  final List<String> acceptableActions;
  final String textureCue;

  String get path =>
      'content/worlds/world5/v1/sessions/$session/drills/d.$id.json';
}

const _w4Targets = <_W4Target>[
  _W4Target(
    'w4.s01',
    'choose_call_trap',
    {'actionId': 'call'},
    'Call keeps weaker bluffs in when raising is too aggressive.',
  ),
  _W4Target(
    'w4.s01',
    'choose_fold_release',
    {'actionId': 'fold'},
    'Fold avoids paying extra when continue value is too low.',
  ),
  _W4Target(
    'w4.s01',
    'choose_raise_value',
    {'actionId': 'raise'},
    'Raise for value when worse hands can still continue.',
  ),
  _W4Target(
    'w4.s02',
    'choose_call_control',
    {'actionId': 'call'},
    'Call controls risk when raising does not gain enough fold equity.',
  ),
  _W4Target(
    'w4.s02',
    'choose_fold_trap',
    {'actionId': 'fold'},
    'Fold when bluff conditions are missing and pressure is too high.',
  ),
  _W4Target(
    'w4.s03',
    'choose_call_trap',
    {'actionId': 'call'},
    'Call keeps the pot under control when bluff pressure is weak.',
  ),
  _W4Target(
    'w4.s03',
    'choose_fold_release',
    {'actionId': 'fold'},
    'Fold when continue value is low and pressure is too costly.',
  ),
  _W4Target(
    'w4.s03',
    'choose_raise_value',
    {'actionId': 'raise'},
    'Raise for value when worse hands can still continue.',
  ),
  _W4Target('w4.s04', 'choose_call_repeat', {
    'actionId': 'call',
  }, 'Call controls risk when raising is too thin.'),
  _W4Target(
    'w4.s04',
    'choose_fold_repeat',
    {'actionId': 'fold'},
    'Fold when expected return is too low to continue.',
  ),
  _W4Target(
    'w4.s04',
    'choose_raise_repeat',
    {'actionId': 'raise'},
    'Raise for value when worse hands can still continue.',
  ),
  _W4Target(
    'w4.s05',
    'choose_call_repeat',
    {'actionId': 'call'},
    'Call controls risk when a raise would overcommit.',
  ),
  _W4Target(
    'w4.s05',
    'choose_fold_repeat',
    {'actionId': 'fold'},
    'Fold when protection pressure is not worth the cost.',
  ),
  _W4Target(
    'w4.s06',
    'choose_call_repeat',
    {'actionId': 'call'},
    'Call controls risk when a raise adds too much variance.',
  ),
  _W4Target(
    'w4.s06',
    'choose_fold_repeat',
    {'actionId': 'fold'},
    'Fold when denial pressure is not worth the extra cost.',
  ),
  _W4Target(
    'w4.s06',
    'choose_raise_repeat',
    {'actionId': 'raise'},
    'Raise now to deny equity and charge weaker draws.',
  ),
  _W4Target(
    'w4.s07',
    'choose_call_focus',
    {'actionId': 'call'},
    'Call keeps weaker hands in when a raise narrows too hard.',
  ),
  _W4Target(
    'w4.s07',
    'choose_fold_focus',
    {'actionId': 'fold'},
    'Fold releases weak value candidates when the price is not justified.',
  ),
  _W4Target(
    'w4.s07',
    'choose_raise_focus',
    {'actionId': 'raise'},
    'Raise for value when worse hands can still continue.',
  ),
  _W4Target(
    'w4.s08',
    'choose_call_focus',
    {'actionId': 'call'},
    'Call controls pot size when protection raise is too thin.',
  ),
  _W4Target(
    'w4.s08',
    'choose_fold_focus',
    {'actionId': 'fold'},
    'Fold preserves chips when protection equity is no longer real.',
  ),
  _W4Target(
    'w4.s08',
    'choose_raise_focus',
    {'actionId': 'raise'},
    'Raise protects equity by charging draws and weak continues.',
  ),
  _W4Target(
    'w4.s09',
    'choose_call_focus',
    {'actionId': 'call'},
    'Call keeps the line alive when raise pressure is weak.',
  ),
  _W4Target(
    'w4.s09',
    'choose_fold_focus',
    {'actionId': 'fold'},
    'Fold when bluff pressure is gone and price is unfavorable.',
  ),
  _W4Target(
    'w4.s09',
    'choose_raise_focus',
    {'actionId': 'raise'},
    'Raise maximizes fold pressure when value hands are capped.',
  ),
  _W4Target(
    'w4.s10',
    'choose_call_focus',
    {'actionId': 'call'},
    'Call controls variance when denial raise adds little value.',
  ),
  _W4Target(
    'w4.s10',
    'choose_fold_focus',
    {'actionId': 'fold'},
    'Fold when denial value is gone and price is unfavorable.',
  ),
  _W4Target(
    'w4.s10',
    'choose_raise_focus',
    {'actionId': 'raise'},
    'Raise denies equity by charging weak draws and overcards.',
  ),
];

const _w5Targets = <_W5Target>[
  _W5Target('w5.s01', 'classify_texture_intro_dry_raise_v1', 'raise', [
    'call',
  ], 'dry'),
  _W5Target('w5.s01', 'classify_texture_intro_dry_call_control_v1', 'call', [
    'fold',
  ], 'dry'),
  _W5Target('w5.s01', 'classify_texture_intro_wet_call_v1', 'call', [
    'fold',
  ], 'wet'),
  _W5Target('w5.s01', 'classify_texture_intro_wet_fold_pressure_v1', 'fold', [
    'call',
  ], 'wet'),
  _W5Target('w5.s10', 'classify_texture_synthesis_dry_raise_v1', 'raise', [
    'call',
  ], 'dry'),
  _W5Target('w5.s10', 'classify_texture_synthesis_wet_fold_v1', 'fold', [
    'call',
  ], 'wet'),
];
