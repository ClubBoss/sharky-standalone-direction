class TypographyCompensationMapV1 {
  const TypographyCompensationMapV1();

  static Map<String, Object> build() {
    return <String, Object>{
      'typography_compensation_map_v1': <String, Object>{
        'weight_bias': -1,
        'scale_bias': 0.015,
        'letter_spacing_bias': 0.05,
        'alpha_bias': 5,
      },
    };
  }
}
