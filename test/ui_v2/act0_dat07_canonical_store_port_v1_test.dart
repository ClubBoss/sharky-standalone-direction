import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_canonical_store_port_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_dat07_transfer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';

// Synthetic storage-protocol fixtures ONLY, not accepted learner snapshots.
// Product integration must inject the real shell validator and separately
// exercise authentic schema-19 snapshots. These tests do not prove that schema.
const a = '{"schemaVersion":19,"fixture":"a"}';
const b = '{"schemaVersion":19,"fixture":"b"}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var sequence = 0;
  late Act0ProgressStoreV1 store;
  late Act0Dat07CanonicalStorePortV1 port;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = Act0ProgressStoreV1(
      key: 'dat07_store_fixture_${sequence++}',
      isValidPayload: (raw) => raw == a || raw == b,
    );
    port = Act0Dat07CanonicalStorePortV1(
      store: store,
      supportedProgressSchema: 19,
    );
  });

  test(
    'real store commits exact bytes and fences previously created writers',
    () async {
      final oldWriter = Act0ProgressStoreV1(
        key: store.key,
        isValidPayload: (raw) => raw == a || raw == b,
      );
      final expected = await port.readDurableSnapshot();
      final restoring = port.restoreIfUnchanged(
        expected: expected,
        incomingPayload: a,
      );
      final pendingOldSave = oldWriter.save(b);
      expect(await restoring, Act0Dat07WriteResultV1.committed);
      expect(await pendingOldSave, isFalse);
      expect(store.isWriteLeaseCurrent, isFalse);
      expect(await store.clear(), isFalse);
      expect(await port.readDurableSnapshot(), (revision: 1, payload: a));
      final remounted = Act0ProgressStoreV1(
        key: store.key,
        isValidPayload: (raw) => raw == a || raw == b,
      );
      expect(await remounted.load(), a);
      expect(await remounted.save(b), isTrue);
    },
  );

  test('empty-reset-empty invalidates the pre-reset preview', () async {
    final expected = await port.readDurableSnapshot();
    expect(await store.clear(), isTrue);
    expect(store.isWriteLeaseCurrent, isFalse);
    expect(
      await port.restoreIfUnchanged(
        expected: (revision: 0, payload: null),
        incomingPayload: a,
      ),
      Act0Dat07WriteResultV1.unverified,
      reason: 'A pre-reset Store never regains its write lease',
    );
    store = Act0ProgressStoreV1(
      key: store.key,
      isValidPayload: (raw) => raw == a || raw == b,
    );
    port = Act0Dat07CanonicalStorePortV1(
      store: store,
      supportedProgressSchema: 19,
    );
    expect(
      await port.restoreIfUnchanged(expected: expected, incomingPayload: a),
      Act0Dat07WriteResultV1.changed,
    );
    expect(await port.readDurableSnapshot(), (revision: 1, payload: null));
  });

  test('A-B-A rejects stale revision even with identical payload', () async {
    expect(await store.save(a), isTrue);
    final expected = await port.readDurableSnapshot();
    expect(await store.save(b), isTrue);
    expect(await store.save(a), isTrue);
    expect(
      await port.restoreIfUnchanged(expected: expected, incomingPayload: a),
      Act0Dat07WriteResultV1.changed,
    );
    expect(await port.readDurableSnapshot(), (revision: 3, payload: a));
  });

  test('same revision but different expected payload is rejected', () async {
    expect(
      await port.restoreIfUnchanged(
        expected: (revision: 0, payload: a),
        incomingPayload: b,
      ),
      Act0Dat07WriteResultV1.changed,
    );
    expect(await port.readDurableSnapshot(), (revision: 0, payload: null));
  });

  test('nonempty differing local progress is never overwritten', () async {
    expect(await store.save(a), isTrue);
    final expected = await port.readDurableSnapshot();
    expect(
      await port.restoreIfUnchanged(expected: expected, incomingPayload: b),
      Act0Dat07WriteResultV1.changed,
    );
    expect(await port.readDurableSnapshot(), expected);
  });

  test(
    'invalid payload and unsupported schema never acquire write fence',
    () async {
      final expected = await port.readDurableSnapshot();
      for (final incoming in [
        'broken',
        '{"schemaVersion":19}',
        '{"schemaVersion":20,"fixture":"a"}',
      ]) {
        expect(
          await port.restoreIfUnchanged(
            expected: expected,
            incomingPayload: incoming,
          ),
          Act0Dat07WriteResultV1.unverified,
        );
      }
      final incompatible = Act0Dat07CanonicalStorePortV1(
        store: store,
        supportedProgressSchema: 20,
      );
      expect(
        await incompatible.restoreIfUnchanged(
          expected: expected,
          incomingPayload: a,
        ),
        Act0Dat07WriteResultV1.unverified,
      );
      expect(store.isWriteLeaseCurrent, isTrue);
      expect(await port.readDurableSnapshot(), expected);
    },
  );

  test('fresh tombstone consent increments destination revision', () async {
    expect(await store.clear(), isTrue);
    expect(store.isWriteLeaseCurrent, isFalse);
    expect(
      await port.restoreIfUnchanged(
        expected: (revision: 0, payload: null),
        incomingPayload: a,
      ),
      Act0Dat07WriteResultV1.unverified,
      reason: 'A pre-reset Store never regains its write lease',
    );
    store = Act0ProgressStoreV1(
      key: store.key,
      isValidPayload: (raw) => raw == a || raw == b,
    );
    port = Act0Dat07CanonicalStorePortV1(
      store: store,
      supportedProgressSchema: 19,
    );
    final expected = await port.readDurableSnapshot();
    expect(
      await port.restoreIfUnchanged(expected: expected, incomingPayload: a),
      Act0Dat07WriteResultV1.committed,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    for (final key in [store.headKey, store.recoveryKey, store.backupKey]) {
      final checkpoint = jsonDecode(prefs.getString(key)!) as Map;
      expect(checkpoint['revision'], 2);
      expect(checkpoint['payload'], a);
    }
  });

  test(
    'pending recovery intent blocks restore without overwriting it',
    () async {
      final expected = await port.readDurableSnapshot();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        store.recoveryIntentKey,
        'synthetic pending intent',
      );
      expect(
        await port.restoreIfUnchanged(expected: expected, incomingPayload: a),
        Act0Dat07WriteResultV1.unverified,
      );
      await prefs.reload();
      expect(
        prefs.getString(store.recoveryIntentKey),
        'synthetic pending intent',
      );
      expect(prefs.containsKey(store.headKey), isFalse);
      expect(store.isWriteLeaseCurrent, isTrue);
    },
  );
}
