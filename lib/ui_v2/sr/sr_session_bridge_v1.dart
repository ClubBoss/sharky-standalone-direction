import 'sr_session_loop_v1.dart';
import 'sr_routing_v1.dart';

class SRSessionBridgeV1 {
  SRSessionBridgeV1({
    required List<Map<String, Object?>> items,
    required this.personaTraits,
    required this.personaInsights,
    required this.nextIdSupplier,
  }) : _items = List<Map<String, Object?>>.from(items);

  final List<Map<String, Object?>> _items;
  final Map<String, String> personaTraits;
  final Map<String, String> personaInsights;
  final String? Function() nextIdSupplier;

  Map<String, Object?>? get nextItem {
    final id = nextIdSupplier();
    if (id != null && id.isNotEmpty) {
      final match = _items.firstWhere(
        (item) => (item['id'] is String && item['id'] == id),
        orElse: () => {},
      );
      if (match.isNotEmpty) return match;
    }
    return routeNextItemOrNull(
      _items,
      personaTraits: personaTraits,
      personaInsights: personaInsights,
    );
  }

  Map<String, Object?> onAnswer(Map<String, Object?> item, String answer) =>
      recordSRAnswer(item, answer);
}
