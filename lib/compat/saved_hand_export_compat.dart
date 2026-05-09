import 'dart:async';
import 'package:poker_analyzer/services/saved_hand_export_service.dart';

extension SavedHandExportServiceCompat on SavedHandExportService {
  Future<String?> exportSessionsArchive() async => null;
  Future<String?> exportAllSessionsCsv(Map<int, String> notes) async => null;
}
