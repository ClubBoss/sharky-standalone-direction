import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'W8-W12 hidden owners are evidence-only and cannot override Act0 runtime',
    () {
      const hiddenOwners = <String>[
        'act0_w8_stack_depth_hidden_runtime_session_owner_v1.dart',
        'act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart',
        'act0_w10_bet_purpose_hidden_runtime_session_owner_v1.dart',
        'act0_w11_board_texture_hidden_runtime_session_owner_v1.dart',
        'act0_w12_review_decision_hidden_runtime_session_owner_v1.dart',
      ];
      const root = 'lib/ui_v2/act0_shell/';
      final canonicalRuntime = File(
        '${root}act0_shell_preview_screen_v1.dart',
      ).readAsStringSync();

      for (final owner in hiddenOwners) {
        final source = File('$root$owner').readAsStringSync();
        expect(source, contains('HiddenRuntimeSessionOwnerV1'));
        expect(
          canonicalRuntime.contains(owner),
          isFalse,
          reason:
              '$owner is capture/evidence-only and must not become a hidden runtime override.',
        );
      }
    },
  );
}
