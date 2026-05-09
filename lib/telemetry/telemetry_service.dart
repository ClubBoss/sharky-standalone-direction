import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

import 'persona_activation_snapshot_v4.dart';

class TelemetryService {
  TelemetryService._();

  static final TelemetryService instance = TelemetryService._();

  Future<void> logV4ThemeToggled(bool active) =>
      FirebaseLiteTelemetryService.instance.logEvent(
        'v4_theme_toggle',
        params: <String, Object?>{'event': 'v4_theme_toggle', 'active': active},
      );

  Map<String, Object?>? _lastActivationSnapshot;

  Future<void> logPersonaActivationSnapshotV4(
    PersonaActivationSnapshotV4 snapshot,
  ) async {
    _lastActivationSnapshot = snapshot.asReadOnlyMap();
  }

  Map<String, Object?> exportPersonaActivationSnapshotV4() {
    return _lastActivationSnapshot ?? <String, Object?>{};
  }

  Map<String, Object?> preparePersonaActivationSnapshotV4ForExport() {
    return exportPersonaActivationSnapshotV4();
  }
}
