import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_t2_canary_v1.dart';

void main() {
  test('T2 remains disabled in every ordinary production build', () {
    expect(Act0SceneT2CanaryV1.enabled, isFalse);
  });

  test('A scene uses the same isotropic transform on all phone sizes', () {
    for (final size in <Size>[const Size(390, 844), const Size(375, 667)]) {
      final image = Act0SceneT2CanaryV1.sceneImageRect(size);
      final table = Act0SceneT2CanaryV1.tableStageRect(size);
      final sx = image.width / Act0SceneT2CanaryV1.sourceSize.width;
      final sy = image.height / Act0SceneT2CanaryV1.sourceSize.height;
      expect(sx, closeTo(sy, 1e-10));
      expect(image.left, greaterThanOrEqualTo(-0.001));
      expect(image.top, greaterThanOrEqualTo(-0.001));
      expect(image.right, lessThanOrEqualTo(size.width + 0.001));
      expect(image.bottom, lessThanOrEqualTo(size.height + 0.001));
      expect(
        table.left,
        closeTo(
          image.left + Act0SceneT2CanaryV1.tableOuterSourceRect.left * sx,
          1e-10,
        ),
      );
      expect(
        table.top,
        closeTo(
          image.top + Act0SceneT2CanaryV1.tableOuterSourceRect.top * sx,
          1e-10,
        ),
      );
      expect(table.right, lessThanOrEqualTo(size.width + 0.001));
      expect(table.bottom, lessThanOrEqualTo(size.height + 0.001));
      // Source art remains isotropic; only poker overlays move up to clear
      // the action dock on short phones, without changing the camera image.
      final shortPhone = size.height / size.width < 2.0;
      expect(
        table.height,
        closeTo(967 * sx * (shortPhone ? 0.80 : 0.88), 1e-9),
      );
    }
  });

  test('T2 assets are opt-in and state-separated', () {
    expect(
      Act0SceneT2CanaryV1.engagedPath,
      isNot(Act0SceneT2CanaryV1.relaxedPath),
    );
    expect(
      Act0SceneT2CanaryV1.emptyPath,
      isNot(Act0SceneT2CanaryV1.engagedPath),
    );
    expect(
      Act0SceneT2CanaryV1.emptyPath,
      isNot(Act0SceneT2CanaryV1.relaxedPath),
    );
    expect(Act0SceneT2CanaryV1.sourceSize, const Size(1093, 1844));
  });

  test('SB source-state priority: unoccupied is Empty, never Relaxed', () {
    final resolve = Act0SceneT2CanaryV1.resolveSbVisualState;
    expect(
      resolve(isOccupied: true, isInHand: true, isFolded: false),
      Act0SceneT2SbVisualStateV1.engaged,
    );
    expect(
      resolve(isOccupied: true, isInHand: true, isFolded: true),
      Act0SceneT2SbVisualStateV1.relaxed,
    );
    expect(
      resolve(isOccupied: true, isInHand: false, isFolded: false),
      Act0SceneT2SbVisualStateV1.relaxed,
    );
    expect(
      resolve(isOccupied: false, isInHand: false, isFolded: false),
      Act0SceneT2SbVisualStateV1.empty,
    );
    expect(
      resolve(isOccupied: false, isInHand: false, isFolded: true),
      Act0SceneT2SbVisualStateV1.empty,
    );
  });

  testWidgets('real authored scene switches on the source-owned SB state', (
    tester,
  ) async {
    Widget host(Act0SceneT2SbVisualStateV1 state) => MaterialApp(
      home: Center(
        child: SizedBox(
          width: 390,
          height: 844,
          child: Act0SceneT2CanaryPlaneV1(horizon: 0.25, sbVisualState: state),
        ),
      ),
    );

    await tester.pumpWidget(host(Act0SceneT2SbVisualStateV1.engaged));
    await tester.runAsync(() => Act0SceneT2CanaryV1.engagedStore.warmUp());
    await tester.pump();
    expect(
      find.byKey(const Key('act0_scene_t2_sb_engaged_ready')),
      findsOneWidget,
    );

    await tester.pumpWidget(host(Act0SceneT2SbVisualStateV1.relaxed));
    await tester.runAsync(() => Act0SceneT2CanaryV1.relaxedStore.warmUp());
    await tester.pump();
    expect(
      find.byKey(const Key('act0_scene_t2_sb_relaxed_ready')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_scene_t2_sb_engaged_ready')),
      findsNothing,
    );

    await tester.pumpWidget(host(Act0SceneT2SbVisualStateV1.empty));
    final emptyImage = await tester.runAsync(
      () => Act0SceneT2CanaryV1.emptyStore.warmUp(),
    );
    expect(
      emptyImage,
      isNotNull,
      reason: 'Empty must be a real bundled RGBA plate',
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.byKey(const Key('act0_scene_t2_sb_empty_ready')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_scene_t2_sb_relaxed_ready')),
      findsNothing,
    );
  });
}
