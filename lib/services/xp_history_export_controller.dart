import 'package:intl/intl.dart';

import 'xp_history_service.dart';

typedef ClipboardWriter = Future<void> Function(String text);
typedef CsvShareHandler = Future<void> Function(String csv, String title);
typedef SnackBarMessenger = void Function(String message);
typedef TelemetryLogger =
    Future<void> Function(String name, [Map<String, dynamic>? props]);
typedef LabelForType = String Function(String type);

enum XpHistoryExportAction { copy, share }

class XpHistoryExportController {
  XpHistoryExportController({
    required this.historyService,
    required this.clipboardWriter,
    required this.shareHandler,
    required this.showSuccess,
    required this.showError,
    required this.telemetryLogger,
    required this.labelForType,
    required this.copySuccessMessage,
    required this.shareSuccessMessage,
    required this.errorMessage,
    required this.exportTitle,
    DateFormat? dateFormat,
  }) : dateFormat = dateFormat ?? DateFormat('yyyy-MM-dd');

  final XpHistoryService historyService;
  final ClipboardWriter clipboardWriter;
  final CsvShareHandler shareHandler;
  final SnackBarMessenger showSuccess;
  final SnackBarMessenger showError;
  final TelemetryLogger telemetryLogger;
  final LabelForType labelForType;
  final String copySuccessMessage;
  final String shareSuccessMessage;
  final String errorMessage;
  final String exportTitle;
  final DateFormat dateFormat;

  Future<void> export(XpHistoryExportAction action) async {
    final events = await historyService.getHistory();
    final csv = _buildCsv(events);
    final actionValue = action == XpHistoryExportAction.copy ? 'copy' : 'share';

    await telemetryLogger('xp_recap_history_export_tap', {
      'action': actionValue,
    });

    try {
      if (action == XpHistoryExportAction.copy) {
        await clipboardWriter(csv);
        showSuccess(copySuccessMessage);
      } else {
        await shareHandler(csv, exportTitle);
        showSuccess(shareSuccessMessage);
      }

      await telemetryLogger('xp_recap_history_export_success', {
        'action': actionValue,
      });
    } catch (_) {
      showError(errorMessage);
    }
  }

  String _buildCsv(List<XpEvent> events) {
    final buffer = StringBuffer();
    buffer.writeln('"Date","Description","XP"');

    for (final event in events) {
      final date = dateFormat.format(event.timestamp);
      final desc = labelForType(event.type);
      final escapedDesc = desc.replaceAll('"', '""');
      buffer.writeln('"$date","$escapedDesc","${event.amount}"');
    }

    return buffer.toString();
  }
}
