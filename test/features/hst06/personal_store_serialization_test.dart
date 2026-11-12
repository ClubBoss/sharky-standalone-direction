import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/features/hst06/pokerstars_text_v1.dart';
import 'personal_hand_v1_test.dart' as fixture;

// Pause the FIRST writer before its setString. Unlike a two-writer barrier,
// this gate never requires the queued writer to enter the critical section.
class FirstWriteGate {
  FirstWriteGate(this.prefs);
  final SharedPreferences prefs;
  final entered = Completer<void>();
  final release = Completer<void>();
  int calls = 0;
  Future<SharedPreferences> get() async {
    calls++;
    if (calls == 2) {
      entered.complete();
      await release.future;
    }
    return prefs;
  }

  void unblock() {
    if (!release.isCompleted) release.complete();
  }
}

Hst06Preview hand(String id, String pot) => Hst06PokerStarsPreview()
    .parse(
      fixture.source900
          .replaceFirst('#900:', '#$id:')
          .replaceFirst(r'Total pot $0.20', 'Total pot \$$pot'),
    )
    .single;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'two instances serialize distinct confirms without losing a successful hand',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final gate = FirstWriteGate(prefs);
      addTearDown(gate.unblock);
      final a = Hst06PersonalStore(preferences: gate.get);
      final b = Hst06PersonalStore(preferences: gate.get);
      final first = a.confirm(hand('900', '0.20'));
      await gate.entered.future.timeout(const Duration(seconds: 2));
      final second = b.confirm(hand('901', '0.21'));
      int callsBeforeRelease;
      try {
        await Future<void>.delayed(Duration.zero);
        callsBeforeRelease = gate.calls;
      } finally {
        gate.unblock();
      }
      final results = await Future.wait([first, second]);
      expect(
        callsBeforeRelease,
        2,
        reason: 'Second instance must not read before first writer finishes.',
      );
      expect(results.map((r) => r.kind), [
        Hst06SaveKind.saved,
        Hst06SaveKind.saved,
      ]);
      final stored = await Hst06PersonalStore().load();
      expect(stored.map((h) => h.roomHandId).toSet(), {'900', '901'});
      expect(
        stored.map((h) => h.localId).toSet(),
        results.map((r) => r.stored!.localId).toSet(),
      );
    },
  );

  test(
    'two instances revising revision one yield one save and one conflict',
    () async {
      final seed = await Hst06PersonalStore().confirm(hand('900', '0.20'));
      final prefs = await SharedPreferences.getInstance();
      final gate = FirstWriteGate(prefs);
      addTearDown(gate.unblock);
      final a = Hst06PersonalStore(preferences: gate.get);
      final b = Hst06PersonalStore(preferences: gate.get);
      final id = seed.stored!.localId;
      final first = a.revise(hand('900', '0.22'), id, 1);
      await gate.entered.future.timeout(const Duration(seconds: 2));
      final second = b.revise(hand('900', '0.24'), id, 1);
      int callsBeforeRelease;
      try {
        await Future<void>.delayed(Duration.zero);
        callsBeforeRelease = gate.calls;
      } finally {
        gate.unblock();
      }
      final results = await Future.wait([first, second]);
      expect(callsBeforeRelease, 2);
      expect(results.map((r) => r.kind), [
        Hst06SaveKind.saved,
        Hst06SaveKind.conflict,
      ]);
      final stored = (await Hst06PersonalStore().load()).single;
      expect(stored.localId, id);
      expect(stored.revision, 2);
      expect(stored.totalPot, '0.22');
      expect(stored.contentDigest, results.first.stored!.contentDigest);
    },
  );

  test(
    'failed mutation preserves original error and queued instance still runs',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final entered = Completer<void>();
      final release = Completer<void>();
      addTearDown(() {
        if (!release.isCompleted) release.complete();
      });
      final error = StateError('injected preference read failure');
      final firstStore = Hst06PersonalStore(
        preferences: () async {
          entered.complete();
          await release.future;
          throw error;
        },
      );
      final secondStore = Hst06PersonalStore(preferences: () async => prefs);
      final first = firstStore.confirm(hand('900', '0.20'));
      final errorAssertion = expectLater(first, throwsA(same(error)));
      await entered.future.timeout(const Duration(seconds: 2));
      final second = secondStore.confirm(hand('901', '0.21'));
      release.complete();
      await errorAssertion;
      expect((await second).kind, Hst06SaveKind.saved);
      final stored = await Hst06PersonalStore().load();
      expect(stored, hasLength(1));
      expect(stored.single.roomHandId, '901');
    },
  );
}
