import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_surface_family_v1.dart';

void main() {
  test(
    'session drill canonical surface selection resolves world2 surfaced host',
    () {
      final selection = buildSessionDrillCanonicalSurfaceSelectionStateV1(
        showsEmbeddedScenarioTable: true,
        isWorld2SurfacedScenarioSession: true,
        isCompleted: false,
      );

      expect(selection.showsSurfacedWorld2Host, isTrue);
      expect(selection.usesWorld2ScaffoldChromeReduction, isTrue);
      expect(selection.showsEmbeddedFeedbackBelowTable, isTrue);
      expect(
        selection.topSectionDensity,
        SessionDrillCanonicalTopSectionDensityV1.world2Surfaced,
      );
    },
  );

  test(
    'session drill canonical render family prioritizes world2 over world10',
    () {
      expect(
        resolveSessionDrillCanonicalRenderSurfaceFamilyV1(
          hasSurfacedWorld2Adapter: true,
          hasWorld10TrackCluster: true,
        ),
        SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced,
      );

      expect(
        resolveSessionDrillCanonicalRenderSurfaceFamilyV1(
          hasSurfacedWorld2Adapter: false,
          hasWorld10TrackCluster: true,
        ),
        SessionDrillCanonicalRenderSurfaceFamilyV1.world10TrackFinite,
      );

      expect(
        resolveSessionDrillCanonicalRenderSurfaceFamilyV1(
          hasSurfacedWorld2Adapter: false,
          hasWorld10TrackCluster: false,
        ),
        SessionDrillCanonicalRenderSurfaceFamilyV1.generic,
      );
    },
  );

  test(
    'generic and world10 finite session surfaces share one embedded frame layout owner',
    () {
      final source = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();

      expect(source.contains('_buildSharedEmbeddedScenarioFrameSurfaceV1('), isTrue);
      expect(
        RegExp(
          r'case SessionDrillCanonicalRenderSurfaceFamilyV1\.world10TrackFinite:\s+case SessionDrillCanonicalRenderSurfaceFamilyV1\.generic:\s+return _buildSharedEmbeddedScenarioFrameSurfaceV1\(',
          multiLine: true,
        ).hasMatch(source),
        isTrue,
      );
      expect(source.contains('_buildWorld10TrackFiniteLayoutSurfaceV1('), isFalse);
    },
  );
}
