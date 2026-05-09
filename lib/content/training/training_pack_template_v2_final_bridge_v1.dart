import '../content_root.dart';

class TrainingPackTemplateV2FinalBridgeV1 {
  final Map<String, Object> finalBridge;

  const TrainingPackTemplateV2FinalBridgeV1(this.finalBridge);

  Map<String, Object> asMap() => <String, Object>{'final_bridge': finalBridge};

  static Map<String, Object> buildStub() {
    const ContentRoot root = ContentRoot();
    final Map<String, Object> adapter = root
        .buildTrainingPackTemplateV2PackAdapterV1();
    final Map<String, Object> binder = root
        .buildTrainingPackTemplateV2BinderV1();
    final Map<String, Object> prewired = root
        .buildTrainingPackTemplateV2PreWiringV1();
    final Map<String, Object> binding = root.buildGLBBindingSurfaceV1();
    final Map<String, Object> normalized = root.buildGLBNormalizationStubV1();
    final Map<String, Object> master = root.buildGLBMasterExportV1();

    return <String, Object>{
      'final_bridge': <String, Object>{
        'adapter': adapter,
        'binder': binder,
        'prewired': prewired,
        'binding': binding,
        'normalized': normalized,
        'master': master,
        'metadata': 'placeholder_training_pack_template_v2_final_bridge_v1',
        'status': 'stub_ready',
      },
    };
  }
}
