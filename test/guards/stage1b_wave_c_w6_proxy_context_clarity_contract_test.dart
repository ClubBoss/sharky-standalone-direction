import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _targetRows = <_TargetRow>[
  _TargetRow(
    path:
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_call_range.json',
    id: 'choose_call_range',
    expectedAction: 'call',
    requiredPromptSignals: <String>['utg', 'kh-8d-3c-2s', 'medium'],
    requiredSupportSignals: <String>['controlled', 'range edge', 'position'],
  ),
  _TargetRow(
    path:
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_raise_range.json',
    id: 'choose_raise_range',
    expectedAction: 'raise',
    requiredPromptSignals: <String>['utg', 'kh-8d-3c-2s', 'pressure'],
    requiredSupportSignals: <String>['board fit', 'range edge', 'fold'],
  ),
  _TargetRow(
    path:
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_fold_trap.json',
    id: 'choose_fold_trap',
    expectedAction: 'fold',
    requiredPromptSignals: <String>['utg', 'kh-8d-3c-2s', 'bb pressure'],
    requiredSupportSignals: <String>['one pair', 'range', 'overpay'],
  ),
  _TargetRow(
    path:
        'content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_call_realize.json',
    id: 'choose_call_realize',
    expectedAction: 'call',
    requiredPromptSignals: <String>['utg', 'jd-7c-3h-2s', 'live equity'],
    requiredSupportSignals: <String>['realizes', 'controlled', 'medium'],
  ),
  _TargetRow(
    path:
        'content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_raise_range.json',
    id: 'choose_raise_range',
    expectedAction: 'raise',
    requiredPromptSignals: <String>['utg', 'jd-7c-3h-2s', 'nut advantage'],
    requiredSupportSignals: <String>['board fit', 'pressure', 'weaker continues'],
  ),
  _TargetRow(
    path:
        'content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_fold_trap.json',
    id: 'choose_fold_trap',
    expectedAction: 'fold',
    requiredPromptSignals: <String>['utg', 'jd-7c-3h-2s', 'river pressure'],
    requiredSupportSignals: <String>['one blocker', 'completed board', 'overpay'],
  ),
];

const _proxyOnlyPromptFragments = <String>[
  'range proxy:',
  'range pressure spot:',
  'trap:',
  'realization proxy:',
  'range-first proxy:',
  'choose raise',
  'choose fold',
];

class _TargetRow {
  const _TargetRow({
    required this.path,
    required this.id,
    required this.expectedAction,
    required this.requiredPromptSignals,
    required this.requiredSupportSignals,
  });

  final String path;
  final String id;
  final String expectedAction;
  final List<String> requiredPromptSignals;
  final List<String> requiredSupportSignals;
}

Map<String, dynamic> _loadJson(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'Missing target drill: $path');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

String _lower(String value) => value.toLowerCase();

String _expectedAction(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is Map<String, dynamic>) {
    final actionId = expected['actionId'];
    if (actionId is String) return actionId.toLowerCase();
  }
  return '';
}

void main() {
  test('Wave C repairs exactly the six W6 proxy action rows', () {
    expect(_targetRows, hasLength(6));
    expect(_targetRows.map((row) => row.path).toSet(), hasLength(6));

    for (final row in _targetRows) {
      final data = _loadJson(row.path);
      final prompt = _lower((data['prompt'] ?? '').toString());
      final why = _lower((data['why_v1'] ?? '').toString());
      final correct = _lower((data['feedback_correct_v1'] ?? '').toString());
      final incorrect = _lower(
        (data['feedback_incorrect_v1'] ?? '').toString(),
      );
      final supportText = '$why $correct $incorrect';

      expect(data['id'], row.id, reason: '${row.path} stable ID changed');
      expect(data['kind'], 'action_choice', reason: '${row.path} kind changed');
      expect(
        _expectedAction(data),
        row.expectedAction,
        reason: '${row.path} expected action changed',
      );
      expect(
        data.containsKey('acceptable_actions_v1'),
        isFalse,
        reason: '${row.path} must not add acceptable action tiers',
      );
      expect(
        data.containsKey('acceptable'),
        isFalse,
        reason: '${row.path} must not add acceptable action tiers',
      );

      for (final fragment in _proxyOnlyPromptFragments) {
        expect(
          prompt,
          isNot(contains(fragment)),
          reason: '${row.path} remains a label-only proxy prompt',
        );
      }

      for (final signal in row.requiredPromptSignals) {
        expect(
          prompt,
          contains(signal),
          reason: '${row.path} prompt missing decisive signal "$signal"',
        );
      }

      for (final signal in row.requiredSupportSignals) {
        expect(
          supportText,
          contains(signal),
          reason:
              '${row.path} why/feedback missing synchronized signal "$signal"',
        );
      }

      expect(
        supportText,
        contains(row.expectedAction),
        reason: '${row.path} feedback/why must name expected action',
      );
    }
  });
}
