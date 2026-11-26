import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_skin_asset_slots_v1.dart';

class _SlotBundle extends CachingAssetBundle {
  _SlotBundle({this.availablePath});

  final String? availablePath;
  final requests = <String>[];

  @override
  Future<ByteData> load(String key) async {
    requests.add(key);
    if (key != availablePath) {
      throw FlutterError('Missing test asset: $key');
    }
    // A single red pixel, not production artwork.
    return ByteData.sublistView(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4'
        'nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
      ),
    );
  }
}

void main() {
  test('all five named slots have distinct flat PNG paths', () {
    expect(
      act0SkinAssetSlotsV1.keys,
      unorderedEquals(Act0SkinAssetSlotV1.values),
    );
    expect(act0SkinAssetSlotsV1.length, 5);
    final paths = act0SkinAssetSlotsV1.values.toSet();
    expect(paths.length, 5);
    for (final path in paths) {
      expect(path, matches(r'^assets/skin_v1/[a-z_]+\.png$'));
    }
  });

  test('designer README covers every slot and its exact filename', () {
    final readme = File('assets/skin_v1/README.md').readAsLinesSync();
    for (final entry in act0SkinAssetSlotsV1.entries) {
      final fileName = entry.value.split('/').last;
      expect(
        readme.where(
          (line) =>
              line.startsWith('| `${entry.key.name}` |') &&
              line.contains('| `$fileName` |'),
        ),
        hasLength(1),
      );
    }
  });

  for (final slot in Act0SkinAssetSlotV1.values) {
    testWidgets('${slot.name} keeps the existing visual when absent', (
      tester,
    ) async {
      final bundle = _SlotBundle();
      const fallback = SizedBox(key: ValueKey('existing-visual'));
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: bundle,
          child: resolveAct0SkinAssetV1(slot, fallback: fallback),
        ),
      );
      await tester.pumpAndSettle();

      expect(bundle.requests, [act0SkinAssetSlotsV1[slot]]);
      expect(find.byWidget(fallback), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('delivered artwork renders in place of the existing visual', (
    tester,
  ) async {
    const slot = Act0SkinAssetSlotV1.sharkyHappy;
    final bundle = _SlotBundle(availablePath: act0SkinAssetSlotsV1[slot]);
    const fallback = SizedBox(key: ValueKey('existing-visual'));
    final resolved = resolveAct0SkinAssetV1(slot, fallback: fallback) as Image;
    await tester.pumpWidget(
      DefaultAssetBundle(bundle: bundle, child: fallback),
    );
    // Complete real decoding before using the cached provider in fake time.
    await tester.runAsync(() async {
      await precacheImage(
        resolved.image,
        tester.element(find.byWidget(fallback)),
        onError: (error, stackTrace) => fail('Asset decode failed: $error'),
      );
    });
    await tester.pumpWidget(
      DefaultAssetBundle(bundle: bundle, child: resolved),
    );
    await tester.pumpAndSettle();

    expect(bundle.requests, contains(act0SkinAssetSlotsV1[slot]));
    expect(find.byWidget(fallback), findsNothing);
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
