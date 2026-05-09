import 'package:flutter/material.dart';

import '../../engine/action_bar_engine.dart';
import 'action_bar_model.dart';
import '../components/design_button.dart';
import '../design/design_containers.dart';
import '../design/design_layout.dart';
import '../design/design_typography.dart';
import '../design/design_tokens.dart';
import 'bet_slider.dart';
import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

class ActionSurface extends StatefulWidget {
  const ActionSurface({
    required this.model,
    this.onAction,
    this.onSelectRaise,
    this.confirmPanelVisible = false,
    super.key,
  });

  final ActionBarModel model;
  final void Function(ActionBarIntent)? onAction;
  final ValueChanged<double>? onSelectRaise;
  final bool confirmPanelVisible;

  @override
  State<ActionSurface> createState() => _ActionSurfaceState();
}

class _ActionSurfaceState extends State<ActionSurface> {
  double _sliderValue = 50.0;
  bool _interactionLocked = false;
  DateTime? _lastTap;
  static const _cooldown = Duration(milliseconds: 180);
  @override
  Widget build(BuildContext context) {
    const width = 320.0;
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.all(VisualThemeV3.spacingM),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
        boxShadow: const [VisualThemeV3.shadowLight],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    context,
                    label: 'Fold',
                    enabled:
                        widget.model.canFold && !widget.confirmPanelVisible,
                    onPressed: () => _handleButtonTap(
                      widget.model.canFold,
                      () =>
                          widget.onAction?.call(const ActionBarIntent('fold')),
                    ),
                    background: VisualThemeV3.accentSecondary,
                    textColor: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: VisualThemeV3.spacingM),
                  _buildActionButton(
                    context,
                    label: 'Call',
                    enabled:
                        widget.model.canCall && !widget.confirmPanelVisible,
                    onPressed: () => _handleButtonTap(
                      widget.model.canCall,
                      () =>
                          widget.onAction?.call(const ActionBarIntent('call')),
                    ),
                    background: VisualThemeV3.accent,
                    textColor: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(width: VisualThemeV3.spacingM),
                  _buildActionButton(
                    context,
                    label: 'Raise',
                    enabled:
                        widget.model.canRaise && !widget.confirmPanelVisible,
                    onPressed: () => _handleButtonTap(
                      widget.model.canRaise,
                      () => _trySelect(_sliderValue),
                    ),
                    background: VisualThemeV3.accent,
                    textColor: theme.colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (widget.model.legalRaise)
            Column(
              children: [
                const SizedBox(height: DesignLayout.sectionSpacing),
                if (widget.model.presets.isNotEmpty)
                  Wrap(
                    spacing: DesignLayout.itemSpacing,
                    runSpacing: DesignLayout.itemSpacing,
                    alignment: WrapAlignment.center,
                    children: widget.model.presets.map(_buildPreset).toList(),
                  ),
                const SizedBox(height: DesignLayout.sectionSpacing),
                BetSlider(value: _sliderValue, onChanged: _setSliderValue),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPreset(RaisePreset preset) {
    final enabled = !widget.confirmPanelVisible;
    return DesignButton(
      label: preset.label,
      enabled: enabled,
      onPressed: () {
        if (!enabled) return;
        _setSliderValue(preset.value);
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
    required Color background,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
        boxShadow: enabled ? const [VisualThemeV3.shadowLight] : null,
      ),
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: VisualThemeV3.spacingL,
            vertical: VisualThemeV3.spacingS,
          ),
          backgroundColor: enabled
              ? background
              : textColor.withValues(alpha: 0.12),
          foregroundColor: enabled ? textColor : textColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius / 2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: enabled ? textColor : textColor.withOpacity(0.65),
          ),
        ),
      ),
    );
  }

  void _setSliderValue(double next) {
    if (widget.confirmPanelVisible) {
      return;
    }
    final snapped = _snapToPreset(next);
    if (snapped == _sliderValue) {
      return;
    }
    setState(() => _sliderValue = snapped);
    _trySelect(snapped);
  }

  double _snapToPreset(double value) {
    for (final preset in widget.model.presets) {
      final distance = ((preset.value - value) / 100).abs();
      if (distance <= 0.05) {
        return preset.value;
      }
    }
    return value;
  }

  void _trySelect(double value) {
    if (_interactionLocked || !widget.model.canRaise) {
      return;
    }
    _interactionLocked = true;
    widget.onSelectRaise?.call(value);
  }

  void _handleButtonTap(bool enabled, VoidCallback action) {
    if (!enabled || widget.confirmPanelVisible) {
      return;
    }
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < _cooldown) {
      return;
    }
    _lastTap = now;
    action();
  }

  @override
  void didUpdateWidget(ActionSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.confirmPanelVisible && oldWidget.confirmPanelVisible) {
      _interactionLocked = false;
    }
  }
}

class RaiseConfirmPanel extends StatelessWidget {
  const RaiseConfirmPanel({
    required this.amount,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final double amount;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 288,
      padding: const EdgeInsets.all(DesignLayout.sectionSpacing),
      decoration: DesignContainers.panel.copyWith(
        color: Color(DesignColors.surfaceElevated),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Confirm Raise: ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: DesignTypography.body,
              color: Color(DesignColors.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current: ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: DesignTypography.caption,
              color: Color(DesignColors.textSecondary),
            ),
          ),
          const SizedBox(height: DesignLayout.vspaceMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DesignButton(label: 'Cancel', onPressed: onCancel),
              DesignButton(label: 'Confirm', onPressed: onConfirm),
            ],
          ),
        ],
      ),
    );
  }
}
