import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_room_plate_v1.dart';

void main() {
  late Act0SceneRoomPlateImageStoreV1 store;

  setUp(() => store = Act0SceneRoomPlateImageStoreV1());
  tearDown(() => store.clear());

  test(
    'production fit covers without distortion and stays in source bounds',
    () {
      expect(Act0SceneRoomPlateFitV1.production.scale, 1.12);
      expect(
        Act0SceneRoomPlateFitV1.production.normalizedOffset,
        const Offset(0, 0.18),
      );
      final source = Act0SceneRoomPlateFitV1.production.sourceRectFor(
        const Size(1254, 1254),
        const Size(375, 812),
      );

      expect(source.height, closeTo(1254 / 1.12, 1e-9));
      expect(source.width / source.height, closeTo(375 / 812, 1e-9));
      expect(source.left, greaterThanOrEqualTo(0));
      expect(source.right, lessThanOrEqualTo(1254));
      expect(source.top, greaterThanOrEqualTo(0));
      expect(source.bottom, lessThanOrEqualTo(1254));
    },
  );

  testWidgets('decode-once store shares warm-up and reaches ready', (
    tester,
  ) async {
    final bundle = _CountingBundle(rootBundle);
    final results = await tester.runAsync(
      () => Future.wait(<Future<Object?>>[
        store.warmUp(bundle: bundle),
        store.warmUp(bundle: bundle),
      ]),
    );

    expect(bundle.loadCount, 1);
    expect(results, everyElement(isNotNull));
    expect(identical(results![0], results[1]), isTrue);
    expect(store.isReady, isTrue);
    expect(store.isPending, isFalse);
  });

  testWidgets('missing asset paints the deterministic procedural fallback', (
    tester,
  ) async {
    await tester.runAsync(() => store.warmUp(bundle: _MissingAssetBundle()));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 375,
          height: 500,
          child: Act0SceneRoomPlaneV1(store: store),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('act0_scene_room_plate_fallback')),
      findsOneWidget,
    );
    expect(store.isMissing, isTrue);
  });

  testWidgets('invalid room bytes report a decode failure', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previous);

    final image = await tester.runAsync(
      () => store.warmUp(bundle: _InvalidImageBundle()),
    );

    expect(image, isNull);
    expect(errors, hasLength(1));
    expect(errors.single.context.toString(), contains('while decoding'));
  });
}

class _CountingBundle extends CachingAssetBundle {
  _CountingBundle(this.delegate);

  final AssetBundle delegate;
  int loadCount = 0;

  @override
  Future<ByteData> load(String key) {
    loadCount++;
    return delegate.load(key);
  }
}

class _InvalidImageBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) => SynchronousFuture<ByteData>(
    ByteData.sublistView(Uint8List.fromList(<int>[1, 2, 3, 4])),
  );
}

class _MissingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future<ByteData>.error(FlutterError('Missing room plate'));
}
