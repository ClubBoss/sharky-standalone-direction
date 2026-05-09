import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'curriculum lock keeps legacy routes redirected and branch requirements visible',
    () {
      final appRoot = File('lib/ui_v2/app_root.dart').readAsStringSync();
      final map = File(
        'lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart',
      ).readAsStringSync();
      final mainMenu = File(
        'lib/screens/main_menu_screen.dart',
      ).readAsStringSync();
      final goalBanner = File(
        'lib/widgets/user_goal_reengagement_banner.dart',
      ).readAsStringSync();

      expect(appRoot.contains("'/home'"), isTrue);
      expect(appRoot.contains("'/home_screen'"), isTrue);
      expect(appRoot.contains("'/modules'"), isTrue);
      expect(appRoot.contains("'/modules_screen'"), isTrue);
      expect(appRoot.contains("'/training_home'"), isTrue);
      expect(appRoot.contains("'/training'"), isTrue);
      expect(
        appRoot.contains('onGenerateRoute: buildLegacySurfaceRedirectRoute'),
        isTrue,
      );

      expect(map.contains('world1_branch_cash_requirements'), isTrue);
      expect(map.contains('world1_branch_mtt_requirements'), isTrue);

      expect(mainMenu.contains('TrainingHomeScreen('), isFalse);
      expect(goalBanner.contains('TrainingHomeScreen('), isFalse);
    },
  );
}
