import 'package:flutter/widgets.dart';

// ignore: must_be_immutable
class PersonaUiLayerV3 extends StatelessWidget {
  PersonaUiLayerV3({super.key});

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

  static const Map<String, String> _fontMap = {
    'surface.base.1': 'font.body.sm',
    'surface.base.2': 'font.body.md',
    'surface.container.1': 'font.body.lg',
    'surface.container.2': 'font.title.sm',
    'surface.overlay.1': 'font.title.md',
    'surface.highlight.1': 'font.title.lg',
  };

  static const Map<String, String> _layoutMap = {
    'surface.base.1': 'layout.compact',
    'surface.base.2': 'layout.normal',
    'surface.container.1': 'layout.normal',
    'surface.container.2': 'layout.roomy',
    'surface.overlay.1': 'layout.compact',
    'surface.highlight.1': 'layout.roomy',
  };

  static const Map<String, double> _fusionMap = {
    'fusion.soft': 2.0,
    'fusion.medium': 4.0,
    'fusion.strong': 8.0,
    'fusion.none': 0.0,
  };

  static const Map<String, String> _roleMap = {
    'surface.base.1': 'role.primary',
    'surface.container.1': 'role.secondary',
    'surface.overlay.1': 'role.ghost',
    'surface.highlight.1': 'role.primary',
  };

  Color _backgroundColor = const Color(0xFFEEEDED);
  String _activeStyle = '';
  double _motionFactor = 1.0;
  double _interactionFactor = 1.0;
  double _paddingValue = 12.0;
  double _elevationFactor = 0.0;
  double _fusionFactor = 0.0;
  String _fontToken = 'font.body.sm';
  String _layoutToken = 'layout.normal';
  String _roleToken = 'role.primary';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _mapMargin(_layoutToken),
      alignment: _mapAlignment(_layoutToken),
      child: Opacity(
        opacity: _motionFactor * _interactionFactor,
        child: Container(
          padding: EdgeInsets.all(_paddingValue),
          decoration: BoxDecoration(
            color: _applyRoleFactor(_backgroundColor, _roleToken),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (_elevationFactor > 0)
                BoxShadow(
                  color: const Color(0x33000000),
                  blurRadius: _elevationFactor + _fusionFactor,
                  offset: Offset(0, (_elevationFactor + _fusionFactor) * 0.5),
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

  void initialize() {}
  void attachPersona() {}
  void attachTheme() {}
  void attachMotion() {}
  void attachAdaptiveHooks() {}
  void syncAll() {}

  void syncStyle(String style) {
    applyResolvedStyle(style);
    applyStyleTokens();
  }

  void applyResolvedStyle(String style) {
    _activeStyle = style;
  }

  void applyStyleTokens() {
    final surfaceToken = _segment(3);
    final motionToken = _segment(4);
    final fusionToken = _segment(5);
    _backgroundColor =
        _surfaceTokenMap[surfaceToken] ?? const Color(0xFFE0E0E0);
    _motionFactor = _motionTokenMap[motionToken] ?? 1.0;
    _interactionFactor = _mapInteraction(surfaceToken);
    _paddingValue = _spacingTokenMap[surfaceToken] ?? 12.0;
    _elevationFactor = _fusionMap[fusionToken] ?? 0.0;
    _fusionFactor = _fusionMap[fusionToken] ?? 0.0;
    _fontToken = _fontMap[surfaceToken] ?? 'font.body.sm';
    _layoutToken = _layoutMap[surfaceToken] ?? 'layout.normal';
    _roleToken = _roleMap[surfaceToken] ?? 'role.primary';
  }

  String _segment(int index) {
    final segments = _activeStyle.split('|');
    if (segments.length > index) return segments[index];
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

  double _mapInteraction(String token) {
    switch (token) {
      case 'surface.container.1':
      case 'surface.container.2':
        return 0.85;
      case 'surface.overlay.1':
        return 0.5;
      case 'surface.highlight.1':
        return 0.75;
      default:
        return 1.0;
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

  Color _applyRoleFactor(Color color, String token) {
    final hsl = HSLColor.fromColor(color);
    final factor = token == 'role.primary'
        ? 1.0
        : token == 'role.secondary'
        ? 0.85
        : 0.7;
    return hsl
        .withLightness((hsl.lightness * factor).clamp(0.0, 1.0))
        .toColor();
  }

  String getFusionCue() {
    if (_fusionFactor >= 8.0) return 'fusion.strong';
    if (_fusionFactor >= 4.0) return 'fusion.medium';
    if (_fusionFactor >= 2.0) return 'fusion.soft';
    return 'fusion.none';
  }
}
