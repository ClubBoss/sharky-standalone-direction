import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'world1 canonical host adapter targets the family-agnostic launch boundary surface',
    () {
      final source = File(
        'lib/ui_v2/runner/world1_canonical_host_adapter_v1.dart',
      ).readAsStringSync();

      expect(
        source.contains('CanonicalLaunchBoundaryRunnerSurfaceV1('),
        isTrue,
      );
      expect(
        source.contains('CanonicalLaunchBoundaryResolvedHostLaunchV1'),
        isTrue,
      );
      expect(
        source.contains(
          'CanonicalTerminalResolvedHostLaunchV1.world1Microtask(',
        ),
        isTrue,
      );
    },
  );

  test('world1 runner owner lives on the shared runner-layer shell path', () {
    final wrapper = File(
      'lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart',
    ).readAsStringSync();
    final owner = File(
      'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
    ).readAsStringSync();

    expect(
      wrapper.contains(
        "export 'package:poker_analyzer/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart';",
      ),
      isTrue,
    );
    expect(owner.contains('SharedLearnerTopLevelShellContractV1('), isTrue);
    expect(owner.contains('return Scaffold('), isFalse);
  });

  test(
    'world1 compact surfaced path uses canonical shell chrome instead of a duplicate local header and overlay lane',
    () {
      final owner = File(
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
      ).readAsStringSync();
      final shell = File(
        'lib/ui_v2/runner/world1_canonical_shell_contract_v1.dart',
      ).readAsStringSync();
      final shellRuntime = File(
        'lib/ui_v2/runner/world1_surfaced_shell_runtime_v1.dart',
      );

      expect(
        owner.contains(
          'topRegion: useRunnerCompactHeaderV1 && !_showEngineV2StreetUi',
        ),
        isTrue,
      );
      expect(owner.contains('child: useRunnerCompactHeaderV1'), isFalse);
      expect(owner.contains('World1LearnerHostShellContractV1'), isFalse);
      expect(owner.contains('resolveWorld1SurfacedShellAssemblyV1('), isFalse);
      expect(shell.contains('final usesCanonicalBottomBandV1 ='), isTrue);
      expect(shell.contains('class World1CanonicalShellSlotsV1'), isTrue);
      expect(
        shell.contains(
          'wrapBottomBandInSupportLane: usesCanonicalBottomBandV1',
        ),
        isTrue,
      );
      expect(
        shell.contains('portraitOverlay: usesCanonicalBottomBandV1'),
        isTrue,
      );
      expect(shellRuntime.existsSync(), isFalse);
    },
  );

  test(
    'world1 active surfaced table path uses the canonical modern table host instead of the bespoke table renderer',
    () {
      final owner = File(
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
      ).readAsStringSync();
      final adapter = File(
        'lib/ui_v2/runner/world1_modern_table_adapter_v1.dart',
      ).readAsStringSync();

      expect(
        owner.contains('_buildWorld1CanonicalEmbeddedTableV1('),
        isTrue,
      );
      expect(owner.contains('child: ModernTableScreenV1('), isTrue);
      expect(
        owner.contains('tableBuilder: (context) => _buildWorld1TableV1('),
        isFalse,
      );
      expect(adapter.contains('scenario_fsm.ScenarioSpecV1('), isTrue);
    },
  );

  test(
    'world1 and canonical session worlds stay on the same modern table host family',
    () {
      final owner = File(
        'lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart',
      ).readAsStringSync();
      final canonical = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();

      expect(owner.contains('child: ModernTableScreenV1('), isTrue);
      expect(
        canonical.contains('_buildEmbeddedScenarioTableSurfaceV1('),
        isTrue,
      );
      expect(canonical.contains('child: ModernTableScreenV1('), isTrue);
      expect(
        RegExp(
              r'child:\s*ModernTableScreenV1\(',
            ).allMatches(canonical).length >=
            1,
        isTrue,
      );
      expect(
        canonical.contains(
          'SessionDrillCanonicalRenderSurfaceFamilyV1.generic',
        ),
        isTrue,
      );
      expect(
        canonical.contains(
          'SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced',
        ),
        isTrue,
      );
    },
  );

  test(
    'embedded modern table host strips debug loader chrome from learner-facing runner paths',
    () {
      final source = File(
        'lib/ui_v2/screens/modern_table_screen_v1.dart',
      ).readAsStringSync();

      expect(source.contains('if (kDebugMode && !widget.embeddedV1)'), isTrue);
      expect(
        source.contains(
          'if (kDebugMode &&\n                                      !widget.embeddedV1 &&\n                                      kEnableMetricsOverlay)',
        ),
        isTrue,
      );
    },
  );
}
