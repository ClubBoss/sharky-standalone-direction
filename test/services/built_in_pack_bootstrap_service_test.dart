import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/built_in_pack_bootstrap_service.dart';
import 'package:poker_analyzer/generated/pack_library.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    packLibrary.clear();
    SharedPreferences.setMockInitialValues({});
  });

  test('imports packs when library empty', () async {
    expect(packLibrary.isEmpty, true);
    await BuiltInPackBootstrapService().importIfNeeded();
    expect(packLibrary.isNotEmpty, true);
  });

  test('import is idempotent', () async {
    await BuiltInPackBootstrapService().importIfNeeded();
    final count = packLibrary.length;
    await BuiltInPackBootstrapService().importIfNeeded();
    expect(packLibrary.length, count);
  });
}
