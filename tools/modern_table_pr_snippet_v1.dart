import 'dart:io';

import 'modern_table_audit_note_v1.dart' as audit_note;

String _extractChecklist(String auditNote) {
  final lines = auditNote.split('\n');
  final checklistStart = lines.indexWhere((line) => line.startsWith('- [ ] '));
  if (checklistStart == -1) {
    return '';
  }
  return lines.sublist(checklistStart).join('\n');
}

String buildPrSnippet(String rootPath) {
  final auditNote = audit_note.buildAuditNote(rootPath);
  final auditLine = auditNote.split('\n').first;
  final checklistBlock = _extractChecklist(auditNote);
  return [
    'Modern Table Visual Cohesion',
    '',
    'Audit',
    auditLine,
    '',
    'Checklist',
    checklistBlock,
    '',
    'Commands',
    'dart run tools/modern_table_screenshot_v1.dart',
    'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh',
    'bash tools/modern_table_audit_run_v1.sh',
  ].join('\n');
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
  print(buildPrSnippet(rootPath));
}
