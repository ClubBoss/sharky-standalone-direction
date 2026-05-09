import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('w5.s01-w5.s10 use board-texture classifier runtime truth', (
    tester,
  ) async {
    final adapter = const DrillRuntimeAdapterV1();

    final w5s01 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s01'),
    ))!;
    expect(w5s01.map((item) => item.drillId).toList(), <String>[
      'classify_texture_intro_dry_raise_v1',
      'classify_texture_intro_wet_call_v1',
      'classify_texture_intro_paired_fold_v1',
    ]);
    expect(
      w5s01.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s01.first.spec.boardTextureV1, 'dry');
    expect(w5s01.first.spec.expectedActionV1, 'raise');
    expect(w5s01[1].spec.boardTextureV1, 'wet');
    expect(w5s01[1].spec.expectedActionV1, 'call');
    expect(w5s01.last.spec.boardTextureV1, 'paired');
    expect(w5s01.last.spec.expectedActionV1, 'fold');

    final w5s02 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s02'),
    ))!;
    expect(w5s02.map((item) => item.drillId).toList(), <String>[
      'classify_dry_discipline_high_card_raise_v1',
      'classify_dry_discipline_paired_call_v1',
      'classify_dry_discipline_trap_fold_v1',
    ]);
    expect(
      w5s02.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s02.first.spec.boardTextureV1, 'high_card');
    expect(w5s02.first.spec.expectedActionV1, 'raise');
    expect(w5s02[1].spec.boardTextureV1, 'paired');
    expect(w5s02[1].spec.expectedActionV1, 'call');
    expect(w5s02.last.spec.boardTextureV1, 'dry');
    expect(w5s02.last.spec.expectedActionV1, 'fold');

    final w5s03 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s03'),
    ))!;
    expect(w5s03.map((item) => item.drillId).toList(), <String>[
      'classify_wet_protection_connected_call_v1',
      'classify_wet_protection_wet_fold_v1',
      'classify_wet_protection_connected_raise_v1',
    ]);
    expect(
      w5s03.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s03.first.spec.boardTextureV1, 'connected');
    expect(w5s03.first.spec.expectedActionV1, 'call');
    expect(w5s03[1].spec.boardTextureV1, 'wet');
    expect(w5s03[1].spec.expectedActionV1, 'fold');
    expect(w5s03.last.spec.boardTextureV1, 'connected');
    expect(w5s03.last.spec.expectedActionV1, 'raise');

    final w5s04 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s04'),
    ))!;
    expect(w5s04.map((item) => item.drillId).toList(), <String>[
      'classify_turn_shift_connected_raise_v1',
      'classify_turn_shift_wet_call_v1',
      'classify_turn_shift_paired_fold_v1',
    ]);
    expect(
      w5s04.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s04.first.spec.boardTextureV1, 'connected');
    expect(w5s04.first.spec.expectedActionV1, 'raise');
    expect(w5s04[1].spec.boardTextureV1, 'wet');
    expect(w5s04[1].spec.expectedActionV1, 'call');
    expect(w5s04.last.spec.boardTextureV1, 'paired');
    expect(w5s04.last.spec.expectedActionV1, 'fold');

    final w5s05 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s05'),
    ))!;
    expect(w5s05.map((item) => item.drillId).toList(), <String>[
      'classify_river_closure_wet_raise_v1',
      'classify_river_closure_connected_call_v1',
      'classify_river_closure_dry_fold_v1',
    ]);
    expect(
      w5s05.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s05.first.spec.boardTextureV1, 'wet');
    expect(w5s05.first.spec.expectedActionV1, 'raise');
    expect(w5s05[1].spec.boardTextureV1, 'connected');
    expect(w5s05[1].spec.expectedActionV1, 'call');
    expect(w5s05.last.spec.boardTextureV1, 'dry');
    expect(w5s05.last.spec.expectedActionV1, 'fold');

    final w5s06 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s06'),
    ))!;
    expect(w5s06.map((item) => item.drillId).toList(), <String>[
      'classify_in_position_dry_raise_v1',
      'classify_in_position_wet_call_v1',
      'classify_in_position_connected_raise_v1',
    ]);
    expect(
      w5s06.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s06.first.spec.boardTextureV1, 'dry');
    expect(w5s06.first.spec.expectedActionV1, 'raise');
    expect(w5s06[1].spec.boardTextureV1, 'wet');
    expect(w5s06[1].spec.expectedActionV1, 'call');
    expect(w5s06.last.spec.boardTextureV1, 'connected');
    expect(w5s06.last.spec.expectedActionV1, 'raise');

    final w5s07 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s07'),
    ))!;
    expect(w5s07.map((item) => item.drillId).toList(), <String>[
      'classify_oop_dry_call_v1',
      'classify_oop_wet_fold_v1',
      'classify_oop_connected_call_v1',
    ]);
    expect(
      w5s07.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s07.first.spec.boardTextureV1, 'dry');
    expect(w5s07.first.spec.expectedActionV1, 'call');
    expect(w5s07[1].spec.boardTextureV1, 'wet');
    expect(w5s07[1].spec.expectedActionV1, 'fold');
    expect(w5s07.last.spec.boardTextureV1, 'connected');
    expect(w5s07.last.spec.expectedActionV1, 'call');

    final w5s08 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s08'),
    ))!;
    expect(w5s08.map((item) => item.drillId).toList(), <String>[
      'classify_draw_completion_wet_raise_v1',
      'classify_draw_completion_connected_call_v1',
      'classify_draw_completion_dry_fold_v1',
    ]);
    expect(
      w5s08.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s08.first.spec.boardTextureV1, 'wet');
    expect(w5s08.first.spec.expectedActionV1, 'raise');
    expect(w5s08[1].spec.boardTextureV1, 'connected');
    expect(w5s08[1].spec.expectedActionV1, 'call');
    expect(w5s08.last.spec.boardTextureV1, 'dry');
    expect(w5s08.last.spec.expectedActionV1, 'fold');

    final w5s09 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s09'),
    ))!;
    expect(w5s09.map((item) => item.drillId).toList(), <String>[
      'classify_blocker_context_connected_raise_v1',
      'classify_blocker_context_paired_call_v1',
      'classify_blocker_context_high_card_fold_v1',
    ]);
    expect(
      w5s09.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s09.first.spec.boardTextureV1, 'connected');
    expect(w5s09.first.spec.expectedActionV1, 'raise');
    expect(w5s09[1].spec.boardTextureV1, 'paired');
    expect(w5s09[1].spec.expectedActionV1, 'call');
    expect(w5s09.last.spec.boardTextureV1, 'high_card');
    expect(w5s09.last.spec.expectedActionV1, 'fold');

    final w5s10 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w5.s10'),
    ))!;
    expect(w5s10.map((item) => item.drillId).toList(), <String>[
      'classify_texture_synthesis_dry_raise_v1',
      'classify_texture_synthesis_connected_call_v1',
      'classify_texture_synthesis_wet_fold_v1',
    ]);
    expect(
      w5s10.every(
        (item) => item.spec.kind == DrillKindV1.boardTextureClassifier,
      ),
      isTrue,
    );
    expect(w5s10.first.spec.boardTextureV1, 'dry');
    expect(w5s10.first.spec.expectedActionV1, 'raise');
    expect(w5s10[1].spec.boardTextureV1, 'connected');
    expect(w5s10[1].spec.expectedActionV1, 'call');
    expect(w5s10.last.spec.boardTextureV1, 'wet');
    expect(w5s10.last.spec.expectedActionV1, 'fold');
  });
}
