import 'training_pack_template_v2.dart';
import 'hero_position.dart';

extension TrainingPackTemplateV2Ext on TrainingPackTemplateV2 {
  String posRangeLabel() {
    if (positions.isEmpty) return '';
    return positions
        .map((p) {
          try {
            return HeroPosition.values
                .firstWhere(
                  (e) => e.name == p,
                  orElse: () => HeroPosition.unknown,
                )
                .label;
          } catch (_) {
            return p;
          }
        })
        .join(', ');
  }
}
