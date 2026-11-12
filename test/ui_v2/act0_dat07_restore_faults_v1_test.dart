import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_canonical_store_port_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_transfer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

// DAT07 fault tests use the real canonical Store and platform persistence API.
// Payloads are deliberately synthetic, NOT accepted shell schema-19 snapshots.
// These tests neither validate the shell's actual payload nor award any XP.
const _imported =
    '{"schemaVersion":19,"earnedXp":35,'
    '"completedTaskIds":["w1_a"],"completedLessonIds":["guide"],'
    '"learningEvidenceHistory":['
    '{"recordId":"attempt-a","taskId":"w1_a","choiceId":"call",'
    '"assistanceKind":"quickHint","isCorrect":false},'
    '{"recordId":"attempt-b","taskId":"w1_a","choiceId":"fold",'
    '"assistanceKind":"none","isCorrect":true}]}';
const _other =
    '{"schemaVersion":19,"earnedXp":9,'
    '"completedTaskIds":["local"],"completedLessonIds":[],'
    '"learningEvidenceHistory":[]}';

bool _validFixture(String raw) => raw == _imported || raw == _other;

final _codec = Act0Dat07CodecV1(
  isValidProgress: _validFixture,
  supportedProgressSchema: 19,
);

Uint8List _file() =>
    _codec.exportPayload(_imported, exportedAtUtc: DateTime.utc(2026, 11, 9));

String _physical(String key) => 'flutter.$key';

enum _SetFault { persistedFalse, persistedThrow, missingFalse }

// Test-only backend. The plugin cache and physical bytes are distinct; reload
// comes through getAll. No Store or transfer-result behavior is substituted.
class _FaultDisk extends SharedPreferencesStorePlatform {
  final bytes = <String, Object>{};
  final setCalls = <String, int>{};
  final removeCalls = <String, int>{};
  int clearCalls = 0;
  final modes = <String, _SetFault>{};

  String? _readTriggerKey;
  int? _triggeredReadOrdinal;
  int? _readsUntilFailure;
  Map<String, Object> Function(Map<String, Object>)? _readOverlayOnTrigger;
  Map<String, Object> Function(Map<String, Object>)? _pendingReadOverlay;

  void failReadAfterSet(String physicalKey, {required int ordinal}) {
    _readTriggerKey = physicalKey;
    _triggeredReadOrdinal = ordinal;
  }

  void overlayReadAfterSet(
    String physicalKey,
    Map<String, Object> Function(Map<String, Object>) overlay,
  ) {
    _readTriggerKey = physicalKey;
    _readOverlayOnTrigger = overlay;
  }

  @override
  Future<Map<String, Object>> getAll() async {
    final remaining = _readsUntilFailure;
    if (remaining != null) {
      if (remaining == 1) {
        _readsUntilFailure = null;
        throw StateError('DAT07 injected reload failure');
      }
      _readsUntilFailure = remaining - 1;
    }
    final overlay = _pendingReadOverlay;
    if (overlay != null) {
      _pendingReadOverlay = null;
      return overlay(Map<String, Object>.of(bytes));
    }
    return Map<String, Object>.of(bytes);
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    setCalls[key] = (setCalls[key] ?? 0) + 1;
    final mode = modes[key];
    if (mode == _SetFault.missingFalse) return false;

    // A returned false or thrown exception is not a physical rollback.
    bytes[key] = value;
    if (key == _readTriggerKey) {
      _readTriggerKey = null;
      _readsUntilFailure = _triggeredReadOrdinal;
      _pendingReadOverlay = _readOverlayOnTrigger;
    }
    if (mode == _SetFault.persistedFalse) return false;
    if (mode == _SetFault.persistedThrow) {
      throw StateError('DAT07 injected exception after durable write');
    }
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    removeCalls[key] = (removeCalls[key] ?? 0) + 1;
    bytes.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    clearCalls++;
    bytes.clear();
    return true;
  }
}

Act0ProgressStoreV1 _openStore(String key) =>
    Act0ProgressStoreV1(key: key, isValidPayload: _validFixture);

