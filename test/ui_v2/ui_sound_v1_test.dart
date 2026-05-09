import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/core/services/audio_service.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const soundKey = 'settings_sound_enabled';

  setUp(() async {
    SharedPreferences.setMockInitialValues({soundKey: false});
    await AppSettingsService.instance.load();
    UiSoundV1.resetHandler();
  });

  tearDown(() {
    UiSoundV1.resetHandler();
    AudioService.onTestPlayUiSfx = null;
  });

  test('UiSoundV1 exposes events and respects AppSettingsService', () async {
    expect(
      UiSoundEventV1.values,
      containsAll([UiSoundEventV1.tap, UiSoundEventV1.success]),
    );

    final captured = <UiSoundEventV1>[];
    UiSoundV1.overrideHandler(captured.add);

    UiSoundV1.fire(UiSoundEventV1.success);
    expect(
      captured,
      isEmpty,
      reason: 'sound-disabled state should keep handler dormant',
    );

    await AppSettingsService.instance.setSoundEnabled(true);

    UiSoundV1.fire(UiSoundEventV1.tap);
    expect(
      captured,
      equals([UiSoundEventV1.tap]),
      reason: 'enabled state should reach overridden handler',
    );

    UiSoundV1.resetHandler();
    final audioCaptured = <String>[];
    AudioService.onTestPlayUiSfx = audioCaptured.add;

    UiSoundV1.fire(UiSoundEventV1.success);
    expect(
      audioCaptured,
      equals(['success']),
      reason: 'Default sink should route to AudioService when enabled',
    );
  });
}
