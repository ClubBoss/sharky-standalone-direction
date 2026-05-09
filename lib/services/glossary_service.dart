import 'dart:convert';

import 'package:flutter/services.dart';

class GlossaryService {
  GlossaryService._();

  static final GlossaryService instance = GlossaryService._();

  Map<String, String>? _definitions;

  Future<void> _ensureLoaded() async {
    if (_definitions != null) return;

    final jsonString = await rootBundle.loadString('content/glossary.json');
    final Map<String, dynamic> jsonMap =
        jsonDecode(jsonString) as Map<String, dynamic>;
    _definitions = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<String?> getDefinition(String term) async {
    await _ensureLoaded();
    return _definitions?[term];
  }

  Future<Map<String, String>> getAllDefinitions() async {
    await _ensureLoaded();
    return Map.unmodifiable(_definitions!);
  }
}
