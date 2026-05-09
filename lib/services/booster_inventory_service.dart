import '../core/training/library/training_pack_library_v2.dart';
import '../core/training/engine/training_type_engine.dart';
import '../models/v2/training_pack_template_v2.dart';

/// Library-backed inventory and lookup for theory/drill boosters.
///
/// Important: This service is unrelated to XP boosters. For XP booster storage
/// use `XpBoosterInventoryService` in `xp_booster_inventory_service.dart`.
class BoosterInventoryService {
  /// Creates a new inventory accessor.
  BoosterInventoryService();

  /// Convenience singleton instance for call sites that prefer it.
  static final BoosterInventoryService instance = BoosterInventoryService();

  /// Ensures training packs are loaded.
  Future<void> loadAll() async {
    await TrainingPackLibraryV2.instance.loadFromFolder();
  }

  /// Returns all booster packs matching the given tag.
  ///
  /// A booster pack is identified by meta.type == 'booster' and meta.tag == tag.
  List<TrainingPackTemplateV2> findByTag(String tag) {
    final lc = tag.trim().toLowerCase();
    final list = TrainingPackLibraryV2.instance.filterBy(
      type: TrainingType.pushFold,
    );
    final result = <TrainingPackTemplateV2>[];
    for (final p in list) {
      final meta = p.meta;
      final type = meta['type']?.toString().toLowerCase();
      final mtag = meta['tag']?.toString().toLowerCase();
      if (type == 'booster' && mtag == lc) {
        result.add(p);
      }
    }
    return result;
  }

  /// Returns a pack by id or null if unknown.
  TrainingPackTemplateV2? getById(String id) =>
      TrainingPackLibraryV2.instance.getById(id);
}
