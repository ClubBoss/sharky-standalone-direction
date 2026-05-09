import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/app_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppSettingsService.debugCheckpointModeOverrideV1 = null;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    AppSettingsService.debugCheckpointModeOverrideV1 = null;
  });

  test('non-checkpoint clamps engine v2 backend setting to false', () async {
    AppSettingsService.debugCheckpointModeOverrideV1 = false;
    final service = AppSettingsService.instance;
    await service.load();

    await service.setEngineV2BackendEnabledV1(true);

    expect(service.isCheckpointModeV1, isFalse);
    expect(service.engineV2BackendEnabledV1, isFalse);
    expect(service.snapshot.engineV2BackendEnabledV1, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('engine_v2_backend_enabled_v1'), isFalse);
  });

  test('checkpoint mode allows enabling engine v2 backend', () async {
    AppSettingsService.debugCheckpointModeOverrideV1 = true;
    final service = AppSettingsService.instance;
    await service.load();

    await service.setEngineV2BackendEnabledV1(true);

    expect(service.isCheckpointModeV1, isTrue);
    expect(service.engineV2BackendEnabledV1, isTrue);
    expect(service.snapshot.engineV2BackendEnabledV1, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('engine_v2_backend_enabled_v1'), isTrue);
  });

  test('persisted true is reset to false outside checkpoint mode', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'engine_v2_backend_enabled_v1': true,
    });
    AppSettingsService.debugCheckpointModeOverrideV1 = false;
    final service = AppSettingsService.instance;
    await service.load();

    expect(service.engineV2BackendEnabledV1, isFalse);
    expect(service.snapshot.engineV2BackendEnabledV1, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('engine_v2_backend_enabled_v1'), isFalse);
  });
}
