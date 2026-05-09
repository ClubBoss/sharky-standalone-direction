import 'v4_token_registry.dart';

class V4VisualQASnapshotV1 {
  final Map<String, Object> snapshot;

  const V4VisualQASnapshotV1(this.snapshot);

  Map<String, Object> asMap() => <String, Object>{'snapshot': snapshot};

  static Map<String, Object> build() {
    const tokens = V4TokenRegistry();
    return <String, Object>{
      'snapshot': <String, Object>{
        'spacing_grid': <String, Object>{
          'xs': tokens.v4SpacingXS,
          's': tokens.v4SpacingS,
          'm': tokens.v4SpacingM,
          'l': tokens.v4SpacingL,
        },
        'radius_grid': <String, Object>{'m': tokens.v4RadiusM},
        'typography_grid': <String, Object>{
          'body_size': tokens.v4FontSizeBody,
          'title_size': tokens.v4FontSizeTitle,
          'body_letter': tokens.v4LetterSpacingBody,
          'title_letter': tokens.v4LetterSpacingTitle,
        },
        'icon_grid': <String, Object>{
          'size_s': tokens.v4IconSizeS,
          'size_m': tokens.v4IconSizeM,
          'size_l': tokens.v4IconSizeL,
          'padding': tokens.v4IconPadding,
        },
        'motion_grid': <String, Object>{
          'duration_xs': tokens.v4MotionDurationXS.inMilliseconds,
          'duration_s': tokens.v4MotionDurationS.inMilliseconds,
          'duration_m': tokens.v4MotionDurationM.inMilliseconds,
          'curve': 'easeInOut',
          'offset_xs': tokens.v4MotionOffsetXS,
          'offset_s': tokens.v4MotionOffsetS,
        },
        'metadata': 'placeholder_v4_visual_qa_snapshot_v1',
      },
    };
  }
}
