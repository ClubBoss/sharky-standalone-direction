// Shared screenshot transport for the seeded runner and real-route walkthrough.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadAct0CaptureFontsV1({bool requireIcons = true}) async {
  const candidates = [
    '/System/Library/Fonts/Supplemental/Arial.ttf',
    '/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  ];
  final font = candidates
      .map(File.new)
      .where((file) => file.existsSync())
      .firstOrNull;
  if (font == null) throw StateError('No local real-text capture font found.');
  Future<void> load(String family, File file) async {
    final bytes = await file.readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }

  for (final family in ['Roboto', 'Ahem']) {
    await load(family, font);
  }
  final loaded = <String>{};
  for (final root in ['build/unit_test_assets', 'build/flutter_assets']) {
    for (final (family, path) in [
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      ('CupertinoIcons', 'packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    ]) {
      final file = File('$root/$path');
      if (!loaded.contains(family) && file.existsSync()) {
        await load(family, file);
        loaded.add(family);
      }
    }
  }
  if (requireIcons && !loaded.contains('MaterialIcons')) {
    throw StateError('No local MaterialIcons font found.');
  }
}

Future<void> captureAct0WidgetPngV1(
  WidgetTester tester,
  Finder boundaryFinder,
  File output,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(boundaryFinder);
  final data = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      return await image.toByteData(format: ui.ImageByteFormat.png);
    } finally {
      image.dispose();
    }
  });
  if (data == null || data.lengthInBytes == 0) {
    throw StateError('Unable to capture ${output.path}');
  }
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
}
