class StabilityQAFrameV1 {
  const StabilityQAFrameV1();

  static Map<String, Object> build({
    required Map<String, Object> stabilityQAShellV1,
  }) {
    return {
      "stability_qa_frame_v1": {"stability_qa_shell_v1": stabilityQAShellV1},
    };
  }
}
