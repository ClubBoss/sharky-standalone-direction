import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('modern_table_audit_v1.md keeps required commands', () {
    const docPath = 'docs/modern_table_audit_v1.md';
    final docFile = File(docPath);
    expect(docFile.existsSync(), isTrue, reason: 'Missing $docPath.');
    final docText = docFile.readAsStringSync();
    const requiredLines = [
      'dart run tools/modern_table_screenshot_v1.dart',
      'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh',
      'bash tools/modern_table_audit_run_v1.sh',
    ];
    for (final line in requiredLines) {
      expect(docText.contains(line), isTrue, reason: 'Doc must include: $line');
    }
    expect(
      docText.contains('modern_table_audit_hub_v1.dart'),
      isTrue,
      reason: 'Doc must mention the audit hub output.',
    );
    expect(
      docText.contains('--root'),
      isTrue,
      reason: 'Doc must mention --root usage.',
    );
  });
}
