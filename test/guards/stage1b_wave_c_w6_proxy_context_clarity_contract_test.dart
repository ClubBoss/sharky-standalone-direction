import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_defaults_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_spatial_scenario_state_v1.dart';

const _targetRows = <_TargetRow>[
  _TargetRow(
    sessionId: 'w6.s01',
    path:
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_call_range.json',
    id: 'choose_call_range',
    expectedAction: 'call',
    requiredSupportSignals: <String>['controlled', 'range edge', 'position'],
  ),
  _TargetRow(
    sessionId: 'w6.s01',
    path:
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_raise_range.json',
    id: 'choose_raise_range',
    expectedAction: 'raise',
    requiredSupportSignals: <String>['board fit', 'range edge', 'fold'],
  ),
  _TargetRow(
    sessionId: 'w6.s01',
    path:
        'content/worlds/world6/v1/sessions/w6.s01/drills/d.choose_fold_trap.json',
    id: 'choose_fold_trap',
    expectedAction: 'fold',
    requiredSupportSignals: <String>['one pair', 'range', 'overpay'],
  ),
  _TargetRow(
    sessionId: 'w6.s03',
    path:
        'content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_call_realize.json',
    id: 'choose_call_realize',
    expectedAction: 'call',
    requiredSupportSignals: <String>['realizes', 'controlled', 'medium'],
  ),
  _TargetRow(
    sessionId: 'w6.s03',
    path:
        'content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_raise_range.json',
    id: 'choose_raise_range',
    expectedAction: 'raise',
    requiredSupportSignals: <String>[
      'board fit',
      'pressure',
      'weaker continues',
    ],
  ),
  _TargetRow(
    sessionId: 'w6.s03',
    path:
        'content/worlds/world6/v1/sessions/w6.s03/drills/d.choose_fold_trap.json',
    id: 'choose_fold_trap',
    expectedAction: 'fold',
    requiredSupportSignals: <String>['one blocker', 'turn board', 'overpay'],
  ),
];

const _projectionDefaultsPath =
    'content/worlds/world6/v1/sessions/spatial_projection_defaults_v1.json';

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
    required this.sessionId,
    required this.path,
    required this.id,
    required this.expectedAction,
    required this.requiredSupportSignals,
  });

  final String sessionId;
  final String path;
  final String id;
  final String expectedAction;
  final List<String> requiredSupportSignals;
}

Map<String, dynamic> _loadJson(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'Missing target drill: $path');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

String _lower(String value) => value.toLowerCase();

String _promptCardPair(List<String> cards) => cards.join();

String _promptBoard(List<String> cards) => cards.join('-');

String _uiCardLabel(String cardId) {
  final rank = cardId[0].toUpperCase();
  final suit = switch (cardId.substring(1).toLowerCase()) {
    's' => '♠',
    'h' => '♥',
    'd' => '♦',
    'c' => '♣',
    _ => throw StateError('Unsupported card: $cardId'),
  };
  return '$rank$suit';
}

String _expectedAction(Map<String, dynamic> data) {
  final expected = data['expected'];
  if (expected is Map<String, dynamic>) {
    final actionId = expected['actionId'];
    if (actionId is String) return actionId.toLowerCase();
  }
  return '';
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 120,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    await tester.pump(const Duration(milliseconds: 60));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for ${finder.description}');
}

