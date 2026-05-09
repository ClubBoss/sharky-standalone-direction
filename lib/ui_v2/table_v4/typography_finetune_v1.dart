class TypographyFineTuneV1 {
  const TypographyFineTuneV1();

  static Map<String, Object> build() {
    return <String, Object>{
      'typography_finetune_v1': <String, Object>{
        'font_scale_delta': 0.02,
        'letter_spacing_delta': 0.1,
        'weight_tweak': 1,
        'alpha_floor': 160,
        'alpha_ceiling': 230,
      },
    };
  }
}
