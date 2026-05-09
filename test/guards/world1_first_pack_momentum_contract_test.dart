import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';

void main() {
  test(
    'early World 1 momentum copy carries seat map into action and street flow',
    () {
      final actionCopy = resolveWorld1EarlyPackMomentumPreludeCopyV1(
        'world1_act0_action_literacy',
      );
      final streetCopy = resolveWorld1EarlyPackMomentumPreludeCopyV1(
        'world1_act0_street_flow',
      );

      expect(actionCopy, isNotNull);
      expect(actionCopy!.setupLine, contains('seat map you just learned'));
      expect(
        actionCopy.supportLine,
        contains('Button and the blinds are clear'),
      );
      expect(
        actionCopy.supportLine,
        contains('move one seat clockwise to the next actor'),
      );

      expect(streetCopy, isNotNull);
      expect(streetCopy!.setupLine, contains('same seat order'));
      expect(streetCopy.supportLine, contains('once you know who acts next'));
      expect(streetCopy.supportLine, contains('read the new street'));

      expect(
        resolveWorld1EarlyPackMomentumPreludeCopyV1(
          'world1_act0_table_literacy',
        ),
        isNull,
      );
    },
  );
}
