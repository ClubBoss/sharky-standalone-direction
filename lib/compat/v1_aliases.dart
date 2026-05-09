import "dart:core" as core;
import 'dart:core';
// lib/compat/v1_aliases.dart

// Экспортируем всё, что нужно с v2-моделей:
export 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
export 'package:poker_analyzer/models/v2/training_pack_spot.dart';

// Старое имя -> новое (чтобы не ломались tool/ и test/)
// @Deprecated('Use TrainingPackTemplateV2 directly')
