import '../content_root.dart';

class TrainingPackTemplateV2PreWiringV1 {
  final Map<String, Object> prewired;

  const TrainingPackTemplateV2PreWiringV1(this.prewired);

  Map<String, Object> asMap() => <String, Object>{'prewired': prewired};

  static Map<String, Object> buildStub() {
    final Map<String, Object> binding = const ContentRoot()
        .buildGLBBindingSurfaceV1();
    return <String, Object>{
      'prewired': <String, Object>{
        'binding': binding,
        'pack_id': 'cash_l3_v1',
        'module_list': <String>['theory', 'drills', 'recap', 'quiz'],
        'presence_flags': <String, Object>{
          'theory': true,
          'drills': true,
          'recap': true,
          'quiz': true,
        },
        'template_hook': 'placeholder_pre_wiring_hook_v1',
        'status': 'stub_ready',
      },
    };
  }
}
