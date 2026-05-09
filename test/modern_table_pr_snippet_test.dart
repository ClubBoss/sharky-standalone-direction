import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

import '../tools/modern_table_pr_snippet_v1.dart' as tool;

void main() {
  const expectedChecklist = [
    '- [ ] Felt spotlight/vignette',
    '- [ ] Board card lift/shadow',
    '- [ ] Dealer puck acrylic',
    '- [ ] Avatar bezel metallic',
    '- [ ] Action buttons glass finish',
    '- [ ] Watermark not behind board',
    '- [ ] Numeric jitter stable (tabular + longestLine)',
    '- [ ] Hit targets >=44',
  ];

  const requiredCommands = [
    'dart run tools/modern_table_screenshot_v1.dart',
    'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh',
    'bash tools/modern_table_audit_run_v1.sh',
  ];

  Future<String?> _captureOutput(String rootPath) async {
    String? output;
    await runZoned(
      () async {
        tool.main([rootPath]);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          output = line;
        },
      ),
    );
    return output;
  }

  void _expectCommonSections(String output) {
    expect(output.contains('Modern Table Visual Cohesion'), isTrue);
    expect(output.contains('Audit'), isTrue);
    expect(output.contains('Checklist'), isTrue);
    expect(output.contains('Commands'), isTrue);
    for (final cmd in requiredCommands) {
      expect(output.contains(cmd), isTrue);
    }
    final lines = output.split('\n');
    final checklistStart = lines.indexWhere(
      (line) => line.startsWith('- [ ] '),
    );
    expect(checklistStart >= 0, isTrue);
    for (var i = 0; i < expectedChecklist.length; i++) {
      expect(lines[checklistStart + i], expectedChecklist[i]);
    }
  }

  test('prints RUN line when zip missing', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'modern_table_pr_snippet_missing_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final output = await _captureOutput(tempDir.path);
    expect(output, isNotNull);
    _expectCommonSections(output!);
    expect(
      output.contains(
        'Audit pack: `RUN: dart run tools/modern_table_screenshot_v1.dart && '
        'SKIP_GENERATE=1 bash tools/modern_table_screenshots_zip_v1.sh`',
      ),
      isTrue,
    );
  });

  test('prints env var when zip exists', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'modern_table_pr_snippet_present_',
    );
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final outDir = Directory('${tempDir.path}${Platform.pathSeparator}out');
    await outDir.create();
    final zipFile = File(
      '${outDir.path}${Platform.pathSeparator}modern_table_screenshots_v1.zip',
    );
    await zipFile.writeAsString('ok');

    final output = await _captureOutput(tempDir.path);
    expect(output, isNotNull);
    _expectCommonSections(output!);
    expect(
      output.contains(
        'Audit pack: `MODERN_TABLE_AUDIT_PACK=out/modern_table_screenshots_v1.zip`',
      ),
      isTrue,
    );
  });
}
