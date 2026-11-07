import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _BlockedHeal extends SharedPreferencesStorePlatform {
  _BlockedHeal(this.values);
  final Map<String, Object> values;

  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);

  @override
  Future<bool> setValue(String type, String key, Object value) async => false;

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> clear() async => false;
}

void main() {
  for (final survivor in ['recovery', 'backup']) {
    test('DAT04 unreadable twin cannot expose lone $survivor proof', () async {
      SharedPreferences.setMockInitialValues({});
      final raw = Act0ProgressStoreV1.debugEnvelopeV1(2, '{"xp":20}');
      final disk = _BlockedHeal({'flutter.p_$survivor': raw});
      SharedPreferencesStorePlatform.instance = disk;
      final store = Act0ProgressStoreV1(key: 'p', isValidPayload: (_) => true);
      await expectLater(store.load(), throwsA(isA<FormatException>()));
      expect(await store.save('{"xp":30}'), isFalse);
      expect(await store.clear(), isFalse);
      expect(disk.values, {'flutter.p_$survivor': raw});
    });
  }
}
