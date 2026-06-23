import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/services/session_drill_recheck_launch_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';

Route<void> sessionDrillRecheckLaunchRouteV1(
  SessionDrillRecheckLaunchQueueItemV1 item,
) {
  return canonicalSessionDrillRouteV1(
    sessionId: item.launchSessionId,
    initialDrillId: item.targetDrillId,
    isRecheckLaunchV1: true,
  );
}

Future<void> pushSessionDrillRecheckLaunchV1(
  BuildContext context,
  SessionDrillRecheckLaunchQueueItemV1 item,
) async {
  if (!context.mounted) return;
  await Navigator.of(
    context,
  ).push<void>(sessionDrillRecheckLaunchRouteV1(item));
}
