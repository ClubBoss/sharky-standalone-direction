/// Genuine test-only helpers localized from the legacy test shims file
/// during test authority migration Phase 1A. These have no canonical production
/// equivalent and must stay behavior-identical to the shim versions.
import 'dart:io';

Map<String, Object?> parseYamlToMap(String src) => const <String, Object?>{};

extension ShimLastModifiedDir on Directory {
  Future<void> setLastModified(DateTime _) async {}
}

extension ShimLastModifiedFile on File {
  Future<void> setLastModified(DateTime _) async {}
}
