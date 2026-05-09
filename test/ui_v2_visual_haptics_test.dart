import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppSettingsService.instance.load();
    UiHapticsV1.resetHandlers();
  });

  test('fire triggers handler when enabled', () async {
    final events = <UiHapticEventV1>[];
    UiHapticsV1.setHandler(UiHapticEventV1.success, () async {
      events.add(UiHapticEventV1.success);
    });
    await AppSettingsService.instance.setHapticsEnabled(true);
    await UiHapticsV1.fire(UiHapticEventV1.success);
    expect(events, [UiHapticEventV1.success]);
  });

  test('fire no-ops when disabled', () async {
    final events = <UiHapticEventV1>[];
    UiHapticsV1.setHandler(UiHapticEventV1.error, () async {
      events.add(UiHapticEventV1.error);
    });
    await AppSettingsService.instance.setHapticsEnabled(false);
    await UiHapticsV1.fire(UiHapticEventV1.error);
    expect(events, isEmpty);
  });
}
