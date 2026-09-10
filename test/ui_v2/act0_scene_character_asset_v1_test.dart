import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_character_asset_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_player_v1.dart';

void main() {
  late Act0SceneCharacterImageStoreV1 store;

  setUp(() => store = Act0SceneCharacterImageStoreV1());
  tearDown(() => store.clear());

  test('production tier and side resolve the five opponent identities', () {
    expect(
      Act0SceneCharacterIdentityResolverV1.resolve(_slot(x: 0.5, depth: 0.1)),
      Act0SceneCharacterIdentityV1.utg,
    );
    expect(
      Act0SceneCharacterIdentityResolverV1.resolve(_slot(x: 0.1, depth: 0.3)),
      Act0SceneCharacterIdentityV1.bb,
    );
    expect(
      Act0SceneCharacterIdentityResolverV1.resolve(_slot(x: 0.9, depth: 0.3)),
      Act0SceneCharacterIdentityV1.hj,
    );
    expect(
      Act0SceneCharacterIdentityResolverV1.resolve(_slot(x: 0.1, depth: 0.8)),
      Act0SceneCharacterIdentityV1.sb,
    );
    expect(
      Act0SceneCharacterIdentityResolverV1.resolve(_slot(x: 0.9, depth: 0.8)),
      Act0SceneCharacterIdentityV1.co,
    );
    expect(
      Act0SceneCharacterIdentityResolverV1.resolve(
        _slot(x: 0.5, depth: 0.8, isHero: true),
      ),
      isNull,
    );
  });

  test('asset paths are stable and folded reuses engaged artwork', () {
    for (final identity in Act0SceneCharacterIdentityV1.values) {
      final engaged = Act0SceneCharacterAssetRegistryV1.pathFor(
        identity,
        Act0SceneCharacterStateV1.engaged,
      );
      expect(
        engaged,
        'assets/act0_characters/opponent_${identity.name}_engaged.png',
      );
      expect(
        Act0SceneCharacterAssetRegistryV1.pathFor(
          identity,
          Act0SceneCharacterStateV1.folded,
        ),
        engaged,
      );
    }
  });

  test('only UTG carries the proven proportional art fit', () {
    final utg = Act0SceneCharacterAssetRegistryV1.artFitFor(
      Act0SceneCharacterIdentityV1.utg,
    );
    expect(utg.scale, 1.30);
    expect(utg.relativeOffset, const Offset(0, -0.28));
    final destination = utg.destinationRectFor(const Size(100, 200));
    expect(destination.left, closeTo(-15, 1e-9));
    expect(destination.top, closeTo(-56, 1e-9));
    expect(destination.width, closeTo(130, 1e-9));
    expect(destination.height, closeTo(260, 1e-9));

    for (final identity in Act0SceneCharacterIdentityV1.values.where(
      (identity) => identity != Act0SceneCharacterIdentityV1.utg,
    )) {
      expect(
        Act0SceneCharacterAssetRegistryV1.artFitFor(identity),
        Act0SceneCharacterArtFitV1.standard,
      );
    }
  });

  testWidgets('decode-once store shares pending work and reaches ready', (
    tester,
  ) async {
    final bundle = _CountingBundle(rootBundle);
    final path = Act0SceneCharacterAssetRegistryV1.engagedPathFor(
      Act0SceneCharacterIdentityV1.utg,
    );

    final results = await tester.runAsync(
      () => Future.wait(<Future<Object?>>[
        store.load(path, bundle: bundle),
        store.load(path, bundle: bundle),
      ]),
    );

    expect(bundle.loadCount, 1);
    expect(results, everyElement(isNotNull));
    expect(identical(results![0], results[1]), isTrue);
    expect(store.isReady(path), isTrue);
    expect(store.isPending(path), isFalse);
  });

  testWidgets('missing asset resolves to deterministic fallback state', (
    tester,
  ) async {
    const path = 'assets/act0_characters/opponent_missing_engaged.png';

    final image = await tester.runAsync(
      () => store.load(path, bundle: _MissingAssetBundle()),
    );

    expect(image, isNull);
    expect(store.isMissing(path), isTrue);
    expect(store.isReady(path), isFalse);
  });

  testWidgets('supplied UTG asset replaces fallback when ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 100,
          height: 120,
          child: Act0SceneCharacterFigureV1(
            identity: Act0SceneCharacterIdentityV1.utg,
            state: Act0SceneCharacterStateV1.folded,
            size: const Size(100, 120),
            haze: 0.2,
            store: store,
            fallback: const SizedBox(key: Key('procedural_fallback')),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => store.load(
        Act0SceneCharacterAssetRegistryV1.engagedPathFor(
          Act0SceneCharacterIdentityV1.utg,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('act0_scene_character_utg_ready')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('procedural_fallback')), findsNothing);
  });

  testWidgets('invalid image bytes report a decode failure', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previous);

    final image = await tester.runAsync(
      () => store.load('invalid.png', bundle: _InvalidImageBundle()),
    );

    expect(image, isNull);
    expect(errors, hasLength(1));
    expect(errors.single.context.toString(), contains('while decoding'));
  });
}

Act0SceneSeatSlotV1 _slot({
  required double x,
  required double depth,
  bool isHero = false,
}) => Act0SceneSeatSlotV1(
  seatId: 'test',
  depth: depth,
  plateAnchor: Offset(x, depth),
  characterAnchor: Offset(x, depth),
  betAnchor: Offset(x, depth),
  cardAnchor: Offset(x, depth),
  plateScale: 1,
  volumeScale: 1,
  isHero: isHero,
);

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
      Future<ByteData>.error(FlutterError('Missing test asset: $key'));
}
