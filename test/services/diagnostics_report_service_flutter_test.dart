import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/app_info_service.dart';
import 'package:poker_analyzer/services/diagnostics_report_service.dart';
import 'package:test/test.dart';

void main() {
  test('buildReport includes deterministic diagnostics payload', () async {
    final service = DiagnosticsReportService(
      appInfoService: _TestAppInfoService(),
      clock: () => DateTime.utc(2025, 1, 1),
    );

    final report = await service.buildReport(
      languageCode: 'en',
      soundEnabled: true,
      hapticsEnabled: false,
      packCatalogCount: 12,
      lastSessionEndReason: 'timeout',
    );

    expect(report, startsWith('Diagnostics report\n'));
    final jsonPart = report.split('\n').skip(1).join('\n');
    final payload = jsonDecode(jsonPart) as Map<String, dynamic>;

    expect(payload['appVersion'], '0.1.0-test');
    expect(payload['appMode'], 'debug');
    expect(payload['selectedLanguage'], 'en');
    expect(payload['soundEnabled'], true);
    expect(payload['hapticsEnabled'], false);
    expect(payload['packCatalogCount'], 12);
    expect(payload['lastSessionEndReason'], 'timeout');
    expect(payload['generatedAt'], '2025-01-01T00:00:00.000Z');
  });

  test('exportReport writes diagnostics to file', () async {
    final service = DiagnosticsReportService(
      appInfoService: _TestAppInfoService(),
      clock: () => DateTime.utc(2025, 1, 1),
    );
    final tempDir = Directory.systemTemp.createTempSync('diag_export_test_');
    try {
      final file = await service.exportReport(
        report: 'diagnostics',
        directoryProvider: () => tempDir,
      );
      expect(file, isNotNull);
      expect(await file!.readAsString(), 'diagnostics');
    } finally {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }
  });

  test('exportReport returns null on failure', () async {
    final service = DiagnosticsReportService(
      appInfoService: _TestAppInfoService(),
      clock: () => DateTime.utc(2025, 1, 1),
    );
    final file = await service.exportReport(
      report: 'diagnostics',
      directoryProvider: () => throw StateError('nope'),
    );
    expect(file, isNull);
  });
}

class _TestAppInfoService extends AppInfoService {
  @override
  Future<String> getAppVersion() async => '0.1.0-test';

  @override
  bool isDebugMode() => true;

  @override
  bool isReleaseMode() => false;
}
