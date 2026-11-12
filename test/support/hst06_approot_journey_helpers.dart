import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_review_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';

Map<String, Object?> evidenceSnapshot(WidgetTester tester) {
  final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
  // Read-only existing test APIs; do not call the next-target getter that records an audit transition.
  return jsonDecode(
        jsonEncode({
          'repairOutcomes': state.debugRepairOutcomeProjectionPayloadV1(),
          'conceptEvidence': state.debugConceptFamilyStatePayloadV1(),
          'retention': state.debugDurableRetentionPayloadV1(),
          'repairAudit': state.debugRepairIntentAuditTrailPayloadV1(),
          'openRepairCount': state.debugOpenRepairIntentCountV1(),
          'activeRepair': state.debugActiveRepairContextPayloadV1(),
          'selectedTask': state.debugSelectedTaskIdV1(),
          'selectedWorld': state.debugSelectedWorldIdV1(),
          'selectedLesson': state.debugSelectedLessonIdV1(),
          'phase': state.debugPhaseV1(),
          'selectedOption': state.debugSelectedOptionIdV1(),
        }),
      )
      as Map<String, Object?>;
}

Future<Map<String, Object?>> youSnapshot(WidgetTester tester) async {
  await tester.tap(find.text('You').last);
  await tester.pumpAndSettle();
  final input = tester
      .widget<Act0AcademyYouLeafV1>(find.byType(Act0AcademyYouLeafV1))
      .input;
  final result = <String, Object?>{
    'xpLine': input.xpLine,
    'completedTaskCount': input.completedTaskCount,
    'earnedMomentIds': input.earnedMoments.map((m) => m.seedId).toList(),
    'bankedRepairs': input.bankedRepairCount,
    'reinforcedRepairs': input.reinforcedRepairCount,
    'openRepairs': input.openRepairCount,
    'dueReviews': input.dueReviewCount,
  };
  await openReview(tester);
  return result;
}

Future<void> openReview(WidgetTester tester) async {
  await tester.tap(find.text('Review').last);
  await tester.pumpAndSettle();
  expect(find.byType(Act0AcademyReviewLeafV1), findsOneWidget);
}

Future<void> boot(WidgetTester tester) async {
  await tester.pumpWidget(const AppRoot());
  await tester.pumpAndSettle();
  expect(find.byType(Act0ShellPreviewScreenV1), findsOneWidget);
  final shell = tester.widget<Act0ShellPreviewScreenV1>(
    find.byType(Act0ShellPreviewScreenV1),
  );
  expect(shell.debugHarnessEntry, isNull);
  expect(shell.showPlacementOnStart, isFalse);
}
