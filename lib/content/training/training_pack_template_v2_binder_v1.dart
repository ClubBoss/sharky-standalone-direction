import '../content_root.dart';

class TrainingPackTemplateV2BinderV1 {
  final Map<String, Object> binder;

  const TrainingPackTemplateV2BinderV1(this.binder);

  Map<String, Object> asMap() => <String, Object>{'binder': binder};

  static Map<String, Object> buildStub() {
    final Map<String, Object> prewired = const ContentRoot()
        .buildTrainingPackTemplateV2PreWiringV1();
    return <String, Object>{
      'binder': <String, Object>{
        'prewired': prewired,
        'binder_metadata': 'placeholder_binder_metadata_v1',
        'glue': 'placeholder_binder_glue_v1',
        'status': 'stub_ready',
      },
    };
  }
}
