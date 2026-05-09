import 'rc_packaging_manifest_v1.dart';
import 'rc_freeze_gate_v1.dart';
import 'release_notes_generator_v1.dart';

/// Provides the current RC packaging manifest entrypoint.
Map<String, Object?> buildRCPackagingManifest() => buildRCPackagingManifestV1();

/// Provides the deterministic RC freeze gate metadata.
Map<String, Object?> buildRCFreezeGate() => buildRCFreezeGateV1();

/// Provides RC release notes metadata for automation.
Map<String, Object?> buildReleaseNotes() => buildReleaseNotesV1();
