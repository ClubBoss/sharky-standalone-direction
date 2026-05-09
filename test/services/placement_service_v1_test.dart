import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/placement_service_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'placement scoring is deterministic and persists only expected keys',
    () async {
      Future<({String resultJson, Map<String, int> metrics, Set<String> keys})>
      runScenario() async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        await PlacementServiceV1.startPlacementV1(totalItems: 10);
        for (var i = 0; i < 7; i++) {
          await PlacementServiceV1.recordAnswerV1(
            correct: true,
            decisionMs: 1200,
          );
        }
        for (var i = 0; i < 3; i++) {
          await PlacementServiceV1.recordAnswerV1(
            correct: false,
            decisionMs: 2200,
          );
        }
        final result = await PlacementServiceV1.finishPlacementV1(
          skillBand: 'intermediate',
        );
        final metrics = await PlacementServiceV1.getLastResultMetricsV1();
        final prefs = await SharedPreferences.getInstance();
        return (
          resultJson: jsonEncode(result.toJson()),
          metrics: metrics,
          keys: prefs.getKeys(),
        );
      }

      final first = await runScenario();
      final second = await runScenario();

      expect(first.resultJson, second.resultJson);
      expect(first.metrics['correctCount'], second.metrics['correctCount']);
      expect(first.metrics['totalCount'], second.metrics['totalCount']);
      expect(first.metrics['durationMs']!, greaterThanOrEqualTo(0));
      expect(second.metrics['durationMs']!, greaterThanOrEqualTo(0));
      expect(first.keys, contains('placement_result_v1'));
      expect(first.keys, isNot(contains('placement_run_state_v1')));

      final parsed = PlacementResultV1.tryParse(
        jsonDecode(first.resultJson) as Map<String, dynamic>,
      );
      expect(parsed, isNotNull);
      expect(parsed!.schemaVersion, 1);
      expect(parsed.bucket, PlacementBucketV1.intermediate);
      expect(parsed.confidence, inInclusiveRange(0.0, 1.0));
      expect(parsed.weakAreas, contains(kPlacementWeakAreaPositionsV1));
      expect(parsed.weakAreas, contains(kPlacementWeakAreaHandSelectionV1));
    },
  );

  test(
    'placement route mapping is deterministic with repair and downgrade',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      const intermediate = PlacementResultV1(
        bucket: PlacementBucketV1.intermediate,
        confidence: 0.82,
        weakAreas: <String>['positions'],
      );
      final routeA = await PlacementServiceV1.computePlacementRouteV1(
        intermediate,
      );
      final routeB = await PlacementServiceV1.computePlacementRouteV1(
        intermediate,
      );
      expect(jsonEncode(routeA.toJson()), jsonEncode(routeB.toJson()));
      expect(routeA.startTargetSessionId, 'w3.s01');
      expect(routeA.repairSessionId, 'w2.s01');
      expect(routeA.reasonCodes, contains('repair_w2_s01'));

      final firstLaunch =
          await PlacementServiceV1.consumeNextPlacementSessionIdV1();
      final secondLaunch =
          await PlacementServiceV1.consumeNextPlacementSessionIdV1();
      final thirdLaunch =
          await PlacementServiceV1.consumeNextPlacementSessionIdV1();
      expect(firstLaunch, 'w2.s01');
      expect(secondLaunch, 'w3.s01');
      expect(thirdLaunch, isNull);

      const advancedLowConfidence = PlacementResultV1(
        bucket: PlacementBucketV1.advanced,
        confidence: 0.65,
        weakAreas: <String>['none'],
      );
      final downgradedRoute = await PlacementServiceV1.computePlacementRouteV1(
        advancedLowConfidence,
      );
      expect(downgradedRoute.startTargetSessionId, 'w3.s01');
      expect(
        downgradedRoute.reasonCodes,
        contains('advanced_low_confidence_downgrade'),
      );

      const handSelection = PlacementResultV1(
        bucket: PlacementBucketV1.beginner,
        confidence: 0.55,
        weakAreas: <String>[kPlacementWeakAreaHandSelectionV1],
      );
      final handSelectionRoute =
          await PlacementServiceV1.computePlacementRouteV1(handSelection);
      expect(handSelectionRoute.repairSessionId, 'w1.s01');

      const tableBasics = PlacementResultV1(
        bucket: PlacementBucketV1.beginner,
        confidence: 0.52,
        weakAreas: <String>[kPlacementWeakAreaTableBasicsV1],
      );
      final tableBasicsRoute = await PlacementServiceV1.computePlacementRouteV1(
        tableBasics,
      );
      expect(tableBasicsRoute.repairSessionId, 'w0.s01');
    },
  );

  test('weak area derivation emits canonical routing tokens', () async {
    Future<PlacementResultV1> runScenario({
      required int wrongCount,
      required int decisionMs,
      required int totalItems,
    }) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await PlacementServiceV1.startPlacementV1(totalItems: totalItems);
      final correctCount = totalItems - wrongCount;
      for (var i = 0; i < correctCount; i++) {
        await PlacementServiceV1.recordAnswerV1(
          correct: true,
          decisionMs: decisionMs,
        );
      }
      for (var i = 0; i < wrongCount; i++) {
        await PlacementServiceV1.recordAnswerV1(
          correct: false,
          decisionMs: decisionMs,
        );
      }
      return PlacementServiceV1.finishPlacementV1(skillBand: 'beginner');
    }

    final positionsOnly = await runScenario(
      wrongCount: 1,
      decisionMs: 2000,
      totalItems: 6,
    );
    expect(positionsOnly.weakAreas, contains(kPlacementWeakAreaPositionsV1));
    expect(
      positionsOnly.weakAreas,
      isNot(contains(kPlacementWeakAreaHandSelectionV1)),
    );

    final withTableBasics = await runScenario(
      wrongCount: 4,
      decisionMs: 2000,
      totalItems: 6,
    );
    expect(
      withTableBasics.weakAreas,
      containsAll(<String>[
        kPlacementWeakAreaPositionsV1,
        kPlacementWeakAreaHandSelectionV1,
        kPlacementWeakAreaTableBasicsV1,
      ]),
    );

    final none = await runScenario(
      wrongCount: 0,
      decisionMs: 1200,
      totalItems: 6,
    );
    expect(none.weakAreas, <String>[kPlacementWeakAreaNoneV1]);
    expect(
      none.weakAreas.any((token) => token == 'seat_order'),
      isFalse,
      reason: 'legacy token must not be emitted by derivation',
    );
    expect(
      none.weakAreas.any((token) => token == 'rules_table_basics'),
      isFalse,
      reason: 'legacy token must not be emitted by derivation',
    );
  });
}
