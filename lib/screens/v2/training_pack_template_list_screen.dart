import 'dart:core' as core;

import 'dart:core';
import 'package:flutter/material.dart' as m;
import 'package:poker_analyzer/models/v2/template_shim.dart';

class TrainingPackTemplateListScreenV2 extends m.StatefulWidget {
  final core.List<TrainingPackTemplateV2> templates;

  const TrainingPackTemplateListScreenV2({super.key, required this.templates});

  @core.override
  m.State<TrainingPackTemplateListScreenV2> createState() =>
      _TrainingPackTemplateListScreenV2State();
}

class _TrainingPackTemplateListScreenV2State
    extends m.State<TrainingPackTemplateListScreenV2> {
  @core.override
  m.Widget build(m.BuildContext context) => const m.SizedBox.shrink();
}
