import 'package:test/test.dart';
import 'package:poker_analyzer/services/session_export_service_v2.dart';
import 'package:poker_analyzer/ui_v2/session_playback_engine.dart';
import 'package:poker_analyzer/ui_v2/hand_analyzer_mode.dart';

void main() {
  group('Session Services Smoke', () {
    test('exportAnalyzedSession returns valid summary', () async {
      final actions = <PlaybackAction>[];
      final analysis = <HandAnalyzerEntry>[];
      final positions = <String>['BTN', 'BB'];
      final board = <String>[];
      final potHistory = <int>[10];

      final summary = await exportAnalyzedSession(
        actions: actions,
        analysis: analysis,
        positions: positions,
        board: board,
        potHistory: potHistory,
      );

      expect(summary, isNotNull);
      expect(summary.pathOriginal, isNotEmpty);
    });
  });
}
