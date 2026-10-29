import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_gate_v1.dart';
import 'act0_f9_placement_repair_persistence_v1_test.dart' as f9;
import 'act0_placement_quick_check_seat_focus_test.dart' as f2;
import 'act0_welcome_teaching_handoff_test.dart' as f3;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    if (kAct0F7TableScenePreview)
      await Act0SceneProfileGateV1.premiumStore.warmUp();
  });
  // Execute the accepted source-contract tests against the registered preview.
  // No alternate assertions, fixtures, callback or persistence implementation.
  f9.main();
  f2.main();
  f3.main();
}
