import '../persona/profile/persona_profile_model_v1.dart';
import '../../services/recommendation_scoring_v1.dart';
import '../../services/recommendation_persona_link_v1.dart';
import 'sr_session_bridge_v1.dart';

class SRRecommendationBridgeV1 {
  SRRecommendationBridgeV1({
    required List<Map<String, Object?>> items,
    required Map<String, List<Map<String, Object?>>> srQueues,
    required PersonaProfileModelV1 model,
  }) : _items = List<Map<String, Object?>>.from(items),
       _srQueues = srQueues,
       _model = model {
    final persona = <String, Object?>{
      'risk_avoidant': _model.staticTraits.values.contains('risk_avoidant'),
      'pattern_seeker': _model.staticTraits.values.contains('pattern_seeker'),
    };
    final scores = <String, double>{};
    for (final item in _items) {
      final score = scoreItem(srItem: item, persona: persona);
      scores[_asId(item)] = score;
    }
    _linkedScores = applyPersonaSRLink(
      baseScores: scores,
      persona: persona,
      srQueues: _srQueues,
    );
    ranked = _items.toList()..sort((a, b) => _score(b).compareTo(_score(a)));
    nextItem = ranked.isNotEmpty ? ranked.first : null;
    if (nextItem == null) {
      final sessionBridge = SRSessionBridgeV1(
        items: _items,
        personaTraits: _model.staticTraits,
        personaInsights: _model.aiInsights,
        nextIdSupplier: () => null,
      );
      nextItem = sessionBridge.nextItem;
    }
  }

  final List<Map<String, Object?>> _items;
  final Map<String, List<Map<String, Object?>>> _srQueues;
  final PersonaProfileModelV1 _model;
  late final Map<String, double> _linkedScores;
  late final Map<String, Object?>? nextItem;
  late final List<Map<String, Object?>> ranked;

  double _score(Map<String, Object?> item) => _linkedScores[_asId(item)] ?? 0.0;

  String _asId(Map<String, Object?> item) =>
      item['id'] is String ? item['id'] as String : '';
}
