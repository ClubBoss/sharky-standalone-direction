import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart';

void main() {
  List<SessionDrillItemV1> buildDrills() {
    SessionDrillItemV1 drill(String id, String prompt, String bucket) {
      return SessionDrillItemV1(
        drillId: id,
        spec: DrillSpecV1.fromJsonString(
          '{"id":"$id","kind":"range_bucket_classifier_v1",'
          '"prompt":"$prompt","range_bucket_v1":"$bucket",'
          '"available_actions_v1":["fold","call","raise"],'
          '"expected_action":"call",'
          '"error_class":"range_bucket_classifier_mismatch",'
          '"feedback_correct_v1":"Correct.",'
          '"feedback_incorrect_v1":"Incorrect."}',
        ),
      );
    }

    return <SessionDrillItemV1>[
      drill('first_range_bucket', 'FIRST TARGET CONTRACT PROMPT', 'medium'),
      drill('recheck_range_bucket', 'RECHECK TARGET CONTRACT PROMPT', 'weak'),
    ];
  }

  Future<void> pumpRunner(
    WidgetTester tester, {
    String? initialDrillId,
    bool isRecheckLaunchV1 = false,
  }) async {
    final namedArguments = <Symbol, dynamic>{
      #sessionId: 'w6.s01',
      #debugDrillsOverrideV1: buildDrills(),
    };
    if (initialDrillId != null) {
      namedArguments[#initialDrillId] = initialDrillId;
    }
    if (isRecheckLaunchV1) {
      namedArguments[#isRecheckLaunchV1] = true;
    }
    final runner =
        Function.apply(
              CanonicalTerminalSessionDrillSurfacedRunnerV1.new,
              const <dynamic>[],
              namedArguments,
            )
            as Widget;

    await tester.pumpWidget(MaterialApp(home: runner));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpAndSettle();
  }

  testWidgets('normal session launch still starts from the first drill', (
    tester,
  ) async {
    await pumpRunner(tester);

    expect(find.text('FIRST TARGET CONTRACT PROMPT'), findsOneWidget);
    expect(find.text('RECHECK TARGET CONTRACT PROMPT'), findsNothing);
  });

  testWidgets('targeted launch starts at the exact requested drill', (
    tester,
  ) async {
    await pumpRunner(tester, initialDrillId: 'recheck_range_bucket');

    expect(find.text('RECHECK TARGET CONTRACT PROMPT'), findsOneWidget);
    expect(find.text('FIRST TARGET CONTRACT PROMPT'), findsNothing);
  });

  testWidgets('invalid target falls back to the normal first drill', (
    tester,
  ) async {
    await pumpRunner(tester, initialDrillId: 'missing_range_bucket');

    expect(find.text('FIRST TARGET CONTRACT PROMPT'), findsOneWidget);
    expect(find.text('RECHECK TARGET CONTRACT PROMPT'), findsNothing);
  });

  test(
    'recheck launch suppresses normal completion while normal launch preserves it',
    () {
      expect(
        shouldSignalNormalSessionDrillCompletionV1(
          completionAlreadySignaled: false,
          isRecheckLaunchV1: true,
        ),
        isFalse,
      );
      expect(
        shouldSignalNormalSessionDrillCompletionV1(
          completionAlreadySignaled: false,
          isRecheckLaunchV1: false,
        ),
        isTrue,
      );
      expect(
        shouldSignalNormalSessionDrillCompletionV1(
          completionAlreadySignaled: true,
          isRecheckLaunchV1: false,
        ),
        isFalse,
      );
    },
  );

  test(
    'route, payload, dispatch, and completion policy preserve recheck intent',
    () {
      final launcher = File(
        'lib/ui_v2/runner/canonical_launcher_api_v1.dart',
      ).readAsStringSync();
      final hostContract = File(
        'lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart',
      ).readAsStringSync();
      final dispatch = File(
        'lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart',
      ).readAsStringSync();
      final runner = File(
        'lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();

      expect(launcher, contains('String? initialDrillId'));
      expect(launcher, contains('bool isRecheckLaunchV1 = false'));
      expect(hostContract, contains('final String? initialDrillId'));
      expect(hostContract, contains('final bool isRecheckLaunchV1'));
      expect(dispatch, contains('initialDrillId: payload.initialDrillId'));
      expect(
        dispatch,
        contains('isRecheckLaunchV1: payload.isRecheckLaunchV1'),
      );
      expect(runner, contains('resolveInitialSessionDrillIndexV1'));
      expect(runner, contains('shouldSignalNormalSessionDrillCompletionV1'));
      expect(runner, contains('ProgressService.markModuleCompleted'));
      expect(
        runner,
        contains("Telemetry.logEvent('session_drills_complete_v1'"),
      );
    },
  );
}
