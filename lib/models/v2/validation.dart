import 'dart:core';
// lib/models/v2/validation.dart

bool validateTrainingPackTemplateV2(Map<String, dynamic> json) {
  // минимальная проверка структуры (расширите позже)
  return json.containsKey('id') && json.containsKey('name');
}

// Удобный хелпер для tools:
bool validateTrainingPackTemplate(Map<String, dynamic> json) =>
    validateTrainingPackTemplateV2(json);
