class ContentSystemMasterObjectV1 {
  const ContentSystemMasterObjectV1();

  static Map<String, Object> build({
    required Map<String, Object> contentSystemGlobalAccessPointV1,
  }) {
    return {
      "content_system_master_object_v1": {
        "content_system_global_access_point_v1":
            contentSystemGlobalAccessPointV1,
      },
    };
  }
}