Act0Dat07CanonicalStorePortV1 _port(Act0ProgressStoreV1 store) =>
    Act0Dat07CanonicalStorePortV1(store: store, supportedProgressSchema: 19);

Act0Dat07TransferV1 _transfer(Act0ProgressStoreV1 store) =>
    Act0Dat07TransferV1(codec: _codec, port: _port(store));

void _expectPhysicalCopies(
  _FaultDisk disk,
  Act0ProgressStoreV1 store,
  int revision,
  String? payload,
) {
  final raw = Act0ProgressStoreV1.debugEnvelopeV1(revision, payload);
  for (final key in [store.headKey, store.recoveryKey, store.backupKey]) {
    expect(disk.bytes[_physical(key)], raw, reason: key);
  }
}

Map<String, Object> _mutationCounts(_FaultDisk disk) => {
  'set': Map<String, int>.of(disk.setCalls),
  'remove': Map<String, int>.of(disk.removeCalls),
  'clear': disk.clearCalls,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var serial = 0;
  late _FaultDisk disk;
  late Act0ProgressStoreV1 store;
  late Act0Dat07TransferV1 transfer;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    disk = _FaultDisk();
    SharedPreferencesStorePlatform.instance = disk;
    store = _openStore('dat07_restore_faults_${serial++}');
    transfer = _transfer(store);
  });

  tearDown(() async {
    await store.flush();
    SharedPreferences.setMockInitialValues({});
  });

  for (final mode in [_SetFault.persistedFalse, _SetFault.persistedThrow]) {
    test('DAT07 $mode landed head is verified by the real Store', () async {
      disk.modes[_physical(store.headKey)] = mode;
      final preview = await transfer.inspect(_file());

      expect(
        await transfer.confirm(preview),
        Act0Dat07RestoreOutcomeV1.restored,
      );
      expect(store.isWriteLeaseCurrent, isFalse);
      final remounted = _openStore(store.key);
      expect(await remounted.readDurableSnapshot(), (
        revision: 1,
        payload: _imported,
      ));
      _expectPhysicalCopies(disk, store, 1, _imported);
    });

    test(
      'DAT07 $mode landed backup with failed reload remains uncertain',
      () async {
        disk.modes[_physical(store.backupKey)] = mode;
        disk.failReadAfterSet(_physical(store.backupKey), ordinal: 1);
        final preview = await transfer.inspect(_file());

        expect(
          await transfer.confirm(preview),
          Act0Dat07RestoreOutcomeV1.notVerified,
        );
        expect(store.isWriteLeaseCurrent, isFalse);
        // All copies physically landed, despite the unverified result.
        _expectPhysicalCopies(disk, store, 1, _imported);
        expect(await _openStore(store.key).readDurableSnapshot(), (
          revision: 1,
          payload: _imported,
        ));
      },
    );
  }

  test(
    'DAT07 missing backup acknowledgement heals on next canonical read',
    () async {
      disk.modes[_physical(store.backupKey)] = _SetFault.missingFalse;
      expect(
        await transfer.confirm(await transfer.inspect(_file())),
        Act0Dat07RestoreOutcomeV1.notVerified,
      );
      expect(disk.bytes.containsKey(_physical(store.backupKey)), isFalse);
      expect(disk.bytes.containsKey(_physical(store.recoveryKey)), isTrue);
      disk.modes.clear();

      // DAT06 resolver, not the legacy mirror, heals the surviving checkpoint.
      final remounted = _openStore(store.key);
      expect(await remounted.readDurableSnapshot(), (
        revision: 1,
        payload: _imported,
      ));
      _expectPhysicalCopies(disk, store, 1, _imported);
    },
  );

  test('DAT07 Store post-commit reload failure is not a rollback', () async {
    disk.failReadAfterSet(_physical(store.key), ordinal: 1);
    expect(
      await transfer.confirm(await transfer.inspect(_file())),
      Act0Dat07RestoreOutcomeV1.notVerified,
    );
    _expectPhysicalCopies(disk, store, 1, _imported);
    expect(await _openStore(store.key).readDurableSnapshot(), (
      revision: 1,
      payload: _imported,
    ));
  });

  test(
    'DAT07 transfer final verification read failure is not success',
    () async {
      // The first read verifies the Store commit. The transfer's next canonical
      // read fails, so even a committed Store ACK is not a restored UI verdict.
      disk.failReadAfterSet(_physical(store.key), ordinal: 2);
      expect(
        await transfer.confirm(await transfer.inspect(_file())),
        Act0Dat07RestoreOutcomeV1.notVerified,
      );
      expect(store.isWriteLeaseCurrent, isFalse);
      expect(await _openStore(store.key).readDurableSnapshot(), (
        revision: 1,
        payload: _imported,
      ));
    },
  );

  test('DAT07 verification cannot accept a stale revision read', () async {
    disk.overlayReadAfterSet(_physical(store.key), (actual) {
      for (final key in [store.headKey, store.recoveryKey, store.backupKey]) {
        actual.remove(_physical(key));
      }
      // Physical checkpoints still exist. This reload reports only the
      // legacy mirror, making a false revision-0 view of the import.
      return actual;
    });
    expect(
      await transfer.confirm(await transfer.inspect(_file())),
      Act0Dat07RestoreOutcomeV1.notVerified,
    );
    expect(await _openStore(store.key).readDurableSnapshot(), (
      revision: 1,
      payload: _imported,
    ));
    _expectPhysicalCopies(disk, store, 1, _imported);
  });

  test('DAT07 verification cannot accept mismatched payload bytes', () async {
    disk.overlayReadAfterSet(_physical(store.key), (actual) {
      final mismatch = Act0ProgressStoreV1.debugEnvelopeV1(1, _other);
      for (final key in [store.headKey, store.recoveryKey, store.backupKey]) {
        actual[_physical(key)] = mismatch;
      }
      return actual;
    });
    expect(
      await transfer.confirm(await transfer.inspect(_file())),
      Act0Dat07RestoreOutcomeV1.notVerified,
    );
    expect(await _openStore(store.key).readDurableSnapshot(), (
      revision: 1,
      payload: _imported,
    ));
    _expectPhysicalCopies(disk, store, 1, _imported);
  });

  test(
    'DAT07 indeterminate commit fences old and already-queued writers',
    () async {
      final oldWriter = _openStore(store.key);
      final expected = await _port(store).readDurableSnapshot();
      disk.modes[_physical(store.backupKey)] = _SetFault.missingFalse;

      // These operations are enqueued before the restore completes. Their
      // instances were created before the lease epoch advances inside commit.
      // Call the synchronous enqueue entry point on the actual Store: an async
      // port wrapper would make the scheduling order less explicit in this case.
      final restoring = store.restoreIfUnchanged(
        expected: expected,
        incomingPayload: _imported,
        supportedProgressSchema: 19,
      );
      final queuedOldSave = oldWriter.save(_other);
      final queuedStoreSave = store.save(_other);
      final queuedOldClear = oldWriter.clear();

      expect(await restoring, Act0ProgressRestoreResultV1.unverified);
      expect(await queuedOldSave, isFalse);
      expect(await queuedStoreSave, isFalse);
      expect(await queuedOldClear, isFalse);
      expect(store.isWriteLeaseCurrent, isFalse);
      expect(oldWriter.isWriteLeaseCurrent, isFalse);
      expect(await store.save(_other), isFalse);
      expect(await oldWriter.clear(), isFalse);

      disk.modes.clear();
      final remounted = _openStore(store.key);
      expect(remounted.isWriteLeaseCurrent, isTrue);
      expect(await remounted.readDurableSnapshot(), (
        revision: 1,
        payload: _imported,
      ));
      _expectPhysicalCopies(disk, store, 1, _imported);
    },
  );

  test(
    'DAT07 retry after uncertain landing is read-only and XP-idempotent',
    () async {
      disk.modes[_physical(store.backupKey)] = _SetFault.missingFalse;
      final originalPreview = await transfer.inspect(_file());
      expect(
        await transfer.confirm(originalPreview),
        Act0Dat07RestoreOutcomeV1.notVerified,
      );
      disk.modes.clear();
      final remounted = _openStore(store.key);
      final retry = _transfer(remounted);
      final actual = await remounted.readDurableSnapshot();
      expect(actual, (revision: 1, payload: _imported));
      final beforeRetryMutations = _mutationCounts(disk);

      for (var retryNumber = 0; retryNumber < 3; retryNumber++) {
        final preview = await retry.inspect(_file());
        expect(preview.alreadyPresent, isTrue);
        expect(
          await retry.confirm(preview),
          Act0Dat07RestoreOutcomeV1.alreadyPresent,
        );
        expect(await remounted.readDurableSnapshot(), actual);
      }
      expect(
        await transfer.confirm(originalPreview),
        Act0Dat07RestoreOutcomeV1.conflict,
      );
      final value = jsonDecode((await remounted.load())!) as Map;
      expect(value['earnedXp'], 35);
      expect(value['completedTaskIds'], ['w1_a']);
      final records = value['learningEvidenceHistory'] as List;
      expect(records.map((r) => (r as Map)['recordId']).toList(), [
        'attempt-a',
        'attempt-b',
      ]);
      expect(_mutationCounts(disk), beforeRetryMutations);
    },
  );

  test('DAT07 restored checkpoints preserve DAT06 reset tombstone', () async {
    disk.modes[_physical(store.backupKey)] = _SetFault.missingFalse;
    expect(
      await transfer.confirm(await transfer.inspect(_file())),
      Act0Dat07RestoreOutcomeV1.notVerified,
    );
    disk.modes.clear();
    final remounted = _openStore(store.key);
    expect(await remounted.readDurableSnapshot(), (
      revision: 1,
      payload: _imported,
    ));
    expect(await remounted.clear(), isTrue);
    expect(await remounted.loadState(), (payload: null, isReset: true));
    _expectPhysicalCopies(disk, store, 2, null);

    // A stale valid legacy XP snapshot cannot resurrect across a tombstone.
    disk.bytes[_physical(store.key)] = _imported;
    final anotherReader = _openStore(store.key);
    expect(await anotherReader.readDurableSnapshot(), (
      revision: 2,
      payload: null,
    ));
    expect((await anotherReader.loadState()).isReset, isTrue);
    _expectPhysicalCopies(disk, store, 2, null);
  });

  test(
    'DAT07 Store uses DAT06 recovery intent and resumable tombstone',
    () async {
      // Synthetic preexisting corruption: only explicit DAT06 recovery consent
      // may replace it; a failed intermediate write must not expose old XP.
      disk.bytes[_physical(store.headKey)] = '{invalid-head';
      disk.bytes[_physical(store.recoveryKey)] =
          Act0ProgressStoreV1.debugEnvelopeV1(4, _imported);
      disk.bytes[_physical(store.backupKey)] =
          Act0ProgressStoreV1.debugEnvelopeV1(2, _other);
      disk.bytes[_physical(store.key)] = _imported;

      final proposal = await store.inspectRecovery();
      disk.modes[_physical(store.backupKey)] = _SetFault.missingFalse;
      expect(
        await store.confirmRecoveryOutcome(proposal),
        Act0RecoveryConfirmationOutcomeV1.notVerified,
      );
      expect(
        disk.bytes.containsKey(_physical(store.recoveryIntentKey)),
        isTrue,
      );
      expect(disk.bytes.containsKey(_physical(store.damagedCopyKey)), isTrue);
      await expectLater(store.loadState(), throwsA(isA<Act0RecoveryHoldV1>()));
      expect(await store.save(_other), isFalse);

      disk.modes.clear();
      final remounted = _openStore(store.key);
      expect(await remounted.loadState(), (payload: null, isReset: true));
      expect(await remounted.readDurableSnapshot(), (
        revision: 5,
        payload: null,
      ));
      _expectPhysicalCopies(disk, store, 5, null);
      expect(
        disk.bytes.containsKey(_physical(store.recoveryIntentKey)),
        isFalse,
      );
      expect(disk.bytes.containsKey(_physical(store.key)), isFalse);
      expect(disk.bytes.containsKey(_physical(store.damagedCopyKey)), isTrue);
      expect(await store.save(_imported), isFalse);
    },
  );
}
