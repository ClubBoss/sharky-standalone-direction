import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class ContentManifest {
  // Deprecated: content/_manifest.json is not the canonical content manifest.
  // Use explicit content/<module>/v1/manifest.json bundles for module readiness
  // and content/_meta/*.json for runtime world/session manifests.
  static const path = 'content/_manifest.json';
  static const ssotDocPath = 'docs/content/ssot_v1.md';
  static bool _warnedDeprecatedPath = false;
  static bool _warnedMissingDefaultManifest = false;

  final Set<String> modules;

  ContentManifest(this.modules);

  static ContentManifest loadSync({String path = path}) {
    _warnIfDefaultPathIsDeprecated(path);
    try {
      final contents = File(path).readAsStringSync();
      final json = jsonDecode(contents);
      if (json is Map) {
        return ContentManifest(json.keys.map((e) => e.toString()).toSet());
      }
    } catch (_) {}
    _warnIfDefaultManifestIsMissing(path);
    return ContentManifest(<String>{});
  }

  static void _warnIfDefaultPathIsDeprecated(String requestedPath) {
    if (!kDebugMode || _warnedDeprecatedPath || requestedPath != path) {
      return;
    }
    _warnedDeprecatedPath = true;
    debugPrint(
      'ContentManifest.loadSync is using deprecated $path. '
      'Canonical manifests live under content/<module>/v1/manifest.json '
      'and content/_meta/*.json. See $ssotDocPath.',
    );
  }

  static void _warnIfDefaultManifestIsMissing(String requestedPath) {
    if (!kDebugMode || _warnedMissingDefaultManifest || requestedPath != path) {
      return;
    }
    _warnedMissingDefaultManifest = true;
    assert(() {
      debugPrint(
        'Missing deprecated readiness manifest at $path. '
        'Do not add new callers for this file; use canonical content manifests instead. '
        'See $ssotDocPath.',
      );
      return true;
    }());
  }

  bool isReady(String moduleId) => modules.contains(moduleId);
}

bool isReady(String moduleId, {String path = ContentManifest.path}) =>
    ContentManifest.loadSync(path: path).isReady(moduleId);
