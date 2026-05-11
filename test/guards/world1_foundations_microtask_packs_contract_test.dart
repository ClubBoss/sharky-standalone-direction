import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';

void main() {
  test(
    'world1 modules have deterministic pack or explicit no-pack coverage',
    () {
      for (final moduleId in kWorld1CanonicalModuleOrder) {
        final hasPack = hasWorld1MicroTaskPack(moduleId);
        final noPack = kWorld1MicroTaskNoPackModules.contains(moduleId);
        expect(
          hasPack || noPack,
          isTrue,
          reason: 'Module $moduleId must declare pack coverage explicitly.',
        );
        if (hasPack) {
          final pack = world1MicroTaskPackFor(moduleId);
          expect(pack.length, inInclusiveRange(3, 12));
        }
      }
    },
  );

  test('world1 act0 opening packs keep distinct task-shape progression', () {
    final tableLiteracy = world1MicroTaskPackFor('world1_act0_table_literacy');
    final actionLiteracy = world1MicroTaskPackFor(
      'world1_act0_action_literacy',
    );
    final streetFlow = world1MicroTaskPackFor('world1_act0_street_flow');

    expect(
      tableLiteracy.every(
        (step) =>
            step.expectedSeatIds.isNotEmpty &&
            (step.allowedActions?.isEmpty ?? true) &&
            step.expectedActionKind == null,
      ),
      isTrue,
      reason: 'The first pack should stay seat-first to anchor the table.',
    );

    expect(
      actionLiteracy.every(
        (step) =>
            (step.allowedActions?.isNotEmpty ?? false) &&
            step.expectedActionKind != null,
      ),
      isTrue,
      reason:
          'The second pack should graduate into real action choices instead of repeating seat taps.',
    );

    expect(
      streetFlow.every(
        (step) =>
            (step.allowedActions?.isNotEmpty ?? false) &&
            step.expectedActionKind != null &&
            step.street != null,
      ),
      isTrue,
      reason:
          'The third pack should feel street-aware, not like another seat-label loop.',
    );

    expect(streetFlow.map((step) => step.street).toSet(), <MicroTaskStreetV1>{
      MicroTaskStreetV1.flop,
      MicroTaskStreetV1.turn,
      MicroTaskStreetV1.river,
    });
  });
}
