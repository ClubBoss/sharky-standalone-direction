export 'package:poker_analyzer/canonical/world1_canonical_module_order_v1.dart'
    show kWorld1CanonicalModuleOrder;

import 'package:poker_analyzer/canonical/world1_canonical_module_order_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_foundations_entry_metadata_v1.dart';

String resolveProgressMapModuleId(
  Map<String, dynamic> module, {
  required int fallbackIndex,
}) {
  final dynamic id = module['id'] ?? module['name'] ?? module['title'];
  if (id == null) return 'module_$fallbackIndex';
  return id.toString();
}

List<Map<String, dynamic>> orderWorld1Modules(
  List<Map<String, dynamic>> rawModules,
) {
  final byId = <String, Map<String, dynamic>>{};
  for (var i = 0; i < rawModules.length; i++) {
    final source = rawModules[i];
    final id = resolveProgressMapModuleId(source, fallbackIndex: i);
    final module = Map<String, dynamic>.from(source)..['id'] = id;
    final entryMetadata = resolveWorld1FoundationsEntryMetadataV1(id);
    if (entryMetadata != null) {
      module['title'] = entryMetadata.titleText;
      module['description'] = entryMetadata.descriptionText;
    }
    byId[id] = module;
  }

  final ordered = <Map<String, dynamic>>[];
  for (final id in kWorld1CanonicalModuleOrder) {
    final module = byId.remove(id);
    if (module != null) {
      module['isAvailable'] = true;
      ordered.add(module);
      continue;
    }
    ordered.add(<String, dynamic>{
      'id': id,
      'title': id,
      'description': '',
      'isAvailable': false,
    });
  }
  return ordered;
}

List<Map<String, dynamic>> applyLinearUnlockByPreviousCompletion(
  List<Map<String, dynamic>> nodes,
) {
  final result = <Map<String, dynamic>>[];
  for (var i = 0; i < nodes.length; i++) {
    final node = Map<String, dynamic>.from(nodes[i]);
    final available = node['isAvailable'] as bool? ?? true;
    if (!available) {
      node['isUnlocked'] = false;
      result.add(node);
      continue;
    }
    if (i == 0) {
      node['isUnlocked'] = true;
      result.add(node);
      continue;
    }
    final previous = result[i - 1];
    final previousCompleted = previous['isCompleted'] as bool? ?? false;
    final previousAvailable = previous['isAvailable'] as bool? ?? true;
    node['isUnlocked'] = previousAvailable && previousCompleted;
    result.add(node);
  }
  return result;
}
