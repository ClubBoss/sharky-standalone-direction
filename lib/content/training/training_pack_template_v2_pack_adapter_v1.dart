import '../content_root.dart';

class TrainingPackTemplateV2PackAdapterV1 {
  final Map<String, Object> adapter;

  const TrainingPackTemplateV2PackAdapterV1(this.adapter);

  Map<String, Object> asMap() => <String, Object>{'adapter': adapter};

  static Map<String, Object> buildStub() {
    final Map<String, Object> binder = const ContentRoot()
        .buildTrainingPackTemplateV2BinderV1();
    return <String, Object>{
      'adapter': <String, Object>{
        'binder': binder,
        'adapter_metadata': 'placeholder_adapter_metadata_v1',
        'manifest': <String, Object>{
          'modules': <String>['theory', 'drills', 'recap', 'quiz'],
          'version': 'v1',
        },
        'routing': 'placeholder_adapter_routing_v1',
        'status': 'stub_ready',
      },
    };
  }
}
