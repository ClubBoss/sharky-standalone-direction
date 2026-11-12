import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/features/hst06/personal_hand_v1.dart';
import 'package:poker_analyzer/features/hst06/pokerstars_text_v1.dart';
import 'personal_hand_v1_test.dart' as fixture;

// All records below are synthetic fixtures, never personal user history.
Hst06Preview preview(String id) => Hst06PokerStarsPreview()
    .parse(fixture.source900.replaceFirst('#900:', '#$id:'))
    .single;

Future<void> rejectsWithoutRewrite(List<Hst06Hand> hands) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = jsonEncode({
    'schema': 1,
    'hands': [for (final hand in hands) hand.toJson()],
  });
  expect(await prefs.setString(Hst06PersonalStore.storageKey, raw), isTrue);
  final store = Hst06PersonalStore();
  await expectLater(store.load(), throwsFormatException);
  await expectLater(store.confirm(preview('902')), throwsFormatException);
  await expectLater(
    store.revise(preview('900'), hands.first.localId, 1),
    throwsFormatException,
  );
  expect(prefs.getString(Hst06PersonalStore.storageKey), raw);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('duplicate local IDs fail closed without rewriting bytes', () async {
    final a = preview('900').hand!.persisted('same-id', 1);
    final b = preview('901').hand!.persisted('same-id', 1);
    expect(a.identity, isNot(b.identity));
    expect(a.contentDigest, isNot(b.contentDigest));
    expect(hst06Inspect(a).canSave && hst06Inspect(b).canSave, isTrue);
    await rejectsWithoutRewrite([a, b]);
  });

  test('duplicate identities with distinct facts fail closed', () async {
    final a = preview('900').hand!.persisted('id-a', 1);
    final data = Map<String, dynamic>.from(a.toJson());
    data['localId'] = 'id-b';
    data['title'] = 'Synthetic alternative title';
    final b = Hst06Hand.fromJson(data);
    expect(a.identity, b.identity);
    expect(a.contentDigest, isNot(b.contentDigest));
    expect(hst06Inspect(b).canSave, isTrue);
    await rejectsWithoutRewrite([a, b]);
  });

  test('same content under distinct IDs fails closed', () async {
    final a = preview('900').hand!.persisted('id-a', 1);
    final b = preview('900').hand!.persisted('id-b', 1);
    expect(a.contentDigest, b.contentDigest);
    await rejectsWithoutRewrite([a, b]);
  });

  test(
    'distinct hands load and dedupe and revision semantics survive',
    () async {
      final store = Hst06PersonalStore();
      final a = await store.confirm(preview('900'));
      final b = await store.confirm(preview('901'));
      expect(a.kind, Hst06SaveKind.saved);
      expect(b.kind, Hst06SaveKind.saved);
      expect(await store.load(), hasLength(2));
      expect(
        (await store.confirm(preview('900'))).kind,
        Hst06SaveKind.duplicate,
      );
      expect(
        (await store.revise(preview('900'), a.stored!.localId, 1)).kind,
        Hst06SaveKind.saved,
      );
      expect(
        (await store.revise(preview('900'), a.stored!.localId, 1)).kind,
        Hst06SaveKind.conflict,
      );
      final loaded = await store.load();
      expect(loaded, hasLength(2));
      expect(loaded.first.revision, 2);
      expect(loaded.last.localId, b.stored!.localId);
    },
  );
}
