class ContentManifestV2 {
  final Map<String, Object> data;

  const ContentManifestV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({
    required String moduleId,
    required String version,
    required String theoryPath,
    required String drillsPath,
    required String recapPath,
    required String quizPath,
    required String footprintPath,
  }) {
    return <String, Object>{
      'content_manifest_v2': <String, Object>{
        'module_id': moduleId,
        'version': version,
        'paths': <String, String>{
          'theory': theoryPath,
          'drills': drillsPath,
          'recap': recapPath,
          'quiz': quizPath,
          'footprint': footprintPath,
        },
        'metadata': 'placeholder_content_manifest_v2',
      },
    };
  }
}
