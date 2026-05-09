import 'dart:convert';
import 'dart:io';

import 'app_info_service.dart';

/// Builds a deterministic diagnostics report for support interactions.
class DiagnosticsReportService {
  DiagnosticsReportService({
    required this.appInfoService,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppInfoService appInfoService;
  final DateTime Function() _clock;

  /// Builds a diagnostics string containing a short header and indented JSON.
  Future<String> buildReport({
    required String languageCode,
    required bool soundEnabled,
    required bool hapticsEnabled,
    required int packCatalogCount,
    String? lastSessionEndReason,
  }) async {
    final version = await appInfoService.getAppVersion();
    final payload = <String, Object>{
      'appVersion': version,
      'appMode': appInfoService.isReleaseMode() ? 'release' : 'debug',
      'selectedLanguage': languageCode,
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
      'packCatalogCount': packCatalogCount,
      'lastSessionEndReason': lastSessionEndReason ?? 'unknown',
      'generatedAt': _clock().toIso8601String(),
    };
    final encoded = const JsonEncoder.withIndent('  ').convert(payload);
    return 'Diagnostics report\n$encoded';
  }

  /// Writes a diagnostics report to a file and returns it, or null on failure.
  Future<File?> exportReport({
    required String report,
    Directory Function()? directoryProvider,
  }) async {
    try {
      final dir = directoryProvider?.call() ?? Directory.systemTemp;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final timestamp = _clock()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final path =
          '${dir.path}${Platform.pathSeparator}'
          'diagnostics_$timestamp.txt';
      final file = File(path);
      await file.writeAsString(report);
      return file;
    } catch (_) {
      return null;
    }
  }
}
