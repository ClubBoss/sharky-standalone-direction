import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart';

class DirectLoader {
  static List<String> availableManifestPathsV1({int world = 1}) {
    return canonicalManifestBackedModuleIdsForWorldV1(world)
        .map((moduleId) => 'content/$moduleId/v1/manifest.json')
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> loadAvailableModules() async {
    final knownPaths = availableManifestPathsV1();

    final List<Map<String, dynamic>> loaded = [];

    for (final path in knownPaths) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        loaded.add(data);
      } catch (e) {
        print('⚠️ Could not load module at $path: $e');
      }
    }

    loaded.sort((a, b) => (a['order'] ?? 99).compareTo(b['order'] ?? 99));
    return loaded;
  }

  static Future<String> loadContentFile(
    String moduleId,
    String fileName,
  ) async {
    final path = 'content/$moduleId/v1/$fileName';
    print('🔍 Attempting to load asset: "$path"');

    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      print('❌ Asset Load Failed: $e');
      try {
        await rootBundle.loadString('content/$moduleId/v1/manifest.json');
        print('✅ BUT manifest.json IS accessible!');
      } catch (_) {
        print('❌ manifest.json is ALSO inaccessible.');
      }

      try {
        final manifestJson = await rootBundle.loadString('AssetManifest.json');
        final assetMap = jsonDecode(manifestJson) as Map<String, dynamic>;
        final available = assetMap.keys
            .where((key) => key.startsWith('content/$moduleId'))
            .take(20)
            .join(', ');
        print('🗂️ Available assets for module "$moduleId": $available');
      } catch (_) {
        print('⚠️ Unable to list available assets via AssetManifest.');
      }

      return '# Error\nCould not load content file: $fileName';
    }
  }
}
