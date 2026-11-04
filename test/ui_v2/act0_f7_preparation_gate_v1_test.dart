import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_source_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_hybrid_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_profile_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const profile = act0PremiumTableSceneProfileV1;
final hand = Act0ShellStateV1.sample.lessonById('your_first_hand').taskList;
Act0F7SceneSourceV1 source(String key, {bool empty = false}) =>
    Act0F7SceneSourceV1.fromTask(
      empty
          ? Act0ShellStateV1.sample
                .lessonById('fold_check_call_raise')
                .taskList
                .singleWhere((t) => t.taskId == 'actions_theory')
          : hand.first,
      scenarioKey: key,
    );

class _Bytes extends CachingAssetBundle {
  _Bytes(this.bytes);
  final Uint8List bytes;
  int loads = 0;
  @override
  Future<ByteData> load(String key) async {
    loads++;
    return ByteData.sublistView(bytes);
  }
}

class _Missing extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('missing plate');
}

class _Deferred extends CachingAssetBundle {
  final done = Completer<ByteData>();
  @override
  Future<ByteData> load(String key) => done.future;
}

Act0SceneSinglePlateImageStoreV1 store({String? path}) =>
    Act0SceneSinglePlateImageStoreV1(
      path ?? profile.assetPath,
      library: 'F7 test',
    );

void main() {
  Future<void> mount(
    WidgetTester t, {
    required Act0F7SceneSourceV1 input,
    required Act0SceneSinglePlateImageStoreV1 images,
    AssetBundle? bundle,
    bool enabled = true,
    VoidCallback? choose,
  }) async {
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Act0F7SceneGateV1(
                  source: input,
                  store: images,
                  assetBundle: bundle,
                  enabled: enabled,
                  originalBuilder: (_) =>
                      const Text('procedural people/table/hands'),
                  registeredBuilder: (_, image, p) => CustomPaint(
                    key: const Key('registered'),
                    painter: Act0F7RegisteredScenePainterV1(
                      image: image,
                      registration: p.register(const Size(393, 759)),
                    ),
                  ),
                ),
              ),
              // Integration contract fixture: learning controls remain mounted while
              // scenery decodes/fails. This is not the protected Runner integration.
              SizedBox(
                height: 48,
                child: TextButton(
                  key: const Key('source-choice'),
                  onPressed: choose ?? () {},
                  child: Text(hand.first.runner.options.first.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await t.pump();
  }

  testWidgets(
    'decoded PNG selects one scenery branch and keeps answer callback',
    (t) async {
      final images = store();
      addTearDown(images.clear);
      final bytes = _Bytes(File(profile.assetPath).readAsBytesSync());
      await t.runAsync(() => images.warmUp(bundle: bytes));
      var choices = 0;
      await mount(
        t,
        input: source('attempt-1'),
        images: images,
        choose: () => choices++,
      );
      expect(find.byKey(const Key('registered')), findsOneWidget);
      expect(find.text('procedural people/table/hands'), findsNothing);
      expect(images.readyImage!.width, 965);
      expect(images.readyImage!.height, 1629);
      expect(
        t.getSize(find.byKey(const Key('source-choice'))).height,
        greaterThanOrEqualTo(44),
      );
      await t.tap(find.byKey(const Key('source-choice')));
      expect(choices, 1);
      final decoded = images.readyImage;
      await mount(t, input: source('attempt-1'), images: images);
      expect(images.readyImage, same(decoded));
      expect(bytes.loads, 1);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'complete empty-seat inventory latches fallback across feedback',
    (t) async {
      final images = store();
      addTearDown(images.clear);
      await mount(t, input: source('attempt-1', empty: true), images: images);
      expect(find.text('procedural people/table/hands'), findsOneWidget);
      await mount(t, input: source('attempt-1'), images: images);
      expect(find.byKey(const Key('registered')), findsNothing);
      expect(images.isPending, isFalse);
      expect(find.text('procedural people/table/hands'), findsOneWidget);
    },
  );

  testWidgets(
    'same-key unsafe source invalidates premium and remains fallback',
    (t) async {
      final images = store();
      addTearDown(images.clear);
      await t.runAsync(
        () => images.warmUp(
          bundle: _Bytes(File(profile.assetPath).readAsBytesSync()),
        ),
      );
      await mount(t, input: source('attempt-1'), images: images);
      expect(find.byKey(const Key('registered')), findsOneWidget);
      await mount(t, input: source('attempt-1', empty: true), images: images);
      expect(find.text('procedural people/table/hands'), findsOneWidget);
      await mount(t, input: source('attempt-1'), images: images);
      expect(find.byKey(const Key('registered')), findsNothing);
      await mount(t, input: source('attempt-2'), images: images);
      expect(find.byKey(const Key('registered')), findsOneWidget);
    },
  );

  testWidgets(
    'OFF, missing source, missing asset and wrong store fail closed',
    (t) async {
      final images = store();
      addTearDown(images.clear);
      await mount(t, input: source('off'), images: images, enabled: false);
      expect(images.isPending, isFalse);
      expect(find.text('procedural people/table/hands'), findsOneWidget);
      await mount(
        t,
        input: Act0F7SceneSourceV1(scenarioKey: 'unknown', tables: {}),
        images: images,
      );
      expect(find.text('procedural people/table/hands'), findsOneWidget);
      await t.runAsync(() => images.warmUp(bundle: _Missing()));
      await mount(t, input: source('missing'), images: images);
      expect(find.text('procedural people/table/hands'), findsOneWidget);
      final wrong = store(path: 'wrong.png');
      addTearDown(wrong.clear);
      await mount(t, input: source('wrong'), images: wrong);
      expect(find.text('procedural people/table/hands'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('wrong decoded dimensions and corrupt bytes retain fallback', (
    t,
  ) async {
    final tiny = store();
    addTearDown(tiny.clear);
    await t.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.black, BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(1, 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await tiny.warmUp(bundle: _Bytes(bytes!.buffer.asUint8List()));
      image.dispose();
      picture.dispose();
    });
    await mount(t, input: source('tiny'), images: tiny);
    expect(find.text('procedural people/table/hands'), findsOneWidget);
    final bad = store();
    addTearDown(bad.clear);
    final errors = <FlutterErrorDetails>[];
    final old = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await t.runAsync(
        () => bad.warmUp(bundle: _Bytes(Uint8List.fromList([1, 2, 3]))),
      );
    } finally {
      FlutterError.onError = old;
    }
    await mount(t, input: source('corrupt'), images: bad, bundle: _Missing());
    expect(errors, hasLength(1));
    expect(find.text('procedural people/table/hands'), findsOneWidget);
  });

  testWidgets(
    'late cold decode cannot replace new fallback; shelf stays mounted',
    (t) async {
      final images = store();
      addTearDown(images.clear);
      final delayed = _Deferred();
      await mount(t, input: source('loading'), images: images, bundle: delayed);
      expect(find.byKey(const Key('act0_f7_scene_loading')), findsOneWidget);
      expect(find.byKey(const Key('source-choice')), findsOneWidget);
      await mount(t, input: source('new-empty', empty: true), images: images);
      await t.runAsync(() async {
        delayed.done.complete(
          ByteData.sublistView(File(profile.assetPath).readAsBytesSync()),
        );
        await images.warmUp();
      });
      await t.pump();
      expect(find.text('procedural people/table/hands'), findsOneWidget);
      expect(find.byKey(const Key('registered')), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
}
