import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_shell_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_composer_contract_v1.dart';

void main() {
  testWidgets('world1 canonical shell contract resolves portrait overlay', (
    tester,
  ) async {
    final resolved = resolveWorld1CanonicalShellContractV1(
      const World1CanonicalShellContractInputV1(
        outerPadding: EdgeInsets.all(8),
        shellBody: SizedBox.shrink(),
        portraitLayout: true,
        compactPortrait: true,
        shellSlots: World1CanonicalShellSlotsV1(
          topShell: null,
          portraitSupportContent: World1LearnerHostSupportContentContractV1(
            child: Text('Support'),
          ),
          landscapeSupportContent: null,
          portraitActionSurface: Text('Action'),
          landscapeHostContent: null,
          landscapeActionSurface: null,
        ),
      ),
    );

    expect(resolved.outerPadding, const EdgeInsets.all(8));
    expect(resolved.portraitOverlay, isNotNull);
    expect(
      resolved.shellContract.bottomBandSurfaceKey,
      const Key('microtask_scene_support_lane_v1'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Stack(children: [resolved.portraitOverlay!])),
      ),
    );

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Action'), findsOneWidget);
  });

  testWidgets(
    'world1 canonical shell contract resolves portrait bottom band when top shell is present',
    (tester) async {
      final resolved = resolveWorld1CanonicalShellContractV1(
        const World1CanonicalShellContractInputV1(
          outerPadding: EdgeInsets.zero,
          shellBody: SizedBox.shrink(),
          portraitLayout: true,
          compactPortrait: true,
          shellSlots: World1CanonicalShellSlotsV1(
            topShell: Text('Header'),
            portraitSupportContent: World1LearnerHostSupportContentContractV1(
              child: Text('Support'),
            ),
            landscapeSupportContent: null,
            portraitActionSurface: Text('Action'),
            landscapeHostContent: null,
            landscapeActionSurface: null,
          ),
        ),
      );

      expect(resolved.portraitOverlay, isNull);
      expect(resolved.shellContract.bottomBandChild, isNotNull);
      expect(resolved.shellContract.bottomBandSurfaceKey, const Key('microtask_scene_support_lane_v1'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                resolved.shellContract.header,
                resolved.shellContract.bottomBandChild!,
              ],
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
    },
  );

  test(
    'world1 canonical shell contract resolves landscape without overlay',
    () {
      final resolved = resolveWorld1CanonicalShellContractV1(
        const World1CanonicalShellContractInputV1(
          outerPadding: EdgeInsets.zero,
          shellBody: SizedBox.shrink(),
          portraitLayout: false,
          compactPortrait: false,
          shellSlots: World1CanonicalShellSlotsV1(
            topShell: null,
            portraitSupportContent: null,
            landscapeSupportContent: null,
            portraitActionSurface: null,
            landscapeHostContent: null,
            landscapeActionSurface: null,
          ),
        ),
      );

      expect(resolved.portraitOverlay, isNull);
      expect(resolved.shellContract.body, isA<SizedBox>());
    },
  );
}
