import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import '../support/hst06_approot_journey_helpers.dart' as journey;
import 'hst06_review_route_proposal_test.dart' as fixture;

const progressKeys = [
  'act0_shell_progress_v1_head',
  'act0_shell_progress_v1_recovery',
  'act0_shell_progress_v1_backup',
  'act0_shell_progress_v1',
];

Map<String, Object?> envelopes(Map<String, Object?> prefs) => {
  for (final key in progressKeys)
    if (prefs.containsKey(key)) key: jsonDecode(prefs[key] as String),
};

Map<String, Object?> payloads(Map<String, Object?> prefs) => {
  for (final entry in envelopes(prefs).entries)
    entry.key: (entry.value as Map)['payload'] is String
        ? jsonDecode((entry.value as Map)['payload'] as String)
        : entry.value,
};

Future<Map<String, Object?>> runArm(
  WidgetTester tester, {
  required bool useHst,
}) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
  SharedPreferences.setMockInitialValues({'onboardingCompleted': true});
  final start = tester.binding.clock.now();
  await journey.boot(tester);
  await journey.openReview(tester);
  final learningBefore = await journey.youSnapshot(tester);
  final evidenceBefore = journey.evidenceSnapshot(tester);
  final before = await fixture.snapshot();
  Map<String, Object?>? afterCancel;
  if (useHst) {
    await fixture.open(tester);
    await fixture.preview(tester);
    await fixture.tapKey(tester, 'hst06-cancel-0');
    await tester.pageBack();
    await tester.pumpAndSettle();
    afterCancel = await fixture.snapshot();
    await fixture.open(tester);
    await fixture.preview(tester);
    await fixture.tapKey(tester, 'hst06-confirm-0');
    await tester.pageBack();
    await tester.pumpAndSettle();
  }
  // Match the scheduled elapsed widget-test time. AppRoot's production wall
  // clock is not injectable here; record that limit rather than fake its clock.
  final remaining = start
      .add(const Duration(seconds: 60))
      .difference(tester.binding.clock.now());
  expect(remaining.isNegative, isFalse);
  await tester.pump(remaining);
  await tester.pumpAndSettle();
  final evidenceBeforeRemount = journey.evidenceSnapshot(tester);
  final learningBeforeRemount = await journey.youSnapshot(tester);
  final beforeRemount = await fixture.snapshot();
  await tester.pumpWidget(const SizedBox());
  await tester.pumpAndSettle();
  await journey.boot(tester);
  await journey.openReview(tester);
  final immediatelyAfterRemount = await fixture.snapshot();
  int? reentrySavedHandCount;
  if (useHst) {
    // Match the original failing HST arm: reopen saved hands, then Back.
    await fixture.open(tester);
    reentrySavedHandCount = (await Hst06PersonalStore().load()).length;
    print(
      'HST_REMOUNT_REENTRY ${jsonEncode({'savedHandCount': reentrySavedHandCount})}',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
  } else {
    // The control must remain no-HST. Match the settle boundary, not navigation
    // into the feature whose effect this arm is intended to exclude.
    await tester.pumpAndSettle();
  }
  final after = await fixture.snapshot();
  final learningAfter = await journey.youSnapshot(tester);
  final evidenceAfter = journey.evidenceSnapshot(tester);
  final pendingException = tester.takeException();
  // Emit raw maps before decoding envelopes or any semantic assertions, so
  // malformed storage or state divergence cannot erase the diagnostic capture.
  print(
    'HST_REMOUNT_RAW ${jsonEncode({'arm': useHst ? 'hst' : 'no_hst', 'before': before, 'afterCancel': afterCancel, 'beforeRemount': beforeRemount, 'immediatelyAfterRemount': immediatelyAfterRemount, 'afterReentryBoundary': after, 'learningBefore': learningBefore, 'learningBeforeRemount': learningBeforeRemount, 'learningAfter': learningAfter, 'evidenceBefore': evidenceBefore, 'evidenceBeforeRemount': evidenceBeforeRemount, 'evidenceAfter': evidenceAfter, 'pendingException': pendingException?.toString()})}',
  );
  final result = <String, Object?>{
    'arm': useHst ? 'hst' : 'no_hst',
    'before': before,
    'beforeRemount': beforeRemount,
    'afterCancel': afterCancel,
    'immediatelyAfterRemount': immediatelyAfterRemount,
    'afterRemount': after,
    'pendingException': pendingException,
    'reentrySavedHandCount': reentrySavedHandCount,
    'learningBeforeRemount': learningBeforeRemount,
    'evidenceBeforeRemount': evidenceBeforeRemount,
    'addedKeys':
        after.keys.where((key) => !beforeRemount.containsKey(key)).toList()
          ..sort(),
    'envelopes': envelopes(after),
    'logicalPayloads': payloads(after),
    'learningBefore': learningBefore,
    'learningAfter': learningAfter,
    'evidenceBefore': evidenceBefore,
    'evidenceAfter': evidenceAfter,
    'originalFullMapEquality': const DeepCollectionEquality().equals(
      after,
      beforeRemount,
    ),
  };
  // Exact synthetic-only diagnostic data; no field normalization or exclusions.
  print(
    'HST_REMOUNT_CONTROL ${jsonEncode({...result, 'pendingException': pendingException?.toString()})}',
  );
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'paired no-HST and HST returning AppRoot remount compare exact progress envelopes',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final control = await runArm(tester, useHst: false);
      final hst = await runArm(tester, useHst: true);
      // Both arms have emitted complete diagnostics before these assertions.
      for (final arm in [control, hst]) {
        expect(arm['pendingException'], isNull);
        expect(arm['learningBeforeRemount'], arm['learningBefore']);
        expect(arm['evidenceBeforeRemount'], arm['evidenceBefore']);
        expect(arm['learningAfter'], arm['learningBefore']);
        expect(arm['evidenceAfter'], arm['evidenceBefore']);
        final beforeRemount = Map<String, Object?>.from(
          arm['beforeRemount'] as Map,
        );
        if (arm['arm'] == 'hst') {
          expect(arm['reentrySavedHandCount'], 1);
          expect(arm['afterCancel'], arm['before']);
          beforeRemount.remove(Hst06PersonalStore.storageKey);
        }
        expect(beforeRemount, arm['before']);
      }
      expect(hst['addedKeys'], control['addedKeys']);
      final controlPrefs = control['afterRemount'] as Map<String, Object?>;
      final hstPrefs = hst['afterRemount'] as Map<String, Object?>;
      for (final key in progressKeys) {
        expect(hstPrefs.containsKey(key), controlPrefs.containsKey(key));
        expect(
          hstPrefs[key],
          controlPrefs[key],
          reason: 'Exact raw value for $key',
        );
      }
      expect(
        hst['envelopes'],
        control['envelopes'],
        reason:
            'Compare full envelope metadata and payload strings, with no normalization.',
      );
      expect(hst['logicalPayloads'], control['logicalPayloads']);
      expect(hst['learningAfter'], control['learningAfter']);
      expect(hst['evidenceAfter'], control['evidenceAfter']);
    },
  );
}
