import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_path_template_v2.dart';
import 'starter_learning_path_builder.dart';

/// Resolves the current learning path template used by the app.
class LearningPathOrchestrator {
  LearningPathOrchestrator._();

  static final LearningPathOrchestrator instance = LearningPathOrchestrator._();

  final _builder = StarterLearningPathBuilder();

  Future<LearningPathTemplateV2>? _future;

  static const _prefsKey = 'current_learning_path_v2';

  /// Returns a learning path, loading it from cache or building a starter path
  /// when nothing is stored.
  Future<LearningPathTemplateV2> resolve() => _future ??= _loadOrBuild();

  Future<LearningPathTemplateV2> _loadOrBuild() async {
    final local = await _loadLocal();
    if (local != null) {
      debugPrint('LearningPathOrchestrator: loaded local path');
      return local;
    }

    final starter = _builder.build();
    await _saveLocal(starter);
    debugPrint('LearningPathOrchestrator: built starter path');
    return starter;
  }

  Future<LearningPathTemplateV2?> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        return LearningPathTemplateV2.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveLocal(LearningPathTemplateV2 path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(path.toJson()));
  }
}
