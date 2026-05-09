import 'dart:core';
import 'training_pack_template.dart';
// Temporary shim to keep legacy name working during migration.
// Remove after all refs switched to TrainingPackTemplateV2.
export 'training_pack_template.dart' show TrainingPackTemplate;

@Deprecated(
  'Use TrainingPackTemplate directly from training_pack_template.dart',
)
typedef TrainingPackTemplateV2 = TrainingPackTemplate;
