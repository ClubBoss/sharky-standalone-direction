import 'dart:convert';
import 'dart:io';

import 'persona_advice_model.dart';

Future<PersonaAdviceModel> loadPersonaAdvice(String moduleId) async {
  final result = await Process.run('dart', [
    'run',
    'tools/persona_advice_api.dart',
    moduleId,
  ], runInShell: true);
  if (result.exitCode != 0) {
    throw Exception('Failed to load persona advice for $moduleId');
  }
  final json = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
  return PersonaAdviceModel.fromJson(json);
}