Future<void> _verifySurfacedRow(WidgetTester tester, _TargetRow row) async {
  final defaultsRaw = File(_projectionDefaultsPath).readAsStringSync();
  final mergedRaw = mergeSessionDrillProjectionDefaultsIntoDrillJsonV1(
    sessionId: row.sessionId,
    drillId: row.id,
    drillRaw: File(row.path).readAsStringSync(),
    defaultsRaw: defaultsRaw,
  );
  final item = SessionDrillItemV1(
    drillId: row.id,
    spec: DrillSpecV1.fromJsonString(mergedRaw),
  );
  final projected = resolveSessionDrillCanonicalSpatialScenarioStateV1(
    item.spec,
  )!;

  await tester.pumpWidget(
    MaterialApp(
      home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
        sessionId: row.sessionId,
        initialDrillId: row.id,
        debugDrillsOverrideV1: <SessionDrillItemV1>[item],
      ),
    ),
  );
  await _pumpUntilFound(
    tester,
    find.byKey(const Key('session_drill_player_spatial_table_v1')),
  );

  expect(
    find.byKey(const Key('session_drill_player_load_error')),
    findsNothing,
    reason: row.path,
  );
  final table = tester.widget<ModernTableScreenV1>(
    find.byType(ModernTableScreenV1),
  );
  expect(
    table.debugHeroCardLabels,
    projected.heroHoleCardsV1!.map(_uiCardLabel).toList(),
    reason: '${row.path} surfaced hero cards',
  );
  expect(
    table.debugBoardCardLabels,
    projected.boardCardsV1!.map(_uiCardLabel).toList(),
    reason: '${row.path} surfaced board cards',
  );
  expect(
    table.scenarioSpec!.decisionNodeV1.street,
    projected.projectedStreetV1,
    reason: '${row.path} surfaced street',
  );
  expect(
    table.debugSeatRoleLabels,
    const <int, String>{4: 'HERO', 6: 'VILLAIN'},
    reason: '${row.path} surfaced Hero/Villain identity',
  );
  expect(
    table.debugSeatMarkerLabels?[4],
    'UTG',
    reason: '${row.path} surfaced Hero position',
  );
  expect(
    table.debugSeatMarkerLabels?[6],
    'BB',
    reason: '${row.path} surfaced opponent position',
  );
  expect(
    find.text(item.spec.prompt),
    findsOneWidget,
    reason: '${row.path} surfaced prompt',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Wave C six-row prompts stay synchronized with merged runtime projection truth',
    () {
      final defaultsRaw = File(_projectionDefaultsPath).readAsStringSync();

      expect(_targetRows, hasLength(6));
      expect(_targetRows.map((row) => row.path).toSet(), hasLength(6));

      for (final row in _targetRows) {
        final data = _loadJson(row.path);
        final mergedRaw = mergeSessionDrillProjectionDefaultsIntoDrillJsonV1(
          sessionId: row.sessionId,
          drillId: row.id,
          drillRaw: File(row.path).readAsStringSync(),
          defaultsRaw: defaultsRaw,
        );
        final spec = DrillSpecV1.fromJsonString(mergedRaw);
        final projected = resolveSessionDrillCanonicalSpatialScenarioStateV1(
          spec,
        );
        final prompt = _lower((data['prompt'] ?? '').toString());
        final why = _lower((data['why_v1'] ?? '').toString());
        final correct = _lower((data['feedback_correct_v1'] ?? '').toString());
        final incorrect = _lower(
          (data['feedback_incorrect_v1'] ?? '').toString(),
        );
        final supportText = '$why $correct $incorrect';

        expect(
          sessionDrillProjectionDefaultsApplyToDrillV1(
            sessionId: row.sessionId,
            drillId: row.id,
            defaultsRaw: defaultsRaw,
          ),
          isTrue,
          reason: '${row.path} must be owned by W6 projection defaults',
        );
        expect(
          projected,
          isNotNull,
          reason: '${row.path} must project a table',
        );
        expect(data['id'], row.id, reason: '${row.path} stable ID changed');
        expect(
          data['kind'],
          'action_choice',
          reason: '${row.path} kind changed',
        );
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

        final heroSeat = projected!.heroSeatV1!;
        final villainSeat = projected.villainSeatV1!;
        final heroCards = projected.heroHoleCardsV1!;
        final boardCards = projected.boardCardsV1!;
        expect(
          prompt,
          contains('hero is ${heroSeat.toLowerCase()}'),
          reason: '${row.path} must explicitly identify Hero as $heroSeat',
        );
        expect(
          prompt,
          contains(_lower(_promptCardPair(heroCards))),
          reason:
              '${row.path} prompt hero cards must match merged runtime cards',
        );
        expect(
          prompt,
          contains(_lower(_promptBoard(boardCards))),
          reason: '${row.path} prompt board must match merged runtime board',
        );
        expect(
          prompt,
          contains(villainSeat.toLowerCase()),
          reason: '${row.path} prior-action actor must match projected villain',
        );
        expect(
          projected.projectedStreetV1,
          Street.turn,
          reason: '${row.path} four-card board must project TURN',
        );
        expect(
          '$prompt $supportText',
          isNot(contains('river')),
          reason: '${row.path} must not claim river on a projected turn state',
        );
        expect(
          '$prompt $supportText',
          isNot(contains('completed board')),
          reason:
              '${row.path} must not claim a completed board with four projected cards',
        );

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
    },
  );

  for (final row in _targetRows) {
    testWidgets(
      '${row.sessionId}/${row.id} active surfaced runner matches merged state',
      (tester) => _verifySurfacedRow(tester, row),
    );
  }
}
