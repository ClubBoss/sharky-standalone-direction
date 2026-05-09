import 'dart:async';

import '../models/v2/training_pack_template_v2.dart';
import '../services/training_session_launcher.dart';
import '../services/training_session_service.dart';

extension TrainingSessionServiceCompat on TrainingSessionService {
  Future<void> startFromTemplate(
    TrainingPackTemplateV2 template, {
    int startIndex = 0,
    List<String>? sessionTags,
    String? source,
  }) => TrainingSessionLauncher().launch(
    template,
    startIndex: startIndex,
    sessionTags: sessionTags,
    source: source,
  );
}
