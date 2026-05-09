class CompositeIntegrityGateV1 {
  const CompositeIntegrityGateV1(this.fullCompositeMap);

  final Object fullCompositeMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> root = fullCompositeMap is Map
        ? (fullCompositeMap as Map).cast<String, Object>()
        : <String, Object>{};
    final List<String> sectionNames = <String>[
      'exportActivationSyncMap',
      'exportV4MaterializationMap',
      'exportTableSurfacePolishMap',
      'exportVisualBindingV1',
      'exportVisualFullPassV1',
      'exportAIPersonalizationTierAContext',
      'exportAIPersonalizationTierBBridge',
      'exportAIPersonalizationTierBAggregate',
      'exportAIPersonalizationTierBConsistency',
      'exportAIPersonalizationTierBOutput',
      'exportAIPersonalizationUIHookV1',
      'exportAIPersonalizationPreModulation',
      'exportAIPersonalizationModulationSeed',
      'exportAIPersonalizationModulationAlpha',
      'exportAIPersonalizationLightModulation',
      'exportAIPersonalizationMicroModulation',
      'exportAIPersonalizationAccentScaffold',
      'exportAIPersonalizationTempo',
      'exportAIPersonalizationFocus',
      'exportAIPersonalizationAdaptiveUIHooks',
      'exportAIPersonalizationAccentApplication',
      'exportAIPersonalizationTempoApplication',
      'exportAIPersonalizationFocusApplication',
      'exportAIPersonalizationPersonaHints',
      'exportAIPersonalizationPrevisualBridge',
      'exportAIPersonalizationTokenMap',
      'exportAIPersonalizationAccentPathways',
      'exportAIPersonalizationScalingPathways',
      'exportAIPersonalizationAdaptiveMerge',
      'exportAIPersonalizationUIPersonalityHints',
      'exportAIPersonalizationBehavioralGradient',
      'exportAIPersonalizationAccentLiftV1',
      'exportAIPersonalizationAccentApplicationV2',
      'exportAIPersonalizationAccentMergeV3',
      'exportAIPersonalizationAccentDeltaV1',
      'exportAIPersonalizationAccentInjectionV1',
      'exportAIPersonalizationAccentNormalizeV1',
      'exportAIPersonalizationAccentRoutingV1',
      'exportTableBoardLayoutV1',
      'exportCardLayoutV2',
      'exportCardRenderParamsV1',
      'exportCardVectorPrimitivesV1',
      'exportCardVectorShapesV1',
      'exportCardFaceComposerV1',
      'exportCardBackV1',
      'exportCardRenderOrchestratorV1',
      'exportTablePreviewRendererV1',
      'exportPreviewIntegrationBridgeV1',
      'exportFakeHandPreviewV1',
      'exportTableBoardAdaptiveLayoutV1',
      'exportTableBoardAdaptiveLayoutV2',
      'exportTableSurfaceTokensV1',
      'exportTableCompositionFrameV1',
      'exportTableInteractionZonesV1',
      'exportActionButtonsGeometryV1',
      'exportChipsPotGeometryV1',
      'exportTableHighlightsV1',
      'exportTableDepthMappingV1',
      'exportTableVisualSnapshotV1',
      'exportTableUIHandoffV1',
      'exportTableUIFinalCompositionV1',
      'exportTableRenderContextV1',
      'exportTableRenderSpecV1',
      'exportTableRenderEnvelopeV1',
      'exportTableViewSkeletonV1',
      'exportTableViewShellV1',
      'exportTableContextBridgeV1',
      'exportTablePersonalizationBridgeV1',
      'exportTableHintMapV1',
      'exportTableFusionPersonaV1',
      'exportTableAdaptivePersonaSpecV1',
      'exportTableFusionConsistencyQAV1',
      'exportTableUIPersonalitySealV1',
      'exportTablePersonalityRenderContextV1',
      'exportTablePersonalityEnvelopeV1',
      'exportTableBehaviorSeedV1',
      'exportTableBehaviorModulationV1',
      'exportTableBehaviorTraitsV1',
      'exportTableBehaviorSpecV1',
      'exportTableBehaviorConsistencyQAV1',
      'exportTableBehaviorEnvelopeV1',
      'exportTableBehaviorFinalizerV1',
      'exportTableBehaviorUIMapV1',
      'exportTableBehaviorDiffuserV1',
      'exportTablePersonaSyncSealV1',
      'exportTablePersonaBlendV1',
      'exportTablePersonaUISnapshotV1',
      'exportTableSoftIntegrationGateV1',
    ];
    final Map<String, Map<String, Object>> sections =
        <String, Map<String, Object>>{};
    final List<String> missing = <String>[];
    final List<String> invalid = <String>[];
    for (final String name in sectionNames) {
      final Object? value = root[name];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = value is Map && value.isNotEmpty;
      sections[name] = <String, Object>{
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
      };
      if (!exists) missing.add(name);
      if (exists && (!isMap || !nonEmpty)) invalid.add(name);
    }
    final bool ready = missing.isEmpty && invalid.isEmpty;
    return <String, Object>{
      'composite_integrity_gate_v1': <String, Object>{
        'sections': sections,
        'missing': missing,
        'invalid': invalid,
        'gate_ready': ready,
      },
      'readiness': ready,
    };
  }
}
