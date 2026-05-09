import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('legacy module surfaces are detached and route-guarded', () {
    final appRoot = File('lib/ui_v2/app_root.dart').readAsStringSync();
    final mvs = File(
      'lib/ui/session_player/mvs_player.dart',
    ).readAsStringSync();
    final mainMenu = File(
      'lib/screens/main_menu_screen.dart',
    ).readAsStringSync();
    final goalBanner = File(
      'lib/widgets/user_goal_reengagement_banner.dart',
    ).readAsStringSync();

    expect(appRoot.contains("'/home'"), isTrue);
    expect(appRoot.contains("'/modules'"), isTrue);
    expect(appRoot.contains("'/training_home'"), isTrue);
    expect(
      appRoot.contains('onGenerateRoute: buildLegacySurfaceRedirectRoute'),
      isTrue,
    );
    expect(mvs.contains('ModulesScreen('), isFalse);
    expect(mainMenu.contains('TrainingHomeScreen('), isFalse);
    expect(goalBanner.contains('TrainingHomeScreen('), isFalse);
  });
}
