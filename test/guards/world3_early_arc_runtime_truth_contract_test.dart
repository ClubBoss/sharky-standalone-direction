import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('w3.s01-w3.s10 use preflop hand-chain runtime truth', (
    tester,
  ) async {
    final adapter = const DrillRuntimeAdapterV1();

    final w3s01 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s01'),
    ))!;
    expect(w3s01.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_framework_intro_v1',
    ]);
    expect(w3s01.single.spec.kind, DrillKindV1.handChain);
    final w3s01Steps = w3s01.single.spec.chainStepsV1;
    expect(w3s01Steps, isNotNull);
    expect(w3s01Steps!, hasLength(3));
    expect(w3s01Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s01Steps.first.prompt, contains('button with AKo'));
    expect(
      w3s01Steps.last.prompt,
      contains('big blind with T6o after the cutoff opened first'),
    );

    final w3s02 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s02'),
    ))!;
    expect(w3s02.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_category_reuse_v1',
    ]);
    expect(w3s02.single.spec.kind, DrillKindV1.handChain);
    final w3s02Steps = w3s02.single.spec.chainStepsV1;
    expect(w3s02Steps, isNotNull);
    expect(w3s02Steps!, hasLength(3));
    expect(w3s02Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s02Steps.first.prompt, contains('button with KJs'));
    expect(
      w3s02Steps.last.prompt,
      contains('the hand is A8o and the cutoff opened first'),
    );

    final w3s03 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s03'),
    ))!;
    expect(w3s03.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_checkpoint_v1',
    ]);
    expect(w3s03.single.spec.kind, DrillKindV1.handChain);
    final w3s03Steps = w3s03.single.spec.chainStepsV1;
    expect(w3s03Steps, isNotNull);
    expect(w3s03Steps!, hasLength(3));
    expect(w3s03Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s03Steps.first.prompt, contains('cutoff with AQs'));
    expect(
      w3s03Steps.last.prompt,
      contains('big blind with J7o after the button opened first'),
    );

    final w3s04 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s04'),
    ))!;
    expect(w3s04.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_premium_strong_reps_v1',
    ]);
    expect(w3s04.single.spec.kind, DrillKindV1.handChain);
    final w3s04Steps = w3s04.single.spec.chainStepsV1;
    expect(w3s04Steps, isNotNull);
    expect(w3s04Steps!, hasLength(3));
    expect(w3s04Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s04Steps.first.prompt, contains('cutoff with QQ'));
    expect(
      w3s04Steps.last.prompt,
      contains('big blind with KTo after the button opened first'),
    );

    final w3s05 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s05'),
    ))!;
    expect(w3s05.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_medium_weak_discipline_v1',
    ]);
    expect(w3s05.single.spec.kind, DrillKindV1.handChain);
    final w3s05Steps = w3s05.single.spec.chainStepsV1;
    expect(w3s05Steps, isNotNull);
    expect(w3s05Steps!, hasLength(3));
    expect(w3s05Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s05Steps.first.prompt, contains('button with 99'));
    expect(
      w3s05Steps.last.prompt,
      contains('big blind with Q8o after the button opened first'),
    );

    final w3s06 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s06'),
    ))!;
    expect(w3s06.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_mixed_context_checkpoint_v1',
    ]);
    expect(w3s06.single.spec.kind, DrillKindV1.handChain);
    final w3s06Steps = w3s06.single.spec.chainStepsV1;
    expect(w3s06Steps, isNotNull);
    expect(w3s06Steps!, hasLength(3));
    expect(w3s06Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s06Steps.first.prompt, contains('button with ATo'));
    expect(
      w3s06Steps.last.prompt,
      contains('big blind with J8o after the cutoff opened first'),
    );

    final w3s07 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s07'),
    ))!;
    expect(w3s07.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_open_fold_position_v1',
    ]);
    expect(w3s07.single.spec.kind, DrillKindV1.handChain);
    final w3s07Steps = w3s07.single.spec.chainStepsV1;
    expect(w3s07Steps, isNotNull);
    expect(w3s07Steps!, hasLength(3));
    expect(w3s07Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s07Steps.first.prompt, contains('button with KJo'));
    expect(
      w3s07Steps.last.prompt,
      contains('button with 86o and the pot is unopened'),
    );

    final w3s08 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s08'),
    ))!;
    expect(w3s08.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_continue_fold_discipline_v1',
    ]);
    expect(w3s08.single.spec.kind, DrillKindV1.handChain);
    final w3s08Steps = w3s08.single.spec.chainStepsV1;
    expect(w3s08Steps, isNotNull);
    expect(w3s08Steps!, hasLength(3));
    expect(w3s08Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s08Steps.first.prompt, contains('button with QTs'));
    expect(
      w3s08Steps.last.prompt,
      contains('button with AJs after the cutoff opened first'),
    );

    final w3s09 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s09'),
    ))!;
    expect(w3s09.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_same_hand_different_action_v1',
    ]);
    expect(w3s09.single.spec.kind, DrillKindV1.handChain);
    final w3s09Steps = w3s09.single.spec.chainStepsV1;
    expect(w3s09Steps, isNotNull);
    expect(w3s09Steps!, hasLength(3));
    expect(w3s09Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s09Steps.first.prompt, contains('button with QJo'));
    expect(w3s09Steps.last.prompt, contains('cutoff and the pot is unopened'));

    final w3s10 = (await tester.runAsync(
      () => adapter.loadSessionDrills('w3.s10'),
    ))!;
    expect(w3s10.map((item) => item.drillId).toList(), <String>[
      'chain_preflop_final_checkpoint_v1',
    ]);
    expect(w3s10.single.spec.kind, DrillKindV1.handChain);
    final w3s10Steps = w3s10.single.spec.chainStepsV1;
    expect(w3s10Steps, isNotNull);
    expect(w3s10Steps!, hasLength(3));
    expect(w3s10Steps.every((step) => step.street == 'preflop'), isTrue);
    expect(w3s10Steps.first.prompt, contains('button with KQs'));
    expect(
      w3s10Steps.last.prompt,
      contains('cutoff with J8o and the pot is unopened'),
    );
  });
}
