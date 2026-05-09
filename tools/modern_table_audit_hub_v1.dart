import 'dart:io';

import 'modern_table_audit_note_v1.dart' as audit_note;
import 'modern_table_audit_pack_hint_v1.dart' as pack_hint;
import 'modern_table_pr_snippet_v1.dart' as pr_snippet;

String buildAuditHubOutput(String rootPath) {
  final sections = [
    pack_hint.buildAuditPackHint(rootPath),
    audit_note.buildAuditNote(rootPath),
    pr_snippet.buildPrSnippet(rootPath),
  ];
  return sections.join('\n\n');
}

void main(List<String> args) {
  String rootPath;
  if (args.length >= 2 && args.first == '--root') {
    rootPath = args[1];
  } else if (args.isNotEmpty && !args.first.startsWith('-')) {
    rootPath = args.first;
  } else {
    rootPath = Directory.current.path;
  }
  print(buildAuditHubOutput(rootPath));
}
