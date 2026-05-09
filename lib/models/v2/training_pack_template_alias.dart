// Back-compat alias kept separate to avoid cycles.
library training_pack_template_alias;

import 'training_pack_template_v2.dart' show TrainingPackTemplateV2;

export 'training_pack_template_v2.dart' show TrainingPackTemplateV2;

@Deprecated('Use TrainingPackTemplateV2 instead')
typedef TrainingPackTemplate = TrainingPackTemplateV2;
