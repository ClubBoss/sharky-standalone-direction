import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'world0 defaults bundle exposes representative visual sessions',
    () async {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final assetManifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      const defaultsAsset =
          'content/worlds/world0/v1/sessions/spatial_projection_defaults_v1.json';
      expect(assetManifest.containsKey(defaultsAsset), isTrue);
      final defaultsRaw = await rootBundle.loadString(defaultsAsset);
      expect(defaultsRaw, isNotEmpty);
      final decoded = jsonDecode(defaultsRaw) as Map<String, dynamic>;
      final sessions = decoded['sessions'] as Map<String, dynamic>;
      expect(
        sessions.keys,
        containsAll(const <String>['w0.s01', 'w0.s05', 'w0.s10']),
      );
    },
  );
}
