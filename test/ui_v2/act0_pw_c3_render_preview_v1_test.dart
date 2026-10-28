import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_pw_c3_facade_v1.dart';

void main() {
  testWidgets(
    'intro art keeps primary/back controls and full candidate framing',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      var primary = 0;
      var back = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Act0PwC3PageV1(
            eyebrow: 'Your first hand',
            title: 'Find your starting point',
            subtitle: 'A short introduction',
            hero: true,
            content: const SizedBox(),
            primaryLabel: 'Continue',
            onPrimary: () => primary++,
            onBack: () => back++,
            backKey: const Key('test_back'),
          ),
        ),
      );
      await t.pumpAndSettle();
      final image = t.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        kAct0PwC3RenderPreviewV1
            ? kAct0PwC3RenderAssetV1
            : 'assets/design/sharky/home/poker_lounge_reference_v2.png',
      );
      expect(
        image.fit,
        kAct0PwC3RenderPreviewV1 ? BoxFit.contain : BoxFit.cover,
      );
      expect(
        find.ancestor(
          of: find.byType(Image),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byType(Image),
          matching: find.byType(IgnorePointer),
        ),
        findsWidgets,
      );
      for (final key in ['pw_c3_primary', 'test_back']) {
        final f = find.byKey(Key(key));
        final rect = t.getRect(f);
        expect(rect.height, greaterThanOrEqualTo(44));
        expect(
          const Rect.fromLTWH(0, 0, 393, 852).contains(rect.center),
          isTrue,
        );
        await t.tap(f);
        await t.pumpAndSettle();
      }
      expect(primary, 1);
      expect(back, 1);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('decorative candidate is absent from ordinary non-intro pages', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Act0PwC3PageV1(
          eyebrow: 'Question',
          title: 'How should Sharky start?',
          subtitle: 'Choose what fits',
          content: SizedBox(),
        ),
      ),
    );
    expect(find.byType(Image), findsNothing);
  });
}
