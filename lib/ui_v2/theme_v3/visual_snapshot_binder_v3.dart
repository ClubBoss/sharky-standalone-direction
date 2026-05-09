import '../components_v3/base_component_v3.dart';

class VisualSnapshotBinderV3 {
  VisualSnapshotBinderV3();

  static const List<String> componentKeys = [
    'component.card.primary',
    'component.surface.primary',
    'component.panel.primary',
    'component.section.primary',
    'component.summary.primary',
    'component.chip.primary',
    'component.button.primary',
    'component.icon.primary',
  ];

  final Map<String, String> _baseline = {};
  bool _v4Active = false;

  Map<String, String> buildBaseline(Map<String, BaseComponentV3> components) {
    final baseline = <String, String>{};
    for (final key in componentKeys) {
      final style = components[key]?.appliedStyle;
      baseline[key] = style?.isNotEmpty == true ? style! : 'UNSET';
    }
    baseline['v4_active'] = _v4Active ? '1' : '0';
    return baseline;
  }

  Map<String, String> loadBaseline() {
    return _baseline.isEmpty ? {} : Map<String, String>.from(_baseline);
  }

  Map<String, String> compareToBaseline(
    Map<String, String> snapshot,
    Map<String, String> baseline,
  ) {
    final results = <String, String>{};
    for (final key in componentKeys) {
      if (!baseline.containsKey(key)) {
        results[key] = 'DIFF(new)';
        continue;
      }
      final value = baseline[key];
      if (snapshot[key] != value) {
        results[key] = value == null ? 'DIFF(new)' : 'DIFF(update)';
      } else {
        results[key] = 'OK';
      }
    }
    return results;
  }

  void writeBaseline(Map<String, String> baseline) {
    _baseline
      ..clear()
      ..addAll(baseline);
  }

  void createBaselineSnapshot() {}
  void loadBaselineSnapshot() {}
  void compareSnapshots() {}
  void writeDiffReport() {}

  void syncV4Activation(bool flag) => _v4Active = flag;

  bool getV4Activation() => _v4Active;
}
