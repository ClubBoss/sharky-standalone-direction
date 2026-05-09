/// Compatibility shim for modules migrating to the v2 models namespace.
///
/// Historically training pack flows referenced `models/v2/training_spot.dart`
/// even though the canonical implementation lived in `models/training_spot.dart`.
/// This file re-exports the v1 implementation so existing imports continue to
/// compile while the Adaptive Content Loop v1 rolls out.
export '../training_spot.dart' show SpotActionType, TrainingSpot;
