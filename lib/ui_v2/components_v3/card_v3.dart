import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class CardV3 extends StatelessWidget {
  CardV3({super.key});

  static const Map<String, Color> _surfaceTokenMap = {
    'color.primary': Color(0xFF3366FF),
    'color.container': Color(0xFFF2F4F8),
    'color.background': Color(0xFFFFFFFF),
    'color.accent': Color(0xFFFFAA33),
  };

  static const Map<String, double> _motionTokenMap = {
    'motion.fade': 0.3,
    'motion.slide': 0.5,
    'motion.scale': 0.4,
    'motion.none': 0.0,
  };

  static const Map<String, double> _spacingTokenMap = {
    'spacing.xs': 4.0,
    'spacing.sm': 8.0,
    'spacing.md': 12.0,
    'spacing.lg': 16.0,
    'spacing.xl': 20.0,
    'spacing.xxl': 28.0,
  };

  static const Map<String, String> _typographyTokenMap = {
    'surface.base.1': 'font.body.sm',
    'surface.base.2': 'font.body.md',
    'surface.container.1': 'font.body.lg',
    'surface.container.2': 'font.title.sm',
    'surface.overlay.1': 'font.title.md',
    'surface.highlight.1': 'font.title.lg',
  };

  static const Map<String, String> _layoutTokenMap = {
    'surface.base.1': 'layout.compact',
    'surface.base.2': 'layout.normal',
    'surface.container.1': 'layout.normal',
    'surface.container.2': 'layout.roomy',
    'surface.overlay.1': 'layout.compact',
    'surface.highlight.1': 'layout.roomy',
  };

  static const Map<String, double> _fusionTokenMap = {
    'fusion.soft': 2.0,
    'fusion.medium': 4.0,
    'fusion.strong': 8.0,
    'fusion.none': 0.0,
  };

  static const Map<String, String> _interactionTokenMap = {
    'surface.base.1': 'interaction.idle',
    'surface.base.2': 'interaction.idle',
    'surface.container.1': 'interaction.press',
    'surface.container.2': 'interaction.active',
    'surface.overlay.1': 'interaction.disabled',
    'surface.highlight.1': 'interaction.active',
  };

  static const Map<String, String> _roleTokenMap = {
    'surface.base.1': 'role.primary',
    'surface.container.1': 'role.secondary',
    'surface.overlay.1': 'role.ghost',
    'surface.highlight.1': 'role.primary',
  };

  Color _backgroundColor = const Color(0xFFFFFFFF);
  String _activeStyle = '';
  double _motionFactor = 1.0;
  double _paddingValue = 16.0;
  double _elevationFactor = 0.0;
  String _fontToken = 'font.body.sm';
  String _layoutToken = 'layout.normal';
  String _interactionToken = 'interaction.idle';
  String _roleToken = 'role.primary';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _mapMargin(_layoutToken),
      alignment: _mapAlignment(_layoutToken),
      child: Opacity(
        opacity: _motionFactor * _mapInteractionFactor(_interactionToken),
        child: Container(
          padding: EdgeInsets.all(_paddingValue),
          decoration: BoxDecoration(
            color: _applyRoleFactor(_backgroundColor, _roleToken),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (_elevationFactor > 0)
                BoxShadow(
                  color: const Color(0x33000000),
                  blurRadius: _elevationFactor,
                  offset: Offset(0, _elevationFactor * 0.5),
                ),
            ],
          ),
          child: Text(
            _fontToken,
            style: TextStyle(
              fontSize: _mapFontSize(_fontToken),
              fontWeight: _mapFontWeight(_fontToken),
            ),
          ),
        ),
      ),
    );
  }

  void syncStyle(String style) {
    applyResolvedStyle(style);
    applyStyleTokens();
  }

  void applyResolvedStyle(String style) {
    _activeStyle = style;
  }

  void applyStyleTokens() {
    final surfaceToken = _extractSurfaceToken();
    final motionToken = _extractMotionToken();
    final fusionToken = _extractFusionToken();
    _backgroundColor =
        _surfaceTokenMap[surfaceToken] ?? const Color(0xFFE0E0E0);
    _motionFactor = _motionTokenMap[motionToken] ?? 0.0;
    _paddingValue = _spacingTokenMap[surfaceToken] ?? 12.0;
    _elevationFactor = _fusionTokenMap[fusionToken] ?? 0.0;
    _fontToken = _typographyTokenMap[surfaceToken] ?? 'font.body.sm';
    _layoutToken = _layoutTokenMap[surfaceToken] ?? 'layout.normal';
    _interactionToken =
        _interactionTokenMap[surfaceToken] ?? 'interaction.idle';
    _roleToken = _roleTokenMap[surfaceToken] ?? 'role.primary';
  }

  String _extractSurfaceToken() {
    final segments = _activeStyle.split('|');
    if (segments.length > 3) return segments[3];
    return '';
  }

  String _extractMotionToken() {
    final segments = _activeStyle.split('|');
    if (segments.length > 4) return segments[4];
    return '';
  }

  String _extractFusionToken() {
    final segments = _activeStyle.split('|');
    if (segments.length > 5) return segments[5];
    return '';
  }

  double _mapFontSize(String token) {
    switch (token) {
      case 'font.body.sm':
        return 12;
      case 'font.body.md':
        return 14;
      case 'font.body.lg':
        return 16;
      case 'font.title.sm':
        return 18;
      case 'font.title.md':
        return 20;
      case 'font.title.lg':
        return 24;
      default:
        return 12;
    }
  }

  FontWeight _mapFontWeight(String token) {
    switch (token) {
      case 'font.body.sm':
      case 'font.body.md':
      case 'font.body.lg':
        return FontWeight.w400;
      case 'font.title.sm':
        return FontWeight.w500;
      case 'font.title.md':
        return FontWeight.w600;
      case 'font.title.lg':
        return FontWeight.w700;
      default:
        return FontWeight.w400;
    }
  }

  EdgeInsets _mapMargin(String token) {
    switch (token) {
      case 'layout.compact':
        return const EdgeInsets.all(4);
      case 'layout.roomy':
        return const EdgeInsets.all(16);
      case 'layout.normal':
      default:
        return const EdgeInsets.all(8);
    }
  }

  Alignment _mapAlignment(String token) {
    switch (token) {
      case 'layout.roomy':
        return Alignment.topCenter;
      case 'layout.compact':
      case 'layout.normal':
      default:
        return Alignment.center;
    }
  }

  double _mapInteractionFactor(String token) {
    switch (token) {
      case 'interaction.press':
        return 0.9;
      case 'interaction.active':
        return 0.8;
      case 'interaction.disabled':
        return 0.4;
      case 'interaction.idle':
      default:
        return 1.0;
    }
  }

  double _mapRoleFactor(String token) {
    switch (token) {
      case 'role.secondary':
        return 0.85;
      case 'role.ghost':
        return 0.70;
      case 'role.primary':
      default:
        return 1.0;
    }
  }

  Color _applyRoleFactor(Color color, String token) {
    final factor = _mapRoleFactor(token);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * factor).clamp(0.0, 1.0))
        .toColor();
  }
}
