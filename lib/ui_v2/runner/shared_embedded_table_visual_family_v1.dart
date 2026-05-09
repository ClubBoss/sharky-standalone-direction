import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';

enum SharedEmbeddedTableVisualFamilyPresetV1 {
  world1LiveSceneOwned,
  world1LearnerEmbeddedStandard,
  world1LearnerEmbeddedCompactState,
  world1LearnerEmbeddedGuidedTeaching,
  surfacedLiveCompatible,
  surfacedLegacyEmbedded,
}

class SharedEmbeddedTableVisualFamilyContractV1 {
  const SharedEmbeddedTableVisualFamilyContractV1({
    required this.embeddedSceneGeometryProfileV1,
    required this.seatStateVisualProfileV1,
    required this.sceneLanePromptProfileV1,
    required this.useReferenceParityLiveProfileV1,
    required this.useSceneOwnedInstructionV1,
  });

  final ModernTableEmbeddedSceneGeometryProfileV1
  embeddedSceneGeometryProfileV1;
  final ModernTableSeatStateVisualProfileV1 seatStateVisualProfileV1;
  final ModernTableSceneLanePromptProfileV1 sceneLanePromptProfileV1;
  final bool useReferenceParityLiveProfileV1;
  final bool useSceneOwnedInstructionV1;

  SharedEmbeddedTableVisualFamilyContractV1 copyWith({
    ModernTableEmbeddedSceneGeometryProfileV1? embeddedSceneGeometryProfileV1,
    ModernTableSeatStateVisualProfileV1? seatStateVisualProfileV1,
    ModernTableSceneLanePromptProfileV1? sceneLanePromptProfileV1,
    bool? useReferenceParityLiveProfileV1,
    bool? useSceneOwnedInstructionV1,
  }) {
    return SharedEmbeddedTableVisualFamilyContractV1(
      embeddedSceneGeometryProfileV1:
          embeddedSceneGeometryProfileV1 ?? this.embeddedSceneGeometryProfileV1,
      seatStateVisualProfileV1:
          seatStateVisualProfileV1 ?? this.seatStateVisualProfileV1,
      sceneLanePromptProfileV1:
          sceneLanePromptProfileV1 ?? this.sceneLanePromptProfileV1,
      useReferenceParityLiveProfileV1:
          useReferenceParityLiveProfileV1 ??
          this.useReferenceParityLiveProfileV1,
      useSceneOwnedInstructionV1:
          useSceneOwnedInstructionV1 ?? this.useSceneOwnedInstructionV1,
    );
  }
}

const SharedEmbeddedTableVisualFamilyContractV1
_kSharedEmbeddedTableLiveBaselineV1 = SharedEmbeddedTableVisualFamilyContractV1(
  embeddedSceneGeometryProfileV1:
      ModernTableEmbeddedSceneGeometryProfileV1.screenOwnedLivePortrait,
  seatStateVisualProfileV1: ModernTableSeatStateVisualProfileV1.learnerEmbedded,
  sceneLanePromptProfileV1: ModernTableSceneLanePromptProfileV1.standard,
  useReferenceParityLiveProfileV1: false,
  useSceneOwnedInstructionV1: false,
);

SharedEmbeddedTableVisualFamilyContractV1
resolveSharedEmbeddedTableVisualFamilyV1({
  required SharedEmbeddedTableVisualFamilyPresetV1 preset,
}) {
  switch (preset) {
    case SharedEmbeddedTableVisualFamilyPresetV1.world1LiveSceneOwned:
      return _kSharedEmbeddedTableLiveBaselineV1.copyWith(
        useReferenceParityLiveProfileV1: true,
        useSceneOwnedInstructionV1: true,
      );
    case SharedEmbeddedTableVisualFamilyPresetV1.world1LearnerEmbeddedStandard:
      return const SharedEmbeddedTableVisualFamilyContractV1(
        embeddedSceneGeometryProfileV1:
            ModernTableEmbeddedSceneGeometryProfileV1.standard,
        seatStateVisualProfileV1:
            ModernTableSeatStateVisualProfileV1.learnerEmbedded,
        sceneLanePromptProfileV1: ModernTableSceneLanePromptProfileV1.standard,
        useReferenceParityLiveProfileV1: false,
        useSceneOwnedInstructionV1: false,
      );
    case SharedEmbeddedTableVisualFamilyPresetV1
        .world1LearnerEmbeddedCompactState:
      return const SharedEmbeddedTableVisualFamilyContractV1(
        embeddedSceneGeometryProfileV1:
            ModernTableEmbeddedSceneGeometryProfileV1.standard,
        seatStateVisualProfileV1:
            ModernTableSeatStateVisualProfileV1.learnerEmbedded,
        sceneLanePromptProfileV1:
            ModernTableSceneLanePromptProfileV1.compactStateOnly,
        useReferenceParityLiveProfileV1: false,
        useSceneOwnedInstructionV1: false,
      );
    case SharedEmbeddedTableVisualFamilyPresetV1
        .world1LearnerEmbeddedGuidedTeaching:
      return const SharedEmbeddedTableVisualFamilyContractV1(
        embeddedSceneGeometryProfileV1:
            ModernTableEmbeddedSceneGeometryProfileV1.standard,
        seatStateVisualProfileV1:
            ModernTableSeatStateVisualProfileV1.learnerEmbedded,
        sceneLanePromptProfileV1:
            ModernTableSceneLanePromptProfileV1.guidedTeaching,
        useReferenceParityLiveProfileV1: false,
        useSceneOwnedInstructionV1: false,
      );
    case SharedEmbeddedTableVisualFamilyPresetV1.surfacedLiveCompatible:
      return _kSharedEmbeddedTableLiveBaselineV1;
    case SharedEmbeddedTableVisualFamilyPresetV1.surfacedLegacyEmbedded:
      return const SharedEmbeddedTableVisualFamilyContractV1(
        embeddedSceneGeometryProfileV1:
            ModernTableEmbeddedSceneGeometryProfileV1.standard,
        seatStateVisualProfileV1: ModernTableSeatStateVisualProfileV1.dense,
        sceneLanePromptProfileV1: ModernTableSceneLanePromptProfileV1.standard,
        useReferenceParityLiveProfileV1: false,
        useSceneOwnedInstructionV1: false,
      );
  }
}
