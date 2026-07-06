import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/services/session_drill_recheck_user_launch_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';

void main() {
  const item = SessionDrillRecheckLaunchQueueItemV1(
    queueKind: 'session_drill_recheck',
    jobId: 'session_drill_recheck:w6.s01:classify_missed_low_cards_no_draw',
    launchSessionId: 'w6.s01',
    sourceWorldId: 'world_6',
    sourceSessionId: 'w6.s01',
    sourceDrillId: 'classify_missed_overcards_no_draw',
    drillFamilyId: 'range_bucket_board_fit_classifier_v1',
    missedSignalId: 'range_bucket_missed',
    missedSignalLabel: 'Missed range bucket',
    chosenActionId: 'strong',
    expectedActionId: 'missed',
    targetSessionId: 'w6.s01',
    targetDrillId: 'classify_missed_low_cards_no_draw',
    targetKind: 'same_signal_recheck',
    errorClass: 'range_bucket_mismatch',
  );

  testWidgets(
    'route consumer passes queue target identity to canonical session drill route',
    (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final route =
          sessionDrillRecheckLaunchRouteV1(item) as MaterialPageRoute<void>;
      final built = route.builder(capturedContext) as CanonicalLauncherV1;

      expect(built.family, CanonicalLauncherFamilyV1.sessionDrill);
      expect(built.sessionId, item.launchSessionId);
      expect(built.initialDrillId, item.targetDrillId);
      expect(built.isRecheckLaunchV1, isTrue);
    },
  );
}
