import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/chips_ledger_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('chips ledger pure ops', () {
    test('earn updates balance and earned total deterministically', () {
      const snapshot = ChipsLedgerSnapshotV1(
        balance: 1,
        earnedTotal: 4,
        spentTotal: 2,
      );
      final mutation = earnChipsV1(snapshot, amount: 2);
      expect(mutation.appliedAmount, 2);
      expect(mutation.insufficientFunds, isFalse);
      expect(mutation.after.balance, 3);
      expect(mutation.after.earnedTotal, 6);
      expect(mutation.after.spentTotal, 2);
    });

    test('spend never drives balance negative and flags bankrupt', () {
      const snapshot = ChipsLedgerSnapshotV1(
        balance: 0,
        earnedTotal: 4,
        spentTotal: 2,
      );
      final mutation = spendChipsV1(snapshot, amount: 1);
      expect(mutation.appliedAmount, 0);
      expect(mutation.insufficientFunds, isTrue);
      expect(mutation.after.balance, 0);
      expect(mutation.after.spentTotal, 2);
    });

    test('pricing constants are deterministic', () {
      expect(kChipsStartPackCostV1, 1);
      expect(chipsCompletionRewardForSessionV1(isCheckpoint: false), 2);
      expect(chipsCompletionRewardForSessionV1(isCheckpoint: true), 3);
    });
  });

  group('ProgressService chips ledger persistence', () {
    test('earn and spend persist counters and guard bankrupt spend', () async {
      await ProgressService.debugReset();

      final firstEarn = await ProgressService.earnChipsForSessionCompletionV1(
        isCheckpoint: false,
      );
      expect(firstEarn.appliedAmount, 2);
      expect(firstEarn.after.balance, 2);

      final firstSpend = await ProgressService.spendChipsForSessionStartV1();
      expect(firstSpend.appliedAmount, 1);
      expect(firstSpend.after.balance, 1);

      final checkpointEarn =
          await ProgressService.earnChipsForSessionCompletionV1(
            isCheckpoint: true,
          );
      expect(checkpointEarn.appliedAmount, 3);
      expect(checkpointEarn.after.balance, 4);

      await ProgressService.spendChipsForSessionStartV1();
      await ProgressService.spendChipsForSessionStartV1();
      await ProgressService.spendChipsForSessionStartV1();
      await ProgressService.spendChipsForSessionStartV1();
      final bankruptSpend = await ProgressService.spendChipsForSessionStartV1();
      expect(bankruptSpend.appliedAmount, 0);
      expect(bankruptSpend.insufficientFunds, isTrue);

      final snapshot = await ProgressService.getChipsLedgerSnapshotV1();
      expect(snapshot.balance, 0);
      expect(snapshot.earnedTotal, 5);
      expect(snapshot.spentTotal, 5);
    });

    test(
      'today entry and daily drip use deterministic idempotent txn ids',
      () async {
        await ProgressService.debugReset();
        expect(ProgressService.getTodayEntitlementsV1().todayEntriesPerDay, 1);

        final drip1 = await ProgressService.applyDailyDripTxnV1(
          utcDayKey: '2026-02-24',
        );
        final drip2 = await ProgressService.applyDailyDripTxnV1(
          utcDayKey: '2026-02-24',
        );
        expect(drip1.txnId, 'daily_drip:v1:2026-02-24');
        expect(drip1.applied, isTrue);
        expect(drip1.alreadyApplied, isFalse);
        expect(drip2.applied, isFalse);
        expect(drip2.alreadyApplied, isTrue);

        final today1 = await ProgressService.applyTodayEntryTxnV1(
          utcDayKey: '2026-02-24',
          cohort: 'beginner',
        );
        final today2 = await ProgressService.applyTodayEntryTxnV1(
          utcDayKey: '2026-02-24',
          cohort: 'beginner',
        );
        expect(today1.txnId, 'today_entry:v1:2026-02-24:beginner');
        expect(today1.applied, isTrue);
        expect(today1.alreadyApplied, isFalse);
        expect(today2.applied, isFalse);
        expect(today2.alreadyApplied, isTrue);

        final snapshot = await ProgressService.getChipsLedgerSnapshotV1();
        expect(snapshot.earnedTotal, 1);
        expect(snapshot.spentTotal, 1);
        expect(snapshot.balance, 0);

        final dripNextDay = await ProgressService.applyDailyDripTxnV1(
          utcDayKey: '2026-02-25',
        );
        expect(dripNextDay.applied, isTrue);
        final snapshotNextDay =
            await ProgressService.getChipsLedgerSnapshotV1();
        expect(snapshotNextDay.earnedTotal, 2);
        expect(snapshotNextDay.balance, 1);
      },
    );
  });
}
